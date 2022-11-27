SQL_Project_1
===

Komentare k SQL dotazom:

- **Tabulka porovnání dostupnosti potravin na základě průměrných příjmů za určité časové období.**
Zo zdrojovych dat czechia_price bola vypocitana priemerna cena kazdej potraviny v priebehu rokov. Cena bola spriemerovana vramci vsetkych regionov CR (v datach mezd niesu rozlisene jednotlive regiony, preto data potravin podla tohto kriteria dalej nebudu rozdelene).
Zo zdrojovych dat czechia_payroll bola vypocitana priemerna rocna mzda pre kazde odvetvie v priebehu rokov.
Data, kde nebol vyplneny industry_branch (pracovne odvetvie) boli odfiltrovane.
Neboli pouzite data z prepocitanych prijmov (prijmy prepocitane z inych typov uvazkov ako plny). Porovnavat dostupnost potravin s prepocitanym (a teda nie skutocnym) prijmom podla mna nedava zmysel.
Data mezd boli spracovavane medzi rokmi 2006 a 2018, pretoze v tomto obdobi su k dispozici data potravin. Ostatne obdobia boli odfiltrovane.

- **Tabulka s HDP, GINI koeficientem a populací dalších evropských států ve stejném období, jako primární přehled pro ČR.**
V tabulke su filtrovane data z rokov 2006 az 2018, rovnako ako v primarnej tabulke.

**OTAZKY:**

**1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?**
Bola vytvorena tabulka t_wages_comparison, kde su porovnane priemerne mzdy pre kazde otvedvie v priebehu rokov a percentualna zmena oproti predoslemu roku.
Z tejto tabulky boli realizovane nasledovne dotazy:

*Dotaz 1a*
Vystupom su odvetvia a roky, v ktorych klesla priemerna rocna mzda v porovnani s predoslym rokom.
Data ukazuju, ze napr. v roku 2009 zaznamenali pokles priemernej rocnej mzdy 4 odvetvia. V roku 2013 6 odvetvi.
Priemerne rocne mzdy teda nerastu kontinualne kazdy rok, su urcite obdobia poklesu v zhorsenych ekonomickych podmienkach, napr. 2009.

*Dotaz 1b*
Vystupom je zoznam odvetvi, v ktorych nikdy (medzi sledovanymi rokmi 2006 az 2018) medzirocne neklesla priemerna rocna mzda. Jedna sa o odvetvia Zpracovatelský průmysl, Doprava a skladování, Administrativní a podpůrné činnosti, Zdravotní a sociální péče, Ostatní činnosti.

*Dotaz 1c*
Vystupom je tabulka, z ktorej je zrejme, ze v priebehu sledovaneho useku 2006 az 2018 mzdy vyrastli vo vsetkych odvetviach. Stlpec percent_increase vyjadruje percentualny rozdiel vo vyske mzdy z roku 2006 a 2018.
Je mozne teda konstatovat, ze mzdy rastu v priebehu rokov z dlhodobeho hladiska vo vsetkych odvetviach.

**2. Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?**
Data ukazuju, ze vseobecne napriec vsetkymi odvetviami je mozne kupit viac l mlieka za priemernu rocnu mzdu v roku 2018 ako v roku 2006. Napriklad v odvetvi Doprava a skladování je mozne si kupit o 155l mlieka viac. Vynimkou je odvetvie Peněžnictví a pojišťovnictví, kde je mozne za priemernu rocnu mzdu v roku 2018 kupit o 34l mlieka menej ako v roku 2006.
Avsak, vseobecne napriec vsetkymi odvetviami je mozne kupit menej kg chleba za priemernu rocnu mzdu v roku 2018 v porovnani s 2006. Napriklad v odvetvi Zdravotní a sociální péče je mozne si kupit o 190kg chleba menej. Vynimkami su odvetvia Ostatní činnosti, Těžba a dobývání, Peněžnictví a pojišťovnictví.

**3. Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?**
Vystupom je tabulka, v ktorej je zrejma zmena priemernej ceny vsetkych potravin v priebehu sledovaneho obdobia.
Z tabulky nie je uplne ocividne, ktora kategoria potravin zdrazuje najpomalsie. Zobrazenie v grafe by bolo prehladnejsie a jasnejsie.
Boli pouzite dalsie dotazy:

*Dotaz 3a*
Vyhodnotenie potraviny, ktora ma v dany rok najnizsi percentualny narast (zaporna hodnota znamena zlacnenie oproti predoslemu roku, kladna zdrazenie).
Najvacsi medzirocny rozdiel bol v roku 2007 u potraviny Rajská jablka červená kulatá, a cinil -30.28%.

*Dotaz 3b*
Porovnanie zmeny cien kazdej potraviny v rokoch 2006 a 2018.
Z tabulky je zrejme, ze vsetky potraviny su v roku 2018 drahsie ako v r. 2006, az na Cukr krystalový, ktory je o 27.52% lacnejsi a Rajská jablka červená kulatá, ktore su o 23.07% lacnejsie. Tieto 2 potraviny teda zdrazuju najpomalsie v ramci celeho sledovaneho obdobia.

**4. Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?.**
Takyto rok neexistuje. V roku 2013 rastli ceny potravin v priemere o 6.01% a mzdy v priemere klesli o 0.78%. Rozdiel cini 6.79%.
Opacny pripad nastal v r. 2009, kedy mzdy v priemere rastli o 9.7% viac, ako ceny potravin.

**5. Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?**
Data boli filtrovane len pre CR. Pre ostatne krajiny neboli dostupne data mezd a cien potravin.
Z dat toto nie je mozne potvrdit. Nevyplyva, ze by pre konkretny rok mal rast (pokles) hdp vplyv na ceny alebo mzdy.