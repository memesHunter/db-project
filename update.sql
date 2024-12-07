-- Проверка на лимит доступных пользователю одновременных обращений в поддержку
CREATE OR REPLACE FUNCTION check_user_tickets_limit()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.TicketStatus = 'Open' THEN
        IF (SELECT COUNT(*) FROM SupportTickets WHERE UserId = NEW.UserId AND TicketStatus = 'Open') > 3 THEN
            RAISE EXCEPTION 'User cannot have more than 3 open tickets.';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_user_tickets_limit_trigger
BEFORE INSERT ON SupportTickets
FOR EACH ROW
EXECUTE FUNCTION check_user_tickets_limit();

-- Команда может иметь только один заказ в процессе.
CREATE OR REPLACE FUNCTION check_order_status()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.OrderStatus = 'In Progress' AND EXISTS (
        SELECT 1 FROM Orders
        WHERE AssignedTeamId = NEW.AssignedTeamId AND OrderStatus = 'In Progress' AND OrderId != NEW.OrderId
    ) THEN
        RAISE EXCEPTION 'A team cannot have more than one order in progress at a time';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER order_status_trigger
BEFORE INSERT OR UPDATE ON Orders
FOR EACH ROW
EXECUTE FUNCTION check_order_status();


-- Назначить заказ с request_id любой подходящей команде и создать запись в Orders
CREATE OR REPLACE FUNCTION assign_request_to_any_team(request_id INTEGER)
RETURNS VOID AS $$
DECLARE
    team_id INTEGER;
BEGIN
    SELECT
        t.TeamId
    INTO
        team_id
    FROM
        Teams t
    WHERE
        (
            SELECT TeamSize
            FROM Teams
            WHERE TeamId = t.TeamId
        ) >= (
            SELECT RequestedTeamSize
            FROM Requests
            WHERE RequestId = request_id
        )
        AND NOT EXISTS (
            SELECT 1
            FROM Orders o
            JOIN Requests r ON o.RequestId = r.RequestId
            WHERE r.RequestedTime BETWEEN (CURRENT_DATE + t.TeamHoursStart) AND (CURRENT_DATE + t.TeamHoursEnd)
            AND o.OrderStatus = 'In Progress'
        )
    LIMIT 1;

    IF team_id IS NOT NULL THEN
        INSERT INTO Orders (RequestId, OrderStatus, AssignedTeamId)
        VALUES (request_id, 'In Progress', team_id);
    ELSE
        RAISE EXCEPTION 'No suitable team found for the request';
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Отметить заказ как выполненный
CREATE OR REPLACE FUNCTION complete_order(order_id INTEGER)
RETURNS VOID AS $$
BEGIN
    UPDATE Orders
    SET OrderStatus = 'Completed'
    WHERE OrderId = order_id;
END;
$$ LANGUAGE plpgsql;

-- Создание, отмена, закрытие обращения в поддержку
CREATE OR REPLACE FUNCTION open_support_ticket(order_id INTEGER, comment VARCHAR(500))
RETURNS VOID AS $$
BEGIN
    INSERT INTO SupportTickets (TicketStatus, OrderId, Comment)
    VALUES ('Open', order_id, comment);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION refute_support_ticket(ticket_id INTEGER)
RETURNS VOID AS $$
BEGIN
    UPDATE SupportTickets SET TicketStatus = 'Refuted' WHERE TicketId = ticket_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION close_support_ticket(ticket_id INTEGER)
RETURNS VOID AS $$
BEGIN
    UPDATE SupportTickets SET TicketStatus = 'Completed' WHERE TicketId = ticket_id;
END;
$$ LANGUAGE plpgsql;
