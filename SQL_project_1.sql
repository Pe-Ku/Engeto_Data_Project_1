/* Tabulka porovnání dostupnosti potravin na základě průměrných příjmů za určité časové období. 
 * Stlpec average_price ukazuje priemernu cenu danej potraviny za dany rok.
 * Stlpec average_wage ukazuje priemernu rocnu mzdu pre dane odvetvie a rok.
 * */
CREATE OR REPLACE TABLE t_Peter_Kubovcik_project_SQL_primary_final AS
SELECT t1.YEAR, t1.name AS food_name, t1.average_price, t2.industry_name, t2.average_wage
FROM (
	SELECT cpc.name, round(avg(cpr.value),2) AS average_price, YEAR(date_from) AS year
	FROM czechia_price cpr
	LEFT JOIN czechia_price_category cpc
	ON cpr.category_code = cpc.code
	GROUP BY name, YEAR(date_from)
	ORDER BY date_from) t1
LEFT JOIN (
	SELECT cpib.name industry_name, avg(cp.value) AS average_wage, cp.payroll_year
	FROM czechia_payroll cp
	LEFT JOIN czechia_payroll_industry_branch cpib
	ON cp.industry_branch_code = cpib.code
	WHERE cp.value_type_code = 5958
		AND cp.unit_code = 200
		AND cp.calculation_code = 100
		AND cp.industry_branch_code IS NOT NULL
	GROUP BY cpib.name, cp.payroll_year
	ORDER BY cp.payroll_year) t2
ON t1.year = t2.payroll_year
ORDER BY t1.YEAR DESC;

SELECT *
FROM t_Peter_Kubovcik_project_SQL_primary_final;


/* Tabulka s HDP, GINI koeficientem a populací dalších evropských států ve stejném období, jako primární přehled pro ČR */
CREATE OR REPLACE TABLE t_Peter_Kubovcik_project_SQL_secondary_final
SELECT t2.YEAR, t2.country, t2.population, t2.gdp, t2.gini
FROM (
	SELECT country
	FROM countries
	WHERE continent = 'Europe'
	AND country IS NOT NULL) t1
LEFT JOIN (
	SELECT country, population, YEAR, gdp, gini
	FROM economies
	WHERE YEAR BETWEEN 
		(SELECT min(th_1.`YEAR`)
		FROM t_peter_kubovcik_project_sql_primary_final th_1)
		AND
		(SELECT max(th_1.`YEAR`)
		FROM t_peter_kubovcik_project_sql_primary_final th_1)
		) t2
ON t1.country = t2.country
WHERE t2.country IS NOT NULL;

SELECT *
FROM t_peter_kubovcik_project_sql_secondary_final;


/* OTAZKA 1)
 * Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají? 
 * Stlpec difference ukazuje rozdiel medzi priemernou mzdou v danom roku a predoslom roku. Percentualne vyjadrenie v stlpci percent_change.
 * Stlpec difference_comment obsahuje hodnotu DOWN ak priemerna mzda oproti predoslemu roku klesla. Stagnate ak stagnuje. NULL v pripade, ze vyrastla.
 * */
CREATE OR REPLACE TABLE t_wages_comparison AS
SELECT `YEAR`, industry_name, average_wage,
	average_wage - (lag(average_wage) OVER (PARTITION BY industry_name ORDER BY `YEAR`)) AS difference,
	round(((average_wage - (lag(average_wage) OVER (PARTITION BY industry_name ORDER BY `YEAR`))) * 100) / (lag(average_wage) OVER (PARTITION BY industry_name ORDER BY `YEAR`)), 2) AS percent_change,
	CASE 
		WHEN average_wage - (lag(average_wage) OVER (PARTITION BY industry_name ORDER BY `YEAR`)) < 0 THEN 'DOWN'
		WHEN average_wage - (lag(average_wage) OVER (PARTITION BY industry_name ORDER BY `YEAR`)) = 0 THEN 'STAGNATE'
	END AS difference_comment
FROM t_peter_kubovcik_project_sql_primary_final
GROUP BY `YEAR`, industry_name
ORDER BY industry_name, `YEAR`;


/* U tychto odvetvi a v tyto roky klesla priemerna rocna mzda v porovnani s predchodzim rokom o hodnotu difference, percentualne vyjadrene v stlpci percent_change. 
 * */
SELECT *
FROM t_wages_comparison
WHERE difference_comment = 'DOWN'
GROUP BY industry_name;


/* U tychto odvetvi nikdy mezdirocne neklesla priemerna rocna mzda
 * */
SELECT cpib.name
FROM czechia_payroll_industry_branch cpib
LEFT JOIN (
	SELECT industry_name 
	FROM t_wages_comparison
	WHERE difference_comment = 'DOWN'
	GROUP BY industry_name) t1
ON cpib.name = t1.industry_name
WHERE t1.industry_name IS NULL;


/* V ramci celeho sledovaneho obdobia od r. 2006 do r. 2018 mzdy vyrastli vo vsetkych odvetviach. 
 * Stlpec wage_increase je zmena vysky priemernej mzdy medzi rokmi 2006 a 2018 pre dane odvetvie. Percentualne vyjadrenie v stlpci percent_increase.
 * */
SELECT t1.industry_name, t1.`YEAR`, t1.average_wage, t2.`YEAR`, t2.average_wage,
	t2.average_wage - t1.average_wage AS wage_increase,
	round(((t2.average_wage-t1.average_wage) * 100)/ t1.average_wage,2) AS percent_increase
FROM (
	SELECT `YEAR`, industry_name, average_wage
	FROM t_wages_comparison
	WHERE YEAR = (
	SELECT min(`YEAR`) 
	FROM t_wages_comparison)) t1
JOIN (
	SELECT `YEAR`, industry_name, average_wage
	FROM t_wages_comparison
	WHERE YEAR = (
	SELECT max(`YEAR`)
	FROM t_wages_comparison)) t2
ON t1.industry_name = t2.industry_name;


/* OTAZKA 2)
 * Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
 * Stlpec l_milk_2006 - mnozstvo mlieka v l, ktore je mozne kupit za priemernu rocnu mzdu pre dane odvetvie v roku 2006.
 * Stlpec milk_difference - porovnanie mnozstva mlieka v l, ktore si bolo mozne kupit v r. 2018 a 2006 za priemerny rocnu mzdu pre dane odvetvie.
 * */
SELECT
	table_1.industry_name,
	table_1.l_milk_2006, table_2.l_milk_2018,
	l_milk_2018 - l_milk_2006 AS milk_difference,
	table_1.kg_bread_2006, table_2.kg_bread_2018,
	kg_bread_2006 - kg_bread_2018 AS bread_difference
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


/* OTAZKA 3)
 * Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
 * Stlpec average_price uvadza priemernu cenu pre danu potravinu a rok.
 * Stlpec percent_change udava zmenu priemernej ceny oproti predoslemu roku.
 * */
CREATE OR REPLACE TABLE t_food_price_change
SELECT `YEAR`, food_name, average_price,
	round(((average_price - (lag(average_price) OVER (PARTITION BY food_name ORDER BY `YEAR`))) * 100) / (lag(average_price) OVER (PARTITION BY food_name ORDER BY `YEAR`)), 2) AS percent_change
FROM t_peter_kubovcik_project_sql_primary_final
GROUP BY `YEAR`, food_name
ORDER BY food_name, `YEAR`;


/*Vyhodnotenie ktora potravina ma pre dany rok najnizsi percentualmny narast (zaporna hodnota znamena zlacnenie oproti predoslemu roku, kladna zdrazenie).
 * */
SELECT t1.YEAR, t2.food_name, t1.min_difference_percent
FROM (
	SELECT `YEAR`, min(percent_change) AS min_difference_percent
	FROM t_food_price_change
	WHERE percent_change IS NOT NULL
	GROUP BY `YEAR`
	ORDER BY `YEAR`) t1
JOIN (
	SELECT *
	FROM t_food_price_change) t2
ON t1.min_difference_percent = t2.percent_change
ORDER BY t1.YEAR;

/* OTAZKA 4)
 * Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
 * Stlpec average_price_change udava priemerne o kolko % zdrazeli / zlacneli potraviny oproti predoslemu roku. Vo vypocte su zahrnute vsetky skumane potraviny.
 * Stlpec average_wage_change udava priemerne o kolko % narastli / poklesli mzdy oproti predoslemu roku. Vo vypocte su zahrnute vsetky skumane odvetvia.
 * Stlpec percent_difference je rozdiel medzi priemernym mezdirocnym narastom cien potravin a priemernym medzirocnym narastom mezd, vyjadrene v percentach.
 * */
CREATE OR REPLACE TABLE t_food_and_wages_comparison
SELECT t1.YEAR, t1.average_price_change, t2.average_wage_change,
	t1.average_price_change - t2.average_wage_change AS percent_difference
FROM (
	SELECT `YEAR`, round(avg(percent_change),2) AS average_price_change
	FROM t_food_price_change
	WHERE percent_change IS NOT NULL
	GROUP BY `YEAR`) t1
JOIN (
	SELECT `YEAR`, round(avg(percent_change),2) AS average_wage_change 
	FROM t_wages_comparison
	WHERE difference IS NOT NULL
	GROUP BY `YEAR`) t2
ON t1.YEAR = t2.YEAR;

SELECT *
FROM t_food_and_wages_comparison;

/* OTAZKA 5)
 * Má výška HDP vliv na změny ve mzdách a cenách potravin? 
 * Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?
 * Stlpec gdp_change udava zmenu vysky hdp oproti predoslemu roku, vyjadrene v percentach.
 * Stlpec average_price_change udava priemerne o kolko % zdrazeli / zlacneli potraviny oproti predoslemu roku. Vo vypocte su zahrnute vsetky skumane potraviny.
 * Stlpec average_wage_change udava priemerne o kolko % narastli / poklesli mzdy oproti predoslemu roku. Vo vypocte su zahrnute vsetky skumane odvetvia.
 * */
SELECT t1.YEAR, t1.gdp_change, t2.average_price_change, t2.average_wage_change
FROM (
	SELECT `YEAR`, population, gini, gdp,
		round(((gdp - (lag(gdp) OVER (ORDER BY `YEAR`))) * 100) / (lag(gdp) OVER (ORDER BY `YEAR`)), 2) AS gdp_change
	FROM t_peter_kubovcik_project_sql_secondary_final
	WHERE country = 'Czech republic'
	ORDER BY `YEAR`) t1
JOIN (
	SELECT `YEAR`, average_price_change, average_wage_change
	FROM t_food_and_wages_comparison) t2
ON t1.YEAR = t2.`YEAR`;