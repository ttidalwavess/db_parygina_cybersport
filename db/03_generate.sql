INSERT INTO players (first_name, second_name, nickname)
SELECT
    'GeneratedFirst' || n,
    'GeneratedLast' || n,
    'generated_player_' || n
FROM generate_series(1, 1000) AS s(n);

INSERT INTO tournaments (
    tournament_name,
    start_day,
    end_day,
    status
)
SELECT
    'Generated Tournament ' || n,
    TIMESTAMPTZ '2027-01-01 10:00:00+00'
        + (n * INTERVAL '1 day'),
    TIMESTAMPTZ '2027-01-01 10:00:00+00'
        + ((n + 2) * INTERVAL '1 day'),
    CASE n % 4
        WHEN 0 THEN 'planned'::tournament_status
        WHEN 1 THEN 'ongoing'::tournament_status
        WHEN 2 THEN 'completed'::tournament_status
        ELSE 'cancelled'::tournament_status
END
FROM generate_series(1, 1000) AS s(n);



WITH numbered_tournaments AS (
    SELECT
        id,
        ROW_NUMBER() OVER (ORDER BY id) AS rn
    FROM tournaments
    WHERE tournament_name LIKE 'Generated Tournament %'
),
     numbered_teams AS (
         SELECT
             id,
             ROW_NUMBER() OVER (ORDER BY id) AS rn
         FROM teams
     )
INSERT INTO participating_teams (teams_playing, contest_name)
SELECT
    teams.id,
    tournaments.id
FROM numbered_tournaments AS tournaments
         JOIN numbered_teams AS teams
              ON teams.rn = ((tournaments.rn - 1) % (SELECT COUNT(*) FROM numbered_teams)) + 1;