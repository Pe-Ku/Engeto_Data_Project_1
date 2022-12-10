/* OTÁZKA 1)
 * Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají? 
 * Stĺpec difference ukazuje medziročnú zmenu priemernej mzdy v CZK. Percentuálne vyjadrenie v stĺpci percent_change.
 * Stĺpec difference_comment obsahuje hodnotu DOWN, ak priemerná mzda medziročne klesla. Stagnate = stagnácia. UP = rast.
 * */
CREATE OR REPLACE TABLE t_wages_comparison AS
SELECT `YEAR`, industry_name, average_wage,
	average_wage - (lag(average_wage) OVER (PARTITION BY industry_name ORDER BY `YEAR`)) AS difference,
	round(((average_wage - (lag(average_wage) OVER (PARTITION BY industry_name ORDER BY `YEAR`))) * 100) / (lag(average_wage) OVER (PARTITION BY industry_name ORDER BY `YEAR`)), 2) AS percent_change,
	CASE 
		WHEN average_wage - (lag(average_wage) OVER (PARTITION BY industry_name ORDER BY `YEAR`)) < 0 THEN 'DOWN'
		WHEN average_wage - (lag(average_wage) OVER (PARTITION BY industry_name ORDER BY `YEAR`)) = 0 THEN 'STAGNATE'
		WHEN average_wage - (lag(average_wage) OVER (PARTITION BY industry_name ORDER BY `YEAR`)) > 0 THEN 'UP'
	END AS difference_comment
FROM t_peter_kubovcik_project_sql_primary_final
GROUP BY `YEAR`, industry_name
ORDER BY industry_name, `YEAR`;


/* Dotaz 1a)
 * Odvetvia a roky, v ktorých klesla medziročne priemerná mzda o hodnotu difference, percentuálne vzjadrenie v stĺpci percent_change. 
 * */
SELECT *
FROM t_wages_comparison
WHERE difference_comment = 'DOWN'
GROUP BY industry_name;


/* Dotaz 1b)
 * U týchto odvetví nikdy medziročne neklesla priemerná mzda.
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


/* Dotaz 1c)
 * V rámci celého sledovaného obdobia od r. 2006 do r. 2018 mzdy vyrástli vo všetkých odvetviach. 
 * Stĺpec wage_increase je zmena priemernej mzdy medzi rokmi 2006 a 2018. Percentuálne vyjadrenie v stĺpci percent_increase.
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
