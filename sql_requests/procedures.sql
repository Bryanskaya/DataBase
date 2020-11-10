-- Лабораторная работа №3
-- Хранимые процедуры

-- 1) Хранимая процедура без параметров или с параметрами
-- Добавить хохяйство в таблицу хозяйств (название, площадь, максимальное количество секторов подаются)
CREATE OR REPLACE PROCEDURE InsertHuntingGround(gr_name VARCHAR(30), s NUMERIC, max_num_s INTEGER)
AS $$
DECLARE 
	temp_id INTEGER;
BEGIN
	SELECT max(hunting_grounds.id) + 1
	FROM hunting_grounds
	INTO temp_id;
	
	INSERT INTO hunting_grounds VALUES (temp_id, gr_name, s, max_num_s);
	RAISE INFO 'Запись добавлена';
END;
$$
LANGUAGE PLpgSql;

CALL InsertHuntingGround('Test_ground', 5000, 10);

SELECT *
FROM hunting_grounds

-- 2) Рекурсивную хранимую процедуру или хранимую процедур с рекурсивным ОТВ
-- Вывести все секторы, принадлежащие тому же хозяйству, что и сектор под номером, которое подали на вход
DROP TABLE temp_table CASCADE;

CREATE TABLE IF NOT EXISTS temp_table(
	id SERIAL PRIMARY KEY,
	square NUMERIC CONSTRAINT valid_square CHECK (square > 0),
	id_husbandry INTEGER REFERENCES hunting_grounds
);

CREATE OR REPLACE PROCEDURE FindRelatedSectors(t_id INTEGER)
AS $$
BEGIN
	WITH RECURSIVE REC(id, square, id_husbandry) AS
	(
		SELECT id, square, id_husbandry
		FROM sectors
		WHERE id = t_id

		UNION

		SELECT sectors.id, sectors.square, sectors.id_husbandry
		FROM sectors JOIN REC ON sectors.id_husbandry = REC.id_husbandry	
	)

	INSERT INTO temp_table
	SELECT *
	FROM REC;
END;
$$
LANGUAGE PLpgSql;

CALL FindRelatedSectors(5);
SELECT *
FROM temp_table;

-- 3) Хранимая процедура с курсором
-- Изменить зарплату у егерей со стажем работы большем или равным ... (коэффициент и стаж подаётся в процедуру)
DROP TABLE temp_huntsmen;

SELECT *
INTO TEMP temp_huntsmen
FROM huntsmen
ORDER BY id;

CREATE OR REPLACE PROCEDURE ChangeHuntsmenSalary(num NUMERIC, expr INTEGER)
AS $$
DECLARE myCursor CURSOR
	FOR
		SELECT *
		FROM temp_huntsmen
		WHERE experience >= expr;
		param RECORD;
BEGIN
	OPEN myCursor;
	LOOP
		FETCH myCursor INTO param;
		EXIT WHEN NOT FOUND;
		
		UPDATE temp_huntsmen
		SET salary = salary * num
		WHERE temp_huntsmen.id = param.id;
	END LOOP;
	CLOSE myCursor;
END
$$
LANGUAGE PLpgSql;

CALL ChangeHuntsmenSalary(1.05, 30);

SELECT *
FROM temp_huntsmen
ORDER BY id;

-- 4) Хранимая процедура доступа к метаданным
-- Вывести название поля и его размер, название таблицы подаётся в процедуру
CREATE OR REPLACE PROCEDURE ShowSize(name_table varchar)
AS $$
DECLARE myCursor CURSOR
	FOR
		SELECT column_name, size
		from
		(
			select column_name, pg_column_size(cast(column_name as varchar)) as size 
			from information_schema.columns
			where table_name = name_table
		) AS size_info;
		param RECORD;
BEGIN
	OPEN myCursor;
	LOOP
		FETCH myCursor INTO param;
		EXIT WHEN NOT FOUND;
		
		RAISE INFO 'column: %   size: %', param.column_name, param.size;
	END LOOP;
	CLOSE myCursor;
END
$$
LANGUAGE PLpgSql;

CALL ShowSize('hunters');
