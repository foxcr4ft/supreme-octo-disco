# Tutorial Passo a Passo: Arena 1 - Criptas Esquecidas (Roblox Studio)

Este guia explica, em linguagem simples e prática, como colocar os scripts da **Arena 1 (Criptas Esquecidas)** para rodar no **Roblox Studio**.

---

## 1. O que foi criado nesta Task
Nesta primeira versão jogável, você tem:
1. **Sistema de Moedas (`CoinSystem.server.lua`)**: Mostra as moedas dos jogadores no topo direito da tela (`leaderstats`) e premia quem derrotar os inimigos.
2. **Sistema do Chefe (`BossSystem.server.lua`)**: Cria o Boss *Lorde Esqueleto Malakar* na Wave 5 com 3 ataques especiais (Golpe Sísmico, Invocação de Servos e Carga Brutal).
3. **Sistema de Waves (`WaveSystem.server.lua`)**: Gera **5 ondas** de esqueletos, chama o boss na wave 5 e oferece o **botão de reviver** com 50% de vida. Não cria a espada.
4. **Espada do Guerreiro (`SwordSystem.server.lua`)**: Cria a Tool no servidor, sem Script interno. O clique dá dano com cooldown e grava a tag `creator`. O giro sai no servidor a cada 8 segundos, só em inimigos.

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

### Passo 5: Colar o `SwordSystem`
1. Em **ServerScriptService**, clique no **`+`** e adicione outro **Script**.
2. Renomeie para: `SwordSystem`.
3. Apague o texto padrão e cole o código de `src/server/SwordSystem.server.lua`.
4. Não crie um Script dentro da espada. O dano já está neste arquivo.

### Passo 6: Colar o `WaveSystem`
1. Em **ServerScriptService**, clique no **`+`** e adicione outro **Script**.
2. Renomeie para: `WaveSystem`.
3. Apague o texto padrão e cole o código de `src/server/WaveSystem.server.lua`.

---

## 3. Como Jogar e Testar

1. No menu superior do Roblox Studio, clique no botão azul **Play** (ou aperte `F5`).
2. **Equipando a Arma:**
   - O personagem nasce e recebe a **Espada do Guerreiro** na barra de itens (tecla `1`).
   - Equipe a espada e use o **botão esquerdo do mouse** para golpear. Há cooldown de 0,5 s.
   - O **giro** sai sozinho a cada 8 segundos enquanto a espada estiver equipada. Só acerta inimigos.
3. **Sobrevivendo às Waves:**
   - **Wave 1:** 5 Esqueletos.
   - **Wave 2:** 7 Esqueletos (mais rápidos).
   - **Wave 3:** 9 Esqueletos (mais fortes).
   - **Wave 4:** 11 Esqueletos (horda pesada).
   - **Wave 5:** Chefe *Lorde Esqueleto Malakar* com barra de vida gigante na tela.
4. **Ganhando Moedas:**
   - Cada esqueleto comum derrotado dá **5 moedas** para quem tem a tag `creator`.
   - O Boss derrotado dá **100 moedas** só para quem lutou.
   - O saldo aparece no canto superior direito (`Moedas`).
5. **Se você morrer:**
   - Uma janela aparece com o botão **"★ Reviver na Arena (50% HP) ★"**.
   - Ao clicar, o herói ressurge com metade da vida e a espada, se ainda não tiver uma.

---

## 4. Onde Entrará a Monetização Real (Robux)
O botão de reviver no `WaveSystem.server.lua` é o gancho para o Dev Product. A compra com Robux ainda não está ligada: o clique só revive na arena.
