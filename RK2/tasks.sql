-- 1) SELECT + CASE
-- Вывести статус экскурсий: прошли или еще актуальны на данный момент
SELECT name, decsr,
	CASE WHEN date_close < NOW() THEN 'прошла'
	ELSE 'актуально'
	END AS status
FROM excurs

-- 2) UPDATE + SET
-- Изменить предметную область стендов, связанных с алгеброй на математику
UPDATE stends
SET sub = 'математика'
where sub = 'алгебра';

SELECT *
FROM stends

-- 3) SELECT + GROUP BY + HAVING
-- Вывести все экскурсии, которые были посещены ровно 1 раз
SELECT excurs.name, count(visitors.snp) as cnt
FROM excur_vis JOIN excurs ON excurs.id = excur_vis.id_ex
	JOIN visitors ON visitors.id = excur_vis.id_vis
GROUP BY excurs.name
HAVING COUNT(visitors.snp) = 1


-- 3 задание
CREATE OR REPLACE PROCEDURE delete_not_encode()
AS $$
BEGIN
	SELECT viewname AS name_temp FROM pg_catalog.pg_views 
	WHERE schemaname='public'
	INSERT INTO temp_table
	

END;
$$
Language PLpgSql






