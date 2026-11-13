# TASK 003 - Primeira Arena Jogável (Criptas Esquecidas)

## Objetivo
Criar os scripts jogáveis da Arena 1 - Criptas Esquecidas, para colar no Roblox Studio e jogar.

## O que tem que ter
1. Sistema de Waves: 5 waves de esqueletos, cada wave mais difícil
2. Sistema de Boss: Boss no final da Wave 5, com 3 ataques
3. Sistema de Classe: Guerreiro jogável (espada + skill de giro)
4. Sistema de Moedas: Ganha moeda ao matar inimigo, mostra na tela
5. Sistema de Reviver: Morreu, pode reviver (lugar para o Dev Product depois)

## Entrega desta TASK
EXPANDIR A ENTREGA (autorizado na TASK 004): a entrega passa a incluir os 5 scripts do servidor
- docs/02-arena-1-criptas.md (passo a passo de como colar no Studio, em linguagem simples)
- src/server/WaveSystem.server.lua
- src/server/BossSystem.server.lua
- src/server/CoinSystem.server.lua
- src/server/SwordSystem.server.lua (novo, a espada separada)
- src/server/HUDSystem.server.lua (novo, contador e aviso de moedas)

## Regras IMPORTANTES
- Seguir AGENTS.md à risca
- Código em Lua, comentado em português, simples para iniciante entender
- NÃO usar assets pagos ou copiados da Gameloft. Tudo autoral.
- Criar branch task/003-primeira-arena-jogavel
- Abrir PR para revisão do Humano
- NÃO mexer em AGENTS.md, README.md ou tasks/

## Finalização (TASK 003)
- [x] 5 scripts do servidor funcionando juntos, sem erro no Output
- [x] Prints de debug limpos: só início de wave, esqueleto derrotado, boss derrotado, moedas recebidas e arena concluída
- [x] Nenhum --[[ aberto, nenhum end faltando, nenhum arquivo duplicado
- [x] Balanceamento: Waves 1-4 = 5/7/9/11 esqueletos, Boss = 100 moedas, total da run = 260 moedas
- [ ] Merge do PR #4 na main
- [ ] TASK 003 marcada como CONCLUÍDA

## Task original
EXPANDIR A ENTREGA (autorizado na TASK 004): a entrega passa a incluir os 5 scripts do servidor

