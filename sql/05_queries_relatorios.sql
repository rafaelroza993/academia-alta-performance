-- =========================================================
-- ACADEMIA DE ALTA PERFORMANCE - QUERIES DE IMPACTO
-- =========================================================
-- Estas são as consultas pensadas para aparecer no README do
-- GitHub como demonstração de domínio em SQL analítico.
-- =========================================================

-- ---------------------------------------------------------
-- 1) Faturamento mensal por modalidade
-- ---------------------------------------------------------
SELECT
    TO_CHAR(mes, 'YYYY-MM')  AS competencia,
    modalidade,
    qtd_pagamentos,
    faturamento
FROM vw_faturamento_mensal_modalidade
ORDER BY mes DESC, faturamento DESC;

-- Versão sem depender da view, caso queira rodar direto:
-- SELECT
--     DATE_TRUNC('month', p.data_pagamento)::DATE AS mes,
--     mo.nome AS modalidade,
--     SUM(p.valor) AS faturamento
-- FROM pagamentos p
-- JOIN matriculas  m  ON m.id  = p.matricula_id
-- JOIN modalidades mo ON mo.id = m.modalidade_id
-- WHERE p.status_pagamento = 'pago'
-- GROUP BY 1, 2
-- ORDER BY 1 DESC, 3 DESC;


-- ---------------------------------------------------------
-- 2) Alunos inadimplentes (mensalidades atrasadas)
-- ---------------------------------------------------------
SELECT
    aluno,
    modalidade,
    email,
    telefone,
    valor,
    data_vencimento,
    dias_atraso
FROM vw_alunos_inadimplentes
ORDER BY dias_atraso DESC;


-- ---------------------------------------------------------
-- 3) Receita prevista x recebida no mês atual
-- ---------------------------------------------------------
-- Compara o que deveria entrar (todas as cobranças com
-- vencimento no mês) com o que de fato já foi pago.
SELECT
    SUM(valor) FILTER (WHERE status_pagamento IN ('pendente','pago')) AS receita_prevista,
    SUM(valor) FILTER (WHERE status_pagamento = 'pago')                AS receita_recebida,
    SUM(valor) FILTER (WHERE status_pagamento = 'pendente'
                        AND data_vencimento < CURRENT_DATE)             AS receita_em_atraso
FROM pagamentos
WHERE DATE_TRUNC('month', data_vencimento) = DATE_TRUNC('month', CURRENT_DATE);


-- ---------------------------------------------------------
-- 4) Ranking de frequência (alunos mais assíduos)
-- ---------------------------------------------------------
-- Útil para identificar quem usa mais a academia e cruzar com
-- estratégias de retenção / programas de fidelidade.
SELECT
    a.nome AS aluno,
    mo.nome AS modalidade,
    COUNT(c.id) AS total_checkins,
    MAX(c.data_hora)::DATE AS ultimo_checkin
FROM checkins c
JOIN matriculas  m  ON m.id  = c.matricula_id
JOIN alunos      a  ON a.id  = m.aluno_id
JOIN modalidades mo ON mo.id = m.modalidade_id
GROUP BY a.nome, mo.nome
ORDER BY total_checkins DESC;


-- ---------------------------------------------------------
-- 5) Distribuição de alunos por status de matrícula
-- ---------------------------------------------------------
-- Bom indicador de saúde da base (quantos ativos vs.
-- cancelados/suspensos/inativos).
SELECT
    status,
    COUNT(*) AS total_alunos,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS percentual
FROM matriculas
GROUP BY status
ORDER BY total_alunos DESC;


-- ---------------------------------------------------------
-- 6) Modalidade mais lucrativa por aluno ativo (ticket médio)
-- ---------------------------------------------------------
SELECT
    mo.nome AS modalidade,
    COUNT(DISTINCT m.id) AS matriculas_ativas,
    ROUND(SUM(p.valor) / COUNT(DISTINCT m.id), 2) AS ticket_medio
FROM matriculas m
JOIN modalidades mo ON mo.id = m.modalidade_id
JOIN pagamentos  p  ON p.matricula_id = m.id AND p.status_pagamento = 'pago'
WHERE m.status = 'ativo'
GROUP BY mo.nome
ORDER BY ticket_medio DESC;
