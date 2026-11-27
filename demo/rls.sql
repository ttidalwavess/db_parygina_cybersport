-- ★★ Проверка Row Level Security на players.
-- Под app_user_1 видна только «своя» строка (nickname = current_user).
-- Под postgres (владелец / superuser) видны все строки.

-- [A] Под app_user_1 видна только своя строка
-- expect: rows 1
SET ROLE app_user_1;
SELECT id, nickname FROM players;
RESET ROLE;

-- [A] Под app_user_1 конкретно своя строка видна
-- expect: rows 1
SET ROLE app_user_1;
SELECT id, nickname FROM players WHERE nickname = 'app_user_1';
RESET ROLE;

-- [B] Под app_user_1 чужая строка не видна
-- expect: rows 0
SET ROLE app_user_1;
SELECT id, nickname FROM players WHERE nickname = 'Axiom';
RESET ROLE;

-- [C] Под postgres (владелец / superuser) видны все строки, политика не мешает
-- expect: rows 50
SELECT count(*) FROM players;