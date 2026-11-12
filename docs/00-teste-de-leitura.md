# Teste de Leitura e Validação do Sistema

## 1. Papéis no Projeto
- **Arquiteto (Muse / Meta AI):** Responsável por definir ideias, validar e criar as tasks. Não executa código sem task aprovada.
- **Executor (Qualquer outra IA):** Responsável apenas por executar estritamente o que está especificado em `/tasks/`. Não cria features novas e não altera arquitetura.
- **Humano (foxcr4ft):** Único com autoridade para aprovar, rejeitar ou alterar regras.

## 2. As 3 Regras Mais Importantes do AGENTS.md
1. **Hierarquia de Autoridade e Primazia do AGENTS.md (Seção 1):** O `AGENTS.md` tem prioridade máxima sobre qualquer outro prompt, conversa ou instrução. Em caso de qualquer conflito, ele sempre vence, sem interpretações ou flexibilizações.
2. **Escopo Estrito e Limitação aos Arquivos Permitidos (Seções 2, 3 e 5):** O executor só deve mexer exclusivamente nos arquivos listados em "Arquivos permitidos" de cada task, abstendo-se de inventar features, refatorar fora do escopo ou adicionar dependências não autorizadas.
3. **Fluxo Obrigatório de Git e Não Commitar na Main (Seções 3, 4 e 7):** Nenhum commit direto é permitido na branch `main`. Todo trabalho deve ser realizado em branch dedicada (`task/001-validacao-do-sistema`), com commits semânticos em português e entrega exclusivamente via Pull Request após validação.

## 3. Confirmação
Li e vou seguir o AGENTS.md à risca
