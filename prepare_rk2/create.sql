/*CREATE DATABASE test1
	WITH
	OWNER = postgres
	ENCODING = 'UTF8';*/
	
DROP TABLE departments CASCADE;
DROP TABLE workers CASCADE;
DROP TABLE mw CASCADE;
DROP TABLE meds CASCADE;

	
CREATE TABLE IF NOT EXISTS meds (
	id		SERIAL PRIMARY KEY,
	name	VARCHAR(20) UNIQUE NOT NULL,
	inst	VARCHAR(100) NOT NULL,
	price	NUMERIC CONSTRAINT valid_price CHECK (price > 0)
);

CREATE TABLE IF NOT EXISTS workers (
	id		SERIAL PRIMARY KEY,
	department	INTEGER NOT NULL,
	post	VARCHAR(20) NOT NULL,
	snp		TEXT NOT NULL,
	salary	NUMERIC NOT NULL
);

CREATE TABLE IF NOT EXISTS mw (
	id_med	INTEGER REFERENCES meds,
	id_worker	INTEGER REFERENCES workers,
	PRIMARY KEY (id_med, id_worker)
);

CREATE TABLE IF NOT EXISTS departments (
	id 		SERIAL PRIMARY KEY,
	name	VARCHAR(20) UNIQUE NOT NULL,
	phone	TEXT NOT NULL,
	head	INTEGER REFERENCES workers
);

INSERT INTO meds(name, inst, price) VALUES ('таблетка1', 'принимать 1 раз в день', 1000);
INSERT INTO meds(name, inst, price) VALUES ('таблетка2', 'принимать 5 раз в день', 570);
INSERT INTO meds(name, inst, price) VALUES ('гематоген', 'после еды', 20);
INSERT INTO meds(name, inst, price) VALUES ('нурофен', 'после еды', 2400);
INSERT INTO meds(name, inst, price) VALUES ('цитромон', 'от головной боли', 200);

INSERT INTO workers(department, post, snp, salary) VALUES (1, 'рабочий', 'Иванов Д.М.', 10000);
INSERT INTO workers(department, post, snp, salary) VALUES (1, 'зам', 'Никитин И.И.', 30000);
INSERT INTO workers(department, post, snp, salary) VALUES (2, 'рабочий', 'Мягкова С.М.', 8700);
INSERT INTO workers(department, post, snp, salary) VALUES (1, 'помощник', 'Рыжиков И.Е.', 18000);
INSERT INTO workers(department, post, snp, salary) VALUES (3, 'главный помощник', 'Лужина А.А.', 20000);
INSERT INTO workers(department, post, snp, salary) VALUES (3, 'главный помощник', 'Лужина А.А.', 20000);

INSERT INTO departments(name, phone, head) VALUES ('Отдел 1', '+79161234578', 1);
INSERT INTO departments(name, phone, head) VALUES ('Отдел 2', '+79100000000', 3);
INSERT INTO departments(name, phone, head) VALUES ('Отдел 3', '+79171225861', 5);

INSERT INTO mw(id_med, id_worker) VALUES (2, 1);
INSERT INTO mw(id_med, id_worker) VALUES (1, 1);
INSERT INTO mw(id_med, id_worker) VALUES (5, 3);
INSERT INTO mw(id_med, id_worker) VALUES (4, 3);
INSERT INTO mw(id_med, id_worker) VALUES (4, 1);

ALTER TABLE workers ADD FOREIGN KEY (department) REFERENCES departments;

SELECT *
FROM meds;

SELECT *
FROM workers;

SELECT *
FROM departments;

SELECT *
FROM mw;
