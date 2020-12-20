DROP FUNCTION IF EXISTS who_late;

CREATE FUNCTION who_late(dt DATE)
RETURNS INTEGER
AS $$
BEGIN
	RETURN 
	(
		SELECT count(*)
		FROM (
			SELECT *,
			row_number() over(partition by id_worker order by cur_time) as num
			from in_out
			where cur_date = dt and cur_type = 1
			) AS temp_res
		where temp_res.cur_time > '09:00:00' and temp_res.num = 1
	);
END;
$$
LANGUAGE PLpgSql;

SELECT who_late('17-12-2020');


select *, EXTRACT(WEEK FROM cur_date) as Week
from in_out

select * 
from in_out

select *
from
	(
	select *,
	row_number() over(partition by id_worker, cur_date order by cur_time) as num,
	EXTRACT(WEEK FROM cur_date) as Week
	from in_out
	where cur_type = 1
	) as temp_res
where temp_res.cur_time > '09:00:00' and temp_res.num = 1
group by id_worker, week

DROP FUNCTION IF EXISTS count_late;

CREATE FUNCTION count_late(pid INTEGER, w INTEGER)
RETURNS INTEGER
AS $$
BEGIN
	RETURN 
	(
		select count(*)
		from
			(
				select *,
				row_number() over(partition by id_worker, cur_date order by cur_time) as num,
				EXTRACT(WEEK FROM cur_date) as week
				from in_out
				where cur_type = 1
			) as temp_res
		where temp_res.cur_time > '09:00:00' and temp_res.num = 1 and temp_res.id_worker = pid and temp_res.week = w
	);
END;
$$
LANGUAGE PLpgSql;

SELECT count_late(2, 52);

-- Вывести все отделы и количество сотрудников хоть раз опоздавших за всю историю учета
select department, count(*)--workers.id_worker, week, count_late, fnp, department
from
(
	SELECT id_worker,
		EXTRACT(WEEK FROM cur_date) as week,
		count_late(id_worker, EXTRACT(WEEK FROM cur_date)::integer)
	from in_out
	group by id_worker, week
) as temp_res join workers on temp_res.id_worker = workers.id_worker
where temp_res.count_late > 0
group by department


-- Найти средний возраст сотрудников, не находящихся на рабочем месте 8 часов в день
select avg(extract (year from(justify_interval(NOW() - brth))))
from
(
	select id_worker, cur_date, sum(res.time_out) - sum(res.time_in) as whole_time
	from 
	(
		select temp1.id_worker, temp1.cur_time as time_in, temp2.cur_time as time_out, temp1.cur_date
		from
		(
			SELECT id_worker, cur_time, cur_date, row_number() over(partition by id_worker, cur_date order by cur_time) as num
			from in_out
			where cur_type = 1
		) as temp1 join 
		(
			SELECT id_worker, cur_time, cur_date, row_number() over(partition by id_worker, cur_date order by cur_time) as num
			from in_out
			where cur_type = 2
		) as temp2 on temp1.id_worker = temp2.id_worker and temp1.num = temp2.num and temp1.cur_date = temp2.cur_date --temp1.cur_time < temp2.cur_time and 
	)as res
	group by id_worker, cur_date
) as get_time join workers on workers.id_worker = get_time.id_worker
where extract (hour from whole_time) < 8


-- Вывести все отделы и количество сотрудников хоть раз опоздавших за всю историю учета
select department, count(distinct(temp_res2.id_worker))
from
(
	select *
	from
		(
		select *,
		row_number() over(partition by id_worker, cur_date order by cur_time) as num
		from in_out
		where cur_type = 1
		) as temp_res1
	where temp_res1.cur_time > '09:00:00' and temp_res1.num = 1
) as temp_res2 join workers on temp_res2.id_worker = workers.id_worker
group by department


--------------------------
select *
from in_out

-- количество сотрудников определенного возраста
create or replace function count_w(dt DATE)
return integer
as $$
begin
	return
	(
		select count(*) as cnt
		from workers
		where EXTRACT(YEAR FROM justify_interval(NOW() - workers.brth)) between 18 and 30 and
		(
			select count(*)
			from in_out
			where cur_date = dt and cur_type = 2 and workers.id_worker = in_out.id_worker
		) > 3
	);
end;
$$
language PLpgSql;

-- где больше n сотрудников
select department
from workers
group by department
having count(*) > 10

select *
from in_out

-- не выходят в течении дня
select *
from 
(
	select id_worker, cur_date
	from in_out
	where cur_type = 1 and cur_date = '14-12-2018'
	group by id_worker, cur_date
	having count(*) = 1
) as res1 join
(
	select id_worker, cur_date
	from in_out
	where cur_type = 2 and cur_time >= '17:30:00'
	group by id_worker, cur_date
	having count(*) = 1
) as res2 on res1.id_worker = res2.id_worker
join workers on workers.id_worker = res3.id_worker



			   
			   
			    


















