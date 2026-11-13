--[[
    ===================================================================
    Dungeon Slayer: Reborn - Mapa da Arena 1 (ArenaMapSystem)
    Arquivo: ServerScriptService/MapSystem/ArenaMapSystem
    ===================================================================
    Constrói o visual da dungeon da Arena 1: paredes, pilares, chão de
    pedra, tochas com fumaça e a arena circular do Boss.

    IMPORTANTE - LÓGICA INTACTA:
    Este script só cria enfeites. Ele NÃO cria, move ou altera o
    SpawnLocation que o WaveSystem usa. Os esqueletos continuam nascendo
    no mesmo lugar de antes, e o boss continua no centro.

    Se não existir um SpawnLocation na Arena 1, este script cria um
    chamado "SpawnArena" no lugar combinado — que é o mesmo que o
    WaveSystem procura. Assim a lógica dele segue valendo sem alterações.
--]]

local Workspace = game:GetService("Workspace")

local NOME_ARENA = "Arena1"
local NOME_SPAWN_ARENA = "SpawnArena"

-- Centro e medidas da arena. O WaveSystem usa o centro (0, 5, 0) para o boss.
local CENTRO_ARENA = Vector3.new(0, 0, 0)
local RAIO_ARENA = 60
local ALTURA_PAREDE = 24

--[[
    Devolve a pasta Arena1, criando se não existir.
--]]
local function obterArena()
    local arena = Workspace:FindFirstChild(NOME_ARENA)
    if arena then
        return arena
    end

    arena = Instance.new("Folder")
    arena.Name = NOME_ARENA
    arena.Parent = Workspace
    return arena
end

--[[
    Cria uma Part ancorada e devolve ela.
--]]
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

--[[
    Tocha da arena: poste, chama neon, PointLight e fumaça subindo.
--]]
local function criarTochaArena(posicao, pai)
    local tocha = Instance.new("Model")
    tocha.Name = "TochaArena"

    local poste = criarPart("Poste", Vector3.new(0.6, 7, 0.6), posicao, "Reddish brown", Enum.Material.Wood, tocha)

    local chama = Instance.new("Part")
    chama.Name = "Chama"
    chama.Shape = Enum.PartType.Ball
    chama.Size = Vector3.new(1.5, 1.5, 1.5)
    chama.Position = posicao + Vector3.new(0, 4, 0)
    chama.Anchored = true
    chama.CanCollide = false
    chama.BrickColor = BrickColor.new("Bright orange")
    chama.Material = Enum.Material.Neon
    chama.Parent = tocha

    local luz = Instance.new("PointLight")
    luz.Name = "LuzTocha"
    luz.Color = Color3.fromRGB(255, 150, 60)
    luz.Brightness = 3
    luz.Range = 34
    luz.Parent = chama

    local fumaca = Instance.new("ParticleEmitter")
    fumaca.Name = "Fumaca"
    fumaca.Texture = "rbxasset://textures/particles/smoke_main.dds"
    fumaca.Rate = 7
    fumaca.Lifetime = NumberRange.new(1.5, 2.5)
    fumaca.Speed = NumberRange.new(3, 5)
    fumaca.SpreadAngle = Vector2.new(10, 10)
    fumaca.Size = NumberSequence.new(1.2, 0.2)
    fumaca.Transparency = NumberSequence.new(0.65, 1)
    fumaca.Color = ColorSequence.new(Color3.fromRGB(110, 110, 110))
    fumaca.Parent = chama

    tocha.PrimaryPart = poste
    tocha.Parent = pai
    return tocha
end

--[[
    Cria um pilar de pedra com uma tocha no topo.
    Os 4 pilares ficam ao redor da arena circular do boss.
--]]
local function criarPilar(angulo, pai)
    local distancia = 32
    local x = CENTRO_ARENA.X + math.cos(angulo) * distancia
    local z = CENTRO_ARENA.Z + math.sin(angulo) * distancia

    local base = Vector3.new(x, ALTURA_PAREDE / 2, z)

    local pilar = Instance.new("Model")
    pilar.Name = "PilarArena"

    criarPart("Corpo", Vector3.new(4, ALTURA_PAREDE, 4), base, "Dark stone grey", Enum.Material.Slate, pilar)
    criarPart("BasePilar", Vector3.new(6, 2, 6), Vector3.new(x, 1, z), "Medium stone grey", Enum.Material.Slate, pilar)

    pilar.Parent = pai

    -- Tocha no topo do pilar
    criarTochaArena(Vector3.new(x, ALTURA_PAREDE + 3.5, z), pai)
end

--[[
    Constrói o mapa inteiro da Arena 1.
--]]
local function construirArena(arena)
    -- Se o mapa já foi construído, não duplica
    if arena:FindFirstChild("ChaoDungeon") then
        return
    end

    -- Chão principal, de pedra
    criarPart(
        "ChaoDungeon",
        Vector3.new(RAIO_ARENA * 2 + 40, 2, RAIO_ARENA * 2 + 40),
        CENTRO_ARENA - Vector3.new(0, 1, 0),
        "Medium stone grey",
        Enum.Material.Cobblestone,
        arena
    )

    -- Arena circular central, onde o Boss Malakar luta
    local arenaCircular = Instance.new("Part")
    arenaCircular.Name = "ArenaCircularBoss"
    arenaCircular.Shape = Enum.PartType.Cylinder
    arenaCircular.Size = Vector3.new(1, 44, 44)
    arenaCircular.CFrame = CFrame.new(CENTRO_ARENA + Vector3.new(0, 0.15, 0)) * CFrame.Angles(0, 0, math.rad(90))
    arenaCircular.Anchored = true
    arenaCircular.BrickColor = BrickColor.new("Dark stone grey")
    arenaCircular.Material = Enum.Material.Slate
    arenaCircular.Parent = arena

    -- Paredes externas, formando a sala
    local lado = RAIO_ARENA + 20
    criarPart("ParedeNorte", Vector3.new(lado * 2, ALTURA_PAREDE, 2), CENTRO_ARENA + Vector3.new(0, ALTURA_PAREDE / 2, -lado), "Dark stone grey", Enum.Material.Slate, arena)
    criarPart("ParedeSul", Vector3.new(lado * 2, ALTURA_PAREDE, 2), CENTRO_ARENA + Vector3.new(0, ALTURA_PAREDE / 2, lado), "Dark stone grey", Enum.Material.Slate, arena)
    criarPart("ParedeLeste", Vector3.new(2, ALTURA_PAREDE, lado * 2), CENTRO_ARENA + Vector3.new(lado, ALTURA_PAREDE / 2, 0), "Dark stone grey", Enum.Material.Slate, arena)
    criarPart("ParedeOeste", Vector3.new(2, ALTURA_PAREDE, lado * 2), CENTRO_ARENA + Vector3.new(-lado, ALTURA_PAREDE / 2, 0), "Dark stone grey", Enum.Material.Slate, arena)

    -- 4 tochas nos cantos
    local canto = lado - 12
    criarTochaArena(Vector3.new(-canto, 3.5, -canto), arena)
    criarTochaArena(Vector3.new(canto, 3.5, -canto), arena)
    criarTochaArena(Vector3.new(-canto, 3.5, canto), arena)
    criarTochaArena(Vector3.new(canto, 3.5, canto), arena)

    -- 4 pilares ao redor da arena circular
    for i = 0, 3 do
        criarPilar(math.rad(i * 90), arena)
    end

    -- 2 caixas decorativas. CanCollide = false para não atrapalhar
    -- o caminho dos esqueletos nem a IA deles.
    for i = 1, 2 do
        local crate = criarPart(
            "CrateDecorativa" .. i,
            Vector3.new(4, 4, 4),
            CENTRO_ARENA + Vector3.new(-42 + (i * 8), 2, 40),
            "Reddish brown",
            Enum.Material.WoodPlanks,
            arena
        )
        crate.CanCollide = false
    end

    -- SpawnArena: só cria se ainda não existir.
    -- É o mesmo nome que o WaveSystem procura, então a lógica dele continua.
    local spawnExistente = arena:FindFirstChild(NOME_SPAWN_ARENA, true)
    if not spawnExistente then
        local spawnArena = Instance.new("SpawnLocation")
        spawnArena.Name = NOME_SPAWN_ARENA
        spawnArena.Size = Vector3.new(10, 1, 10)
        spawnArena.Position = CENTRO_ARENA + Vector3.new(0, 1, 40)
        spawnArena.Anchored = true
        spawnArena.Neutral = true
        spawnArena.Duration = 0
        spawnArena.BrickColor = BrickColor.new("Dark stone grey")
        spawnArena.Material = Enum.Material.Slate
        spawnArena.Parent = arena
    end

    print("[ArenaMapSystem] Mapa da Arena 1 construído.")
end

local arena = obterArena()
construirArena(arena)

print("[ArenaMapSystem] Arena 1 pronta. O SpawnLocation da lógica não foi alterado.")
