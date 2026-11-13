# Tutorial Passo a Passo: Arena 1 - Criptas Esquecidas (Roblox Studio)

Este guia explica, em linguagem simples e prática, como colocar os scripts da **Arena 1 (Criptas Esquecidas)** e das **4 classes jogáveis** para rodar no **Roblox Studio**.

> **Importante:** são **5 scripts** no `ServerScriptService`, **4 scripts** dentro de uma pasta chamada `ClassSystems` e **1 LocalScript** no `StarterPlayerScripts`. O LocalScript é o do Ladino, e é o passo que mais gente esquece — sem ele, o dash não funciona.

---

## 1. O que foi criado

### Scripts da arena (TASK 003)
1. **CoinSystem**: Cria a `leaderstats` "Moedas" de cada jogador e credita as moedas. A tabela do Roblox mostra o saldo na tela.
2. **BossSystem**: Cria o Boss *Lorde Esqueleto Malakar* na Wave 5, com 3 ataques especiais (Golpe Sísmico, Invocação de Servos e Carga Brutal). As 100 moedas vão só para quem lutou.
3. **WaveSystem**: Gera as 5 waves de esqueletos, oferece o botão de reviver com 50% de vida e chama o boss na Wave 5.
4. **SwordSystem**: Cria a **Espada do Guerreiro** e cuida do dano dela. Entrega a espada sozinho quando o jogador nasce.
5. **HUDSystem**: Mostra o `+X moedas` subindo no centro da tela e o contador **"Moedas na Dungeon"** no canto. Só exibe: quem credita é o CoinSystem.

### Classes (TASK 004)
6. **ClassSelector**: Menu no spawn com os 4 botões de classe. Aplica a vida e a velocidade da classe e entrega a arma certa. Também vigia a mochila para o jogador nunca ficar com duas armas.
7. **MageSystem**: **Cajado Arcano**. Clique lança Bola de Fogo com **mira automática** (pega o inimigo mais próximo num raio de 30 studs). Habilidade passiva: Nova Arcana, dano em área a cada 8 s.
8. **ArcherSystem**: **Arco do Caçador**. Clique atira uma Flecha com mira automática. Tem **20% de chance de crítico**, que dobra o dano. Passiva: Chuva de Flechas em área a cada 8 s.
9. **RogueSystem**: **Adagas Sombrias**. Clique dá um corte rápido, o mais veloz do jogo. Passiva: **Dash no Shift**, avançando 12 studs com 0,5 s de invulnerabilidade.
10. **DashClient** (LocalScript): Lê o Shift e avisa o servidor sobre o dash. Vai no `StarterPlayerScripts`, **não** no `ServerScriptService`.

### Resumo das classes

| Classe | Arma | Vida | Velocidade | Clique | Passiva |
|---|---|---|---|---|---|
| Guerreiro | Espada do Guerreiro | 100 (padrão) | 16 (padrão) | 25 de dano, 10 studs, 0,8 s | Giro em área a cada 8 s |
| Mago | Cajado Arcano | 80 | 16 (padrão) | 30 de dano, alcance 30, 1,0 s | Nova Arcana, área de 8 studs |
| Arqueiro | Arco do Caçador | 90 | 17,6 (+10%) | 22 de dano, alcance 30, 0,6 s, 20% crítico | Chuva de Flechas, área de 12 studs |
| Ladino | Adagas Sombrias | 70 | 20 (+25%) | 18 de dano, 8 studs, 0,35 s | Dash no Shift, 12 studs, 0,5 s invulnerável |

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
1. Em **ServerScriptService**, clique no **`+`** e adicione outro **Script**.
2. Renomeie para: `WaveSystem`.
3. Apague o texto padrão e cole o código de `src/server/WaveSystem.server.lua`.

### Passo 6: Colar o `SwordSystem`
1. Em **ServerScriptService**, clique no **`+`** e adicione outro **Script**.
2. Renomeie para: `SwordSystem`.
3. Apague o texto padrão e cole o código de `src/server/SwordSystem.server.lua`.
4. **Não crie um Script dentro da espada.** O dano já está neste arquivo.

### Passo 7: Colar o `HUDSystem`
1. Em **ServerScriptService**, clique no **`+`** e adicione outro **Script**.
2. Renomeie para: `HUDSystem`.
3. Apague o texto padrão e cole o código de `src/server/HUDSystem.server.lua`.

Neste ponto o `ServerScriptService` deve ter **5 scripts**: `CoinSystem`, `BossSystem`, `WaveSystem`, `SwordSystem` e `HUDSystem`.

### Passo 8: Criar a pasta `ClassSystems`
1. Passe o mouse sobre **ServerScriptService**, clique no **`+`** e escolha **Folder**.
2. Renomeie a pasta para: `ClassSystems`.
3. Todos os quatro scripts das classes entram **dentro dessa pasta**.

### Passo 9: Colar os scripts das classes
Dentro da pasta `ClassSystems`, crie **4 Scripts** (não LocalScript), um de cada vez:

1. **`ClassSelector`** — cole o código de `src/server/ClassSystems/ClassSelector.lua`.
2. **`MageSystem`** — cole o código de `src/server/ClassSystems/MageSystem.lua`.
3. **`ArcherSystem`** — cole o código de `src/server/ClassSystems/ArcherSystem.lua`.
4. **`RogueSystem`** — cole o código de `src/server/ClassSystems/RogueSystem.lua`.

A ordem em que você cria não importa. O `ClassSelector` procura cada classe na hora do clique, então não tem ordem de carregamento para se preocupar.

### Passo 10: Colar o `DashClient` (ESTE É O PASSO DIFÍCIL)
O `DashClient` lê o Shift do teclado, e **teclado só existe no cliente**. Se ele ficar no `ServerScriptService`, ele roda no servidor e o Shift não é detectado — o dash simplesmente não acontece, sem mensagem de erro.

1. No **Explorer**, procure a pasta **`StarterPlayer`** (fica perto do fim da lista).
2. Expanda ela e localize **`StarterPlayerScripts`**.
3. Clique com o botão direito sobre `StarterPlayerScripts` → **Insert Object** → **`LocalScript`**.
   - Tem que ser **LocalScript**. Se você escolher "Script", não funciona.
4. Renomeie para: `DashClient`.
5. Apague o texto padrão e cole o código de `src/client/DashClient.lua`.

> **Como saber se deu certo:** ao dar Play, aparece um `RemoteEvent` chamado **`DashLadino`** dentro da pasta `ReplicatedStorage`. Se ele não estiver lá, o `RogueSystem` não rodou — confira se ele está em `ClassSystems` no `ServerScriptService`.

---

## 3. Estrutura final no Explorer

```
ServerScriptService
├── ClassSystems (Folder)
│   ├── ClassSelector
│   ├── MageSystem
│   ├── ArcherSystem
│   └── RogueSystem
├── BossSystem
├── CoinSystem
├── HUDSystem
├── WaveSystem
└── SwordSystem

StarterPlayer
└── StarterPlayerScripts
    └── DashClient   (LocalScript)

ReplicatedStorage
└── DashLadino   (RemoteEvent, criado sozinho ao dar Play)
```

---

## 4. Como Jogar e Testar

1. No menu superior do Roblox Studio, clique no botão azul **Play** (ou aperte `F5`).
2. **Escolhendo a classe:**
   - Uma janela com 4 botões aparece na tela: **Guerreiro, Mago, Arqueiro e Ladino**.
   - Ao clicar, você recebe a arma da classe na barra de itens (tecla `1`).
   - Pode trocar de classe a qualquer momento clicando de novo. A arma antiga é removida antes da nova chegar, então **nunca fica com duas armas**.
   - Se você morrer e renascer, volta com a **mesma classe** que escolheu, sem precisar escolher de novo.

3. **Usando cada classe:**
   - **Guerreiro:** equipe a espada e clique para golpear. O giro em área sai sozinho a cada 8 segundos.
   - **Mago:** clique e a Bola de Fogo voa até o inimigo mais próximo. Se não tiver ninguém por perto, sai reto na direção da sua mira.
   - **Arqueiro:** igual ao Mago, com flecha. De vez em quando o dano dobra — é o crítico de 20%.
   - **Ladino:** clique para cortar (bem rápido). **Aperte Shift** para o dash: você avança 12 studs deixando um rastro escuro, e fica sem tomar dano por 0,5 s. O dash tem 6 segundos de espera — apertar Shift duas vezes seguidas, o segundo não sai.

4. **Sobrevivendo às Waves:**
   - **Wave 1:** 5 Esqueletos.
   - **Wave 2:** 7 Esqueletos (mais rápidos).
   - **Wave 3:** 9 Esqueletos (mais fortes).
   - **Wave 4:** 11 Esqueletos (horda pesada).
   - **Wave 5:** Chefe *Lorde Esqueleto Malakar* com barra de vida gigante na tela.

5. **Ganhando Moedas:**
   - Cada esqueleto derrotado dá **5 moedas** para quem deu o golpe final.
   - O Boss derrotado dá **100 moedas** para quem lutou contra ele.
   - O saldo total aparece no canto superior direito (`Moedas`) e continua somando entre as partidas.
   - O contador **"Moedas na Dungeon"** no canto superior esquerdo mostra só o que você ganhou nesta run, e zera quando a arena reinicia.
   - Qualquer classe ganha moeda igual — o sistema é o mesmo para todas.

6. **Se você morrer:**
   - Uma janela aparece com o botão **"★ Reviver na Arena (50% HP) ★"**.
   - Ao clicar, seu herói ressurge com metade da vida e com a arma da sua classe.

---

## 5. Se alguma coisa não funcionar

| Sintoma | Causa provável | O que fazer |
|---|---|---|
| Nasci com **duas armas** | O `ClassSelector` está desatualizado | Confira se ele tem a função `removerArmasErradas` (use Ctrl+F no script) |
| O **dash não faz nada** | O `DashClient` está no lugar errado | Ele precisa ser **LocalScript** em `StarterPlayerScripts` |
| O dash **não avança** | O `RogueSystem` está desatualizado | Confira se ele tem `PASSOS_DASH` e `WalkSpeed = 0` (Ctrl+F no script) |
| **Nenhuma arma** na mochila | A classe ainda não carregou | Veja no Output se aparece `[ClassSelector] A classe ... ainda não carregou` |
| Os esqueletos **não nascem** | Falta um `SpawnLocation` no mapa | Aparece um aviso amarelo no Output e eles nascem em `(0, 5, 0)` |
| Aparece o aviso do **Assistant plugin** | Plugin do Studio | Ignore, não tem relação com o projeto |

---

## 6. Onde Entrará a Monetização Real (Robux)
O botão de reviver no `WaveSystem.server.lua` é o gancho para o Dev Product. A compra com Robux ainda **não está ligada** — hoje o clique só revive na arena. Para ativar, é ali que se conecta o `MarketplaceService:PromptProductPurchase` com o ID do produto.
