********************************************************************************
/* Linear regressions of VA vars on all 3 index vars in a "horse race" type regression
with school demographic controls for both complete case and imputed data  */
********************************************************************************
********************************************************************************
*************** written by Christina Sun. Email: ucsun@ucdavis.edu *************
********************************************************************************


/* CHANGE LOG:
 */

/* to run this do file:

do $projdir/do/share/factoranalysis/indexhorseracewithdemo

 */

cap log close _all

log using $projdir/log/share/factoranalysis/indexhorsewithdemo.smcl, replace

graph drop _all
set more off
set varabbrev off
set graphics off
set scheme s1color
set seed 1984


local date1 = c(current_date)
local time1 = c(current_time)


local datatype compcase imputed

foreach type of local datatype {
  use $projdir/dta/allsvyfactor/categoryindex/`type'categoryindex, clear
  //merge with pooled average enrollment characteristics over 1415-1718 constructed from Matt Naven's data
  //keep only merged observations or unmatched master observations
  merge 1:1 cdscode using $projdir/dta/schoolchar/schlcharpooledmeans, keep(1 3) nogen

  merge 1:1 cdscode using $projdir/dta/schoolchar/testscorecontrols, keep(1 3) nogen

  // local macro for index vars
  local indexsdvars z_climateindex z_qualityindex z_supportindex

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


                qui reg va_`va_outcome'_`sample'_sp_`control'_ct`peer' `indexsdvars' ln_* `scorevars'

                regsave using $projdir/out/dta/factor/indexhorsewithdemo/`type'/va_`va_outcome'_`sample'_sp_`control'_ct`peer' ///
                  , replace ///
                  table(va_`va_outcome'_`sample'_sp_`control'_ct`peer', format(%7.2f) parentheses(stderr) asterisk()) ///
                  addlabel(va, `va_outcome', sample, `sample', control, `control', peer, `peer_yn')



            }

          }
  }


  //-----------------------------------------------------------
  //merge the va index horse race reg datasets to produce combined table
  //-----------------------------------------------------------


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


        `merge_command' $projdir/out/dta/factor/indexhorsewithdemo/`type'/va_`va_outcome'_`sample'_sp_`control'_ct`peer', `merge_options'

        local merge_command "merge 1:1 var using"
        local merge_options nogen
      }
    }
  }


  save $projdir/out/dta/factor/indexhorsewithdemo/`type'_index_horse_wdemo, replace

  export excel using $projdir/out/csv/factoranalysis/indexhorsewithdemo/`type'_index_horse_wdemo.csv, replace firstrow(variables)

}

















local date2 = c(current_date)
local time2 = c(current_time)

di "Start date time: `date1' `time1'"
di "End date time: `date2' `time2'"

log close
translate $projdir/log/share/factoranalysis/indexhorsewithdemo.smcl ///
  $projdir/log/share/factoranalysis/indexhorsewithdemo.log, replace
