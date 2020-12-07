from py_linq import Enumerable

huntsmen = Enumerable()


def print_request(req):
    print("-" * 120)
    for i in req:
        for j in i:
            print('{:<20}'.format(j), end = "")
        print()
    print("-" * 120)
    print()

def print_request_1(req):
    print("-" * 120)
    print('{:<20}'.format(req[0][0]), end="")
    for i in range(1, len(req[0])):
        for j in req[0][i]:
            print('{:<20}'.format(j), end="")
        print()
        print('{:<20}'.format(""), end="")
    print("\n" + "-" * 120)
    print()

def print_request_2(req):
    print("-" * 120)
    for i in req:
        print('{:<5}'.format(i['id']), end="")
        print('{:<15}'.format(i['surname']), end="")
        print('{:<15}'.format(i['firstname']), end="")
        print('{:<15}'.format(i['patronymic']), end="")
        print('{:<15}'.format(i['date_of_birth']), end="")
        print('{:<5}'.format(i['sex']), end="")
        print('{:<4}'.format(i['experience']), end="")
        print('{:<20}'.format(i['mobile_phone']), end="")
        print('{:<30}'.format(i['email']), end=" ")
        print('{:<9}'.format(i['salary']), end="")
        print()
    print("\n" + "-" * 120)
    print()


def add_data(id, surname, firstname, patronymic, date, sex, experience, phone, email, salary):
    data = {'id': id, 'surname': surname,
            'firstname': firstname, 'patronymic': patronymic,
            'date_of_birth': date, 'sex': sex, 'experience': experience,
            'mobile_phone': phone, 'email': email, 'salary': salary}
    huntsmen.append(data)


add_data(1, "Кириллова", "Екатерина", "Павловна", "1976-06-15", "ж", 32, "+7 231 569 2254", "ifedoseeva@npo.info", 50000)
add_data(2, "Евдокимов", "Викторин", "Демьянович", "1944-07-11", "м", 33, "8 692 151 0324", "muhingavrila@oao.org", 60000)
add_data(3, "Кузнецов", "Флорентин", "Артёмович","1941-07-23", "м", 12, "+7 (217) 643-80-20", "aksenovernst@anisimov.biz", 30000)
add_data(4, "Крюкова", "Оксана", "Евгеньевна", "1981-12-26", "ж", 15, "8 293 607 61 03", "svorobeva@rambler.ru", 50000)
add_data(5, "Захарова", "Лора", "Леоновна", "1964-06-08", "ж", 39, "8 (914) 963-3884", "zhanna2007@rambler.ru", 10000)
add_data(6, "Петухова", "Галина", "Филипповна", "1950-09-07", "ж", 4, "+7 (371) 260-7172", "vatslav_2004@snezhnaja.biz", 70000)
add_data(7, "Савельева", "Агата", "Ефимовна", "1967-02-05", "ж", 31, "8 188 412 85 13", "stojan10@yahoo.com", 50000)
add_data(8, "Петрова", "Ульяна", "Ждановна", "1950-09-07", "ж", 1, "+7 (017) 759-26-82", "marianegorov@rambler.ru", 20000)
add_data(9, "Щукина", "Ирина", "Ниловна", "1960-05-27", "ж", 34, "+7 623 904 9347", "andronikterentev@rambler.ru", 10000)
add_data(10, "Афанасьев", "Поликарп", "Филимонович", "1978-06-18", "м", 7, "+7 (335) 799-6748", "timofeevserge@mail.ru", 45000)

# Вывести максимальную зарплату среди мужчин и женщин, у которых опыт работы больше 10 лет
q1 = huntsmen.where(lambda x: x['experience'] > 10)\
    .group_by(key_names=['sex'], key=lambda x: x['sex'])\
    .select(lambda x: {x.key.sex, x.max(lambda y: y['salary'])})
print_request(q1)

# Вывести ФИО егерей, у которых зарплата выше средней. Вывести в алфавитном порядке
q2 = huntsmen.where(lambda x: x['salary'] > huntsmen.avg(lambda y: y['salary']))\
    .order_by(lambda x: x['surname'])\
    .select(lambda x: [x['id'], x['surname'], x['firstname'], x['patronymic'], x['salary']])
print_request(q2)

# Разделить всех егерей по полу, и среди тех, у кого в группе есть человек 1960 года рождения, вывести самого старшего
q3 = huntsmen.group_by(key_names=['sex'], key=lambda x: x['sex'])\
    .where(lambda x: x.any(lambda y: ('1960' in y['date_of_birth'])))\
    .select(lambda x: [x.key.sex, *huntsmen.where(lambda y: x.min(lambda z: z['date_of_birth']) == y['date_of_birth'])\
                                        .select(lambda y: [y['surname'], y['firstname'], y['patronymic'], y['date_of_birth']])])
print_request_1(q3)

# Вывести все возможные зарплаты в порядке убывания, пропустить самую большую и самую маленькую
q4 = huntsmen.order_by_descending(lambda x: x['salary'])\
    .distinct(lambda x: x['salary'])\
    .skip(1)\
    .skip_last(1)\
    .select(lambda x: [x['salary']])
print_request(q4)

# Получить всех егерей с 1960 по 1980 год рождения
q5 = huntsmen.where(lambda x: "1960-01-01" <= x['date_of_birth'] <= "1980-12-31")

# Добавить столбец их числа и сколько в сумме тратится средств на их зарплату
q6 = q5.select(lambda x: [x['surname'], x['firstname'], x['patronymic'], x['date_of_birth'], q5.count(), q5.sum(lambda y: y['salary'])])
print_request(q6)

# Найти егерей, у которых стаж работы не превышает 10 лет
q7_1 = huntsmen.where(lambda x: x['experience'] <= 10)
#print(q7_1)

# Найти егерей, у которых зарплата выше средней
q7_2 = huntsmen.where(lambda x: x['salary'] > huntsmen.avg(lambda y: y['salary']))
#print(q7_2)

# Вывести всех тех, у кого стаж не превышает 10 лет и зарплата выше средней
q7_3 = q7_1.join(q7_2, lambda x1: x1['id'], lambda x2: x2['id'], lambda res: (res[0], res[0].update(res[1]))[0])
print_request_2(q7_3)

