
***********
* Table 5 *
***********

local i = 1
qui foreach y in $outcomes {
	
	forval g = 0/1 {
		
		mat results_`i'_`g' = J(4,4,.)
		mat stars_`i'_`g' = J(4,4,0) 

		reg `y' w_bargain $controls $fe if urban == `g' [pw=factor_pond] , r

		mat R = r(table)		
		mat B_1 = R[1,1..3]'
		mat SE_1 = R[2,1..3]'	
		mat T_1 = R[3,1..3]'
		matewmf T_1 T_1, f(abs)
		
		local obs_`g' = e(N)
		
		mean `y' if urban == `g' & e(sample) [pw=factor_pond] 
		mat m = e(b)

		ivregress 2sls `y' $controls $fe (w_bargain = $instrument) if urban == `g' [pw=factor_pond], r

		mat R = r(table)		
		mat B_2 = R[1,1..3]'
		mat SE_2 = R[2,1..3]'	
		mat T_2 = R[3,1..3]'
		matewmf T_2 T_2, f(abs)
		
		* Filling results matrix
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
			mat stars_`i'_`g'[`r', `c'] = (t_stat_`i'_`g'[`r',`c']>= 1.645)+(t_stat_`i'_`g'[`r',`c']>= 1.96)+(t_stat_`i'_`g'[`r',`c']>= 2.576)
			}
		}
		
	}
		
	mat extra_`i' =  J(4,4,.)
	mat stars_extra_`i' = J(4,4,0)
	
	qui reg `y' w_bargain c.w_bargain#c.urban  $controls $fe [pw=factor_pond] , cluster(hhid_int)
				
	mat R = r(table)		
	mat B = R[1,1..2]'
	mat SE = R[2,1..2]'	
	mat T = R[3,1..2]'
	matewmf T T, f(abs)
	
	mat extra_`i'[1,1] = B
	mat extra_`i'[1,2] = SE
	mat extra_`i'[3,1] = [`obs_0' , . , `obs_0', .]
	mat extra_`i'[4,1] = [`obs_1' , . , `obs_1', .]
	
	forval r = 1/2 {
			mat stars_extra_`i'[`r', 1] = (T[`r',1]>= 1.645)+(T[`r',1]>= 1.96)+(T[`r',1]>= 2.576)
			}
			
	local i = `i' + 1
}


mat sup1 = J(1,4,.)
mat sup2 = J(1,4,0)


forval outcome = 1/3 {
    
	mat results_`outcome'_urban = [sup1\ results_`outcome'_0 \ sup1 \ results_`outcome'_1 \ sup1 \ extra_`outcome'] 
	mat stars_`outcome'_urban = [sup2\stars_`outcome'_0 \ sup2 \ stars_`outcome'_1 \ sup2 \ stars_extra_`outcome'] 

}
  
mat results_urban = [results_1_urban, results_2_urban, results_3_urban]
mat stars_urban = [stars_1_urban, stars_2_urban, stars_3_urban]


#delimit ;

frmttable using table_5_urban_results.doc, statmat(results_urban) sdec(3,3,3) substat(1) 
		  ctitles("", "Stunting", "", "Underweight", "", "Anemia" \
				  "", "OLS", "IV", "OLS", "IV", "OLS", "IV")
		  rtitles("Panel A: Rural"\ "" \
				"Bargaining Power Index" \ "" \
				"Mother's education years"\ "" \				
				"Mother's work status" \ "" \
				"Mean of dep. var."\ "" \
				"Panel B: Urban"\""\
				"Bargaining Power Index" \ "" \
				"Mother's education years"\ "" \				
				"Mother's work status" \ "" \
				"Mean of dep. var."\ "" \
				"Panel C: Pooled sample" \ "" \
				"BPI" \ "" \
				"BPI$\times$Urban"\""\
				"Observations Rural" \ "" \
				"Observations Urban" \ "") annotate(stars_urban) asymbol(*, **, ***) plain tex fragment replace ; // 
#delimit cr

exit
