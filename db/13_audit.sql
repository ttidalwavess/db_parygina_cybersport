-- Таблица журнала. Внешний ключ на players намеренно не создаётся,
-- чтобы запись в журнале сохранялась после удаления игрока.
CREATE TABLE players_audit (
                               id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
                               player_id integer NOT NULL,
                               operation text NOT NULL CHECK (operation IN ('INSERT', 'UPDATE', 'DELETE')),
                               old_data jsonb,
                               new_data jsonb,
                               changed_by name NOT NULL,
                               changed_at timestamptz NOT NULL
);

-- Функция записи INSERT, UPDATE и DELETE в журнал
CREATE OR REPLACE FUNCTION log_player_changes()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO players_audit (
            player_id, operation, old_data, new_data, changed_by, changed_at
        )
        VALUES (
            NEW.id, TG_OP, NULL, to_jsonb(NEW),
            session_user, clock_timestamp()
        );
RETURN NEW;

ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO players_audit (
            player_id, operation, old_data, new_data, changed_by, changed_at
        )
        VALUES (
            NEW.id, TG_OP, to_jsonb(OLD), to_jsonb(NEW),
            session_user, clock_timestamp()
        );
RETURN NEW;

ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO players_audit (
            player_id, operation, old_data, new_data, changed_by, changed_at
        )
        VALUES (
            OLD.id, TG_OP, to_jsonb(OLD), NULL,
            session_user, clock_timestamp()
        );
RETURN OLD;
END IF;

RETURN NULL;
END;
$$;

-- Триггер журналирования всех изменений игроков
CREATE TRIGGER trg_players_audit
    AFTER INSERT OR UPDATE OR DELETE ON players
    FOR EACH ROW
    EXECUTE FUNCTION log_player_changes();

-- Возвращает состояние игрока на указанный момент времени.
-- Если на этот момент игрок уже был удалён, возвращает NULL.
CREATE OR REPLACE FUNCTION player_state_at(
    p_player_id integer,
    p_moment timestamptz
)
RETURNS jsonb
LANGUAGE plpgsql
AS $$
DECLARE
v_state jsonb;
    v_found boolean;
BEGIN
    -- Последнее изменение, произошедшее не позднее указанного момента
SELECT
    CASE
        WHEN a.operation = 'DELETE' THEN NULL
        ELSE a.new_data
        END
INTO v_state
FROM players_audit a
WHERE a.player_id = p_player_id
  AND a.changed_at <= p_moment
ORDER BY a.changed_at DESC, a.id DESC
    LIMIT 1;

IF FOUND THEN
        RETURN v_state;
END IF;

    -- Если изменений до указанного момента не было,
    -- восстанавливаем состояние по старым данным первого будущего события.
SELECT
    CASE
        WHEN a.operation = 'INSERT' THEN NULL
        ELSE a.old_data
        END
INTO v_state
FROM players_audit a
WHERE a.player_id = p_player_id
  AND a.changed_at > p_moment
ORDER BY a.changed_at, a.id
    LIMIT 1;

IF FOUND THEN
        RETURN v_state;
END IF;

    -- Если у игрока вообще нет записей в журнале,
    -- он мог быть добавлен начальными данными до установки триггера.
SELECT to_jsonb(p)
INTO v_state
FROM players p
WHERE p.id = p_player_id;

RETURN v_state;
END;
$$;