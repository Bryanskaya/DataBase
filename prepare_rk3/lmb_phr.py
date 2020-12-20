from peewee import *

db = PostgresqlDatabase('prep3', user='postgres', password='bdwdcb8y',
                           host='localhost')


class workers(Model):
    id_worker = AutoField(column_name='id_worker', primary_key=True)
    fnp = TextField(column_name='fnp')
    brth = DateTimeField(column_name='brth')
    department = TextField(column_name='department')

    class Meta:
        table_name = 'workers'
        database = db

class in_out(Model):
    id_worker = ForeignKeyField(workers, column_name='id_worker')
    cur_date = DateTimeField(column_name='cur_date')
    cur_day = TextField(column_name='cur_day')
    cur_time = TimeField(column_name='cur_time')
    cur_type = TextField(column_name='cur_type')

    class Meta:
        table_name = 'in_out'
        database = db


# Вывести все отделы и количество сотрудников хоть раз опоздавших за всю историю учета
def task_3():
    '''res = (in_out.select(workers.id_worker, in_out.cur_type, workers.fnp)\
           .join(workers, on=workers.id_worker == in_out.id_worker))'''

    num = SQL('id_worker')
    cur_date = SQL('cur_date')
    cur_time = SQL('cur_time')
    cur_date = SQL('cur_date')
    cur_type = SQL('cur_type')
    num = SQL('num')

    temp_res = (workers
                .select(workers.department, fn.count(SQL('id_worker1').distinct()).alias('cnt'))\
                .from_(in_out
                     .select(SQL('id_worker1'), SQL('cur_date'), SQL('cur_time'), SQL('cur_date'), SQL('cur_type'), SQL('num'))\
                     .from_(in_out
                            .select(in_out.id_worker.alias('id_worker1'), in_out.cur_date.alias('cur_date'), in_out.cur_time.alias('cur_time'),
                                    in_out.cur_type.alias('cur_type'),
                                    fn.RANK().over(partition_by=[in_out.id_worker, in_out.cur_date],
                                                          order_by=[in_out.cur_time]).alias('num'))\
                       .where(in_out.cur_type == 1))\
                     .where(SQL('cur_time') > '09:00:00')\
                     .where(SQL('num') == 1))
                .join(workers, on=workers.id_worker == SQL('id_worker1'))\
                .group_by(workers.department))

    print(temp_res)
    for row in temp_res:
        print(row.department, row.cnt)

# Найти средний возраст сотрудников, не находящихся на рабочем месте 8 часов в день
def task_2():
    temp = (in_out
            .select(in_out.id_worker, in_out.cur_date, in_out.cur_time.alias('time_out'),
                    in_out.cur_type,
                    fn.RANK().over(partition_by=[in_out.id_worker, in_out.cur_date],
                                   order_by=[in_out.cur_time]).alias('num'))\
            .where(SQL('cur_type') == 2).alias('res2'))

    temp_res = (in_out
                .select(workers.id_worker)\
                .from_(in_out
                .select(SQL('res1.id_worker'), SQL('res1.cur_date'), (fn.SUM(SQL('time_out')) - fn.SUM(SQL('time_in'))).alias('hours'))\
                .from_(in_out
                        .select(in_out.id_worker, in_out.cur_date, in_out.cur_time.alias('time_in'),
                                in_out.cur_type,
                                fn.RANK().over(partition_by=[in_out.id_worker, in_out.cur_date],
                                               order_by=[in_out.cur_time]).alias('num'))\
                        .where(SQL('cur_type') == 1).alias('res1'))
                .join(temp, on=SQL('res1.id_worker') == SQL('res2.id_worker') and SQL('res1.num') == SQL('res2.num') and SQL('res1.cur_date') == SQL('res2.cur_date'))\
                .group_by(SQL('res1.id_worker'), SQL('res1.cur_date')))\
                .join(workers, on=SQL('res1.id_worker') == workers.id_worker)\
                .where(SQL('hours') < 8))

    print(temp_res)
    for row in temp_res:
        print(row.id_worker)



def task_1_2():
    res = (workers
           .select(workers.department)\
           .group_by(workers.department)\
           .having(fn.COUNT(workers.id_worker) > 10))

    for row in res:
        print(row.department)


def task_2_2(dt):
    temp_1 = (in_out
              .select(in_out.id_worker, in_out.cur_date)\
              .where(in_out.cur_type == 1)\
              .where(in_out.cur_date == dt)\
              .group_by(in_out.id_worker, in_out.cur_date)\
              .having(fn.COUNT(in_out.id_worker) == 1).alias('res1'))

    temp_2 = (in_out
              .select(in_out.id_worker, in_out.cur_date) \
              .where(in_out.cur_type == 2) \
              .where(in_out.cur_time >= '17:30:00') \
              .group_by(in_out.id_worker, in_out.cur_date) \
              .having(fn.COUNT(in_out.id_worker) == 1).alias('res2'))

    res = (workers
           .select(workers.fnp)\
           .join(temp_1, on=workers.id_worker == SQL('res1.id_worker'))\
           .join(temp_2, on=workers.id_worker == SQL('res2.id_worker')))

    for row in res:
        print(row.fnp)



#task_2()
#task_3()

#task_1_2()
task_2_2('14-12-2018')






