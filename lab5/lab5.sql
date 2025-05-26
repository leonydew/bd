-- 1. Представление для отчета по сессиям звукозаписи с расчетом стоимости
CREATE OR REPLACE VIEW session_cost_report AS
SELECT 
    rs.id AS session_id,
    a.artist_name,
    CONCAT(p.last_name, ' ', p.first_name) AS producer_name,
    CONCAT(e.last_name, ' ', e.first_name) AS employee_name,
    rs.start_time,
    rs.end_time,
    EXTRACT(HOUR FROM (rs.end_time - rs.start_time)) AS duration_hours,
    rs.hourly_rate,
    EXTRACT(HOUR FROM (rs.end_time - rs.start_time)) * rs.hourly_rate AS total_cost
FROM 
    recording_sessions rs
JOIN 
    artists a ON rs.artist_id = a.id
JOIN 
    producers p ON rs.producer_id = p.id
JOIN 
    employees e ON rs.employee_id = e.id;

-- 2. Представление для каталога композиций с подробной информацией
CREATE OR REPLACE VIEW composition_catalog AS
SELECT 
    c.id AS composition_id,
    c.title,
    c.album,
    c.genre,
    a.artist_name,
    a.is_group,
    CONCAT(p.last_name, ' ', p.first_name) AS producer_name
FROM 
    compositions c
JOIN 
    artists a ON c.artist_id = a.id
JOIN 
    producers p ON c.producer_id = p.id
ORDER BY 
    a.artist_name, c.title;

-- 3. Представление для анализа загруженности сотрудников
CREATE OR REPLACE VIEW employee_workload AS
SELECT 
    e.id AS employee_id,
    CONCAT(e.last_name, ' ', e.first_name) AS employee_name,
    COUNT(rs.id) AS session_count,
    SUM(EXTRACT(HOUR FROM (rs.end_time - rs.start_time))) AS total_hours,
    SUM(EXTRACT(HOUR FROM (rs.end_time - rs.start_time)) * rs.hourly_rate) AS total_earnings
FROM 
    employees e
LEFT JOIN 
    recording_sessions rs ON e.id = rs.employee_id
GROUP BY 
    e.id, e.last_name, e.first_name, rs.hourly_rate
ORDER BY 
    total_hours DESC;

-- 4. Представление для поиска самых популярных жанров
CREATE OR REPLACE VIEW popular_genres AS
SELECT 
    genre,
    COUNT(*) AS composition_count,
    (SELECT COUNT(*) FROM compositions) AS total_compositions,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM compositions), 2) AS percentage
FROM 
    compositions
GROUP BY 
    genre
ORDER BY 
    composition_count DESC;

-- 5. Представление для отображения расписания сессий на текущую неделю
CREATE OR REPLACE VIEW current_week_schedule AS
SELECT 
    rs.id AS session_id,
    a.artist_name,
    CONCAT(p.last_name, ' ', p.first_name) AS producer_name,
    rs.start_time,
    rs.end_time,
    CONCAT(e.last_name, ' ', e.first_name) AS employee_assigned
FROM 
    recording_sessions rs
JOIN 
    artists a ON rs.artist_id = a.id
JOIN 
    producers p ON rs.producer_id = p.id
JOIN 
    employees e ON rs.employee_id = e.id
WHERE 
    rs.start_time BETWEEN date_trunc('week', CURRENT_DATE) AND date_trunc('week', CURRENT_DATE) + INTERVAL '7 days'
ORDER BY 
    rs.start_time;



-- 1. Вывод отчета по сессиям звукозаписи с расчетом стоимости
SELECT * FROM session_cost_report
ORDER BY start_time DESC
LIMIT 10; -- Последние 10 сессий

-- 2. Просмотр каталога композиций с фильтрацией по жанру
SELECT * FROM composition_catalog;

-- 3. Анализ загруженности сотрудников за период
SELECT 
    employee_name,
    session_count,
    total_hours,
    total_earnings
FROM employee_workload
WHERE total_hours > 0  -- Только работавшие сотрудники
ORDER BY total_hours DESC;

-- 4. Отчет по популярности жанров
SELECT 
    genre,
    composition_count,
    percentage || '%' AS market_share  -- Добавляем знак процента
FROM popular_genres
WHERE percentage >= 5.0  -- Только значимые жанры (5% и более)
ORDER BY percentage DESC;

-- 5. Просмотр расписания на текущую неделю с фильтрацией по дате
SELECT 
    session_id,
    artist_name,
    producer_name,
    TO_CHAR(start_time, 'DD.MM.YYYY HH24:MI') AS start_time,
    TO_CHAR(end_time, 'DD.MM.YYYY HH24:MI') AS end_time,
    employee_assigned
FROM current_week_schedule
WHERE start_time::date = CURRENT_DATE  -- Сегодняшние сессии
ORDER BY start_time;
