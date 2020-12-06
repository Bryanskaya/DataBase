DROP TABLE Table1 CASCADE;
DROP TABLE Table2 CASCADE;

CREATE TEMP TABLE IF NOT EXISTS Table1 
(
	id 					INT,
	var1 				TEXT,
	valid_from_dttm 	DATE,
	valid_to_dttm 		DATE
);

CREATE TEMP TABLE IF NOT EXISTS Table2
(
	id 					INT,
	var2 				TEXT,
	valid_from_dttm 	DATE,
	valid_to_dttm 		DATE
);

INSERT INTO Table1(id, var1, valid_from_dttm, valid_to_dttm) VALUES (1, 'A', '2018-09-01', '2018-09-15');
INSERT INTO Table1(id, var1, valid_from_dttm, valid_to_dttm) VALUES (1, 'B', '2018-09-16', '2018-10-11');
INSERT INTO Table1(id, var1, valid_from_dttm, valid_to_dttm) VALUES (1, 'C', '2018-10-12', '2018-10-14');
INSERT INTO Table1(id, var1, valid_from_dttm, valid_to_dttm) VALUES (1, 'D', '2018-10-15', '5999-12-31');

INSERT INTO Table1(id, var1, valid_from_dttm, valid_to_dttm) VALUES (2, 'AA', '2018-09-12', '2018-10-14');
INSERT INTO Table1(id, var1, valid_from_dttm, valid_to_dttm) VALUES (2, 'BB', '2018-10-15', '5999-12-31');


INSERT INTO Table2(id, var2, valid_from_dttm, valid_to_dttm) VALUES (1, 'A', '2018-09-01', '2018-09-14');
INSERT INTO Table2(id, var2, valid_from_dttm, valid_to_dttm) VALUES (1, 'B', '2018-09-15', '2018-09-21');
INSERT INTO Table2(id, var2, valid_from_dttm, valid_to_dttm) VALUES (1, 'C', '2018-09-22', '2018-09-30');
INSERT INTO Table2(id, var2, valid_from_dttm, valid_to_dttm) VALUES (1, 'D', '2018-10-01', '5999-12-31');

INSERT INTO Table2(id, var2, valid_from_dttm, valid_to_dttm) VALUES (2, 'AA', '2018-09-12', '5999-12-31');


SELECT CASE
			WHEN tbl1.id IS NOT NULL THEN tbl1.id
			ELSE tbl2.id
	   END AS idd,
	   var1, var2,
	   CASE 
	   		WHEN tbl1.valid_from_dttm > tbl2.valid_from_dttm OR tbl2.valid_from_dttm IS NULL
				THEN tbl1.valid_from_dttm
			ELSE tbl2.valid_from_dttm
	   END,
	   CASE 
	   		WHEN tbl1.valid_to_dttm < tbl2.valid_to_dttm OR tbl2.valid_to_dttm IS NULL 
				THEN tbl1.valid_to_dttm
			ELSE tbl2.valid_to_dttm
	   END
FROM Table1 tbl1 FULL JOIN Table2 tbl2 ON 
	tbl1.id = tbl2.id AND
	(tbl2.valid_from_dttm BETWEEN tbl1.valid_from_dttm AND tbl1.valid_to_dttm OR
     tbl1.valid_from_dttm BETWEEN tbl2.valid_from_dttm AND tbl2.valid_to_dttm)
ORDER BY idd, valid_from_dttm;

SELECT * FROM Table1;
SELECT * FROM Table2;