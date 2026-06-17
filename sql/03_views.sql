-- =========================================================
-- ACADEMIA DE ALTA PERFORMANCE - VIEWS
-- =========================================================

-- -------------------------------------------------
-- View: alunos inadimplentes
-- -------------------------------------------------
-- Em vez de armazenar um status "atrasado" fixo na tabela
-- pagamentos, calculamos isso dinamicamente comparando o
-- vencimento com a data atual. Assim a informação nunca fica
-- desatualizada (não depende de um job rodar todo dia).
CREATE OR REPLACE VIEW vw_alunos_inadimplentes AS
SELECT
    a.id            AS aluno_id,
    a.nome          AS aluno,
    a.email,
    a.telefone,
    mo.nome         AS modalidade,
    p.id            AS pagamento_id,
    p.valor,
    p.data_vencimento,
    (CURRENT_DATE - p.data_vencimento) AS dias_atraso
FROM pagamentos p
JOIN matriculas  m  ON m.id  = p.matricula_id
JOIN alunos      a  ON a.id  = m.aluno_id
JOIN modalidades mo ON mo.id = m.modalidade_id
WHERE p.status_pagamento = 'pendente'
  AND p.data_vencimento < CURRENT_DATE
ORDER BY dias_atraso DESC;

-- -------------------------------------------------
-- View: faturamento mensal por modalidade
-- -------------------------------------------------
-- Considera apenas pagamentos efetivamente recebidos ('pago'),
-- agrupados pelo mês em que o pagamento ocorreu.
CREATE OR REPLACE VIEW vw_faturamento_mensal_modalidade AS
SELECT
    DATE_TRUNC('month', p.data_pagamento)::DATE AS mes,
    mo.nome                                     AS modalidade,
    COUNT(p.id)                                 AS qtd_pagamentos,
    SUM(p.valor)                                AS faturamento
FROM pagamentos p
JOIN matriculas  m  ON m.id  = p.matricula_id
JOIN modalidades mo ON mo.id = m.modalidade_id
WHERE p.status_pagamento = 'pago'
GROUP BY DATE_TRUNC('month', p.data_pagamento), mo.nome
ORDER BY mes, modalidade;
