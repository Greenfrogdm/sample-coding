
***********
* Table 6 *
***********

mat results = J(6,12,.)
mat t_stat = J(6,12,0) 
mat stars = J(6,12,0) 

local i = 1
foreach y in $outcomes {
	
	local z = 1
	
	foreach x in w_bargain v743a v743b v743c v743d v743e  { // Delete v743f
	qui reg `y' `x' $controls $fe [pw=factor_pond], r

	mat B = e(b)
	mat V = e(V)

	local ols_b = B[1,1]
	local ols_se = V[1,1]^(1/2)
	local obs = e(N)
	
	mat results[`z',4*`i'-3] = `ols_b'
	mat results[`z',4*`i'-2] = `ols_se'
	
	mat t_stat[`z',4*`i'-3] = abs(`ols_b'/`ols_se')
	
	local z = `z' + 1
	}

	qui reg `y' v743a v743b v743c v743d v743e  $controls $fe [pw=factor_pond], r // Delete v743f 
	
	mat R = r(table)		
	mat B = R[1,1..5]'
	mat SE = R[2,1..5]'	
	mat T = R[3,1..5]'
	
	mat results[2,4*`i'-1] = B
	mat results[2,4*`i'] = SE 
	
	mat t_stat[2,4*`i'-1] = T
	
	forval r = 1/6 {
		mat stars[`r',4*`i'-3] = (abs(t_stat[`r',4*`i'-3])>= 1.645)+(abs(t_stat[`r',4*`i'-3])>= 1.96)+(abs(t_stat[`r',4*`i'-3])>= 2.576)
		mat stars[`r',4*`i'-1] = (abs(t_stat[`r',4*`i'-1])>= 1.645)+(abs(t_stat[`r',4*`i'-1])>= 1.96)+(abs(t_stat[`r',4*`i'-1])>= 2.576)
	}

	local i = `i' + 1
}


#delimit ;

frmttable using table_6_robust_separate.doc, statmat(results) sdec(3,3,3) substat(1) 
		  ctitles("", "Stunting", "", "Underweight", "", "Anemia" \
				  "","Separate", "Join", "Separate", "Join", "Separate", "Join")
		  rtitles("Female Bargaining index" \ "" \
				"I. Health Care"\ "" \				
				"II. Large Household Purchases" \ "" \
				"III. Daily Needs Purchases" \ "" \ 
				"IV.  Family Visits" \ "" \
				"V. Food Cooked"\ "") annotate(stars) asymbol(*, **, ***) plain tex fragment  replace ; // 
#delimit cr

