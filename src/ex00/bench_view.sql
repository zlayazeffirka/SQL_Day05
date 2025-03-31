\set id random(1, 10000000)
BEGIN;
SELECT * FROM data.v_country_indicator_original WHERE id = :id;
END;