-- Лабораторная работа №3
-- Функции

-- 1) Скалярная функция
-- Средняя цена по всем путёвкам
DROP FUNCTION IF EXISTS AvgPrice;
CREATE FUNCTION AvgPrice()
RETURNS NUMERIC
AS $$
BEGIN
	RETURN 
	(
		SELECT ROUND(AVG(price), 3)
		FROM vouchers
	);
END;
$$
LANGUAGE PLpgSql;

SELECT AvgPrice();


-- 2) Подставляемая табличная функция
-- Вывести информацию по всем охотникам, у которых есть путёвка на конкретное животное
DROP TYPE table_vh;
CREATE TYPE table_vh AS
(
	voucher_id 		INTEGER, 
	surname 		VARCHAR(30), 
	firstname 		VARCHAR(30), 
	patronymic 		VARCHAR(30), 
	ticket_num 		INTEGER, 
	date_of_birth 	DATE, 
	license_num_gun VARCHAR(15), 
	phone 			VARCHAR(30), 
	email 			VARCHAR(40)
);

CREATE OR REPLACE FUNCTION ShowHunterByAnimal(animal_type VARCHAR(30))
/*RETURNS TABLE(voucher_id INTEGER, surname VARCHAR(30), firstname VARCHAR(30), 
			  patronymic VARCHAR(30), ticket_num INTEGER, date_of_birth date, 
			  license_num_gun VARCHAR(15), phone VARCHAR(30), email VARCHAR(40)) --//другой абстрактый тип
*/
RETURNS SETOF table_vh
AS $$
BEGIN
	RETURN QUERY
	(
		SELECT vouchers.id,
			   hunters.surname, 
			   hunters.firstname, 
			   hunters.patronymic, 
			   hunters.ticket_num, 
			   hunters.date_of_birth, 
			   hunters.license_num_gun, 
			   hunters.mobile_phone, 
			   hunters.email
		FROM hunters JOIN vouchers ON hunters.ticket_num = vouchers.id_hunter
		WHERE animal = animal_type
	);
END;
$$
LANGUAGE PLpgSql;

SELECT *
FROM ShowHunterByAnimal('лиса');


-- 3) Многооператорная табличная функция
-- Сформировать строку, в которой за охотником (id охотника и сектора подаются в функцию)
-- закрепляется путёвка на самого популярного животного (продолжительность и разрешенное количество подаются).
-- Стоимость такой путёвки берётся как средняя среди путёвок на такой вид животного
DROP TYPE result_vchr;
CREATE TYPE result_vchr AS
(
	added_id 	INTEGER, 
	animal 		VARCHAR(30), 
	days 		INTEGER, 
	amount		INTEGER, 
	price 		NUMERIC, 
	id_sct 		INTEGER, 
	id_hnt 		INTEGER
);

DROP TABLE temp_table CASCADE;

CREATE OR REPLACE FUNCTION AddVoucher(id_sect INTEGER, id_h INTEGER, d INTEGER, num INTEGER)
/*RETURNS TABLE(added_id INTEGER, animal VARCHAR(30), days INTEGER, 
			  amount INTEGER, price NUMERIC, id_sct INTEGER, id_hnt INTEGER)
*/
RETURNS SETOF result_vchr
AS $$
DECLARE 
	temp_id INTEGER;
	temp_days INTEGER;
	temp_max INTEGER;
	temp_animal VARCHAR(30);
	temp_amount INTEGER;
	temp_price NUMERIC;
BEGIN
	CREATE TEMPORARY TABLE temp_table(added_id INTEGER, animal VARCHAR(30), days INTEGER, 
									  amount INTEGER, price NUMERIC, id_sct INTEGER, id_hnt INTEGER);
	
	SELECT max(vouchers.id) + 1
	FROM vouchers
	INTO temp_id;
	
	SELECT MAX(cnt)
	FROM
	(
		SELECT vouchers.animal, count(vouchers.animal) AS cnt
		FROM vouchers
		GROUP BY vouchers.animal
	) AS temp_table_1
	INTO temp_max;
	
	SELECT temp_table_2.animal
	FROM
	(
		SELECT vouchers.animal, count(vouchers.animal) AS cnt
		FROM vouchers
		GROUP BY vouchers.animal
	) AS temp_table_2
	WHERE cnt = temp_max
	INTO temp_animal;
	
	temp_days = d;
	temp_amount = num;
	
	SELECT ROUND(AVG(vouchers.price), 3)
	FROM vouchers
	WHERE vouchers.animal = temp_animal
	GROUP BY vouchers.animal
	INTO temp_price;
	
	INSERT INTO temp_table
	VALUES (temp_id, temp_animal, temp_days, temp_amount, temp_price, id_sect, id_h);
	
	RETURN QUERY 
	(
		SELECT *
		FROM temp_table
	);
END;
$$
LANGUAGE PLpgSql;

SELECT *
FROM AddVoucher(20, 74758791, 2, 1);


-- 4) Рекурсивную функцию или функцию с рекурсивным ОТВ
-- Вывести все секторы, принадлежащие тому же хозяйству, что и сектор под номером, которое подали на вход функции
CREATE OR REPLACE FUNCTION FindRelatedSector(sect_id INTEGER, temp_id INT) --//рекурсию сделать
RETURNS TABLE(sector_id INTEGER, sector_square NUMERIC, id_hsb INTEGER)
AS $$
BEGIN
	IF (temp_id <= (SELECT COUNT(*) FROM sectors)) THEN
		RETURN QUERY
			(
				SELECT sectors.id, sectors.square, sectors.id_husbandry
				FROM sectors JOIN 
				(
					SELECT *
					FROM sectors
					WHERE sectors.id = sect_id
				) AS input_sect
				ON sectors.id_husbandry = input_sect.id_husbandry
				WHERE sectors.id = temp_id

				UNION 

				SELECT *
				FROM FindRelatedSector(sect_id, temp_id + 1)
		);
		END IF;
END;
$$
LANGUAGE PLpgSql;

SELECT *
FROM FindRelatedSector(2, 1);
--


CREATE OR REPLACE FUNCTION FindRelatedSector(t_id INTEGER)
RETURNS TABLE(sector_id INTEGER, sector_square NUMERIC, id_hsb INTEGER)
AS $$
BEGIN
	RETURN QUERY
		(
			WITH RECURSIVE REC(id, square, id_husbandry) AS
			(
				SELECT id, square, id_husbandry
				FROM sectors
				WHERE id = t_id

				UNION

				SELECT sectors.id, sectors.square, sectors.id_husbandry
				FROM sectors JOIN REC ON sectors.id_husbandry = REC.id_husbandry	
			)
			
			SELECT *
			FROM REC
		);
END;
$$
LANGUAGE PLpgSql;

SELECT *
FROM FindRelatedSector(2);
