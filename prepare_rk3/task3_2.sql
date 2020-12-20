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


-- Вывести все отделы и количество сотрудников хоть раз опоздавших за всю историю учета
select department, count(distinct(workers.id_worker))
from
(
	select *, row_number() over(partition by id_worker, cur_date order by cur_time) as num
	from in_out
	where cur_type = 1
)as temp_res1 join workers on workers.id_worker = temp_res1.id_worker
where cur_time > '09:00:00'
group by department

-- Найти средний возраст сотрудников, не находящихся на рабочем месте 8 часов в день
select temp1.id_worker, temp1.cur_date, temp1.cur_time as time_in, temp2.cur_time as time_out
from
(
	select *, row_number() over(partition by id_worker, cur_date order by cur_time) as num
	from in_out
	where cur_type = 1
) as temp1 join 
(
	select *, row_number() over(partition by id_worker, cur_date order by cur_time) as num
	from in_out
	where cur_type = 2
) as temp2  on temp1.id_worker = temp2.id_worker and temp1.num = temp2.num and temp1.cur_date = temp2.cur_date

