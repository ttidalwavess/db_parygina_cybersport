-- 1. Список игроков, их команд и ролей
CREATE OR REPLACE VIEW nickname_role AS
SELECT
    p.nickname,
    p.first_name,
    p.second_name,
    t.team_name,
    r.role_name
FROM team_members tm
    JOIN players p ON p.id = tm.player_id
    JOIN teams t ON t.id = tm.team_id
    JOIN roles r ON r.id = tm.role_in_team;

-- 2. Команды, участвовавшие в завершённых турнирах
CREATE OR REPLACE VIEW participated_in_tournament AS
SELECT
    tu.tournament_name,
    t.team_name
FROM participating_teams pt
    JOIN teams t ON t.id = pt.teams_playing
    JOIN tournaments tu ON tu.id = pt.contest_name
WHERE tu.status = 'completed';

-- 3. Материализованный отчёт по турнирам
CREATE MATERIALIZED VIEW tournament_report AS
SELECT
    t.id AS tournament_id,
    t.tournament_name,
    t.start_day,
    t.end_day,
    t.status,
    COUNT(pt.teams_playing)::integer AS teams_count
FROM tournaments t
LEFT JOIN participating_teams pt ON pt.contest_name = t.id
GROUP BY
    t.id,
    t.tournament_name,
    t.start_day,
    t.end_day,
    t.status;