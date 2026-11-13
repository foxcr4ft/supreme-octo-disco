--[[
    ===================================================================
    Dungeon Slayer: Reborn - Hub de Spawn (HubSystem)
    Arquivo: ServerScriptService/MapSystem/HubSystem
    ===================================================================
    Cria e mantém a sala inicial segura onde o jogador nasce.

    O QUE ESTE SCRIPT FAZ:
      1. Cria a pasta Workspace/Hub com o chão, as paredes e o teto.
      2. Coloca as 4 tochas com PointLight (luz quente) e fumaça.
      3. Cria o NPC "Mercador" (só visual, ainda sem loja).
      4. Cria o portal "Entrar na Arena 1".
      5. Leva o jogador para o Hub quando ele nasce.
      6. Quando ele toca no portal, manda para a Arena 1.

    TASK 005: o respawn respeita o revive pago. Quem usou o botão
    "Reviver na Arena" tem o atributo RevivePago marcado pelo WaveSystem,
    e neste respawn ele NÃO volta para o Hub — renasce dentro da arena,
    com a run intacta.
--]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local NOME_HUB = "Hub"
local NOME_ARENA = "Arena1"
local NOME_SPAWN_HUB = "SpawnHub"
local NOME_SPAWN_ARENA = "SpawnArena"

local CENTRO_HUB = Vector3.new(0, 100, 0)
local TAMANHO_SALA = Vector3.new(90, 24, 90)

local ATRIBUTO_REVIVE_PAGO = "RevivePago"

local function criarPart(nome, tamanho, posicao, cor, material, pai)
    local part = Instance.new("Part")
    part.Name = nome
    part.Size = tamanho
    part.Position = posicao
    part.Anchored = true
    part.BrickColor = BrickColor.new(cor)
    part.Material = material
    part.Parent = pai
    return part
end

local function criarTocha(posicao, pai)
    local tocha = Instance.new("Model")
    tocha.Name = "TochaHub"

    local poste = criarPart("Poste", Vector3.new(0.6, 6, 0.6), posicao, "Reddish brown", Enum.Material.Wood, tocha)

    local chama = Instance.new("Part")
    chama.Name = "Chama"
    chama.Shape = Enum.PartType.Ball
    chama.Size = Vector3.new(1.6, 1.6, 1.6)
    chama.Position = posicao + Vector3.new(0, 3.4, 0)
    chama.Anchored = true
    chama.CanCollide = false
    chama.BrickColor = BrickColor.new("Bright orange")
    chama.Material = Enum.Material.Neon
    chama.Parent = tocha

    local luz = Instance.new("PointLight")
    luz.Name = "LuzTocha"
    luz.Color = Color3.fromRGB(255, 170, 80)
    luz.Brightness = 3
    luz.Range = 28
    luz.Parent = chama

    local fumaca = Instance.new("ParticleEmitter")
    fumaca.Name = "Fumaca"
    fumaca.Texture = "rbxasset://textures/particles/smoke_main.dds"
    fumaca.Rate = 8
    fumaca.Lifetime = NumberRange.new(1.5, 2.5)
    fumaca.Speed = NumberRange.new(3, 5)
    fumaca.SpreadAngle = Vector2.new(10, 10)
    fumaca.Size = NumberSequence.new(1.2, 0.2)
    fumaca.Transparency = NumberSequence.new(0.6, 1)
    fumaca.Color = ColorSequence.new(Color3.fromRGB(120, 120, 120))
    fumaca.Parent = chama

    tocha.PrimaryPart = poste
    tocha.Parent = pai

    return tocha
end

local function criarHub()
    local hubExistente = Workspace:FindFirstChild(NOME_HUB)
    if hubExistente then
        return hubExistente
    end

    local hub = Instance.new("Folder")
    hub.Name = NOME_HUB
    hub.Parent = Workspace

    local meiaAltura = TAMANHO_SALA.Y / 2
    local meiaLargura = TAMANHO_SALA.X / 2
    local meiaProfundidade = TAMANHO_SALA.Z / 2

    criarPart(
        "ChaoHub",
        Vector3.new(TAMANHO_SALA.X, 2, TAMANHO_SALA.Z),
        CENTRO_HUB - Vector3.new(0, meiaAltura, 0),
        "Medium stone grey",
        Enum.Material.Slate,
        hub
    )

    criarPart(
        "TetoHub",
        Vector3.new(TAMANHO_SALA.X, 2, TAMANHO_SALA.Z),
        CENTRO_HUB + Vector3.new(0, meiaAltura, 0),
        "Dark stone grey",
        Enum.Material.Slate,
        hub
    )

    criarPart(
        "ParedeNorte",
        Vector3.new(TAMANHO_SALA.X, TAMANHO_SALA.Y, 2),
        CENTRO_HUB + Vector3.new(0, 0, -meiaProfundidade),
        "Medium stone grey",
        Enum.Material.Slate,
        hub
    )
    criarPart(
        "ParedeSul",
        Vector3.new(TAMANHO_SALA.X, TAMANHO_SALA.Y, 2),
        CENTRO_HUB + Vector3.new(0, 0, meiaProfundidade),
        "Medium stone grey",
        Enum.Material.Slate,
        hub
    )
    criarPart(
        "ParedeLeste",
        Vector3.new(2, TAMANHO_SALA.Y, TAMANHO_SALA.Z),
        CENTRO_HUB + Vector3.new(meiaLargura, 0, 0),
        "Medium stone grey",
        Enum.Material.Slate,
        hub
    )
    criarPart(
        "ParedeOeste",
        Vector3.new(2, TAMANHO_SALA.Y, TAMANHO_SALA.Z),
        CENTRO_HUB - Vector3.new(meiaLargura, 0, 0),
        "Medium stone grey",
        Enum.Material.Slate,
        hub
    )

    local alturaTocha = CENTRO_HUB.Y - meiaAltura + 3
    local recuo = 10
    criarTocha(Vector3.new(CENTRO_HUB.X - meiaLargura + recuo, alturaTocha, CENTRO_HUB.Z - meiaProfundidade + recuo), hub)
    criarTocha(Vector3.new(CENTRO_HUB.X + meiaLargura - recuo, alturaTocha, CENTRO_HUB.Z - meiaProfundidade + recuo), hub)
    criarTocha(Vector3.new(CENTRO_HUB.X - meiaLargura + recuo, alturaTocha, CENTRO_HUB.Z + meiaProfundidade - recuo), hub)
    criarTocha(Vector3.new(CENTRO_HUB.X + meiaLargura - recuo, alturaTocha, CENTRO_HUB.Z + meiaProfundidade - recuo), hub)

    local spawnHub = Instance.new("SpawnLocation")
    spawnHub.Name = NOME_SPAWN_HUB
    spawnHub.Size = Vector3.new(8, 1, 8)
    spawnHub.Position = CENTRO_HUB + Vector3.new(0, -meiaAltura + 1, 22)
    spawnHub.Anchored = true
    spawnHub.BrickColor = BrickColor.new("Bright blue")
    spawnHub.Material = Enum.Material.Neon
    spawnHub.Neutral = true
    spawnHub.Duration = 0
    spawnHub.Parent = hub

    local mercador = Instance.new("Model")
    mercador.Name = "Mercador"

    local corpoMercador = Instance.new("Part")
    corpoMercador.Name = "HumanoidRootPart"
    corpoMercador.Size = Vector3.new(2, 4, 1.5)
    corpoMercador.Position = CENTRO_HUB + Vector3.new(-16, -meiaAltura + 2, -18)
    corpoMercador.Anchored = true
    corpoMercador.BrickColor = BrickColor.new("Bright yellow")
    corpoMercador.Material = Enum.Material.Fabric
    corpoMercador.Parent = mercador

    local cabecaMercador = Instance.new("Part")
    cabecaMercador.Name = "Head"
    cabecaMercador.Shape = Enum.PartType.Ball
    cabecaMercador.Size = Vector3.new(1.6, 1.6, 1.6)
    cabecaMercador.Position = corpoMercador.Position + Vector3.new(0, 2.8, 0)
    cabecaMercador.Anchored = true
    cabecaMercador.CanCollide = false
    cabecaMercador.BrickColor = BrickColor.new("Cool yellow")
    cabecaMercador.Material = Enum.Material.SmoothPlastic
    cabecaMercador.Parent = mercador

    local humanoidMercador = Instance.new("Humanoid")
    humanoidMercador.Parent = mercador

    local etiqueta = Instance.new("BillboardGui")
    etiqueta.Name = "Etiqueta"
    etiqueta.Size = UDim2.new(0, 220, 0, 50)
    etiqueta.StudsOffset = Vector3.new(0, 3.5, 0)
    etiqueta.AlwaysOnTop = true
    etiqueta.Adornee = cabecaMercador
    etiqueta.Parent = cabecaMercador

    local textoNome = Instance.new("TextLabel")
    textoNome.Size = UDim2.new(1, 0, 0.6, 0)
    textoNome.BackgroundTransparency = 1
    textoNome.Font = Enum.Font.SourceSansBold
    textoNome.TextSize = 22
    textoNome.TextColor3 = Color3.fromRGB(255, 255, 255)
    textoNome.TextStrokeTransparency = 0.3
    textoNome.Text = "Mercador"
    textoNome.Parent = etiqueta

    local textoAviso = Instance.new("TextLabel")
    textoAviso.Size = UDim2.new(1, 0, 0.4, 0)
    textoAviso.Position = UDim2.new(0, 0, 0.6, 0)
    textoAviso.BackgroundTransparency = 1
    textoAviso.Font = Enum.Font.SourceSans
    textoAviso.TextSize = 16
    textoAviso.TextColor3 = Color3.fromRGB(210, 210, 210)
    textoAviso.Text = "(loja em breve)"
    textoAviso.Parent = etiqueta

    mercador.PrimaryPart = corpoMercador
    mercador.Parent = hub

    local portal = Instance.new("Part")
    portal.Name = "PortalArena1"
    portal.Size = Vector3.new(12, 16, 1)
    portal.Position = CENTRO_HUB + Vector3.new(0, -meiaAltura + 8, -meiaProfundidade + 6)
    portal.Anchored = true
    portal.BrickColor = BrickColor.new("Bright violet")
    portal.Material = Enum.Material.Neon
    portal.Transparency = 0.25
    portal.CanCollide = false
    portal.Parent = hub

    local luzPortal = Instance.new("PointLight")
    luzPortal.Color = Color3.fromRGB(170, 90, 255)
    luzPortal.Brightness = 4
    luzPortal.Range = 30
    luzPortal.Parent = portal

    local placa = Instance.new("BillboardGui")
    placa.Name = "TextoPortal"
    placa.Size = UDim2.new(0, 320, 0, 60)
    placa.StudsOffset = Vector3.new(0, 5, 0)
    placa.AlwaysOnTop = true
    placa.Adornee = portal
    placa.Parent = portal

    local textoPortal = Instance.new("TextLabel")
    textoPortal.Size = UDim2.new(1, 0, 1, 0)
    textoPortal.BackgroundTransparency = 1
    textoPortal.Font = Enum.Font.SourceSansBold
    textoPortal.TextSize = 26
    textoPortal.TextColor3 = Color3.fromRGB(255, 255, 255)
    textoPortal.TextStrokeTransparency = 0.3
    textoPortal.Text = "Entrar na Arena 1"
    textoPortal.Parent = placa

    print("[HubSystem] Hub criado em " .. tostring(CENTRO_HUB))
    return hub
end

local function posicaoDoSpawnHub()
    local hub = Workspace:FindFirstChild(NOME_HUB)
    if hub then
        local spawnHub = hub:FindFirstChild(NOME_SPAWN_HUB)
        if spawnHub and spawnHub:IsA("BasePart") then
            return spawnHub.Position + Vector3.new(0, 4, 0)
        end
    end

    return CENTRO_HUB + Vector3.new(0, 6, 22)
end

local function levarParaHub(jogador)
    local personagem = jogador.Character
    if not personagem then
        return
    end

    local root = personagem:FindFirstChild("HumanoidRootPart")
    if not root then
        return
    end

    root.CFrame = CFrame.new(posicaoDoSpawnHub())
end

local function levarParaArena(jogador)
    local personagem = jogador.Character
    if not personagem then
        return
    end

    local root = personagem:FindFirstChild("HumanoidRootPart")
    if not root then
        return
    end

    local destino = nil
    local arena = Workspace:FindFirstChild(NOME_ARENA)
    if arena then
        local spawnArena = arena:FindFirstChild(NOME_SPAWN_ARENA, true)
        if spawnArena and spawnArena:IsA("BasePart") then
            destino = spawnArena.Position + Vector3.new(0, 4, 0)
        end
    end

    if not destino then
        warn("[HubSystem] SpawnArena não encontrado dentro de Workspace/" .. NOME_ARENA .. ". O portal não vai teleportar.")
        return
    end

    root.CFrame = CFrame.new(destino)
    print("[HubSystem] " .. jogador.Name .. " entrou na Arena 1.")
end

local function ligarPortal(portal)
    local ultimoUso = {}

    portal.Touched:Connect(function(hit)
        local personagem = hit:FindFirstAncestorOfClass("Model")
        if not personagem then
            return
        end

        local jogador = Players:GetPlayerFromCharacter(personagem)
        if not jogador then
            return
        end

        local agora = os.clock()
        if ultimoUso[jogador] and (agora - ultimoUso[jogador]) < 3 then
            return
        end
        ultimoUso[jogador] = agora

        levarParaArena(jogador)
    end)
end

local function configurarJogador(jogador)
    jogador.CharacterAdded:Connect(function()
        task.wait(0.3)

        -- Respawn de revive pago: fica na arena, não volta para o Hub
        if jogador:GetAttribute(ATRIBUTO_REVIVE_PAGO) then
            jogador:SetAttribute(ATRIBUTO_REVIVE_PAGO, false)
            print("[HubSystem] " .. jogador.Name .. " reviveu na arena. Não volta para o Hub.")
            return
        end

        levarParaHub(jogador)
    end)
end

local hub = criarHub()

local portal = hub:FindFirstChild("PortalArena1")
if portal then
    ligarPortal(portal)
end

Players.PlayerAdded:Connect(configurarJogador)
for _, jogador in ipairs(Players:GetPlayers()) do
    configurarJogador(jogador)

    if jogador.Character then
        task.spawn(function()
            task.wait(0.3)
            levarParaHub(jogador)
        end)
    end
end

print("[HubSystem] Hub carregado. O jogador nasce aqui, seguro.")
