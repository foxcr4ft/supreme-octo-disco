--[[
    ===================================================================
    Dungeon Slayer: Reborn - Sistema do Chefe da Arena (BossSystem)
    Arquivo: src/server/BossSystem.server.lua
    ===================================================================
    Descrição:
    Este script gerencia o Boss final da Wave 5: Lorde Esqueleto Malakar.
    Ele possui 3 ataques especiais programados:
      1. Golpe Sísmico (Terremoto em área)
      2. Invocação de Servos Esqueléticos (Invoca lacaios na arena)
      3. Carga Brutal (Investida em alta velocidade atropelando jogadores)
--]]

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local NOME_BOSS = "Lorde Esqueleto Malakar"
local VIDA_MAXIMA = 800
local RECOMPENSA_MOEDAS = 100

local function encontrarJogadorMaisProximo(posicaoBoss)
    local alvoMaisProximo = nil
    local menorDistancia = math.huge

    for _, jogador in ipairs(Players:GetPlayers()) do
        local personagem = jogador.Character
        if personagem and personagem:FindFirstChild("HumanoidRootPart") then
            local humanoide = personagem:FindFirstChild("Humanoid")
            if humanoide and humanoide.Health > 0 then
                local distancia = (personagem.HumanoidRootPart.Position - posicaoBoss).Magnitude
                if distancia < menorDistancia then
                    menorDistancia = distancia
                    alvoMaisProximo = personagem
                end
            end
        end
    end

    return alvoMaisProximo, menorDistancia
end

-- ATAQUE 1: Golpe Sísmico (Terremoto em Área)
local function executarGolpeSismico(bossModel)
    local root = bossModel:FindFirstChild("HumanoidRootPart")
    if not root then return end

    print("[BossSystem] " .. NOME_BOSS .. " está preparando o Golpe Sísmico!")

    local anel = Instance.new("Part")
    anel.Shape = Enum.PartType.Cylinder
    anel.Size = Vector3.new(0.5, 30, 30)
    anel.CFrame = root.CFrame * CFrame.Angles(0, 0, math.rad(90))
    anel.BrickColor = BrickColor.new("Bright red")
    anel.Material = Enum.Material.Neon
    anel.Transparency = 0.5
    anel.Anchored = true
    anel.CanCollide = false
    anel.Parent = Workspace

    task.wait(1.2)

    local RAIO_IMPACTO = 25
    local DANO_SISMICO = 35

    for _, jogador in ipairs(Players:GetPlayers()) do
        local char = jogador.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local distancia = (char.HumanoidRootPart.Position - root.Position).Magnitude
            if distancia <= RAIO_IMPACTO then
                local humanoide = char:FindFirstChild("Humanoid")
                if humanoide and humanoide.Health > 0 then
                    humanoide:TakeDamage(DANO_SISMICO)
                    local direcao = (char.HumanoidRootPart.Position - root.Position).Unit
                    char.HumanoidRootPart.AssemblyLinearVelocity = (direcao + Vector3.new(0, 0.5, 0)) * 50
                end
            end
        end
    end

    Debris:AddItem(anel, 0.3)
end

-- ATAQUE 2: Invocação de Servos Esqueléticos
local function executarInvocacao(bossModel)
    local root = bossModel:FindFirstChild("HumanoidRootPart")
    if not root then return end

    print("[BossSystem] " .. NOME_BOSS .. " está invocando servos esqueléticos!")

    local QUANTIDADE_SERVOS = 3
    for i = 1, QUANTIDADE_SERVOS do
        local offset = Vector3.new(math.random(-15, 15), 0, math.random(-15, 15))
        local spawnPos = root.Position + offset

        local servo = Instance.new("Model")
        servo.Name = "Servo Esqueleto"

        local corpo = Instance.new("Part")
        corpo.Name = "HumanoidRootPart"
        corpo.Size = Vector3.new(2, 4, 2)
        corpo.Position = spawnPos
        corpo.BrickColor = BrickColor.new("Institutional white")
        corpo.Material = Enum.Material.SmoothPlastic
        corpo.Parent = servo

        local humanoid = Instance.new("Humanoid")
        humanoid.MaxHealth = 40
        humanoid.Health = 40
        humanoid.WalkSpeed = 12
        humanoid.Parent = servo

        servo.PrimaryPart = corpo
        servo.Parent = Workspace

        task.spawn(function()
            while servo and servo.Parent and humanoid.Health > 0 do
                local alvo = encontrarJogadorMaisProximo(corpo.Position)
                if alvo and alvo:FindFirstChild("HumanoidRootPart") then
                    humanoid:MoveTo(alvo.HumanoidRootPart.Position)
                    local dist = (alvo.HumanoidRootPart.Position - corpo.Position).Magnitude
                    if dist < 4 then
                        local humAlvo = alvo:FindFirstChild("Humanoid")
                        if humAlvo then humAlvo:TakeDamage(10) end
                        task.wait(1.5)
                    end
                end
                task.wait(0.5)
            end
            if servo then servo:Destroy() end
        end)
    end
end

-- ATAQUE 3: Carga Brutal (Investida em Linha Reta)
local function executarCargaBrutal(bossModel)
    local root = bossModel:FindFirstChild("HumanoidRootPart")
    local humanoid = bossModel:FindFirstChild("Humanoid")
    if not root or not humanoid then return end

    local alvo = encontrarJogadorMaisProximo(root.Position)
    if not alvo or not alvo:FindFirstChild("HumanoidRootPart") then return end

    print("[BossSystem] " .. NOME_BOSS .. " está preparando a Carga Brutal!")
    
    root.BrickColor = BrickColor.new("Really red")
    local direcaoCarga = (alvo.HumanoidRootPart.Position - root.Position).Unit
    local pontoDestino = root.Position + (direcaoCarga * 40)
    
    task.wait(1)

    humanoid.WalkSpeed = 35
    humanoid:MoveTo(pontoDestino)

    local conexaoToque
    conexaoToque = root.Touched:Connect(function(hit)
        local char = hit.Parent
        if char and char ~= bossModel then
            local hum = char:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                hum:TakeDamage(40)
                if char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.AssemblyLinearVelocity = direcaoCarga * 60 + Vector3.new(0, 20, 0)
                end
            end
        end
    end)

    task.wait(2)
    conexaoToque:Disconnect()
    humanoid.WalkSpeed = 14
    root.BrickColor = BrickColor.new("Pastel brown")
end

function _G.IniciarLutaBoss(pontoDeSpawn, aoDerrotarBossCallback)
    print("[BossSystem] Criando o " .. NOME_BOSS .. "...")

    local bossModel = Instance.new("Model")
    bossModel.Name = NOME_BOSS

    local root = Instance.new("Part")
    root.Name = "HumanoidRootPart"
    root.Size = Vector3.new(5, 8, 3)
    root.Position = pontoDeSpawn or Vector3.new(0, 10, 0)
    root.BrickColor = BrickColor.new("Pastel brown")
    root.Material = Enum.Material.Slate
    root.CanCollide = true
    root.Parent = bossModel

    local cabeca = Instance.new("Part")
    cabeca.Name = "Head"
    cabeca.Size = Vector3.new(3, 3, 3)
    cabeca.Position = root.Position + Vector3.new(0, 5, 0)
    cabeca.BrickColor = BrickColor.new("Black")
    cabeca.Material = Enum.Material.Neon
    cabeca.CanCollide = false
    cabeca.Parent = bossModel

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = root
    weld.Part1 = cabeca
    weld.Parent = root

    local humanoid = Instance.new("Humanoid")
    humanoid.MaxHealth = VIDA_MAXIMA
    humanoid.Health = VIDA_MAXIMA
    humanoid.WalkSpeed = 14
    humanoid.Parent = bossModel

    bossModel.PrimaryPart = root
    bossModel.Parent = Workspace

    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(8, 0, 1.5, 0)
    billboard.StudsOffset = Vector3.new(0, 4, 0)
    billboard.AlwaysOnTop = true
    billboard.Adornee = cabeca
    billboard.Parent = cabeca

    local fundoVida = Instance.new("Frame")
    fundoVida.Size = UDim2.new(1, 0, 0.4, 0)
    fundoVida.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    fundoVida.BorderSizePixel = 2
    fundoVida.Parent = billboard

    local barraVida = Instance.new("Frame")
    barraVida.Size = UDim2.new(1, 0, 1, 0)
    barraVida.BackgroundColor3 = Color3.fromRGB(220, 20, 60)
    barraVida.BorderSizePixel = 0
    barraVida.Parent = fundoVida

    local nomeLabel = Instance.new("TextLabel")
    nomeLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nomeLabel.Position = UDim2.new(0, 0, -0.6, 0)
    nomeLabel.BackgroundTransparency = 1
    nomeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nomeLabel.TextScaled = true
    nomeLabel.Font = Enum.Font.SourceSansBold
    nomeLabel.Text = "★ " .. NOME_BOSS .. " ★"
    nomeLabel.Parent = billboard

    humanoid.HealthChanged:Connect(function(novaVida)
        local porcentagem = math.clamp(novaVida / VIDA_MAXIMA, 0, 1)
        barraVida.Size = UDim2.new(porcentagem, 0, 1, 0)
    end)

    task.spawn(function()
        local listaAtaques = { executarGolpeSismico, executarInvocacao, executarCargaBrutal }
        local indiceAtaque = 1

        while bossModel and bossModel.Parent and humanoid.Health > 0 do
            local alvo, distancia = encontrarJogadorMaisProximo(root.Position)
            if alvo and alvo:FindFirstChild("HumanoidRootPart") then
                humanoid:MoveTo(alvo.HumanoidRootPart.Position)

                task.wait(4)
                if humanoid.Health > 0 then
                    local ataqueEscolhido = listaAtaques[indiceAtaque]
                    ataqueEscolhido(bossModel)
                    
                    indiceAtaque = indiceAtaque + 1
                    if indiceAtaque > #listaAtaques then
                        indiceAtaque = 1
                    end
                end
            else
                task.wait(1)
            end
        end
    end)

    humanoid.Died:Connect(function()
        print("[BossSystem] " .. NOME_BOSS .. " foi derrotado!")

        for _, jogador in ipairs(Players:GetPlayers()) do
            if _G.AdicionarMoedas then
                _G.AdicionarMoedas(jogador, RECOMPENSA_MOEDAS)
            end
        end

        if aoDerrotarBossCallback then
            aoDerrotarBossCallback()
        end

        task.wait(3)
        if bossModel then bossModel:Destroy() end
    end)
end

print("[BossSystem] Sistema do Chefe da Arena 1 carregado com sucesso!")
