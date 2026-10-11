-- Лаба 1. Сценарий для показа. Формат описан в docs/scenarios.md.
-- Запуск: dbcheck run demo/lab1.sql, или в psql: \i /demo/lab1.sql
--
-- Каждый шаг: строка «-- N. что показываем», под ней «-- expect: ответ базы», под ней запрос.
-- Пример, замените своими запросами:
--
-- -- 1. Таблицы на месте: 6 таблиц
-- -- expect: rows 6
-- SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY 1;
--
-- -- 2. Отрицательная цена билета: ошибка CHECK
-- -- expect: error check
-- INSERT INTO tickets (session_id, seat_id, price) VALUES (1, 1, -100);
--
-- -- 3. Несуществующий сеанс: ошибка внешнего ключа
-- -- expect: error fk
-- INSERT INTO tickets (session_id, seat_id, price) VALUES (9999, 1, 300);
--
-- -- 4. То же место на тот же сеанс второй раз: ошибка UNIQUE
-- -- expect: error unique
-- INSERT INTO tickets (session_id, seat_id, price) VALUES (1, 1, 300);


INSERT INTO teams (team_name) VALUES ('Team Spirit');
-- ERROR:  duplicate key value violates unique constraint "teams_team_name_key"
-- DETAIL:  Key (team_name)=(Team Spirit) already exists.


INSERT INTO players (first_name, second_name, nickname) VALUES ('Morgan', 'Swift', 'Axiom');
-- ERROR:  duplicate key value violates unique constraint "players_nickname_key"
-- DETAIL:  Key (nickname)=(Axiom) already exists.


INSERT INTO team_members
(player_id, role_in_team, team_id, start_play, end_play)
SELECT
    p.id,
    r.id,
    t.id,
    v.start_play::date,
    v.end_play::date
FROM (
         VALUES ('Gatsby', 'carry', 'Team Yandex', '2024-01-01', '2023-01-01')
     ) AS v(nickname, role_name, team_name, start_play, end_play)
         JOIN players p ON p.nickname = v.nickname
         JOIN roles r ON r.role_name = v.role_name
         JOIN teams t ON t.team_name = v.team_name;

-- ERROR:  new row for relation "team_members" violates check constraint "team_members_check"
-- DETAIL:  Failing row contains (22, 1, 10, 2024-01-01, 2023-01-01).


INSERT INTO tournaments (id, tournament_name, start_day, end_day, ongoing) VALUES (99, 'Hackaton2000', '2026-05-07', '2026-08-09', 'false');
-- ERROR:  cannot insert a non-DEFAULT value into column "id"
-- DETAIL:  Column "id" is an identity column defined as GENERATED ALWAYS.
-- HINT:  Use OVERRIDING SYSTEM VALUE to override.