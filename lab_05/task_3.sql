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
