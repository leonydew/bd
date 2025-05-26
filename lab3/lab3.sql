-- 1. Выбор всех записей из таблицы сотрудников
SELECT * FROM employees;

-- 2. Выбор 3 самых дорогих сессий записи
SELECT title, hourly_rate 
FROM recording_sessions rs
JOIN compositions c ON rs.artist_id = c.artist_id AND rs.producer_id = c.producer_id
ORDER BY hourly_rate DESC
LIMIT 3;

-- 3. Уникальные жанры композиций
SELECT DISTINCT genre FROM compositions;

-- 4. Количество композиций в каждом жанре
SELECT genre, COUNT(*) as composition_count
FROM compositions
GROUP BY genre
ORDER BY composition_count DESC;

-- 5. Расчет длительности и стоимости сессий
SELECT 
    rs.id,
    c.title,
    (rs.end_time - rs.start_time) as duration,
    EXTRACT(HOUR FROM (rs.end_time - rs.start_time)) * rs.hourly_rate as session_cost,
    CONCAT(e.last_name, ' ', LEFT(e.first_name, 1), '.') as employee_short_name
FROM recording_sessions rs
JOIN compositions c ON rs.artist_id = c.artist_id
JOIN employees e ON rs.employee_id = e.id
ORDER BY session_cost DESC;

-- 6. Анализ имен продюсеров
SELECT 
    id,
    UPPER(last_name) as last_name_upper,
    LOWER(first_name) as first_name_lower,
    LENGTH(CONCAT(last_name, first_name, COALESCE(middle_name, ''))) as name_length,
    CONCAT(last_name, ' ', LEFT(first_name, 1), '. ', COALESCE(middle_name, '')) as full_name
FROM producers;

-- 7. Сессии с информацией о всех участниках (INNER JOIN) 
SELECT 
    rs.id as session_id,
    c.title as composition,
    ar.artist_name,
    CONCAT(p.last_name, ' ', p.first_name) as producer_name,
    CONCAT(e.last_name, ' ', e.first_name) as employee_name,
    rs.start_time,
    rs.end_time
FROM recording_sessions rs
INNER JOIN compositions c ON rs.artist_id = c.artist_id AND rs.producer_id = c.producer_id
INNER JOIN artists ar ON rs.artist_id = ar.id
INNER JOIN producers p ON rs.producer_id = p.id
INNER JOIN employees e ON rs.employee_id = e.id
WHERE rs.hourly_rate > 1800
ORDER BY rs.start_time;

-- 8. Поиск композиций без сессий записи (LEFT JOIN)
SELECT 
    c.id AS composition_id,
    c.title,
    a.artist_name,
    p.last_name AS producer_last_name,
    (SELECT COUNT(*) 
     FROM recording_sessions rs 
     WHERE rs.artist_id = c.artist_id 
     AND rs.producer_id = c.producer_id) AS session_count,
    CASE 
        WHEN NOT EXISTS (
            SELECT 1 FROM recording_sessions rs 
            WHERE rs.artist_id = c.artist_id 
            AND rs.producer_id = c.producer_id
        ) THEN 'Нет сессий'
        ELSE 'Есть сессии'
    END AS session_status
FROM 
    compositions c
JOIN 
    artists a ON c.artist_id = a.id
JOIN 
    producers p ON c.producer_id = p.id
ORDER BY 
    session_count ASC, a.artist_name;

-- 9. Сессии за определенный период с фильтрацией 
SELECT 
    rs.id,
    c.title,
    ar.artist_name,
    rs.start_time,
    rs.end_time,
    rs.hourly_rate
FROM recording_sessions rs
JOIN compositions c ON rs.artist_id = c.artist_id
JOIN artists ar ON rs.artist_id = ar.id
WHERE 
    rs.start_time BETWEEN '2023-01-01' AND '2023-06-30'
    AND (ar.artist_name LIKE '%Кино%' OR c.genre IN ('Рок', 'Рок-н-ролл'))
ORDER BY rs.start_time, rs.hourly_rate DESC;

-- 10. Анализ сотрудников и их сессий 
SELECT 
    e.id,
    CONCAT(e.last_name, ' ', e.first_name) as employee_name,
    COUNT(rs.id) as session_count,
    COALESCE(SUM(EXTRACT(EPOCH FROM (rs.end_time - rs.start_time))/3600 * rs.hourly_rate), 0)::NUMERIC(10,2) as total_earnings
FROM employees e
LEFT JOIN recording_sessions rs ON e.id = rs.employee_id
GROUP BY e.id, employee_name
ORDER BY total_earnings DESC, session_count DESC;

