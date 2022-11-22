********************************************************************************
/* create pooled average value added estimates over years */
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu *******************
********************************************************************************
cap log close _all
clear all
set more off

log using $projdir/log/build/buildanalysisdata/poolingva/poolva.smcl, replace

/* created pooled average for ELA test score VA */
use $vadtadir/va_g11_ela, clear
sort cdscode year
collapse va_cfr_g11_ela, by(cdscode)
rename va_cfr_g11_ela va_ela
label var va_ela "VA estimate on ELA test scores"
save $projdir/dta/buildanalysisdata/va/ela, replace


/* create pooled average for math test score VA */
use $vadtadir/va_g11_math.dta, clear
sort cdscode year
collapse va_cfr_g11_math, by(cdscode)
rename va_cfr_g11_math va_math
label var va_math "VA estimate on math test scores"
save $projdir/dta/buildanalysisdata/va/math, replace


/* create pooled average for VA on postsecondary enrollment */
use $vadtadir/va_g11_enr.dta, clear
sort cdscode year
collapse va_cfr_g11_enr va_cfr_g11_enr_ela va_cfr_g11_enr_math va_cfr_g11_enr_dk, by(cdscode)
rename va_cfr_g11_enr va_enr
rename va_cfr_g11_enr_ela va_enrela
rename va_cfr_g11_enr_math va_enrmath
rename va_cfr_g11_enr_dk va_enrdk
label var va_enr "VA on postsecondary enrollment"
label var va_enrela "VA on postsec enrollment controlling for ELA VA"
label var va_enrmath "VA on postsec enrollment controlling for math VA"
label var va_enrdk "deep knowledge VA on postsec enrollment controlling for ELA and math VA"
save $projdir/dta/buildanalysisdata/va/enr, replace


/* create pooled average for VA on 2 year community college enrollment */
use $vadtadir/va_g11_enr_2year.dta, clear
sort cdscode year
collapse va_cfr_g11_enr_2year va_cfr_g11_enr_2year_ela va_cfr_g11_enr_2year_math va_cfr_g11_enr_2year_dk, by(cdscode)
rename va_cfr_g11_enr_2year va_2yr
rename va_cfr_g11_enr_2year_ela va_2yrela
rename va_cfr_g11_enr_2year_math va_2yrmath
rename va_cfr_g11_enr_2year_dk va_2yrdk
label var va_2yr "VA on 2 year CC enrollment"
label var va_2yrela "VA on 2 year CC enrollment controlling for ELA VA"
label var va_2yrmath "VA on 2 year CC enrollment controlling for math VA"
label var va_2yrdk "deep knowledge VA on 2 year CC enrollment controlling for ELA and math"
save $projdir/dta/buildanalysisdata/va/2yr, replace


/* create pooled average for VA on 4 year college enrollment */
use $vadtadir/va_g11_enr_4year.dta, clear
sort cdscode year
collapse va_cfr_g11_enr_4year va_cfr_g11_enr_4year_ela va_cfr_g11_enr_4year_math va_cfr_g11_enr_4year_dk, by(cdscode)
rename va_cfr_g11_enr_4year va_4yr
rename va_cfr_g11_enr_4year_ela va_4yrela
rename va_cfr_g11_enr_4year_math va_4yrmath
rename va_cfr_g11_enr_4year_dk va_4yrdk
label var va_4yr "VA on 4 year college enrollment"
label var va_4yrela "VA on 4 year college enrollment controlling for ELA VA"
label var va_4yrmath "VA on 4 year college enrollment controlling for math VA"
label var va_4yrdk "deep knowledge VA on 4 year college enrollment controlling for ELA and math VA"
save $projdir/dta/buildanalysisdata/va/4yr, replace


log close
translate $projdir/log/build/buildanalysisdata/poolingva/poolva.smcl $projdir/log/build/buildanalysisdata/poolingva/poolva.log, replace 
