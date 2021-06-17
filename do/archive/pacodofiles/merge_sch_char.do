


use /secure/ca_ed_lab/common_core_va/data/sbac/va_g11_ela,clear
keep grade year cdscode va_cfr_g11_ela n_g11_ela
foreach y in enr_2year enr_4year enr math {
 qui merge 1:1 cdscode year using /secure/ca_ed_lab/common_core_va/data/sbac/va_g11_`y', keepusing(va_cfr_g11_`y' grade year cdscode n_g11_`y')
 tab _m
 drop _m
}
merge m:1 cdscode year using /secure/ca_ed_lab/common_core_va/data/sch_char.dta, keep(1 3) nogen
replace enr_total = enr_total / 1000
label var enr_total "Total Enrollment (Thousands)"

saveold ~/va/output/va_with_sch_char,replace
egen school_pseudo_id=group(cdscode)
drop cdscode
saveold ~/va/output/va_with_sch_char_deident,replace
