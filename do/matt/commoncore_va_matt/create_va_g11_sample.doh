local drift_limit = max(`test_score_max_year' - `test_score_min_year' - 1, 1)
use if grade==11 & dataset=="CAASPP" & inrange(year, `test_score_min_year', `test_score_max_year') using `va_dataset', clear

include do_files/sbac/create_diff_school_prop.doh
keep if diff_school_prop>=0.95

include do_files/sbac/create_prior_scores.doh


* Save temporary dataset
compress
tempfile va_g11_dataset
save `va_g11_dataset'
