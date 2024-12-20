/* re-writing survey code from pooling survey data until running VA regressions
 */


 /* 
 do $projdir/do/debug/new_survey_code_test.do
  */

 cap log close _all
clear all
set more off

local debugdtadir "$projdir/dta/debug"


//------------------------------------------------------------------------------
// collapse VA estimates to school level mean over the years 2015-2018
//------------------------------------------------------------------------------

foreach va_outcome in ela math enr enr_2year enr_4year {
  use $vaprojdir/estimates/va_cfr_all_v1/va_est_dta/va_`va_outcome'_all.dta, clear
  collapse (mean) va*, by(cdscode)

  tempfile va_`va_outcome'
  save `va_`va_outcome''
}

//------------------------------------------------------------------------------
// merge collapsed VA estimates
//------------------------------------------------------------------------------

// use a macro to store the command to initialize the data for merge
local merge_command use
local merge_options clear

foreach va_outcome in ela math enr enr_2year enr_4year {
  `merge_command' `va_`va_outcome'', `merge_options'
  local merge_command "merge 1:1 cdscode using"
  local merge_options nogen
}

label data "Pooled  School Level VA mean estimates for all test scores and enrollment over 2015-2018"
save `debugdtadir'/va_pooled_all.dta, replace



//------------------------------------------------------------------------------
// merge collapsed VA estimates onto survey data
//------------------------------------------------------------------------------
foreach svyname in sec parent staff {
  use $projdir/dta/buildanalysisdata/analysisready/`svyname'analysisready, clear
  merge 1:1 cdscode using `debugdtadir'/va_pooled_all.dta, nogen 

  save `debugdtadir'/`svyname'analysisready_va, replace
}

foreach svyname in sec parent staff {
    use `debugdtadir'/`svyname'analysisready_va, clear 
    keep cdscode qoi*
    rename qoi* `svyname'qoi* 
    save `debugdtadir'/`svyname'qoimeans, replace 
}

// merge survey qoimeans together
use `debugdtadir'/parentqoimeans, clear
merge 1:1 cdscode using `debugdtadir'/secqoimeans, nogen
merge 1:1 cdscode using `debugdtadir'/staffqoimeans, nogen

// merge on VA
merge 1:1 cdscode using `debugdtadir'/va_pooled_all, nogen 

save `debugdtadir'/allsvyqoimeans_va, replace 


//----------------------------------------
// imputation

use `debugdtadir'/allsvyqoimeans_va, clear

local allqoivars parentqoi9mean_pooled parentqoi15mean_pooled parentqoi16mean_pooled parentqoi17mean_pooled parentqoi27mean_pooled parentqoi30mean_pooled parentqoi31mean_pooled parentqoi32mean_pooled parentqoi33mean_pooled parentqoi34mean_pooled parentqoi64mean_pooled ///
secqoi22mean_pooled secqoi23mean_pooled secqoi24mean_pooled secqoi25mean_pooled secqoi26mean_pooled secqoi27mean_pooled secqoi28mean_pooled secqoi29mean_pooled secqoi30mean_pooled secqoi31mean_pooled secqoi32mean_pooled secqoi33mean_pooled secqoi34mean_pooled secqoi35mean_pooled secqoi36mean_pooled secqoi37mean_pooled secqoi38mean_pooled secqoi39mean_pooled secqoi40mean_pooled ///
staffqoi10mean_pooled staffqoi20mean_pooled staffqoi24mean_pooled staffqoi41mean_pooled staffqoi44mean_pooled staffqoi64mean_pooled staffqoi87mean_pooled staffqoi98mean_pooled staffqoi103mean_pooled staffqoi104mean_pooled staffqoi105mean_pooled staffqoi109mean_pooled staffqoi111mean_pooled staffqoi112mean_pooled staffqoi128mean_pooled

local climatevars parentqoi9mean_pooled parentqoi16mean_pooled parentqoi17mean_pooled parentqoi27mean_pooled secqoi22mean_pooled secqoi23mean_pooled secqoi24mean_pooled secqoi25mean_pooled secqoi26mean_pooled secqoi27mean_pooled secqoi28mean_pooled secqoi29mean_pooled secqoi30mean_pooled staffqoi20mean_pooled staffqoi24mean_pooled staffqoi41mean_pooled staffqoi44mean_pooled staffqoi64mean_pooled staffqoi87mean_pooled staffqoi98mean_pooled
local qualityvars parentqoi30mean_pooled parentqoi31mean_pooled parentqoi32mean_pooled parentqoi33mean_pooled parentqoi34mean_pooled secqoi35mean_pooled secqoi36mean_pooled secqoi37mean_pooled secqoi38mean_pooled secqoi39mean_pooled secqoi40mean_pooled staffqoi103mean_pooled staffqoi104mean_pooled staffqoi105mean_pooled staffqoi109mean_pooled staffqoi111mean_pooled staffqoi112mean_pooled
local supportvars parentqoi15mean_pooled parentqoi64mean_pooled staffqoi10mean_pooled staffqoi128mean_pooled
local motivationvars secqoi31mean_pooled secqoi32mean_pooled secqoi33mean_pooled secqoi34mean_pooled

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

local supportimputedummies
foreach i of local supportvars {
  gen imputed`i' = 0
  replace imputed`i' = 1 if missing(`i')
  label var imputed`i' "dummy for whether variable `i' is imputed"
  local addvar imputed`i'
  local supportimputedummies: list supportimputedummies | addvar
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


save `debugdtadir'/imputedallsvyqoimeans, replace


// imputed category index

use `debugdtadir'/imputedallsvyqoimeans, clear

local climatevars parentqoi16mean_pooled parentqoi17mean_pooled parentqoi27mean_pooled secqoi22mean_pooled secqoi23mean_pooled secqoi24mean_pooled secqoi26mean_pooled secqoi27mean_pooled  secqoi29mean_pooled
local qualityvars parentqoi30mean_pooled parentqoi31mean_pooled parentqoi32mean_pooled parentqoi33mean_pooled parentqoi34mean_pooled secqoi28mean_pooled secqoi35mean_pooled secqoi36mean_pooled secqoi37mean_pooled secqoi38mean_pooled secqoi39mean_pooled secqoi40mean_pooled staffqoi20mean_pooled staffqoi24mean_pooled staffqoi87mean_pooled
local supportvars parentqoi15mean_pooled parentqoi64mean_pooled staffqoi10mean_pooled staffqoi128mean_pooled


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

// local macro for index vars
local indexvars climateindex qualityindex supportindex

//generate standardized z scores for variables
foreach var of varlist va* {
  sum `var'
  replace `var' = (`var' - r(mean))/r(sd)
}

foreach i of local indexvars {
  sum `i'
  gen z_`i' = (`i' - r(mean))/r(sd)
}

save `debugdtadir'/imputedcategoryindex, replace



// indexregwithdemo
use `debugdtadir'/imputedcategoryindex, clear 

  merge 1:1 cdscode using $projdir/dta/schoolchar/schlcharpooledmeans, keep(1 3) nogen


  merge 1:1 cdscode using $projdir/dta/schoolchar/testscorecontrols, keep(1 3) nogen

  // local macro for index vars
  local indexvars climateindex qualityindex supportindex

  //local macro for demographics vars
  local demovars minorityenrprop maleenrprop freemealprop elprop maleteachprop minoritystaffprop newteachprop fullcredprop fteteachperstudent fteadminperstudent fteserviceperstudent

  //local macro for SBAC test scores
  local scorevars avg_gr6math_zscore avg_gr8ela_zscore

  //log transform the demo vars, adding 0.0000001 does not affect interpretation because it is small compared to variable values
  foreach i of local demovars {
    gen ln_`i' = log(`i'+ 0.0000001)
  }


    // macros for different VA estimates to be used in each sample
  local b_sample_controls b
  local las_sample_controls las




  foreach va_outcome in ela math enr enr_2year enr_4year dk_enr dk_enr_2year dk_enr_4year {
    foreach sample in b las {
      foreach control of local `sample'_sample_controls {
        //macro for whether to use the VA estimates with peer effects
        if "`sample'" == "b" {
          local peer
          local peer_yn "N"
        }
        if "`sample'" == "las" {
          local peer "_p"
          local peer_yn "Y"
        }

        local append_macro replace

        foreach index of local indexvars {
          reg va_`va_outcome'_`sample'_sp_`control'_ct`peer' z_`index' ln_* `scorevars'

          regsave using `debugdtadir'/va_`va_outcome'_`sample'_sp_`control'_ct`peer'_index ///
            , `append_macro' ///
            table(va_`va_outcome'_`sample'_sp_`control'_ct`peer', format(%7.2f) parentheses(stderr) asterisk()) ///
            addlabel(va, `va_outcome', sample, `sample', control, `control', peer, `peer_yn')

          local append_macro append

        }
      }
    }
  }

 save `debugdtadir'/imputedindexwithdemo, replace


     //merge the va index reg datasets to produce combined table
    local merge_command use
    local merge_options clear

    foreach va_outcome in ela math enr enr_2year enr_4year dk_enr dk_enr_2year dk_enr_4year {
      di "va: `va_outcome'"
      foreach sample in b las {
        di "sample: `sample'"
        foreach control of local `sample'_sample_controls {
          //macro for whether to use the VA estimates with peer effects
          if "`sample'" == "b" {
            local peer
            local peer_yn "N"
          }
          if "`sample'" == "las" {
            local peer "_p"
            local peer_yn "Y"
          }

          di "peer controls in VA estimates (empty if no peer, _p if peer): `peer'"


          `merge_command' `debugdtadir'/va_`va_outcome'_`sample'_sp_`control'_ct`peer'_index, `merge_options'

          local merge_command "merge 1:1 var using"
          local merge_options nogen
        }
      }
    }

    save `debugdtadir'/imputed_index_bivar_wdemo, replace
 
**************************************************************************************
 // index horserace with demo 
 use `debugdtadir'/imputedindexwithdemo, clear 

   // local macro for index vars
  local indexsdvars z_climateindex z_qualityindex z_supportindex

  //local macro for demographics vars
  local demovars minorityenrprop maleenrprop freemealprop elprop maleteachprop minoritystaffprop newteachprop fullcredprop fteteachperstudent fteadminperstudent fteserviceperstudent

  //local macro for SBAC test scores
  local scorevars avg_gr6math_zscore avg_gr8ela_zscore

   foreach va_outcome in ela math enr enr_2year enr_4year dk_enr dk_enr_2year dk_enr_4year {

        foreach sample in b las {
          foreach control of local `sample'_sample_controls {
            //macro for whether to use the VA estimates with peer effects
            if "`sample'" == "b" {
              local peer
              local peer_yn "N"
            }
            if "`sample'" == "las" {
              local peer "_p"
              local peer_yn "Y"

            }


                qui reg va_`va_outcome'_`sample'_sp_`control'_ct`peer' `indexsdvars' ln_* `scorevars'

                regsave using `debugdtadir'/va_`va_outcome'_`sample'_sp_`control'_ct`peer' ///
                  , replace ///
                  table(va_`va_outcome'_`sample'_sp_`control'_ct`peer', format(%7.2f) parentheses(stderr) asterisk()) ///
                  addlabel(va, `va_outcome', sample, `sample', control, `control', peer, `peer_yn')



            }

          }
  }

  local merge_command use
  local merge_options clear

  foreach va_outcome in ela math enr enr_2year enr_4year dk_enr dk_enr_2year dk_enr_4year {
    di "va: `va_outcome'"
    foreach sample in b las {
      di "sample: `sample'"
      foreach control of local `sample'_sample_controls {
        //macro for whether to use the VA estimates with peer effects
        if "`sample'" == "b" {
          local peer
          local peer_yn "N"
        }
        if "`sample'" == "las" {
          local peer "_p"
          local peer_yn "Y"
        }

        di "peer controls in VA estimates (empty if no peer, _p if peer): `peer'"


        `merge_command' `debugdtadir'/va_`va_outcome'_`sample'_sp_`control'_ct`peer', `merge_options'

        local merge_command "merge 1:1 var using"
        local merge_options nogen
      }
    }
  }


  save `debugdtadir'/imputed_index_horse_wdemo, replace