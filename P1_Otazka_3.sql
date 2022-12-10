/* OTÁZKA 3)
 * Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
 * Stĺpec average_price udáva priemernú cenu potraviny v danom roku.
 * Stĺpec percent_change udáva medziročnú zmenu priemernej ceny.
 * */
CREATE OR REPLACE TABLE t_food_price_change
SELECT `YEAR`, food_name, average_price,
	round(((average_price - (lag(average_price) OVER (PARTITION BY food_name ORDER BY `YEAR`))) * 100) / (lag(average_price) OVER (PARTITION BY food_name ORDER BY `YEAR`)), 2) AS percent_change
FROM t_peter_kubovcik_project_sql_primary_final
GROUP BY `YEAR`, food_name
ORDER BY food_name, `YEAR`;

/* Dotaz 3a)
 * Stĺpec min_difference_percent udáva potravinu, ktorá má medziročne najnižší percentuálny nárast ceny (záporná hodnota znamená zlacnenie oproti predošlému roku, kladná zdraženie)
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

/* Dotaz 3b)
 * Vyhodnotenie zmeny cien každej potraviny v rámci celého sledovaného obdobia.*/
SELECT t1.YEAR, t1.food_name, t1.average_price, t2.average_price, round(((t2.average_price / t1.average_price) * 100 ) - 100, 2) AS percent_change
FROM (
	SELECT `YEAR`, food_name, average_price 
	FROM t_food_price_change
	WHERE `YEAR` = 2006) t1
JOIN (
	SELECT `YEAR`, food_name, average_price
	FROM t_food_price_change
	WHERE `YEAR` = 2018) t2
ON t1.food_name = t2.food_name;