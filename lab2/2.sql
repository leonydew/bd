-- 1. Выбор из одной таблицы (копирование продюсеров в сотрудники)
INSERT INTO employees (last_name, first_name, middle_name)
SELECT last_name, first_name, middle_name FROM producers
WHERE id <= 3;

-- 2. Использование констант (добавление тестовых записей)
INSERT INTO recording_sessions (employee_id, producer_id, artist_id, start_time, end_time, hourly_rate)
SELECT 
    1, 
    1, 
    1, 
    CURRENT_TIMESTAMP, 
    CURRENT_TIMESTAMP + INTERVAL '2 hours', 
    1000.00
FROM artists
WHERE id = 1;

-- 3. Декартово произведение (создание всех возможных комбинаций сотрудников и продюсеров)
INSERT INTO recording_sessions (employee_id, producer_id, artist_id, start_time, end_time, hourly_rate)
SELECT 
    e.id, 
    p.id, 
    1, 
    '2023-06-01 10:00:00', 
    '2023-06-01 12:00:00', 
    1500.00
FROM employees e, producers p
WHERE e.id <= 2 AND p.id <= 2;

-- 4. Выбор из двух таблиц с INNER JOIN (добавление записей для рок-композиций)
INSERT INTO recording_sessions (employee_id, producer_id, artist_id, start_time, end_time, hourly_rate)
SELECT 
    1, 
    c.producer_id, 
    c.artist_id, 
    '2023-07-01 10:00:00', 
    '2023-07-01 14:00:00', 
    2000.00
FROM compositions c
INNER JOIN artists a ON c.artist_id = a.id
WHERE c.genre = 'Рок';

-- 5. С фильтром WHERE (добавление записей для групповых исполнителей)
INSERT INTO recording_sessions (employee_id, producer_id, artist_id, start_time, end_time, hourly_rate)
SELECT 
    e.id, 
    p.id, 
    a.id, 
    '2023-08-01 11:00:00', 
    '2023-08-01 16:00:00', 
    1800.00
FROM employees e, producers p, artists a
WHERE e.id = 1 AND p.id = 1 AND a.is_group = TRUE;