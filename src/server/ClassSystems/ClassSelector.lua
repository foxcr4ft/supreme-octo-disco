--[[
    ===================================================================
    Dungeon Slayer: Reborn - Seleção de Classe (ClassSelector)
    Arquivo: ServerScriptService/ClassSystems/ClassSelector
    ===================================================================
    Mostra um botão para o jogador escolher a classe no spawn.
    Quem entrega a Tool e ajusta vida/velocidade são os scripts de cada
    classe. Aqui só se chama a função certa.

    CONTROLE DE ARMA ÚNICA:
    A classe escolhida é gravada no próprio jogador, no atributo
    "ClasseEscolhida". Este script VIGIA a mochila: quando uma arma de
    classe entra e não é a da classe escolhida, ela sai na hora.

    Isso é de propósito. O SwordSystem entrega a Espada do Guerreiro
    sozinho, 0,4 s depois do respawn. Uma limpeza feita uma vez só não
    resolvia: a Espada chegava DEPOIS dela e ficava na barra. Com a vigia
    ligada, a ordem de carregamento dos scripts deixa de importar.

    Classes disponíveis:
      Guerreiro - Espada do Guerreiro (SwordSystem, já existente)
      Mago      - Cajado Arcano      (MageSystem)
      Arqueiro  - Arco do Caçador    (ArcherSystem)
      Ladino    - Adagas Sombrias    (RogueSystem)
--]]

local Players = game:GetService("Players")

local ATRIBUTO_CLASSE = "ClasseEscolhida"

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
    Devolve o nome da arma que a classe do jogador deve ter.
    É a única arma de classe permitida na barra dele.
--]]
local function armaDaClasse(jogador)
    local nome = jogador:GetAttribute(ATRIBUTO_CLASSE) or classeEscolhida[jogador]
    local classe = nome and acharClasse(nome)
    if not classe then
        return nil
    end
    return classe.tool
end

--[[
    VIGIA a mochila do jogador.

    Quando uma arma de classe entra na mochila e não é a da classe
    escolhida, ela é removida na hora. É isso que impede o Mago, o
    Arqueiro e o Ladino de ficarem com a Espada do Guerreiro junto —
    mesmo que o SwordSystem a entregue depois deste script rodar.
--]]
local function vigiarMochila(jogador)
    local mochila = jogador:WaitForChild("Backpack")

    mochila.ChildAdded:Connect(function(arma)
        local permitida = armaDaClasse(jogador)
        if not permitida or arma.Name == permitida then
            return
        end

        -- Só mexe em arma de classe; outras ferramentas ficam em paz
        for _, classe in ipairs(CLASSES) do
            if classe.tool == arma.Name then
                task.defer(function()
                    if arma and arma.Parent then
                        arma:Destroy()
                    end
                end)
                return
            end
        end
    end)
end

--[[
    Tira da mochila e do corpo TODAS as armas de classe.
    Usada ao trocar de classe e também no respawn.
--]]
local function limparArmasDeClasse(jogador)
    local mochila = jogador:FindFirstChild("Backpack")
    local personagem = jogador.Character

    for _, classe in ipairs(CLASSES) do
        if mochila then
            local naMochila = mochila:FindFirstChild(classe.tool)
            if naMochila then
                naMochila:Destroy()
            end
        end

        if personagem then
            local noCorpo = personagem:FindFirstChild(classe.tool)
            if noCorpo then
                noCorpo:Destroy()
            end
        end
    end
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

            -- Grava a classe no próprio jogador. É esse atributo que a
            -- vigia da mochila lê.
            jogador:SetAttribute(ATRIBUTO_CLASSE, classe.nome)

            menu.Enabled = false

            -- Tira as armas antigas antes de entregar a nova
            limparArmasDeClasse(jogador)

            local personagem = jogador.Character

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
    A vigia da mochila cuida da Espada que o SwordSystem entrega depois;
    aqui só se garante que a arma certa esteja na mão.
--]]
local function reentregarClasse(jogador)
    -- Lê o atributo: a escolha sobrevive mesmo se este script recarregar
    local nome = jogador:GetAttribute(ATRIBUTO_CLASSE) or classeEscolhida[jogador]
    if not nome then
        return false
    end

    local classe = acharClasse(nome)
    if not classe then
        return false
    end

    task.wait(0.3)

    -- Limpa o que já estiver lá e entrega só a arma da classe salva.
    -- A vigia cobre a Espada que o SwordSystem entrega 0,4 s depois.
    limparArmasDeClasse(jogador)

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
    jogador:SetAttribute(ATRIBUTO_CLASSE, nil)

    -- A vigia começa junto com o jogador, antes de qualquer respawn
    vigiarMochila(jogador)

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
