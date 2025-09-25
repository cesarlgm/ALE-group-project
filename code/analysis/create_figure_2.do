use "data/output/cleaned_census_acs", clear

set seed 100

generate target_women=inrange(relative_income,0.49,0.51) if female&relative_income>0
generate rand_share=runiform() if target_women==1
generate flag_noise=rand_share<.4

generate income_noise=exp(rnormal(0,1.14)) if flag_noise==1
replace income_noise=1 if flag_noise==0|missing(flag_noise)
generate new_inctot=inctot*income_noise


egen new_couple_income=sum(new_inctot), by(serial year)

generate new_relative_share=new_inctot/new_couple_income

hist new_relative if relative_income>0&female, xline(0.5) xtitle("Woman's share in household income") frac ytitle("Share of couples")
graph export "results/figures/figure_2.png", replace

local figure_name "results/figures/figure_2.tex"
local figure_path "../../results/figures"
local figure_list figure_2.png
local figure_title  "Share of couples by women's relative income (after adding noise to wife's income)"
local figure_key    fig:figure_2
local figure_notes  "For readibility the histogram restricts couples where women have non-zero income.  Vertical line marks couples where the woman earns 50\% of the couples income."
local figlabs      ""

latexfigure using `figure_name', path(`figure_path') ///
    figurelist(`figure_list') rowsize(2) title(`figure_title') ///
    key(`figure_key') note(`figure_notes') figlab(`figlabs') nodate

