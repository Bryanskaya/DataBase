import psycopg2

class DataBase:
    connection = None
    cursor = None

    def __init__(self):
        try:
            self.connection = psycopg2.connect(dbname='rk3', user = 'postgres', password='bdwdcb8y', host='localhost')
            self.cursor = self.connection.cursor()
        except:
            print("ОШИБКА: соединения")
            self.connection = None
            self.cursor = None

    def is_close(self):
        if self.connection == None or self.cursor == None:
            return True
        return False

# Все отделы, где больше 10 сотрудников
    def task_1_1(self):
        self.cursor.execute(
            "select department "
            "from workers "
            "group by department "
            "having count(id_worker) > 10"
        )

# ВАЖНО: рабочий день с 9.00 по 17.30, исследуемая дата подаётся
# Найти сотрудников, которые не выходят в течении дня
    def task_2_1(self, dt):
        self.cursor.execute(
            "select workers.fnp "
            "from "
            "("
            "select id_worker, cur_date "
            "from in_out "
            "where cur_type = 1 and cur_date = '%s' "
            "group by id_worker, cur_date "
            "having count(*) = 1 "
            ") as temp1 join"
            "("
            "select id_worker, cur_date "
            "from in_out "
            "where cur_type = 2 and cur_time >= '17:30:00' "
            "group by id_worker, cur_date "
            "having count(*) = 1 "
            ") as temp2 on temp1.id_worker = temp2.id_worker "
            "join workers on temp1.id_worker = workers.id_worker" % (dt))

# Все отделы, где есть сотрудники, опаздавшие в опр дату
    def task_3_1(self, dt):
        self.cursor.execute(
            "select department "
            "from "
            "( "
            "select * "
            "from "
            "( "
            "select *, row_number() over(partition by id_worker, cur_date order by cur_time) as num "
            "from in_out "
            "where cur_type = 1 "
            ")as temp_res1 "
            "where temp_res1.cur_time > '09:00:00' and temp_res1.num = 1 and temp_res1.cur_date = '%s' "
            ")as temp_res2 join workers on temp_res2.id_worker = workers.id_worker "
            "group by department " % (dt))



def menu():
    my_db = DataBase()
    if my_db.is_close():
        return

    #my_db.task_1_1()
    #my_db.task_2_1('14-12-2018')
    #my_db.task_3_1()

menu()