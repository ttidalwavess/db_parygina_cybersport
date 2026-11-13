-- 1. Проверка статуса турнира перед регистрацией команды
CREATE TRIGGER trg_check_tournament_status
    BEFORE INSERT ON participating_teams
    FOR EACH ROW
    EXECUTE FUNCTION check_tournament_status();

-- 2. Проверка пересечения периодов участия игрока в разных командах
CREATE TRIGGER trg_check_player_team
    BEFORE INSERT ON team_members
    FOR EACH ROW
    EXECUTE FUNCTION check_player_in_team();

-- 3. Автоматическое обновление updated_at
CREATE TRIGGER trg_update_players_timestamp
    BEFORE UPDATE ON players
    FOR EACH ROW
    EXECUTE FUNCTION update_timestamp();