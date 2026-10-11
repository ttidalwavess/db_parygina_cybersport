-- Лаба 1. Схема базы: таблицы, ключи, ограничения.
-- Скрипты из db/ выполняются по порядку имён при первом docker compose up.
-- Следующие лабы добавляют новые файлы (02_seed.sql, 03_..., 10_views.sql и так далее), этот файл остаётся.
--
-- Пример, замените своими таблицами:

CREATE TABLE roles (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    role_name text NOT NULL UNIQUE
);

CREATE TABLE teams (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    team_name text NOT NULL UNIQUE
);

CREATE TABLE players (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name text NOT NULL,
    second_name text NOT NULL,
    nickname text NOT NULL UNIQUE
);

CREATE TABLE team_members (
    player_id integer NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    role_in_team integer NOT NULL REFERENCES roles(id) ON DELETE RESTRICT,
    team_id integer NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    start_play timestampz NOT NULL,
    end_play timestampz NOT NULL,
    CHECK (start_play < end_play),
    PRIMARY KEY (player_id, role_in_team, team_id, start_play, end_play)
);

CREATE TYPE tournament_status AS ENUM (
    'planned',
    'ongoing',
    'completed',
    'cancelled'
);

CREATE TABLE tournaments (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tournament_name text NOT NULL UNIQUE,
    start_day timestampz NOT NULL,
    end_day timestampz NOT NULL,
    status tournament_status NOT NULL DEFAULT 'planned',
    CHECK (start_day < end_day)
);

CREATE TABLE participating_teams (
    teams_playing integer NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    contest_name integer NOT NULL REFERENCES tournaments(id) ON DELETE CASCADE,
    PRIMARY KEY (teams_playing, contest_name)
);
