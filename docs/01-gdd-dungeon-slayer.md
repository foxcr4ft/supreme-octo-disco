# Game Design Document (GDD)
# Dungeon Slayer: Reborn

> **Projeto:** Dungeon Slayer: Reborn  
> **Gênero:** Action RPG / Hack and Slash / Co-op Arena Dungeon Crawler  
> **Plataforma:** Roblox (PC, Mobile, Console)  
> **Modelo:** Free-to-Play com foco em Monetização Estratégica  
> **Status:** Conceito Inicial / GDD da TASK 002  

---

## 1. Visão Geral e Conceito

### 1.1 Premissa
**Dungeon Slayer: Reborn** é um RPG de ação cooperativo em arena fechada construído na plataforma Roblox. Inspirado na jogabilidade clássica e viciante de combate em arenas por ondas (waves) de jogos estilo *Dungeon Hunter 3*, o projeto é **100% autoral**, utilizando narrativas, personagens, design de níveis, balanceamento e assets originais desenvolvidos especificamente para o ecossistema Roblox.

### 1.2 Pilares do Jogo
1. **Combate Dinâmico e Reativo:** Ação rápida e responsiva com ataques básicos fluidos, habilidades de classe com tempo de recarga e esquiva tática (dash/roll).
2. **Cooperação Tática (1 a 4 Jogadores):** Sinergia entre arquétipos de classes complementares enfrentando hordas e chefes desafiadores com escalonamento automático de dificuldade.
3. **Loop de Progressão Viciante:** Recompensas imediatas ao final de cada arena (XP, Ouro e fragmentos) que alimentam melhorias tangíveis de equipamento e árvores de atributos no Lobby.
4. **Monetização de Alto Impacto:** Estruturada nativamente no ciclo de gameplay com produtos consumíveis de alta demanda (Reviver, Moedas) e Passes Permanentes atrativos (Classes exclusivas, 2x XP).

---

## 2. Gameplay Core & Loop Principal

### 2.1 O Core Loop
- **Lobby / Hub:** Ponto de encontro, seleção de classe, forja e compra de aprimoramentos.
- **Seleção de Arena:** Escolha do mapa temático e nível de dificuldade.
- **Combate em Arena Fechada (Waves):** Sobrevivência contra hordas sucessivas de inimigos.
- **Batalha contra o Boss:** Confronto tático com mecânicas e ataques em área (AoE).
- **Recompensas e Extração:** Coleta de XP, Ouro e materiais para evolução.

### 2.2 Dinâmica das Arenas
- **Ambiente:** Arenas tridimensionais fechadas com obstáculos físicos, colunas destrutíveis e perigos ambientais interativos (chapas de espinhos, poças de lava).
- **Estrutura de Ondas:**
  - **Ondas 1 a 4:** Tropas de linha de frente (melee), suporte à distância (arqueiros/magos) e enxames ágeis.
  - **Onda 5 (Clímax):** Boss com barra de vida dedicada, padrões de ataque telegrafados e mecânica de invocação de lacaios.
- **Condição de Vitória:** Eliminar todos os inimigos da última onda mantendo ao menos um jogador vivo.
- **Condição de Derrota:** Morte de todos os membros do esquadrão sem uso de item ou Dev Product de ressurreição.

---

## 3. Classes de Personagens

O jogo conta com 4 classes balanceadas gratuitas e 1 classe premium desbloqueável via Gamepass.

### 3.1 Guerreiro (Warrior) - Tanque / Dano Melee
- **Arma Principal:** Espada Longa e Escudo ou Machado de Duas Mãos.
- **Atributos Principais:** Alta Vida e Defesa Física; mobilidade moderada.
- **Habilidades:**
  1. *Investida Fulminante:* Avança em linha reta empurrando inimigos e atordoando o alvo final.
  2. *Torvelinho de Aço (Whirlwind):* Gira desferindo múltiplos golpes em 360° com dano crescente.
  3. *Postura Inabalável:* Buff temporário que reduz o dano recebido em 40% e atrai o foco dos inimigos próximos (Taunt).

### 3.2 Mago (Mage) - Controle de Grupo / Dano em Área (AoE)
- **Arma Principal:** Cajado Arcano.
- **Atributos Principais:** Alto dano mágico à distância; baixa vida e armadura física.
- **Habilidades:**
  1. *Esfera de Fogo Concentrada:* Lança um projétil explosivo que queima inimigos em raio de impacto.
  2. *Nevasca Glacial:* Invoca uma tempestade de gelo em área, causando dano contínuo e desacelerando (Slow/Freeze) inimigos.
  3. *Salto Dimensional:* Teletransporta uma curta distância na direção do movimento, deixando uma onda de choque que repele perseguidores.

### 3.3 Ladino (Rogue) - Assassino Ágil / Dano Crítico
- **Arma Principal:** Adagas Duplas.
- **Atributos Principais:** Altíssima velocidade de ataque e taxa de dano crítico; vida baixa.
- **Habilidades:**
  1. *Dança das Sombras:* Sequência ultrarrápida de cortes contra alvos únicos com 100% de chance de crítico.
  2. *Lâminas Tóxicas:* Impregna suas armas com veneno que causa dano ao longo do tempo (DoT) e reduz a velocidade de ataque dos inimigos.
  3. *Passo Espectral:* Esquiva rápida que confere 1.5s de invulnerabilidade e reposiciona o personagem nas costas do inimigo mais próximo.

### 3.4 Arqueiro (Archer) - Dano Sustentado à Distância
- **Arma Principal:** Arco Composto ou Besta de Repetição.
- **Atributos Principais:** Alcance longo, precisão e mobilidade tática constante.
- **Habilidades:**
  1. *Chuva de Flechas:* Dispara uma salva aos céus que atinge uma área delimitada no solo repetidamente.
  2. *Tiro Penetrante:* Dispara uma flecha pesada de alta perfuração que atravessa múltiplos inimigos em fila indiana com efeito de recuo (Knockback).
  3. *Abrolhos / Armadilha:* Lança armadilhas de espinhos no chão que imobilizam os primeiros inimigos que as pisarem.

---

## 4. Monetização Estratégica (Roblox)

A monetização é desenhada para converter tanto microtransações espontâneas durante sessões tensas de arena quanto investimentos definitivos de jogadores engajados, respeitando as boas práticas da plataforma Roblox.

### 4.1 Gamepasses (Compras Únicas / Permanentes)

| Nome do Gamepass | Tipo | Descrição e Benefício | Faixa Sugerida (Robux) |
| :--- | :--- | :--- | :--- |
| **Classe Premium: Cavaleiro Sombrio** | Classe Exclusiva | Desbloqueia o *Cavaleiro Sombrio (Dark Knight)*, classe empunhando foice espectral com mecânicas únicas de Vampirismo (Life Steal passivo) e explosão sombria. | 450 - 600 R$ |
| **Passe 2x XP Permanente** | Booster Vitalício | Dobra permanentemente o ganho de experiência em todas as arenas, acelerando a subida de nível de qualquer classe. | 350 - 450 R$ |
| **Inventário Expandido VIP** | Conveniência | Aumenta o espaço de armazenamento de equipamentos e materiais em +50 slots e concede tag dourada no chat do Lobby. | 150 - 200 R$ |

### 4.2 Developer Products (Produtos Consumíveis / Repetíveis)

| Produto | Função no Jogo | Descrição | Faixa Sugerida (Robux) |
| :--- | :--- | :--- | :--- |
| **Reviver Imediato (Ressurreição)** | Salvamento de Partida | Usável quando o jogador é derrotado dentro de uma arena. Restaura o personagem imediatamente com 50% de HP e 2 segundos de escudo de invencibilidade, permitindo continuar a wave sem falhar a run da equipe. | 25 - 40 R$ |
| **Pacote 100 Moedas** | Economia Básica | Fornece 100 moedas de ouro imediatas para pequenos aprimoramentos de equipamentos iniciais. | 30 R$ |
| **Pacote 500 Moedas** | Custo-Benefício Intermediário | Fornece 500 moedas de ouro para forjar equipamentos raros e acelerar o nível de classe. | 120 R$ |
| **Pacote 1500 Moedas** | Grande Investimento | Pacote volumoso com bônus de ouro, voltado a upgrades de itens de alta raridade (Épicos/Lendários). | 300 R$ |

---

## 5. Progressão e Economia Interna

### 5.1 Moedas e Recursos
- **Ouro (Gold):** Moeda padrão obtida derrotando inimigos e completando arenas. Utilizada para comprar poções básicas, forjar armaduras e aumentar o nível de refino das armas.
- **Fragmentos de Essência:** Materiais dropados exclusivamente por chefes de arena, requeridos em conjunto com Ouro para forjar armas de nível avançado.

### 5.2 Sistema de Forja e Aprimoramento
- Cada arma e peça de armadura possui níveis de aprimoramento de +1 a +10.
- A cada nível de aprimoramento, os atributos de Dano Base, Defesa ou Vida aumentam percentualmente.

---

## 6. Plano de Arenas e Fases (Level Design)

### 6.1 Fase 1: Criptas Esquecidas (Dificuldade: Normal)
- **Tema Visual:** Cripta gótica medieval subterrânea, tochas bruxuleantes e sarcófagos de pedra.
- **Inimigos Comuns:** Esqueletos Guerreiros, Arqueiros Decrépitos e Carniçais Famintos.
- **Chefe da Fase:** *Lorde Esqueleto Malakar* (Ataques pesados em arco com espada colossal e invocação de servos esqueléticos).

### 6.2 Fase 2: Forja Vulcânica (Dificuldade: Difícil)
- **Tema Visual:** Cavernas escuras cortadas por rios de lava e plataformas rochosas estreitas com pontes de ferro.
- **Inimigos Comuns:** Goblins Piromantes, Cães de Lava e Golens Rochosos.
- **Chefe da Fase:** *Magmatron, o Destruidor* (Padrões de solo com jatos de fogo e terremoto em área que exige esquiva precisa).

### 6.3 Fase 3: Santuário Corrompido (Dificuldade: Pesadelo)
- **Tema Visual:** Ruínas de um templo ancestral invadido por vegetação e névoa abissal.
- **Inimigos Comuns:** Espectros das Trevas, Cultistas Arcanos e Gárgulas Aladas.
- **Chefe da Fase:** *Arquidemonio Vaelok* (Combate em múltiplas fases, alternando entre ataques de projéteis teleguiados e rajadas de energia negra).

---

## 7. Arquitetura Técnica Recomendada no Roblox Studio

- **ServerScriptService:**
  - `CombatManager`: Validação de hitboxes, cálculo de dano com mitigação e controle de cooldowns server-side para prevenção de exploits.
  - `WaveSpawner`: Gerenciamento do ciclo de vida das ondas de inimigos e estado da arena.
  - `MarketplaceHandler`: Processamento seguro de `ProcessReceipt` para Developer Products e verificação de propriedade de Gamepasses via `MarketplaceService:UserOwnsGamePassAsync`.
- **ReplicatedStorage:**
  - `NetworkRemotes`: Pastas com `RemoteEvents` e `RemoteFunctions` para sincronização de animações, efeitos visuais (VFX/SFX) e requisições de interface.
- **StarterPlayerScripts:**
  - `InputController`: Mapeamento de teclas (M1 para ataque, Teclas 1/2/3 para habilidades, Barra de Espaço ou Q para esquiva) com suporte nativo a Mobile (touch buttons) e Gamepad.
