DROP TABLE hunting_grounds CASCADE;
DROP TABLE sectors CASCADE;
DROP TABLE huntsmen CASCADE;
DROP TABLE hunters CASCADE;
DROP TABLE weapon CASCADE;
DROP TABLE hunter_weapon CASCADE;
DROP TABLE vouchers CASCADE;


CREATE TABLE IF NOT EXISTS hunting_grounds(
	id SERIAL PRIMARY KEY,
	ground_name VARCHAR(30) UNIQUE NOT NULL,
	square NUMERIC CONSTRAINT valid_square CHECK (square > 0),
	max_num_sectors INTEGER CONSTRAINT valid_max_num CHECK (max_num_sectors > 0)
);

CREATE TABLE IF NOT EXISTS sectors(
	id SERIAL PRIMARY KEY,
	square NUMERIC CONSTRAINT valid_square CHECK (square > 0),
	id_husbandry INTEGER REFERENCES hunting_grounds
);

CREATE TABLE IF NOT EXISTS huntsmen(
	id INTEGER REFERENCES sectors,
	PRIMARY KEY (id),
	
	surname VARCHAR(30) NOT NULL,
	firstname VARCHAR(30) NOT NULL,
	patronymic VARCHAR(30),
	date_of_birth date NOT NULL,
	sex CHAR NOT NULL,
	experience INTEGER CONSTRAINT valid_experience CHECK (experience >= 0),
	mobile_phone VARCHAR(30) NOT NULL,
	email VARCHAR(40) NOT NULL,
	salary NUMERIC CONSTRAINT valid_salary CHECK (salary > 0)
);

CREATE TABLE IF NOT EXISTS hunters(
	ticket_num INTEGER PRIMARY KEY,
	surname VARCHAR(30) NOT NULL,
	firstname VARCHAR(30) NOT NULL,
	patronymic VARCHAR(30),
	date_of_birth date NOT NULL,
	sex CHAR NOT NULL,
	license_num_gun VARCHAR(15) UNIQUE NOT NULL,
	residence VARCHAR(100) NOT NULL,
	mobile_phone VARCHAR(30) NOT NULL,
	email VARCHAR(40) NOT NULL
);

CREATE TABLE IF NOT EXISTS weapon(
	id SERIAL PRIMARY KEY,
	brand VARCHAR(30) NOT NULL,
	type_weapon VARCHAR(30) NOT NULL,
	num_barrels INTEGER NOT NULL,
	caliber VARCHAR(15) NOT NULL
);

CREATE TABLE IF NOT EXISTS hunter_weapon(
	id_hunter INTEGER REFERENCES hunters,
	id_weapon INTEGER REFERENCES weapon,
	PRIMARY KEY (id_hunter, id_weapon)
);

CREATE TABLE IF NOT EXISTS vouchers(
	id SERIAL PRIMARY KEY,
	animal VARCHAR(30) NOT NULL,
	duration_days INTEGER CONSTRAINT valid_days CHECK (duration_days > 0),
	amount_animals INTEGER CONSTRAINT valid_animals CHECK (amount_animals > 0),
	price NUMERIC CONSTRAINT valid_price CHECK (price > 0),
	id_sector INTEGER REFERENCES sectors,
	id_hunter INTEGER REFERENCES hunters
);

--ALTER TABLE hunting_grounds RENAME COLUMN name TO ground_name;
COPY hunting_grounds (ground_name, square, max_num_sectors)
FROM 'C:\msys64\home\bryan\DataBase\generating\grounds.cvg' 	DELIMITER ',';

COPY sectors (square, id_husbandry)
FROM 'C:\msys64\home\bryan\DataBase\generating\sectors.cvg' 	DELIMITER ',';

COPY huntsmen
FROM 'C:\msys64\home\bryan\DataBase\generating\huntsmen.cvg'	 DELIMITER ',';

COPY hunters
FROM 'C:\msys64\home\bryan\DataBase\generating\hunters.cvg'	 DELIMITER '|';

COPY vouchers (animal, duration_days, amount_animals, price, id_sector, id_hunter)
FROM 'C:\msys64\home\bryan\DataBase\generating\vouchers.cvg'	 DELIMITER ',';

COPY weapon (brand, type_weapon, num_barrels, caliber)
FROM 'C:\msys64\home\bryan\DataBase\generating\weapon.cvg'	 DELIMITER ',';

COPY hunter_weapon
FROM 'C:\msys64\home\bryan\DataBase\generating\hunter_weapon.cvg'	 DELIMITER ',';

--SELECT * FROM hunting_grounds;
--SELECT * FROM sectors;
--SELECT * FROM huntsmen;
--SELECT * FROM hunters;
SELECT * FROM vouchers;
--SELECT * FROM weapon;
--SELECT * FROM hunter_weapon;