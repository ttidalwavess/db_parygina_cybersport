-- Лаба 4. Гонка: два окна добавляют одного игрока в разные команды.
-- [check] должен вернуть false (правило нарушено).

-- [setup]
DROP TABLE IF EXISTS race_demo;
CREATE TABLE race_demo (
                           player_id integer NOT NULL,
                           team_id   integer NOT NULL,
                           joined_at timestamp DEFAULT now()
);

-- [A] Окно A: проверяет, что игрок 999 свободен
BEGIN;
SELECT count(*) = 0 AS player_is_free FROM race_demo WHERE player_id = 999;

-- [B] Окно B: в тот же момент тоже видит «свободен»
BEGIN;
SELECT count(*) = 0 AS player_is_free FROM race_demo WHERE player_id = 999;

-- [A] Окно A добавляет игрока в Team Spirit (team_id = 3)
INSERT INTO race_demo (player_id, team_id) VALUES (999, 3);

-- [B] Окно B добавляет того же игрока в OG (team_id = 1)
INSERT INTO race_demo (player_id, team_id) VALUES (999, 1);

-- [A]
COMMIT;

-- [B]
COMMIT;

-- [check] Игрок в одной команде? (ожидаем false)
-- expect: false
SELECT count(*) <= 1 AS player_in_one_team FROM race_demo WHERE player_id = 999;

-- [cleanup]
DROP TABLE IF EXISTS race_demo;