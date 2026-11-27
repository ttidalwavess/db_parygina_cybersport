-- ★★ Row Level Security: пользователь видит только свои строки.
-- Владелец таблицы (postgres) и суперпользователь политику не замечают.

DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'app_user_1') THEN
CREATE ROLE app_user_1 NOLOGIN;
END IF;
END
$$;

GRANT USAGE ON SCHEMA public TO app_user_1;
GRANT SELECT ON players TO app_user_1;

-- Тестовый игрок, чей nickname совпадает с именем роли
INSERT INTO players (first_name, second_name, nickname)
VALUES ('RLS', 'Owner', 'app_user_1')
    ON CONFLICT (nickname) DO NOTHING;

ALTER TABLE players ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS players_own_rows ON players;
CREATE POLICY players_own_rows ON players
    FOR SELECT
                        USING (nickname = current_user);