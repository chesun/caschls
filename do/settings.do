********************************************************************************
******* global settings for calschls sruvey data do files********************
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu ********************
********************************************************************************

/* IMPORTAMT: before running running the master do file, make sure the directories global macros
are set correctly in the settings.do file according to your current file structure */

/* creating global macro for the raw csv file directory */
global rawcsvdir "/home/research/ca_ed_lab/data/restricted_access/raw/calschls/csv"


/* creating global macro for the raw dta file directory */
global rawdtadir "/home/research/ca_ed_lab/data/restricted_access/raw/calschls/stata"


/* creating global macro for the clean dta file directory */
global clndtadir "/home/research/ca_ed_lab/data/restricted_access/clean/calschls"


/* creating global macro for the current project directory. IMPORTANT
to set correctly so that the do files will run  */
global projdir "/home/research/ca_ed_lab/chesun/gsr/caschls"


/* create global macro for the value added estimates file directory */
global vadtadir "/home/research/ca_ed_lab/msnaven/common_core_va/data/sbac"


/* create global macro for CST data directory */
global cstdtadir "/home/research/ca_ed_lab/data/restricted_access/clean/cst"
