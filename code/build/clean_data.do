
{
    import excel "data/input/0911acs_topcodes.xls", sheet("acs_topcodes_0911") firstrow clear

    rename (inc*) (st_inc*)

    tempfile topcodes
    save `topcodes'
}

use "data/input/ex_1_census_acs.dta", clear

cap drop inctot incearn

keep if inrange(age,18,65)

keep if inlist(relate,1,2)


*Dropping negative values
foreach variable in incwage incbus incbus00 incfarm incss incwelfr incinvst incretir incsupp incother {
    drop if `variable'<0 
}

*Dropping imputed values
foreach variable in qincbus qincfarm qincinvs qincothe qincreti qincss qincsupp qincwage qincwelf {
    drop if inlist(`variable',4)
}

*Keeping only completed couples
gegen n_people=count(year), by(serial year)

keep if n_people==2


*Dealing with topcoded values
merge m:1 statefip using `topcodes', keep(3)

*incwage
generate tc_incwage=0
replace tc_incwage=1 if year==1990&incwage==140000
replace tc_incwage=1 if year==2000&incwage>=175000&!missing(incwage)
replace tc_incwage=1 if year==2011&incwage==st_incwage&!missing(incwage)

generate tc_incbus=0
replace tc_incbus=1 if year==1990&incbus>=90000&!missing(incbus)


generate tc_incfarm=0
replace tc_incfarm=1 if year==1990&incfarm>=54000&!missing(incfarm)

generate tc_incbus00=0
replace tc_incbus00=1 if year==2000&incbus00>=126000&!missing(incbus00)
replace tc_incbus00=1 if year==2011&incbus00==st_incbus00&!missing(incbus00)



foreach variable in incwage incbus incfarm incbus00 {
    gegen n_tc_`variable'=sum(tc_`variable'), by(year serial)
}

foreach variable in incwage incbus incfarm incbus00 {
    drop if n_tc_`variable'==2
}

drop n_tc_*


foreach variable in incwage incbus incfarm incbus00 {
    replace `variable'=`variable'*1.5 if tc_`variable'==1 
}

generate inctot=.
ereplace inctot=rowtotal(incwage incbus incfarm incss incwelfr incinvst incretir incother) if inlist(year, 1990)
ereplace inctot=rowtotal(incwage incbus00 incss incwelfr incinvst incretir incsupp incother) if inlist(year, 2000, 2011)

*Make sure I am using people with full income components
generate complete_income=0
ereplace complete_income=rowmiss(incwage incbus incfarm incss incwelfr incinvst incretir incother) if inlist(year, 1990)
ereplace complete_income=rowmiss(incwage incbus00 incss incwelfr incinvst incretir incsupp incother)  if inlist(year, 2000, 2011)

cap drop n_people
gegen n_people=count(year), by(serial year)
assert n_people==2

egen n_women=sum(sex==2), by(serial year)
keep if n_women==1

egen couple_income=sum(inctot), by(serial year)

generate relative_income=inctot/couple_income

generate female=sex==2
generate some_college=educ>=7 
generate in_labor_force=labforce==2
generate non_white=race!=1


save "data/output/cleaned_census_acs", replace

