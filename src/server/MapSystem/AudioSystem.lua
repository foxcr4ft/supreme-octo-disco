--[[
    ===================================================================
    Dungeon Slayer: Reborn - Sistema de Áudio (AudioSystem)
    Arquivo: ServerScriptService/MapSystem/AudioSystem
    ===================================================================
    Toca a música certa conforme o lugar onde o jogador está:

      - No Hub        -> MusicaHub  (calma, em loop)
      - Na Arena 1    -> MusicaArena (tensa, em loop)

    Também cuida dos sons de combate:
      - Som de hit no inimigo
      - Som de morte do esqueleto

    Os Sound são criados dentro do SoundService, com os IDs free do Roblox
    listados no topo. Para trocar uma música, é só mudar o ID aqui.

    COMO O JOGO SABE ONDE O JOGADOR ESTÁ:
    Pela posição Y do personagem. O Hub fica bem acima da arena (em
    Y = 100), então a conta é simples e não depende de nenhum outro script.

    Este script NÃO altera nada da arena nem das classes. Os sons de
    combate são ligados às Part que os próprios sistemas já criam.
--]]

local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")

--[[
    ===================================================================
    IDs DOS ÁUDIOS (todos free do Roblox)
    Para trocar a música, mude o ID aqui e pronto.
    ===================================================================
--]]
local ID_MUSICA_HUB = "rbxassetid://1837879082" -- calma, ambiente
local ID_MUSICA_ARENA = "rbxassetid://1836316838" -- tensa, batalha
local ID_SOM_HIT = "rbxassetid://9114642969" -- impacto curto
local ID_SOM_MORTE = "rbxassetid://9114642969" -- queda

-- Altura a partir da qual o jogador está no Hub (o Hub fica em Y = 100)
local ALTURA_HUB = 60

--[[
    Cria (ou reaproveita) um Sound dentro do SoundService.
--]]
local function obterSom(nome, id, volume, loopado)
    local som = SoundService:FindFirstChild(nome)
    if not som then
        som = Instance.new("Sound")
        som.Name = nome
        som.SoundId = id
        som.Volume = volume
        som.Looped = loopado
        som.Parent = SoundService
    end
    return som
end

local musicaHub = obterSom("MusicaHub", ID_MUSICA_HUB, 0.35, true)
local musicaArena = obterSom("MusicaArena", ID_MUSICA_ARENA, 0.4, true)

--[[
    Toca uma música e para a outra.
--]]
local function tocarSomente(somParaTocar, somParaParar)
    if somParaParar and somParaParar.IsPlaying then
        somParaParar:Stop()
    end

    if somParaTocar and not somParaTocar.IsPlaying then
        somParaTocar:Play()
    end
end

--[[
    Decide qual música toca, olhando a altura do personagem.
--]]
local function atualizarMusicaDoJogador(jogador)
    local personagem = jogador.Character
    if not personagem then
        return
    end

    local root = personagem:FindFirstChild("HumanoidRootPart")
    if not root then
        return
    end

    if root.Position.Y >= ALTURA_HUB then
        tocarSomente(musicaHub, musicaArena)
    else
        tocarSomente(musicaArena, musicaHub)
    end
end

--[[
    Som de combate: toca um som curto numa posição do mundo.
    Assim o som sai de onde o golpe aconteceu.

    O som é colocado numa Part temporária, porque Sound sozinho no
    Workspace não tem posição.
--]]
local function tocarSomNoMundo(id, posicao, volume, velocidade)
    local parte = Instance.new("Part")
    parte.Name = "PontoDeSom"
    parte.Size = Vector3.new(0.2, 0.2, 0.2)
    parte.Position = posicao
    parte.Anchored = true
    parte.CanCollide = false
    parte.CanTouch = false
    parte.CanQuery = false
    parte.Transparency = 1
    parte.Parent = Workspace

    local som = Instance.new("Sound")
    som.SoundId = id
    som.Volume = volume
    som.PlaybackSpeed = velocidade
    som.Parent = parte
    som:Play()

    task.delay(2, function()
        if parte and parte.Parent then
            parte:Destroy()
        end
    end)
end

--[[
    Liga os sons de combate nas Part de efeito que os outros sistemas
    já criam: os rastros de ataque contam como hit, e a saída de um
    esqueleto do jogo marca a morte.

    Nada disso altera os scripts originais: só escutamos o que já existe
    no Workspace.
--]]
local function ligarSonsDeCombate()
    Workspace.DescendantAdded:Connect(function(objeto)
        if not objeto:IsA("BasePart") then
            return
        end

        local nome = objeto.Name

        -- Golpes: qualquer Part de rastro de ataque
        if nome == "SwingGuerreiro" or nome == "RastroAdagas" or nome == "BolaDeFogo" or nome == "FlechaCacador" then
            tocarSomNoMundo(ID_SOM_HIT, objeto.Position, 0.5, 1.2)
            return
        end

        -- Morte: quando um esqueleto sai do jogo
        if nome:find("Esqueleto") then
            objeto.AncestryChanged:Connect(function()
                if not objeto:IsDescendantOf(game) then
                    tocarSomNoMundo(ID_SOM_MORTE, objeto.Position, 0.6, 0.85)
                end
            end)
        end
    end)
end

local function configurarJogador(jogador)
    jogador.CharacterAdded:Connect(function(personagem)
        task.wait(0.5)

        local root = personagem:WaitForChild("HumanoidRootPart", 5)
        if not root then
            return
        end

        -- Atualiza a música agora e sempre que o jogador mudar de lugar
        atualizarMusicaDoJogador(jogador)

        task.spawn(function()
            while personagem.Parent do
                task.wait(1)
                atualizarMusicaDoJogador(jogador)
            end
        end)
    end)
end

ligarSonsDeCombate()

Players.PlayerAdded:Connect(configurarJogador)
for _, jogador in ipairs(Players:GetPlayers()) do
    configurarJogador(jogador)

    if jogador.Character then
        task.spawn(function()
            atualizarMusicaDoJogador(jogador)
        end)
    end
end

Players.PlayerRemoving:Connect(function()
    -- Se não sobrou ninguém, para a música
    if #Players:GetPlayers() == 0 then
        musicaHub:Stop()
        musicaArena:Stop()
    end
end)

print("[AudioSystem] Áudio carregado: MusicaHub e MusicaArena prontas.")
