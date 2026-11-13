--[[
    ===================================================================
    Dungeon Slayer: Reborn - Espada do Guerreiro (SwordSystem)
    Arquivo: src/server/SwordSystem.server.lua
    ===================================================================
    Este é o único script que cuida da espada.
    Aqui NÃO existe Instance.new("Script") nem .Source: isso dá erro no Roblox.
    O dano é controlado no servidor pelo tool.Activated, com tag creator
    em quem bateu e cooldown entre golpes. O giro sai no servidor enquanto
    a espada estiver equipada.

    Outros scripts podem pedir a espada com:
      _G.EntregarEspada(jogador)
--]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")

local NOME_ESPADA = "Espada do Guerreiro"
local DANO_BASICO = 25
local COOLDOWN_BASICO = 0.5
local DANO_GIRO = 50
local COOLDOWN_GIRO = 8
local RAIO_GIRO = 14

--[[
    Grava a tag "creator" no Humanoid do inimigo.
    É essa tag que os outros sistemas leem para saber quem causou o dano.
--]]
local function marcarCriador(humanoideInimigo, jogador)
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
    Monta a Tool "Espada do Guerreiro" só com Parts e WeldConstraint.
    Nenhum Script é criado dentro dela.
--]]
local function criarEspada()
    local tool = Instance.new("Tool")
    tool.Name = NOME_ESPADA
    tool.ToolTip = "Clique para golpear. O giro sai sozinho a cada 8 segundos."
    tool.CanBeDropped = false
    tool.RequiresHandle = true

    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(1, 4, 1)
    handle.BrickColor = BrickColor.new("Silver")
    handle.Material = Enum.Material.Metal
    handle.Parent = tool

    local lamina = Instance.new("Part")
    lamina.Name = "Lamina"
    lamina.Size = Vector3.new(0.5, 3, 0.5)
    lamina.BrickColor = BrickColor.new("Cyan")
    lamina.Material = Enum.Material.Neon
    lamina.CanCollide = false
    lamina.Massless = true
    lamina.Parent = tool

    lamina.CFrame = handle.CFrame * CFrame.new(0, 3.2, 0)

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = handle
    weld.Part1 = lamina
    weld.Parent = handle

    -- Ataque básico: só no servidor, com cooldown
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

        local conexao
        conexao = handle.Touched:Connect(function(hit)
            local modelo = hit:FindFirstAncestorOfClass("Model")
            if not ehInimigo(modelo, personagem) then
                return
            end

            local humanoideInimigo = modelo:FindFirstChildOfClass("Humanoid")
            marcarCriador(humanoideInimigo, jogador)
            humanoideInimigo:TakeDamage(DANO_BASICO)
            print("[SwordSystem] Golpe de " .. jogador.Name .. " causou " .. DANO_BASICO .. " de dano em " .. modelo.Name)
        end)

        task.delay(COOLDOWN_BASICO, function()
            if conexao then
                conexao:Disconnect()
            end
            podeAtacar = true
        end)
    end)

    -- Giro: roda no servidor enquanto a espada está equipada
    tool.Equipped:Connect(function()
        local personagem = tool.Parent
        local jogador = Players:GetPlayerFromCharacter(personagem)
        if not jogador then
            return
        end

        task.spawn(function()
            while tool.Parent == personagem do
                task.wait(COOLDOWN_GIRO)
                if tool.Parent ~= personagem then
                    break
                end

                local root = personagem:FindFirstChild("HumanoidRootPart")
                local humanoide = personagem:FindFirstChildOfClass("Humanoid")
                if not root or not humanoide or humanoide.Health <= 0 then
                    continue
                end

                -- Anel visual do giro
                local anel = Instance.new("Part")
                anel.Shape = Enum.PartType.Cylinder
                anel.Size = Vector3.new(0.5, 16, 16)
                anel.CFrame = root.CFrame * CFrame.Angles(0, 0, math.rad(90))
                anel.BrickColor = BrickColor.new("Cyan")
                anel.Material = Enum.Material.Neon
                anel.Transparency = 0.4
                anel.Anchored = true
                anel.CanCollide = false
                anel.Parent = Workspace
                Debris:AddItem(anel, 0.4)

                -- Dano em área só em inimigos
                for _, objeto in ipairs(Workspace:GetChildren()) do
                    if ehInimigo(objeto, personagem) then
                        local rootInimigo = objeto:FindFirstChild("HumanoidRootPart")
                        if rootInimigo and (rootInimigo.Position - root.Position).Magnitude <= RAIO_GIRO then
                            local humanoideInimigo = objeto:FindFirstChildOfClass("Humanoid")
                            marcarCriador(humanoideInimigo, jogador)
                            humanoideInimigo:TakeDamage(DANO_GIRO)
                            print("[SwordSystem] Giro atingiu " .. objeto.Name)
                        end
                    end
                end
            end
        end)
    end)

    return tool
end

--[[
    Entrega a espada para o jogador, sem duplicar.
    Pode ser chamada de qualquer outro script do servidor.
--]]
function _G.EntregarEspada(jogador)
    if typeof(jogador) ~= "Instance" or not jogador:IsA("Player") then
        return
    end

    local mochila = jogador:FindFirstChild("Backpack")
    if not mochila then
        return
    end

    local jaTem = mochila:FindFirstChild(NOME_ESPADA)
    local noPersonagem = jogador.Character and jogador.Character:FindFirstChild(NOME_ESPADA)
    if jaTem or noPersonagem then
        return
    end

    local espada = criarEspada()
    espada.Parent = mochila
    print("[SwordSystem] Espada entregue para " .. jogador.Name)
end

local function aoNascer(jogador)
    task.wait(0.4)
    _G.EntregarEspada(jogador)
end

local function configurarJogador(jogador)
    jogador.CharacterAdded:Connect(function()
        aoNascer(jogador)
    end)

    if jogador.Character then
        task.spawn(aoNascer, jogador)
    end
end

Players.PlayerAdded:Connect(configurarJogador)
for _, jogador in ipairs(Players:GetPlayers()) do
    configurarJogador(jogador)
end

print("[SwordSystem] Espada do Guerreiro carregada no servidor.")
