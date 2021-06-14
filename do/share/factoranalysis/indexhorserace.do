********************************************************************************
/* lienar regressions of VA vars on all 4 index vars in a "horse race" type regression
for both complete case and imputed data  */
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu *******************
********************************************************************************
clear all
set more off

////////////////////////////////////////////////////////////////////////////////
/* complete case analysis  */


use $projdir/dta/allsvyfactor/categoryindex/compcasecategoryindex, clear

//local macro for VA vars in z scores
local vasdvars z_va_ela z_va_math z_va_enr z_va_enrela z_va_enrmath z_va_enrdk z_va_2yr z_va_2yrela z_va_2yrmath z_va_2yrdk z_va_4yr z_va_4yrela z_va_4yrmath z_va_4yrdk

//local macro for z score index vars
local indexsdvars z_climateindex z_qualityindex z_supportindex z_motivationindex


// regress va vars on index vars
foreach i of local vasdvars {
  local append replace

  eststo: reg `i' `indexsdvars'

  local append append
}

esttab using $projdir/out/csv/factoranalysis/indexhorserace/compcasehorserace.csv, replace

eststo clear



////////////////////////////////////////////////////////////////////////////////
/* imputed data analysis  */

use $projdir/dta/allsvyfactor/categoryindex/imputedcategoryindex, clear

//local macro for VA vars in z scores
local vasdvars z_va_ela z_va_math z_va_enr z_va_enrela z_va_enrmath z_va_enrdk z_va_2yr z_va_2yrela z_va_2yrmath z_va_2yrdk z_va_4yr z_va_4yrela z_va_4yrmath z_va_4yrdk

//local macro for z score index vars
local indexsdvars z_climateindex z_qualityindex z_supportindex z_motivationindex


// regress va vars on index vars
foreach i of local vasdvars {
  local append replace

  eststo: reg `i' `indexsdvars'

  local append append
}

esttab using $projdir/out/csv/factoranalysis/indexhorserace/imputedhorserace.csv, replace

eststo clear