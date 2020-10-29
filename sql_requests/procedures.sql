-- Лабораторная работа №3
-- Хранимые процедуры

-- 1) Хранимая процедура без параметров или с параметрами
CREATE OR REPLACE PROCEDURE InsertHuntingGround(gr_name VARCHAR(30), s NUMERIC, max_num_s INTEGER)
AS $$
DECLARE 
	temp_id INTEGER;
BEGIN
	SELECT max(hunting_grounds.id) + 1
	FROM hunting_grounds
	INTO temp_id;
	
	--INSERT INTO hunting_grounds VALUES (temp_id, gr_name, s, max_num_s);
	RAISE INFO 'Запись добавлена';
END;
$$
LANGUAGE PLpgSql;

CALL InsertHuntingGround('Test_ground', 5000, 10)
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
-- 4) Хранимая процедура доступа к метаданным