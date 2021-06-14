********************************************************************************
/* creates a linear index for each question cateogry use complete case only: school climate, teacher staff quality,
student support, student motivation. Then run bivariate VA regressions on each index var  */
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu *******************
********************************************************************************
clear all
set more off

use $projdir/dta/allsvyfactor/allsvyqoimeans, clear

local climatevars parentqoi9mean_pooled parentqoi16mean_pooled parentqoi17mean_pooled parentqoi27mean_pooled secqoi22mean_pooled secqoi23mean_pooled secqoi24mean_pooled secqoi25mean_pooled secqoi26mean_pooled secqoi27mean_pooled secqoi28mean_pooled secqoi29mean_pooled secqoi30mean_pooled staffqoi20mean_pooled staffqoi24mean_pooled staffqoi41mean_pooled staffqoi44mean_pooled staffqoi64mean_pooled staffqoi87mean_pooled staffqoi98mean_pooled
local qualityvars parentqoi30mean_pooled parentqoi31mean_pooled parentqoi32mean_pooled parentqoi33mean_pooled parentqoi34mean_pooled secqoi35mean_pooled secqoi36mean_pooled secqoi37mean_pooled secqoi38mean_pooled secqoi39mean_pooled secqoi40mean_pooled staffqoi103mean_pooled staffqoi104mean_pooled staffqoi105mean_pooled staffqoi109mean_pooled staffqoi111mean_pooled staffqoi112mean_pooled
local supportvars parentqoi15mean_pooled parentqoi64mean_pooled staffqoi10mean_pooled staffqoi128mean_pooled
local motivationvars secqoi31mean_pooled secqoi32mean_pooled secqoi33mean_pooled secqoi34mean_pooled

/* generate linear index by summing the variables in each category */
gen climateindex = 0

foreach climatevar of local climatevars {
  replace climateindex = climateindex + `climatevar'
}

gen qualityindex = 0

foreach qualityvar of local qualityvars {
  replace qualityindex =  qualityindex + `qualityvar'
}

gen supportindex = 0

foreach supportvar of local supportvars {
  replace supportindex = supportindex + `supportvar'
}

gen motivationindex = 0

foreach motivationvar of local motivationvars {
  replace motivationindex = motivationindex + `motivationvar'
}

//creating a local macro for va variables
local vavars va_ela va_math va_enr va_enrela va_enrmath va_enrdk va_2yr va_2yrela va_2yrmath va_2yrdk va_4yr va_4yrela va_4yrmath va_4yrdk

// local macro for index vars
local indexvars climateindex qualityindex supportindex motivationindex

//generate standardized z scores for variables
foreach i of local vavars {
  sum `i'
  gen z_`i' = (`i' - r(mean))/r(sd)
}

foreach i of local indexvars {
  sum `i'
  gen z_`i' = (`i' - r(mean))/r(sd)
}

// regress va vars on index vars
foreach i of local vavars {
  local append replace

  foreach j of local indexvars {
    qui reg z_`i' z_`j'
    regsave using $projdir/out/dta/factor/compcase/`i'_index_compregs, `append' table(`i', format(%7.2f) parentheses(stderr) asterisk())

    local append append
  }
}


//save dataset
save $projdir/dta/allsvyfactor/categoryindex/compcasecategoryindex, replace


//merge the va index reg datasets to produce combined table
// local macro for all va vars except the first one (va_ela) for merging loop
local vaminusfirst va_math va_enr va_enrela va_enrmath va_enrdk va_2yr va_2yrela va_2yrmath va_2yrdk va_4yr va_4yrela va_4yrmath va_4yrdk

use $projdir/out/dta/factor/compcase/va_ela_index_compregs, clear
foreach i of local vaminusfirst {
  merge 1:1 var using $projdir/out/dta/factor/compcase/`i'_index_compregs
  drop _merge
}

save $projdir/out/dta/factor/compcase/vaindex_compregs_all, replace

export excel using $projdir/out/xls/factor/compcase/vaindex_compregs_all, replace
