********************
* Globals defining *
********************

global full_outcomes m_stunting s_stunting m_underweight s_underweight m_anemia s_anemia
global outcomes m_stunting m_underweight m_anemia
global c_outcomes haz waz hemoglobin
global controls m_educ_years m_work gender age_months i_mother_tongue civil_state p_educ_years urban n_children_b5 m_age
global fe i.region i.year i.quintil 
global instrument ln_wtm_ratio_5y

global instrument_1 ln_wtm_ratio_5y
global instrument_2 ln_wtm_ratio_4y
global instrument_3 ln_wtm_ratio_3y

global instrument_4 ln_wtm_ratio_5y age_dif
global instrument_5 (i.year*ln_wtm_ratio_5y)
global instrument_6 (i.year*ln_wtm_ratio_5y) age_dif

global region_d i_region2 i_region3 i_region6 i_region9
global year_d i_year3 i_year5 i_year7 i_year9
global quintil_d wealth_index

global vars_eq1 {b1}*w_bargain - {b2}*m_educ_years - {b3}*m_work - {b4}*gender - {b5}*age_months - {b6}*i_mother_tongue - {b7}*civil_state - {b8}*p_educ_years -  {b9}*urban - {b10}*n_children_b5 - {b11}*m_age - {b12}*i_quintil2 - {b13}*i_quintil3  - {b14}*i_quintil4  - {b15}*i_quintil5 - {b16}*i_year10 - {b17}*i_year2 - {b18}*i_year3 - {b19}*i_year4 - {b20}*i_year5 - {b21}*i_year6 - {b22}*i_year7 - {b23}*i_year8 - {b24}*i_year9 - {b26}*i_region2 - {b27}*i_region3 - {b28}*i_region4 - {b29}*i_region5 - {b30}*i_region6 - {b31}*i_region7 - {b32}*i_region8 - {b33}*i_region9 - {b34}*i_region10 - {b35}*i_region11 - {b36}*i_region12 - {b37}*i_region13 - {b38}*i_region14 - {b39}*i_region15 - {b40}*i_region16 - {b41}*i_region17 - {b42}*i_region18 - {b43}*i_region19 - {b44}*i_region20 - {b45}*i_region21 - {b46}*i_region22 - {b47}*i_region23 - {b48}*i_region24 - {b25}*i_region25 - {b0}

global vars_eq2 {c1}*w_bargain - {c2}*m_educ_years - {c3}*m_work - {c4}*gender - {c5}*age_months - {c6}*i_mother_tongue - {c7}*civil_state - {c8}*p_educ_years -  {c9}*urban - {c10}*n_children_b5 - {c11}*m_age - {c12}*i_quintil2 - {c13}*i_quintil3  - {c14}*i_quintil4  - {c15}*i_quintil5 - {c16}*i_year10 - {c17}*i_year2 - {c18}*i_year3 - {c19}*i_year4 - {c20}*i_year5 - {c21}*i_year6 - {c22}*i_year7 - {c23}*i_year8 - {c24}*i_year9 - {c26}*i_region2 - {c27}*i_region3 - {c28}*i_region4 - {c29}*i_region5 - {c30}*i_region6 - {c31}*i_region7 - {c32}*i_region8 - {c33}*i_region9 - {c34}*i_region10 - {c35}*i_region11 - {c36}*i_region12 - {c37}*i_region13 - {c38}*i_region14 - {c39}*i_region15 - {c40}*i_region16 - {c41}*i_region17 - {c42}*i_region18 - {c43}*i_region19 - {c44}*i_region20 - {c45}*i_region21 - {c46}*i_region22 - {c47}*i_region23 - {c48}*i_region24 - {c25}*i_region25 - {c0}

* Testing elements: i_mother_tongue civil_state p_educ_years child_number siblings urban
* Control vars:  siblings m_age health_insurance health_insurance
* Instrument: wtm_ratio ln_wtm_ratio
* replace ln_wtm_ratio = ln(years_there*wtm_ratio + 1)

