from faker import Faker
from datetime import *
import time
from random import choice, random
import json

NUM_MINUTES = 1

NAME_TABLE = "dogs"


sex = ['м', 'ж']
price = [i for i in range(0, 3000, 150)]
names = ["Арчи", "Алекс", "Амур", "Алтaй", "Альф", "Алмаз", "Атос", "Амиго", "Аксель", "Ангел",
         "Адам", "Арнольд", "Август", "Айрон", "Акс", "Альт", "Арго", "Арес", "Атаман", "Арс",
         "Айран", "Антей", "Арамис", "Азор", "Апельсин", "Азарт", "Аркан", "Аскольд", "Артос", "Антонио",
         "Арман", "Аватар", "Арахис", "Барон", "Бутч", "Боня", "Бим", "Бадди", "Барни", "Балу",
         "Барс", "Балто", "Бакси", "Байкал", "Буран", "Босс", "Блэк", "Бой", "Бублик", "Бумер",
         "Бек", "Бандит", "Барри", "Бен", "Бакстер", "Блэйк", "Борман", "Буян", "Беня", "Блэйд",
         "Бонд", "Бантик", "Бостон", "Бинго", "Бэст", "Бетмен", "Билли", "Бобби", "Брюс", "Вольт",
         "Вальтер", "Веня", "Вольф", "Вулкан", "Вегас", "Ватсон", "Вайс", "Вилли", "Винни", "Валли",
         "Волк", "Винчестер", "Валет", "Вайт", "Вульф", "Вуди", "Вайк", "Викинг", "Волчок", "Вжик",
         "Винстон", "Вилл", "Вольдемар", "Винтик", "Везунчик", "Варг", "Вест", "Вито", "Витязь", "Восток", "Верон"]

def create_record():
    fake_ru = Faker('ru_Ru')

    sex_p = choice(sex)
    if sex_p == 'м':
        name = choice(names)
    else:
        name = choice(names)

    age = choice(range(0, 10))
    mark = round(random() * 10, 3)
    prc = choice(price)

    line = {"nickname": name, "age": age, "sex": sex_p, "mark": mark, "price": prc}

    return line

def create_file():
    id_file = 1
    while True:
        filename = "tests/" + str(id_file) + "__" +\
                   NAME_TABLE + "__" +\
                   datetime.now().strftime("%d_%m_%Y__%H_%M_%S") + ".json"
        f = open(filename, 'w', encoding='utf-8')

        line = create_record()
        json.dump(line, f, ensure_ascii=False)

        f.close()

        id_file += 1
        time.sleep(30)
        #time.sleep(NUM_MINUTES * 60)




create_file()