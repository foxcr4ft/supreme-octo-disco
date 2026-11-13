--[[
    ===================================================================
    Dungeon Slayer: Reborn - Sistema de Waves e Arena (WaveSystem)
    Arquivo: src/server/WaveSystem.server.lua
    ===================================================================
    Este script cuida APENAS de:
      1. 5 Waves progressivas de esqueletos com dificuldade crescente.
      2. Sistema de Reviver com 50% de vida (ResetOnSpawn = false).
      3. Premiação de moedas apenas para o jogador que derrotou o inimigo.
      4. Integração na Wave 5 com o BossSystem.

    A espada NÃO fica aqui. Ela mora em src/server/SwordSystem.server.lua.
    Quando precisa, este script apenas pede a entrega com _G.EntregarEspada.
--]]

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local CENTRO_ARENA = Vector3.new(0, 5, 0)
local RAIO_SPAWN = 25

local waveAtual = 1
local MAX_WAVES = 5
local inimigosVivos = 0

--[[
    ===================================================================
    SISTEMA DE REVIVER E CONTROLE DE SPAWN
    ===================================================================
--]]
local function configurarJogador(jogador)
    -- Cria a interface de reviver com ResetOnSpawn = false para não sumir ao renascer
    local function obterOuCriarGuiReviver()
        local playerGui = jogador:WaitForChild("PlayerGui")
        local guiReviver = playerGui:FindFirstChild("ReviverGui")

        if not guiReviver then
            guiReviver = Instance.new("ScreenGui")
            guiReviver.Name = "ReviverGui"
            guiReviver.ResetOnSpawn = false -- GUI NÃO some ao renascer
            guiReviver.Enabled = false
            guiReviver.Parent = playerGui

            local botao = Instance.new("TextButton")
            botao.Name = "BotaoReviver"
            botao.Size = UDim2.new(0, 260, 0, 60)
            botao.Position = UDim2.new(0.5, -130, 0.7, 0)
            botao.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
            botao.Text = "★ Reviver na Arena (50% HP) ★"
            botao.TextColor3 = Color3.fromRGB(255, 255, 255)
            botao.Font = Enum.Font.SourceSansBold
            botao.TextSize = 16
            botao.Parent = guiReviver

            botao.MouseButton1Click:Connect(function()
                guiReviver.Enabled = false -- Oculta a janela ao reviver
                print("[Reviver] O jogador " .. jogador.Name .. " usou o reviver!")

                jogador:LoadCharacter()
                task.wait(0.3)

                if jogador.Character and jogador.Character:FindFirstChild("Humanoid") then
                    jogador.Character.Humanoid.Health = jogador.Character.Humanoid.MaxHealth * 0.5
                    -- A espada é responsabilidade do SwordSystem
                    if _G.EntregarEspada then
                        _G.EntregarEspada(jogador)
                    end
                end
            end)
        end

        return guiReviver
    end

    jogador.CharacterAdded:Connect(function(personagem)
        local guiReviver = obterOuCriarGuiReviver()
        guiReviver.Enabled = false -- Começa oculta enquanto vivo

        local humanoid = personagem:WaitForChild("Humanoid")
        humanoid.Died:Connect(function()
            print("[Reviver] O jogador " .. jogador.Name .. " caiu em combate!")
            task.delay(1, function()
                if guiReviver then
                    guiReviver.Enabled = true -- Mostra o botão de reviver
                end
            end)
        end)
    end)
end

Players.PlayerAdded:Connect(configurarJogador)
for _, jog in ipairs(Players:GetPlayers()) do
    configurarJogador(jog)
end

--[[
    ===================================================================
    SPAWN DOS ESQUELETOS (WAVES 1 A 4)
    ===================================================================
--]]
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
    root.Material = Enum.Material.Plastic
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

    -- IA de perseguição do esqueleto ao jogador mais próximo
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

    -- Morte do esqueleto: premia moedas APENAS para quem matou
    humanoid.Died:Connect(function()
        inimigosVivos = inimigosVivos - 1
        print("[WaveSystem] Esqueleto derrotado! Restam: " .. inimigosVivos)

        -- Identifica o jogador que causou o golpe final pela tag "creator"
        local tagCriador = humanoid:FindFirstChild("creator")
        if tagCriador and tagCriador.Value and tagCriador.Value:IsA("Player") then
            local jogadorMatador = tagCriador.Value
            if _G.AdicionarMoedas then
                _G.AdicionarMoedas(jogadorMatador, 5)
                print("[WaveSystem] +5 moedas para quem matou: " .. jogadorMatador.Name)
            end
        else
            print("[WaveSystem] Abate sem tag creator. Ninguém recebeu moedas.")
        end

        task.wait(1.5)
        if esqueleto then
            esqueleto:Destroy()
        end
    end)

    inimigosVivos = inimigosVivos + 1
end

--[[
    ===================================================================
    LOOP PRINCIPAL DA ARENA
    ===================================================================
--]]
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
