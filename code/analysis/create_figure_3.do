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

cap drop cut_relative_share
generate cut_relative_share=.
replace cut_relative_share=0 if new_relative_share>=0&new_relative_share<=0.05
forvalues j=1/21 {
    replace cut_relative_share=`j'*0.05 if new_relative_share>`j'*0.05&new_relative_share<=(`j'+1)*0.05
}


table cut_relative_share, c(max new_relative_share)


gcollapse (count) n_couples=age (mean) some_college non_white, by(cut_relative_share year)

egen total_couples=sum(n_couples), by(year)

generate share_couples=n_couples/total_couples

grscheme, ncolor(7) palette(tableau)
global graph_options yscale(range(0 .05)) xtitle("Women's share in household income") ytitle("Share of couples")
tw (scatter share_couples cut_relative_share)  ///
    (lowess share_couples cut_relative_share if cut_relative_share<0.5, lcolor(black) lpattern(dash)) ///
     (lowess share_couples cut_relative_share if cut_relative_share>=0.5, lcolor(black) lpattern(dash)) if year==1990, /// 
    legend(off) xline(0.5) $graph_options


tw (scatter share_couples cut_relative_share)  ///
    (lowess share_couples cut_relative_share if cut_relative_share<0.5, lcolor(black) lpattern(dash)) ///
     (lowess share_couples cut_relative_share if cut_relative_share>=0.5, lcolor(black) lpattern(dash)) if year==1990, /// 
    legend(off) xline(0.5) $graph_options
graph export "results/figures/figure_3_1990.png", replace

tw (scatter share_couples cut_relative_share)  ///
    (lowess share_couples cut_relative_share if cut_relative_share<0.5, lcolor(black) lpattern(dash)) ///
     (lowess share_couples cut_relative_share if cut_relative_share>=0.5, lcolor(black) lpattern(dash)) if year==2000, /// 
    legend(off) xline(0.5)  $graph_options
graph export "results/figures/figure_3_2000.png", replace

tw (scatter share_couples cut_relative_share)  ///
    (lowess share_couples cut_relative_share if cut_relative_share<0.5, lcolor(black) lpattern(dash)) ///
     (lowess share_couples cut_relative_share if cut_relative_share>=0.5, lcolor(black) lpattern(dash)) if year==2011, /// 
    legend(off) xline(0.5)  $graph_options
graph export "results/figures/figure_3_2011.png", replace

local figure_name "results/figures/figure_3.tex"
local figure_path "../../results/figures"
local figure_list figure_3_1990.png figure_3_2000.png figure_3_2011.png
local figure_title  "Share of couples by women's relative income by year"
local figure_key    fig:figure_3
local figure_notes  "Each dot represents a bin of size 0.05 of the relative income share.  Vertical line marks couples where the woman earns 50\% of the couples income."
local figlabs      "1990 2000 2011"

latexfigure using `figure_name', path(`figure_path') ///
    figurelist(`figure_list') rowsize(2) title(`figure_title') ///
    key(`figure_key') note(`figure_notes') figlab(`figlabs') nodate



/*
hist new_relative if relative_income>0&female, xline(0.5) xtitle("Woman's share in household income") frac ytitle("Share of couples")
graph export "results/figures/figure_2.png", replace

local figure_name "results/figures/figure_3.tex"
local figure_path "../../results/figures"
local figure_list figure_3.png
local figure_title  "Share of couples by women's relative income (after adding noise to wife's income)"
local figure_key    fig:figure_3
local figure_notes  "For readibility the histogram restricts couples where women have non-zero income.  Vertical line marks couples where the woman earns 50\% of the couples income."
local figlabs      ""

latexfigure using `figure_name', path(`figure_path') ///
    figurelist(`figure_list') rowsize(2) title(`figure_title') ///
    key(`figure_key') note(`figure_notes') figlab(`figlabs') nodate

