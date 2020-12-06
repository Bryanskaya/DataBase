-- Лабораторная работа №3
-- DML триггеры

-- 1) Триггер AFTER
-- Вывести сообщение, если произошли какие-то изменения в таблице weapon
DROP TRIGGER IF EXISTS myTrigger ON weapon;

CREATE OR REPLACE FUNCTION proc_trigger_update()
RETURNS TRIGGER
AS $$
BEGIN
	RAISE INFO 'Запись в таблице weapon изменена';
	RETURN NULL;
END;
$$
LANGUAGE PLpgSql;

CREATE TRIGGER myTrigger
AFTER UPDATE ON weapon
FOR EACH STATEMENT
EXECUTE PROCEDURE proc_trigger_update();

UPDATE weapon
SET num_barrels = num_barrels
WHERE caliber = '12';


-- 2) Триггер INSTEAD OF (INSERT/UPDATE/DELETE только для view!)
-- Запретить удаление в представлении vouchers_view, и зафиксировать время попытки в отдельной таблице
DROP VIEW IF EXISTS vouchers_view;
DROP TRIGGER IF EXISTS myTrigger ON weapon;
DROP TABLE IF EXISTS try_delete;

CREATE TABLE IF NOT EXISTS try_delete
(
	id SERIAL PRIMARY KEY,
	data_time TIMESTAMP NOT NULL
);

CREATE VIEW vouchers_view 
AS
SELECT *
FROM vouchers;

SELECT *
FROM vouchers_view;


CREATE OR REPLACE FUNCTION proc_trigger_instead_of()
RETURNS TRIGGER
AS $$
BEGIN
	RAISE WARNING 'УДАЛЕНИЕ в таблице vouchers_view ЗАПРЕЩЕНО';
	INSERT INTO try_delete(data_time) 
	VALUES (NOW());
	RETURN NULL;
END;
$$
LANGUAGE PLpgSql;

CREATE TRIGGER myTrigger
INSTEAD OF DELETE ON vouchers_view
FOR EACH ROW
EXECUTE PROCEDURE proc_trigger_instead_of();

DELETE
FROM vouchers_view
where price < 5000;

SELECT *
FROM try_delete
