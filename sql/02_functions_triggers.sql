-- =========================================================
-- ACADEMIA DE ALTA PERFORMANCE - REGRAS DE NEGÓCIO (TRIGGERS)
-- =========================================================

-- -------------------------------------------------
-- Regra: só é permitido check-in se a matrícula estiver
-- com status 'ativo' e dentro da vigência (data_fim).
-- -------------------------------------------------
CREATE OR REPLACE FUNCTION fn_valida_checkin()
RETURNS TRIGGER AS $$
DECLARE
    v_status   status_matricula;
    v_data_fim DATE;
BEGIN
    SELECT status, data_fim
      INTO v_status, v_data_fim
      FROM matriculas
     WHERE id = NEW.matricula_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Matrícula % não encontrada', NEW.matricula_id;
    END IF;

    IF v_status <> 'ativo' THEN
        RAISE EXCEPTION
            'Check-in não permitido: matrícula % está com status "%"',
            NEW.matricula_id, v_status;
    END IF;

    IF v_data_fim IS NOT NULL AND v_data_fim < CURRENT_DATE THEN
        RAISE EXCEPTION
            'Check-in não permitido: matrícula % expirou em %',
            NEW.matricula_id, v_data_fim;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_valida_checkin
    BEFORE INSERT ON checkins
    FOR EACH ROW
    EXECUTE FUNCTION fn_valida_checkin();

-- -------------------------------------------------
-- Teste rápido (rode manualmente no DBeaver para validar):
--
-- 1) Marque uma matrícula como suspensa:
--    UPDATE matriculas SET status = 'suspenso' WHERE id = 1;
--
-- 2) Tente inserir um check-in para ela:
--    INSERT INTO checkins (matricula_id) VALUES (1);
--    -> deve falhar com a exceção definida acima.
-- -------------------------------------------------
