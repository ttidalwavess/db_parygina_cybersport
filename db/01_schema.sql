-- Лаба 1. Схема базы: таблицы, ключи, ограничения.
-- Скрипты из db/ выполняются по порядку имён при первом docker compose up.
-- Следующие лабы добавляют новые файлы (02_seed.sql, 03_..., 10_views.sql и так далее), этот файл остаётся.
--
-- Пример, замените своими таблицами:

CREATE TABLE roles (
    id      integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    role_name text NOT NULL UNIQUE
);

CREATE TABLE teams (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    team_name text NOT NULL UNIQUE
);

CREATE TABLE players (
    id      integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name text NOT NULL,
    second_name text NOT NULL,
    third_name text NOT NULL,
    nickname text NOT NULL UNIQUE
);

CREATE TABLE team_members (
    player_id integer REFERENCES players(id) ON DELETE CASCADE,
    role_in_team integer REFERENCES roles(id),
    team_id integer REFERENCES teams(id),
    start_play date NOT NULL,
    end_play date NOT NULL CHECK (start_play < end_play),
    PRIMARY KEY (player_id, role_in_team, team_id, start_play, end_play)
);

CREATE TABLE tournaments (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tournament_name text NOT NULL UNIQUE,
    start_day date NOT NULL,
    end_day date NOT NULL CHECK (start_day < end_day),
    ongoing boolean DEFAULT false
);

CREATE TABLE participating_teams (
    teams_playing integer REFERENCES teams(id) ON DELETE CASCADE,
    contest_name integer REFERENCES tournaments(id) ON DELETE CASCADE,
    PRIMARY KEY (teams_playing, contest_name)
);