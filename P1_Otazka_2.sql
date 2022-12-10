/* OTÁZKA 2)
 * Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
 * Stĺpec l_milk_2006 - množstvo mlieka v l, ktoré je možné kúpiť za priemernú ročnu mzdu pre dané odvetvie v roku 2006.
 * Stĺpec milk_difference - porovnanie množstva mlieka v l, ktoré si bolo možné kúpiť v r. 2018 a 2006 za priemernú ročnú mzdu.
 * */
CREATE OR REPLACE TABLE t_milk_and_bread_comparison
SELECT
	table_1.industry_name,
	table_1.l_milk_2006, table_2.l_milk_2018,
	l_milk_2018 - l_milk_2006 AS milk_difference,
	table_1.kg_bread_2006, table_2.kg_bread_2018,
	kg_bread_2018 - kg_bread_2006 AS bread_difference
FROM (
	SELECT t1.industry_name, t1.YEAR, 
		round((t1.average_wage / t1.average_price)) AS l_milk_2006,
		round((t2.average_wage / t2.average_price)) AS kg_bread_2006
	FROM (
	SELECT industry_name, `YEAR`, average_wage, food_name, average_price
		FROM t_peter_kubovcik_project_sql_primary_final
		WHERE `YEAR` = (
			SELECT min(`YEAR`) 
			FROM t_peter_kubovcik_project_sql_primary_final)
			AND food_name LIKE 'Mléko%') t1
	JOIN (
		SELECT industry_name, `YEAR`, average_wage, food_name, average_price
		FROM t_peter_kubovcik_project_sql_primary_final
		WHERE `YEAR` = (
			SELECT min(`YEAR`) 
			FROM t_peter_kubovcik_project_sql_primary_final)
		AND food_name LIKE 'Chléb%') t2
	ON t1.industry_name = t2.industry_name) table_1
JOIN (
	SELECT t1.industry_name, t1.YEAR, 
		round((t1.average_wage / t1.average_price)) AS l_milk_2018,
		round((t2.average_wage / t2.average_price)) AS kg_bread_2018
	FROM (
		SELECT industry_name, `YEAR`, average_wage, food_name, average_price
		FROM t_peter_kubovcik_project_sql_primary_final
		WHERE `YEAR` = (
			SELECT max(`YEAR`) 
			FROM t_peter_kubovcik_project_sql_primary_final)
		AND food_name LIKE 'Mléko%') t1
	JOIN (
		SELECT industry_name, `YEAR`, average_wage, food_name, average_price
		FROM t_peter_kubovcik_project_sql_primary_final
		WHERE `YEAR` = (
			SELECT max(`YEAR`) 
			FROM t_peter_kubovcik_project_sql_primary_final)
		AND food_name LIKE 'Chléb%') t2
	ON t1.industry_name = t2.industry_name) table_2
ON table_1.industry_name = table_2.industry_name;

/* Dotaz 2a)
 * Porovnanie množstva mlieka a chleba, ktoré je možné kúpiť za priemernú ročnú mzdu v roku 2006 a 2018.
 */
SELECT 
	round(avg(l_milk_2006), 2) AS avg_l_milk_2006,
	round(avg(l_milk_2018), 2) AS avg_l_milk_2018,
	round(avg(l_milk_2018), 2) - round(avg(l_milk_2006), 2) AS avg_milk_difference,
	round(avg(kg_bread_2006), 2) AS avg_kg_bread_2006,
	round(avg(kg_bread_2018), 2) AS avg_kg_bread_2018,
	round(avg(kg_bread_2018), 2) - round(avg(kg_bread_2006), 2) AS avg_bread_difference
FROM t_milk_and_bread_comparison;
