use "data/output/cleaned_census_acs", clear

set seed 100

generate target_women=inrange(relative_income,0.49,0.51) if female&relative_income>0
generate rand_share=runiform() if target_women==1
generate flag_noise=rand_share<.4

generate income_noise=exp(rnormal(0,1.14)) if flag_noise==1
replace income_noise=1 if flag_noise==0
generate new_inctot=inctot*income_noise


gegen new_couple_income=sum(new_inctot), by(serial year)

generate new_relative_share=new_inctot/new_couple_income


generate temp=educ if !female

cap drop husbands_education
gegen husbands_education=max(temp), by(year serial)


keep if !missing(new_relative_share)&new_relative_share>0&female==1

cap drop wife_more_educ
generate wife_more_educ=educ>husbands_education


generate cut_relative_share=.
replace cut_relative_share=0 if new_relative_share>=0&new_relative_share<=0.025
forvalues j=1/99 {
    qui replace cut_relative_share=`j'*0.025 if new_relative_share>`j'*.025&new_relative_share<=(`j'+1)*.025
}


table cut_relative_share, c(max new_relative_share)

gcollapse (mean) wife_more_educ, by(cut_relative_share year)


generate women_h_earn=cut_relative_share>=.5

generate square=cut_relative_share*c.cut_relative_share
generate cube=cut_relative_share*c.cut_relative_share*c.cut_relative_share

generate int_line=(cut_relative_share-.5)*women_h_earn
generate int_square=(cut_relative_share-.5)*(c.cut_relative_share-.5)*women_h_earn
generate int_cube=(cut_relative_share-.5)*(cut_relative_share-.5)*(cut_relative_share-.5)*women_h_earn


binscatter wife_more_educ cut_relative_share, rd(.5) line(qfit) xtitle(Wife's relative income share) ///
    ytitle("Share of couples with more educated wives") yscale(range(0 .5)) ylab(0(.1).5)
graph export "results/figures/figure_4.png", replace

label var women_h_earn "Woman is the highest earner"
eststo clear
eststo reg1: regress wife_more_educ women_h_earn c.cut_relative_share c.square c.cube int_line int_square int_cube, vce(r)


local figure_name "results/figures/figure_4.tex"
local figure_path "../../results/figures"
local figure_list figure_4.png
local figure_title  "Relative income and relative education"
local figure_key    fig:figure_4
local figure_notes  "Vertical line marks couples where the woman earns 50\% of the couples income."
local figlabs      ""

latexfigure using `figure_name', path(`figure_path') ///
    figurelist(`figure_list') rowsize(2) title(`figure_title') ///
    key(`figure_key') note(`figure_notes') figlab(`figlabs') nodate



local table_name "results/tables/table_3.tex"
local table_title "Regression discontinuity estimates: share of couples where the wife has more education"
local table_key "tab:table_3"
local ncols 1
local model_list reg1
local table_notes "The regression includes a cubic polynomical of the relative income share, along with interactions between the discontinuity and the polynomial"

textablehead using `table_name', ncols(`ncols') coltitles(`coltitles') title(`table_title') key(`table_key') f("")  ful(rrr)
leanesttab `model_list' using `table_name', append  ///
            keep(women_h_earn) star(* .1 ** .05 *** .01)   substitute(_ _)  format(3) stat(N, label("\midrule Observations"))
textablefoot using `table_name', notes(`table_notes') nodate

