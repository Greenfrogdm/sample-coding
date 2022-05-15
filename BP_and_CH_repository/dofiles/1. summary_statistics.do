
**********************
* Variable labelling *
**********************

la var gender "Gender (Girl = 1)"
la var age_months "Age (months)"
la var weight "Weight (kg)"
la var height "Height (cm)"
la var n_children_b5 "Nº children below 5"
la var m_educ_years "Mother's years of schooling"
la var p_educ_years "Father's years of schooling"
la var civil_state "Civil state"
la var urban "Urban"
la var i_mother_tongue "Indigenous Mother Tongue"

*******************************
* Table 1: Summary statistics *
*******************************

global child_vars gender age_months weight height 
global parents_vars m_educ_years p_educ_years m_age n_children_b5 civil_state i_mother_tongue urban  
global outcomes m_underweight s_underweight m_stunting s_stunting m_anemia s_anemia

local sum_vars $child_vars $parents_vars $outcomes
local y0 2011
local y1 2020
local ref_years `y0' `y1'

local n_k:  word count = `sum_vars'
local i = 1

foreach y in `ref_years' {

		matrix summary_`y' = J(`n_k' , 2, .)
		matrix obs_`y' = J(1 , 1, .)

		qui mean `sum_vars' if year == `y' [pw=factor_pond]
		local obs = e(N)
		g in_sample_`y' = (e(sample))
			
		matrix summary_`y'[`n_k' , 1] = `obs'

		foreach x in  `sum_vars' {

			qui mean `x' if year == `y' & in_sample_`y'== 1 [pw=factor_pond]

			matrix A = e(b)
			matrix V = e(sd)
					
			local mean_b = A[1,1]
			local sd_b = V[1,1]
					
			matrix summary_`y'[`i',1] = `mean_b'
			matrix summary_`y'[`i',2] = `sd_b'
		
			local i = `i' + 1
			
		}	
		
		*levelsof hhid_int if year == `y' & in_sample_`y'== 1
		*noisily di r(r)		
		
		local i = 1

}

* Whole sample *
matrix summary = J(`n_k' , 2, .)
matrix obs = J(1 , 1, .)

qui mean `sum_vars' [pw=factor_pond]
local obs = e(N)
g in_sample = (e(sample))
	
matrix summary[`n_k' , 1] = `obs'

foreach x in  `sum_vars' {
	qui mean `x' if in_sample == 1 [pw=factor_pond]

	matrix A = e(b)
	matrix V = e(sd)
			
	local mean_b = A[1,1]
	local sd_b = V[1,1]
			
	matrix summary[`i',1] = `mean_b'
	matrix summary[`i',2] = `sd_b'

	local i = `i' + 1
	
}	


* Summary statistics 2011 *

#delimit ;

frmttable , statmat(summary_`y0') sdec(2,2,2) substat(1) 
		  ctitles("", "{\b `y0'}"\
				  "", "Mean") 
		  rtitles("Gender (girl = 1)" \ "" \
				"Age (months)"\ "" \				
				"Weight" \ "" \ 
				"Height" \ "" \
				"Mother's years of schooling" \ "" \ 
				"Father's years of schooling" \"" \ 
				"Mother's age"\"" \ 
				"Nº of children below 5 in the HH"\"" \ 
				"Married parents" \ "" \
				"Indigenous mother tongue"\ "" \
				"Living in an urban area" \ "" \
				"Moderate underweight" \ "" \
				"Severe underweight" \ "" \
				"Moderate stunting" \ "" \
				"Severe stunting" \ "" \
				"Moderate anemia" \ "" \
				"Severe anemia" \ "" \
				"Observations" \ "") replace ; // 
#delimit cr


* Summary statistics 2020 *

#delimit ;

frmttable , statmat(summary_`y1') sdec(2,2,2) substat(1) 
		  ctitles("", "{\b `y1'}"\
				  "", "Mean") 
		  rtitles("Gender (girl = 1)" \ "" \
				"Age (months)"\ "" \				
				"Weight" \ "" \ 
				"Height" \ "" \
				"Mother's years of schooling" \ "" \ 
				"Father's years of schooling" \"" \ 
				"Mother's age"\"" \ 
				"Nº of children below 5 in the HH"\"" \ 
				"Married parents" \ "" \
				"Indigenous mother tongue"\ "" \
				"Living in an urban area" \ "" \
				"Moderate underweight" \ "" \
				"Severe underweight" \ "" \
				"Moderate stunting" \ "" \
				"Severe stunting" \ "" \
				"Moderate anemia" \ "" \
				"Severe anemia" \ "" \
				"Observations" \ "")replace merge ; // 
#delimit cr

* Whole sample summaray *

#delimit ;

frmttable using table_1_summary.doc, statmat(summary) sdec(2,2,2) substat(1) 
		  ctitles("", "Total"\
				  "", "Mean") 
		  rtitles("Gender (girl = 1)" \ "" \
				"Age (months)"\ "" \				
				"Weight" \ "" \ 
				"Height" \ "" \
				"Mother's years of schooling" \ "" \ 
				"Father's years of schooling" \"" \ 
				"Mother's age"\"" \ 
				"Nº of children below 5 in the HH"\"" \ 
				"Married parents" \ "" \
				"Indigenous mother tongue"\ "" \
				"Living in an urban area" \ "" \
				"Moderate underweight" \ "" \
				"Severe underweight" \ "" \
				"Moderate stunting" \ "" \
				"Severe stunting" \ "" \
				"Moderate anemia" \ "" \
				"Severe anemia" \ "" \
				"Observations" \ "") coljust(l{c}) plain tex fragment replace merge ; // 
#delimit cr
