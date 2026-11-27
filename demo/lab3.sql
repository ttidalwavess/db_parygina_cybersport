------------------------- ПРЕДСТАВЛЕНИЯ ----------------------

-- Сценарий 1. Представление со списком игроков, команд и ролей
SELECT * FROM nickname_role
ORDER BY team_name, role_name;

-- Сценарий 2. Команды завершённых турниров
SELECT * FROM participated_in_tournament
ORDER BY tournament_name, team_name;

-- expect: error "Нельзя зарегистрировать команду на завершённый турнир"
INSERT INTO participating_teams (teams_playing, contest_name)
VALUES (
    (SELECT id FROM teams WHERE team_name = 'OG'),
    (SELECT id FROM tournaments WHERE tournament_name = 'Winter Clash')
);

-- Сценарий 3. Материализованный отчёт до изменения
SELECT * FROM tournament_report
ORDER BY tournament_id;

-- Добавляем OG к запланированному турниру
INSERT INTO participating_teams (teams_playing, contest_name)
VALUES (
    (SELECT id FROM teams WHERE team_name = 'OG'),
    (SELECT id FROM tournaments WHERE tournament_name = 'World Cyber Cup')
);

-- Обновляем материализованное представление
REFRESH MATERIALIZED VIEW tournament_report;

-- Проверяем обновлённый отчёт
SELECT * FROM tournament_report
ORDER BY tournament_id;


--------------------- ФУНКЦИИ И ПРОЦЕДУРЫ -------------------

-- Сценарий 1. Попытка добавить игрока в другую команду
-- в период, пересекающийся с его текущим контрактом.
-- expect: error "Игрок ... уже состоит в другой команде..."
CALL add_player_to_team(
    (SELECT id FROM players WHERE nickname = 'Axiom'),
    (SELECT id FROM roles WHERE role_name = 'carry'),
    (SELECT id FROM teams WHERE team_name = 'Team Liquid'),
    '2024-05-01',
    '2024-09-01'
);

-- Сценарий 2. Успешное добавление игрока в другую команду
-- после завершения предыдущего контракта
CALL add_player_to_team(
    (SELECT id FROM players WHERE nickname = 'Sentinel'),
    (SELECT id FROM roles WHERE role_name = 'offlaner'),
    (SELECT id FROM teams WHERE team_name = 'OG'),
    '2026-01-01',
    '2026-04-01'
);

-- Сценарий 3. Проверяем updated_at до изменения
SELECT id, nickname, first_name, updated_at
FROM players
WHERE nickname = 'Axiom';

-- Изменяем данные игрока
UPDATE players
SET first_name = 'Alexander'
WHERE nickname = 'Axiom';

-- Проверяем updated_at после изменения
SELECT id, nickname, first_name, updated_at
FROM players
WHERE nickname = 'Axiom';


------------------------- ФИЛЬТРАЦИЯ -------------------------

-- Все турниры
SELECT * FROM filter_tournaments();

-- Только запланированные турниры
SELECT * FROM filter_tournaments('planned');

-- Только завершённые турниры
SELECT * FROM filter_tournaments('completed');

-- Турниры минимум с четырьмя командами
SELECT * FROM filter_tournaments(p_min_teams := 4);

-- Текущие турниры минимум с четырьмя командами
SELECT * FROM filter_tournaments(p_status := 'ongoing', p_min_teams := 4);


---------------------- ЖУРНАЛ ИЗМЕНЕНИЙ ----------------------

-- Проверяем журнал после изменения Axiom
SELECT *
FROM players_audit
WHERE player_id = (SELECT id FROM players WHERE nickname = 'Axiom')
ORDER BY changed_at, id;

-- Демонстрируем INSERT, UPDATE и DELETE на тестовом игроке.
-- При повторном запуске сценария тестовый игрок уже будет удалён.
INSERT INTO players (first_name, second_name, nickname)
VALUES ('Audit', 'Test', 'AuditTestPlayer');

UPDATE players
SET first_name = 'AuditUpdated'
WHERE nickname = 'AuditTestPlayer';

DELETE FROM players
WHERE nickname = 'AuditTestPlayer';

-- Проверяем, что в журнале есть все три типа операций
SELECT
    player_id,
    operation,
    old_data,
    new_data,
    changed_by,
    changed_at
FROM players_audit
WHERE COALESCE(old_data->>'nickname', new_data->>'nickname') = 'AuditTestPlayer'
ORDER BY changed_at, id;

-- Получаем состояние тестового игрока непосредственно перед удалением.
-- После удаления функция должна вернуть NULL.
SELECT player_state_at(
    (
    SELECT player_id
    FROM players_audit
    WHERE COALESCE(old_data->>'nickname', new_data->>'nickname') = 'AuditTestPlayer'
    ORDER BY id LIMIT 1
    ),
    (
    SELECT changed_at - interval '1 microsecond'
    FROM players_audit
    WHERE operation = 'DELETE' AND old_data->>'nickname' = 'AuditTestPlayer'
    ORDER BY id DESC LIMIT 1
)
) AS state_before_delete;

SELECT player_state_at(
    (
    SELECT player_id
    FROM players_audit
    WHERE COALESCE(old_data->>'nickname', new_data->>'nickname') = 'AuditTestPlayer'
    ORDER BY id LIMIT 1
    ),
    clock_timestamp()
) AS state_after_delete;