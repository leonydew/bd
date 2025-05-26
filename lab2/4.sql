-- 1. Удаление по выбору из одной таблицы (удалить короткие сессии)
DELETE FROM recording_sessions
WHERE id IN (
    SELECT id FROM recording_sessions
    WHERE (end_time - start_time) < INTERVAL '1 hour'
);

-- 2. Удаление с INNER JOIN (удалить композиции продюсера Зайцев)
DELETE FROM compositions
WHERE producer_id IN (
    SELECT p.id 
    FROM producers p
    INNER JOIN compositions c ON p.id = c.producer_id
    WHERE p.last_name = 'Зайцев'
);

-- 3. Удаление с фильтром WHERE (удалить сессии с низкой ставкой)
DELETE FROM recording_sessions
WHERE id IN (
    SELECT id FROM recording_sessions
    WHERE hourly_rate < 1500.00
);

-- 4. Удаление с подзапросом (удалить сотрудников без сессий)
DELETE FROM employees
WHERE id NOT IN (
    SELECT DISTINCT employee_id FROM recording_sessions
);

-- 5. Удаление с комплексным условием (удалить поп-композиции групп)
DELETE FROM compositions
WHERE genre = 'Поп' AND artist_id IN (
    SELECT id FROM artists 
    WHERE is_group = TRUE
);