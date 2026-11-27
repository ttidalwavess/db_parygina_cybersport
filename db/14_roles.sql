\getenv reader_password APP_READER_PASSWORD
\getenv writer_password APP_WRITER_PASSWORD

CREATE ROLE app_reader LOGIN PASSWORD :'reader_password';
CREATE ROLE app_writer LOGIN PASSWORD :'writer_password' IN ROLE app_reader;

REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM PUBLIC;
REVOKE EXECUTE ON ALL ROUTINES IN SCHEMA public FROM PUBLIC;

-- Разрешаем ролям заходить в схему public
GRANT USAGE ON SCHEMA public TO app_reader, app_writer;

-- app_reader: чтение только через представления
GRANT SELECT ON nickname_role, participated_in_tournament, tournament_report TO app_reader;

-- app_writer: бизнес-операции из 11_functions.sql
GRANT EXECUTE ON PROCEDURE add_player_to_team(integer, integer, integer, timestamptz, timestamptz) TO app_writer;
GRANT EXECUTE ON FUNCTION filter_tournaments(tournament_status, integer) TO app_writer;