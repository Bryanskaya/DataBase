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
