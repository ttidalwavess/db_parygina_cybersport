-- [setup]
DROP TABLE IF EXISTS race_demo;
CREATE TABLE race_demo (
                           player_id integer NOT NULL,
                           team_id   integer NOT NULL,
                           joined_at timestamp DEFAULT now()
);

-- [A]
BEGIN;
SELECT count(*) = 0 AS player_is_free FROM race_demo WHERE player_id = 999;

-- [B]
BEGIN;
SELECT count(*) = 0 AS player_is_free FROM race_demo WHERE player_id = 999;

-- [A]
INSERT INTO race_demo (player_id, team_id) VALUES (999, 3);

-- [B]
INSERT INTO race_demo (player_id, team_id) VALUES (999, 1);

-- [A]
COMMIT;

-- [B]
COMMIT;

-- [check]
-- expect: false
SELECT count(*) <= 1 AS player_in_one_team FROM race_demo WHERE player_id = 999;

-- [cleanup]
DROP TABLE IF EXISTS race_demo;