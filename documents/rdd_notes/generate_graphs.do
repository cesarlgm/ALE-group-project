

cd "C:\Users\thecs\Dropbox\2_edinburgh\2_teaching\3_applied_labour_economics\group_project\documents\rdd_notes"
clear
set obs 10000
set seed 100


generate income=5000*exp(rnormal(0,.7))

generate d_i=income<12000

generate scores=(1/70000*income+rnormal(0,.1)+.2*d_i+.2)*100


tw (scatter scores income, mcolor(ebblue%10)) ///
	(lfit scores income if income<=12000, lcolor(red)) ///
	(lfit scores income if income>12000, lcolor(red)), ///
	xtitle("Parental income") ytitle("Scores") legend(off) ///
	xline(12000, lpattern(dash) lcolor(black))
	
graph export "figure_1.png", replace



local figure_name "figure_1.tex"
local figure_path "./"
local figure_list figure_1
local figure_title  "RDD in a graph"
local figure_key    fig:figure_1
local figure_notes  "Vertical line denotes \textsterling 12,000."
local figlabs       

latexfigure using `figure_name', path(`figure_path') ///
    figurelist(`figure_list') rowsize(2) title(`figure_title') ///
    key(`figure_key') note(`figure_notes') figlab(`figlabs')



generate scores2=(1/2.6*(1/10000*income-1/1000000000*income*income+rnormal(0,.1))+.2*d_i)*100


regress scores2 income c.income#c.income d_i 
predict fitted

tw (scatter scores2 income, mcolor(ebblue%10)), ///
	xtitle("Parental income") ytitle("Scores") legend(off) ///
	xline(12000, lpattern(dash) lcolor(black))
graph export "figure_2_a.png", replace
	
generate scores3=(1/70000*income+1/50000*(12000-income)*d_i+rnormal(0,.1)+.2*d_i+.1)*100

tw (scatter scores3 income, mcolor(ebblue%10)) ///
	(lfit scores3 income if income<=12000, lcolor(red)) ///
	(lfit scores3 income if income>12000, lcolor(red)), ///
	xtitle("Parental income") ytitle("Scores") legend(off) ///
	xline(12000, lpattern(dash) lcolor(black))
	
	
graph export "figure_2_b.png", replace

local figure_name "figure_2.tex"
local figure_path "./"
local figure_list figure_2_a figure_2_b
local figure_title  "RDD and functional form"
local figure_key    fig:figure_2
local figure_notes  "Vertical line denotes \textsterling 12,000."
local figlabs       `""Non-linear relationship with the running variable""Different function on each side of the discontinuity""'

latexfigure using `figure_name', path(`figure_path') ///
    figurelist(`figure_list') rowsize(2) title(`figure_title') ///
    key(`figure_key') note(`figure_notes') figlab(`figlabs')




