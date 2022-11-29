********************************************************************************
/* Bivariate VA regressions on each category index with school demographics from Matt Naven's data as controls */
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu *******************
********************************************************************************

/* CHANGE LOG:
11/27/2022: Rewrote code for using new VA estimates
 */

/* to run this do file:

do $projdir/do/share/factoranalysis/indexregwithdemo

 */

cap log close _all
clear all
set more off

log using $projdir/log/share/factoranalysis/indexregwithdemo.smcl, replace




////////////////////////////////////////////////////////////////////////////////
/* both complete case analysis and imputed data  */

local datatype compcase imputed

foreach type of local datatype {
  use $projdir/dta/allsvyfactor/categoryindex/`type'categoryindex, clear

  //merge with pooled average enrollment characteristics over 1415-1718 constructed from Matt Naven's data
  //keep only merged observations or unmatched master observations
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

/*
  foreach i of local demovars {
    sum `i'
    gen z_`i' = (`i' - r(mean))/r(sd)
  }

  local zdemovars z_minorityenrprop z_maleenrprop z_freemealprop z_elprop z_maleteachprop z_minoritystaffprop z_newteachprop z_fullcredprop z_fteteachperstudent z_fteadminperstudent z_fteserviceperstudent
 */



  //-------------------------------------------------------------
  // bivariate regressions va z scores on index z scores and demographics controls
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
          reg va_`va_outcome'_`sample'_sp_`control'_ct`peer' z_`index' ln_* `scorevars'

          regsave using $projdir/out/dta/factor/indexregwcontrols/`type'/va_`va_outcome'_`sample'_sp_`control'_ct`peer'_`index' ///
            , replace ///
            table(va_`va_outcome'_`sample'_sp_`control'_ct`peer', format(%7.2f) parentheses(stderr) asterisk()) ///
            addlabel(va, `va_outcome', sample, `sample', control, `control', peer, `peer_yn')
        }
      }
    }
  }




  //save dataset
  compress
  save $projdir/dta/allsvyfactor/categoryindex/`type'indexwithdemo, replace



set trace on



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


          `merge_command' $projdir/out/dta/factor/indexregwcontrols/`type'/va_`va_outcome'_`sample'_sp_`control'_ct`peer'_`index', `merge_options'

          local merge_command "merge 1:1 var using"
          local merge_options nogen
        }
      }
    }

    save $projdir/out/dta/factor/indexregwcontrols/`type'/`index'_va_`type'regs_wcontrols, replace
    export excel using $projdir/out/xls/factor/indexregwcontrols/`type'/`index'_va_`type'regs_wcontrols, replace firstrow(variables)
  }

set trace off

}

log close
translate $projdir/log/share/factoranalysis/indexregwithdemo.smcl $projdir/log/share/factoranalysis/indexregwithdemo.log, replace
