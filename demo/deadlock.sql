-- Взаимоблокировка: A блокирует players(1), B блокирует players(2),
-- затем A пытается взять players(2), B — players(1). Одна из транзакций
-- получит ошибку deadlock detected.

-- [setup] Гарантируем, что строки 1 и 2 существуют
SELECT id FROM players WHERE id IN (1, 2) ORDER BY id;

-- [A] Окно A блокирует строку 1
BEGIN;
SELECT id FROM players WHERE id = 1 FOR UPDATE;

-- [B] Окно B блокирует строку 2
BEGIN;
SELECT id FROM players WHERE id = 2 FOR UPDATE;

-- [A] Окно A пытается взять строку 2 — ждёт B
SELECT id FROM players WHERE id = 2 FOR UPDATE;

-- [B] Окно B пытается взять строку 1 — цикл, база отменяет одну из транзакций
-- expect: error deadlock
SELECT id FROM players WHERE id = 1 FOR UPDATE;

-- [A] и [B]: одна из транзакций уже отменена, вторая ещё жива.
-- COMMIT безопасен для обеих (для отменённой — no-op / ошибка уже получена).
COMMIT;
COMMIT;