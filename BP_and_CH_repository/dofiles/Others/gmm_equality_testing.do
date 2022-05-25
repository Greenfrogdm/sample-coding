
* GMM equality loop *

mat wald = J(3,3,.)
local c = 1
foreach y in $outcomes {
local r = 1
	forval z = 4/6 { 
	xi: gmm	(eq1: `y' - $vars_eq1) ///
		(eq2: `y' - $vars_eq2) [pw=factor_pond], ///
		instruments(eq1: $instrument_1 $controls $fe)  ///
		instruments(eq2: ${instrument_`k'} $controls $fe)  ///
		onestep winitial(unadjusted, indep)	
	test [b1]_cons = [c1]_cons
	mat wald[`r',`c'] = r(p) 
	local r = `r' + 1
	}
local c = `c' + 1
}
