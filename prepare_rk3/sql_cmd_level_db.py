import psycopg2
import getpass
from py_linq import Enumerable

class DataBase:
    connection = None
    cursor = None

    def __init__(self, pwd):
        try:
            self.connection = psycopg2.connect(dbname='prep3', user = 'postgres', password=pwd, host='localhost')
            self.cursor = self.connection.cursor()
        except:
            print("ОШИБКА: соединения")
            self.connection = None
            self.cursor = None

    def __del__(self):
        if self.connection != None:
            self.connection.close()
        if self.cursor != None:
            self.cursor.close()

    def is_close(self):
        if self.connection == None or self.cursor == None:
            return True
        return False

    def get_result(self):
        res = self.cursor.fetchall()
        if res is not None:
            for name in self.cursor.description:
                print('{:^20}'.format(name.name), end="|")
            print()

            for row in res:
                for item in row:
                    print('{:<20}'.format(str(item)), end="|")
                print()

# Найти отделы, в которых хоть один сотрудник опаздывает больше 3х раз в неделю
    def task_1(self):
        self.cursor.execute(
            "select workers.id_worker, week, count_late, fnp, department "
            "from "
            "("
            "SELECT id_worker, "
            "EXTRACT(WEEK FROM cur_date) as week, "
            "count_late(id_worker, EXTRACT(WEEK FROM cur_date)::integer) "
            "from in_out "
            "group by id_worker, week "
            ") as temp_res "
            "join workers on temp_res.id_worker = workers.id_worker "
            "where temp_res.count_late > 1 "
        )

# Найти средний возраст сотрудников, не находящихся на рабочем месте 8 часов в день
    def task_2(self):
        self.cursor.execute(
            "select avg(extract (year from(justify_interval(NOW() - brth)))) "
            "from "
            "( "
            "select id_worker, cur_date, sum(res.time_out) - sum(res.time_in) as whole_time "
            "from "
            "( "
            "select temp1.id_worker, temp1.cur_time as time_in, temp2.cur_time as time_out, temp1.cur_date "
            "from "
            "( "
            "SELECT id_worker, cur_time, cur_date, row_number() over(partition by id_worker, cur_date order by cur_time) as num "
            "from in_out "
            "where cur_type = 1 "
            ") as temp1 join "
            "( "
            "SELECT id_worker, cur_time, cur_date, row_number() over(partition by id_worker, cur_date order by cur_time) as num "
            "from in_out "
            "where cur_type = 2 "
            ") as temp2 on temp1.id_worker = temp2.id_worker and temp1.num = temp2.num and temp1.cur_date = temp2.cur_date "
            ")as res "
            "group by id_worker, cur_date "
            ") as get_time join workers on workers.id_worker = get_time.id_worker "
            "where whole_time < interval '8 hours'"
        )

# Вывести все отделы и количество сотрудников хоть раз опоздавших за всю историю учета
    def task_3(self):
        self.cursor.execute(
            "select department, count(distinct(temp_res2.id_worker)) "
            "from "
            "( "
            "select * "
            "from "
            "( "
            "select *, "
            "row_number() over(partition by id_worker, cur_date order by cur_time) as num "
            "from in_out "
            "where cur_type = 1 "
            ") as temp_res1 "
            "where temp_res1.cur_time > '09:00:00' and temp_res1.num = 1 "
            ") as temp_res2 join workers on temp_res2.id_worker = workers.id_worker "
            "group by department "
        )

    def task_3_2(self):
        self.cursor.execute("select * from in_out")
        in_out = self.cursor.fetchall()

        self.cursor.execute("select * from workers")
        workers = self.cursor.fetchall()

        res = Enumerable(in_out)\
            .where(lambda x: x[4] == 1)\
            .select(lambda x: [x[0], x[1], x[3], x[4]], )

        for row in res:
            print(row)


def menu():
    #pwd = getpass.getpass("Введите пароль для работы с базой данных: ")
    my_db = DataBase("bdwdcb8y")
    if my_db.is_close():
        return

    #my_db.task_1()
    #my_db.get_result()
    #my_db.task_2()
    #my_db.get_result()
    #my_db.task_3()
    #my_db.get_result()
    my_db.task_3_2()

menu()