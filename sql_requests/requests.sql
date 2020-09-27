--1. Инструкция SELECT, использующая предикат сравнения
--Получить все хозяйства, площадь которых больше, чем 2000
SELECT *
FROM hunting_grounds
WHERE square > 2000;

--2. Инстукция SELECT, использующая предикат BETWEEN
--Получить всех охотников 1974 года рождения
SELECT *
FROM hunters
WHERE date_of_birth BETWEEN '1974-01-01' AND '1974-12-31';

--3. Инстукция SELECT, использующая предикат LIKE
--Получить фамилии охотников, владеющих маркой оружия, начинающаяся с "МР-18М", и вывести тип ружья
SELECT hunters.surname, 
	   brand, 
	   type_weapon
FROM weapon JOIN hunter_weapon ON weapon.id = hunter_weapon.id_weapon
			JOIN hunters ON id_hunter = hunters.ticket_num
WHERE brand LIKE 'МР-18М%';

--4. Инстукция SELECT, использующая предикат IN с вложенным подзапросом
--Получить ФИО охотников, которым разрешено охотиться в секторе 8
SELECT surname, 
	   firstname, 
	   patronymic
FROM hunters
WHERE hunters.ticket_num IN
	(
		SELECT vouchers.id_hunter
		FROM vouchers
		WHERE vouchers.id_sector = 8
	);
	
--5. Инстукция SELECT, использующая предикат EXISTS с вложенным подзапросом
--Получить информацию об охотниках, у которых нет путёвок
SELECT *
FROM hunters AS hnt
WHERE EXISTS
	(
		SELECT hunters.ticket_num, hunters.surname, hunters.firstname, hunters.patronymic
		FROM hunters LEFT OUTER JOIN vouchers 
		ON vouchers.id_hunter = hunters.ticket_num
		WHERE vouchers.id_hunter IS NULL AND hunters.ticket_num = hnt.ticket_num
	);
	
--6. Инстукция SELECT, использующая предикат сравнения с квантором
--Получить информацию о егерях, которые получают зарплату выше, чем егери со стажем, большим, чем 45
SELECT huntsmen.surname, 
	   huntsmen.firstname, 
	   huntsmen.patronymic, 
	   experience, 
	   salary
FROM huntsmen
WHERE salary > ALL
	(
		SELECT salary
		FROM huntsmen
		WHERE experience > 45
	);
	
--7. Инстукция SELECT, использующая агрегатные функции в выражениях столбцов
--Получить информацию о наименьшей, наибольшей и средней площади секторов каждого из хозяйств
SELECT hunting_grounds.ground_name, 
	   MIN(sectors.square) AS "Min square", 
	   MAX(sectors.square) AS "Max square",
	   ROUND(AVG(sectors.square), 3) AS "Average square"
FROM sectors JOIN hunting_grounds ON sectors.id_husbandry = hunting_grounds.id
GROUP BY hunting_grounds.ground_name;

--8. Инстукция SELECT, использующая скалярные подзапросы в выражениях столбцов
--Получить информацию об количестве взятых путёвок каждым охотником
SELECT hunters.surname||' '||hunters.firstname||' '||hunters.patronymic AS "Hunter",
	(
		SELECT COUNT(vouchers.id_hunter)
		FROM vouchers
		WHERE vouchers.id_hunter = hunters.ticket_num
	)AS "Num of vouchers"
FROM hunters
ORDER BY hunters.surname;

--9. Инстукция SELECT, использующая простое выражение CASE
--Получить информацию об разрешенных/запрещённых путёвках
WITH Birds (kinds) AS (
	VALUES ('утка'), ('гусь'), ('тетерев'), ('рябчик'), ('бекас'),
	('глухарь'), ('перепел'), ('куропатка'), ('вальдшнеп'), ('кряква'),
	('чернеть'), ('чирки')
	)
	
SELECT vouchers.id AS "num of voucher", 
	   animal,
	   CASE 
	   	   WHEN animal IN (SELECT * FROM Birds) THEN 'Разрешена'
		   ELSE 'Запрещена'
	   END AS "status"
FROM vouchers;

--10. Инструкция SELECT, использующая поисковое выражение CASE
--Получить информацию об опыте работы каждого из егерей
SELECT surname, 
	   firstname, 
	   patronymic,
	   CASE
		   WHEN experience < 10 THEN 'Новичок'
		   WHEN experience < 20 THEN 'Средний опыт работы'
		   WHEN experience < 30 THEN 'Опытный'
		   ELSE 'Профессионал'
	   END AS "level",
	   experience
FROM huntsmen
ORDER BY surname;

--11. Создание новой временной локальной таблицы из результирующего набора данных инструкции SELECT
--Получение информации о прибыли с продажи путёвок на каждый из видов животных и их количестве 
DROP TABLE income CASCADE;
SELECT animal,
	SUM(price) AS "income",
	SUM(amount_animals) AS "number"
INTO income
FROM vouchers
GROUP BY animal;

--12. Инструкция SELECT, использующая вложенные коррелированные подзапросы в качестве производных
--таблиц в предложении FROM
--Получение информации о том, кто зарегистрирован в текущих хозяйствах и вывести их статус (охотник/егерь)
--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1

SELECT ground_name AS "area", 
	   person_id, 
	   surname, 
	   firstname, 
	   patronymic, 
	   date_of_birth, 
	   sex, 
	   mobile_phone, 
	   email, 
	   'егерь' AS status
FROM hunting_grounds JOIN
	(
		SELECT huntsmen.id AS "person_id", 
			   id_husbandry, 
			   surname, 
			   firstname, 
		       patronymic, 
			   date_of_birth, 
			   sex, 
			   mobile_phone, 
			   email
		FROM sectors JOIN huntsmen ON sectors.id = huntsmen.id AND
	)AS NH ON hunting_grounds.id = NH.id_husbandry
UNION
SELECT ground_name AS "area", 
	   id_hunter AS person_id, 
	   surname, 
	   firstname, 
	   patronymic, 
	   date_of_birth, 
	   sex, 
	   mobile_phone, 
	   email, 
	   'охотник' AS status
FROM hunters JOIN
	(
		SELECT id_hunter, ground_name
		FROM vouchers JOIN sectors ON vouchers.id_sector = sectors.id JOIN hunting_grounds ON id_husbandry = hunting_grounds.id
	)AS NT ON hunters.ticket_num = NT.id_hunter
ORDER BY area;

--13. Инструкция SELECT, использующая вложенные подзапросы с уровнем вложенности 3
--Получить информацию об охотниках, у которых есть путёвка на охоту в Курской области
SELECT * 
FROM hunters
WHERE hunters.ticket_num IN
	(
		SELECT id_hunter
		FROM vouchers
		WHERE id_sector IN 
			(
				SELECT sectors.id
				FROM sectors
				WHERE id_husbandry =
					(
						SELECT hunting_grounds.id
						FROM hunting_grounds
						WHERE hunting_grounds.ground_name = 'Курская обл.'
					)
			)
	)
ORDER BY surname;

--14. Инструкция SELECT, консолидирующая данные с помощью предложения GROUP BY,
--но без предложения HAVING
--Получить среднюю цену за путевки для каждого вида
SELECT animal,
	   ROUND(AVG(price), 3) AS "average_price"
FROM vouchers
GROUP BY animal;

--15. Инструкция SELECT, консолидирующая данные с помощью предложения GROUP BY
--и предложения HAVING
--Получить путёвки, средняя цена которых выше средней
SELECT animal, ROUND(AVG(price), 3) AS "average price"
FROM vouchers
GROUP BY animal
HAVING AVG(price) >
	(
		SELECT AVG(price)
		FROM vouchers
	);
	
--16. Однострочная инструкция INSERT, выполняющая вставку в таблицу одной
--строки значений.
--Вставка строки в конец таблицы
INSERT INTO weapon(brand, type_weapon, num_barrels, caliber)
VALUES ('AA-50', 'гладкоствольное', 3, 12);

--17. Многострочная инструкция INSERT, выполняющая вставку в таблицу результирующего
--набора данных вложенного подзапроса.
--Добавить охотнику с номером 74758791 бонусную путёвку на лося к каждой из уже имеющихся путёвок
INSERT INTO vouchers(animal, duration_days, amount_animals, price, id_sector, id_hunter)
SELECT 'лось',
	   3,
	   1,
	   (
			SELECT ROUND(AVG(price),3)
			FROM vouchers
	   ),
	   id_sector,
	   id_hunter
FROM vouchers
WHERE id_hunter = 74758791;

--18. Простая инструкция UPDATE
--Увеличить цену на путёвки, если их уникальный номер >= 1000
UPDATE vouchers
SET price = price * 2.5
WHERE id >= 1000;

--19. Инстукция UPDATE со скалярным подзапросом в предложении SET.
--Изменить стоимость путёвки с номером 1200 на значение в 3 раза больше средней 
UPDATE vouchers
SET price = 
	(
		SELECT ROUND(AVG(price)) * 3
		FROM vouchers
	)
WHERE id = 1200

--20. Простая инструкция DELETE
--Удалить все ружья, марка которых начинается с "АА"
DELETE FROM weapon
WHERE brand LIKE 'AA%';

--21. Инструкция DELETE с вложенным коррелированным подзапросом в предложении WHERE
--Удалить записи о путёвках, выписанных охотникам без закреплённого за ними ружья
DELETE FROM vouchers
WHERE id_hunter IN
	(
		SELECT ticket_num
		FROM hunters LEFT JOIN hunter_weapon ON hunters.ticket_num = hunter_weapon.id_hunter
		WHERE id_weapon IS NULL AND vouchers.id_hunter = hunters.ticket_num
	);
	
--22. Инструкция SELECT, использующая простое обобщённое табличное выражение
--Вывести полную информацию об охотниках, у которых более 2 путёвок на различных животных.
WITH hunter_vouchers (hunter, cnt) AS
(
	SELECT id_hunter, COUNT(distinct animal)
	FROM vouchers
	GROUP BY id_hunter
)
SELECT *
FROM hunter_vouchers HV JOIN hunters H on HV.hunter = H.ticket_num
WHERE HV.cnt > 2;

--23. Инструкция SELECT, использующая рекурсивное обобщённое табличное выражение
--
WITH RECURSIVE REC(id, square, id_husbandry) AS
(
	SELECT id, square, id_husbandry
	FROM sectors
	WHERE id = 1 OR id = 2
	
	UNION
	
	SELECT sectors.id, sectors.square, sectors.id_husbandry
	FROM sectors JOIN REC ON sectors.id_husbandry = REC.id_husbandry	
)
SELECT *
FROM REC;

--24. Оконные функции. Использование конструкций MIN/MAX/AVG OVER()
--
SELECT animal,
	   ground_name,
	   price,
	   ROUND(AVG(price) OVER(PARTITION BY animal), 3) AS average_price,
	   MAX(price) OVER(PARTITION BY animal) AS max_price,
	   MIN(price) OVER(PARTITION BY animal) AS min_price
FROM vouchers AS V JOIN sectors AS S ON V.id_sector = S.id 
			  JOIN hunting_grounds AS HG ON HG.id = S.id_husbandry



















/*SELECT id_hunter, surname, firstname, patronymic, mobile_phone, max_price
FROM hunters H JOIN
	(
		SELECT vouchers.id_hunter, MAX(price) AS max_price
		FROM vouchers
		GROUP BY vouchers.id_hunter
	.)AS MV ON MV.id_hunter = H.ticket_num
ORDER BY max_price DESC*/

	