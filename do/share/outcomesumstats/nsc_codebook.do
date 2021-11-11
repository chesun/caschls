********************************************************************************
/* create a txt file codebook for NSC clean datasets, both for 2010-2017
and 2010-2018 */
********************************************************************************
/* to run this do file, type:
do $projdir/do/share/outcomesumstats/nsc_codebook.do
 */

use $nscdtadir/nsc_2010_2017_clean, clear
quietly {
    log using $projdir/out/txt/outcomesumstats/nsc_2010_2017_codebook.txt, text replace
    noisily codebook
    log close
}

use $nscdtadir/nsc_2010_2018_clean, clear
quietly {
    log using $projdir/out/txt/outcomesumstats/nsc_2010_2018_codebook.txt, text replace
    noisily codebook
    log close
}
