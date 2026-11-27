-- Окно A: первый SELECT (old value), второй SELECT (тоже old value).
-- Окно B между ними делает UPDATE.

-- [setup]
UPDATE players SET first_name = 'IsolationOld' WHERE id = 1;

-- [A] Окно A: устанавливает REPEATABLE READ и читает
BEGIN ISOLATION LEVEL REPEATABLE READ;
-- expect: value IsolationOld
SELECT first_name FROM players WHERE id = 1;

-- [B] Окно B: меняет значение
BEGIN;
UPDATE players SET first_name = 'IsolationNew' WHERE id = 1;
COMMIT;

-- [A] Окно A: второе чтение — на REPEATABLE READ видит старый снимок
-- expect: value IsolationOld
SELECT first_name FROM players WHERE id = 1;
COMMIT;

-- [cleanup]
UPDATE players SET first_name = 'Alex' WHERE id = 1;