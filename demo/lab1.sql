-- Лаба 1. Сценарий для показа. Формат описан в docs/scenarios.md.
-- Запуск: dbcheck run demo/lab1.sql, или в psql: \i /demo/lab1.sql



-- Проверка UNIQUE.
-- expect: error unique

INSERT INTO teams (team_name)
VALUES ('Team Spirit');


-- Проверка CHECK.
-- expect: error check

INSERT INTO team_members (player_id, role_in_team, team_id, start_play, end_play)
VALUES (1, 1, 1, '2024-07-01', '2024-01-01');


-- Проверка FOREIGN KEY.
-- expect: error fk

INSERT INTO team_members (player_id, role_in_team, team_id, start_play, end_play)
VALUES (999999, 1, 1, '2024-01-01', '2024-07-01');


-- app=# \i /demo/lab1.sql
-- psql:/demo/lab1.sql:10: ERROR:  duplicate key value violates unique constraint "teams_team_name_key"
-- DETAIL:  Key (team_name)=(Team Spirit) already exists.
-- psql:/demo/lab1.sql:17: ERROR:  new row for relation "team_members" violates check constraint "team_members_check"
-- DETAIL:  Failing row contains (1, 1, 1, 2024-07-01, 2024-01-01).
-- psql:/demo/lab1.sql:24: ERROR:  insert or update on table "team_members" violates foreign key constraint "team_members_player_id_fkey"
-- DETAIL:  Key (player_id)=(999999) is not present in table "players".
-- app=#
