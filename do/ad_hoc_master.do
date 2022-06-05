********************************************************************************
/* ad hoc master do files to run do files as needed
 */
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu *******************
********************** First written on June 2, 2022 ***************************

/* To run this do file:

do $projdir/do/ad_hoc_master

 */

timer on 1

do $vaprojdir/do_files/sbac/prior_decile_original_sample


do $projdir/do/share/siblingvaregs/reg_out_va_sib_acs


do $projdir/do/share/siblingvaregs/reg_out_va_sib_acs_dk

/* output regression estimates from regressing enrollment outcomes on test score
VA from the restricted sibling census sample to csv files */
do $projdir/do/share/siblingvaregs/reg_out_va_sib_acs_tab


/* Creates figures for regressions of enrollment outcomes on test score VA
interacted with prior score deciles from the restricted sibling census sample */
do $projdir/do/share/siblingvaregs/reg_out_va_sib_acs_fig


/* Creates figures for regressions of enrollment outcomes on deep knowledge VA
interacted with prior score deciles from the restricted sibling census sample */
do $projdir/do/share/siblingvaregs/reg_out_va_sib_acs_dk_fig



timer off 1
timer list
