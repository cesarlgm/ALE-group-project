use "data/output/cleaned_census_acs", clear

local variable_list year age female non_white some_college inctot 

foreach variable in `variable_list' {
    foreach year in 1990 2000 2011 {
        if "`variable'"=="year" {
            qui summ  year if year==`year', 
            local year_`year'=`r(N)'
            local year_`year': di %9.0fc `year_`year''
        }
        else {
            qui summ  `variable' if year==`year', 
            local `variable'_`year'=`r(mean)'
            local `variable'_`year': di %9.2fc ``variable'_`year''
        }
    }
    local `variable'_list "& ``variable'_1990' & ``variable'_2000' & ``variable'_2011' \\"
}



local table_name "results/tables/table_1.tex"
local table_title "Individual summary statistics"
local coltitles `""1990""2000""2011""'
local table_key "tab:table_1"
local table_notes "Table shows summary statistics for the full sample"
local ncols 3

textablehead using `table_name', ncols(`ncols') coltitles(`coltitles') title(`table_title') key(`table_key') drop f("")  ful(rrr)

writeln "`table_name'" "Number of people `year_list' "
writeln "`table_name'" "Mean age `age_list' "
writeln "`table_name'" "Share female `female_list' "
writeln "`table_name'" "Share non-white `non_white_list' "
writeln "`table_name'" "Share with some college `some_college_list' "
writeln "`table_name'" "Mean total income `inctot_list' "
textablefoot using `table_name', notes(`table_notes') nodate
