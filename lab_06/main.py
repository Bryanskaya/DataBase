import psycopg2
import getpass


def print_menu():
    print()
    print('-' * 35 + " MENU " + '-' * 35)
    print(" 1 Получить общее количество охотников\n"
          "\t--> Выполнить скалярный запрос")
    print(" 2 Вывести фамилии охотников, у которых есть ружья конкретной марки, марку и тип\n"
          "\t--> Выполнить запрос с несколькими соединениями (JOIN)")
    print(" 3 Определить какие марки ружей используются\n"
          "\t--> Выполнить запрос с ОТВ(CTE) и оконными функциями")
    print(" 4 Вывести таблицы базы данных и их размер в байтах\n"
          "\t--> Выполнить запрос к метаданным")
    print(" 5 Получить среднюю цену по путёвкам\n"
          "\t--> Вызвать скалярную функцию")
    print(" 6 Вывести информацию по всем охотникам, у которых есть путёвка на конкретное животное\n"
          "\t--> Вызвать многооператорную или табличную функцию")
    print(" 7 Добавить хозяйство в таблицу хозяйств (название, площадь, максимальное количество секторов подаются)\n"
          "\t--> Вызвать хранимую процедуру")
    print(" 8 Вывести название текущей базы данных, порт соединения и время запуска сервера\n"
          "\t--> Вызвать системную функцию или процедуру")
    print(" 9 Создать таблицу temp_dogs с полями name, breed, age\n"
          "\t--> Создать таблицу в базе данных, соответствующую тематике БД")
    print(" 10 Вставить данные в талицу temp_dogs\n"
          "\t--> Выполнить вставку данных в созданную таблицу с использованием инструкции INSERT или COPY")
    print(" 0 Выход\n")

class DataBase:
    connection = None
    cursor = None

    def __init__(self, pwd):
        try:
            self.connection = psycopg2.connect(dbname='hunting_grounds', user = 'postgres', password=pwd, host='localhost')
            self.cursor = self.connection.cursor()
        except:
            print("ОШИБКА: соединения")
            connection = None
            cursor = None

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
        else:
            print("Result is empty!")

    def get_number_hunters(self):
        self.cursor.execute("SELECT COUNT(*) AS number FROM hunters")

    def get_hunters_with_cur_weapon(self, kind):
        self.cursor.execute("SELECT hunters.surname, brand, type_weapon "
                            "FROM weapon JOIN hunter_weapon ON weapon.id = hunter_weapon.id_weapon "
                            "JOIN hunters ON id_hunter = hunters.ticket_num "
                            "WHERE brand LIKE '%s';" % (kind))

    def get_kinds_of_weapon(self):
        self.cursor.execute("WITH num_group (id, brand, type_weapon, num_barrels, caliber, cnt) AS ("
                            "SELECT id, brand, type_weapon, num_barrels, caliber,"
                            "ROW_NUMBER() OVER(PARTITION BY brand, type_weapon, num_barrels, caliber) AS cnt "
                            "FROM weapon "
                            ")"
                            "SELECT id, brand, type_weapon, num_barrels, caliber "
                            "FROM num_group WHERE cnt = 1;")

    def get_tables_with_size(self):
        self.cursor.execute("SELECT table_name, pg_relation_size(cast(table_name as varchar)) as size "
                            "FROM information_schema.tables "
                            "WHERE table_schema not in ('information_schema','pg_catalog')")

    def get_avg_price_vouchers(self):
        self.cursor.callproc("AvgPrice")

    def get_hunter_by_animal(self, kind):
        self.cursor.callproc("ShowHunterByAnimal", [kind])

    def insert_hunting_ground(self, name, s, max_num):
        try:
            self.cursor.execute("CALL InsertHuntingGround('%s', %f, %d)" % (name, s, max_num))
            self.connection.commit()
            print("Запись успешно добавлена")
        except:
            print("ОШИБКА: такое имя уже существует в таблице")

    def call_systems_call(self):
        self.cursor.execute("SELECT * "
                            "FROM current_database(), inet_server_port(), pg_postmaster_start_time()")

    def create_table(self):
        try:
            self.cursor.execute("CREATE TABLE IF NOT EXISTS temp_dogs ("
                                "id     SERIAL PRIMARY KEY,"
                                "name   TEXT NOT NULL,"
                                "breed  TEXT NOT NULL,"
                                "age    INTEGER NOT NULL CONSTRAINT valid_age CHECK (age > 0))")
            self.connection.commit()
            print("Таблица успешно создана")
        except:
            print("ОШИБКА: не удалось создать таблицу")

    def insert_data(self, name, breed, age):
        try:
            self.cursor.execute("INSERT INTO temp_dogs(name, breed, age) "
                                "VALUES ('%s', '%s', %d);" % (name, breed, age))
            self.connection.commit()
            print("Запись успешно добавлена")
        except:
            print("ОШИБКА: не удалось добавить данные в таблицу")

def menu():
    pwd = getpass.getpass("Введите пароль для работы с базой данных: ")
    my_db = DataBase(pwd)
    if my_db.is_close():
        return

    while True:
        print_menu()
        choice = int(input(">> Ваш выбор: "))

        if choice == 1:
            my_db.get_number_hunters()
            my_db.get_result()
        elif choice == 2:
            kind = input("Введите марку (полностью или часть, например, МР-18М%) ружья: ")
            my_db.get_hunters_with_cur_weapon(kind)
            my_db.get_result()
        elif choice == 3:
            my_db.get_kinds_of_weapon()
            my_db.get_result()
        elif choice == 4:
            my_db.get_tables_with_size()
            my_db.get_result()
        elif choice == 5:
            my_db.get_avg_price_vouchers()
            my_db.get_result()
        elif choice == 6:
            kind = input("Введите название животного: ")
            my_db.get_hunter_by_animal(kind)
            my_db.get_result()
        elif choice == 7:
            print("Введите: ")
            name = input("- название нового хозяйства: ")
            try:
                s = float(input("- площадь: "))
            except:
                print("ОШИБКА: неверное значение площади")
                continue

            if s <= 0:
                print("ОШИБКА: неверное значение площади")
                continue

            try:
                max_num = int(input("- максимальное количество секторов: "))
            except:
                print("ОШИБКА: неверное значение количества секторов")
                continue

            if max_num <= 0:
                print("ОШИБКА: неверное значение количества секторов")
                continue

            my_db.insert_hunting_ground(name, s, max_num)
        elif choice == 8:
            my_db.call_systems_call()
            my_db.get_result()
        elif choice == 9:
            my_db.create_table()
        elif choice == 10:
            print("Введите: ")
            name = input("- кличку: ")
            if name == "":
                print("ОШИБКА: неверный ввод имени")
                continue

            breed = input("- породу: ")
            if breed == "":
                print("ОШИБКА: неверный ввод названия породы")
                continue

            age = int(input("- возраст (полных лет): "))
            if age < 0 or age == "":
                print("ОШИБКА: неверный ввод возраста")
                continue

            my_db.insert_data(name, breed, age)
        elif choice == 0:
            break
        else:
            print("ОШИБКА: неверный ввод")

if __name__ == '__main__':
    menu()