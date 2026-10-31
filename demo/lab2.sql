-- 1. Вывести имя игрока, его команду и роль
SELECT p.nickname, p.first_name, p.second_name, t.team_name, r.role_name
FROM team_members tm
JOIN players p ON p.id = tm.player_id
JOIN teams t ON t.id = tm.team_id
JOIN roles r ON r.id = tm.role_in_team
ORDER BY t.team_name, r.role_name;


-- 2. Списки команд, участвующих в турнирах
SELECT tr.tournament_name, tr.status, t.team_name
FROM tournaments tr
JOIN participating_teams pt ON pt.contest_name = tr.id
JOIN teams t ON t.id = pt.teams_playing
ORDER BY tr.tournament_name, t.team_name;


-- 3. Игроки команд, которые участвуют в турнирах
SELECT tr.tournament_name, t.team_name, p.nickname, r.role_name
FROM tournaments tr
JOIN participating_teams pt ON pt.contest_name = tr.id
JOIN teams t ON t.id = pt.teams_playing
JOIN team_members tm ON tm.team_id = t.id
JOIN players p ON p.id = tm.player_id
JOIN roles r ON r.id = tm.role_in_team
ORDER BY tr.tournament_name, t.team_name, p.nickname;


-- 4. Сколько игроков имеют каждую роль?
SELECT r.role_name, COUNT(tm.role_in_team) as roles_count
FROM roles r
JOIN team_members tm ON r.id = tm.role_in_team
GROUP BY r.id, r.role_name
ORDER BY roles_count DESC;


-- 5. В каких командах больше 1 игроков?
SELECT t.team_name, COUNT(tm.player_id) AS players_count
FROM teams t
JOIN team_members tm ON t.id = tm.team_id
GROUP BY t.id, t.team_name
HAVING COUNT(tm.player_id) > 1
ORDER BY players_count DESC;


-- 6. Турниры без команд
SELECT tr.id, tr.tournament_name, tr.start_day, tr.status
FROM tournaments tr
LEFT JOIN participating_teams pt
ON pt.contest_name = tr.id
WHERE pt.contest_name IS NULL
ORDER BY tr.start_day;


-- 7. Игроки с самой популярной ролью во всей лиге
SELECT p.nickname, r.role_name
FROM players p
JOIN team_members tm ON tm.player_id = p.id
JOIN roles r ON r.id = tm.role_in_team
WHERE tm.role_in_team = (
    SELECT tm2.role_in_team
    FROM team_members tm2
    GROUP BY tm2.role_in_team
    ORDER BY COUNT(*) DESC, tm2.role_in_team
    LIMIT 1 )
ORDER BY p.nickname;


-- 8. Команды, участвующие в законченных турнирах (completed)
SELECT tu.tournament_name, t.team_name
FROM participating_teams pt
JOIN teams t ON t.id = pt.teams_playing
JOIN tournaments tu ON tu.id = pt.contest_name
WHERE pt.contest_name IN (
    SELECT tu2.id
    FROM tournaments tu2
    WHERE tu2.status = 'completed'
    )
ORDER BY t.team_name;


-- 9.Команды, в которых количество игроков больше среднего
SELECT t.team_name, COUNT(tm.player_id) AS players_count
FROM teams t
JOIN team_members tm ON tm.team_id = t.id
GROUP BY t.id, t.team_name
HAVING COUNT(tm.player_id) > (
    SELECT AVG(players_count)
    FROM (
        SELECT COUNT(player_id) AS players_count
        FROM team_members
        GROUP BY team_id
    ) AS team_stats
)
ORDER BY players_count DESC;


-- 10. Средняя продолжительность турнира: до и после продления турнира на 10%
BEGIN;

SELECT ROUND (AVG(EXTRACT(EPOCH FROM end_day - start_day)) / 86400, 2 )::numeric AS avg_duration_days
FROM tournaments;

UPDATE tournaments SET end_day = start_day + (end_day - start_day) * 1.1 WHERE end_day > start_day;;

SELECT ROUND (AVG(EXTRACT(EPOCH FROM end_day - start_day)) / 86400, 2 )::numeric AS avg_duration_days
FROM tournaments;

ROLLBACK;


-- 11. Добавление нового турнира
BEGIN;
SELECT * FROM tournaments WHERE tournament_name = 'Rookie Cup 2027';

INSERT INTO tournaments (tournament_name,start_day,end_day,status)
VALUES ('Rookie Cup 2027','2027-02-01 10:00:00+00','2027-02-07 10:00:00+00','planned');

SELECT * FROM tournaments WHERE tournament_name = 'Rookie Cup 2027';


-- 12. Отменили турниры, не набравшие участвующих команд. Количество до и после
BEGIN;
SELECT COUNT(*) AS tournaments_before FROM tournaments;
DELETE FROM tournaments tr WHERE NOT EXISTS (SELECT 1 FROM participating_teams pt WHERE pt.contest_name = tr.id);
SELECT COUNT(*) AS tournaments_after FROM tournaments;
ROLLBACK;



-- CTE и оконные функции
-- 13. Топ-3 команды по количеству турниров в каждом статусе
WITH team_tournament_stats AS (
    SELECT
        tr.status,
        t.team_name,
        COUNT(pt.contest_name) AS tournaments_count
    FROM participating_teams pt
             JOIN teams t ON t.id = pt.teams_playing
             JOIN tournaments tr ON tr.id = pt.contest_name
    GROUP BY tr.status, t.id, t.team_name
),
     ranked_teams AS (
         SELECT
             status,
             team_name,
             tournaments_count,
             ROW_NUMBER() OVER (
            PARTITION BY status
            ORDER BY tournaments_count DESC, team_name
        ) AS team_rank
         FROM team_tournament_stats
     )
SELECT status, team_rank, team_name, tournaments_count
FROM ranked_teams
WHERE team_rank <= 3
ORDER BY status, team_rank;


-- 14. Накопительное количество участников турниров
SELECT tr.tournament_name, tr.start_day, COUNT(pt.teams_playing) AS teams_count,
    SUM( COUNT(pt.teams_playing) ) OVER ( ORDER BY tr.start_day, tr.id
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_teams
FROM tournaments tr
LEFT JOIN participating_teams pt
ON pt.contest_name = tr.id
GROUP BY tr.id, tr.tournament_name, tr.start_day
ORDER BY tr.start_day, tr.id;


-- 15. Помесячная динамика количества турниров с процентом изменения относительно прошлого месяца
WITH monthly_stats AS (
    SELECT date_trunc('month', start_day)::date AS tournament_month, COUNT(*) AS tournaments_count
    FROM tournaments
    GROUP BY date_trunc('month', start_day)
),
     monthly_dynamics AS (
         SELECT tournament_month, tournaments_count, LAG(tournaments_count)
         OVER ( ORDER BY tournament_month ) AS previous_month_count
         FROM monthly_stats
     )
SELECT tournament_month, tournaments_count, previous_month_count,
    ROUND( (tournaments_count - previous_month_count) * 100.0 / NULLIF(previous_month_count, 0), 2
    ) AS change_percent
FROM monthly_dynamics
ORDER BY tournament_month;


-- 16. Календарь турниров
WITH RECURSIVE day_calendar AS (
    SELECT MIN(start_day)::date AS calendar_day, MAX(end_day)::date AS last_day
    FROM tournaments

    UNION ALL

    SELECT (calendar_day + INTERVAL '1 day')::date,last_day
    FROM day_calendar
    WHERE calendar_day < last_day
)
SELECT dc.calendar_day, COUNT(tr.id) AS tournaments_count
FROM day_calendar dc
LEFT JOIN tournaments tr
ON dc.calendar_day BETWEEN tr.start_day::date AND tr.end_day::date
GROUP BY dc.calendar_day
ORDER BY dc.calendar_day;
