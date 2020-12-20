-- Задание 1
-- Найти количество сотрудников (от 18 до 40 лет), кто выходил более 3х раз
drop function count_workers
create or replace function count_workers(dt DATE)
returns integer
as $$
begin
	return
	(
		select count(*)
		from workers
		where extract(year from justify_interval(NOW() - brth)) between 18 and 40 and
		(
			select count(*)
			from in_out
			where cur_type = 2 and in_out.id_worker = workers.id_worker and cur_date = dt
		) > 3
	);
end;
$$
language PLpgSql;

select *
from workers

select count_workers('14-12-2018');

-- Задание 2
-- 1. Найти все отделы, в которых более 10 сотрудников
select department
from workers
group by department
having count(id_worker) > 10

-- 2. Найти сотрудников, которые не выходят в течении дня
-- ВАЖНО рабочий день с 9:00 по 17:30
select workers.id_worker, workers.fnp
from
(
	select id_worker, cur_date
	from in_out
	where cur_type = 1 and cur_date = '14-12-2018'
	group by id_worker, cur_date
	having count(*) = 1
) as temp1 join
(
	select id_worker, cur_date
	from in_out
	where cur_type = 2 and cur_time >= '17:30:00'
	group by id_worker, cur_date
	having count(*) = 1
) as temp2 on temp1.id_worker = temp2.id_worker
join workers on temp1.id_worker = workers.id_worker


-- все отделы, где есть сотрудники, опаздавшие в опр дату
select *
from in_out

select department
from
(
	select *
	from
	(
		select *, row_number() over(partition by id_worker, cur_date order by cur_time) as num
		from in_out
		where cur_type = 1
	)as temp_res1
	where temp_res1.cur_time > '09:00:00' and temp_res1.num = 1 and temp_res1.cur_date = '14-12-2018'
)as temp_res2 join workers on temp_res2.id_worker = workers.id_worker
group by department








