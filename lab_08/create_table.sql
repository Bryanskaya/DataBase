drop table in_out cascade;

drop table dogs;

create table if not exists dogs(
	id		 	SERIAL PRIMARY KEY,
	nickname	TEXT,
	age			INTEGER CONSTRAINT valid_age CHECK (age >= 0),
	sex			CHAR NOT NULL,
	mark		NUMERIC CONSTRAINT valid_mark CHECK (mark >= 0),
	price		NUMERIC CONSTRAINT valid_price CHECK (price >= 0)
);

select *
from dogs