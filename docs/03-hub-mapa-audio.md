# Tutorial: Hub, Mapa e Áudio (Arena 1)

Este guia cobre as três coisas novas da **TASK 005**: o Hub de spawn, o mapa da Arena 1 e o áudio. Ele continua o tutorial principal (`02-arena-1-criptas.md`), que explica os 5 scripts da arena e as 4 classes.

---

## 1. O que foi criado

### Scripts novos (TASK 005)
Todos vão numa pasta **`MapSystem`** dentro do `ServerScriptService`:

1. **HubSystem**: Cria a sala inicial segura (`Workspace/Hub`), com chão, paredes, teto, 4 tochas com luz quente, o NPC "Mercador" e o portal "Entrar na Arena 1". Também leva o jogador para o Hub quando ele nasce ou morre.
2. **ArenaMapSystem**: Constrói o visual da dungeon da Arena 1 — chão de pedra, paredes, 4 pilares com tochas, arena circular para o Boss e 2 caixas decorativas.
3. **AudioSystem**: Toca `MusicaHub` no Hub e `MusicaArena` na arena, em loop. Também liga os sons de hit e de morte dos inimigos.

### O que já existia e NÃO foi alterado
Nenhum destes arquivos foi tocado: `WaveSystem`, `BossSystem`, `CoinSystem`, `HUDSystem`, `SwordSystem`, `MageSystem`, `ArcherSystem`, `RogueSystem` e `ClassSelector`. A lógica da arena e das classes é exatamente a mesma de antes.

---

## 2. Como montar no Roblox Studio

### Passo 1: Criar a pasta `MapSystem`
1. No **Explorer**, clique com o botão direito sobre **ServerScriptService** → **Insert Object** → **Folder**.
2. Renomeie para: `MapSystem`.

### Passo 2: Colar os três scripts
Dentro da pasta `MapSystem`, crie **3 Scripts** (não LocalScript):

1. **`HubSystem`** — cole o código de `src/server/MapSystem/HubSystem.lua`.
2. **`ArenaMapSystem`** — cole o código de `src/server/MapSystem/ArenaMapSystem.lua`.
3. **`AudioSystem`** — cole o código de `src/server/MapSystem/AudioSystem.lua`.

### Passo 3: Dar Play
Não precisa montar o mapa na mão. Os scripts constroem tudo sozinhos quando o jogo roda.

> **Atenção a um detalhe:** o mapa é criado **em tempo de execução**, então ele só existe enquanto o Play está rodando. Se você quiser o mapa salvo no lugar (para editar na mão depois), dá para copiar os objetos criados durante o Play e colar no Workspace fora do Play. O jeito mais simples: dê Play, selecione a pasta `Hub` no Explorer, copie, pare o Play e cole no Workspace.

---

## 3. Como funciona o Hub

**Onde ele fica:** em `Workspace/Hub`, numa altura de **Y = 100**, bem acima da arena. Isso é de propósito — o Hub e a Arena não se misturam, e o jogador nunca cai de um para o outro.

**O que tem dentro:**
- Sala de 90×24×90 studs, com chão, teto e 4 paredes.
- 4 tochas nos cantos, cada uma com `PointLight` de luz quente (laranja) e `ParticleEmitter` de fumaça.
- Um `SpawnLocation` chamado **`SpawnHub`** — é onde o jogador nasce.
- O NPC **"Mercador"**, só visual, com uma etiqueta dizendo "(loja em breve)".
- O **PortalArena1**, uma Part brilhante com o texto "Entrar na Arena 1".

**Como o jogador entra na arena:** encostando no portal. Ele teleporta para `Workspace/Arena1/SpawnArena`.

**Quando o jogador morre:** ele volta para o Hub, não para a arena. Quem faz isso é o `CharacterAdded` do `HubSystem`, que roda a cada respawn.

**O menu de classes continua funcionando:** o `ClassSelector` já cria o menu sozinho em cada spawn, e o `HubSystem` não interfere nele.

---

## 4. Como funciona o mapa da Arena 1

**O que o `ArenaMapSystem` cria:**
- Chão de pedra prata (`Cobblestone`).
- 4 paredes externas de pedra escura.
- **Arena circular** no centro, onde o Boss Malakar luta.
- **4 pilares** ao redor da arena circular, cada um com uma tocha no topo.
- 4 tochas nos cantos da sala, com luz e fumaça.
- **2 caixas decorativas**, com `CanCollide = false`.

### Por que as caixas não atrapalham os inimigos
Elas têm **`CanCollide = false`**, ou seja, os esqueletos e o boss atravessam. A IA de perseguição do `WaveSystem` não é afetada.

### O ponto mais importante: a lógica da arena não mudou
O `WaveSystem` procura um `SpawnLocation` no Workspace e espalha os esqueletos em volta dele. O `ArenaMapSystem` **não move nem altera** esse SpawnLocation:

- Se já existe um `SpawnLocation` na Arena, ele fica intocado.
- Se não existe, o `ArenaMapSystem` cria um chamado **`SpawnArena`** — que é exatamente o nome que o `HubSystem` procura para o portal, e o mesmo que o `WaveSystem` encontra sozinho.

Resultado: as waves continuam nascendo nos mesmos lugares, e a arena continua dando **260 moedas** com qualquer uma das 4 classes (32 esqueletos × 5 moedas + 100 do boss).

---

## 5. Músicas e sons

### Como trocar a música
Abra o **`AudioSystem`** e mude os IDs no topo do arquivo:

```lua
local ID_MUSICA_HUB = "rbxassetid://1837879082" -- calma, ambiente
local ID_MUSICA_ARENA = "rbxassetid://1836316838" -- tensa, batalha
local ID_SOM_HIT = "rbxassetid://9114642969" -- impacto curto
local ID_SOM_MORTE = "rbxassetid://9114642969" -- queda
```

Para usar outra música, troque só o número depois de `rbxassetid://`. O ID você pega na página do áudio na Toolbox — o número aparece na URL.

Você também pode trocar as músicas **sem mexer no código**: durante o Play, os dois `Sound` ficam em `SoundService`, com os nomes `MusicaHub` e `MusicaArena`. Edite o `SoundId` deles no Explorer.

### Como o jogo decide qual música tocar
Pela **altura (Y) do personagem**. O Hub fica em Y = 100, então:

- Personagem acima de Y = 60 → está no Hub → toca `MusicaHub`.
- Abaixo disso → está na arena → toca `MusicaArena`.

O script confere isso a cada 1 segundo. Se você mover o Hub para outra altura, ajuste a constante `ALTURA_HUB` no `AudioSystem` para ficar entre as duas alturas.

### IDs de assets usados

| Asset | ID | Onde é usado |
|---|---|---|
| Música do Hub | `rbxassetid://1837879082` | `AudioSystem`, `MusicaHub` |
| Música da Arena | `rbxassetid://1836316838` | `AudioSystem`, `MusicaArena` |
| Som de hit | `rbxassetid://9114642969` | `AudioSystem`, golpes |
| Som de morte | `rbxassetid://9114642969` | `AudioSystem`, esqueletos |
| Textura de fumaça | `rbxasset://textures/particles/smoke_main.dds` | Tochas (Hub e Arena) |

> **Sobre os sons de hit e morte:** os dois usam o mesmo ID por padrão, mudando só a velocidade de reprodução (o de morte é mais grave e lento). Se você arrumar dois sons diferentes, é só trocar um dos IDs.

---

## 6. Como adicionar um novo mapa

O jeito mais simples é **copiar o `ArenaMapSystem`** e adaptar:

1. Duplique o script e renomeie (por exemplo, `ArenaMapSystem2`).
2. No topo, mude o nome da pasta e o centro:

```lua
local NOME_ARENA = "Arena2"
local CENTRO_ARENA = Vector3.new(0, 0, 400) -- bem longe da Arena 1
```

3. Ajuste as medidas (`RAIO_ARENA`, `ALTURA_PAREDE`) e mude as cores e materiais se quiser.
4. Crie um portal novo no Hub apontando para o `SpawnArena` da nova arena. No `HubSystem`, copie o trecho do `PortalArena1` e mude o destino.
5. Se quiser música própria, adicione um `Sound` novo no `AudioSystem` e uma checagem a mais de altura ou posição.

**Dica:** mantenha cada arena em uma coordenada bem distante das outras (400 studs de distância, por exemplo). Assim nada se sobrepõe e a checagem de altura do áudio continua simples.

---

## 7. Se alguma coisa não funcionar

| Sintoma | Causa provável | O que fazer |
|---|---|---|
| O jogador nasce na arena, não no Hub | O `HubSystem` não rodou | Confira se ele está na pasta `MapSystem` do `ServerScriptService` |
| O portal não teleporta | Não existe `SpawnArena` na Arena 1 | Aparece um aviso amarelo no Output; dê Play uma vez com o `ArenaMapSystem` ativo |
| Duas músicas ao mesmo tempo | Um `Sound` antigo ficou no `SoundService` | Apague o `MusicaHub` ou `MusicaArena` duplicado no Explorer |
| O mapa some quando paro o Play | É esperado | O mapa é criado em execução; copie e cole no Workspace se quiser salvar |
| Os esqueletos nascem longe | O SpawnLocation mudou de lugar | O `ArenaMapSystem` só cria um se não existir; confira se você não moveu o original |
| As caixas travam o jogador | `CanCollide` foi mexido | As crates devem ficar com `CanCollide = false` |
