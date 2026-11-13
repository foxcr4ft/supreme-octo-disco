--[[
    ===================================================================
    Dungeon Slayer: Reborn - HUD da Arena (HUDSystem)
    Arquivo: src/server/HUDSystem.server.lua
    ===================================================================
    Só exibição. Não dá moeda nenhuma: quem credita é o CoinSystem.

    Mostra duas coisas na tela de cada jogador:
      1. Contador "Moedas na Dungeon: X", que zera ao entrar na arena
         e soma a cada abate. É separado do leaderstats total.
      2. Texto "+X moedas" subindo no centro da tela por 1,5 s.

    TASK 005 (autorizado pelo Humano): ganhou três funções novas, para
    o menu de morte funcionar:
      - _G.LerMoedasDaDungeon    (só leitura)
      - _G.PenalizarMoedasDaDungeon (morte sem pagar: perde a entrada)
      - _G.MostrarAviso          (aviso curto no centro da tela)

    A recompensa em si NÃO mudou: quem credita continua sendo o
    _G.AdicionarMoedas do CoinSystem.
--]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local TEMPO_NA_TELA = 1.5 -- quanto tempo o "+X moedas" fica visível

-- Contador da dungeon de cada jogador (separado do leaderstats)
local moedasDaDungeon = {}

--[[
    Cria (ou reaproveita) o ScreenGui do HUD e devolve as peças que usamos.
--]]
local function obterHud(jogador)
    local playerGui = jogador:WaitForChild("PlayerGui")

    local hud = playerGui:FindFirstChild("HUDDungeon")
    if hud then
        return hud, hud:FindFirstChild("ContadorMoedas"), hud:FindFirstChild("AvisoMoedas")
    end

    hud = Instance.new("ScreenGui")
    hud.Name = "HUDDungeon"
    hud.ResetOnSpawn = false -- o HUD não some ao renascer
    hud.IgnoreGuiInset = true
    hud.Parent = playerGui

    -- Contador no canto superior esquerdo
    local contador = Instance.new("TextLabel")
    contador.Name = "ContadorMoedas"
    contador.Size = UDim2.new(0, 300, 0, 36)
    contador.Position = UDim2.new(0, 16, 0, 16)
    contador.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
    contador.BackgroundTransparency = 0.35
    contador.BorderSizePixel = 0
    contador.Font = Enum.Font.SourceSansBold
    contador.TextSize = 22
    contador.TextColor3 = Color3.fromRGB(255, 215, 0)
    contador.TextXAlignment = Enum.TextXAlignment.Left
    contador.Text = "Moedas na Dungeon: 0"
    contador.Parent = hud

    -- Aviso de ganho no centro da tela
    local aviso = Instance.new("TextLabel")
    aviso.Name = "AvisoMoedas"
    aviso.Size = UDim2.new(0, 320, 0, 48)
    aviso.Position = UDim2.new(0.5, -160, 0.42, 0)
    aviso.BackgroundTransparency = 1
    aviso.Font = Enum.Font.SourceSansBold
    aviso.TextSize = 34
    aviso.TextColor3 = Color3.fromRGB(255, 215, 0)
    aviso.TextStrokeTransparency = 0.4
    aviso.TextTransparency = 1 -- começa invisível
    aviso.Text = ""
    aviso.Parent = hud

    return hud, contador, aviso
end

local function atualizarContador(jogador)
    local _, contador = obterHud(jogador)
    if contador then
        contador.Text = "Moedas na Dungeon: " .. (moedasDaDungeon[jogador] or 0)
    end
end

--[[
    Mostra "+X moedas" no centro da tela, subindo e desaparecendo.
    Chamada pelo CoinSystem depois de creditar a moeda.
--]]
function _G.MostrarGanhoDeMoedas(jogador, quantidade)
    if typeof(jogador) ~= "Instance" or not jogador:IsA("Player") then
        return
    end

    quantidade = math.floor(tonumber(quantidade) or 0)
    if quantidade == 0 then
        return
    end

    -- Soma no contador da dungeon (o leaderstats total é do CoinSystem)
    moedasDaDungeon[jogador] = (moedasDaDungeon[jogador] or 0) + quantidade
    atualizarContador(jogador)

    local _, _, aviso = obterHud(jogador)
    if not aviso then
        return
    end

    aviso.Text = "+" .. quantidade .. " moedas"
    aviso.TextColor3 = Color3.fromRGB(255, 215, 0)
    aviso.TextTransparency = 0
    aviso.TextStrokeTransparency = 0.4
    aviso.Position = UDim2.new(0.5, -160, 0.42, 0)

    -- Sobe um pouco e some
    local subida = TweenService:Create(
        aviso,
        TweenInfo.new(TEMPO_NA_TELA, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {
            Position = UDim2.new(0.5, -160, 0.34, 0),
            TextTransparency = 1,
            TextStrokeTransparency = 1,
        }
    )

    subida:Play()
    task.delay(TEMPO_NA_TELA, function()
        if aviso and aviso.Text == "+" .. quantidade .. " moedas" then
            aviso.Text = ""
        end
    end)
end

--[[
    Zera o contador da dungeon. Chamado quando o jogador entra na arena.
--]]
function _G.ZerarMoedasDaDungeon(jogador)
    if typeof(jogador) ~= "Instance" or not jogador:IsA("Player") then
        return
    end

    moedasDaDungeon[jogador] = 0
    atualizarContador(jogador)
end

--[[
    Devolve quantas moedas o jogador ganhou NESTA entrada da dungeon.
    É só leitura: não mexe no leaderstats total, que é do CoinSystem.
--]]
function _G.LerMoedasDaDungeon(jogador)
    if typeof(jogador) ~= "Instance" or not jogador:IsA("Player") then
        return 0
    end

    return moedasDaDungeon[jogador] or 0
end

--[[
    Aplica a penalidade de morte: perde as moedas ganhas nesta entrada.

    A TASK 005 definiu que morrer sem pagar o revive custa TUDO o que
    foi ganho naquela entrada. O contador volta a zero, e o saldo total
    do leaderstats NÃO é tocado — ele fica no CoinSystem, intacto.
--]]
function _G.PenalizarMoedasDaDungeon(jogador)
    if typeof(jogador) ~= "Instance" or not jogador:IsA("Player") then
        return 0
    end

    local perdidas = moedasDaDungeon[jogador] or 0

    moedasDaDungeon[jogador] = 0
    atualizarContador(jogador)

    print("[HUDSystem] " .. jogador.Name .. " perdeu " .. perdidas .. " moedas da entrada.")

    return perdidas
end

--[[
    Mostra um aviso curto no centro da tela, com a cor escolhida.
    Usado pelo menu de morte do WaveSystem.
--]]
function _G.MostrarAviso(jogador, texto, cor)
    if typeof(jogador) ~= "Instance" or not jogador:IsA("Player") then
        return
    end

    local _, _, aviso = obterHud(jogador)
    if not aviso then
        return
    end

    aviso.Text = texto
    aviso.TextColor3 = cor or Color3.fromRGB(255, 215, 0)
    aviso.TextTransparency = 0
    aviso.TextStrokeTransparency = 0.4
    aviso.Position = UDim2.new(0.5, -160, 0.42, 0)

    task.delay(TEMPO_NA_TELA, function()
        if aviso then
            aviso.Text = ""
            aviso.TextTransparency = 1
        end
    end)
end

local function configurarJogador(jogador)
    moedasDaDungeon[jogador] = 0
    obterHud(jogador)
    atualizarContador(jogador)
end

Players.PlayerAdded:Connect(configurarJogador)
for _, jogador in ipairs(Players:GetPlayers()) do
    configurarJogador(jogador)
end

Players.PlayerRemoving:Connect(function(jogador)
    moedasDaDungeon[jogador] = nil
end)
