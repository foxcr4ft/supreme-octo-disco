--[[
    ===================================================================
    Dungeon Slayer: Reborn - Arqueiro (ArcherSystem)
    Arquivo: ServerScriptService/ClassSystems/ArcherSystem
    ===================================================================
    Segue o mesmo padrão do SwordSystem do Guerreiro:
    Tool criada por código, dano pelo Tool.Activated no servidor,
    habilidade passiva com cooldown e tag "creator" em quem foi atingido.

    Ataques:
      1. Clique: Flecha com AUTO-MIRA. Procura o inimigo mais próximo num
         raio de 30 studs e atira nele, sem exigir que esteja na frente.
         Dano 22, cooldown 0,6 s, 20% de chance de crítico (dano dobrado).
         Se não houver inimigo no raio, atira na direção da mira.
      2. Passivo: Chuva de Flechas a cada 8 s, 30 de dano em área de 12 studs.

    EFEITOS (TASK 005, autorizado pelo Humano):
      - Flecha: Trail verde e luz na ponta.
      - Chuva de Flechas: ParticleEmitter circular caindo do alto.

    Vida 90, velocidade 10% acima do normal. O Guerreiro não é afetado:
    este script só cuida do Arco do Caçador.

    Outros scripts podem pedir o arco com:
      _G.EntregarArco(jogador)
--]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")

local NOME_ARCO = "Arco do Caçador"

local DANO_FLECHA = 22
local COOLDOWN_FLECHA = 0.6
local ALCANCE_FLECHA = 30
local CHANCE_CRITICO = 0.2 -- 20%
local MULTIPLICADOR_CRITICO = 2

local DANO_CHUVA = 30
local COOLDOWN_CHUVA = 8
local RAIO_CHUVA = 12

local VIDA_CLASSE = 90
local VELOCIDADE_BASE = 16
local VELOCIDADE_CLASSE = VELOCIDADE_BASE * 1.1 -- +10%

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
    Serve para esqueleto, boss e servo esqueleto, que são Models com Humanoid.
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
    AUTO-MIRA: procura o inimigo mais próximo dentro do raio, sem exigir que
    ele esteja na frente. Se não achar ninguém, devolve nil e o ataque sai
    na direção da mira, para o clique nunca travar.
--]]
local function acharInimigoMaisProximo(personagem, alcance)
    local root = personagem:FindFirstChild("HumanoidRootPart")
    if not root then
        return nil
    end

    local escolhido = nil
    local menorDistancia = math.huge

    for _, objeto in ipairs(Workspace:GetChildren()) do
        if ehInimigo(objeto, personagem) then
            local rootInimigo = objeto:FindFirstChild("HumanoidRootPart")
            if rootInimigo then
                local distancia = (rootInimigo.Position - root.Position).Magnitude

                if distancia <= alcance and distancia < menorDistancia then
                    menorDistancia = distancia
                    escolhido = objeto
                end
            end
        end
    end

    return escolhido
end

--[[
    Flecha: viaja da mão do Arqueiro até o alvo e causa o dano na chegada.
    O crítico é sorteado no disparo: 20% de chance de dobrar o dano.
--]]
local function dispararFlecha(jogador, personagem, alvo)
    local root = personagem:FindFirstChild("HumanoidRootPart")
    if not root then
        return
    end

    local origem = root.Position + (root.CFrame.LookVector * 2) + Vector3.new(0, 1, 0)
    local destino = origem + (root.CFrame.LookVector * ALCANCE_FLECHA)

    if alvo then
        local rootAlvo = alvo:FindFirstChild("HumanoidRootPart")
        if rootAlvo then
            destino = rootAlvo.Position
        end
    end

    local ehCritico = math.random() < CHANCE_CRITICO
    local danoFinal = DANO_FLECHA
    if ehCritico then
        danoFinal = DANO_FLECHA * MULTIPLICADOR_CRITICO
    end

    local flecha = Instance.new("Part")
    flecha.Name = "FlechaCacador"
    flecha.Size = Vector3.new(0.3, 0.3, 3)
    flecha.Position = origem
    flecha.BrickColor = BrickColor.new("Bright green")
    flecha.Material = Enum.Material.Neon
    flecha.CanCollide = false
    flecha.CanTouch = false
    flecha.CanQuery = false
    flecha.Massless = true
    flecha.Anchored = true
    flecha.Parent = Workspace

    -- Trail da flecha: a linha verde que ela deixa no ar
    local ponta0 = Instance.new("Attachment")
    ponta0.Name = "Ponta0"
    ponta0.Position = Vector3.new(0, 0.2, 1.5)
    ponta0.Parent = flecha

    local ponta1 = Instance.new("Attachment")
    ponta1.Name = "Ponta1"
    ponta1.Position = Vector3.new(0, -0.2, -1.5)
    ponta1.Parent = flecha

    local rastroFlecha = Instance.new("Trail")
    rastroFlecha.Name = "RastroDaFlecha"
    rastroFlecha.Attachment0 = ponta0
    rastroFlecha.Attachment1 = ponta1
    rastroFlecha.Lifetime = 0.3
    rastroFlecha.MinLength = 0
    rastroFlecha.Color = ColorSequence.new(Color3.fromRGB(180, 255, 160), Color3.fromRGB(40, 160, 60))
    rastroFlecha.Transparency = NumberSequence.new(0.15, 1)
    rastroFlecha.WidthScale = NumberSequence.new(0.6, 0.1)
    rastroFlecha.FaceCamera = true
    rastroFlecha.Parent = flecha

    -- Um brilho verde na ponta da flecha
    local luzFlecha = Instance.new("PointLight")
    luzFlecha.Color = Color3.fromRGB(120, 255, 140)
    luzFlecha.Brightness = 1.5
    luzFlecha.Range = 10
    luzFlecha.Parent = flecha

    local distancia = (destino - origem).Magnitude
    local passos = math.max(1, math.floor(distancia / 3))

    task.spawn(function()
        for _ = 1, passos do
            if not flecha.Parent then
                return
            end

            flecha.CFrame = CFrame.new(flecha.Position, destino)
            flecha.Position = flecha.Position + ((destino - flecha.Position).Unit * 3)
            task.wait(0.02)
        end

        if alvo and ehInimigo(alvo, personagem) then
            local humanoideInimigo = alvo:FindFirstChildOfClass("Humanoid")
            marcarCriador(humanoideInimigo, jogador)
            humanoideInimigo:TakeDamage(danoFinal)
        end

        Debris:AddItem(flecha, 0.05)
    end)
end

--[[
    Chuva de Flechas: dano em área de RAIO_CHUVA studs em volta do Arqueiro.
    Passivo, roda sozinho enquanto o Arco está equipado.
--]]
local function lancarChuvaDeFlechas(jogador, personagem)
    local root = personagem:FindFirstChild("HumanoidRootPart")
    if not root then
        return
    end

    local area = Instance.new("Part")
    area.Shape = Enum.PartType.Cylinder
    area.Size = Vector3.new(0.5, RAIO_CHUVA * 2, RAIO_CHUVA * 2)
    area.CFrame = root.CFrame * CFrame.Angles(0, 0, math.rad(90))
    area.BrickColor = BrickColor.new("Bright green")
    area.Material = Enum.Material.Neon
    area.Transparency = 0.55
    area.Anchored = true
    area.CanCollide = false
    area.CanTouch = false
    area.CanQuery = false
    area.Parent = Workspace

    -- Particula circular: as flechas caindo do ceu em volta do Arqueiro
    local emissorChuva = Instance.new("Attachment")
    emissorChuva.Name = "EmissorChuva"
    emissorChuva.Parent = area

    local flechasCaindo = Instance.new("ParticleEmitter")
    flechasCaindo.Name = "FlechasCaindo"
    flechasCaindo.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    flechasCaindo.Rate = 150
    flechasCaindo.Lifetime = NumberRange.new(0.6, 1)
    flechasCaindo.Speed = NumberRange.new(30, 45)
    flechasCaindo.SpreadAngle = Vector2.new(6, 6)
    flechasCaindo.Size = NumberSequence.new(0.8, 0)
    flechasCaindo.Transparency = NumberSequence.new(0.15, 1)
    flechasCaindo.Color = ColorSequence.new(Color3.fromRGB(140, 255, 150))
    flechasCaindo.Shape = Enum.ParticleEmitterShape.Cylinder
    flechasCaindo.ShapeStyle = Enum.ParticleEmitterShapeStyle.Surface
    flechasCaindo.ShapeInOut = Enum.ParticleOrientation.InnerBox
    flechasCaindo.EmissionDirection = Enum.NormalId.Bottom
    flechasCaindo.Parent = emissorChuva

    Debris:AddItem(area, 0.8)

    for _, objeto in ipairs(Workspace:GetChildren()) do
        if ehInimigo(objeto, personagem) then
            local rootInimigo = objeto:FindFirstChild("HumanoidRootPart")
            if rootInimigo and (rootInimigo.Position - root.Position).Magnitude <= RAIO_CHUVA then
                local humanoideInimigo = objeto:FindFirstChildOfClass("Humanoid")
                marcarCriador(humanoideInimigo, jogador)
                humanoideInimigo:TakeDamage(DANO_CHUVA)
            end
        end
    end
end

--[[
    Monta a Tool "Arco do Caçador" só com Parts e WeldConstraint.
    Nenhum Script é criado dentro dela.
--]]
local function criarArco()
    local tool = Instance.new("Tool")
    tool.Name = NOME_ARCO
    tool.ToolTip = "Clique para atirar a Flecha (mira automática). A Chuva de Flechas sai sozinha a cada 8 segundos."
    tool.CanBeDropped = false
    tool.RequiresHandle = true

    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(0.4, 4, 0.4)
    handle.BrickColor = BrickColor.new("Reddish brown")
    handle.Material = Enum.Material.Wood
    handle.Parent = tool

    local corda = Instance.new("Part")
    corda.Name = "Corda"
    corda.Size = Vector3.new(0.15, 3, 0.15)
    corda.BrickColor = BrickColor.new("White")
    corda.Material = Enum.Material.SmoothPlastic
    corda.CanCollide = false
    corda.Massless = true
    corda.Parent = tool

    corda.CFrame = handle.CFrame * CFrame.new(0.5, 0, 0)

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = handle
    weld.Part1 = corda
    weld.Parent = handle

    -- Clique: Flecha com cooldown de COOLDOWN_FLECHA segundos
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

        -- Auto-mira: atira no inimigo mais próximo do raio.
        -- Sem inimigo por perto, atira na direção da mira.
        local alvo = acharInimigoMaisProximo(personagem, ALCANCE_FLECHA)
        dispararFlecha(jogador, personagem, alvo)

        task.delay(COOLDOWN_FLECHA, function()
            podeAtacar = true
        end)
    end)

    -- Passivo: Chuva de Flechas a cada COOLDOWN_CHUVA segundos
    tool.Equipped:Connect(function()
        local personagem = tool.Parent
        local jogador = Players:GetPlayerFromCharacter(personagem)
        if not jogador then
            return
        end

        task.spawn(function()
            while tool.Parent == personagem do
                task.wait(COOLDOWN_CHUVA)
                if tool.Parent ~= personagem then
                    break
                end

                local humanoide = personagem:FindFirstChildOfClass("Humanoid")
                if humanoide and humanoide.Health > 0 then
                    lancarChuvaDeFlechas(jogador, personagem)
                end
            end
        end)
    end)

    return tool
end

--[[
    Entrega o Arco para o jogador, sem duplicar.
    Pode ser chamada de qualquer outro script do servidor.
--]]
function _G.EntregarArco(jogador)
    if typeof(jogador) ~= "Instance" or not jogador:IsA("Player") then
        return
    end

    local mochila = jogador:FindFirstChild("Backpack")
    if not mochila then
        return
    end

    local jaTem = mochila:FindFirstChild(NOME_ARCO)
    local noPersonagem = jogador.Character and jogador.Character:FindFirstChild(NOME_ARCO)
    if jaTem or noPersonagem then
        return
    end

    local arco = criarArco()
    arco.Parent = mochila
end

--[[
    Aplica a vida e a velocidade da classe no personagem.
--]]
function _G.AplicarAtributosArqueiro(personagem)
    local humanoid = personagem:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        return
    end

    humanoid.MaxHealth = VIDA_CLASSE
    humanoid.Health = VIDA_CLASSE
    humanoid.WalkSpeed = VELOCIDADE_CLASSE
end

function _G.EntregarKitArqueiro(jogador)
    _G.EntregarArco(jogador)
end
