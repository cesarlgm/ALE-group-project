use "data/output/cleaned_census_acs", clear

set seed 100

generate target_women=inrange(relative_income,0.49,0.51) if female&relative_income>0
generate rand_share=runiform() if target_women==1
generate flag_noise=rand_share<.4

generate income_noise=exp(rnormal(0,1.14)) if flag_noise==1
replace income_noise=1 if flag_noise==0|missing(flag_noise)
generate new_inctot=inctot*income_noise

gegen new_couple_income=sum(new_inctot), by(serial year)

generate new_relative_share=new_inctot/new_couple_income

keep if !missing(new_relative_share)&new_relative_share>0&female==1


generate cut_relative_share=.
replace cut_relative_share=0 if new_relative_share>=0&new_relative_share<=0.025
forvalues j=1/39 {
    qui replace cut_relative_share=`j'*0.025 if new_relative_share>`j'*0.025&new_relative_share<=(`j'+1)*0.025
}


table cut_relative_share, c(max new_relative_share)

gcollapse (count) n_couples=age (mean) income_share=new_relative_share, by(cut_relative_share year)



egen total_couples=sum(n_couples), by(year)

generate share_couples=n_couples/total_couples

generate women_h_earn=cut_relative_share>=.5

generate square=income_share*c.income_share
generate cube=income_share*c.income_share*c.income_share

generate int_line=(income_share-.5)*women_h_earn
generate int_square=(income_share-.5)*(c.income_share-.5)*women_h_earn
generate int_cube=(income_share-.5)*(income_share-.5)*(income_share-.5)*women_h_earn

label var square "Square of relative income share"
label var cube "Cubic of relative income share"
label var cut_relative_share "Relative income share"
label var women_h_earn "Women is the highest earner"

generate int2000=women_h_earn*year==2000
generate int2011=women_h_earn*year==2011

label var int2000 "Women is the highest earner $ \times $ 2000 "
label var int2011 "Women is the highest earner $ \times $ 2011 "

eststo clear
eststo reg1: regress share_couples women_h_earn c.income_share c.square c.cube int_line int_square int_cube, vce(r)


local table_name "results/tables/table_2.tex"
local table_title "Regression discontinuity estimates"
local table_key "tab:table_2"
local ncols 1
local model_list reg1
local table_notes "The regression includes a cubic polynomical of the relative income share, along with interactions between the discontinuity and the polynomial"

textablehead using `table_name', ncols(`ncols') coltitles(`coltitles') title(`table_title') key(`table_key') f("")  ful(rrr)
leanesttab `model_list' using `table_name', append  ///
            keep(women_h_earn) star(* .1 ** .05 *** .01)   substitute(_ _)  format(3) stat(N, label("\midrule Observations"))
textablefoot using `table_name', notes(`table_notes') nodate

