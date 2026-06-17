-- =========================================================
-- ACADEMIA DE ALTA PERFORMANCE - SCHEMA PRINCIPAL
-- =========================================================
-- Banco: PostgreSQL 14+
-- Ordem de execução: 01 -> 02 -> 03 -> 04 -> 05
-- =========================================================

-- -------------------------------------------------
-- 1. TIPOS ENUM
-- -------------------------------------------------
-- Usamos ENUM em vez de VARCHAR livre para garantir, no nível
-- do banco, que só existam os status previstos pelo negócio.
-- Isso evita "Ativo", "ativo", "ATIVO", "Ativa" convivendo na
-- mesma coluna.

CREATE TYPE status_matricula AS ENUM ('ativo', 'inativo', 'suspenso', 'cancelado');
CREATE TYPE status_pagamento AS ENUM ('pendente', 'pago', 'cancelado');
CREATE TYPE tipo_plano       AS ENUM ('mensal', 'trimestral', 'semestral', 'anual');

-- -------------------------------------------------
-- 2. MODALIDADES
-- -------------------------------------------------
CREATE TABLE modalidades (
    id          SERIAL PRIMARY KEY,
    nome        VARCHAR(50) NOT NULL UNIQUE,
    descricao   TEXT
);

-- -------------------------------------------------
-- 3. PLANOS
-- -------------------------------------------------
CREATE TABLE planos (
    id              SERIAL PRIMARY KEY,
    nome            VARCHAR(50)  NOT NULL,
    tipo            tipo_plano   NOT NULL,
    duracao_meses   SMALLINT     NOT NULL CHECK (duracao_meses > 0),
    valor           NUMERIC(10,2) NOT NULL CHECK (valor > 0)
);

-- -------------------------------------------------
-- 4. ALUNOS
-- -------------------------------------------------
CREATE TABLE alunos (
    id               SERIAL PRIMARY KEY,
    nome             VARCHAR(100) NOT NULL,
    cpf              VARCHAR(11)  NOT NULL UNIQUE,
    email            VARCHAR(100) UNIQUE,
    telefone         VARCHAR(20),
    data_nascimento  DATE NOT NULL,
    data_cadastro    DATE NOT NULL DEFAULT CURRENT_DATE,
    CONSTRAINT chk_cpf_formato CHECK (cpf ~ '^[0-9]{11}$')
);

-- -------------------------------------------------
-- 5. MATRÍCULAS (vínculo aluno + plano + modalidade)
-- -------------------------------------------------
-- Um aluno pode ter mais de uma matrícula ao longo do tempo
-- (trocou de plano, mudou de modalidade, voltou depois de
-- cancelar). O status aqui é o que efetivamente controla se o
-- check-in pode acontecer.
CREATE TABLE matriculas (
    id              SERIAL PRIMARY KEY,
    aluno_id        INTEGER NOT NULL REFERENCES alunos(id)      ON DELETE RESTRICT,
    plano_id        INTEGER NOT NULL REFERENCES planos(id)      ON DELETE RESTRICT,
    modalidade_id   INTEGER NOT NULL REFERENCES modalidades(id) ON DELETE RESTRICT,
    data_inicio     DATE NOT NULL DEFAULT CURRENT_DATE,
    data_fim        DATE,
    status          status_matricula NOT NULL DEFAULT 'ativo',
    CONSTRAINT chk_datas_matricula CHECK (data_fim IS NULL OR data_fim >= data_inicio)
);

-- -------------------------------------------------
-- 6. PAGAMENTOS (histórico financeiro)
-- -------------------------------------------------
-- O valor é gravado na própria linha (e não recalculado a
-- partir de planos.valor) de propósito: se o preço do plano
-- mudar no futuro, o histórico de cobranças passadas não pode
-- ser alterado retroativamente.
CREATE TABLE pagamentos (
    id              SERIAL PRIMARY KEY,
    matricula_id    INTEGER NOT NULL REFERENCES matriculas(id) ON DELETE CASCADE,
    valor           NUMERIC(10,2) NOT NULL CHECK (valor > 0),
    data_vencimento DATE NOT NULL,
    data_pagamento  DATE,
    status_pagamento status_pagamento NOT NULL DEFAULT 'pendente',
    CONSTRAINT chk_pagamento_consistente CHECK (
        (status_pagamento = 'pago' AND data_pagamento IS NOT NULL)
        OR (status_pagamento <> 'pago')
    )
);

-- -------------------------------------------------
-- 7. CHECK-INS (controle de frequência)
-- -------------------------------------------------
CREATE TABLE checkins (
    id              SERIAL PRIMARY KEY,
    matricula_id    INTEGER NOT NULL REFERENCES matriculas(id) ON DELETE CASCADE,
    data_hora       TIMESTAMP NOT NULL DEFAULT NOW()
);

-- -------------------------------------------------
-- 8. ÍNDICES
-- -------------------------------------------------
CREATE INDEX idx_matriculas_aluno        ON matriculas(aluno_id);
CREATE INDEX idx_matriculas_status       ON matriculas(status);
CREATE INDEX idx_pagamentos_matricula    ON pagamentos(matricula_id);
CREATE INDEX idx_pagamentos_vencimento   ON pagamentos(data_vencimento)
    WHERE status_pagamento = 'pendente';
CREATE INDEX idx_checkins_matricula      ON checkins(matricula_id);
CREATE INDEX idx_checkins_data           ON checkins(data_hora);
