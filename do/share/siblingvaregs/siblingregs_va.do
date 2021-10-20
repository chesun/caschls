********************************************************************************
/* do file to run VA regressions with sibling effects. See VA to do list doc for details.
Current models:
1. Sibling FE as an additional demographic control in our value added estimation.
2. Proportion of older siblings that attended college as an additional demographic control in our value added estimation.
3. Specification test with sibling FE
4. Proportion of older siblings that attended college as a leave-out variable to use for a forecast bias test.
5. Sibling FE as an additional control for regressions of long-run outcomes on value added.
6. Proportion of older siblings that attended college as an additional control for regressions of long-run outcomes on value added.
 */
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu *******************
********************** First written on Sep 22, 2021 ***************************

//install VAM package to estimate value added models a la Chetty, Freidman, and Rockoff
/* ssc install vam, replace  */


//specify a macro for the va g11 outcomes dataset to reconcile with dataset calls in matt's do files
local va_g11_dataset "$projdir/dta/common_core_va/va_g11_out_dataset"
