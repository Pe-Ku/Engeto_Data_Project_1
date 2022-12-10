/* OTÁZKA 5)
 * Má výška HDP vliv na změny ve mzdách a cenách potravin? 
 * Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?
 * Stĺpec gdp_change udáva medziročnú zmenu výšky HDP, v %.
 * Stĺpec average_price_change udáva celkový priemerný rast/pokles cien potravín v % medziročne. Vo výpočte sú zahrnuté všetky sledované potraviny.
 * Stĺpec average_wage_change udáva celkový priemerný rast/pokles mezd v % medziročne. Vo výpočte sú zahrnuté všetky odvetvia.
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