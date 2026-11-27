-- Лаба 4. Исправление гонки: PRIMARY KEY не даёт вставить player_id дважды.
-- [check] должен вернуть true.

-- [setup]
DROP TABLE IF EXISTS race_fixed_demo;
CREATE TABLE race_fixed_demo (
                                 player_id integer PRIMARY KEY,
                                 team_id   integer NOT NULL,
                                 joined_at timestamp DEFAULT now()
);

-- [A] Окно A: проверяет, что игрок свободен
BEGIN;
SELECT count(*) = 0 AS player_is_free FROM race_fixed_demo WHERE player_id = 999;

-- [B] Окно B: тоже видит «свободен»
BEGIN;
SELECT count(*) = 0 AS player_is_free FROM race_fixed_demo WHERE player_id = 999;

-- [A] Окно A вставляет (захватывает PK)
INSERT INTO race_fixed_demo (player_id, team_id) VALUES (999, 3);

-- [B] Окно B ждёт блокировки по PK
-- expect: blocked
INSERT INTO race_fixed_demo (player_id, team_id) VALUES (999, 1);

-- [A]
COMMIT;

-- [B] после COMMIT A — ошибка UNIQUE
-- expect: error unique

-- [check] Игрок в одной команде? (ожидаем true)
-- expect: true
SELECT count(*) <= 1 AS player_in_one_team FROM race_fixed_demo WHERE player_id = 999;

-- [cleanup]
DROP TABLE IF EXISTS race_fixed_demo;