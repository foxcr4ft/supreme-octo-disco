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
      2. Passivo: Dash ao apertar Shift, avanço de 12 studs com 0,5 s de
         invulnerabilidade, cooldown de 6 s.

    EFEITOS (TASK 005, autorizado pelo Humano):
      - Rastro do dash: Trail de sombra e fumaça escura.

    O DASH RODA NO SERVIDOR. O teclado é lido pelo LocalScript DashClient,
    que manda o pedido pelo RemoteEvent "DashLadino". O servidor confere
    cooldown e Tool equipada, então o cliente não consegue burlar nada.

    Vida 70, velocidade 25% acima do normal. O Guerreiro não é afetado:
    este script só cuida das Adagas Sombrias.

    Outros scripts podem pedir as adagas com:
      _G.EntregarAdagas(jogador)
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")

local NOME_ADAGAS = "Adagas Sombrias"

local DANO_CORTE = 18
local COOLDOWN_CORTE = 0.35
local ALCANCE_CORTE = 8

local COOLDOWN_DASH = 6
local DURACAO_INVULNERAVEL = 0.5
local DURACAO_DASH = 0.22 -- quanto tempo o avanço leva, em segundos
local DURACAO_RASTRO = 1.2 -- quanto tempo o rastro fica na tela
local DISTANCIA_DASH = 12 -- studs que o jogador avança
local PASSOS_DASH = 4 -- em quantos passos o avanço é dividido

local VIDA_CLASSE = 70
local VELOCIDADE_BASE = 16
local VELOCIDADE_CLASSE = VELOCIDADE_BASE * 1.25 -- +25%

--[[
    RemoteEvent do Dash.
    O servidor cria o Remote e escuta; o cliente só manda o pedido.
--]]
local NOME_REMOTE_DASH = "DashLadino"

local function obterRemoteDash()
    local remote = ReplicatedStorage:FindFirstChild(NOME_REMOTE_DASH)
    if not remote then
        remote = Instance.new("RemoteEvent")
        remote.Name = NOME_REMOTE_DASH
        remote.Parent = ReplicatedStorage
    end
    return remote
end

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
    Efeito visual de partida: uma marca no chão onde o Ladino estava.
    É o que faz o dash aparecer na tela: você vê de onde saiu.
--]]
local function marcarPartida(posicao)
    local marca = Instance.new("Part")
    marca.Name = "MarcaDePartida"
    marca.Shape = Enum.PartType.Cylinder
    marca.Size = Vector3.new(0.4, 8, 8)
    marca.CFrame = CFrame.new(posicao) * CFrame.Angles(0, 0, math.rad(90))
    marca.BrickColor = BrickColor.new("Really black")
    marca.Material = Enum.Material.Neon
    marca.Transparency = 0.25
    marca.Anchored = true
    marca.CanCollide = false
    marca.CanTouch = false
    marca.CanQuery = false
    marca.Parent = Workspace
    Debris:AddItem(marca, DURACAO_RASTRO)
end

--[[
    Rastro do dash: uma caixa escura e alta deixada atrás,
    com Trail de sombra e fumaça escura saindo dela.
--]]
local function mostrarRastroDash(posicao, direcao)
    local rastro = Instance.new("Part")
    rastro.Name = "RastroDash"
    rastro.Size = Vector3.new(4, 6, 3)
    rastro.CFrame = CFrame.new(posicao, posicao + direcao) * CFrame.new(0, 0, 1.5)
    rastro.BrickColor = BrickColor.new("Really black")
    rastro.Material = Enum.Material.Neon
    rastro.Transparency = 0.3
    rastro.Anchored = true
    rastro.CanCollide = false
    rastro.CanTouch = false
    rastro.CanQuery = false
    rastro.Massless = true
    rastro.Parent = Workspace

    -- Trail vertical: a cortina de sombra entre um rastro e o outro
    local topo = Instance.new("Attachment")
    topo.Name = "Topo"
    topo.Position = Vector3.new(0, 3, 0)
    topo.Parent = rastro

    local base = Instance.new("Attachment")
    base.Name = "Base"
    base.Position = Vector3.new(0, -3, 0)
    base.Parent = rastro

    local rastroSombra = Instance.new("Trail")
    rastroSombra.Name = "RastroSombra"
    rastroSombra.Attachment0 = topo
    rastroSombra.Attachment1 = base
    rastroSombra.Lifetime = 0.6
    rastroSombra.MinLength = 0
    rastroSombra.Color = ColorSequence.new(Color3.fromRGB(120, 120, 140), Color3.fromRGB(20, 20, 30))
    rastroSombra.Transparency = NumberSequence.new(0.3, 1)
    rastroSombra.WidthScale = NumberSequence.new(1, 0.3)
    rastroSombra.FaceCamera = true
    rastroSombra.Parent = rastro

    -- Fumaça escura saindo do rastro
    local fumaca = Instance.new("ParticleEmitter")
    fumaca.Name = "FumacaDash"
    fumaca.Texture = "rbxasset://textures/particles/smoke_main.dds"
    fumaca.Rate = 60
    fumaca.Lifetime = NumberRange.new(0.6, 1.2)
    fumaca.Speed = NumberRange.new(2, 6)
    fumaca.SpreadAngle = Vector2.new(40, 40)
    fumaca.Size = NumberSequence.new(2, 3)
    fumaca.Transparency = NumberSequence.new(0.5, 1)
    fumaca.Color = ColorSequence.new(Color3.fromRGB(60, 60, 70))
    fumaca.Parent = rastro

    Debris:AddItem(rastro, DURACAO_RASTRO)
end

--[[
    Som do dash, criado por código.
--]]
local function tocarSomDash(root)
    local som = Instance.new("Sound")
    som.Name = "SomDash"
    som.SoundId = "rbxassetid://9114642969"
    som.Volume = 1
    som.PlaybackSpeed = 1.1
    som.Parent = root
    som:Play()
    Debris:AddItem(som, 1.5)
end

--[[
    Dash: avança DISTANCIA_DASH studs na direção da mira e fica
    invulnerável por DURACAO_INVULNERAVEL segundos.

    A invulnerabilidade é feita elevando o MaxHealth do Humanoid. Ao
    acabar, o MaxHealth volta para VIDA_CLASSE e a vida retorna ao valor
    de antes do dash, então o dash não serve de cura.

    Roda SÓ no servidor. O cliente apenas pede o dash pelo RemoteEvent.
--]]
local function executarDash(jogador, personagem)
    local root = personagem:FindFirstChild("HumanoidRootPart")
    local humanoid = personagem:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid or humanoid.Health <= 0 then
        return
    end

    local direcao = root.CFrame.LookVector
    local posicaoInicial = root.Position
    local destino = posicaoInicial + (direcao * DISTANCIA_DASH)

    marcarPartida(posicaoInicial)
    mostrarRastroDash(posicaoInicial, direcao)
    tocarSomDash(root)

    local vidaAntes = humanoid.Health
    humanoid.MaxHealth = 1000000
    humanoid.Health = 1000000

    --[[
        Avanço em passos, com o WalkSpeed zerado: o Humanoid não pode
        brigar com o CFrame, senão o motor de física reancora o corpo
        no lugar e o dash não sai do ponto.
    ]]
    local velocidadeGuardada = humanoid.WalkSpeed
    humanoid.WalkSpeed = 0

    task.spawn(function()
        local alturaInicial = posicaoInicial.Y
        local porPasso = (destino - posicaoInicial) / PASSOS_DASH

        for i = 1, PASSOS_DASH do
            if not root or not root.Parent or not humanoid.Parent then
                break
            end

            local atual = root.Position
            local novo = atual + porPasso
            novo = Vector3.new(novo.X, alturaInicial, novo.Z)

            root.CFrame = CFrame.new(novo, novo + direcao)

            mostrarRastroDash(atual, direcao)
            task.wait(DURACAO_DASH / PASSOS_DASH)
        end

        if humanoid and humanoid.Parent then
            humanoid.WalkSpeed = velocidadeGuardada
        end
    end)

    task.delay(DURACAO_INVULNERAVEL, function()
        if not humanoid or not humanoid.Parent then
            return
        end

        humanoid.MaxHealth = VIDA_CLASSE
        humanoid.Health = math.min(vidaAntes, VIDA_CLASSE)
    end)
end

--[[
    Cooldown do dash, guardado por jogador no servidor.
    Assim o segundo Shift seguido é bloqueado, mesmo se o cliente insistir.
--]]
local ultimoDash = {}

local function podeDarDash(jogador)
    local agora = os.clock()
    local ultimo = ultimoDash[jogador]
    if ultimo and (agora - ultimo) < COOLDOWN_DASH then
        return false
    end
    return true
end

local function registrarDash(jogador)
    ultimoDash[jogador] = os.clock()
end

-- Tool equipada de cada jogador, para validar o pedido de dash
local equipado = {}

--[[
    Escuta o pedido de dash vindo do cliente.
    O servidor confere: a Tool tem que estar equipada e o cooldown tem que
    ter passado. Assim o Shift repetido não passa.
--]]
local function aoPedirDash(jogador)
    local tool = equipado[jogador]
    if not tool or tool.Parent ~= jogador.Character then
        return
    end

    if not podeDarDash(jogador) then
        return
    end

    local personagem = jogador.Character
    if not personagem then
        return
    end

    registrarDash(jogador)
    executarDash(jogador, personagem)
end

obterRemoteDash().OnServerEvent:Connect(aoPedirDash)

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

    -- Passivo: Dash. O cliente avisa pelo RemoteEvent; o servidor decide.
    tool.Equipped:Connect(function()
        local personagem = tool.Parent
        local jogador = Players:GetPlayerFromCharacter(personagem)
        if not jogador then
            return
        end

        -- Marca que este jogador está com as Adagas equipadas,
        -- para o RemoteEvent saber que o pedido é válido.
        equipado[jogador] = tool
    end)

    tool.Unequipped:Connect(function()
        local jogador = Players:GetPlayerFromCharacter(tool.Parent)
        if jogador then
            equipado[jogador] = nil
        end
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

Players.PlayerRemoving:Connect(function(jogador)
    ultimoDash[jogador] = nil
    equipado[jogador] = nil
end)
