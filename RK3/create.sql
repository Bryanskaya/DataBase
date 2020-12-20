drop table workers cascade;
drop table in_out cascade;

create table if not exists workers(
	id_worker 	SERIAL PRIMARY KEY,
	fnp			TEXT,
	brth		DATE,
	department	TEXT
);

create table if not exists in_out(
	id_worker 	INTEGER REFERENCES workers,
	cur_date	DATE,
	cur_day		TEXT,
	cur_time	TIME,
	cur_type	INTEGER
)

insert into workers(fnp, brth, department) values('Иванов Иван Иванович', '25-09-1990', 'ИТ');
insert into workers(fnp, brth, department) values('Петров Петр Петрович', '12-11-1987', 'Бухгалтерия');
insert into workers(fnp, brth, department) values('Мягкова Александра Витальевна', '12-11-1975', 'Бухгалтерия');


insert into in_out(id_worker, cur_date, cur_day, cur_time, cur_type) values(1, '14-12-2018', 'Суббота', '9:00', 1);
insert into in_out(id_worker, cur_date, cur_day, cur_time, cur_type) values(1, '14-12-2018', 'Суббота', '9:20', 2);
insert into in_out(id_worker, cur_date, cur_day, cur_time, cur_type) values(1, '14-12-2018', 'Суббота', '9:25', 1);
insert into in_out(id_worker, cur_date, cur_day, cur_time, cur_type) values(2, '14-12-2018', 'Суббота', '9:05', 1);
insert into in_out(id_worker, cur_date, cur_day, cur_time, cur_type) values(2, '14-12-2018', 'Суббота', '19:05', 2);


select *
from in_out




