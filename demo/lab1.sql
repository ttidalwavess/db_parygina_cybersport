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
