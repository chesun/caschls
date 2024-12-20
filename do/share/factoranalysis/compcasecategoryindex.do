********************************************************************************
/* creates a linear index for each question cateogry use complete case only: school climate, teacher staff quality,
student support, student motivation. Then run bivariate VA regressions on each index var  */
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu *******************
********************************************************************************

/* to run this do file:

do $projdir/do/share/factoranalysis/compcasecategoryindex

 */



/* CHANGE LOG:
11/21/2022: Rewrote code for using new VA estimates
 */


cap log close _all
clear all
set more off

log using $projdir/log/share/factoranalysis/compcasecategoryindex.smcl, replace

use $projdir/dta/allsvyfactor/allsvyqoimeans, clear

local climatevars parentqoi16mean_pooled parentqoi17mean_pooled parentqoi27mean_pooled secqoi22mean_pooled secqoi23mean_pooled secqoi24mean_pooled secqoi26mean_pooled secqoi27mean_pooled  secqoi29mean_pooled
local qualityvars parentqoi30mean_pooled parentqoi31mean_pooled parentqoi32mean_pooled parentqoi33mean_pooled parentqoi34mean_pooled secqoi28mean_pooled secqoi35mean_pooled secqoi36mean_pooled secqoi37mean_pooled secqoi38mean_pooled secqoi39mean_pooled secqoi40mean_pooled staffqoi20mean_pooled staffqoi24mean_pooled staffqoi87mean_pooled
local supportvars parentqoi15mean_pooled parentqoi64mean_pooled staffqoi10mean_pooled staffqoi128mean_pooled
/* local motivationvars secqoi31mean_pooled secqoi32mean_pooled secqoi33mean_pooled secqoi34mean_pooled */

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



//-------------------------------------------------------------
// bivariate regression of VA z scores on index z scores
// regress va vars on index vars, have one file for each index to save N in the dataset

 /* 1. base sample base contro, no peer effects
 2. leave out score - sibling - acs sample, kitchen sink controls, peer effects */
//-------------------------------------------------------------

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



            foreach index of local indexvars {

              qui reg va_`va_outcome'_`sample'_sp_`control'_ct`peer' z_`index'

              regsave using $projdir/out/dta/factor/compcase/va_`va_outcome'_`sample'_sp_`control'_ct`peer'_`index' ///
                , replace ///
                table(va_`va_outcome'_`sample'_sp_`control'_ct`peer', format(%7.2f) parentheses(stderr) asterisk()) ///
                addlabel(va, `va_outcome', sample, `sample', control, `control', peer, `peer_yn')


            }
          }

        }
}


//save dataset
save $projdir/dta/allsvyfactor/categoryindex/compcasecategoryindex, replace




foreach index of local indexvars {
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


        `merge_command' $projdir/out/dta/factor/compcase/va_`va_outcome'_`sample'_sp_`control'_ct`peer'_`index', `merge_options'

        local merge_command "merge 1:1 var using"
        local merge_options nogen
      }
    }
  }

  save $projdir/out/dta/factor/compcase/`index'_va_compregs, replace
  export excel using $projdir/out/csv/factoranalysis/compcase/`index'_va_compregs, replace firstrow(variables)
}

log close
translate $projdir/log/share/factoranalysis/compcasecategoryindex.smcl $projdir/log/share/factoranalysis/compcasecategoryindex.log, replace
