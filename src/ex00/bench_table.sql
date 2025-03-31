\set id random(1, 10000000)
BEGIN;
SELECT * FROM data.country_indicator WHERE id = :id;
END;