
***********
* Table 4 *
***********

local i = 1
qui foreach y in $outcomes {
	
	forval g = 0/1 {
		
		mat results_`i'_`g' = J(4,4,.)
		mat stars_`i'_`g' = J(4,4,0) 

		reg `y' w_bargain $controls $fe if gender == `g' [pw=factor_pond] , r

		mat R = r(table)		
		mat B_1 = R[1,1..3]'
		mat SE_1 = R[2,1..3]'	
		mat T_1 = R[3,1..3]'
		matewmf T_1 T_1, f(abs)
		
		local obs_`g' = e(N)
		local df = e(df_r)
		
		mean `y' if gender == `g' & e(sample) [pw=factor_pond] 
		mat m = e(b)
		
		qui ivregress 2sls `y'  $controls $fe  (w_bargain = $instrument) ///
			if gender == `g' [pw=factor_pond], r

		mat R = r(table)		
		mat B_2 = R[1,1..3]'
		mat SE_2 = R[2,1..3]'	
		mat T_2 = R[3,1..3]'
		matewmf T_2 T_2, f(abs)
		
		mat results_`i'_`g'[1,1] = B_1
		mat results_`i'_`g'[1,2] = SE_1
		mat results_`i'_`g'[1,3] = B_2
		mat results_`i'_`g'[1,4] = SE_2
		
		* Mean of h. outcome
		mat results_`i'_`g'[4,1] = m
		mat results_`i'_`g'[4,3] = m
		
		mat empty = J(3,1,0)
		mat t_stat_`i'_`g' = [T_1, empty, T_2, empty]
		
		foreach c in 1 3 {
			forval r = 1/3 {
			mat stars_`i'_`g'[`r', `c'] = (t_stat_`i'_`g'[`r',`c']> invttail(`df', 0.1/2)) ///
			+ (t_stat_`i'_`g'[`r',`c'] > invttail(`df',0.05/2)) + ///
			(t_stat_`i'_`g'[`r',`c']> invttail(`df',0.01/2))
			}
		}

	}
	
	* For Panel C of the table
	mat extra_`i' =  J(4,4,.)
	mat stars_extra_`i' = J(4,4,0)
	
	qui reg `y' w_bargain c.w_bargain#c.gender   $controls $fe [pw=factor_pond] , r
				
	mat R = r(table)		
	mat B = R[1,1..2]'
	mat SE = R[2,1..2]'	
	mat T = R[3,1..2]'
	matewmf T T, f(abs)
	local df = e(df_r)
	
	mat extra_`i'[1,1] = B
	mat extra_`i'[1,2] = SE
	mat extra_`i'[3,1] = [`obs_0' , . , `obs_0', .]
	mat extra_`i'[4,1] = [`obs_1' , . , `obs_1', .]
	
	forval r = 1/2 {
			mat stars_extra_`i'[`r', 1] = (T[`r',1]> invttail(`df', 0.1/2)) + ///
			(T[`r',1]> invttail(`df', 0.05/2)) + (T[`r',1]> invttail(`df', 0.01/2))
		}
			
	local i = `i' + 1
}


mat sup1 = J(1,4,.)
mat sup2 = J(1,4,0)


forval outcome = 1/3 {
    
	mat results_`outcome'_gender = [sup1\ results_`outcome'_0 \ sup1 \ results_`outcome'_1 \ sup1 \ extra_`outcome'] 
	mat stars_`outcome'_gender = [sup2\stars_`outcome'_0 \ sup2 \ stars_`outcome'_1 \ sup2 \ stars_extra_`outcome'] 

}
  
mat results_gender = [results_1_gender, results_2_gender, results_3_gender]
mat stars_gender = [stars_1_gender, stars_2_gender, stars_3_gender]


#delimit ;

frmttable using table_4_gender_results.doc, statmat(results_gender) sdec(3,3,3) substat(1) 
		  ctitles("", "OLS", "IV")
		  rtitles("Panel A: Boys"\ "" \
				"Bargaining Power Index" \ "" \
				"Mother's education years"\ "" \				
				"Mother's work status" \ "" \
				"Mean of dep. var."\ "" \
				"Panel B: Girls"\""\
				"Bargaining Power Index" \ "" \
				"Mother's education years"\ "" \				
				"Mother's work status" \ "" \
				"Mean of dep. var."\ "" \
				"Panel C: Pooled sample" \ "" \
				"BPI" \ "" \
				"BPI#Gender"\""\
				"Observations boys" \ "" \
				"Observations girls" \ "") annotate(stars_gender) asymbol(*, **, ***) plain tex fragment replace ; // 
#delimit cr


