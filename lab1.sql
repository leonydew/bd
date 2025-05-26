-- Создание таблицы сотрудников студии
CREATE TABLE employees (
    id BIGSERIAL PRIMARY KEY,
    last_name VARCHAR(100) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    middle_name VARCHAR(100)
);

-- Создание таблицы продюсеров
CREATE TABLE producers (
    id BIGSERIAL PRIMARY KEY,
    last_name VARCHAR(100) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    middle_name VARCHAR(100)
);

-- Создание таблицы исполнителей (певцы/группы)
CREATE TABLE artists (
    id BIGSERIAL PRIMARY KEY,
    artist_name VARCHAR(255) NOT NULL,
    is_group BOOLEAN NOT NULL DEFAULT FALSE
);

-- Создание таблицы композиций
CREATE TABLE compositions (
    id BIGSERIAL PRIMARY KEY,
    artist_id BIGINT NOT NULL,
    producer_id BIGINT NOT NULL,
    title VARCHAR(255) NOT NULL,
    album VARCHAR(255),
    genre VARCHAR(100) NOT NULL,
    
    CONSTRAINT fk_artist FOREIGN KEY (artist_id) REFERENCES artists(id),
    CONSTRAINT fk_producer FOREIGN KEY (producer_id) REFERENCES producers(id)
);

-- Создание таблицы записей
CREATE TABLE recording_sessions (
    id BIGSERIAL PRIMARY KEY,
    employee_id BIGINT NOT NULL,
    producer_id BIGINT NOT NULL,
    artist_id BIGINT NOT NULL,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    hourly_rate NUMERIC(10, 2) NOT NULL,
    
    CONSTRAINT fk_employee FOREIGN KEY (employee_id) REFERENCES employees(id),
    CONSTRAINT fk_producer FOREIGN KEY (producer_id) REFERENCES producers(id),
    CONSTRAINT fk_artist FOREIGN KEY (artist_id) REFERENCES artists(id),
    CONSTRAINT valid_time CHECK (end_time > start_time),
    CONSTRAINT positive_rate CHECK (hourly_rate > 0)
);