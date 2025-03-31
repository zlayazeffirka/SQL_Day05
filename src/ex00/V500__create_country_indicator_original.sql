SET search_path TO data;
CREATE VIEW v_country_indicator_original AS
SELECT * FROM country_indicator;

COMMENT ON VIEW v_country_indicator_original IS 'Представление, возвращающее все данные из таблицы country_indicator';













