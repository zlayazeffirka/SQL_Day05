SET search_path TO data;
CREATE OR REPLACE VIEW v_intervals_distribution AS
WITH intervals AS (
    SELECT
        'test00_01_1' AS table_name,
        ROUND(CAST(PERCENTILE_CONT(0.05) WITHIN GROUP (ORDER BY time) FILTER (WHERE client_id = 9) AS NUMERIC), 2) AS d05,
        ROUND(CAST(PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY time) FILTER (WHERE client_id = 9) AS NUMERIC), 2) AS d95
    FROM test00_01_1
    UNION ALL
    SELECT
        'test00_01_2' AS table_name,
        ROUND(CAST(PERCENTILE_CONT(0.05) WITHIN GROUP (ORDER BY time) FILTER (WHERE client_id = 9) AS NUMERIC), 2),
        ROUND(CAST(PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY time) FILTER (WHERE client_id = 9) AS NUMERIC), 2)
    FROM test00_01_2
),
intervals_with_bounds AS (
    SELECT
        table_name,
        d05,
        d95,
        ROUND((d95 - d05) / 3::NUMERIC, 2) AS interval_width
    FROM intervals
),
rows_with_intervals AS (
    SELECT
        'test00_01_1' AS table_name,
        CASE
            WHEN t.time >= i.d05 AND t.time < i.d05 + i.interval_width THEN 1
            WHEN t.time >= i.d05 + i.interval_width AND t.time < i.d05 + 2 * i.interval_width THEN 2
            WHEN t.time >= i.d05 + 2 * i.interval_width AND t.time <= i.d95 THEN 3
        END AS interval_no,
        t.time
    FROM test00_01_1 t
    JOIN intervals_with_bounds i
        ON i.table_name = 'test00_01_1'
    WHERE t.client_id = 9
    UNION ALL
    SELECT
        'test00_01_2' AS table_name,
        CASE
            WHEN t.time >= i.d05 AND t.time < i.d05 + i.interval_width THEN 1
            WHEN t.time >= i.d05 + i.interval_width AND t.time < i.d05 + 2 * i.interval_width THEN 2
            WHEN t.time >= i.d05 + 2 * i.interval_width AND t.time <= i.d95 THEN 3
        END AS interval_no,
        t.time
    FROM test00_01_2 t
    JOIN intervals_with_bounds i
        ON i.table_name = 'test00_01_2'
    WHERE t.client_id = 9
),
intervals_summary AS (
    SELECT
        table_name,
        interval_no,
        COUNT(*) AS amount_of_rows,
        '[' || ROUND(d05 + (interval_no - 1) * interval_width, 2) || ', ' ||
        ROUND(d05 + interval_no * interval_width, 2) || ')' AS interval_bounds,
        (SELECT COUNT(*) FROM test00_01_1 WHERE client_id = 9) AS total_rows
    FROM rows_with_intervals
    JOIN intervals_with_bounds USING (table_name)
    GROUP BY table_name, interval_no, d05, interval_width
)
SELECT
    table_name,
    interval_bounds AS interval,
    amount_of_rows,
    REPEAT('|', CEIL((amount_of_rows * 100.0) / total_rows)::INTEGER) AS histogram,
    CEIL((amount_of_rows * 100.0) / total_rows)::INTEGER AS percent
FROM intervals_summary
ORDER BY table_name, interval_no;
