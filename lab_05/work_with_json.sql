-- Лабораторная работа 5

-- 1) Из таблиц базы данных, созданной в первой лабораторной работе, извлечь
-- данные в JSON(Postgres). 
SELECT row_to_json(huntsmen)
FROM huntsmen
WHERE experience >= 10;

-- 2) Выполнить загрузку и сохранение JSON файла в таблицу.
-- Созданная таблица после всех манипуляций должна соответствовать таблице
-- базы данных, созданной в первой лабораторной работе.

COPY (SELECT row_to_json(huntsmen)
	  FROM huntsmen
	  WHERE experience >= 10)
TO 'C:\msys64\home\bryan\DataBase\lab_05\save_table.json';

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

--
SELECT *
FROM huntsmen
WHERE experience >= 10
--

-- 3) Создать таблицу, в которой будет атрибут(-ы) с типом JSON, или
-- добавить атрибут с типом JSON к уже существующей таблице.
-- Заполнить атрибут правдоподобными данными с помощью команд INSERT
-- или UPDATE. 
CREATE TEMP TABLE IF NOT EXISTS dogs_json(
	id SERIAL PRIMARY KEY,
	data_json JSONB
);

INSERT INTO dogs_json(data_json) VALUES ('{"name" : "Грей", "breed" : "Пойнтер", "age" : 2, "id_sector" : 15}');
INSERT INTO dogs_json(data_json) VALUES ('{"name" : "Буч", "breed" : "Pетривер", "age" : 1, "id_sector" : 1}');
INSERT INTO dogs_json(data_json) VALUES ('{"name" : "Дерик", "breed" : "Pетривер", "age" : 7, "id_sector" : 15}');
INSERT INTO dogs_json(data_json) VALUES ('{"name" : "Бим", "breed" : "Гончая", "age" : 5, "id_sector" : 9}');
INSERT INTO dogs_json(data_json) VALUES ('{"name" : "Лайд", "breed" : "Гончая", "age" : 1, "id_sector" : 43}');


UPDATE dogs_json
SET data_json = data_json || '{"age" : 8}'::JSONB
WHERE id = 3;

SELECT *
FROM dogs_json;

DROP TABLE dogs_json CASCADE;

-- 4) Выполнить следующие действия:
--    1. Извлечь JSON фрагмент из JSON документа //иерархичный атрибут : другой json
--	  2. Извлечь значения конкретных атрибутов JSON документа
--	  3. Выполнить проверку существования узла или атрибута
--    4. Изменить JSON документ
--    5. Разделить JSON документ на несколько строк по узлам


