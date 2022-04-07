********************************************************************************
/* impute missing values in allsvyqoimeans.dta */
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu *******************
********************************************************************************

cap log close _all
clear all
set more off

log using $projdir/log/share/factoranalysis/imputation.smcl, replace

use $projdir/dta/allsvyfactor/allsvyqoimeans, clear

local allqoivars parentqoi9mean_pooled parentqoi15mean_pooled parentqoi16mean_pooled parentqoi17mean_pooled parentqoi27mean_pooled parentqoi30mean_pooled parentqoi31mean_pooled parentqoi32mean_pooled parentqoi33mean_pooled parentqoi34mean_pooled parentqoi64mean_pooled ///
secqoi22mean_pooled secqoi23mean_pooled secqoi24mean_pooled secqoi25mean_pooled secqoi26mean_pooled secqoi27mean_pooled secqoi28mean_pooled secqoi29mean_pooled secqoi30mean_pooled secqoi31mean_pooled secqoi32mean_pooled secqoi33mean_pooled secqoi34mean_pooled secqoi35mean_pooled secqoi36mean_pooled secqoi37mean_pooled secqoi38mean_pooled secqoi39mean_pooled secqoi40mean_pooled ///
staffqoi10mean_pooled staffqoi20mean_pooled staffqoi24mean_pooled staffqoi41mean_pooled staffqoi44mean_pooled staffqoi64mean_pooled staffqoi87mean_pooled staffqoi98mean_pooled staffqoi103mean_pooled staffqoi104mean_pooled staffqoi105mean_pooled staffqoi109mean_pooled staffqoi111mean_pooled staffqoi112mean_pooled staffqoi128mean_pooled

local climatevars parentqoi9mean_pooled parentqoi16mean_pooled parentqoi17mean_pooled parentqoi27mean_pooled secqoi22mean_pooled secqoi23mean_pooled secqoi24mean_pooled secqoi25mean_pooled secqoi26mean_pooled secqoi27mean_pooled secqoi28mean_pooled secqoi29mean_pooled secqoi30mean_pooled staffqoi20mean_pooled staffqoi24mean_pooled staffqoi41mean_pooled staffqoi44mean_pooled staffqoi64mean_pooled staffqoi87mean_pooled staffqoi98mean_pooled
local qualityvars parentqoi30mean_pooled parentqoi31mean_pooled parentqoi32mean_pooled parentqoi33mean_pooled parentqoi34mean_pooled secqoi35mean_pooled secqoi36mean_pooled secqoi37mean_pooled secqoi38mean_pooled secqoi39mean_pooled secqoi40mean_pooled staffqoi103mean_pooled staffqoi104mean_pooled staffqoi105mean_pooled staffqoi109mean_pooled staffqoi111mean_pooled staffqoi112mean_pooled
local supportvars parentqoi15mean_pooled parentqoi64mean_pooled staffqoi10mean_pooled staffqoi128mean_pooled
local motivationvars secqoi31mean_pooled secqoi32mean_pooled secqoi33mean_pooled secqoi34mean_pooled


/* Note: NEED TO ADD VAR LABELS */

// generate an indicator for imputed qoi vars and assign a local macro for the imputation indicator dummies for each category
local climateimputedummies
foreach i of local climatevars {
  gen imputed`i' = 0
  replace imputed`i' = 1 if missing(`i')
  label var imputed`i' "dummy for whether variable `i' is imputed"
  local addvar imputed`i'
  local climateimputedummies: list climateimputedummies | addvar
}

local qualityimputedummies
foreach i of local qualityvars {
  gen imputed`i' = 0
  replace imputed`i' = 1 if missing(`i')
  label var imputed`i' "dummy for whether variable `i' is imputed"
  local addvar imputed`i'
  local qualityimputedummies: list qualityimputedummies | addvar
}

local supportimputeddummies
foreach i of local supportvars {
  gen imputed`i' = 0
  replace imputed`i' = 1 if missing(`i')
  label var imputed`i' "dummy for whether variable `i' is imputed"
  local addvar imputed`i'
  local supportimputeddummies: list supportimputeddummies | addvar
}

local motivationimputedummies
foreach i of local motivationvars {
  gen imputed`i' = 0
  replace imputed`i' = 1 if missing(`i')
  label var imputed`i' "dummy for whether variable `i' is imputed"
  local addvar imputed`i'
  local motivationimputedummies: list motivationimputedummies | addvar
}


// impute missing values of each variable using nonmissing sample mean
foreach i of local allqoivars {
  egen mean`i' = mean(`i')
  replace `i' = mean`i' if missing(`i')
  drop mean`i'
}


********************************************************************************
/* Regress each var on other vars in each category and imputed dummies; predict y hat and replace missing with y hat */
// do this for climate vars
local xdummies
foreach i of local climatevars {
  local xvars: list climatevars - i
  local minusvar imputed`i'
  local xdummies: list climateimputedummies - minusvar
  reg `i' `xvars' `xdummies'
  predict hat_`i'
  replace `i' = hat_`i' if imputed`i' == 1
  drop hat_`i'
}


// do this for quality vars
local xdummies
foreach i of local qualityvars {
  local xvars: list qualityvars - i
  local minusvar imputed`i'
  local xdummies: list qualityimputedummies - minusvar
  reg `i' `xvars' `xdummies'
  predict hat_`i'
  replace `i' = hat_`i' if imputed`i' == 1
  drop hat_`i'
}


// do this for support vars
local xdummies
foreach i of local supportvars {
  local xvars: list supportvars - i
  local minusvar imputed`i'
  local xdummies: list supportimputedummies - minusvar
  reg `i' `xvars' `xdummies'
  predict hat_`i'
  replace `i' = hat_`i' if imputed`i' == 1
  drop hat_`i'
}


// do this for motivation vars
local xdummies
foreach i of local motivationvars {
  local xvars: list motivationvars - i
  local minusvar imputed`i'
  local xdummies: list motivationimputedummies - minusvar
  reg `i' `xvars' `xdummies'
  predict hat_`i'
  replace `i' = hat_`i' if imputed`i' == 1
  drop hat_`i'
}


save $projdir/dta/allsvyfactor/imputedallsvyqoimeans, replace

iog close
translate $projdir/log/share/factoranalysis/imputation.smcl $projdir/log/share/factoranalysis/imputation.log, replace 
