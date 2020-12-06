--SELECT + CASE
SELECT CASE 
	WHEN salary < 10000 THEN 'маленькая зарплата'
	WHEN salary < 20000 THEN 'средняя зарплата'
	ELSE 'выше среднего'
	END AS status,
	id,
	department,
	post,
	snp,
	salary
FROM workers;


-- оконная функция
SELECT *, 
	MIN(salary) 
	OVER (PARTITION BY department) AS min_salary
FROM workers

-- GROUP BY + HAVING
SELECT department, AVG(salary) AS "avg salary"
FROM workers
GROUP BY department
HAVING AVG(salary) > 10000
	
-- Создать хранимую процедуру с 2 входными параметрами
-- имя базы данных и имя таблицы, которая выводит сведения
-- об индексах указанной таблицы в указанной бд

CREATE OR REPLACE PROCEDURE show_index(name_base TEXT, name_table TEXT)
AS $$
DECLARE temp_result RECORD;
BEGIN
	FOR temp_result IN
		SELECT indexname
		FROM pg_indexes
		WHERE tablename = name_table
	LOOP
		RAISE NOTICE '%', temp_result;
	END LOOP;
END;
$$
LANGUAGE PLpgSql;

CALL show_index(current_database(), 'departments');


CREATE OR REPLACE FUNCTION show_table1(n VARCHAR(30))
returns table(id INTEGER, department INTEGER, post VARCHAR(20),snp TEXT, salary	NUMERIC)
AS $$
begin
	return QUERY EXECUTE format('SELECT * FROM %I;', n);
end;
$$
language PLpgSql;

SELECT *
FROM show_table1('workers');


-- РЕЗЕРВНЫЕ КОПИИ
CREATE OR REPLACE PROCEDURE var2()
AS $$
DECLARE
	str TEXT;
BEGIN	
	str = format('C:\msys64\home\bryan\DataBase\prepare_2\%s_%s%s%s', current_database(), EXTRACT(YEAR FROM NOW()), EXTRACT(DAY FROM NOW()), EXTRACT(MONTH FROM NOW()));

	EXECUTE format ('COPY (SELECT * FROM pg_shadow) TO ''%s'' ', str);
END;
$$
Language PlpgSql;

call var2();

-- хранимая с входным параметром, выводит имена и описания
-- типов объектов (только хранимых процедур и скалярных 
-- функций)...
CREATE OR REPLACE PROCEDURE show_obj(temp_str TEXT)
AS
$$
DECLARE temp_result RECORD;
BEGIN
	FOR temp_result IN
		SELECT  proname, prosrc
		FROM    pg_catalog.pg_namespace n
				JOIN    pg_catalog.pg_proc p
		ON      pronamespace = n.oid
		WHERE   nspname = 'public' AND
				prosrc ILIKE '%' || temp_str || '%'
	LOOP
		RAISE NOTICE '%', temp_result;
	END LOOP;
END;
$$
Language PlpgSql;

CALL show_obj('EXECUTE');

-- ДУБЛИКАТЫ
CREATE OR REPLACE PROCEDURE DelDuplicates(TName TEXT)
AS $$
DECLARE
    AllCol    TEXT;
BEGIN
    AllCol = (SELECT  string_agg(column_name, ', ')
              FROM information_schema.columns
              WHERE table_name = 'workers' and column_name != 'id');
    EXECUTE format('DELETE FROM %I WHERE (SELECT ROW_NUMBER() OVER (PARTITION BY %s) AS temp FROM %I) != 1', TName, AllCol, TName);
END;
$$ LANGUAGE plpgsql;

CALL DelDuplicates('workers');

SELECT *
FROM workers

