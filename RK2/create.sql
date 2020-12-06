-- Вариант 4

/*CREATE DATABASE RK2
	WITH
	OWNER = postgres
	ENCODING = 'UTF8';*/
	
DROP TABLE excur_vis CASCADE;
	
CREATE TABLE IF NOT EXISTS stends
(
	id 		SERIAL PRIMARY KEY,
	name	TEXT,
	sub		TEXT,
	info	TEXT
);

CREATE TABLE IF NOT EXISTS excurs
(
	id 			SERIAL PRIMARY KEY,
	name		TEXT,
	decsr		TEXT,
	date_open	DATE,
	date_close	DATE
);

CREATE TABLE IF NOT EXISTS visitors
(
	id 			SERIAL PRIMARY KEY,
	snp			TEXT,
	address		TEXT,
	phone 		TEXT
);

CREATE TABLE IF NOT EXISTS excur_st
(
	id_st 		INTEGER REFERENCES stends,
	id_ex 		INTEGER REFERENCES excurs,
	PRIMARY KEY (id_st, id_ex)
);

CREATE TABLE IF NOT EXISTS excur_vis
(
	id_vis 		INTEGER REFERENCES stends,
	id_ex 		INTEGER REFERENCES excurs,
	PRIMARY KEY (id_vis, id_ex)
);

INSERT INTO stends(name, sub, info) VALUES('Стенд 1', 'физика', 'опыт');
INSERT INTO stends(name, sub, info) VALUES('Стенд 2', 'алгебра', 'открытие');
INSERT INTO stends(name, sub, info) VALUES('Стенд 3', 'исскуство', 'случайно произошло');
INSERT INTO stends(name, sub, info) VALUES('Стенд 4', 'наука', 'долгая история');
INSERT INTO stends(name, sub, info) VALUES('Стенд 5', 'алгебра', 'автор не известен');
INSERT INTO stends(name, sub, info) VALUES('Стенд 6', 'техника', 'опыт');
INSERT INTO stends(name, sub, info) VALUES('Стенд 7', 'техника', 'тайна истории');
INSERT INTO stends(name, sub, info) VALUES('Стенд 8', 'алгебра', 'ничего хорошего');
INSERT INTO stends(name, sub, info) VALUES('Стенд 9', 'техника', 'долго рассказывать');
INSERT INTO stends(name, sub, info) VALUES('Стенд 10', 'физика', 'опыт');


INSERT INTO excurs(name, decsr, date_open, date_close) VALUES('Экск 101', 'очень интересно', '10-10-2020', '15-10-2020');
INSERT INTO excurs(name, decsr, date_open, date_close) VALUES('Экск 102', 'долго ждали', '22-12-2020', '10-09-2021');
INSERT INTO excurs(name, decsr, date_open, date_close) VALUES('Экск 103', 'очень популярная', '01-01-2020', '15-01-2020');
INSERT INTO excurs(name, decsr, date_open, date_close) VALUES('Экск 104', 'очень популярная', '08-03-2020', '15-10-2021');
INSERT INTO excurs(name, decsr, date_open, date_close) VALUES('Экск 105', 'очень популярная', '10-10-2020', '15-10-2020');
INSERT INTO excurs(name, decsr, date_open, date_close) VALUES('Экск 106', 'для детей', '10-05-2020', '25-05-2021');
INSERT INTO excurs(name, decsr, date_open, date_close) VALUES('Экск 107', 'для старших классов', '03-12-2020', '05-12-2020');


INSERT INTO visitors(snp, address, phone) VALUES('Иванов А.А.', 'Москва', '+79162367588');
INSERT INTO visitors(snp, address, phone) VALUES('Жилина С.П.', 'Звенигород', '+79000000000');
INSERT INTO visitors(snp, address, phone) VALUES('Мухин В.В.', 'Москва', '+79152223658');
INSERT INTO visitors(snp, address, phone) VALUES('Никитина Е.В.', 'Ногинск', '+79120147852');

INSERT INTO excur_st(id_st, id_ex) VALUES(1, 1);
INSERT INTO excur_st(id_st, id_ex) VALUES(1, 7);
INSERT INTO excur_st(id_st, id_ex) VALUES(5, 1);
INSERT INTO excur_st(id_st, id_ex) VALUES(7, 2);
INSERT INTO excur_st(id_st, id_ex) VALUES(7, 3);

INSERT INTO excur_vis(id_vis, id_ex) VALUES(1, 2);
INSERT INTO excur_vis(id_vis, id_ex) VALUES(1, 1);
INSERT INTO excur_vis(id_vis, id_ex) VALUES(1, 4);
INSERT INTO excur_vis(id_vis, id_ex) VALUES(2, 5);
INSERT INTO excur_vis(id_vis, id_ex) VALUES(4, 5);


SELECT *
FROM excur_vis


SELECT *
FROM excurs

