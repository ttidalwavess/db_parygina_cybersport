-- 1. Запрет регистрации команды на завершённый турнир
CREATE OR REPLACE FUNCTION check_tournament_status()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
v_status tournament_status;
BEGIN
SELECT status
INTO v_status
FROM tournaments
WHERE id = NEW.contest_name;

IF v_status = 'completed' THEN
        RAISE EXCEPTION
            'Нельзя зарегистрировать команду на завершённый турнир';
END IF;

RETURN NEW;
END;
$$;

-- 2. Проверка, что игрок не состоит в другой команде в пересекающийся период времени
CREATE OR REPLACE FUNCTION check_player_in_team()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM team_members tm
        WHERE tm.player_id = NEW.player_id
          AND tm.team_id <> NEW.team_id
          AND NEW.start_play <= tm.end_play
          AND NEW.end_play >= tm.start_play
    ) THEN
        RAISE EXCEPTION
            'Игрок % уже состоит в другой команде в указанный период',
            NEW.player_id;
END IF;

RETURN NEW;
END;
$$;

-- 3. Процедура добавления игрока в команду
CREATE OR REPLACE PROCEDURE add_player_to_team(
    p_player_id integer,
    p_role_id integer,
    p_team_id integer,
    p_start_date timestamptz,
    p_end_date timestamptz
)
LANGUAGE plpgsql
AS $$
BEGIN
INSERT INTO team_members (
    player_id,
    role_in_team,
    team_id,
    start_play,
    end_play
)
VALUES (
           p_player_id,
           p_role_id,
           p_team_id,
           p_start_date,
           p_end_date
       );

RAISE NOTICE 'Игрок успешно добавлен в команду';
END;
$$;

-- 4. Служебное поле updated_at и функция его обновления
ALTER TABLE players
    ADD COLUMN updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP;

CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at := clock_timestamp();
RETURN NEW;
END;
$$;

-- 5. Функция фильтрации турниров.
-- Каждый параметр необязательный.
CREATE OR REPLACE FUNCTION filter_tournaments(
    p_status tournament_status DEFAULT NULL,
    p_min_teams integer DEFAULT NULL
)
RETURNS TABLE (
    tournament_id integer,
    tournament_name text,
    start_day timestamptz,
    end_day timestamptz,
    status tournament_status,
    teams_count integer
)
LANGUAGE sql
AS $$
SELECT
    t.id,
    t.tournament_name,
    t.start_day,
    t.end_day,
    t.status,
    COUNT(pt.teams_playing)::integer AS teams_count
FROM tournaments t
         LEFT JOIN participating_teams pt
                   ON pt.contest_name = t.id
WHERE p_status IS NULL OR t.status = p_status
GROUP BY
    t.id,
    t.tournament_name,
    t.start_day,
    t.end_day,
    t.status
HAVING
    p_min_teams IS NULL
    OR COUNT(pt.teams_playing) >= p_min_teams
ORDER BY t.start_day;
$$;