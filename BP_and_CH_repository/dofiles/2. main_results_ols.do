
***************
* Regressions *
***************
global outcomes stunting underweight anemia

mat results = J(6,12,.)
mat t_stat = J(6,12,0) 
mat stars = J(6,12,0) 

local i = 1
foreach y in $outcomes {
	
	* Moderate Outcome *
	qui reg m_`y' w_bargain $controls $fe [pw=factor_pond], r
	
	mat R = r(table)		
	mat B_1 = R[1,1..3]'
	mat SE_1 = R[2,1..3]'	
	mat T_1 = R[3,1..3]'
	matewmf T_1 T_1, f(abs)
	
	local obs = e(N)

	qui mean m_`y' if e(sample) [pw=factor_pond]
	mat B = e(b)
	local mean_y1 = B[1,1]

	* Severe Outcome *
	qui reg s_`y' w_bargain $controls $fe [pw=factor_pond], r

	mat B = e(b)
	mat V = e(V)
	mat F = e(first)
	
	mat R = r(table)		
	mat B_2 = R[1,1..3]'
	mat SE_2 = R[2,1..3]'	
	mat T_2 = R[3,1..3]'
	matewmf T_2 T_2, f(abs)
	
	qui mean s_`y' if e(sample) [pw=factor_pond]
	mat B = e(b)
	local mean_y2 = B[1,1]
	
	****************************
	mat results[1,4*`i'-3] = B_1
	mat results[1,4*`i'-2] = SE_1
	mat results[1,4*`i'-1] = B_2
	mat results[1,4*`i'] = SE_2

	mat t_stat[1,4*`i'-3]  = T_1
	mat t_stat[1,4*`i'-1]  = T_2
	
	* Row 4: empty

	mat results[5,4*`i'-3] = `mean_y1'
	mat results[5,4*`i'-1] = `mean_y2'
	
	mat results[6,4*`i'-3] = `obs'
	mat results[6,4*`i'-1] = `obs'

	* Row 3: empty

	forval r = 1/3 {
	mat stars[`r',4*`i'-3] = (t_stat[`r',4*`i'-3]>= 1.645)+(t_stat[`r',4*`i'-3]>= 1.96)+(t_stat[`r',4*`i'-3]>= 2.576)
	mat stars[`r',4*`i'-1] = (t_stat[`r',4*`i'-1]>= 1.645)+(t_stat[`r',4*`i'-1]>= 1.96)+(t_stat[`r',4*`i'-1]>= 2.576)
	}

	local i = `i' + 1
}


#delimit ;

frmttable using table_2_ols_results.doc, statmat(results) sdec(3,3,3) substat(1) 
		  ctitles("", "Stunting", "Stunting", "Underweight", "Underweight", "Anemia", "Anemia")
		  rtitles("Bargaining Power Index" \ "" \
				"Mother's education years"\ "" \				
				"Mother's work status" \ "" \
				"" \ "" \
				"Mean of the dependent variable" \ "" \ 
				"Observations" \ "") annotate(stars) asymbol(*, **, ***) plain tex fragment replace ; // 
#delimit cr
