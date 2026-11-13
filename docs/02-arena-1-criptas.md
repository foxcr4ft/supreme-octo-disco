# Tutorial Passo a Passo: Arena 1 - Criptas Esquecidas (Roblox Studio)

Este guia explica, em linguagem simples e prática, como colocar os scripts da **Arena 1 (Criptas Esquecidas)** para rodar no **Roblox Studio**.

---

## 1. O que foi criado nesta Task
Nesta primeira versão jogável, você tem:
1. **Sistema de Moedas (`CoinSystem.server.lua`)**: Mostra as moedas dos jogadores no topo direito da tela (`leaderstats`) e premia quem derrotar os inimigos.
2. **Sistema do Chefe (`BossSystem.server.lua`)**: Cria o Boss *Lorde Esqueleto Malakar* na Wave 5 com 3 ataques especiais (Golpe Sísmico, Invocação de Servos e Carga Brutal).
3. **Sistema de Waves e Guerreiro (`WaveSystem.server.lua`)**:
   - Entrega a **Espada do Guerreiro** (ataque no clique + habilidade de giro *Whirlwind* em área).
   - Gera **5 ondas (waves)** crescentes de esqueletos.
   - Oferece o **botão de reviver** com 50% de vida na arena (gancho pronto para o Dev Product com Robux).

---

## 2. Passo a Passo para Colar no Roblox Studio

### Passo 1: Abrir o Roblox Studio
1. Abra o **Roblox Studio**.
2. Crie um projeto novo clicando em **Baseplate** (ou use seu mapa de dungeon, se já tiver um modelo de arena).

### Passo 2: Localizar a pasta `ServerScriptService`
1. No lado direito da tela, procure pela janela **Explorer** (se não estiver visível, vá na aba superior **View** e clique em **Explorer**).
2. Na lista de itens, localize a pasta chamada **ServerScriptService**.

### Passo 3: Colar o `CoinSystem`
1. Passe o mouse sobre **ServerScriptService**, clique no botão **`+`** e selecione **Script** (não LocalScript).
2. Renomeie esse script para: `CoinSystem`.
3. Abra o script, apague o `print("Hello world!")` que vem por padrão.
4. Cole o código do arquivo `src/server/CoinSystem.server.lua` dentro dele.

### Passo 4: Colar o `BossSystem`
1. Novamente em **ServerScriptService**, clique no **`+`** e adicione outro **Script**.
2. Renomeie para: `BossSystem`.
3. Abra o script, apague o texto padrão.
4. Cole o código do arquivo `src/server/BossSystem.server.lua` dentro dele.

### Passo 5: Colar o `WaveSystem`
1. Em **ServerScriptService**, clique no **`+`** e adicione um terceiro **Script**.
2. Renomeie para: `WaveSystem`.
3. Abra o script, apague o texto padrão.
4. Cole o código do arquivo `src/server/WaveSystem.server.lua` dentro dele.

---

## 3. Como Jogar e Testar

1. No menu superior do Roblox Studio, clique no botão azul **Play** (ou aperte `F5`).
2. **Equipando a Arma:**
   - Seu personagem vai nascer e automaticamente receberá a **Espada do Guerreiro** na barra de itens (tecla `1`).
   - Equipe a espada e use o **botão esquerdo do mouse** para golpear os esqueletos.
   - A habilidade de **Giro da Morte (Whirlwind)** ativa um anel de corte que atinge todos os inimigos ao seu redor.
3. **Sobrevivendo às Waves:**
   - **Wave 1:** 5 Esqueletos.
   - **Wave 2:** 7 Esqueletos (mais rápidos).
   - **Wave 3:** 9 Esqueletos (mais fortes).
   - **Wave 4:** 11 Esqueletos (horda pesada).
   - **Wave 5:** Chefe *Lorde Esqueleto Malakar* com barra de vida gigante na tela.
4. **Ganhando Moedas:**
   - Cada esqueleto comum derrotado dá **5 moedas**.
   - O Boss derrotado dá **100 moedas**.
   - O saldo acumulado aparece no canto superior direito da tela (`Moedas`).
5. **Se você morrer:**
   - Uma janela aparecerá na tela com o botão: **"★ Reviver na Arena (50% HP) ★"**.
   - Ao clicar, seu herói ressurge imediatamente no combate pronto para continuar a batalha!

---

## 4. Onde Entrará a Monetização Real (Robux)
No código dos scripts, os pontos de integração com o `MarketplaceService` do Roblox já estão sinalizados:
- **Reviver na Arena**: No `WaveSystem.server.lua`, basta conectar o clique do botão com `MarketplaceService:PromptProductPurchase` usando o ID do produto de 25 Robux.
- **Pacotes de Moedas**: No `CoinSystem.server.lua`, a função `ProcessarCompraDeMoedas` já está mapeada para conceder os pacotes de 100, 500 ou 1500 moedas após a confirmação do pagamento.
