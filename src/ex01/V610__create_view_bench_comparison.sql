SET search_path TO data;
CREATE VIEW v_compare_test_results AS
SELECT
	'v_country_indicator_original' AS object_name,
    MAX(time) AS maximum_time,
    MIN(time) AS minimum_time,
    AVG(time) AS average_time
FROM test00_01_1
UNION ALL
SELECT
    'country_indicator' AS object_name,
    MAX(time) AS maximum_time,
    MIN(time) AS minimum_time,
    AVG(time) AS average_time
FROM test00_01_2;