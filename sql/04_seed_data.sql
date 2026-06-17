-- =========================================================
-- ACADEMIA DE ALTA PERFORMANCE - DADOS DE TESTE (SEED)
-- =========================================================
-- As datas são calculadas em relação a CURRENT_DATE para que
-- o cenário (alunos inadimplentes, faturamento do mês etc.)
-- sempre faça sentido, independentemente de quando este script
-- for executado.
-- =========================================================

-- -------------------------------------------------
-- MODALIDADES
-- -------------------------------------------------
INSERT INTO modalidades (nome, descricao) VALUES
('Musculação', 'Treinamento de força com pesos livres e máquinas'),
('Crossfit',   'Treinamento funcional de alta intensidade'),
('Natação',    'Aulas de natação em piscina semiolímpica'),
('Funcional',  'Treino funcional em circuito'),
('Pilates',    'Aulas de pilates em solo e aparelhos');

-- -------------------------------------------------
-- PLANOS
-- -------------------------------------------------
INSERT INTO planos (nome, tipo, duracao_meses, valor) VALUES
('Mensal',     'mensal',     1,  129.90),
('Trimestral', 'trimestral', 3,  349.90),
('Semestral',  'semestral',  6,  639.90),
('Anual',      'anual',      12, 1199.90);

-- -------------------------------------------------
-- ALUNOS
-- -------------------------------------------------
INSERT INTO alunos (nome, cpf, email, telefone, data_nascimento, data_cadastro) VALUES
('Mariana Costa Lima',     '11122233344', 'mariana.lima@email.com',   '21988887701', '1995-03-12', CURRENT_DATE - INTERVAL '11 months'),
('Rafael Souza Andrade',   '22233344455', 'rafael.andrade@email.com', '21988887702', '1990-07-25', CURRENT_DATE - INTERVAL '9 months'),
('Beatriz Fernandes Rocha','33344455566', 'beatriz.rocha@email.com',  '21988887703', '1998-11-02', CURRENT_DATE - INTERVAL '8 months'),
('Lucas Almeida Pereira',  '44455566677', 'lucas.pereira@email.com',  '21988887704', '1992-05-18', CURRENT_DATE - INTERVAL '7 months'),
('Carla Mendes Oliveira',  '55566677788', 'carla.oliveira@email.com', '21988887705', '1988-01-30', CURRENT_DATE - INTERVAL '6 months'),
('Thiago Ribeiro Santos',  '66677788899', 'thiago.santos@email.com',  '21988887706', '2000-09-09', CURRENT_DATE - INTERVAL '5 months'),
('Juliana Pinto Cardoso',  '77788899900', 'juliana.cardoso@email.com','21988887707', '1996-04-21', CURRENT_DATE - INTERVAL '4 months'),
('Eduardo Martins Barros', '88899900011', 'eduardo.barros@email.com', '21988887708', '1985-12-14', CURRENT_DATE - INTERVAL '3 months'),
('Patrícia Gomes Teixeira','99900011122', 'patricia.teixeira@email.com','21988887709','1993-06-07', CURRENT_DATE - INTERVAL '2 months'),
('Gustavo Henrique Dias',  '00011122233', 'gustavo.dias@email.com',   '21988887710', '1991-02-28', CURRENT_DATE - INTERVAL '1 month');

-- -------------------------------------------------
-- MATRÍCULAS
-- -------------------------------------------------
-- A maioria ativa, com alguns casos de suspenso/cancelado/inativo
-- para validar a trigger de check-in e os filtros de status.
INSERT INTO matriculas (aluno_id, plano_id, modalidade_id, data_inicio, data_fim, status) VALUES
(1, 4, 1, CURRENT_DATE - INTERVAL '11 months', NULL,                          'ativo'),     -- Mariana, Anual, Musculação
(2, 2, 2, CURRENT_DATE - INTERVAL '9 months',  CURRENT_DATE + INTERVAL '1 month', 'ativo'), -- Rafael, Trimestral, Crossfit
(3, 1, 5, CURRENT_DATE - INTERVAL '8 months',  NULL,                          'ativo'),     -- Beatriz, Mensal, Pilates
(4, 3, 3, CURRENT_DATE - INTERVAL '7 months',  NULL,                          'ativo'),     -- Lucas, Semestral, Natação
(5, 1, 4, CURRENT_DATE - INTERVAL '6 months',  CURRENT_DATE - INTERVAL '1 month', 'cancelado'), -- Carla, cancelou
(6, 2, 2, CURRENT_DATE - INTERVAL '5 months',  NULL,                          'ativo'),     -- Thiago, Trimestral, Crossfit
(7, 1, 1, CURRENT_DATE - INTERVAL '4 months',  NULL,                          'suspenso'),  -- Juliana, suspensa (ex.: trancamento)
(8, 4, 3, CURRENT_DATE - INTERVAL '3 months',  NULL,                          'ativo'),     -- Eduardo, Anual, Natação
(9, 1, 5, CURRENT_DATE - INTERVAL '2 months',  NULL,                          'ativo'),     -- Patrícia, Mensal, Pilates
(10,2, 4, CURRENT_DATE - INTERVAL '1 month',   NULL,                          'inativo');   -- Gustavo, parou de frequentar

-- -------------------------------------------------
-- PAGAMENTOS
-- -------------------------------------------------
-- Para cada matrícula ativa há histórico de mensalidades:
-- algumas pagas em meses anteriores, uma pendente já vencida
-- (gera inadimplência) e, em alguns casos, a próxima ainda a
-- vencer.

-- Mariana (matrícula 1) - paga em dia
INSERT INTO pagamentos (matricula_id, valor, data_vencimento, data_pagamento, status_pagamento) VALUES
(1, 1199.90, CURRENT_DATE - INTERVAL '11 months', CURRENT_DATE - INTERVAL '11 months', 'pago');

-- Rafael (matrícula 2) - trimestral pago, próxima ciclo a vencer no futuro
INSERT INTO pagamentos (matricula_id, valor, data_vencimento, data_pagamento, status_pagamento) VALUES
(2, 349.90, CURRENT_DATE - INTERVAL '3 months', CURRENT_DATE - INTERVAL '3 months', 'pago'),
(2, 349.90, CURRENT_DATE + INTERVAL '1 month',  NULL,                                'pendente');

-- Beatriz (matrícula 3) - mensalista, está ATRASADA (gera inadimplência)
INSERT INTO pagamentos (matricula_id, valor, data_vencimento, data_pagamento, status_pagamento) VALUES
(3, 129.90, CURRENT_DATE - INTERVAL '2 months', CURRENT_DATE - INTERVAL '2 months', 'pago'),
(3, 129.90, CURRENT_DATE - INTERVAL '1 month',  CURRENT_DATE - INTERVAL '1 month', 'pago'),
(3, 129.90, CURRENT_DATE - INTERVAL '15 days',  NULL,                                'pendente');

-- Lucas (matrícula 4) - semestral, pago
INSERT INTO pagamentos (matricula_id, valor, data_vencimento, data_pagamento, status_pagamento) VALUES
(4, 639.90, CURRENT_DATE - INTERVAL '7 months', CURRENT_DATE - INTERVAL '7 months', 'pago');

-- Carla (matrícula 5, cancelada) - último pagamento antes do cancelamento
INSERT INTO pagamentos (matricula_id, valor, data_vencimento, data_pagamento, status_pagamento) VALUES
(5, 129.90, CURRENT_DATE - INTERVAL '2 months', CURRENT_DATE - INTERVAL '2 months', 'pago');

-- Thiago (matrícula 6) - ATRASADO há mais tempo (caso "crítico")
INSERT INTO pagamentos (matricula_id, valor, data_vencimento, data_pagamento, status_pagamento) VALUES
(6, 349.90, CURRENT_DATE - INTERVAL '5 months', CURRENT_DATE - INTERVAL '5 months', 'pago'),
(6, 349.90, CURRENT_DATE - INTERVAL '40 days',  NULL,                                'pendente');

-- Juliana (matrícula 7, suspensa) - pagamento em dia, mas plano suspenso
INSERT INTO pagamentos (matricula_id, valor, data_vencimento, data_pagamento, status_pagamento) VALUES
(7, 129.90, CURRENT_DATE - INTERVAL '3 months', CURRENT_DATE - INTERVAL '3 months', 'pago');

-- Eduardo (matrícula 8) - anual pago
INSERT INTO pagamentos (matricula_id, valor, data_vencimento, data_pagamento, status_pagamento) VALUES
(8, 1199.90, CURRENT_DATE - INTERVAL '3 months', CURRENT_DATE - INTERVAL '3 months', 'pago');

-- Patrícia (matrícula 9) - mensal, pago no mês atual
INSERT INTO pagamentos (matricula_id, valor, data_vencimento, data_pagamento, status_pagamento) VALUES
(9, 129.90, CURRENT_DATE - INTERVAL '5 days', CURRENT_DATE - INTERVAL '5 days', 'pago');

-- Gustavo (matrícula 10, inativo) - ATRASADO e sem frequência
INSERT INTO pagamentos (matricula_id, valor, data_vencimento, data_pagamento, status_pagamento) VALUES
(10, 349.90, CURRENT_DATE - INTERVAL '20 days', NULL, 'pendente');

-- -------------------------------------------------
-- CHECK-INS
-- -------------------------------------------------
-- Apenas para matrículas com status 'ativo' (a trigger
-- impediria check-ins em matrículas suspensas/canceladas/inativas).
INSERT INTO checkins (matricula_id, data_hora) VALUES
(1, NOW() - INTERVAL '1 day'),
(1, NOW() - INTERVAL '3 days'),
(2, NOW() - INTERVAL '2 days'),
(3, NOW() - INTERVAL '1 day'),
(4, NOW() - INTERVAL '4 days'),
(6, NOW() - INTERVAL '2 days'),
(8, NOW() - INTERVAL '1 day'),
(9, NOW() - INTERVAL '5 days');
