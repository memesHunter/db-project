CREATE TYPE order_status AS ENUM (
    'In Progress', -- заказ выполняется
    'Completed', -- заказ выполнен
    'Cancelled' -- заказ выполнялся, но не был закончен
);

CREATE TYPE ticket_status AS ENUM (
    'Open',
    'Completed',
    'Refuted'
);

CREATE TABLE Languages (
    LanguageId INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    LanguageName VARCHAR(60) NOT NULL,
    LanguageCode VARCHAR(2) NOT NULL
);

CREATE TABLE Games (
    GameId INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    GameName VARCHAR(60) NOT NULL,
    PlatformName VARCHAR(60) NOT NULL
);

CREATE TABLE Users (
    UserId INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    UserName VARCHAR(60) NOT NULL,
    UserLanguageId INTEGER NOT NULL,
    UserContactInfo VARCHAR(500),
    FOREIGN KEY (UserLanguageId) REFERENCES Languages(LanguageId)
);

CREATE TABLE Teams (
    TeamId INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    TeamName VARCHAR(60) NOT NULL,
    TeamLeaderUserId INTEGER NOT NULL,
    TeamHoursStart TIME,
    TeamHoursEnd TIME,
    TeamSize SMALLINT NOT NULL,
    FOREIGN KEY (TeamLeaderUserId) REFERENCES Users(UserId)
);

CREATE TABLE Requests (
    RequestId INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    UserId INTEGER NOT NULL,
    RequestedTime TIMESTAMP,
    RequestedGameId INTEGER NOT NULL,
    RequestedTeamSize SMALLINT NOT NULL,
    FOREIGN KEY (UserId) REFERENCES Users(UserId),
    FOREIGN KEY (RequestedGameId) REFERENCES Games(GameId)
);

CREATE OR REPLACE FUNCTION not_team_assigned_to_leader_request(team_id INTEGER, request_id INTEGER)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN NOT EXISTS (
        SELECT 1
        FROM Teams t
        JOIN Requests r ON t.TeamLeaderUserId = r.UserId
        WHERE t.TeamId = team_id AND r.RequestId = request_id
    );
END;
$$ LANGUAGE plpgsql;

CREATE TABLE Orders (
    OrderId INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    RequestId INTEGER UNIQUE,
    OrderStatus order_status,
    AssignedTeamId INTEGER,
    FOREIGN KEY (RequestId) REFERENCES Requests(RequestId),
    FOREIGN KEY (AssignedTeamId) REFERENCES Teams(TeamId),
    CONSTRAINT orders_check CHECK (not_team_assigned_to_leader_request(AssignedTeamId, RequestId))
);

CREATE OR REPLACE FUNCTION not_team_leader(user_id INTEGER, team_id INTEGER)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN NOT EXISTS (
        SELECT 1
        FROM Teams t
        WHERE t.TeamId = team_id AND t.TeamLeaderUserId = user_id
    );
END;
$$ LANGUAGE plpgsql;

CREATE TABLE Feedback (
    UserId INTEGER NOT NULL,
    TeamId INTEGER NOT NULL,
    Rating INTEGER CHECK (Rating >= 1 AND Rating <= 5),
    PRIMARY KEY (UserId, TeamId),
    FOREIGN KEY (UserId) REFERENCES Users(UserId),
    FOREIGN KEY (TeamId) REFERENCES Teams(TeamId),
    CONSTRAINT feedback_check CHECK (not_team_leader(UserId, TeamId))
);

CREATE TABLE SupportTickets (
    TicketId INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    TicketStatus ticket_status,
    OrderId INTEGER,
    Comment VARCHAR(500),
    FOREIGN KEY (OrderId) REFERENCES Orders(OrderId)
);

-- https://www.postgresql.org/docs/current/indexes-unique.html
-- PostgreSQL automatically creates a unique index when a unique constraint or primary key is defined for a table.
-- The index covers the columns that make up the primary key or unique constraint
-- (a multicolumn index, if appropriate), and is the mechanism that enforces the constraint.

-- Создаются индексы вида
-- "X_pkey" PRIMARY KEY, btree (userid)
-- где X название таблицы

-- Быстрее находим команты по лидеру
CREATE INDEX idx_teams_leader_user_id ON Teams (TeamLeaderUserId);

-- Быстрее находим заявки по пользователю
CREATE INDEX idx_requests_user_id ON Requests (UserId);
-- Быстрее находим заявки для данных игр
CREATE INDEX idx_requests_game_id ON Requests (RequestedGameId);

-- Быстрее находим заказы данной команды
CREATE INDEX idx_orders_assigned_team_id ON Orders (AssignedTeamId);

-- Быстро находим отзывы о данной команде
CREATE INDEX idx_feedback_team_id ON Feedback (TeamId);

-- Быстрее находим обращения по данному заказу
CREATE INDEX idx_support_tickets_order_id ON SupportTickets (OrderId);
