--[[
    ===================================================================
    Dungeon Slayer: Reborn - Sistema de Waves e Arena (WaveSystem)
    Arquivo: src/server/WaveSystem.server.lua
    ===================================================================
    Descrição:
    Este script controla o fluxo principal da Arena 1 - Criptas Esquecidas:
      1. 5 Waves progressivas de esqueletos com dificuldade crescente.
      2. Entrega da classe Guerreiro (Espada com Ataque Básico + Giro Whirlwind).
      3. Sistema de Reviver com 50% de vida (gancho para o Dev Product com Robux).
      4. Integração na Wave 5 com o BossSystem.
--]]

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local CENTRO_ARENA = Vector3.new(0, 5, 0)
local RAIO_SPAWN = 25

local waveAtual = 1
local MAX_WAVES = 5
local inimigosVivos = 0

-- SISTEMA DE CLASSE: GUERREIRO
local function criarEspadaGuerreiro()
    local tool = Instance.new("Tool")
    tool.Name = "Espada do Guerreiro"
    tool.ToolTip = "Ataque Básico (Clique) | Golpe de Giro (Ativação)"
    tool.CanBeDropped = false

    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(1, 4, 1)
    handle.BrickColor = BrickColor.new("Silver")
    handle.Material = Enum.Material.Metal
    handle.Parent = tool

    local ponta = Instance.new("Part")
    ponta.Name = "Lamina"
    ponta.Size = Vector3.new(0.5, 3, 0.5)
    ponta.BrickColor = BrickColor.new("Cyan")
    ponta.Material = Enum.Material.Neon
    ponta.CanCollide = false
    ponta.Parent = tool

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = handle
    weld.Part1 = ponta
    weld.Parent = handle

    local scriptEspada = Instance.new("Script")
    scriptEspada.Name = "LogicaGuerreiro"
    scriptEspada.Source = [[
        local tool = script.Parent
        local handle = tool:WaitForChild("Handle")
        local podeAtacar = true

        tool.Activated:Connect(function()
            if not podeAtacar then return end
            podeAtacar = false

            local char = tool.Parent
            local humanoid = char:FindFirstChild("Humanoid")
            if not humanoid then podeAtacar = true return end

            local conexao
            conexao = handle.Touched:Connect(function(hit)
                local inimigoChar = hit.Parent
                if inimigoChar and inimigoChar ~= char then
                    local inimigoHum = inimigoChar:FindFirstChild("Humanoid")
                    if inimigoHum and inimigoHum.Health > 0 then
                        inimigoHum:TakeDamage(25)
                        print("[Guerreiro] Golpe de espada causou 25 de dano!")
                    end
                end
            end)

            task.wait(0.5)
            conexao:Disconnect()
            podeAtacar = true
        end)

        task.spawn(function()
            while tool and tool.Parent do
                task.wait(8)
                local char = tool.Parent
                local root = char:FindFirstChild("HumanoidRootPart")
                if root and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                    local anelGiro = Instance.new("Part")
                    anelGiro.Shape = Enum.PartType.Cylinder
                    anelGiro.Size = Vector3.new(0.5, 16, 16)
                    anelGiro.CFrame = root.CFrame * CFrame.Angles(0, 0, math.rad(90))
                    anelGiro.BrickColor = BrickColor.new("Cyan")
                    anelGiro.Material = Enum.Material.Neon
                    anelGiro.Transparency = 0.4
                    anelGiro.Anchored = true
                    anelGiro.CanCollide = false
                    anelGiro.Parent = workspace
                    game:GetService("Debris"):AddItem(anelGiro, 0.4)

                    for _, objeto in ipairs(workspace:GetChildren()) do
                        if objeto:FindFirstChild("Humanoid") and objeto ~= char then
                            local rootInimigo = objeto:FindFirstChild("HumanoidRootPart")
                            if rootInimigo and (rootInimigo.Position - root.Position).Magnitude <= 14 then
                                objeto.Humanoid:TakeDamage(50)
                            end
                        end
                    end
                end
            end
        end)
    ]]
    scriptEspada.Parent = tool

    return tool
end

local function equiparGuerreiro(jogador)
    jogador.CharacterAdded:Connect(function(personagem)
        task.wait(0.5)
        local espada = criarEspadaGuerreiro()
        espada.Parent = jogador.Backpack

        local humanoid = personagem:WaitForChild("Humanoid")
        humanoid.Died:Connect(function()
            print("[Reviver] O jogador " .. jogador.Name .. " caiu em combate!")
            
            task.delay(1, function()
                if jogador:FindFirstChild("PlayerGui") then
                    local guiReviver = Instance.new("ScreenGui")
                    guiReviver.Name = "ReviverGui"
                    guiReviver.ResetOnSpawn = true
                    guiReviver.Parent = jogador.PlayerGui

                    local botao = Instance.new("TextButton")
                    botao.Size = UDim2.new(0, 240, 0, 60)
                    botao.Position = UDim2.new(0.5, -120, 0.7, 0)
                    botao.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
                    botao.Text = "★ Reviver na Arena (50% HP) ★"
                    botao.TextColor3 = Color3.fromRGB(255, 255, 255)
                    botao.Font = Enum.Font.SourceSansBold
                    botao.TextSize = 16
                    botao.Parent = guiReviver

                    botao.MouseButton1Click:Connect(function()
                        guiReviver:Destroy()
                        print("[Reviver] Jogador reviveu na arena!")
                        jogador:LoadCharacter()
                        task.wait(0.3)
                        if jogador.Character and jogador.Character:FindFirstChild("Humanoid") then
                            jogador.Character.Humanoid.Health = jogador.Character.Humanoid.MaxHealth * 0.5
                            local esp = criarEspadaGuerreiro()
                            esp.Parent = jogador.Backpack
                        end
                    end)
                end
            end)
        end)
    end)
end

Players.PlayerAdded:Connect(equiparGuerreiro)
for _, jog in ipairs(Players:GetPlayers()) do
    equiparGuerreiro(jog)
end

-- SPAWN DOS ESQUELETOS (WAVES 1 A 4)
local function spawnEsqueleto(nivelWave)
    local angulo = math.random() * math.pi * 2
    local distancia = math.random(8, RAIO_SPAWN)
    local posSpawn = CENTRO_ARENA + Vector3.new(math.cos(angulo) * distancia, 2, math.sin(angulo) * distancia)

    local esqueleto = Instance.new("Model")
    esqueleto.Name = "Esqueleto (Wave " .. nivelWave .. ")"

    local root = Instance.new("Part")
    root.Name = "HumanoidRootPart"
    root.Size = Vector3.new(2, 4, 1.5)
    root.Position = posSpawn
    root.BrickColor = BrickColor.new("White")
    root.Material = Enum.Material.Bone
    root.CanCollide = true
    root.Parent = esqueleto

    local humanoid = Instance.new("Humanoid")
    local vidaBase = 40 + (nivelWave * 15)
    humanoid.MaxHealth = vidaBase
    humanoid.Health = vidaBase
    humanoid.WalkSpeed = 10 + (nivelWave * 1.5)
    humanoid.Parent = esqueleto

    esqueleto.PrimaryPart = root
    esqueleto.Parent = Workspace

    task.spawn(function()
        while esqueleto and esqueleto.Parent and humanoid.Health > 0 do
            local alvoMaisProximo = nil
            local menorDistancia = math.huge

            for _, jog in ipairs(Players:GetPlayers()) do
                if jog.Character and jog.Character:FindFirstChild("HumanoidRootPart") then
                    local h = jog.Character:FindFirstChild("Humanoid")
                    if h and h.Health > 0 then
                        local dist = (jog.Character.HumanoidRootPart.Position - root.Position).Magnitude
                        if dist < menorDistancia then
                            menorDistancia = dist
                            alvoMaisProximo = jog.Character
                        end
                    end
                end
            end

            if alvoMaisProximo and alvoMaisProximo:FindFirstChild("HumanoidRootPart") then
                humanoid:MoveTo(alvoMaisProximo.HumanoidRootPart.Position)
                if menorDistancia <= 3.5 then
                    local humAlvo = alvoMaisProximo:FindFirstChild("Humanoid")
                    if humAlvo then
                        humAlvo:TakeDamage(8 + (nivelWave * 2))
                        task.wait(1.2)
                    end
                end
            end
            task.wait(0.4)
        end
    end)

    humanoid.Died:Connect(function()
        inimigosVivos = inimigosVivos - 1
        print("[WaveSystem] Esqueleto derrotado! Restam: " .. inimigosVivos)

        for _, jog in ipairs(Players:GetPlayers()) do
            if _G.AdicionarMoedas then
                _G.AdicionarMoedas(jog, 5)
            end
        end

        task.wait(1.5)
        if esqueleto then esqueleto:Destroy() end
    end)

    inimigosVivos = inimigosVivos + 1
end

-- LOOP PRINCIPAL DA ARENA
task.spawn(function()
    task.wait(4)
    print("[WaveSystem] Iniciando Arena 1: Criptas Esquecidas!")

    for w = 1, MAX_WAVES do
        waveAtual = w
        print("--------------------------------------------------")
        print("★ INICIANDO WAVE " .. waveAtual .. " DE " .. MAX_WAVES .. " ★")
        print("--------------------------------------------------")

        if waveAtual < 5 then
            local qtdInimigos = 3 + (waveAtual * 2)
            for i = 1, qtdInimigos do
                spawnEsqueleto(waveAtual)
                task.wait(0.6)
            end

            while inimigosVivos > 0 do
                task.wait(0.5)
            end

            print("[WaveSystem] Wave " .. waveAtual .. " concluída com sucesso!")
            task.wait(3)
        else
            print("[WaveSystem] ATENÇÃO! A WAVE 5 É O CHEFE FINAL!")
            if _G.IniciarLutaBoss then
                _G.IniciarLutaBoss(CENTRO_ARENA + Vector3.new(0, 4, 0), function()
                    print("==================================================")
                    print("★ ARENA 1 CONCLUÍDA! PARABÉNS GUERREIROS! ★")
                    print("==================================================")
                end)
            else
                warn("[WaveSystem] BossSystem não encontrado!")
            end
        end
    end
end)

print("[WaveSystem] Sistema de Waves da Arena 1 carregado com sucesso!")
