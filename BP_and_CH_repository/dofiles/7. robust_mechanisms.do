clear all
set more off

global root "C:\Mariano\CIUP\Peruvian wage gap"
use "$root\Output\bases\final_base.dta"

local y0 = 2011
local yf = 2020
keep if inrange(anio, `y0', `yf')
merge m:1 anio using "$root\Otros\IPC_deflactor.dta", keepusing(ipc) nogen keep(match)

forval i = 1/7 {
g share_`i' = gru`i'1hd/gashog2d
g exp_`i'_pc = gru`i'1hd/(mieperho*(1+ipc))
}

drop hhid
egen hhid = concat(anio conglome vivienda hogar)
egen hhid_int = group(hhid)

* Identifying nuclear HHs *
* Deleting HH with other siblings *
g otro_rel = 0 
replace otro_rel = 1 if relacion_JH > 3 & relacion_JH != .
bys hhid_int: egen suma_1 = total(otro_rel)
keep if suma_1 == 0

* Deleting HH with no chidren *
replace relacion_JH = 3 if relacion_JH == .
g child = 0
replace child = 1 if relacion_JH == 3
bys hhid_int: egen suma_2 = total(child)
drop if suma_2 == 0

* Deleting Monoparental HH *
g parejita = 0
replace parejita = 1 if relacion_JH == 2
bys hhid_int: egen suma_3 = total(parejita)
drop if suma_3 == 0

egen siblings = count (relacion_JH ==3), by(hhid_int)

egen m_educ = total(anios_educ) if relacion_JH != 3 & sexo == 1, by(hhid_int)
egen d_educ = total(anios_educ) if relacion_JH != 3 & sexo == 0, by(hhid_int)
egen m_age = total(edad) if relacion_JH != 3 & sexo == 1, by(hhid_int)
egen d_age = total(edad) if relacion_JH != 3 & sexo == 0, by(hhid_int)
egen m_income = total(ingreso_pr_hora) if relacion_JH != 3 & sexo == 1, by(hhid_int)
egen d_income = total(ingreso_pr_hora) if relacion_JH != 3 & sexo == 0, by(hhid_int)
egen m_native = total(lengua_indigena) if relacion_JH != 3 & sexo == 1, by(hhid_int)
egen d_native = total(lengua_indigena) if relacion_JH != 3 & sexo == 0, by(hhid_int)
egen m_n_educ = total(n_educacion) if relacion_JH != 3 & sexo == 1, by(hhid_int)
egen d_n_educ = total(n_educacion) if relacion_JH != 3 & sexo == 0, by(hhid_int)

egen m_works = total(trabaja) if relacion_JH != 3 & sexo == 1, by(hhid_int)

egen mom_educ = total(m_educ), by(hhid_int)
egen dad_educ = total(d_educ), by(hhid_int)
egen mom_n_educ = total(m_n_educ), by(hhid_int)
egen dad_n_educ = total(d_n_educ), by(hhid_int)
egen mom_age = total(m_age), by(hhid_int)
egen dad_age = total(d_age), by(hhid_int)
egen mom_income = total(m_income), by(hhid_int)
egen dad_income = total(d_income), by(hhid_int)
egen mom_native = total(m_native), by(hhid_int)
egen dad_native = total(d_native), by(hhid_int)
egen mom_works = total(m_works), by(hhid_int)
drop m_educ d_educ m_age d_age m_works

g casado_parents = 0 if relacion_JH >= 2
replace casado_parents = 1 if relacion_JH >= 2 & estado_civil == 1

egen region = max(departamento_g), by(hhid_int)
egen marital_parents = max(casado_parents), by(hhid_int)

drop if n_hijos_menor_6 == 0


collapse (firstnm) mom_educ mom_n_educ dad_educ dad_n_educ share_* exp_* siblings mom_age dad_age marital_parents ///
		 region mom_native ubigeo anio urban quintile_expend mom_works factor07 mieperho ipc, by(hhid_int)

rename (mom_educ mom_n_educ mom_age dad_educ dad_age mom_native anio urbano quintile_expend marital_parents mom_works mieperho ipc factor07) ///
	   (m_educ_years m_n_educ m_age p_educ_years p_age i_mother_tongue year urban quintil civil_state m_work n_hh_members cpi factor_pond)
   
tostring hhid_int, g(hhid)
replace hhid = "E" + hhid
g enaho = 1

compress

qui foreach y in exp_1_pc exp_5_pc {
	lv `y'
	local ub_`y' = r(u_A)
	local lb_`y' = r(l_A)
}

qui foreach y in exp_1_pc exp_5_pc  {
	drop if (`y' <  `lb_`y'' | `y' > `ub_`y'' ) & (`y' != .)
}


set seed 123

g u = uniform()
sort u, stable
sum  u
g n = _n
sum n
local mid = r(max)/2
g training = (n <= `mid')
g l_exp_1_pc = ln(exp_1_pc)
g l_exp_5_pc = ln(exp_5_pc + 1)

* Diagnostics *
/*
gen out_of_bag_error1 = .
gen validation_error = .
gen iter1 = .

sum n
local mid = r(max)/2
local mid_plus = `mid' + 1
local max = r(max)

local j = 1
qui forvalues i = 1(1)15 {
	noisily  di in yellow  "." _continue
	xi: rforest l_exp_1_pc m_educ_years m_age p_educ_years p_age i_mother_tongue urban civil_state m_work n_hh_members ///
	i.quintil i.region in 1/`mid', type(reg) iter(150) numv(`i') seed(123)


	qui replace iter1 = `i' if n == `j'

	qui replace out_of_bag_error1 =  e(OOB_Error) if n == `j'
	predict p in `mid_plus'/`max'
	
	qui replace validation_error = e(RMSE) if n == `j'
	drop p
	local j = `j' + 1
}

label var out_of_bag_error1 "Out of Bag Error"
label var iter1 "Iterations"
label var validation_error "Validation RMSE"
scatter out_of_bag_error1 iter1, mcolor(blue) msize(tiny) || scatter validation_error iter1, mcolor(red) msize(tiny)

exit
*/

append using "C:\Mariano\KU Leuven\2022 (feb - jun)\0. Master Thesis\I. Bargaining power and children outcomes\3. Output\Database\final_base.dta"
replace enaho = 0 if enaho == .

xi: rforest l_exp_1_pc m_educ_years m_age p_educ_years p_age i_mother_tongue urban civil_state m_work n_hh_members ///
	i.quintil i.region i.year if training == 1, type(reg) iter(1000) numv(3) seed(123)

predict l_exp_1_rf

xi: rforest exp_5_pc m_educ_years m_age p_educ_years p_age i_mother_tongue urban civil_state m_work n_hh_members ///
	i.quintil i.region i.year if training == 1 , type(reg) iter(1000) numv(3) seed(123)

predict exp_5_rf
g l_exp_5_rf = ln(exp_5_rf)

global root "C:\Mariano\KU Leuven\2022 (feb - jun)\0. Master Thesis\I. Bargaining power and children outcomes"
run "$root\4. dofiles\0. Processing data\globals.do"

global set1 
global set2 l_exp_1_rf l_exp_5_rf 
global set3 l_m_bmi d_mom_anemia 
global set4 violence 

mat results = J(9, 6, .)
mat t_stat = J(9, 6, 0)
mat stars = J(9, 6, 0)

local c = 1

foreach y in $outcomes {
local i = 0	
	forval k = 1/4 {
	qui reg `y' w_bargain ${set`k'} $controls $fe [pw=factor_pond], r
	mat B = r(table)
	local obs = r(N)
	mat b = B[1,1..3]'
	mat sd = B[2,1..3]'
	mat t = B[3,1..3]'
	matewmf t t, f(abs)
	
		if `k' == 1 {
		mat results[`k', 2*`c'-1] = b[1,1]
		mat results[`k', 2*`c'] = sd[1,1]
		
		mat t_stat[`k', 2*`c'-1] = t[1,1]
		}
		
		if (`k' == 2 | `k' == 3) {
		mat results[`k'+ `i' , 2*`c'-1] = b 		
		mat results[`k'+ `i', 2*`c'] = sd
		
		mat t_stat[`k'+ `i', 2*`c'-1] = t
		local i = `i' + 2
		}

		if `k' == 4 {
		mat results[`k' + 4 , 2*`c'-1] = b[1..2,1]
		mat results[`k' + 4 , 2*`c'] = sd[1..2,1]
		
		mat t_stat[`k' + 4, 2*`c'-1] = t[1..2,1]
		}
	
	}
	
	forval r = 1/9 {
		mat stars[`r', 2*`c'-1] = (t_stat[`r', 2*`c'-1]>= 1.645)+(t_stat[`r', 2*`c'-1]>= 1.96)+(t_stat[`r',2*`c'-1]>= 2.576)
	}

local c = `c' + 1
}

cd "$root\3. Output\Tables"
#delimit ;

frmttable using mechanisms.doc, statmat(results) sdec(3,3,3) substat(1) 
		  ctitles("", "Stunting", "Underweight", "Anemia")
		  rtitles("(a) BPI" \ "" \			
				"(b) BPI (+ Inc. exp.)" \ "" \
				"  Exp. food"\""\
				"  Exp. health"\""\
				"(d) BPI (+ Maternal helth)"\""\
				"  BMI" \""\
				"  Anemia" \""\
				"(e) BPI (+ Violence)" \ "" \
				"  Violence" \"") annotate(stars) asymbol(*, **, ***) plain tex fragment replace ;
#delimit cr

exit

