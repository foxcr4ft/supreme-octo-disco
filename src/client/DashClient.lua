--[[
    ===================================================================
    Dungeon Slayer: Reborn - Cliente do Dash do Ladino
    Arquivo: StarterPlayerScripts/DashClient (LocalScript)
    ===================================================================
    O teclado só pode ser lido no cliente. Este script observa o Shift e
    avisa o servidor pelo RemoteEvent "DashLadino".

    Ele NÃO decide nada: só manda o pedido. Quem valida cooldown, vida e
    invulnerabilidade é o RogueSystem, no servidor. Assim ninguém consegue
    burlar o cooldown mexendo no cliente.

    Só manda o pedido se o jogador estiver com as Adagas Sombrias equipadas.
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local jogador = Players.LocalPlayer

local NOME_ADAGAS = "Adagas Sombrias"
local NOME_REMOTE_DASH = "DashLadino"

-- Espera o RemoteEvent que o RogueSystem cria no servidor
local remoteDash = ReplicatedStorage:WaitForChild(NOME_REMOTE_DASH)

local function estaComAdagasEquipadas()
    local personagem = jogador.Character
    if not personagem then
        return false
    end

    local tool = personagem:FindFirstChildOfClass("Tool")
    return tool ~= nil and tool.Name == NOME_ADAGAS
end

UserInputService.InputBegan:Connect(function(entrada, processadoPeloJogo)
    -- Se o jogo já tratou a tecla (por exemplo, num chat aberto), ignora
    if processadoPeloJogo then
        return
    end

    if entrada.KeyCode ~= Enum.KeyCode.LeftShift then
        return
    end

    if not estaComAdagasEquipadas() then
        return
    end

    -- Só pede. O servidor decide se o dash pode sair agora.
    remoteDash:FireServer()
end)
