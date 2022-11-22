********************************************************************************
/* Linear regressions of VA vars on all 3 index vars in a "horse race" type regression
for both complete case and imputed data  */
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu *******************
********************************************************************************
cap log close _all
clear all
set more off

log using $projdir/log/share/factoranalysis/indexhorserace.smcl, replace

////////////////////////////////////////////////////////////////////////////////


foreach type in compcase imputed {

  use $projdir/dta/allsvyfactor/categoryindex/`type'categoryindex, clear

  //local macro for z score index vars
  local indexsdvars z_climateindex z_qualityindex z_supportindex


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


                qui reg va_`va_outcome'_`sample'_sp_`control'_ct`peer' `indexsdvars'

                regsave using $projdir/out/csv/factoranalysis/indexhorserace/va_`va_outcome'_`sample'_sp_`control'_ct`peer'_`type' ///
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


        `merge_command' $projdir/out/csv/factoranalysis/indexhorserace/va_`va_outcome'_`sample'_sp_`control'_ct`peer'_`type', `merge_options'

        local merge_command "merge 1:1 var using"
        local merge_options nogen
      }
    }
  }

  export excel using $projdir/out/csv/factoranalysis/indexhorserace/`type'horserace.csv, replace firstrow(variables)


}





log close
translate $projdir/log/share/factoranalysis/indexhorserace.smcl $projdir/log/share/factoranalysis/indexhorserace.log, replace
