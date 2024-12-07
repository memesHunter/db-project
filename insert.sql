INSERT INTO Languages (LanguageName, LanguageCode) VALUES
    ('English', 'EN'),
    ('Spanish', 'ES'),
    ('German', 'DE'),
    ('French', 'FR'),
    ('Italian', 'IT');

INSERT INTO Games (GameName, PlatformName) VALUES
    ('Destiny 2', 'PS4'),
    ('Destiny 2', 'PS5'),
    ('Fortnite', 'XboxOne'),
    ('CS2', 'PC'),
    ('WOW', 'PC'),
    ('Fortnite', 'PS4'),
    ('Overwatch', 'PC');

INSERT INTO Users (UserName, UserLanguageId, UserContactInfo) VALUES
    ('UserTL1', 1, 'user1@example.com'),
    ('UserTL2', 2, 'user2@example.com'),
    ('UserTL3', 1, 'user3@example.com'),
    ('UserTL4', 3, 'user4@example.com'),
    ('UserTL5', 2, 'user5@example.com'),
    ('UserTL6', 1, 'user6@example.com'),
    ('User7', 3, 'user7@example.com'),
    ('User8', 4, 'user8@example.com'),
    ('User9', 2, 'user9@example.com'),
    ('User10', 1, 'user10@example.com'),
    ('User11', 5, 'user11@example.com'),
    ('User12', 3, 'user12@example.com');

INSERT INTO Teams (TeamName, TeamLeaderUserId, TeamHoursStart, TeamHoursEnd, TeamSize) VALUES
    ('Alpha', 1, '09:00:00', '18:00:00', 5),
    ('Bravo', 2, '10:00:00', '17:00:00', 6),
    ('Charlie', 3, '19:00:00', '23:00:00', 2),
    ('Delta', 4, '01:00:00', '08:00:00', 4),
    ('Echo', 5, '12:00:00', '22:00:00', 3),
    ('Foxtrot', 6, '15:00:00', '21:00:00', 5);

INSERT INTO Requests (UserId, RequestedTime, RequestedGameId, RequestedTeamSize) VALUES
    (5, '2024-01-10 12:00:00', 1, 5),
    (6, '2024-01-11 14:00:00', 2, 2),
    (7, '2024-01-12 10:00:00', 4, 4),
    (5, '2024-01-13 08:30:00', 3, 3),
    (3, '2024-01-14 16:00:00', 2, 5),
    (7, '2024-01-15 11:45:00', 5, 4),
    (5, '2024-01-16 19:15:00', 2, 3),
    (6, '2024-01-17 04:30:00', 3, 2),
    (7, '2024-01-19 15:00:00', 4, 4),
    (8, '2024-01-19 20:30:00', 6, 6),
    (9, '2024-01-19 18:45:00', 7, 3),
    (10, '2024-01-21 14:00:00', 5, 2),
    (10, '2024-01-22 09:00:00', 3, 4),
    (11, '2024-01-23 16:30:00', 1, 5);

INSERT INTO Orders (RequestId, OrderStatus, AssignedTeamId) VALUES
    (1, 'In Progress', 1),
    (2, 'Completed', 1),
    (3, 'Cancelled', 3),
    (4, 'In Progress', 4),
    (5, 'Completed', 5),
    (9, 'In Progress', 2);

INSERT INTO Feedback (UserId, TeamId, Rating) VALUES
    (2, 1, 4),
    (1, 2, 5),
    (5, 3, 3),
    (3, 4, 2),
    (4, 5, 4),
    (7, 6, 5),
    (6, 4, 3),
    (8, 5, 4),
    (9, 6, 5);

INSERT INTO SupportTickets (TicketStatus, OrderId, Comment) VALUES
    ('Open', 1, 'Need assistance with the order'),
    ('Open', 2, 'Issue with completed order'),
    ('Completed', 3, 'Question about cancelled order'),
    ('Open', 4, 'Need assistance with the ongoing order'),
    ('Completed', 5, 'Satisfied with the completed order');
