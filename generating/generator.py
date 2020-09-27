from faker import Faker
from random import choice

MAX_AMOUNT = 1000
NUM_SECTORS = 100
SQUARE = []
MAX_NUM_SECTORS = []
HUNTSMEN_SECTORS = [i+1 for i in range(NUM_SECTORS)]
HUNTERS = []

sex = ['м', 'ж']
price = [i for i in range(300, 1000, 150)]
animals = ['утка', 'гусь', 'тетерев', 'заяц-русак', 'лиса',
           'бобёр', 'выдра', 'косуля', 'лось', 'рябчик',
           'олень', 'бекас', 'медведь', 'волк', 'кабан',
           'глухарь', 'перепел', 'куропатка', 'заяц-беляк', 'барсук',
           'куница', 'норка', 'вальдшнеп', 'куропатка', 'перепел',
           'кряква', 'чернеть', 'чирки', 'ондатра', 'хорёк']
type_1 = "гладкоствольное"
type_2 = "нарезное"
type_3 = "комбинированное"

weapon = [{'brand' : 'МР-18М-М', 'type' : type_1, 'num_barrels' : 1, 'caliber' : 12},
          {'brand' : 'МР-18М-М', 'type' : type_1, 'num_barrels' : 1, 'caliber' : 16},
          {'brand' : 'МР-18М-М', 'type' : type_1, 'num_barrels' : 1, 'caliber' : 20},
          {'brand' : 'МР-18М-М', 'type' : type_1, 'num_barrels' : 1, 'caliber' : 32},

          {'brand' : 'МР-153', 'type' : type_1, 'num_barrels' : 1, 'caliber' : 12},

          {'brand' : 'МР-133', 'type' : type_1, 'num_barrels' : 1, 'caliber' : 12},

          {'brand' : 'МР-27М', 'type' : type_1, 'num_barrels' : 2, 'caliber' : 16},
          {'brand' : 'МР-27М', 'type' : type_1, 'num_barrels' : 2, 'caliber' : 20},
          {'brand' : 'МР-27М', 'type' : type_1, 'num_barrels' : 2, 'caliber' : 32},
          {'brand' : 'МР-27М', 'type' : type_1, 'num_barrels' : 2, 'caliber' : 12},

          {'brand' : 'МР-233', 'type' : type_1, 'num_barrels': 2, 'caliber': 16},
          {'brand' : 'МР-233', 'type' : type_1, 'num_barrels': 2, 'caliber': 20},
          {'brand' : 'МР-233', 'type' : type_1, 'num_barrels': 2, 'caliber': 32},
          {'brand' : 'МР-233', 'type' : type_1, 'num_barrels': 2, 'caliber': 12},

          {'brand': 'МР-43', 'type': type_1, 'num_barrels': 2, 'caliber': 16},
          {'brand': 'МР-43', 'type': type_1, 'num_barrels': 2, 'caliber': 20},
          {'brand': 'МР-43', 'type': type_1, 'num_barrels': 2, 'caliber': 32},
          {'brand': 'МР-43', 'type': type_1, 'num_barrels': 2, 'caliber': 12},

          {'brand': 'МР-18МН', 'type' : type_2, 'num_barrels' : 1, 'caliber': '7.62 мм'},
          {'brand': 'МР-94 "Экспресс"', 'type': type_2, 'num_barrels': 2, 'caliber': '7.62 мм'},
          {'brand': 'МР-94 "Север"', 'type' : type_3, 'num_barrels' : 2, 'caliber': '7.62 мм'},
          {'brand': 'МР-94МР', 'type' : type_3, 'num_barrels' : 2, 'caliber': '7.62 мм'},

          {'brand' : 'МР-143', 'type' : type_1, 'num_barrels' : 1, 'caliber': '7.62 мм'},
          {'brand' : 'ОП-СКС', 'type' : type_1, 'num_barrels' : 1, 'caliber': '7.62 мм'},
          {'brand' : 'Сайга 308-1', 'type' : type_2, 'num_barrels' : 2, 'caliber' : '7.62 мм'},
          {'brand': 'МР-94 "Артемида"', 'type' : type_3, 'num_barrels' : 2, 'caliber': '7.62 мм'}]

def generate_hunting_grounds():
    fake_ru = Faker('ru_Ru')

    f = open('grounds.cvg', 'w')
    temp = []
    i = 0

    while i < 70:
        name = fake_ru.region()
        if name not in temp:
            temp.append(name)
        else:
            continue

        s = choice(range(100, 10000))
        SQUARE.append(s)
        max_num = choice(range(1, 10))
        MAX_NUM_SECTORS.append(max_num)

        line = "{0}, {1}, {2}\n".format(
            name,
            s,
            max_num
        )

        f.write(line)
        i += 1
    f.close()

def generate_sectors():
    f = open('sectors.cvg', 'w')

    i = 1
    while i <= NUM_SECTORS:
        id_husbandry = choice(range(1, 70))
        if MAX_NUM_SECTORS[id_husbandry - 1] == 0:
            continue

        s = choice(range(100, 10000))
        if SQUARE[id_husbandry - 1] < s:
            continue
        if SQUARE[id_husbandry - 1] == s:
            if MAX_NUM_SECTORS[id_husbandry - 1] == 1:
                MAX_NUM_SECTORS[id_husbandry - 1] -=1
                SQUARE[id_husbandry - 1] -= s
                i += 1
            else:
                continue
        else:
            if MAX_NUM_SECTORS[id_husbandry - 1]:
                MAX_NUM_SECTORS[id_husbandry - 1] -= 1
                SQUARE[id_husbandry - 1] -= s
                i += 1

        line = "{0}, {1}\n".format(
            s,
            id_husbandry
        )

        f.write(line)
    f.close()

def generate_hunters():
    fake_ru = Faker('ru_Ru')

    f = open('hunters.cvg', 'w')

    for i in range(MAX_AMOUNT):
        sex_p = choice(sex)
        if sex_p == 'м':
            surname = fake_ru.last_name_male()
            name = fake_ru.first_name_male()
            middle_name = fake_ru.middle_name_male()
        else:
            surname = fake_ru.last_name_female()
            name = fake_ru.first_name_female()
            middle_name = fake_ru.middle_name_female()

        date_of_brth = fake_ru.date_of_birth(None, 21, 80)
        address = fake_ru.address()
        phone = fake_ru.phone_number()
        email = fake_ru.email()
        num_license = fake_ru.license_plate()
        num_ticket = fake_ru.ean(length = 8)

        HUNTERS.append(num_ticket)

        line = "{0}|{1}|{2}|{3}|{4}|{5}|{6}|{7}|{8}|{9}\n".format(
            num_ticket,
            surname,
            name,
            middle_name,
            date_of_brth,
            sex_p,
            num_license,
            address,
            phone,
            email
        )

        f.write(line)
    f.close()

def generate_huntsmen():
    fake_ru = Faker('ru_Ru')

    f = open('huntsmen.cvg', 'w')

    i = 0
    while i < NUM_SECTORS:
        ind = choice(range(len(HUNTSMEN_SECTORS)))
        id_sector = HUNTSMEN_SECTORS[ind]
        del HUNTSMEN_SECTORS[ind]

        sex_p = choice(sex)
        if sex_p == 'м':
            surname = fake_ru.last_name_male()
            name = fake_ru.first_name_male()
            middle_name = fake_ru.middle_name_male()
        else:
            surname = fake_ru.last_name_female()
            name = fake_ru.first_name_female()
            middle_name = fake_ru.middle_name_female()

        date_of_brth = fake_ru.date_of_birth(None, 21, 80)
        experience = choice(range(0, 50))
        phone = fake_ru.phone_number()
        email = fake_ru.email()
        salary = choice(range(10000, 80000, 5000))

        line = "{0},{1},{2},{3},{4},{5},{6},{7},{8},{9}\n".format(
            id_sector,
            surname,
            name,
            middle_name,
            date_of_brth,
            sex_p,
            experience,
            phone,
            email,
            salary
        )

        f.write(line)
        i += 1
    f.close()

def generate_voucher():
    f = open('vouchers.cvg', 'w')

    for i in range(MAX_AMOUNT + 200):
        animal = choice(animals)
        duration = choice(range(1, 100))
        amount = choice(range(1, 10))
        prc = choice(price) * amount
        id_sector = choice(range(1, NUM_SECTORS))
        ind = choice(range(1, MAX_AMOUNT))
        id_hunter = HUNTERS[ind]

        line = "{0},{1},{2},{3},{4},{5}\n".format(
            animal,
            duration,
            amount,
            prc,
            id_sector,
            id_hunter
        )

        f.write(line)
    f.close()

def generate_weapon():
    f = open('weapon.cvg', 'w')

    for i in range(MAX_AMOUNT + 200):
        ind = choice(range(0, len(weapon) - 1))

        brand = weapon[ind]['brand']
        type_w = weapon[ind]['type']
        num_barrels = weapon[ind]['num_barrels']
        caliber = weapon[ind]['caliber']

        line = "{0},{1},{2},{3}\n".format(
            brand,
            type_w,
            num_barrels,
            caliber
        )

        f.write(line)
    f.close()

def generate_hunter_weapon():
    arr = []
    file_hunters = open("hunters.cvg", 'r')
    for row in file_hunters.readlines():
        arr.append(list(row.split('|'))[0])
    file_hunters.close()

    f = open('hunter_weapon.cvg', 'w')

    for i in range(MAX_AMOUNT):
        ind = choice(range(1, MAX_AMOUNT))
        ind_hunter = arr[ind]
        ind_weapon = choice(range(1, MAX_AMOUNT + 200))

        line = "{0},{1}\n".format(
            ind_hunter,
            ind_weapon
        )

        f.write(line)
    f.close()

if __name__ == "__main__":
    #generate_hunting_grounds()
    #generate_sectors()
    #generate_hunters()
    #generate_huntsmen()
    #generate_voucher()
    #generate_weapon()
    generate_hunter_weapon()