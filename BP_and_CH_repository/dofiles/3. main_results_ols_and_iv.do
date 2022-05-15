
***********
* Table 3 *
***********

* Only on moderate outcomes: for tidiness purposes

mat results = J(8,12,.)
mat t_stat = J(8,12,0) 
mat stars = J(8,12,0) 

local i = 1

qui foreach y in $outcomes {
	
	* OLS *
	reg `y' w_bargain $controls $fe [pw=factor_pond], r

	mat R = r(table)		
	mat B_1 = R[1,1..3]'
	mat SE_1 = R[2,1..3]'	
	mat T_1 = R[3,1..3]'
	matewmf T_1 T_1, f(abs)
	
	local obs_ols = e(N)

	qui mean `y' if e(sample) [pw=factor_pond]
	mat B = e(b)
	local mean_y = B[1,1]
	
	* IV *
	ivregress 2sls `y' $controls $fe (w_bargain = $instrument) [pw=factor_pond],  r

	mat R = r(table)		
	mat B_2 = R[1,1..3]'
	mat SE_2 = R[2,1..3]'	
	mat T_2 = R[3,1..3]'
	matewmf T_2 T_2, f(abs)
	
	local obs_iv = e(N)
	
	* Recovering the first stage *
	ivreg2 `y'  $controls $fe (w_bargain = $instrument) [pw=factor_pond], first savefirst r
	
	mat F = e(first)	  
	local F_stat = F[4,1]

	qui estimates replay _ivreg2_w_bargain
	
	* Imputting outcomes into 'results' matrix
	
	* From rows 1 to 3:
	mat results[1,4*`i'-3] = B_1
	mat results[1,4*`i'-2] = SE_1
	mat results[1,4*`i'-1] = B_2
	mat results[1,4*`i'] = SE_2
	
	* Note: Row 4 is empty

	mat results[5,4*`i'-1] = r(table)["b", "$instrument"]
	mat results[5,4*`i'] = r(table)["se", "$instrument"]

	mat results[6,4*`i'-1] = `F_stat'
	
	mat results[7,4*`i'-3] = `mean_y'
	mat results[7,4*`i'-1] = `mean_y'
	
	mat results[8,4*`i'-3] = `obs_ols'
	mat results[8,4*`i'-1] = `obs_iv'
	
	mat t_stat[1,4*`i'-3]  = T_1
	mat t_stat[1,4*`i'-1]  = T_2
	mat t_stat[5,4*`i'-1]  = abs(results[6,4*`i'-1]/results[6,4*`i'])


	forval r = 1/7 {
		mat stars[`r',4*`i'-3] = (t_stat[`r',4*`i'-3]>= 1.645)+(t_stat[`r',4*`i'-3]>= 1.96)+(t_stat[`r',4*`i'-3]>= 2.576)
		mat stars[`r',4*`i'-1] = (t_stat[`r',4*`i'-1]>= 1.645)+(t_stat[`r',4*`i'-1]>= 1.96)+(t_stat[`r',4*`i'-1]>= 2.576)
	}

* Note: I might be forgetting of include siblings in the summary statistics table

	local i = `i' + 1
}


* Insert missing values with mata to give the right format

#delimit ;

frmttable using table_3_iv_results.doc, statmat(results) sdec(3,3,3) substat(1) 
		  ctitles("", "Stunting", "", "Underweight", "", "Anemia" \
				  "", "OLS", "IV", "OLS", "IV", "OLS", "IV") 
		  rtitles("Bargaining Power Index" \ "" \
				"Mother's education years"\ "" \				
				"Mother's work status" \ "" \
				"First-stage instruments"\""\
				"  Labor participation ratio"\""\
				"Kleibergen-Paap F statistic"\""\
				"Mean of the dependent variable" \ "" \ 
				"Observations" \ "") annotate(stars) asymbol(*, **, ***) plain tex fragment replace ;
#delimit cr