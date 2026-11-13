--[[
    ===================================================================
    Dungeon Slayer: Reborn - Sistema de Moedas (CoinSystem)
    Arquivo: src/server/CoinSystem.server.lua
    ===================================================================
    Descrição:
    Cria a leaderstats "Moedas" de cada jogador e expõe
    _G.AdicionarMoedas(jogador, quantidade) para os outros scripts.
    A tabela do Roblox (leaderboard) mostra o valor na tela.

    Este script cuida da RECOMPENSA. A exibição na tela (contador da
    dungeon e "+X moedas" flutuando) fica no HUDSystem.server.lua.
--]]

local Players = game:GetService("Players")

local NOME_STAT = "Moedas"

-- Garante a pasta leaderstats e o IntValue Moedas, começando em 0
local function garantirMoedas(jogador)
    local leaderstats = jogador:FindFirstChild("leaderstats")
    if not leaderstats then
        leaderstats = Instance.new("Folder")
        leaderstats.Name = "leaderstats"
        leaderstats.Parent = jogador
    end

    local moedas = leaderstats:FindFirstChild(NOME_STAT)
    if not moedas then
        moedas = Instance.new("IntValue")
        moedas.Name = NOME_STAT
        moedas.Value = 0
        moedas.Parent = leaderstats
    end

    return moedas
end

-- Chamada pelos outros sistemas (WaveSystem, BossSystem)
-- jogador: Player | quantidade: número de moedas a somar
function _G.AdicionarMoedas(jogador, quantidade)
    if typeof(jogador) ~= "Instance" or not jogador:IsA("Player") then
        warn("[CoinSystem] Jogador inválido. Moedas não entregues.")
        return
    end

    quantidade = math.floor(tonumber(quantidade) or 0)
    if quantidade == 0 then
        return
    end

    local moedas = garantirMoedas(jogador)
    moedas.Value = moedas.Value + quantidade
    print("[CoinSystem] " .. jogador.Name .. " recebeu " .. quantidade .. " moedas. Total: " .. moedas.Value)

    -- O HUD só mostra o que já foi creditado: a recompensa continua sendo só daqui.
    if _G.MostrarGanhoDeMoedas then
        _G.MostrarGanhoDeMoedas(jogador, quantidade)
    end
end

local function configurarJogador(jogador)
    garantirMoedas(jogador)
    print("[CoinSystem] Leaderstats criada para " .. jogador.Name)
end

Players.PlayerAdded:Connect(configurarJogador)
for _, jogador in ipairs(Players:GetPlayers()) do
    configurarJogador(jogador)
end

print("[CoinSystem] Sistema de moedas carregado com sucesso!")
