/* OTÁZKA 4)
 * Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
 * Stĺpec average_price_change udáva celkový priemerný rast/pokles cien potravín v % medziročne. Vo výpočte sú zahrnuté všetky sledované potraviny.
 * Stĺpec average_wage_change udáva celkový priemerný rast/pokles mezd v % medziročne. Vo výpočte sú zahrnuté všetky odvetvia.
 * Stĺpec percent_difference je rozdiel medzi priemerným mezdiročným nárastom cien potravín a priemerným medziročným nárastom mezd, vyjadrené v percentách.
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