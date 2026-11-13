--[[
    ===================================================================
    Dungeon Slayer: Reborn - Mago (MageSystem)
    Arquivo: ServerScriptService/ClassSystems/MageSystem
    ===================================================================
    Segue o mesmo padrão do SwordSystem do Guerreiro:
    Tool criada por código, dano pelo Tool.Activated no servidor,
    habilidade passiva com cooldown e tag "creator" em quem foi atingido.

    Ataques:
      1. Clique: Bola de Fogo à distância, 30 de dano, alcance 20 studs,
         cooldown de 1,0 s.
      2. Passivo: Nova Arcana a cada 8 s, 40 de dano em área de 8 studs.

    Vida 80, velocidade normal. A espada do Guerreiro não é afetada:
    este script só cuida do Cajado Arcano.

    Outros scripts podem pedir o cajado com:
      _G.EntregarCajado(jogador)
--]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")

local NOME_CAJADO = "Cajado Arcano"

local DANO_FOGO = 30
local COOLDOWN_FOGO = 1.0
local ALCANCE_FOGO = 20

local DANO_NOVA = 40
local COOLDOWN_NOVA = 8
local RAIO_NOVA = 8

local VIDA_CLASSE = 80
local VELOCIDADE_CLASSE = 16

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
    Escolhe o inimigo mais próximo, dentro do alcance, na direção da mira.
    Usado pela Bola de Fogo, que é um ataque à distância.
--]]
local function acharAlvoNaMira(personagem, alcance)
    local root = personagem:FindFirstChild("HumanoidRootPart")
    if not root then
        return nil
    end

    local frente = root.CFrame.LookVector
    local escolhido = nil
    local menorDistancia = math.huge

    for _, objeto in ipairs(Workspace:GetChildren()) do
        if ehInimigo(objeto, personagem) then
            local rootInimigo = objeto:FindFirstChild("HumanoidRootPart")
            if rootInimigo then
                local distancia = (rootInimigo.Position - root.Position).Magnitude
                local direcao = (rootInimigo.Position - root.Position).Unit

                -- Precisa estar na frente, igual ao golpe do Guerreiro
                if distancia <= alcance and frente:Dot(direcao) > 0.2 then
                    if distancia < menorDistancia then
                        menorDistancia = distancia
                        escolhido = objeto
                    end
                end
            end
        end
    end

    return escolhido
end

--[[
    Bola de Fogo: viaja da mão do Mago até o alvo e causa o dano na chegada.
    A Part não colide, não é tocável e não entra nas checagens de física,
    pelo mesmo motivo do efeito do Guerreiro: não pode virar parede.
--]]
local function lancarBolaDeFogo(jogador, personagem, alvo)
    local root = personagem:FindFirstChild("HumanoidRootPart")
    if not root then
        return
    end

    local origem = root.Position + (root.CFrame.LookVector * 2) + Vector3.new(0, 1, 0)
    local destino = origem + (root.CFrame.LookVector * ALCANCE_FOGO)

    if alvo then
        local rootAlvo = alvo:FindFirstChild("HumanoidRootPart")
        if rootAlvo then
            destino = rootAlvo.Position
        end
    end

    local bola = Instance.new("Part")
    bola.Name = "BolaDeFogo"
    bola.Shape = Enum.PartType.Ball
    bola.Size = Vector3.new(2, 2, 2)
    bola.Position = origem
    bola.BrickColor = BrickColor.new("Bright orange")
    bola.Material = Enum.Material.Neon
    bola.CanCollide = false
    bola.CanTouch = false
    bola.CanQuery = false
    bola.Massless = true
    bola.Anchored = true
    bola.Parent = Workspace

    local distancia = (destino - origem).Magnitude
    local passos = math.max(1, math.floor(distancia / 2))

    -- Voo da bola, passo a passo, para o jogador ver o projétil
    task.spawn(function()
        for _ = 1, passos do
            if not bola.Parent then
                return
            end

            bola.CFrame = CFrame.new(bola.Position, destino)
            bola.Position = bola.Position + ((destino - bola.Position).Unit * 2)
            task.wait(0.02)
        end

        if alvo and ehInimigo(alvo, personagem) then
            local humanoideInimigo = alvo:FindFirstChildOfClass("Humanoid")
            marcarCriador(humanoideInimigo, jogador)
            humanoideInimigo:TakeDamage(DANO_FOGO)
        end

        Debris:AddItem(bola, 0.05)
    end)
end

--[[
    Nova Arcana: dano em área de RAIO_NOVA studs em volta do Mago.
    Passivo, roda sozinho enquanto o Cajado está equipado.
--]]
local function lancarNovaArcana(jogador, personagem)
    local root = personagem:FindFirstChild("HumanoidRootPart")
    if not root then
        return
    end

    local anel = Instance.new("Part")
    anel.Shape = Enum.PartType.Cylinder
    anel.Size = Vector3.new(0.5, RAIO_NOVA * 2, RAIO_NOVA * 2)
    anel.CFrame = root.CFrame * CFrame.Angles(0, 0, math.rad(90))
    anel.BrickColor = BrickColor.new("Bright violet")
    anel.Material = Enum.Material.Neon
    anel.Transparency = 0.45
    anel.Anchored = true
    anel.CanCollide = false
    anel.CanTouch = false
    anel.CanQuery = false
    anel.Parent = Workspace
    Debris:AddItem(anel, 0.5)

    for _, objeto in ipairs(Workspace:GetChildren()) do
        if ehInimigo(objeto, personagem) then
            local rootInimigo = objeto:FindFirstChild("HumanoidRootPart")
            if rootInimigo and (rootInimigo.Position - root.Position).Magnitude <= RAIO_NOVA then
                local humanoideInimigo = objeto:FindFirstChildOfClass("Humanoid")
                marcarCriador(humanoideInimigo, jogador)
                humanoideInimigo:TakeDamage(DANO_NOVA)
            end
        end
    end
end

--[[
    Monta a Tool "Cajado Arcano" só com Parts e WeldConstraint.
    Nenhum Script é criado dentro dela.
--]]
local function criarCajado()
    local tool = Instance.new("Tool")
    tool.Name = NOME_CAJADO
    tool.ToolTip = "Clique para lançar Bola de Fogo. A Nova Arcana sai sozinha a cada 8 segundos."
    tool.CanBeDropped = false
    tool.RequiresHandle = true

    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(0.4, 5, 0.4)
    handle.BrickColor = BrickColor.new("Reddish brown")
    handle.Material = Enum.Material.Wood
    handle.Parent = tool

    local cristal = Instance.new("Part")
    cristal.Name = "Cristal"
    cristal.Shape = Enum.PartType.Ball
    cristal.Size = Vector3.new(0.9, 0.9, 0.9)
    cristal.BrickColor = BrickColor.new("Bright violet")
    cristal.Material = Enum.Material.Neon
    cristal.CanCollide = false
    cristal.Massless = true
    cristal.Parent = tool

    cristal.CFrame = handle.CFrame * CFrame.new(0, 3.2, 0)

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = handle
    weld.Part1 = cristal
    weld.Parent = handle

    -- Clique: Bola de Fogo com cooldown de COOLDOWN_FOGO segundos
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

        local alvo = acharAlvoNaMira(personagem, ALCANCE_FOGO)
        lancarBolaDeFogo(jogador, personagem, alvo)

        task.delay(COOLDOWN_FOGO, function()
            podeAtacar = true
        end)
    end)

    -- Passivo: Nova Arcana a cada COOLDOWN_NOVA segundos
    tool.Equipped:Connect(function()
        local personagem = tool.Parent
        local jogador = Players:GetPlayerFromCharacter(personagem)
        if not jogador then
            return
        end

        task.spawn(function()
            while tool.Parent == personagem do
                task.wait(COOLDOWN_NOVA)
                if tool.Parent ~= personagem then
                    break
                end

                local humanoide = personagem:FindFirstChildOfClass("Humanoid")
                if humanoide and humanoide.Health > 0 then
                    lancarNovaArcana(jogador, personagem)
                end
            end
        end)
    end)

    return tool
end

--[[
    Entrega o Cajado para o jogador, sem duplicar.
    Pode ser chamada de qualquer outro script do servidor.
--]]
function _G.EntregarCajado(jogador)
    if typeof(jogador) ~= "Instance" or not jogador:IsA("Player") then
        return
    end

    local mochila = jogador:FindFirstChild("Backpack")
    if not mochila then
        return
    end

    local jaTem = mochila:FindFirstChild(NOME_CAJADO)
    local noPersonagem = jogador.Character and jogador.Character:FindFirstChild(NOME_CAJADO)
    if jaTem or noPersonagem then
        return
    end

    local cajado = criarCajado()
    cajado.Parent = mochila
end

--[[
    Aplica a vida e a velocidade da classe no personagem.
    Chamado na seleção de classe e a cada renascimento.
--]]
function _G.AplicarAtributosMago(personagem)
    local humanoid = personagem:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        return
    end

    humanoid.MaxHealth = VIDA_CLASSE
    humanoid.Health = VIDA_CLASSE
    humanoid.WalkSpeed = VELOCIDADE_CLASSE
end

function _G.EntregarKitMago(jogador)
    _G.EntregarCajado(jogador)
end
