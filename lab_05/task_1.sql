-- 1) Из таблиц базы данных, созданной в первой лабораторной работе, извлечь
-- данные в JSON(Postgres). 
-- Скопировать все данные из таблицы егерей (huntsmen)
COPY (SELECT row_to_json(huntsmen)
	  FROM huntsmen)
TO 'C:\msys64\home\bryan\DataBase\lab_05\save_table.json';