SET search_path TO data;

CREATE VIEW v_test00_01_1 AS
SELECT time, transaction_no
FROM test00_01_1
WHERE client_id = 5
ORDER BY time_us, transaction_no;

CREATE VIEW v_test00_01_2 AS
SELECT time, transaction_no
FROM test00_01_2
WHERE client_id = 5
ORDER BY time_us, transaction_no;