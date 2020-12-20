DROP TABLE workers CASCADE;
DROP TABLE in_out CASCADE;

CREATE TABLE IF NOT EXISTS workers (
	id_worker	SERIAL PRIMARY KEY,
	fnp			TEXT,
	brth		DATE,
	department	TEXT
);

CREATE TABLE IF NOT EXISTS in_out (
	id_worker	INTEGER REFERENCES workers,
	cur_date	DATE,
	cur_day		TEXT,
	cur_time	TIME,
	cur_type	INTEGER
);

INSERT INTO workers(fnp, brth, department) VALUES('Иванов Иван Иванович', '25-09-1990', 'ИТ');
INSERT INTO workers(fnp, brth, department) VALUES('Петров Петр Петрович', '12-11-1987', 'Бухгалтерия');

INSERT INTO in_out(id_worker, cur_date, cur_day, cur_time, cur_type) VALUES(1, '14-12-2018', 'Четверг', '9:00', 1);
INSERT INTO in_out(id_worker, cur_date, cur_day, cur_time, cur_type) VALUES(1, '14-12-2018', 'Четверг', '9:20', 2);
INSERT INTO in_out(id_worker, cur_date, cur_day, cur_time, cur_type) VALUES(1, '14-12-2018', 'Четверг', '9:25', 1);
INSERT INTO in_out(id_worker, cur_date, cur_day, cur_time, cur_type) VALUES(1, '14-12-2018', 'Четверг', '9:45', 2);
INSERT INTO in_out(id_worker, cur_date, cur_day, cur_time, cur_type) VALUES(2, '14-12-2018', 'Четверг', '9:05', 1);
INSERT INTO in_out(id_worker, cur_date, cur_day, cur_time, cur_type) VALUES(2, '14-12-2018', 'Четверг', '19:05', 2);


SELECT * FROM workers;
SELECT * FROM in_out;