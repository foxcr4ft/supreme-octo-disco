--[[
    ===================================================================
    Dungeon Slayer: Reborn - Seleção de Classe (ClassSelector)
    Arquivo: ServerScriptService/ClassSystems/ClassSelector
    ===================================================================
    Mostra um botão para o jogador escolher a classe no spawn.
    Quem entrega a Tool e ajusta vida/velocidade são os scripts de cada
    classe. Aqui só se chama a função certa.

    Classes disponíveis:
      Guerreiro - Espada do Guerreiro (SwordSystem, já existente)
      Mago      - Cajado Arcano      (MageSystem)
      Arqueiro  - Arco do Caçador    (ArcherSystem)
      Ladino    - Adagas Sombrias    (RogueSystem)

    Os scripts das classes são lidos com _G quando carregam, então a
    ordem de carregamento no Studio não importa.
--]]

local Players = game:GetService("Players")

-- Nome da Tool e funções de cada classe
local CLASSES = {
    {
        nome = "Guerreiro",
        tool = "Espada do Guerreiro",
        chamar = "EntregarEspada",
        atributos = nil, -- o Guerreiro usa os atributos padrão do Roblox
        cor = Color3.fromRGB(60, 140, 255),
    },
    {
        nome = "Mago",
        tool = "Cajado Arcano",
        chamar = "EntregarKitMago",
        atributos = "AplicarAtributosMago",
        cor = Color3.fromRGB(150, 80, 220),
    },
    {
        nome = "Arqueiro",
        tool = "Arco do Caçador",
        chamar = "EntregarKitArqueiro",
        atributos = "AplicarAtributosArqueiro",
        cor = Color3.fromRGB(60, 190, 110),
    },
    {
        nome = "Ladino",
        tool = "Adagas Sombrias",
        chamar = "EntregarKitLadino",
        atributos = "AplicarAtributosLadino",
        cor = Color3.fromRGB(130, 130, 145),
    },
}

-- Guarda a classe escolhida de cada jogador
local classeEscolhida = {}

local function acharClasse(nome)
    for _, classe in ipairs(CLASSES) do
        if classe.nome == nome then
            return classe
        end
    end
    return nil
end

--[[
    Cria o menu de escolha na tela do jogador.
--]]
local function criarMenu(jogador)
    local playerGui = jogador:WaitForChild("PlayerGui")

    local menu = playerGui:FindFirstChild("MenuDeClasse")
    if menu then
        menu.Enabled = true
        return menu
    end

    menu = Instance.new("ScreenGui")
    menu.Name = "MenuDeClasse"
    menu.ResetOnSpawn = false -- não some ao renascer
    menu.IgnoreGuiInset = true
    menu.Enabled = true
    menu.Parent = playerGui

    local fundo = Instance.new("Frame")
    fundo.Name = "Fundo"
    fundo.Size = UDim2.new(0, 460, 0, 300)
    fundo.Position = UDim2.new(0.5, -230, 0.5, -150)
    fundo.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
    fundo.BackgroundTransparency = 0.1
    fundo.BorderSizePixel = 0
    fundo.Parent = menu

    local titulo = Instance.new("TextLabel")
    titulo.Size = UDim2.new(1, 0, 0, 44)
    titulo.BackgroundTransparency = 1
    titulo.Font = Enum.Font.SourceSansBold
    titulo.TextSize = 26
    titulo.TextColor3 = Color3.fromRGB(255, 255, 255)
    titulo.Text = "Escolha sua classe"
    titulo.Parent = fundo

    -- Um botão para cada classe
    for indice, classe in ipairs(CLASSES) do
        local botao = Instance.new("TextButton")
        botao.Name = "Botao" .. classe.nome
        botao.Size = UDim2.new(0, 200, 0, 70)
        botao.Position = UDim2.new(
            0, 16 + (((indice - 1) % 2) * 214),
            0, 56 + (math.floor((indice - 1) / 2) * 84)
        )
        botao.BackgroundColor3 = classe.cor
        botao.BorderSizePixel = 0
        botao.Font = Enum.Font.SourceSansBold
        botao.TextSize = 20
        botao.TextColor3 = Color3.fromRGB(255, 255, 255)
        botao.Text = classe.nome
        botao.Parent = fundo

        botao.MouseButton1Click:Connect(function()
            classeEscolhida[jogador] = classe.nome
            menu.Enabled = false

            -- Tira a arma da classe anterior, para não ficar com duas
            local mochila = jogador:FindFirstChild("Backpack")
            local personagem = jogador.Character
            for _, outra in ipairs(CLASSES) do
                if outra.nome ~= classe.nome and mochila then
                    local antiga = mochila:FindFirstChild(outra.tool)
                    if antiga then
                        antiga:Destroy()
                    end
                end
                if outra.nome ~= classe.nome and personagem then
                    local antigaNoCorpo = personagem:FindFirstChild(outra.tool)
                    if antigaNoCorpo then
                        antigaNoCorpo:Destroy()
                    end
                end
            end

            -- Aplica os atributos da classe
            if personagem and classe.atributos and _G[classe.atributos] then
                _G[classe.atributos](personagem)
            end

            -- Entrega a Tool da classe
            if _G[classe.chamar] then
                _G[classe.chamar](jogador)
            else
                warn("[ClassSelector] A classe " .. classe.nome .. " ainda não carregou.")
            end

            print("[ClassSelector] " .. jogador.Name .. " escolheu " .. classe.nome .. ".")
        end)
    end

    local instrucao = Instance.new("TextLabel")
    instrucao.Size = UDim2.new(1, -32, 0, 20)
    instrucao.Position = UDim2.new(0, 16, 1, -28)
    instrucao.BackgroundTransparency = 1
    instrucao.Font = Enum.Font.SourceSans
    instrucao.TextSize = 16
    instrucao.TextColor3 = Color3.fromRGB(200, 200, 210)
    instrucao.TextXAlignment = Enum.TextXAlignment.Left
    instrucao.Text = "Trocar de classe apaga a arma antiga e entrega a nova."
    instrucao.Parent = fundo

    return menu
end

--[[
    Entrega de novo a Tool da classe já escolhida (usado no renascimento).
--]]
local function reentregarClasse(jogador)
    local nome = classeEscolhida[jogador]
    if not nome then
        return false
    end

    local classe = acharClasse(nome)
    if not classe then
        return false
    end

    task.wait(0.3)

    local personagem = jogador.Character
    if personagem and classe.atributos and _G[classe.atributos] then
        _G[classe.atributos](personagem)
    end

    if _G[classe.chamar] then
        _G[classe.chamar](jogador)
    end

    return true
end

local function configurarJogador(jogador)
    classeEscolhida[jogador] = nil

    jogador.CharacterAdded:Connect(function()
        -- Se já escolheu antes, entrega a mesma classe direto.
        -- Se ainda não escolheu, mostra o menu.
        task.spawn(function()
            local jaEscolheu = reentregarClasse(jogador)
            if not jaEscolheu then
                task.wait(0.5)
                criarMenu(jogador)
            end
        end)
    end)

    if jogador.Character then
        task.spawn(function()
            task.wait(0.5)
            criarMenu(jogador)
        end)
    end
end

Players.PlayerAdded:Connect(configurarJogador)
for _, jogador in ipairs(Players:GetPlayers()) do
    configurarJogador(jogador)
end

Players.PlayerRemoving:Connect(function(jogador)
    classeEscolhida[jogador] = nil
end)
