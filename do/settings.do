********************************************************************************
******* global settings for common core va project do files********************
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
global projdir "/home/research/ca_ed_lab/users/chesun/gsr/caschls"

/* global macro for the common core VA project folder directory */
global vaprojdir "/home/research/ca_ed_lab/projects/common_core_va"

/* create global macro for the value added estimates file directory */
global vadtadir "/home/research/ca_ed_lab/projects/common_core_va/data/sbac"


/* create global macro for CST data directory */
global cstdtadir "/home/research/ca_ed_lab/data/restricted_access/clean/cde/cst"


/* create global macro for NSC data directory */
global nscdtadir "/home/research/ca_ed_lab/data/restricted_access/clean/cde_nsc"

/* create global macro for NSC old format data directory */
global nscdtadir_oldformat "/home/research/ca_ed_lab/data/restricted_access/clean/cde_nsc/oldformat"


/* global macro for Matt's crosswalks folder */
global mattxwalks "/home/research/ca_ed_lab/users/msnaven/data/restricted_access/clean/crosswalks"


/* global macro for common core VA project crosswalks folder  */
global vaprojxwalks "/home/research/ca_ed_lab/projects/common_core_va/data/restricted_access/clean/crosswalks"

/* global macros for k12 and postsec distance data directory */
global distance_dtadir "/home/research/ca_ed_lab/projects/common_core_va/data/k12_postsec_distance"
