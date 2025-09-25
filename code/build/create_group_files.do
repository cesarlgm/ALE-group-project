use "data/input/census_acs.dta", clear


egen household_id=group(year serial)

*Number of total households
*14443058

forvalues j=1/20 {
    preserve 
        set seed `j'
        bsample round(0.4*14443058), cluster(household_id)
        compress
        save "data/output/ex_`j'_census_acs_temp", replace 
    restore
}


*Need to reassign the ids to the households to avoid duplication
forvalues j=1/1 {
    use "data/output/ex_`j'_census_acs_temp", clear

    cap drop household_id obs_id

    generate obs_id=_n 
    
    sort year serial pernum
    by year serial pernum: generate temp=_n

    gegen new_serial=group(year serial temp), 

    drop temp

    label var new_serial "household serial number"

    
    drop serial 

    rename new_serial serial 

    order serial, before(cbserial)

    *save "data/output/ex_`j'_census_acs", replace 
}