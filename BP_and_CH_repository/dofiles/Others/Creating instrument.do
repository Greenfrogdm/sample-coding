clear all
set more off

global root "C:\Mariano\CIUP\Peruvian wage gap"

use "$root\Output\bases\final_base.dta"

keep if inrange(edad, 18, 65) // mayores de edad
	  
g code_province = substr(ubigeo,1,4)
encode code_province, generate(code_province_i)

local y0 = 2006 // potential y0: 2004, 2005, 2006
local y1 = 2008

g work = (mensual != .)
local z work
keep if inrange(anio, `y0', `y1')
levelsof code_province_i if inrange(anio, `y0', `y1'), local(levels)

qui foreach d of local levels {

noisily  di in yellow  "." _continue

mean `z' if (code_province_i == `d') & inrange(anio, `y0', `y1') [pw=factor07], over(sexo)
local p_ratio = _b[c.`z'@1.sexo]/_b[c.`z'@0bn.sexo]

mat dom_`d' = [`d' , `p_ratio']
	
}

levelsof code_province_i if inrange(anio, `y0', `y1'), local(levels)

qui foreach d of local levels { // appending deps
	if `d' == 1 {
	mat dom = dom_`d'	
	}
	
	if `d' != 1 {
	mat dom = (dom \ dom_`d')	
	}
	
}

* Recovering the province code (string): we are going to use this for the match with our endes do.
preserve

	collapse (first) code_province_i, by(code_province)
	save "C:\Mariano\KU Leuven\2022 (feb - jun)\0. Master Thesis\I. Bargaining power and children outcomes\3. Output\Temporals\temp.dta", replace

restore

mat list dom
mat colname dom = "code_province_i" "wtm_ratio_`y0'_`y1'"

drop _all
svmat dom, names(col)

merge m:1 code_province_i using "C:\Mariano\KU Leuven\2022 (feb - jun)\0. Master Thesis\I. Bargaining power and children outcomes\3. Output\Temporals\temp.dta"
keep if _m == 3
save "C:\Mariano\KU Leuven\2022 (feb - jun)\0. Master Thesis\I. Bargaining power and children outcomes\3. Output\Temporals\lagged_wtm_`y0'_`y1'.dta", replace

exit

