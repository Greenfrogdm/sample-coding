
* Install: 
* ssc install spmap
* ssc install shp2dta
* ssc install mif2dta
* Reference: https://www.stata.com/support/faqs/graphics/spmap-and-maps/

clear all
set more off
global root "C:\Mariano\KU Leuven\2022 (feb - jun)\0. Master Thesis\I. Bargaining power and children outcomes"
use "$root\2. Input\Maps\provdb", clear
rename IDPROV code_province
merge 1:1 code_province using "$root\3. Output\Temporals\province_level_BPI.dta" // base con BP y w_gap a nivel de provincia
keep if _merge ==  3

replace w_bargain = round(w_bargain, 0.001)
replace ln_wtm_ratio_5y = round(ln_wtm_ratio_5y, 0.001)
replace wtm_ratio_2006_2010 = round(wtm_ratio_2006_2010, 0.001)

bys region: egen m_ln_wtm = mean(ln_wtm_ratio_5y)
replace ln_wtm_ratio_5y = m_ln_wtm if ln_wtm_ratio_5y == .

bys region: egen m_wtm = mean(wtm_ratio_2006_2010)
replace wtm_ratio_2006_2010 = m_wtm if wtm_ratio_2006_2010 == .

spmap w_bargain using "$root\2. Input\Maps\provcoord", id(id) fcolor(Reds) clnumber(5) ///
	  legtitle("{bf:Bargaining Power Index}") legcount
graph export "$root\3. Output\Figures\map_w_bargain.png", replace

spmap wtm_ratio_2006_2010 using "$root\2. Input\Maps\provcoord", id(id) fcolor(Reds) clnumber(5) ///
	  legtitle("{bf:Labor Participation Ratio}") legcount
graph export "$root\3. Output\Figures\map_gender_gap.png", replace

preserve

scatter w_bargain wtm_ratio_2006_2010,  sort mcolor(%30) ///
		graphregion(fcolor(white)) plotregion(lcolor(black)) ///
		|| lfit w_bargain wtm_ratio_2006_2010, lwidth(0.6) ytitle("{bf:Bargaining Power Index (mean by province)}") ///
		xtitle("{bf:Labor Participation Ratio (mean by province)}") legend(off)

restore

graph export "$root\3. Output\Figures\scatter_bargain_gap.png", replace

exit
