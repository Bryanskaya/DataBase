"""В postgresql:
COPY (SELECT row_to_json(hunting_grounds)
	  FROM hunting_grounds)
TO 'C:\msys64\home\bryan\DataBase\lab_07\save_HuntingGrounds.json';
"""
from py_linq import Enumerable
import json


data = Enumerable()


def load_data(filename):
    f = open(filename, 'r', encoding='utf-8')
    for row in f.readlines():
        data.append(json.loads(row))
    f.close()


def print_data(dt):
    for i in dt:
        print('{:<5}'.format(i['id']), end="")
        print('{:<40}'.format(i['ground_name']), end="")
        print('{:<10}'.format(i['square']), end="")
        print('{:<5}'.format(i['max_num_sectors']), end="\n")


def update_in_file(dt, filename):
    f = open(filename, 'w', encoding='utf-8')
    for item in dt:
        json.dump(item, f, ensure_ascii=False)
        print(" ", file=f)
    f.close()


def update_dt(id, key, value, dt):
    for i in dt.where(lambda x: x['id'] == id):
        i[key] = value


def update_data(dt, filename):
    id = int(input(">>> Введите id: "))
    if not is_exist('id', id, dt):
        print("ОШИБКА: такого хозяйства не существует")
        return

    print("Обновить:")
    print("1 название")
    print("2 значение площади")
    print("3 количества секторов")
    choice = int(input(">>> Ваш выбор: "))

    if choice not in [1, 2, 3]:
        print("ОШИБКА: некорректный ввод")
        return

    temp = input(">>> Введите новое значение: ")

    if choice == 1:
        if temp == "":
            print("ОШИБКА: некорректное название")
            return
        update_dt(id, 'ground_name', temp, dt)
    elif choice == 2:
        temp = float(temp)
        if temp <= 0:
            print("ОШИБКА: некорректное значение площади")
            return
        update_dt(id, 'square', temp, dt)
    elif choice == 3:
        temp = int(temp)
        if temp <= 0:
            print("ОШИБКА: некорректное значение числа секторов")
            return
        update_dt(id, 'max_num_sectors', temp, dt)
    update_in_file(dt, filename)


def insert_in_file(item, filename):
    f = open(filename, 'a', encoding='utf-8')
    json.dump(item, f, ensure_ascii=False)
    print(" ", file=f)
    f.close()


def insert_data(filename, name, s, num, dt): #Проверить
    id = dt.order_by(lambda x: x['id']).last()['id'] + 1
    temp = {'id': id, 'ground_name': name,
            'square': s, 'max_num_sectors': num}

    dt.append(temp)
    insert_in_file(temp, filename)


def is_exist(key, value, dt):
    for i in dt.where(lambda x: x[key] == value):
        return True
    return False


def add_data(dt, filename):
    print("Введите:")
    name = input("- название: ")
    if name == "":
        print("ОШИБКА: некорректное название")
        return

    s = float(input("- площадь: "))
    if s <= 0:
        print("ОШИБКА: некорректное значение площади")
        return

    num = int(input("- максимальное число секторов: "))
    if num <= 0:
        print("ОШИБКА: некорректное значение числа секторов")
        return

    if is_exist('ground_name', name, dt):
        print("ОШИБКА: такое хозяйство уже существует")
        return

    insert_data(filename, name, s, num, dt)

    print("Запись успешно добавлена")


def main():
    filename = 'save_HuntingGrounds.json'
# ---------------------------------------------
    load_data(filename)
    print_data(data)
# ---------------------------------------------
    while True:
        print('\n' + "-" * 10 + 'MENU' + "-" * 10)
        print("1 Обновить данные")
        print("2 Добавить данные")
        print("3 Напечатать данные")
        print("> Остальное - выход\n")
        choice = int(input(">>> Ваш выбор: "))

        if choice == 1:
            update_data(data, filename)
        elif choice == 2:
            add_data(data, filename)
        elif choice == 3:
            print_data(data)
        else:
            break

main()