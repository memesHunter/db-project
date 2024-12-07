CREATE VIEW TeamRatings AS
SELECT
    t.TeamId,
    t.TeamName,
    ROUND(AVG(f.Rating), 2) AS AverageRating
FROM
    Teams t
JOIN Feedback f ON t.TeamId = f.TeamId
GROUP BY
    t.TeamId, t.TeamName;

-- Статистика команд
SELECT
    tr.TeamId,
    tr.TeamName,
    COUNT(o.OrderId) AS CompletedOrders,
    tr.AverageRating AS TeamRating
FROM
    TeamRatings tr
LEFT JOIN
    Orders o ON tr.TeamId = o.AssignedTeamId AND o.OrderStatus = 'Completed'
GROUP BY
    tr.TeamId, tr.TeamName, tr.AverageRating
ORDER BY
    CompletedOrders DESC, tr.TeamId;


CREATE OR REPLACE VIEW RequestsAvailableToday AS
SELECT
    r.RequestId,
    r.UserId,
    r.RequestedTime,
    r.RequestedGameId,
    r.RequestedTeamSize
FROM
    Requests r
WHERE
    DATE(r.RequestedTime) = CURRENT_DATE
    AND NOT EXISTS (
        SELECT 1
        FROM Orders o
        WHERE o.RequestId = r.RequestId
    );

-- Свободные заявки на сегодня
select * from RequestsAvailableToday;

-- Открытые обращения для заказов в процессе
SELECT
    st.TicketId,
    st.TicketStatus,
    st.OrderId,
    st.Comment
FROM
    SupportTickets st
JOIN
    Orders o ON st.OrderId = o.OrderId
WHERE
    o.OrderStatus = 'In Progress' AND st.TicketStatus = 'Open';

-- Заявки которые не могут быть назначены ни одной команде
SELECT
    r.RequestId,
    r.UserId,
    r.RequestedTime,
    r.RequestedGameId,
    r.RequestedTeamSize
FROM
    Requests r
WHERE
    r.RequestedTime >= CURRENT_DATE
    AND NOT EXISTS (
        SELECT 1
        FROM Teams t
        WHERE
            r.RequestedTeamSize <= t.TeamSize
            AND r.RequestedTime::time BETWEEN t.TeamHoursStart AND t.TeamHoursEnd
    )
ORDER BY
    r.RequestId;