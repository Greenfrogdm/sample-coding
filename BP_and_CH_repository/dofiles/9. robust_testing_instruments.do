
***********
* Table 8 *
***********

mat results = J(11,6,.)
mat t_stat = J(11,6,0) 
mat stars = J(11,6,0) 

local i = 1

qui foreach y in $outcomes {
	
	* IV: exactly identified *
	forval k = 1/6 {
	xi: ivregress 2sls `y' $controls $fe (w_bargain = ${instrument_`k'})  [pw=factor_pond],  r
			  
	mat R = r(table)		
	mat B_`k' = R[1,1]'
	mat SE_`k' = R[2,1]'	
	mat T_`k' = R[3,1]'
	matewmf T_`k' T_`k', f(abs)
	
	local obs = e(N)
	
		if `k' > 3 {		
		overid 
		mat j_`k' = r(j_oid)
		mat p_j_`k' = r(p_oid)
		}
	}
		
	* Imputting outcomes into 'results' matrix
	******************************************
	* From rows 1 to 3:
	mat results[1,2*`i'-1] = B_1
	mat results[1,2*`i'] = SE_1
	mat results[2,2*`i'-1] = B_2
	mat results[2,2*`i'] = SE_2
	mat results[3,2*`i'-1] = B_3
	mat results[3,2*`i'] = SE_4	

	* Note: Row 4 is empty

	mat results[5,2*`i'-1] = B_4
	mat results[5,2*`i'] = SE_4
	mat results[6,2*`i'-1] = j_4
	mat results[6,2*`i'] = p_j_4
	
	mat results[7,2*`i'-1] = B_5
	mat results[7,2*`i'] = SE_5
	mat results[8,2*`i'-1] = j_5
	mat results[8,2*`i'] = p_j_5

	mat results[9,2*`i'-1] = B_6
	mat results[9,2*`i'] = SE_6
	mat results[10,2*`i'-1] = j_6
	mat results[10,2*`i'] = p_j_6
	
	mat t_stat[1,2*`i'-1]  = T_1
	mat t_stat[2,2*`i'-1]  = T_2
	mat t_stat[3,2*`i'-1]  = T_3
	mat t_stat[5,2*`i'-1]  = T_4
	mat t_stat[7,2*`i'-1]  = T_5
	mat t_stat[9,2*`i'-1]  = T_6
	
	mat results[11,2*`i'-1] = `obs'


	forval r = 1/9 {
		mat stars[`r',2*`i'-1] = (t_stat[`r',2*`i'-1]>= 1.645)+(t_stat[`r',2*`i'-1]>= 1.96)+(t_stat[`r',2*`i'-1]>= 2.576)
	}

* Note: I might be forgetting of include siblings in the summary statistics table

	local i = `i' + 1
}

	
* NOTE: GMM equality test are delivered in other do-file. Estimation of that dofile can take up to 2 days.

#delimit ;

frmttable using table_8_robust_instruments.doc, statmat(results) sdec(3,3,3) substat(1) 
		  ctitles("", "Stunting", "Underweight", "Anemia")
		  rtitles("5 year window" \ "" \
				"4 year window"\ "" \				
				"3 year window" \ "" \
				"Overidentified estimators"\""\
				"+ Age dif"\""\
				"  J-Test"\""\				
				"Heterogeneous effects across years"\""\
				" J-Test" \ "" \ 
				"Heterogeneous effects across years + age dif"\""\
				" J-Test" \ "" \ 
				"Observations" \ "") annotate(stars) asymbol(*, **, ***) plain tex fragment replace ; // 
#delimit cr