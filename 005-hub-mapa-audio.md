# TASK 005 - Hub, Mapa da Arena 1 e Áudio

## Objetivo
Criar o Hub seguro de spawn, melhorar visualmente a Arena 1, adicionar o sistema de música por local e fechar o fluxo de morte com revive pago e renascimento gratuito com penalidade.

## Arquivos permitidos
- docs/03-hub-mapa-audio.md (novo)
- src/server/MapSystem/HubSystem.lua (novo)
- src/server/MapSystem/ArenaMapSystem.lua (novo)
- src/server/MapSystem/AudioSystem.lua (novo)
- src/server/MapSystem/RunSystem.lua (novo)
- src/server/WaveSystem.server.lua (manutenção autorizada pelo Humano)
- src/server/HUDSystem.server.lua (manutenção autorizada pelo Humano)

## Instruções validadas
1. Criar o Hub como sala fechada e segura, elevada em Y = 100, com chão, paredes, teto, 4 tochas com luz e fumaça, o NPC "Mercador" (só visual) e o portal "Entrar na Arena 1".
2. Levar o jogador ao Hub quando ele nasce, e à Arena 1 quando ele toca o portal.
3. Cria `SpawnArena` dentro de `Workspace/Arena1` para a lógica de respawn, sem alterar o `SpawnLocation` que o WaveSystem já usava.
4. Melhorar o visual da Arena 1: textura de pedra, pilares, 4 tochas de canto com fumaça, sala circular do boss e caixas decorativas.
5. Adicionar o AudioSystem com troca de música entre Hub e Arena conforme a posição do jogador.
6. Menu de morte com dois botões: "Reviver na Arena" (run intacta) e "Voltar ao Hub" (perde as moedas da entrada).
7. O renascimento passa a ser feito pelos botões, com `Players.CharacterAutoLoads = false`.
8. Quem morre fora da arena, onde o menu não abre, volta ao Hub sozinho após alguns segundos.

## Critério de pronto
- [x] Hub criado e o jogador nasce nele, seguro
- [x] Portal leva o jogador para a Arena 1
- [x] Arena 1 com o visual melhorado e as tochas
- [x] AudioSystem troca a música entre Hub e Arena
- [x] Menu de morte com os dois botões
- [x] Reviver na Arena devolve o jogador para o `SpawnArena`, com 50% de vida
- [x] Voltar ao Hub aplica a penalidade das moedas e renasce no Hub
- [x] Reinício da arena volta para a Wave 1 e solta as waves de novo
- [x] Sintaxe validada antes de cada commit
- [x] Nenhum arquivo da TASK 003 ou 004 alterado fora do autorizado
- [ ] PR #7 mergeado na main
- [ ] TASK 005 marcada como CONCLUÍDA

## Não fazer
- Não mudar AGENTS.md, README.md ou tasks/ sem autorização do Humano
- Não refatorar código fora do escopo da task
- Não mudar HP dos inimigos
- Não commitar na main direto

## Como testar
1. Colar os scripts no Studio conforme o docs/03-hub-mapa-audio.md.
2. Entrar no jogo: o jogador nasce no Hub, com as tochas e o Mercador por perto.
3. Atravessar o portal: deve entrar na Arena 1 e a música deve mudar.
4. Matar esqueletos: as moedas da dungeon devem subir no HUD.
5. Morrer na arena: o menu deve abrir depois de 1 segundo.
6. Clicar em "Voltar ao Hub": a penalidade roda, o jogador renasce no Hub, e a arena recomeça na Wave 1.
7. Morrer de novo e clicar em "Reviver na Arena": o jogador deve renascer dentro da arena, com 50% de vida, e a run deve continuar.

## Log de teste
Trecho do log entregue pelo Humano, no fluxo de "Voltar ao Hub":

```
14:24:46.126  [Reviver] O jogador foxycraft203 caiu em combate!
14:24:57.024  [HUDSystem] foxycraft203 perdeu 10 moedas da entrada.
14:24:57.024  [Reviver] foxycraft203 foi para o Hub e perdeu 10 moedas.
14:24:57.025  [WaveSystem] Arena reiniciada na Wave 1.
14:25:09.223  [HubSystem] foxycraft203 entrou na Arena 1.
```

As waves rodando normalmente, em outra sessão de teste:

```
15:29:49.848  [WaveSystem] Iniciando Arena 1: Criptas Esquecidas!
15:29:49.848  [WaveSystem] Wave 1/5 começou.
15:30:45.947  [WaveSystem] Esqueleto derrotado! +5 moedas para foxycraft203
```

## Correções feitas durante a execução
- Bug 1: o menu de morte abria com o jogador já renascido. O `Died` do corpo antigo chegava durante a troca de personagem. Corrigido conferindo se o personagem do `CharacterAdded` ainda é o atual e se o Humanoid dele ainda está morto antes de ligar o menu.
- Bug 2: o `Players.CharacterAutoLoads = false` não valia quando o script do servidor carregava depois do primeiro jogador entrar. O Roblox renascia o jogador sozinho e o menu aparecia sem clique. Corrigido reaplicando o desligamento no `Players.PlayerAdded` e uma vez na carga do script.
- Bug 3: o botão "Voltar ao Hub" faltava no menu. A função reaproveitava qualquer `ReviverGui` que já existisse, sem olhar o que tinha dentro. Corrigido conferindo os dois botões antes de reaproveitar; GUI incompleto é descartado e remontado.
- Bug 4: a arena reiniciava e não soltava mais nenhuma wave. O `_G.ReiniciarArena` fazia `rodando = false` e o loop principal, que era `while rodando do`, encerrava a corrotina para sempre — o `rodando = true` agendado 2 segundos depois não tinha mais quem o lesse. Corrigido com a bandeira `reiniciarAgora`: o reinício limpa os inimigos e o loop principal continua vivo, lendo a bandeira e recomeçando da Wave 1.

## Pendências conhecidas
- Os IDs de áudio `rbxassetid://1836316838` (música) e `rbxassetid://9114642969` (som do dash) são inválidos: o log registra `Asset type does not match requested type`. Precisam ser trocados por IDs reais da Toolbox. O AudioSystem suprime os erros repetidos enquanto isso.
- Os kits da Toolbox planejados para o mapa não foram baixados por falta de acesso.

## Task original
Autorizada pelo Humano ao longo da TASK 005: criar o Hub, melhorar o mapa da Arena 1, adicionar o áudio, e fechar o fluxo de morte com revive pago e renascimento gratuito com penalidade. Inclui manutenção autorizada no WaveSystem e no HUDSystem.
