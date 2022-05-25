******************************************
* Dofile to construct the ENDES database *
******************************************
clear all
set more off

global root "C:\Mariano\KU Leuven\2022 (feb - jun)\0. Master Thesis\I. Bargaining power and children outcomes"

cd "$root\2. Input\ENDES"

local y0 2011 // Initial year
local y1 = `y0' + 1 // for appending 
local yf 2020 // End year

qui forval y = `y0'/`yf' { // 
	
	***********************************
	* Keeping only nuclear households *
	***********************************
	* First Filter *
	use `y'\modulo64\rech1.dta, clear
	g hhid_clean = strltrim(hhid)
	g year = `y'
	tostring year, g(year_s)
	g  hhid_s = year_s + hhid_clean
	destring hhid_s, g(hhid_int)
	
	rename hv101 HH_rel
	
	* Deleting HH with other than siblings *
	g other_rel = 0 
	replace other_rel = 1 if HH_rel > 3 & HH_rel != .
	bys hhid_int: egen sum1 = total(other_rel)
	keep if sum1 == 0

	* Deleting HH with no (below 5) chidren *
	replace HH_rel = 3 if HH_rel == .
	g child = 0
	replace child = 1 if HH_rel == 3 & hv120 == 1
	bys hhid_int: egen sum2 = total(child)
	drop if sum2 == 0

	* Deleting Monoparental HH *
	g partner_HH = 0
	replace partner_HH = 1 if HH_rel == 2
	bys hhid_int: egen sum3 = total(partner_HH)
	drop if sum3 == 0
	egen siblings = count (HH_rel ==3), by(hhid_int)
	
	collapse (first) hhid_int hhid_s siblings, by (hhid)
	
	keep hhid hhid_s hhid_int siblings
	
	save `y'\Working_bases\filtering_characteristics.dta, replace
	
	
	*Geographic characteristics* // for constructing instruments using ubigeo | NOT AVAILABLE FOR ALL SAMPLE
	
	use `y'\modulo64\rech0.dta, clear
	g year = `y'
	rename (hv009) (n_hh_members) // Last addition, be careful
	keep hhid n_hh_members
	*rename (hv005 hv040) (h_factor_pond altitud)
	*keep hhid ubigeo longitudx latitudy h_factor altitud
	
	save `y'\Working_bases\geo_characteristics.dta, replace
	
	
	*************************************
	* a) HH and Mother's characteristics*
	*************************************
	
	*I. Household Demographics*
	use `y'\modulo66\rec0111.dta, clear
	
	g year = `y'

	rename (v190 v191 v005 v012 v024 v025 v137 v104 v151) ///
		   (quintil wealth_index factor_pond m_age region urban n_children_b5 years_there hh_gender)
	
	replace wealth_index = wealth_index/100000
	recode urban (2=0)
	recode hh_gender (2 = 1) (1 = 0)
	keep factor_pond caseid quintil wealth_index m_age region urban n_children_b5 years_there hh_gender
		  
	save `y'\Working_bases\hh_characteristics.dta, replace
	
	* II. Individual Characteristics*
	use `y'\modulo66\rec91.dta, clear

	g year = `y'

	cap rename (s108n) (m_education)
	cap rename (s108y) (m_l_education_year)
	cap rename (s108g) (m_l_education_grade)
	cap rename (s704n) (p_education)
	cap rename (s704y) (p_l_education_year)
	cap rename (s704g) (p_l_education_grade)
	cap rename (sprovin) (province)
	cap rename (sdistri) (district)
	cap rename (s119)  (mother_tongue)
	cap rename (s1026) (close_violence)
	
	keep m_education m_l_education_year m_l_education_grade p_education /// 
		 p_l_education_year p_l_education_grade mother_tongue close_violence province district s493* caseid year
	
	g i_mother_tongue = 0
	replace i_mother_tongue = 1 if (mother_tongue != 1 & year < 2018)
	replace i_mother_tongue = 1 if (mother_tongue != 10 & year >= 2018)
	
	replace close_violence = . if close_violence > 1
	
	g m_educ_years = 0
	replace m_educ_years = 0 if m_education == 0 
	replace m_educ_years = m_l_education_grade if m_education == 1 // primaria 
	replace m_educ_years = 6 + m_l_education_year if m_education == 2 // secundaria
	replace m_educ_years = 11 + m_l_education_year if (m_education == 3) | (m_education == 4) // 
	replace m_educ_years = 16 + m_l_education_year if (m_education == 5) // 
			
	save `y'\Working_bases\individual_characteristics.dta, replace


	* III. Working and empowerment characteristics*
	use `y'\modulo71\re516171.dta, clear

	g year = `y'
	
	rename (v501 v504 v511 v729 v714 v715 v716 v730 v741 v746) ///
	(civil_state living_together age_married p_education m_work p_educ_years m_occupation p_age m_payment wage_dif)
	recode civil_state (2=0)
	keep if living_together == 1
	
	recode v743* v739 (0 4 5 = 1) (1 = 3) (3 = 2)	
	
	label define decision 1 "Parter" 2 "Together with partner" 3 "Only she"
	label values v743* v739 decision
	
	*pca v743*
	pca v743a v743b v743c v743d v743e // there are some husbands that do not generate income | CHECK if I use this or the other
	predict w_bargain, score // A higher level, a higher (female) bargaining power
	
	keep caseid civil_state living_together age_married m_work p_educ_years m_occupation p_age m_payment wage_dif v739 v743* w_bargain
		
	merge 1:1 caseid using "`y'\Working_bases\individual_characteristics.dta", keep(match) nogen
	merge 1:1 caseid using "`y'\Working_bases\hh_characteristics.dta", keep(match) nogen
	
	save `y'\Working_bases\mother_characteristics.dta, replace
	
	* IV. Domestic violence * // NOTE: So far, available DB just from 2017-2019 
	
	use `y'\modulo73\rec84dv.dta, clear
	
	rename (d104 d106 d107 d108 d121) ///
		   (emotional_violence violence_1 violence_2 sexual_violence past_family_violence)
		   
	keep caseid emotional_violence violence_1 violence_2 sexual_violence past_family_violence
	
	merge 1:1 caseid using "`y'\Working_bases\mother_characteristics.dta", keep(match) nogen
	
	save `y'\Working_bases\mother_characteristics.dta, replace

	
	* V. Dietary habits * 
	use `y'\modulo70\rec42.dta, clear
	keep caseid v414* v481 v462 v457 v437 v438
	rename (v481 v462 v457 v437 v438) (health_insurance hand_wash mom_anemia m_weight m_height)
	g m_bmi = (m_weight/10)/((m_height/1000)^2)
	merge 1:1 caseid using "`y'\Working_bases\mother_characteristics.dta", keep(match) nogen
	save `y'\Working_bases\mother_characteristics.dta, replace
	
	*********************************
	* b) Children's characteristics *
	*********************************
	
	use `y'\modulo74\rech6.dta, clear

	g year = `y'

	rename (hc1 hc2 hc3 hc27 hc56 hc57 hc60 hc61 hc64 hc70 hc71) ///
		   (age_months weight height gender hemoglobin anemia m_order m_n_educ child_number hta wta)
		   
	keep hhid hc0 age_months weight height gender hemoglobin anemia m_order m_n_educ child_number year hta wta
	
	*decode mother_order, g(mother_order_s)
	tostring m_order, g(m_order_s)
	g caseid =  hhid + "  " + m_order_s
	
	* Special case for 2012:
	{
	replace caseid = hhid + " 0" + m_order_s if (year == 2011 | year == 2012) 
	}
	
	drop m_order_s
	
	g hhid_clean = strltrim(hhid)
	tostring year, g(year_s)
	g  hhid_s = year_s + hhid_clean
	destring hhid_s, g(hhid_int)
	
	save `y'\Working_bases\children_h_outcomes.dta, replace
	
	********************************************************
	* c) Merging children's with mother's charactericstics *
	********************************************************
	
	merge m:1 caseid using `y'\Working_bases\mother_characteristics.dta, keep(match) nogen
	merge m:1 hhid_s using `y'\Working_bases\filtering_characteristics.dta, keep(match) nogen // GIVE A LOOK TO THIS FOR 2012-2014
	merge m:1 hhid using `y'\Working_bases\geo_characteristics.dta, keep(match) nogen
	
	save `y'\Working_bases\wb_`y'.dta, replace 
	
}

use `y0'\Working_bases\wb_`y0'.dta, clear

qui	forval y = `y1'/`yf' {

	append using `y'\Working_bases\wb_`y'.dta

	}
	
********************************
* Constructing Health outcomes *
********************************

qui {
	
* Dichotomic anemia *
g m_anemia = 0 if anemia != .
g s_anemia = 0 if anemia != .

replace m_anemia = 1 if (anemia == 1 | anemia == 2 | anemia == 3)
replace s_anemia = 1 if (anemia == 1 | anemia == 2)

recode gender (1 = 0) (2 = 1)
label define gender_label 0 "Boy" 1 "Girl"
label values gender gender_label   

preserve
	import excel "$root\Otros\hfa_boys", clear first
	drop if age_months == .
	tempfile hfa_boys
	save `hfa_boys'
	
	import excel "$root\Otros\hfa_girls", clear first
	drop if age_months == .
	tempfile hfa_girls
	save `hfa_girls'
	
	import excel "$root\Otros\wfa_boys", clear first
	drop if age_months == .
	tempfile wfa_boys
	save `wfa_boys'	

	import excel "$root\Otros\wfa_girls", clear first
	drop if age_months == .
	tempfile wfa_girls
	save `wfa_girls'

restore

merge m:1 age_months gender using `hfa_boys', keepusing(hfa_sd2neg hfa_sd3neg hfa_m hfa_sd) keep(1 3) nogen
merge m:1 age_months gender using `hfa_girls', keepusing(hfa_sd2neg hfa_sd3neg hfa_m hfa_sd) keep(1 3 4) nogen update replace
merge m:1 age_months gender using `wfa_boys', keepusing(wfa_sd1neg wfa_sd2neg wfa_sd3neg wfa_m wfa_sd) keep(1 3) nogen
merge m:1 age_months gender using `wfa_girls', keepusing(wfa_sd1neg wfa_sd2neg wfa_sd3neg wfa_m wfa_sd) keep(1 3 4) nogen update replace

replace height = height/10 // now in cm.
replace weight = weight/10 // now in kg.

g m_stunting = (height < hfa_sd2neg) if (height != . & hfa_sd2neg != .)
g s_stunting = (height < hfa_sd3neg) if (height != . & hfa_sd3neg != .)

g m_underweight = (weight < wfa_sd2neg) if (weight != . & wfa_sd2neg != .)
g s_underweight = (weight < wfa_sd3neg) if (weight != . & wfa_sd2neg != .)

* Generating Z-scores *
g haz = (height - hfa_m)/hfa_sd
g waz = (weight - wfa_m)/wfa_sd

* Standarizing bargaining power: to interpret coefficients as ... * 
foreach y in w_bargain v743a v743b v743c v743d v743e v743f v739 { // 
	sum `y'
	replace `y' = (`y' - r(mean))/r(sd)	
}
}

*******************************
* Other variable construction *
*******************************
qui {
* Generating instruments *
* I. Age difference *
g age_dif = m_age - p_age

* Dietary Score (DDS) * 
qui foreach y of varlist v414a-v414s {
    replace `y' = . if `y' == 8
	*replace `y' = 0 if `y' == .
}

g d_cereals_tubers = (v414e == 1 | v414f == 1) if (v414e != . | v414f != .)
g d_eggs =  (v414g == 1) if (v414g != .)
g d_dairy = (v414p == 1) if (v414p != .)
g d_meat = (v414h == 1) if (v414h != .)
g d_legumes = (v414o == 1) if (v414o != .)
g d_vitamin_a = (v414k == 1 | v414i == 1) if (v414k != . | v414i != .)
g d_other_vegetables = (v414j == 1) if (v414j != .)
g d_other_fruits = (v414l == 1) if (v414l != .)
g d_fats = (v414q == 1) if (v414q != .)

egen dds = rowtotal(d_*)

* Generating code_district
tostring region province district , g(s_region s_province s_district)
replace s_region = "0" + s_region if length(s_region) != 2
replace s_province = "0" + s_province if length(s_province) != 2
g code_province = s_region + s_province	

* Generating additional dummies
tab region, g(i_region)
tab year, g(i_year)
tab quintil, g(i_quintil)
encode code_province, g(code_province_i)
replace years_there = m_age if years_there == 95
replace years_there = 0 if years_there == 96

g violence = (violence_1 == 1| violence_2 == 1)
g l_m_bmi = ln(m_bmi)
g d_mom_anemia = (mom_anemia < 4) & mom_anemia != .

}

* Dropping outliers
qui foreach y in hemoglobin weight height haz waz {
	lv `y'
	local ub_`y' = r(u_X)
	local lb_`y' = r(l_X)
}

qui foreach y in hemoglobin weight height haz waz {
	drop if (`y' <  `lb_`y'' | `y' > `ub_`y'' ) & (`y' != .)
	
}

***********************
* Merging instruments *
***********************

forval y = 2004/2006 {
merge m:1 code_province using "$root\3. Output\Temporals\lagged_wtm_`y'_2009.dta", keepusing(wtm_ratio) nogen	
g ln_wtm_ratio_`y'_2009 = ln(wtm_ratio_`y'_2009)
}

forval y = 2005/2007 {
merge m:1 code_province using "$root\3. Output\Temporals\lagged_wtm_`y'_2010.dta", keepusing(wtm_ratio) nogen	
g ln_wtm_ratio_`y'_2010 = ln(wtm_ratio_`y'_2010)
}

merge m:1 code_province using "$root\3. Output\Temporals\lagged_wtm_2006_2008.dta", keepusing(wtm_ratio) nogen	
g ln_wtm_ratio_2006_2008 = ln(wtm_ratio_2006_2008)

rename (ln_wtm_ratio_2006_2010 ln_wtm_ratio_2006_2009 ln_wtm_ratio_2006_2008) (ln_wtm_ratio_5y ln_wtm_ratio_4y ln_wtm_ratio_3y)

* Generating data for maps *
preserve
	collapse (mean) w_bargain ln_wtm_ratio_5y wtm_ratio_2006_2010 (first) region [pw=factor_pond], by(code_province)
	save "$root\3. Output\Temporals\province_level_BPI.dta", replace
restore

run "$root\4. dofiles\0. Processing data\globals.do"

compress 

save "C:\Mariano\KU Leuven\2022 (feb - jun)\0. Master Thesis\I. Bargaining power and children outcomes\3. Output\Database\final_base.dta", replace


exit


