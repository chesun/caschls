********************************************************************************
******* checking whether csv and dta are the same datasets ********************
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu ********************
********************************************************************************
set more off

import delimited "$rawcsvdir/elementary/CHKS_1415_ElemData_AllDistricts_012916.csv"
cf _all using "rawdtadir/elementary/CHKS_1415_ElemData_AllDistricts_012916.csv"
