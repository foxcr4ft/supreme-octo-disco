--[[
    ===================================================================
    Dungeon Slayer: Reborn - Ladino (RogueSystem)
    Arquivo: ServerScriptService/ClassSystems/RogueSystem
    ===================================================================
    Segue o mesmo padrão do SwordSystem do Guerreiro:
    Tool criada por código, dano pelo Tool.Activated no servidor,
    habilidade passiva com cooldown e tag "creator" em quem foi atingido.

    Ataques:
      1. Clique: Corte rápido, 18 de dano, alcance 8 studs,
         cooldown de 0,35 s (bem rápido, é a classe de mais DPS).
      2. Passivo: Dash ao apertar Shift, avanço rápido com 0,5 s de
         invulnerabilidade, cooldown de 6 s.

    Vida 70, velocidade 25% acima do normal. O Guerreiro não é afetado:
    este script só cuida das Adagas Sombrias.

    Outros scripts podem pedir as adagas com:
      _G.EntregarAdagas(jogador)
--]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")

local NOME_ADAGAS = "Adagas Sombrias"

local DANO_CORTE = 18
local COOLDOWN_CORTE = 0.35
local ALCANCE_CORTE = 8

local COOLDOWN_DASH = 6
local DURACAO_INVULNERAVEL = 0.5
local DISTANCIA_DASH = 45

local VIDA_CLASSE = 70
local VELOCIDADE_BASE = 16
local VELOCIDADE_CLASSE = VELOCIDADE_BASE * 1.25 -- +25%

--[[
    Grava a tag "creator" no Humanoid do inimigo.
    É essa tag que o WaveSystem e o BossSystem leem para premiar o abate.
--]]
local function marcarCriador(humanoideInimigo, jogador)
    if not humanoideInimigo then
        return
    end

    local tag = humanoideInimigo:FindFirstChild("creator")
    if not tag then
        tag = Instance.new("ObjectValue")
        tag.Name = "creator"
        tag.Parent = humanoideInimigo
    end

    tag.Value = jogador
end

--[[
    Diz se o modelo é um inimigo válido.
    Nunca aceita o próprio personagem nem o personagem de outro jogador.
--]]
local function ehInimigo(modelo, personagemDoJogador)
    if not modelo or modelo == personagemDoJogador then
        return false
    end

    if Players:GetPlayerFromCharacter(modelo) then
        return false
    end

    local humanoide = modelo:FindFirstChildOfClass("Humanoid")
    return humanoide ~= nil and humanoide.Health > 0
end

--[[
    Corte rápido: adagas atingem os inimigos à frente, em ALCANCE_CORTE studs.
--]]
local function cortarNaFrente(jogador, personagem)
    local root = personagem:FindFirstChild("HumanoidRootPart")
    if not root then
        return
    end

    local frente = root.CFrame.LookVector

    -- Rastro do corte: uma linha fina, sem colisão e sem toque
    local rastro = Instance.new("Part")
    rastro.Name = "RastroAdagas"
    rastro.Size = Vector3.new(ALCANCE_CORTE * 0.8, 1.2, 0.25)
    local centro = root.Position + (frente * (ALCANCE_CORTE * 0.5))
    rastro.CFrame = CFrame.new(centro, centro + frente)
    rastro.BrickColor = BrickColor.new("Dark stone grey")
    rastro.Material = Enum.Material.Neon
    rastro.Transparency = 0.55
    rastro.Anchored = true
    rastro.CanCollide = false
    rastro.CanTouch = false
    rastro.CanQuery = false
    rastro.Massless = true
    rastro.Parent = Workspace
    Debris:AddItem(rastro, 0.15)

    for _, objeto in ipairs(Workspace:GetChildren()) do
        if ehInimigo(objeto, personagem) then
            local rootInimigo = objeto:FindFirstChild("HumanoidRootPart")
            if rootInimigo then
                local distancia = (rootInimigo.Position - root.Position).Magnitude
                local direcao = (rootInimigo.Position - root.Position).Unit
                local naFrente = frente:Dot(direcao) > 0.2

                if distancia <= ALCANCE_CORTE and naFrente then
                    local humanoideInimigo = objeto:FindFirstChildOfClass("Humanoid")
                    marcarCriador(humanoideInimigo, jogador)
                    humanoideInimigo:TakeDamage(DANO_CORTE)
                end
            end
        end
    end
end

--[[
    Dash: avanço rápido na direção da mira, com 0,5 s sem tomar dano.
--]]
local function executarDash(jogador, personagem)
    local root = personagem:FindFirstChild("HumanoidRootPart")
    local humanoid = personagem:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid or humanoid.Health <= 0 then
        return
    end

    local direcao = root.CFrame.LookVector
    root.AssemblyLinearVelocity = direcao * DISTANCIA_DASH + Vector3.new(0, 8, 0)

    -- Invulnerabilidade: qualquer dano durante o dash é devolvido
    local vidaGuardada = humanoid.Health
    local conexaoDano
    conexaoDano = humanoid.HealthChanged:Connect(function(novaVida)
        if novaVida < vidaGuardada then
            humanoid.Health = vidaGuardada
        else
            vidaGuardada = novaVida
        end
    end)

    -- Rastro do dash
    local rastro = Instance.new("Part")
    rastro.Name = "RastroDash"
    rastro.Size = Vector3.new(2, 4, 4)
    rastro.CFrame = root.CFrame * CFrame.new(0, 0, -2)
    rastro.BrickColor = BrickColor.new("Dark stone grey")
    rastro.Material = Enum.Material.Neon
    rastro.Transparency = 0.5
    rastro.Anchored = true
    rastro.CanCollide = false
    rastro.CanTouch = false
    rastro.CanQuery = false
    rastro.Massless = true
    rastro.Parent = Workspace
    Debris:AddItem(rastro, DURACAO_INVULNERAVEL)

    task.delay(DURACAO_INVULNERAVEL, function()
        if conexaoDano then
            conexaoDano:Disconnect()
        end
    end)
end

--[[
    Monta a Tool "Adagas Sombrias" só com Parts e WeldConstraint.
    Nenhum Script é criado dentro dela.
--]]
local function criarAdagas()
    local tool = Instance.new("Tool")
    tool.Name = NOME_ADAGAS
    tool.ToolTip = "Clique para cortar rápido. Aperte Shift para o Dash (invulnerável por 0,5 s)."
    tool.CanBeDropped = false
    tool.RequiresHandle = true

    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(0.3, 1.6, 0.3)
    handle.BrickColor = BrickColor.new("Dark stone grey")
    handle.Material = Enum.Material.Metal
    handle.Parent = tool

    local lamina = Instance.new("Part")
    lamina.Name = "Lamina"
    lamina.Size = Vector3.new(0.2, 1.4, 0.2)
    lamina.BrickColor = BrickColor.new("Really black")
    lamina.Material = Enum.Material.Neon
    lamina.CanCollide = false
    lamina.Massless = true
    lamina.Parent = tool

    lamina.CFrame = handle.CFrame * CFrame.new(0, 1.3, 0)

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = handle
    weld.Part1 = lamina
    weld.Parent = handle

    -- Clique: corte com cooldown de COOLDOWN_CORTE segundos
    local podeAtacar = true

    tool.Activated:Connect(function()
        if not podeAtacar then
            return
        end

        local personagem = tool.Parent
        local jogador = Players:GetPlayerFromCharacter(personagem)
        if not jogador then
            return
        end

        local humanoid = personagem:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then
            return
        end

        podeAtacar = false
        cortarNaFrente(jogador, personagem)

        task.delay(COOLDOWN_CORTE, function()
            podeAtacar = true
        end)
    end)

    -- Passivo: Dash no Shift, com cooldown de COOLDOWN_DASH segundos
    local podeDarDash = true

    tool.Equipped:Connect(function(mouse)
        local personagem = tool.Parent
        local jogador = Players:GetPlayerFromCharacter(personagem)
        if not jogador then
            return
        end

        -- Escuta o Shift só enquanto a Tool está equipada.
        -- A conexão é desfeita no Unequipped para não ficar escutando sempre.
        local conexaoInput
        conexaoInput = UserInputService.InputBegan:Connect(function(entrada, processadoPeloJogo)
            if processadoPeloJogo then
                return
            end
            if entrada.KeyCode ~= Enum.KeyCode.LeftShift then
                return
            end
            if not podeDarDash then
                return
            end
            if tool.Parent ~= personagem then
                return
            end

            podeDarDash = false
            executarDash(jogador, personagem)

            task.delay(COOLDOWN_DASH, function()
                podeDarDash = true
            end)
        end)

        tool.Unequipped:Connect(function()
            if conexaoInput then
                conexaoInput:Disconnect()
                conexaoInput = nil
            end
        end)
    end)

    return tool
end

--[[
    Entrega as Adagas para o jogador, sem duplicar.
    Pode ser chamada de qualquer outro script do servidor.
--]]
function _G.EntregarAdagas(jogador)
    if typeof(jogador) ~= "Instance" or not jogador:IsA("Player") then
        return
    end

    local mochila = jogador:FindFirstChild("Backpack")
    if not mochila then
        return
    end

    local jaTem = mochila:FindFirstChild(NOME_ADAGAS)
    local noPersonagem = jogador.Character and jogador.Character:FindFirstChild(NOME_ADAGAS)
    if jaTem or noPersonagem then
        return
    end

    local adagas = criarAdagas()
    adagas.Parent = mochila
end

--[[
    Aplica a vida e a velocidade da classe no personagem.
--]]
function _G.AplicarAtributosLadino(personagem)
    local humanoid = personagem:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        return
    end

    humanoid.MaxHealth = VIDA_CLASSE
    humanoid.Health = VIDA_CLASSE
    humanoid.WalkSpeed = VELOCIDADE_CLASSE
end

function _G.EntregarKitLadino(jogador)
    _G.EntregarAdagas(jogador)
end
