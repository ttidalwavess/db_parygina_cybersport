-- Окно A: первый SELECT (old value), затем второй SELECT (new value).
-- Окно B между ними делает UPDATE.

-- [setup] Приводим игрока к известному значению
UPDATE players SET first_name = 'IsolationOld' WHERE id = 1;

-- [A] Окно A: устанавливает READ COMMITTED и читает
BEGIN ISOLATION LEVEL READ COMMITTED;
-- expect: value IsolationOld
SELECT first_name FROM players WHERE id = 1;

-- [B] Окно B: меняет значение
BEGIN;
UPDATE players SET first_name = 'IsolationNew' WHERE id = 1;
COMMIT;

-- [A] Окно A: второе чтение — на READ COMMITTED видит новое значение
-- expect: value IsolationNew
SELECT first_name FROM players WHERE id = 1;
COMMIT;

-- [cleanup]
UPDATE players SET first_name = 'Alex' WHERE id = 1;