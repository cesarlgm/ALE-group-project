use "data/output/cleaned_census_acs", clear


hist relative_income if relative_income>0&female, xline(0.5) xtitle("Woman's share in household income") frac ytitle("Share of couples")
graph export "results/figures/figure_1.png", replace


local figure_name "results/figures/figure_1.tex"
local figure_path "../../results/figures"
local figure_list figure_1.png
local figure_title  "Share of couples by women's relative income"
local figure_key    fig:figure_1
local figure_notes  "For readibility the histogram restricts couples where women have non-zero income.  Vertical line marks couples where the woman earns 50\% of the couples income."
local figlabs      ""

latexfigure using `figure_name', path(`figure_path') ///
    figurelist(`figure_list') rowsize(2) title(`figure_title') ///
    key(`figure_key') note(`figure_notes') figlab(`figlabs') nodate



