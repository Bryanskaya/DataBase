-- 2) Выполнить загрузку и сохранение JSON файла в таблицу.
-- Созданная таблица после всех манипуляций должна соответствовать таблице
-- базы данных, созданной в первой лабораторной работе.

-- Данные берутся из файла, созданного в задании №1
DROP TABLE table_json;
CREATE TABLE table_json (doc json);
COPY table_json FROM 'C:\msys64\home\bryan\DataBase\lab_05\save_table.json';

DROP TABLE table_from_json CASCADE;
CREATE TABLE IF NOT EXISTS table_from_json(
	id INTEGER PRIMARY KEY,
	surname VARCHAR(30) NOT NULL,
	firstname VARCHAR(30) NOT NULL,
	patronymic VARCHAR(30),
	date_of_birth date NOT NULL,
	sex CHAR NOT NULL,
	experience INTEGER CONSTRAINT valid_experience CHECK (experience >= 0),
	mobile_phone VARCHAR(30) NOT NULL,
	email VARCHAR(40) NOT NULL,
	salary NUMERIC CONSTRAINT valid_salary CHECK (salary > 0)
);

INSERT INTO table_from_json(id, surname, firstname, 
					   patronymic, date_of_birth, sex, 
					   experience, mobile_phone, email,
					   salary) 
SELECT test.*
FROM table_json, json_populate_record(null::huntsmen, doc) AS test;

SELECT *
FROM table_from_json;

SELECT *
FROM table_json;

--
SELECT *
FROM huntsmen;
--