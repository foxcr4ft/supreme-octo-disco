--[[
    ===================================================================
    Menu de Morte e Estado da Run (RunSystem)
    Arquivo: ServerScriptService/MapSystem/RunSystem
    ===================================================================
    Este arquivo existe como apoio da TASK 005. A logica das duas
    escolhas de morte fica no WaveSystem, que foi autorizado pelo Humano
    a receber a manutencao necessaria.

    Aqui ficam as funcoes de leitura que outros scripts podem usar para
    saber o estado da run, sem precisar mexer no WaveSystem.
--]]

local Players = game:GetService("Players")

local NOME_ARENA = "Arena1"

--[[
    Diz se o jogador esta dentro da area da arena.
    O Hub fica em Y = 100; a arena fica perto do chao.
--]]
function _G.JogadorEstaNaArena(jogador)
    if typeof(jogador) ~= "Instance" or not jogador:IsA("Player") then
        return false
    end

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
    Quantos jogadores estao vivos dentro da arena agora.
    Usado para decidir se o reinicio pode acontecer na hora.
--]]
function _G.ContarJogadoresNaArena()
    local total = 0

    for _, jogador in ipairs(Players:GetPlayers()) do
        if _G.JogadorEstaNaArena(jogador) then
            local personagem = jogador.Character
            if personagem then
                local humanoid = personagem:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    total = total + 1
                end
            end
        end
    end

    return total
end

Players.PlayerRemoving:Connect(function(jogador)
    -- Se a arena ficou vazia e havia reinicio pendente, tenta de novo
    task.wait(1)

    if _G.ReiniciarArena and _G.ContarJogadoresNaArena() == 0 then
        _G.ReiniciarArena()
    end
end)

print("[RunSystem] Apoio da run carregado.")
