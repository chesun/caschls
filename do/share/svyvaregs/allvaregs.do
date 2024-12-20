********************************************************************************
/* running value added regressions for secondary, parent, and staff surveys questions of interest */
/* This file supercededs parentvareg.do and secvareg.do since this files does the VA regs for secondary, staff, and parent using a loop*/
********************************************************************************
********************************************************************************
*************** written by Christina Sun. Email: ucsun@ucdavis.edu *******************
********************************************************************************


/* To run this do file, type:
do $projdir/do/share/svyvaregs/allvaregs
 */

/* CHANGE LOG:
11/21/2022: Rewrote code for using new VA estimates
 */

/* set trace on
set tracedepth 1 */

cap log close _all
graph drop _all
set more off
set varabbrev off
set graphics off
set scheme s1color
set seed 1984

log using $projdir/log/share/svyvaregs/allvaregs.smcl, replace


/* create a local macro for secondary qoi numbers  */
local secqoinums 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40

/* create a local macro for parent qoi numbers  */
local parentqoinums 9 15 16 17 27 30 31 32 33 34 64

/* create a local macro for staff qoi numbers  */
local staffqoinums 10 20 24 41 44 64 87 98 103 104 105 109 111 112 128




foreach svyname in sec parent staff {

  //-------------------------------------------------------------
  // create z scores for survey qoi and VA estimates
  //-------------------------------------------------------------

  use $projdir/dta/buildanalysisdata/analysisready/`svyname'analysisready, clear

  /* standardize qoi mean vars into z scores */
  foreach i of local `svyname'qoinums {
    sum qoi`i'mean_pooled
    gen qoi`i'mean_z = (qoi`i'mean_pooled - r(mean))/r(sd)
  }

  /* standardize va vars into z scores */
  foreach var of varlist va* {
    sum `var'
    replace `var' = (`var' - r(mean))/r(sd)
  }


  //-------------------------------------------------------------
  // bivariate regression of VA z scores on qoi z scores
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

          local append replace

          foreach i of local `svyname'qoinums {

            //---------------------------------------------------
            /* running unweighted regressions */
            //---------------------------------------------------

            qui reg va_`va_outcome'_`sample'_sp_`control'_ct`peer' qoi`i'mean_z
            regsave using $projdir/out/dta/varegs/`svyname'/va_`va_outcome'_`sample'_sp_`control'_ct`peer'_nw ///
              , `append' ///
              table(va_`va_outcome'_`sample'_sp_`control'_ct`peer', format(%7.2f) parentheses(stderr) asterisk()) ///
              addlabel(va, `va_outcome', sample, `sample', control, `control', peer, `peer_yn', weighted, N)


            //---------------------------------------------------
            /* running weighted regressions */
            //---------------------------------------------------
            qui reg va_`va_outcome'_`sample'_sp_`control'_ct`peer' qoi`i'mean_z  [aweight = gr11enr_mean]
            regsave using $projdir/out/dta/varegs/`svyname'/va_`va_outcome'_`sample'_sp_`control'_ct`peer'_wt ///
              , `append' ///
              table(va_`va_outcome'_`sample'_sp_`control'_ct`peer', format(%7.2f) parentheses(stderr) asterisk()) ///
              addlabel(va, `va_outcome', sample, `sample', control, `control', peer, `peer_yn', weighted, Y)

            local append append
          }
        }

      }

  }

  //---------------------------------------------------------
  /* merge regsave output dta datasets to produce big table */
  //---------------------------------------------------------


  //-------------------------------------------
  // merge unweighted regressions
  //-------------------------------------------
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


        `merge_command' $projdir/out/dta/varegs/`svyname'/va_`va_outcome'_`sample'_sp_`control'_ct`peer'_nw, `merge_options'

        local merge_command "merge 1:1 var using"
        local merge_options nogen
      }
    }
  }

  save $projdir/out/dta/varegs/`svyname'/`svyname'_va_all_nw, replace
  export excel using $projdir/out/xls/varegs/unweighted/`svyname'/`svyname'_va_all_nw, replace firstrow(variables)


  //-------------------------------------------
  // merge weighted regressions
  //-------------------------------------------
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


        `merge_command' $projdir/out/dta/varegs/`svyname'/va_`va_outcome'_`sample'_sp_`control'_ct`peer'_wt, `merge_options'

        local merge_command "merge 1:1 var using"
        local merge_options nogen
      }
    }
  }

  save $projdir/out/dta/varegs/`svyname'/`svyname'_va_all_nw, replace
  export excel using $projdir/out/xls/varegs/weighted/`svyname'/`svyname'_va_all_wt, replace firstrow(variables)




}


set trace off


log close
translate $projdir/log/share/svyvaregs/allvaregs.smcl $projdir/log/share/svyvaregs/allvaregs.log, replace
