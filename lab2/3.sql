-- 1. Обновление по выбору из одной таблицы (увеличить ставку для длительных сессий)
UPDATE recording_sessions
SET hourly_rate = hourly_rate * 1.1
WHERE id IN (
    SELECT id FROM recording_sessions 
    WHERE (end_time - start_time) > INTERVAL '3 hours'
);

-- 2. Обновление с INNER JOIN (изменить жанр для композиций продюсера Лукашенко)
UPDATE compositions
SET genre = 'Рок-н-ролл'
WHERE producer_id IN (
    SELECT p.id 
    FROM producers p
    INNER JOIN compositions c ON p.id = c.producer_id
    WHERE p.last_name = 'Лукашенко'
);

-- 3. Обновление с фильтром WHERE (добавить отчество NULL сотрудникам без отчества)
UPDATE employees
SET middle_name = 'Не указано'
WHERE id IN (
    SELECT id FROM employees 
    WHERE middle_name IS NULL
);

-- 4. Обновление с подзапросом (увеличить ставку для сессий с дорогими продюсерами)
UPDATE recording_sessions
SET hourly_rate = hourly_rate * 1.15
WHERE producer_id IN (
    SELECT id FROM producers
    WHERE last_name IN ('Лукашенко', 'Зайцев', 'Волкова')
);

-- 5. Обновление с комплексным условием (изменить альбом для композиций группы Little Big)
UPDATE compositions
SET album = 'NEW ALBUM'
WHERE artist_id IN (
    SELECT id FROM artists 
    WHERE artist_name = 'Little Big' AND is_group = TRUE
);