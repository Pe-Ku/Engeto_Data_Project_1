/* Tabulka porovnání dostupnosti potravin na základě průměrných příjmů za určité časové období. 
 * Stĺpec average_price ukazuje priemernú cenu potraviny za daný rok.
 * Stĺpec average_wage ukazuje priemernú ročnú mzdu pre odvetvie a rok.
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