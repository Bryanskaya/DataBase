from peewee import *

db = PostgresqlDatabase('rk3', user='postgres', password='bdwdcb8y',
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


def task_1_2():
    res = (workers
           .select(workers.department)\
           .group_by(workers.department)\
           .having(fn.COUNT(workers.id_worker) > 10))

    for row in res:
        print(row.department)

def task_2_2(dt):
    temp1 = (in_out
             .select(in_out.id_worker, in_out.cur_date)\
             .where(in_out.cur_type == 1)\
             .where(in_out.cur_date == dt)\
             .group_by(in_out.id_worker, in_out.cur_date)\
             .having(fn.COUNT(in_out.id_worker) == 1).alias('res1'))

    temp2 = (in_out
             .select(in_out.id_worker, in_out.cur_date) \
             .where(in_out.cur_type == 2) \
             .where(in_out.cur_time >= '17:30:00') \
             .group_by(in_out.id_worker, in_out.cur_date) \
             .having(fn.COUNT(in_out.id_worker) == 1).alias('res2'))


    res = (workers
           .select(workers.fnp)\
           .join(temp1, on=workers.id_worker == SQL('res1.id_worker'))\
           .join(temp2, on=workers.id_worker == SQL('res2.id_worker')))

    for row in res:
        print(row.fnp)

def task_3_2(dt):
    res = (workers
           .select(workers.department)\
           .from_(in_out
                   .select(SQL('id_worker1'), SQL('cur_date'), SQL('cur_time'), SQL('cur_date'), SQL('cur_type'), SQL('num'))\
                   .from_(in_out
                           .select(in_out.id_worker.alias('id_worker1'), in_out.cur_date.alias('cur_date'), in_out.cur_time.alias('cur_time'),
                                   in_out.cur_type.alias('cur_type'),
                                   fn.RANK().over(partition_by=[in_out.id_worker, in_out.cur_date], order_by=[in_out.cur_time]).alias('num'))\
                           .where(in_out.cur_type == 1))\
                   .where(SQL('cur_time') > '09:00:00')\
                   .where(SQL('num') == 1)\
                   .where(SQL('cur_date') == dt))\
           .join(workers, on=workers.id_worker == SQL('id_worker1'))\
           .group_by(workers.department))

    for row in res:
        print(row.department)


#task_1_2()
d = input()
#task_2_2(d)
#task_3_2(d)
#task_2_2('14-12-2018')
#task_3_2('14-12-2018')