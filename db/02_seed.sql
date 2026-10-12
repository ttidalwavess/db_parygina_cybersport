INSERT INTO roles (role_name) VALUES
    ('carry'),
    ('midlaner'),
    ('offlaner'),
    ('soft support'),
    ('hard_support');



INSERT INTO teams (team_name) VALUES
    ('OG'),
    ('Team Liquid'),
    ('Team Spirit'),
    ('LGD Gaming'),
    ('Virtus.pro'),
    ('Natus Vincere'),
    ('BetBoom Team'),
    ('PARIVISION'),
    ('Xtreme Gaming'),
    ('Team Yandex');



INSERT INTO players (first_name, second_name, nickname) VALUES
    ('Alex', 'Morgan', 'Axiom'),
    ('Daniel', 'Carter', 'Dusk'),
    ('Michael', 'Brooks', 'Vortex'),
    ('Ethan', 'Parker', 'Blaze'),
    ('Oliver', 'Reed', 'Frost'),
    ('Noah', 'Bennett', 'Titan'),
    ('Liam', 'Cooper', 'Echo'),
    ('Lucas', 'Bailey', 'Raven'),
    ('Mason', 'Hayes', 'Phantom'),
    ('James', 'Foster', 'Nova'),
    ('William', 'Gray', 'Storm'),
    ('Benjamin', 'Ward', 'Ghost'),
    ('Henry', 'Price', 'Shadow'),
    ('Jack', 'Kelly', 'Inferno'),
    ('Samuel', 'Ross', 'Venom'),
    ('Logan', 'Wood', 'Falcon'),
    ('Jacob', 'Brooks', 'Cobra'),
    ('Alexander', 'Diaz', 'Orbit'),
    ('Daniel', 'Bell', 'Pixel'),
    ('Matthew', 'Cook', 'Zen');



INSERT INTO team_members
(player_id, role_in_team, team_id, start_play, end_play)
SELECT
    p.id,
    r.id,
    t.id,
    v.start_play::date,
    v.end_play::date
FROM (
         VALUES
             ('Axiom',   'carry',         'OG',            '2024-01-01 10:00:00+00', '2024-07-01 10:00:00+00'),
             ('Dusk',    'midlaner',      'OG',            '2024-01-01 10:00:00+00', '2024-07-01 10:00:00+00'),
             ('Vortex',  'carry',         'Team Liquid',   '2024-02-01 10:00:00+00', '2024-08-01 10:00:00+00'),
             ('Blaze',   'offlaner',      'Team Liquid',   '2024-02-01 10:00:00+00', '2024-08-01 10:00:00+00'),
             ('Frost',   'carry',         'Team Spirit',   '2024-03-01 10:00:00+00', '2024-09-01 10:00:00+00'),
             ('Titan',   'midlaner',      'Team Spirit',   '2024-03-01 10:00:00+00', '2024-09-01 10:00:00+00'),
             ('Echo',    'hard_support',  'LGD Gaming',    '2024-01-15 10:00:00+00', '2024-06-15 10:00:00+00'),
             ('Raven',   'soft support',  'LGD Gaming',    '2024-01-15 10:00:00+00', '2024-06-15 10:00:00+00'),
             ('Phantom', 'carry',         'Virtus.pro',    '2024-04-01 10:00:00+00', '2024-10-01 10:00:00+00'),
             ('Nova',    'midlaner',      'Virtus.pro',    '2024-04-01 10:00:00+00', '2024-10-01 10:00:00+00'),
             ('Storm',   'offlaner',      'Natus Vincere', '2024-02-01 10:00:00+00', '2024-08-01 10:00:00+00'),
             ('Ghost',   'hard_support',  'Natus Vincere', '2024-02-01 10:00:00+00', '2024-08-01 10:00:00+00'),
             ('Shadow',  'carry',         'BetBoom Team',  '2024-05-01 10:00:00+00', '2024-11-01 10:00:00+00'),
             ('Inferno', 'soft support',  'BetBoom Team',  '2024-05-01 10:00:00+00', '2024-11-01 10:00:00+00'),
             ('Venom',   'midlaner',      'PARIVISION',    '2024-03-01 10:00:00+00', '2024-09-01 10:00:00+00'),
             ('Falcon',  'offlaner',      'PARIVISION',    '2024-03-01 10:00:00+00', '2024-09-01 10:00:00+00'),
             ('Cobra',   'carry',         'Xtreme Gaming', '2024-01-01 10:00:00+00', '2024-07-01 10:00:00+00'),
             ('Orbit',   'hard_support',  'Xtreme Gaming', '2024-01-01 10:00:00+00', '2024-07-01 10:00:00+00'),
             ('Pixel',   'midlaner',      'Team Yandex',   '2024-06-01 10:00:00+00', '2024-12-01 10:00:00+00'),
             ('Zen',     'soft support',  'Team Yandex',   '2024-06-01 10:00:00+00', '2024-12-01 10:00:00+00')
     ) AS v(nickname, role_name, team_name, start_play, end_play)
         JOIN players p ON p.nickname = v.nickname
         JOIN roles r ON r.role_name = v.role_name
         JOIN teams t ON t.team_name = v.team_name;



INSERT INTO tournaments (tournament_name, start_day, end_day, status) VALUES
    ('Winter Clash', '2026-01-10 10:00:00+00', '2026-01-15 10:00:00+00', 'completed'),
    ('Spring Championship', '2026-03-01 10:00:00+00', '2026-03-10 10:00:00+00', 'completed'),
    ('Pro League', '2026-07-01 10:00:00+00', '2026-07-15 10:00:00+00', 'ongoing'),
    ('Summer Masters', '2026-08-01 10:00:00+00', '2026-08-10 10:00:00+00', 'completed'),
    ('World Cyber Cup', '2026-12-01 10:00:00+00', '2026-12-15 10:00:00+00', 'planned'),
    ('Autumn Invitational', '2026-09-01 10:00:00+00', '2026-09-07 10:00:00+00', 'completed'),
    ('European Cyber League', '2026-09-15 10:00:00+00', '2026-09-25 10:00:00+00', 'completed'),
    ('Masters of Strategy', '2026-10-01 10:00:00+00', '2026-10-10 10:00:00+00', 'completed'),
    ('Autumn Pro Series', '2026-10-15 10:00:00+00', '2026-10-25 10:00:00+00', 'ongoing'),
    ('Northern Arena Cup', '2026-11-01 10:00:00+00', '2026-11-08 10:00:00+00', 'planned'),
    ('Winter Pro League', '2026-11-15 10:00:00+00', '2026-11-25 10:00:00+00', 'planned'),
    ('New Year Showdown', '2027-01-05 10:00:00+00', '2027-01-12 10:00:00+00', 'planned');


INSERT INTO participating_teams (teams_playing, contest_name)
SELECT t.id, tr.id
FROM ( VALUES
           ('OG', 'Winter Clash'),
           ('Team Liquid', 'Winter Clash'),
           ('Team Spirit', 'Winter Clash'),
           ('LGD Gaming', 'Winter Clash'),
           ('OG', 'Spring Championship'),
           ('Virtus.pro', 'Spring Championship'),
           ('Natus Vincere', 'Spring Championship'),
           ('BetBoom Team', 'Spring Championship'),
           ('Team Liquid', 'Pro League'),
           ('PARIVISION', 'Pro League'),
           ('Xtreme Gaming', 'Pro League'),
           ('Team Yandex', 'Pro League'),
           ('OG', 'Summer Masters'),
           ('Team Spirit', 'Summer Masters'),
           ('BetBoom Team', 'Summer Masters'),
           ('Xtreme Gaming', 'Summer Masters'),
           ('Team Liquid', 'World Cyber Cup'),
           ('Virtus.pro', 'World Cyber Cup'),
           ('PARIVISION', 'World Cyber Cup'),
           ('Team Yandex', 'World Cyber Cup')
     ) AS v(team_name, tournament_name)
         JOIN teams t ON t.team_name = v.team_name
         JOIN tournaments tr ON tr.tournament_name = v.tournament_name;