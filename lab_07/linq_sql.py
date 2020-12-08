from pony.orm import *
from datetime import datetime, date


db = Database()


class Sectors(db.Entity):
    id = PrimaryKey(int, auto=True)
    square = Required(float)
    id_husbandry = Required(int)
    id_voucher = Set("Vouchers")


class Hunters(db.Entity):
    _table_ = "hunters"
    ticket_num = PrimaryKey(int)
    surname = Required(str, 30)
    firstname = Required(str, 30)
    patronymic = Optional(str, 30)
    date_of_birth = Required(date)
    sex = Required(str, 1)
    license_num_gun = Required(str, 15, unique=True)
    residence = Required(str, 100)
    mobile_phone = Required(str, 30)
    email = Required(str, 40)
    id_voucher = Set("Vouchers")

    @property
    def full_name(self):
        return self.surname + ' ' + self.firstname + ' ' + self.patronymic

    @property
    def all_info(self):
        return self.full_name + ' ' + str(self.date_of_birth) + ' ' + self.sex + ' ' +\
               self.license_num_gun + ' ' + self.residence + ' ' + self.mobile_phone + ' ' +\
               self.email


class Vouchers(db.Entity):
    id = PrimaryKey(int, auto=True)
    animal = Required(str, 30)
    duration_days = Required(int)
    amount_animals = Required(int)
    price = Required(float)
    id_sector = Required(Sectors)
    id_hunter = Required(Hunters)

    @property
    def all_info(self):
        return self.id + ' ' + self.animal + ' ' + str(self.duration_days) + ' ' +\
               str(self.amount_animals) + ' ' + str(self.price) + ' ' + str(self.id_sector) + ' ' +\
               str(self.id_hunter)


db.bind(
    provider='postgres',
    user='postgres',
    password='bdwdcb8y',
    host='localhost',
    database='hunting_grounds'
)
db.generate_mapping()


# Вывести всю информацию по охотнику с данной фамилией
@db_session
def get_hunter(surname):
    return select(person.all_info for person in Hunters if
                  surname == person.surname).fetch()


# Получить запись охотник - его путёвка
@db_session
def get_voucher_hunter():
    query = select((p.full_name, v.id, v.animal)
                   for p in Hunters
                   for v in Vouchers
                   if v.id_hunter == p)
    query.show()


# Проверка на существование конкретного id в таблице секторов
@db_session
def is_sector_exist(id_s):
    return select(s.id for s in Sectors
           if s.id == id_s).fetch()


# Проверка на существование конкретного id в таблице охотников
@db_session
def is_hunter_exist(id_h):
    return select(h.ticket_num for h in Hunters
           if h.ticket_num == id_h).fetch()


# Проверка на существование конкретного id в таблице охотников
@db_session
def insert_voucher(animal, num_days, num_anim, price, id_s, id_h):
    v = Vouchers(animal=animal, duration_days=num_days, amount_animals=num_anim,
                 price=price, id_sector=id_s, id_hunter=id_h)
    commit()

    return v.id


# Увеличить цену на путёвок
@db_session
def update_vouchers(n):
    query = select(v for v in Vouchers)
    for v in query:
        v.price += v.price * n
    query.show()

    commit()


# Удалить все путёвки, цена на которые меньше средней
@db_session
def delete_vouchers():
    select(v for v in Vouchers if v.price < avg(item.price for item in Vouchers)).delete()

    commit()


@db_session
def call_func():
    return db.select("* FROM AvgPrice()")

def print_request(r):
    print()
    for item in r:
        print(item)

def main():
    while True:
        print("\n\n1 Вывести всю информацию по охотнику с данной фамилией (Однотабличный запрос)")
        print("2 Вывести охотников и их путёвки (Многотабличный запрос)")
        print("3 Добавить путёвку (Добавление)")
        print("4 Увеличить цену на путёвки на 20% (Изменение)")
        print("5 Удалить все путёвки, цена на которые меньше средней (Удаление)")
        print("6 Вывести среднюю цену по всем путёвкам (Получение доступа к данным, выполняя только хранимую процедуру)")
        print("Остальное - выход\n")

        choice = int(input(">>> Ваш выбор: "))
        if choice == 1:
            srn = input("Введите фамилию охотника: ")
            print_request(get_hunter(srn))
        elif choice == 2:
            get_voucher_hunter()
        elif choice == 3:
            print("> Введите: ")
            animal = input("- животное: ")
            num_days = int(input("- количество дней: "))
            if num_days <= 0:
                print("ОШИБКА: некорректное количество дней")
                continue

            num_anim = int(input("- количество животных: "))
            if num_anim <= 0:
                print("ОШИБКА: некорректное количество животных")
                continue

            price = float(input("- цену: "))
            if price <= 0:
                print("ОШИБКА: некорректная цена")
                continue

            id_s = int(input("- номер сектора: "))
            if not is_sector_exist(id_s):
                print("ОШИБКА: такого сектора нет")
                continue

            id_h = (input("- id охотника: "))
            if not is_hunter_exist(id_h):
                print("ОШИБКА: такого охотника нет")
                continue

            print("id добавленной путёвки: ", insert_voucher(animal, num_days, num_anim, price, id_s, id_h))
            print("\nЗапись успешно добавлена")
        elif choice == 4:
            update_vouchers(0.2)
        elif choice == 5:
            delete_vouchers()
        elif choice == 6:
            print(call_func())
        else:
            break

main()

