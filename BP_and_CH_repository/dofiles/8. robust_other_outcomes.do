***********
* Table 7 *
***********

***************************
* Constructing QR dtabase *
***************************
set seed 123

* NOTE: REPLICATION OF THIS SEGMENT CAN TAKE SEVERAL HOURS
qui foreach y in $c_outcomes {
sqreg `y' w_bargain $controls $region_d $year_d $quintil_d, quantile(.1 .25 .5 .75 .9) reps(100)

mat R = r(table)
local nvars = colsof(R)/5
local max = colsof(R)
		   
preserve
	cd "$root\output"
	drop _all
	svmat R, names(`y')
	mat R = R[1..3,1..`max']
	local z = 1
	
	forval i = 1(`nvars')`max' {
		local g`z' = `i'
		local z = `z' + 1
	}
	
	keep `y'`g1' `y'`g2' `y'`g3' `y'`g4' `y'`g5'
	save qr_results_`y'.dta, replace
restore   
}


***************
* Regressions *
***************

* For robustness purposes we use continuos vars:
mat results = J(12,12,.)
mat t_stat = J(12,12,0) 
mat stars = J(12,12,0) 

local i = 1

qui foreach y in $c_outcomes {
	
	* OLS *
	reg `y' w_bargain $controls	$region_d $year_d $quintil_d [pw=factor_pond], r

	mat R = r(table)		
	mat B_1 = R[1,1..3]'
	mat SE_1 = R[2,1..3]'	
	mat T_1 = R[3,1..3]'
	matewmf T_1 T_1, f(abs)
	
	local obs = e(N)

	qui mean `y' if e(sample) [pw=factor_pond]
	mat B = e(b)
	local mean_y = B[1,1]
	
	* IV: Second stage results *
	ivregress 2sls `y' $controls $fe ///
			  (w_bargain = $instrument)  [pw=factor_pond],  r

	mat R = r(table)		
	mat B_2 = R[1,1..3]'
	mat SE_2 = R[2,1..3]'	
	mat T_2 = R[3,1..3]'
	matewmf T_2 T_2, f(abs)
	
	* Imputting OLS and IV outcomes into 'results' matrix
	
	* From rows 1 to 3:
	mat results[1,4*`i'-3] = B_1
	mat results[1,4*`i'-2] = SE_1
	mat results[1,4*`i'-1] = B_2
	mat results[1,4*`i'] = SE_2
	
	* Importing QREG results
	preserve
	use "$root\output\qr_results_`y'.dta", clear
	mkmat _all, mat(Q)
	mat Q = Q'	
	restore
	
	* Note: Row 4 is empty
	
	* Inserting QREG betas and se's
	mat results[5,4*`i'-3] = Q[1..5,1] // beta
	mat results[5,4*`i'-2] = Q[1..5,2] // se
	
	mat t_stat[1,4*`i'-3]  = T_1
	mat t_stat[1,4*`i'-1]  = T_2
	mat t_stat[5,4*`i'-3]  = Q[1..5,3]

	mat results[11,4*`i'-3] = `mean_y'
	mat results[11,4*`i'-1] = `mean_y'
	mat results[12,4*`i'-3] = `obs'
	mat results[12,4*`i'-1] = `obs'
	
	* Inserting stars
	forval r = 1/9 {
		mat stars[`r',4*`i'-3] = (t_stat[`r',4*`i'-3]>= 1.645)+(t_stat[`r',4*`i'-3]>= 1.96)+(t_stat[`r',4*`i'-3]>= 2.576)
		mat stars[`r',4*`i'-1] = (t_stat[`r',4*`i'-1]>= 1.645)+(t_stat[`r',4*`i'-1]>= 1.96)+(t_stat[`r',4*`i'-1]>= 2.576)
	}

* Note: I might be forgetting of include siblings in the summary statistics table

	local i = `i' + 1
}


cd "$root\output\tables"

#delimit ;

frmttable using table_7_robust_other_outcomes.doc, statmat(results) sdec(3,3,3) substat(1) 
		  ctitles("", "HAZ", "", "WAZ", "", "Hemoglobin" \
				  "", "OLS", "IV", "OLS", "IV", "OLS", "IV") 
		  rtitles("Bargaining Power Index" \ "" \
				"Mother's education years"\ "" \				
				"Mother's work status" \ "" \
				"QR Estimates for BPI"\""\
				"  p10"\""\
				"  p25"\""\
				"  p50" \ "" \ 
				"  p75" \ "" \ 
				"  p90" \ "" \
				" " \ "" \
				"Mean dep. variable"\""\
				"Observations" \ "") annotate(stars) asymbol(*, **, ***) plain tex fragment replace ; 
#delimit cr