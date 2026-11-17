local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local PONTO_RESERVA = Vector3.new(0, 5, 0)
local CENTRO_ARENA = Vector3.new(0, 5, 0)
local RAIO_SPAWN = 25

local waveAtual = 1
local MAX_WAVES = 5
local inimigosVivos = 0

-- TASK 005 (autorizado pelo Humano): controla o loop das waves.
local rodando = false
local reinicioPendente = false

--[[
    ===================================================================
    MENU DE MORTE: REVIVER NA ARENA OU VOLTAR AO HUB
    ===================================================================
--]]

local ATRIBUTO_REVIVE_PAGO = "RevivePago"

--[[
    RENASCIMENTO LIGADO AOS BOTOES.

    Antes o Roblox renascia o jogador sozinho, alguns segundos depois da
    morte, no SpawnLocation neutro do Hub. Isso atropelava a escolha:

      - no "Reviver na Arena" o corpo ja tinha ido para o Hub, entao o
        aviso aparecia e a run ficava intacta, mas o jogador era jogado
        para fora da arena;
      - no "Voltar ao Hub" a penalidade so rodava se o botao fosse
        clicado, porque o respawn automatico nao passa por botao nenhum.

    Com Players.CharacterAutoLoads desligado, quem renasce e o botao:

      - "Reviver na Arena" -> nasce no SpawnArena, com 50% de vida
      - "Voltar ao Hub"    -> e o renascimento gratuito, com a perda da
                              entrada, e acontece no clique

    Quem morre FORA da arena nao ve menu. Para esse caso existe a volta
    automatica ao Hub, alguns segundos depois, senao ficaria preso na
    tela de morte para sempre.
]]
Players.CharacterAutoLoads = false

local ESPERA_FORA_DA_ARENA = 4

--[[
    Acha o SpawnArena. Ele e criado pelo ArenaMapSystem dentro de
    Workspace/Arena1, mas a busca aceita qualquer lugar do Workspace.
--]]
local function acharSpawnArena()
    local arena = Workspace:FindFirstChild("Arena1")
    local spawnArena = nil

    if arena then
        spawnArena = arena:FindFirstChild("SpawnArena", true)
    end

    if not spawnArena then
        spawnArena = Workspace:FindFirstChild("SpawnArena", true)
    end

    if spawnArena and spawnArena:IsA("BasePart") then
        return spawnArena
    end

    return nil
end

--[[
    Coloca o corpo dentro da arena. E o que faltava no revive pago:
    sem isso o jogador nascia no SpawnLocation neutro, que fica no Hub.
--]]
local function levarParaArena(jogador)
    local personagem = jogador.Character
    if not personagem then
        return
    end

    local root = personagem:FindFirstChild("HumanoidRootPart")
    if not root then
        return
    end

    local destino = CENTRO_ARENA + Vector3.new(0, 5, 0)
    local spawnArena = acharSpawnArena()

    if spawnArena then
        destino = spawnArena.Position + Vector3.new(0, 4, 0)
    end

    root.CFrame = CFrame.new(destino)
end

--[[
    Devolve o jogador ao Hub. Usada pelo botao gratuito e pela morte
    fora da arena. A penalidade das moedas e responsabilidade de quem
    chama: aqui so acontece o renascimento.
--]]
local function voltarAoHub(jogador)
    if not jogador.Parent then
        return
    end

    jogador:SetAttribute(ATRIBUTO_REVIVE_PAGO, false)
    jogador.RespawnLocation = nil
    jogador:LoadCharacter()
end

--[[
    Só oferece a escolha para quem caiu DENTRO da arena.
    O Hub fica em Y = 100; a arena fica perto do chão.
--]]
local function estaNaArena(jogador)
    local personagem = jogador.Character
    if not personagem then
        return false
    end

    local root = personagem:FindFirstChild("HumanoidRootPart")
    if not root then
        return false
    end

    return root.Position.Y < 60
end

--[[
    Menu com DOIS botoes:
      1. Reviver na Arena (50% HP) - revive pago, run intacta.
      2. Voltar ao Hub (PERDE TUDO) - renascimento gratuito com penalidade.
--]]
local function obterOuCriarGuiReviver(jogador)
    local playerGui = jogador:WaitForChild("PlayerGui")
    local guiReviver = playerGui:FindFirstChild("ReviverGui")

    if guiReviver then
        return guiReviver
    end

    guiReviver = Instance.new("ScreenGui")
    guiReviver.Name = "ReviverGui"
    guiReviver.ResetOnSpawn = false
    guiReviver.Enabled = false
    guiReviver.Parent = playerGui

    local fundo = Instance.new("Frame")
    fundo.Name = "Fundo"
    fundo.Size = UDim2.new(0, 420, 0, 190)
    fundo.Position = UDim2.new(0.5, -210, 0.55, 0)
    fundo.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    fundo.BackgroundTransparency = 0.15
    fundo.BorderSizePixel = 0
    fundo.Parent = guiReviver

    local titulo = Instance.new("TextLabel")
    titulo.Name = "Titulo"
    titulo.Size = UDim2.new(1, -20, 0, 36)
    titulo.Position = UDim2.new(0, 10, 0, 10)
    titulo.BackgroundTransparency = 1
    titulo.Font = Enum.Font.SourceSansBold
    titulo.TextSize = 24
    titulo.TextColor3 = Color3.fromRGB(255, 80, 80)
    titulo.Text = "Você caiu em combate!"
    titulo.Parent = fundo

    -- BOTAO 1: revive pago
    local botaoPago = Instance.new("TextButton")
    botaoPago.Name = "BotaoReviver"
    botaoPago.Size = UDim2.new(1, -20, 0, 60)
    botaoPago.Position = UDim2.new(0, 10, 0, 54)
    botaoPago.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    botaoPago.BorderSizePixel = 0
    botaoPago.Text = "Reviver na Arena (50% HP) - mantem a run"
    botaoPago.TextColor3 = Color3.fromRGB(255, 255, 255)
    botaoPago.Font = Enum.Font.SourceSansBold
    botaoPago.TextSize = 16
    botaoPago.Parent = fundo

    -- BOTAO 2: renascimento gratuito, com a penalidade explicita
    local botaoGratis = Instance.new("TextButton")
    botaoGratis.Name = "BotaoVoltarHub"
    botaoGratis.Size = UDim2.new(1, -20, 0, 60)
    botaoGratis.Position = UDim2.new(0, 10, 0, 120)
    botaoGratis.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
    botaoGratis.BorderSizePixel = 0
    botaoGratis.Text = "Voltar ao Hub (PERDE TUDO) - sem pagar, perde a entrada"
    botaoGratis.TextColor3 = Color3.fromRGB(255, 235, 235)
    botaoGratis.Font = Enum.Font.SourceSansBold
    botaoGratis.TextSize = 15
    botaoGratis.Parent = fundo

    -- Revive pago: renasce DENTRO da arena, run intacta
    botaoPago.MouseButton1Click:Connect(function()
        guiReviver.Enabled = false

        jogador:SetAttribute(ATRIBUTO_REVIVE_PAGO, true)

        if _G.MostrarAviso then
            _G.MostrarAviso(jogador, "Reviveu na arena! A run continua.", Color3.fromRGB(0, 200, 255))
        end

        -- O SpawnLocation do renascimento aponta para a arena. O HubSystem
        -- só teleporta ao Hub quando o atributo nao esta marcado, entao
        -- este respawn respeita a arena.
        local spawnArena = acharSpawnArena()
        if spawnArena then
            jogador.RespawnLocation = spawnArena
        end

        jogador:LoadCharacter()

        -- Espera passar o HubSystem (0,3 s) e o seletor de classe, que
        -- repoe a vida cheia. Por isso a vida fica aqui no fim.
        task.wait(0.8)

        levarParaArena(jogador)
        jogador.RespawnLocation = nil

        local personagem = jogador.Character
        if personagem then
            local humanoid = personagem:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.Health = humanoid.MaxHealth * 0.5
            end

            if _G.EntregarEspada then
                _G.EntregarEspada(jogador)
            end
        end

        print("[Reviver] " .. jogador.Name .. " reviveu na arena. A run continua.")
    end)

    -- Renascimento gratuito: volta ao Hub e PERDE as moedas da entrada
    botaoGratis.MouseButton1Click:Connect(function()
        guiReviver.Enabled = false

        -- Penalidade total: perde o que ganhou nesta entrada.
        -- O leaderstats total NAO e tocado.
        local perdidas = 0
        if _G.PenalizarMoedasDaDungeon then
            perdidas = _G.PenalizarMoedasDaDungeon(jogador)
        end

        if _G.MostrarAviso then
            _G.MostrarAviso(jogador, "Perdeu " .. perdidas .. " moedas da entrada!", Color3.fromRGB(255, 90, 90))
        end

        print("[Reviver] " .. jogador.Name .. " foi para o Hub e perdeu " .. perdidas .. " moedas.")

        -- A arena dele recomeca do zero. Se ainda tiver alguem vivo
        -- dentro, o reinicio fica agendado ate a arena esvaziar.
        if _G.ReiniciarArena then
            _G.ReiniciarArena()
        end

        -- O clique E o renascimento: com o auto-load desligado, nada
        -- aconteceria sem esta chamada.
        voltarAoHub(jogador)
    end)

    return guiReviver
end

local function configurarJogador(jogador)
    jogador.CharacterAdded:Connect(function(personagem)
        local guiReviver = obterOuCriarGuiReviver(jogador)
        guiReviver.Enabled = false

        local humanoid = personagem:WaitForChild("Humanoid")
        humanoid.Died:Connect(function()
            print("[Reviver] O jogador " .. jogador.Name .. " caiu em combate!")

            if not estaNaArena(jogador) then
                -- Fora da arena o menu nao abre. Sem o auto-load, o
                -- jogador ficaria preso morto: volta sozinho ao Hub.
                task.delay(ESPERA_FORA_DA_ARENA, function()
                    if not jogador.Parent then
                        return
                    end

                    local atual = jogador.Character
                    local humanoideAtual = atual and atual:FindFirstChildOfClass("Humanoid")
                    if humanoideAtual and humanoideAtual.Health > 0 then
                        return
                    end

                    print("[Reviver] " .. jogador.Name .. " morreu fora da arena. De volta ao Hub.")
                    voltarAoHub(jogador)
                end)
                return
            end

            task.delay(1, function()
                if guiReviver then
                    guiReviver.Enabled = true
                end
            end)
        end)
    end)
end

local function garantirPersonagem(jogador)
    if not jogador.Character then
        jogador:LoadCharacter()
    end
end

Players.PlayerAdded:Connect(function(jogador)
    configurarJogador(jogador)
    garantirPersonagem(jogador)
end)

for _, jog in ipairs(Players:GetPlayers()) do
    configurarJogador(jog)
    garantirPersonagem(jog)
end

--[[
    ===================================================================
    CONTADOR DA DUNGEON
    ===================================================================
--]]

local function zerarContadorDaArena()
    if not _G.ZerarMoedasDaDungeon then
        return
    end

    for _, jog in ipairs(Players:GetPlayers()) do
        _G.ZerarMoedasDaDungeon(jog)
    end
end

--[[
    ===================================================================
    SPAWN DOS ESQUELETOS (WAVES 1 A 4)
    ===================================================================
--]]

local function acharPontoDeSpawn()
    local spawnLocation = Workspace:FindFirstChild("SpawnLocation")

    if not spawnLocation then
        spawnLocation = Workspace:FindFirstChildWhichIsA("SpawnLocation", true)
    end

    if spawnLocation and spawnLocation:IsA("BasePart") then
        return spawnLocation.Position
    end

    warn("[WaveSystem] SpawnLocation não encontrado. Usando Vector3.new(0, 5, 0).")
    return PONTO_RESERVA
end

local function spawnEsqueleto(wave)
    local pontoDeSpawn = acharPontoDeSpawn()

    local angulo = math.random() * math.pi * 2
    local distancia = math.random(4, RAIO_SPAWN)
    local posSpawn = pontoDeSpawn + Vector3.new(math.cos(angulo) * distancia, 3, math.sin(angulo) * distancia)

    local esqueleto = Instance.new("Model")
    esqueleto.Name = "Esqueleto (Wave " .. wave .. ")"

    local root = Instance.new("Part")
    root.Name = "HumanoidRootPart"
    root.Size = Vector3.new(2, 4, 1.5)
    root.Position = posSpawn
    root.BrickColor = BrickColor.new("Institutional white")
    root.Material = Enum.Material.Plastic
    root.CanCollide = true
    root.Parent = esqueleto

    local cabeca = Instance.new("Part")
    cabeca.Name = "Head"
    cabeca.Size = Vector3.new(1.6, 1.6, 1.6)
    cabeca.CFrame = root.CFrame * CFrame.new(0, 2.8, 0)
    cabeca.BrickColor = BrickColor.new("White")
    cabeca.Material = Enum.Material.Plastic
    cabeca.CanCollide = false
    cabeca.Massless = true
    cabeca.Parent = esqueleto

    local pescoco = Instance.new("WeldConstraint")
    pescoco.Part0 = root
    pescoco.Part1 = cabeca
    pescoco.Parent = root

    local humanoid = Instance.new("Humanoid")
    local vidaTotal = 100 + (wave * 30)
    humanoid.MaxHealth = vidaTotal
    humanoid.Health = vidaTotal
    humanoid.WalkSpeed = 10 + (wave * 1.5)
    humanoid.Parent = esqueleto

    esqueleto.PrimaryPart = root
    esqueleto.Parent = Workspace

    humanoid.Died:Connect(function()
        inimigosVivos = inimigosVivos - 1

        local tagCriador = humanoid:FindFirstChild("creator")
        if tagCriador and tagCriador.Value and tagCriador.Value:IsA("Player") then
            local jogadorMatador = tagCriador.Value
            if _G.AdicionarMoedas then
                _G.AdicionarMoedas(jogadorMatador, 5)
                print("[WaveSystem] Esqueleto derrotado! +5 moedas para " .. jogadorMatador.Name)
            end
        else
            print("[WaveSystem] Esqueleto derrotado, sem autor identificado. Sem moedas.")
        end

        task.wait(1.5)
        if esqueleto and esqueleto.Parent then
            esqueleto:Destroy()
        end
    end)

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
                        humAlvo:TakeDamage(8 + (wave * 2))
                        task.wait(1.2)
                    end
                end
            end
            task.wait(0.4)
        end
    end)

    inimigosVivos = inimigosVivos + 1
end

--[[
    ===================================================================
    ESTADO DA RUN E REINICIO
    ===================================================================
--]]

-- Diz se tem alguem vivo lutando dentro da arena.
local function temAlguemNaArena()
    for _, jog in ipairs(Players:GetPlayers()) do
        if estaNaArena(jog) then
            local personagem = jog.Character
            if personagem then
                local humanoid = personagem:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    return true
                end
            end
        end
    end
    return false
end

-- Limpa o que pertence a run: esqueletos e o boss.
local function limparInimigos()
    for _, objeto in ipairs(Workspace:GetChildren()) do
        if objeto:IsA("Model") then
            local nome = objeto.Name
            if nome:find("Esqueleto") or nome == "Lorde Esqueleto Malakar" then
                objeto:Destroy()
            end
        end
    end

    inimigosVivos = 0
end

--[[
    Reinicia a arena na Wave 1.

    Se ainda houver alguem vivo lutando, o reinicio NAO acontece na hora:
    seria derrubar a run de quem esta jogando. Ele fica agendado e
    acontece quando a arena esvaziar.
--]]
function _G.ReiniciarArena()
    if temAlguemNaArena() then
        reinicioPendente = true
        print("[WaveSystem] Reinício agendado: ainda tem gente lutando na arena.")
        return false
    end

    rodando = false
    limparInimigos()
    waveAtual = 1
    reinicioPendente = false

    print("[WaveSystem] Arena reiniciada na Wave 1.")

    task.spawn(function()
        task.wait(2)
        zerarContadorDaArena()
        rodando = true
    end)

    return true
end

task.spawn(function()
    while true do
        task.wait(2)

        if reinicioPendente and not temAlguemNaArena() then
            _G.ReiniciarArena()
        end
    end
end)

--[[
    ===================================================================
    LOOP PRINCIPAL DA ARENA
    ===================================================================
--]]
task.spawn(function()
    task.wait(4)
    print("[WaveSystem] Iniciando Arena 1: Criptas Esquecidas!")
    zerarContadorDaArena()

    rodando = true

    while rodando do
        for w = 1, MAX_WAVES do
            if not rodando then
                break
            end

            waveAtual = w

            if waveAtual < 5 then
                print("[WaveSystem] Wave " .. waveAtual .. "/" .. MAX_WAVES .. " começou.")

                local qtdInimigos = 3 + (waveAtual * 2)
                for i = 1, qtdInimigos do
                    if not rodando then
                        break
                    end

                    spawnEsqueleto(waveAtual)
                    task.wait(0.6)
                end

                while inimigosVivos > 0 and rodando do
                    task.wait(0.5)
                end

                if not rodando then
                    break
                end

                print("[WaveSystem] Wave " .. waveAtual .. "/" .. MAX_WAVES .. " concluída!")
                task.wait(3)
            else
                print("[WaveSystem] Wave 5: o chefe final apareceu!")

                if _G.IniciarLutaBoss then
                    _G.IniciarLutaBoss(CENTRO_ARENA + Vector3.new(0, 4, 0), function()
                        print("==================================================")
                        print("★ ARENA 1 CONCLUÍDA! PARABÉNS GUERREIROS! ★")
                        print("==================================================")
                    end)
                else
                    warn("[WaveSystem] BossSystem não encontrado!")
                end

                rodando = false
            end
        end

        if rodando then
            print("[WaveSystem] As 5 waves terminaram. Arena livre para nova entrada.")
            rodando = false
        end
    end
end)
