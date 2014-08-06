program reg_all

local mode `1'
local ln `2'

make_data `mode'
run_reg `ln'bd
esttab using "${tables}`mode'.tex", ${top} posthead("\midrule \vspace{5mm} \underline{\textbf{Panel A: Citations }}\\") 

make_data `mode'
run_reg `ln'img
esttab using "${tables}`mode'.tex",  ${middle} posthead("\midrule \vspace{5mm} \underline{\textbf{Panel B : Images}}\\")

make_data `mode'
run_reg `ln'text
esttab using "${tables}`mode'.tex",   ${end} posthead("\midrule \vspace{5mm} \underline{\textbf{Panel C : Text}}\\")

end


program save_mean

local var `1'
qui tabstat `var', save
matrix stats=r(StatTotal)
global meanvar=round(stats[1,1],0.01)

end

program make_data

local mode `1'

use ${stash}master, clear
fvset base 2013 year

if "`mode'" == "digit" {
    gen tvar = isbaseball
}

if "`mode'" == "copy" {
    drop if isbaseball == 0
    gen tvar = treat
}

end

program run_reg

est clear
local x `1'

eststo: qui xtreg `x' 1.tvar#1.post, fe cluster(id)

save_mean `x'
qui estadd local fixed "Yes"
qui estadd local yearfe "No"
qui estadd local mean "${meanvar}"

eststo: qui xtreg `x' 1.tvar#1.post i.${fe}, fe cluster(id)
qui estadd local fixed "Yes"
qui estadd local yearfe "Yes"
qui estadd local mean "${meanvar}"

keep if year==2008 | year==2013

eststo: qui xtreg `x' 1.tvar#1.post i.${fe}, fe cluster(id)
save_mean `x'
qui estadd local fixed "Yes"
qui estadd local yearfe "Yes"
qui estadd local mean "${meanvar}"

end


