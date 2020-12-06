CREATE EXTENSION plpython3u;

-- 1) Определяемая пользователем скалярняя функция CLR
-- Посчитать количество ружей у охотников определённой марки
CREATE OR REPLACE FUNCTION CountWeapon(temp_brand VARCHAR(30))
RETURNS integer
AS $$
  num = 0
  for wpn in plpy.execute("SELECT * FROM weapon"):
    if wpn["brand"] == temp_brand:
      num += 1
  return num
$$
LANGUAGE plpython3u;

SELECT CountWeapon('МР-233')


-- 2) Пользовательскую агрегатную функцию CLR
-- Средняя цена по всем путёвкам
DROP FUNCTION AvgPrice();
CREATE OR REPLACE FUNCTION AvgPrice()
RETURNS float
AS $$
  temp_avg = 0
  num = 0
  for voucher in plpy.execute("SELECT * FROM vouchers"):
    temp_avg += voucher["price"]
    num += 1

  if num != 0:
    temp_avg = temp_avg / num
  else:
    temp_avg = None
	
  return temp_avg
$$
LANGUAGE plpython3u;

SELECT AvgPrice();


-- 3) Определяемую пользователем табличную функцию CLR
-- Вывести все хозяйства, площадь которых находится в отрезке [s1, s2]
DROP TYPE result_grounds CASCADE;
CREATE TYPE result_grounds AS
(
	id 					INTEGER, 
	ground_name 		VARCHAR(30), 
	square 				NUMERIC,
	max_num_sectors		INTEGER
);

CREATE OR REPLACE FUNCTION ShowGrounds(s1 NUMERIC, s2 NUMERIC)
RETURNS SETOF result_grounds
AS $$
  temp_res = []
  
  for ground in plpy.execute("SELECT * FROM hunting_grounds"):
    if s1 <= ground["square"] <= s2:
      temp_res.append(ground)
  
  return temp_res
$$ LANGUAGE plpython3u;

SELECT * FROM ShowGrounds(1000, 3000);


-- 4) Хранимую процедуру CLR
-- Добавить хозяйство в таблицу хозяйств (название, площадь, максимальное количество секторов подаются)
CREATE OR REPLACE PROCEDURE AddHuntingGround(gr_name VARCHAR(30), s NUMERIC, max_num_s INTEGER)
AS $$
  temp_t = plpy.prepare("INSERT INTO hunting_grounds(ground_name, square, max_num_sectors) \
						 VALUES ($1, $2, $3);", \
						 ["VARCHAR(30)", "NUMERIC", "INTEGER"])
  plpy.execute(temp_t, [gr_name, s, max_num_s])
  plpy.info('Запись добавлена')
$$ LANGUAGE plpython3u;

CALL AddHuntingGround('Test_ground', 5000, 10);

SELECT *
FROM hunting_grounds


-- 5) Триггер CLR
-- Запретить удаление в представлении vouchers_view, и зафиксировать время попытки в отдельной таблице
DROP TABLE try_delete CASCADE;
CREATE TABLE IF NOT EXISTS try_delete
(
	data_time   TIMESTAMP NOT NULL,
	id_voucher	INTEGER,
	price 		NUMERIC,
	id_sector	INTEGER,
	id_hunter	INTEGER
);

DROP VIEW vouchers_view;
CREATE VIEW vouchers_view 
AS
SELECT *
FROM vouchers;

SELECT *
FROM vouchers_view;


CREATE OR REPLACE FUNCTION proc_trigger_instead_of()
RETURNS TRIGGER
AS $$
  from datetime import datetime
  temp_t = plpy.prepare("INSERT INTO try_delete(data_time, id_voucher, price, id_sector, id_hunter) \
						 VALUES ($1, $2, $3, $4, $5);", \
						 ["TIMESTAMP", "INTEGER", "NUMERIC", "INTEGER", "INTEGER"])
  temp_data = TD['old']
  plpy.execute(temp_t, [datetime.now().strftime('%Y-%m-%d %H:%M:%S'), 
						temp_data["id"], 
						temp_data["price"], 
						temp_data["id_sector"], 
						temp_data["id_hunter"]])
  plpy.warning('УДАЛЕНИЕ в таблице vouchers_view ЗАПРЕЩЕНО')
  
  return TD['new']
$$
LANGUAGE plpython3u;


CREATE TRIGGER myTrigger
INSTEAD OF DELETE ON vouchers_view
FOR EACH ROW
EXECUTE PROCEDURE proc_trigger_instead_of();

DELETE
FROM vouchers_view
where price < 5000;

SELECT *
FROM try_delete

-- 6) Определяемый пользователем тип данных CLR
-- Вывести информацию по всем охотникам, у которых есть путёвка на конкретное животное
DROP TYPE result_hunters CASCADE;
CREATE TYPE result_hunters AS
(
	ticket_num 		INTEGER, 
	surname 		VARCHAR(30), 
	firstname		VARCHAR(30),
	patronymic		VARCHAR(30),
	mobile_phone 	VARCHAR(30),
	email 			VARCHAR(40),
	id_voucher 		INTEGER,
	id_sector		INTEGER
);

CREATE OR REPLACE FUNCTION ShowHuntersByAnimal(kind VARCHAR(30))
RETURNS SETOF result_hunters
AS $$
  temp_res = []
  
  for hunter in plpy.execute("SELECT hunters.ticket_num, \
							         hunters.surname, \
							 		 hunters.firstname, \
							 		 hunters.patronymic, \
							 		 hunters.mobile_phone, \
							 		 hunters.email, \
							 		 vouchers.id AS id_voucher, \
							 		 vouchers.animal, \
							 		 vouchers.id_sector \
							 FROM vouchers JOIN hunters ON vouchers.id_hunter = hunters.ticket_num"):
    if hunter["animal"] == kind:
      temp_res.append((hunter["ticket_num"], 
					   hunter["surname"], 
					   hunter["firstname"], 
					   hunter["patronymic"], 
					   hunter["mobile_phone"], 
					   hunter["email"], 
					   hunter["id_voucher"], 
					   hunter["id_sector"]))
  
  return temp_res
$$ LANGUAGE plpython3u;

SELECT * FROM ShowHuntersByAnimal('лиса');

-- создать таблицу
-- 1 из атрибутов - мой тип
-- insert
-- select * 
-- select один из атрибутов из этого типа

CREATE TYPE my_type AS
(
	sex		CHAR,
	age		INTEGER,
	score	NUMERIC
);

DROP TABLE dogs;
CREATE TABLE dogs 
(
	nickname	VARCHAR(10),
	item		my_type,
	price		NUMERIC
);

INSERT INTO dogs VALUES ('Грей', ('м', 1, 5.7), 2500);
INSERT INTO dogs VALUES ('Буч', ('м', 1, 3.2), 1500);
INSERT INTO dogs VALUES ('Эмма', ('ж', 7, 8.99), 1500);
INSERT INTO dogs VALUES ('Бим', ('м', 5, 7.58), 1500);

SELECT *
FROM dogs

SELECT (item).age
FROM dogs
WHERE nickname = 'Бим';


