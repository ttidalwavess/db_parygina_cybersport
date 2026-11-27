-- Лаба 4. Транзакции, атомарность и доступ.

-- 1. Исходное состояние: тестового игрока нет
-- expect: rows 0
SELECT id, nickname FROM players WHERE nickname = 'Lab4TransactionTest';

-- 2. Транзакция падает на середине (вторая вставка ломает UNIQUE по nickname = Axiom)
-- expect: error unique
BEGIN;
INSERT INTO players (first_name, second_name, nickname)
VALUES ('Transaction', 'Test', 'Lab4TransactionTest');
INSERT INTO players (first_name, second_name, nickname)
VALUES ('Duplicate', 'Test', 'Axiom');
COMMIT;

-- 3. Атомарность: первая вставка тоже откатилась
-- expect: rows 0
SELECT id, nickname FROM players WHERE nickname = 'Lab4TransactionTest';


-- 4. app_reader читает через представление — можно
-- expect: rows 5
SET ROLE app_reader;
SELECT * FROM nickname_role LIMIT 5;
RESET ROLE;

-- 5. app_reader читает таблицу напрямую — нельзя
-- expect: error permission
SET ROLE app_reader;
SELECT * FROM players;
RESET ROLE;

-- 6. app_reader вызывает бизнес-операцию — нельзя
-- expect: error permission
SET ROLE app_reader;
CALL add_player_to_team(
    (SELECT id FROM players WHERE nickname = 'Sentinel'),
    (SELECT id FROM roles WHERE role_name = 'offlaner'),
    (SELECT id FROM teams WHERE team_name = 'OG'),
    '2027-01-01', '2027-04-01'
);
RESET ROLE;


-- 7. app_writer вызывает бизнес-операцию — можно
-- expect: rows 1
BEGIN;
SET LOCAL ROLE app_writer;
CALL add_player_to_team(
    (SELECT id FROM players WHERE nickname = 'Sentinel'),
    (SELECT id FROM roles WHERE role_name = 'offlaner'),
    (SELECT id FROM teams WHERE team_name = 'OG'),
    '2027-01-01', '2027-04-01'
);
SELECT count(*) FROM team_members
WHERE player_id = (SELECT id FROM players WHERE nickname = 'Sentinel')
  AND team_id   = (SELECT id FROM teams WHERE team_name = 'OG');
ROLLBACK;

-- 8. app_writer меняет таблицу напрямую — нельзя
-- expect: error permission
SET ROLE app_writer;
UPDATE players SET first_name = 'Unauthorized' WHERE nickname = 'Axiom';
RESET ROLE;

-- 9. app_writer читает журнал напрямую — нельзя
-- expect: error permission
SET ROLE app_writer;
SELECT * FROM players_audit;
RESET ROLE;


-- 10. Транзакция + ROLLBACK
BEGIN;
INSERT INTO players (first_name, second_name, nickname)
VALUES ('Transaction', 'Test', 'Lab4RollbackTest');
-- expect: rows 1
SELECT COUNT(*) FROM players WHERE nickname = 'Lab4RollbackTest';
ROLLBACK;
-- expect: rows 0
SELECT COUNT(*) FROM players WHERE nickname = 'Lab4RollbackTest';


-- 11. Бизнес-правило: нельзя зарегистрировать команду на завершённый турнир
-- expect: error "Нельзя зарегистрировать команду на завершённый турнир"
INSERT INTO participating_teams (teams_playing, contest_name)
VALUES (
           (SELECT id FROM teams WHERE team_name = 'Team Liquid'),
           (SELECT id FROM tournaments WHERE tournament_name = 'Winter Clash')
       );