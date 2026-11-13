# TASK 004 - Novas Classes

## Objetivo
Criar 3 novas classes jogáveis (Mago, Arqueiro e Ladino), cada uma com sua Tool, seguindo o mesmo padrão do SwordSystem do Guerreiro, e uma seleção de classe no spawn.

## O que tem que ter
1. Mago - Cajado Arcano: Bola de Fogo no clique (30 dano, 20 studs, 1.0s) e Nova Arcana passiva (8s, área de 8 studs). Vida 80.
2. Arqueiro - Arco do Caçador: Flecha no clique (22 dano, 30 studs, 0.6s) e Chuva de Flechas passiva (8s). Crítico de 20% = dano dobrado. Vida 90, +10% velocidade.
3. Ladino - Adagas Sombrias: Corte rápido (18 dano, 8 studs, 0.35s) e Dash no Shift (12 studs, 0.5s invulnerável, 6s cooldown). Vida 70, +25% velocidade.
4. Seleção de classe no spawn: Guerreiro / Mago / Arqueiro / Ladino.

## Entrega desta TASK
- src/server/ClassSystems/MageSystem.lua (novo)
- src/server/ClassSystems/ArcherSystem.lua (novo)
- src/server/ClassSystems/RogueSystem.lua (novo)
- src/server/ClassSystems/ClassSelector.lua (novo)
- src/client/DashClient.lua (novo, LocalScript em StarterPlayerScripts)

## Regras IMPORTANTES
- Seguir AGENTS.md à risca
- Código em Lua, comentado em português, simples para iniciante entender
- NÃO usar assets pagos ou copiados da Gameloft. Tudo autoral.
- Branch task/004-novas-classes
- Abrir PR para revisão do Humano
- REGRA DE OURO: não mexer em WaveSystem, BossSystem, CoinSystem, HUDSystem e SwordSystem do Guerreiro. Só reutilizar o padrão deles.
- Não mudar HP dos inimigos

## Critério de pronto
- [x] 4 arquivos de classe criados na pasta ClassSystems
- [x] DashClient como LocalScript em StarterPlayerScripts
- [x] As 3 classes funcionam na Arena 1, contra os mesmos esqueletos e o Boss Malakar
- [x] Moedas e contador da dungeon funcionam igual para todas as classes (via tag creator)
- [x] Seleção de classe no spawn funcionando
- [x] Nenhuma arma duplicada no respawn
- [x] Nenhum arquivo da TASK 003 alterado
- [x] Sintaxe validada antes de cada commit
- [x] PR #5 mergeado na main
- [x] TASK 004 CONCLUÍDA

## Não fazer
- Não refatorar código fora do escopo da task
- Não mexer nos 5 scripts da TASK 003
- Não commitar na main direto

## Correções feitas durante a execução
- Bug 1: espada do Guerreiro voltava no respawn junto da arma da classe. Corrigido com `SetAttribute("ClasseEscolhida")` e uma vigia que remove armas de classe erradas da mochila e do corpo, em vários instantes após o respawn.
- Bug 2: dash do Ladino não funcionava. Corrigido movendo o dash para o servidor, com RemoteEvent "DashLadino" e o DashClient lendo o Shift no cliente.
- Bug 3: dash sem avanço. Corrigido zerando o WalkSpeed durante o dash e movendo o CFrame em passos, em vez de confiar em AssemblyLinearVelocity.
- Mudança: Mago e Arqueiro passaram a usar auto-mira, procurando o inimigo mais próximo num raio de 30 studs.
