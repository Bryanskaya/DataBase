-- Лабораторная работа 5

-- 1) Из таблиц базы данных, созданной в первой лабораторной работе, извлечь
-- данные в JSON(Postgres). 
-- Скопировать все данные из таблицы егерей (huntsmen)
COPY (SELECT row_to_json(huntsmen)
	  FROM huntsmen)
TO 'C:\msys64\home\bryan\DataBase\lab_05\save_table.json';

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

-- 3) Создать таблицу, в которой будет атрибут(-ы) с типом JSON, или
-- добавить атрибут с типом JSON к уже существующей таблице.
-- Заполнить атрибут правдоподобными данными с помощью команд INSERT
-- или UPDATE. 

-- Создаётся таблица собак
CREATE TEMP TABLE IF NOT EXISTS dogs_json(
	id SERIAL PRIMARY KEY,
	data_json JSONB
);

INSERT INTO dogs_json(data_json) VALUES ('{"name" : "Грей", "breed" : "Пойнтер", "data": { "sex" : "м", "age" : 2, "id_sector" : 15}, "features": "Любит детей"}');
INSERT INTO dogs_json(data_json) VALUES ('{"name" : "Буч", "breed" : "Pетривер", "data": { "sex" : "м", "age" : 1, "id_sector" : 1}}');
INSERT INTO dogs_json(data_json) VALUES ('{"name" : "Дина", "breed" : "Pетривер", "data": { "sex" : "ж", "age" : 7, "id_sector" : 15}, "features": "Агрессивна"}');
INSERT INTO dogs_json(data_json) VALUES ('{"name" : "Бим", "breed" : "Гончая", "data": { "sex" : "м", "age" : 5, "id_sector" : 9}}');
INSERT INTO dogs_json(data_json) VALUES ('{"name" : "Берта", "breed" : "Гончая", "data": { "sex" : "ж", "age" : 1, "id_sector" : 43}}');

-- Исправить кличку собаки с id 3 на Дана
UPDATE dogs_json
SET data_json = data_json || '{"name" : "Дана"}'
WHERE id = 3;

SELECT *
FROM dogs_json;

DROP TABLE dogs_json CASCADE;

-- 4) Выполнить следующие действия:
--    1. Извлечь JSON фрагмент из JSON документа
--	  2. Извлечь значения конкретных атрибутов JSON документа
--	  3. Выполнить проверку существования узла или атрибута
--    4. Изменить JSON документ
--    5. Разделить JSON документ на несколько строк по узлам

-- 4.1. Вывести кличку собаки и её возраст					   
SELECT id, json_extract_path(data_json::JSON, 'name') AS name, json_extract_path(data_json::JSON, 'data', 'age') AS age
FROM dogs_json

-- 4.2. Вывести всех кобелей, возраст которых больше 1 года 
SELECT id, (data_json->>'name') AS DogName, (data_json->'data'->>'age')::int AS age
FROM dogs_json
WHERE (data_json->'data'->>'sex') = 'м' AND (data_json->'data'->>'age')::int > 1;

-- 4.3. Вывести всех собак, у которых есть особые характеристики 
SELECT id, (data_json->>'name') AS DogName, (data_json->>'breed') AS breed, (data_json->>'features') AS features
FROM dogs_json
WHERE data_json::JSONB ? 'features'::TEXT

-- 4.4 Удалить поле особых характеристик у тех, у кого они есть
SELECT *
FROM dogs_json;

UPDATE dogs_json
SET data_json = data_json::JSONB - 'features'::TEXT
WHERE data_json::JSONB ? 'features'::TEXT

SELECT *
FROM dogs_json;

-- 4.5 Разделить поле data_json на ключ/значение
SELECT id, key, value
FROM dogs_json, json_each_text(dogs_json.data_json::JSON)
