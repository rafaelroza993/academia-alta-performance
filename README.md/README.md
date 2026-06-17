# Sistema de Gestão — Academia de Alta Performance

Modelagem e implementação em PostgreSQL de um sistema de gestão para academia, cobrindo alunos, planos de assinatura, modalidades de treino, controle de frequência (check-in) e histórico de pagamentos.

Projetado e testado em PostgreSQL com DBeaver como interface gráfica.

## Modelo de dados

```
modalidades ───┐
                ├──< matriculas >── alunos
planos ────────┘        │
                         ├──< pagamentos
                         └──< checkins
```

- **alunos**: dados cadastrais.
- **planos**: catálogo de mensalidades (mensal, trimestral, semestral, anual) com duração e valor.
- **modalidades**: musculação, crossfit, natação, funcional, pilates etc.
- **matriculas**: liga um aluno a um plano e uma modalidade, com `status` (`ativo`, `inativo`, `suspenso`, `cancelado`). É essa tabela que decide se o check-in pode acontecer.
- **pagamentos**: histórico financeiro de cada matrícula (vencimento, data de pagamento, status).
- **checkins**: registro de frequência, vinculado a uma matrícula específica.

## Regras de negócio implementadas

- **ENUMs no banco** (`status_matricula`, `status_pagamento`, `tipo_plano`) em vez de strings livres, evitando inconsistência de dados na origem.
- **Trigger `trg_valida_checkin`**: impede a inserção de um check-in se a matrícula não estiver com status `ativo` ou já tiver passado da `data_fim`. A regra fica garantida no banco, não depende da aplicação se lembrar de validar.
- **Constraint de consistência em pagamentos**: um pagamento só pode estar como `pago` se tiver `data_pagamento` preenchida.
- **Inadimplência calculada dinamicamente** (não armazenada): a view `vw_alunos_inadimplentes` compara `data_vencimento` com `CURRENT_DATE`, então o resultado nunca fica desatualizado.
- **Valor do pagamento desacoplado do valor do plano**: o histórico financeiro não é reescrito se o preço do plano mudar no futuro.

## Estrutura dos arquivos

| Arquivo | Conteúdo |
|---|---|
| `sql/01_schema.sql` | Tipos ENUM, tabelas, constraints e índices |
| `sql/02_functions_triggers.sql` | Função e trigger de validação de check-in |
| `sql/03_views.sql` | Views de inadimplência e faturamento mensal |
| `sql/04_seed_data.sql` | Dados de teste (alunos, matrículas, pagamentos, check-ins) |
| `sql/05_queries_relatorios.sql` | Queries analíticas para relatórios |

## Como rodar no Pop!_OS com DBeaver

1. Crie um banco dedicado:
   ```sql
   CREATE DATABASE academia_alta_performance;
   ```
2. No DBeaver, conecte nesse banco e abra os arquivos `.sql` na ordem numérica (01 → 05), executando cada script completo (`Alt+X` ou o botão "Execute SQL Script").
3. Depois de rodar o `04_seed_data.sql`, abra `05_queries_relatorios.sql` e execute cada bloco para ver os relatórios.

## Queries de destaque

**Faturamento mensal por modalidade**
```sql
SELECT * FROM vw_faturamento_mensal_modalidade ORDER BY mes DESC;
```

**Alunos inadimplentes**
```sql
SELECT * FROM vw_alunos_inadimplentes ORDER BY dias_atraso DESC;
```

## Testando a trigger de check-in

```sql
-- Suspende uma matrícula ativa
UPDATE matriculas SET status = 'suspenso' WHERE id = 1;

-- Tenta fazer check-in: deve falhar
INSERT INTO checkins (matricula_id) VALUES (1);
-- ERROR: Check-in não permitido: matrícula 1 está com status "suspenso"
```

## Possíveis evoluções

- Job agendado (`pg_cron` ou rotina externa) para notificar inadimplentes automaticamente por e-mail.
- Tabela de auditoria para mudanças de status de matrícula.
- API REST sobre esse schema (Node/Express ou FastAPI) para expor os relatórios.
- Particionamento da tabela `checkins` por mês, caso o volume de frequência cresça muito.

## Tecnologias

- PostgreSQL 14+
- DBeaver (interface gráfica)
- Desenvolvido e testado em Pop!_OS
