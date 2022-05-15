******************
* Master do-file *
******************
* Paper: Female bargaining power and children's nutrition: Evidence for Peru
* Author: Mariano Montoya
* Last edition: 15.05.2022

clear all
set more off

global root "C:\Mariano\KU Leuven\2022 (feb - jun)\0. Master Thesis\I. Bargaining power and children outcomes\4. dofiles\BP_and_CH_repository\"

* Uploading final data base
use "$root\data\final_base.dta"
run "$root\dofiles\globals.do"

**********************
* Tables replication *
**********************
cd "$root\output\tables"

* Table 1: Summary statistics *
do "$root\dofiles\1. summary_statistics.do"

* Table 2: OLS results *
do "$root\dofiles\2. main_results_ols.do"

* Table 3: OLS and IV results *
do "$root\dofiles\3. main_results_ols_and_iv.do"

* Table 4: Results by gender *
do "$root\dofiles\4. results_by_gender.do"

* Table 5: Results by geo-domain *
do "$root\dofiles\5. results_by_geo.do"

* Table 6: Results dissagregated by bargaining domain *
do "$root\dofiles\6. robust_dimensions.do"

* Table 7: Results using continuos outcomes *
do "$root\dofiles\7. robust_other_outcomes.do"

* Table 8: Testing other IV specifications *
do "$root\dofiles\8. robust_testing_instruments.do"

