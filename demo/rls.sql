-- ★★ Проверка Row Level Security на players.

-- [A] Под app_user_1 видна только своя строка
-- expect: rows 1
SET ROLE app_user_1;
SELECT id, nickname FROM players;
RESET ROLE;

-- [B] Под app_user_1 чужая строка не видна
-- expect: rows 0
SET ROLE app_user_1;
SELECT id, nickname FROM players WHERE nickname = 'Axiom';
RESET ROLE;

-- [C] Под postgres (владелец/суперюзер) видны все строки — политика не мешает
-- expect: value true
SELECT
    (SELECT count(*) FROM players) >
    (SELECT count(*) FROM players WHERE nickname = 'app_user_1') AS superuser_sees_more;