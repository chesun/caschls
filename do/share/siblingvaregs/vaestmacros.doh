********************************************************************************
/* Macros for common core VA project stored estimates  */
********************************************************************************
********************************************************************************
/* First written by Che Sun, 1/6/2022  */

/* to include this in do files:
include $projdir/do/share/siblingvaregs/vaestmacros.doh
 */

********************************************************************************
***test score VA
foreach subject in ela math {
  //original VA CFR estimates
  local `subject'_va_dta "$vaprojdir/data/sbac/va_g11_`subject'.dta, replace"
  //original VA CFR spec test without peer control
  local `subject'_spec_va "$vaprojdir/estimates/sbac/spec_test_va_cfr_g11_`subject'.ster"
  //original VA CFR spec test with peer control
  local `subject'_spec_va_peer "$vaprojdir/estimates/sbac/spec_test_va_cfr_g11_`subject'_peer.ster"



  //original VA with leave out L4 scores sample
  local `subject'_va_dta_l4 "$vaprojdir/data/sbac/bias_va_g11_`subject'_L4_cst_ela_z_score.dta"
  //spec test for VA on L4 leave out var sample
  **no peer controls
  local `subject'_spec_va_l4 "$vaprojdir/estimates/sbac/bias_spec_test_va_cfr_g11_`subject'_L4_cst_ela_z_score.ster"
  **with peer controls
  local `subject'_spec_va_l4_peer "$vaprojdir/estimates/sbac/bias_spec_test_va_cfr_g11_`subject'_L4_cst_ela_z_score_peer.ster"
  //forecast bias test for VA with L4 score leave out var
  **without peer controls
  local `subject'_fb_va_l4 "$vaprojdir/estimates/sbac/bias_test_va_cfr_g11_`subject'_L4_cst_ela_z_score.ster"



  //Original VA with census tract leave out var sample
  local `subject'_va_dta_census "$vaprojdir/data/sbac/bias_va_g11_`subject'_census.dta"
  //original VA spec test on census tract leave out var sample
  **no peer controls
  local `subject'_spec_va_census "$vaprojdir/estimates/sbac/bias_spec_test_va_cfr_g11_`subject'_census.ster"
  **with peer controls
  local `subject'_spec_va_census_peer "vaprojdir/estimates/sbac/bias_spec_test_va_cfr_g11_`subject'_census_peer.ster"
  //forecast bias test for VA with census tract leave out var
  **without peer controls
  local `subject'_fb_va_census "$vaprojdir/estimates/sbac/bias_test_va_cfr_g11_`subject'_census.ster"



  //VA on sibling sample without sibling control
  local `subject'_va_dta_sibling "$projdir/dta/common_core_va/test_score_va/va_g11_`subject'_sibling.dta"
  //spec test for original VA on sibling sample
  **no peer controls
  local `subject'_spec_va_sibling_og "$projdir/est/siblingvaregs/test_score_va/spec_test_va_cfr_g11_`subject'_sibling_nocontrol.ster"
  //spec test for sibling VA with sibling controls
  **no peer controls
  local `subject'_spec_va_sibling "$projdir/est/siblingvaregs/test_score_va/spec_test_va_cfr_g11_`subject'_sibling.ster"
  **peer control
  local `subject'_spec_va_sibling_peer "$projdir/est/siblingvaregs/test_score_va/spec_test_va_cfr_g11_`subject'_peer_sibling.ster"
  //forecast bias test for sibling control leave out var
  **without peer controls
  local `subject'_fb_va_sibling "$projdir/est/siblingvaregs/test_score_va/fb_test_va_cfr_g11_`subject'_sibling.ster"
}













********************************************************************************
**** enrollment outcome VA
foreach outcome in enr enr_2year enr_4year {
  //original VA CFR estimates
  local `outcome'_va_dta "$vaprojdir/data/sbac/va_g11_`outcome'.dta, replace"
  //original VA CFR spec test without peer control
  local `outcome'_spec_va "$vaprojdir/estimates/sbac/spec_test_va_cfr_g11_`outcome'.ster"
  //original VA CFR spec test with peer control
  local `outcome'_spec_va_peer "$vaprojdir/estimates/sbac/spec_test_va_cfr_g11_`outcome'_peer.ster"




  //original VA with leave out L4 scores sample
  local `outcome'_va_dta_l4 "$vaprojdir/data/sbac/bias_va_g11_`outcome'_L4_cst_ela_z_score.dta"
  //spec test for VA on L4 leave out var sample
  **no peer controls
  local `outcome'_spec_va_l4 "$vaprojdir/estimates/sbac/bias_spec_test_va_cfr_g11_`outcome'_L4_cst_ela_z_score.ster"
  **with peer controls
  local `outcome'_spec_va_l4_peer "$vaprojdir/estimates/sbac/bias_spec_test_va_cfr_g11_`outcome'_L4_cst_ela_z_score_peer.ster"
  //forecast bias test for VA with L4 score leave out var
  **without peer controls
  local `outcome'_fb_va_l4 "$vaprojdir/estimates/sbac/bias_test_va_cfr_g11_`outcome'_L4_cst_ela_z_score.ster"




  //Original VA with census tract leave out var sample
  local `outcome'_va_dta_census "$vaprojdir/data/sbac/bias_va_g11_`outcome'_census.dta"
  //original VA spec test on census tract leave out var sample
  **no peer controls
  local `outcome'_spec_va_census "$vaprojdir/estimates/sbac/bias_spec_test_va_cfr_g11_`outcome'_census.ster"
  **with peer controls
  local `outcome'_spec_va_census_peer "vaprojdir/estimates/sbac/bias_spec_test_va_cfr_g11_`outcome'_census_peer.ster"
  //forecast bias test for VA with census tract leave out var
  **without peer controls
  local `outcome'_fb_va_census "$vaprojdir/estimates/sbac/bias_test_va_cfr_g11_`outcome'_census.ster"




  //VA on sibling sample without sibling control
  local `outcome'_va_dta_sibling "$projdir/dta/common_core_va/outcome_va/va_g11_`outcome'_sibling.dta"
  //spec test for original VA on sibling sample
  **no peer controls
  local `outcome'_spec_va_sibling_og "$projdir/est/siblingvaregs/outcome_va/spec_test_va_cfr_g11_`outcome'_sibling_nocontrol.ster"
  //spec test for sibling VA with sibling controls
  **no peer controls
  local `outcome'_spec_va_sibling "$projdir/est/siblingvaregs/outcome_va/spec_test_va_cfr_g11_`outcome'_sibling.ster"
  **peer control
  local `outcome'_spec_va_sibling_peer "$projdir/est/siblingvaregs/outcome_va/spec_test_va_cfr_g11_`outcome'_peer_sibling.ster"
  //forecast bias test for sibling control leave out var
  **without peer controls
  local `outcome'_fb_va_sibling "$projdir/est/siblingvaregs/outcome_va/fb_test_va_cfr_g11_`outcome'_sibling.ster"
}
