* 1 is liberal and 7 is conservative
* V160101 weight variable

* recode self placement
gen lib_con_self = V161126
replace lib_con_self = . if V161126 < 1 | V161126 > 7


* recode input variables
gen spend_serv = 8 - V161178
replace spend_serv = . if V161178 < 1 | V161178 > 7

gen def_spend = V161181
replace def_spend = . if V161181 < 1 | V161181 > 7

gen insurance = V161184
replace insurance = . if V161184 < 1 | V161184 > 7

gen job_income = V161189
replace job_income = . if V161189 < 1 | V161189 > 7

gen birth_cit = 8 - V161194x
replace birth_cit = . if V161194x < 1

gen ill_children = 7 - V161195x
replace ill_children = . if V161195x < 1
replace ill_children = ill_children + 1 if ill_children > 3

gen wall = 8 - V161196x
replace wall = . if V161196x < 1

gen black_assist = V161198
replace black_assist = . if V161198 < 1 | V161198 > 7

gen env_jobs = V161201
replace env_jobs = . if V161201 < 1 | V161201 > 7

gen affirm_act = V161204x
replace affirm_act = . if V161204x < 1

gen par_leave = V161226x
replace par_leave = . if V161226x < 1

gen trans_pol = 8 - V161228x
replace trans_pol = . if V161228x < 1


* make unrounded index variable
egen lib_con_avg = rowmean(spend_serv def_spend insurance job_income birth_cit ill_children wall black_assist env_jobs affirm_act par_leave trans_pol)

egen soc_avg = rowmean(birth_cit ill_children wall affirm_act par_leave trans_pol)

egen econ_avg = rowmean(spend_serv def_spend insurance job_income black_assist env_jobs)

* standard deviation of unrounded index
egen standard_deviation = rowsd(spend_serv def_spend insurance job_income birth_cit ill_children wall black_assist env_jobs affirm_act par_leave trans_pol)

* variance of unrounded index
gen variance = standard_deviation^2

* max and min of unrounded index
egen _max = rowmax(spend_serv def_spend insurance job_income birth_cit ill_children wall black_assist env_jobs affirm_act par_leave trans_pol)

egen _min = rowmin(spend_serv def_spend insurance job_income birth_cit ill_children wall black_assist env_jobs affirm_act par_leave trans_pol)

gen spread = _max - _min

* recode demographic control variables
recode V161270 (1/10 = 0) (11/16 = 1) (-9 = .) (90/95 = .), gen(college)
recode V161267 (-9 = .) (-8 = .), gen(age)
recode V161342 (-9 = .) (2/3 = 0), gen(male)
recode V161361x (-9 = .) (-5 = .), gen(income)

gen _error = sqrt(((spend_serv - lib_con_self)^2 + (def_spend - lib_con_self)^2 + (insurance - lib_con_self)^2 + (job_income - lib_con_self)^2 + (birth_cit - lib_con_self)^2 + (ill_children - lib_con_self)^2 + (wall - lib_con_self)^2 + (black_assist - lib_con_self)^2 + (env_jobs - lib_con_self)^2 + (affirm_act - lib_con_self)^2 + (par_leave - lib_con_self)^2 + (trans_pol - lib_con_self)^2)/12)

* gen _error = abs((spend_serv - lib_con_self) + (def_spend - lib_con_self) + (insurance - lib_con_self) + (job_income - lib_con_self) + (birth_cit - lib_con_self) + (ill_children - lib_con_self) + (wall - lib_con_self) + (black_assist - lib_con_self) + (env_jobs - lib_con_self) + (affirm_act - lib_con_self) + (par_leave - lib_con_self) + (trans_pol - lib_con_self))/12

* statistical tests
regress lib_con_self lib_con_avg college age male income [aw = V160101]

regress lib_con_self spend_serv def_spend insurance job_income birth_cit ill_children wall black_assist env_jobs affirm_act par_leave trans_pol [aw = V160101]

correlate spend_serv def_spend insurance job_income birth_cit ill_children wall black_assist env_jobs affirm_act par_leave trans_pol [aw = V160101]

eststo: reg lib_con_self lib_con_avg college age male income [aw = V160101]
estimates store model1
eststo: reg lib_con_self soc_avg college age male income [aw = V160101]
estimates store model2
eststo: reg lib_con_self econ_avg college age male income [aw = V160101]
estimates store model3
esttab model1 model2 model3 using _table.tex, label title(Ideological Self Placement)


eststo: reg standard_deviation lib_con_self college age male income [aw = V160101]
estimates store model4
eststo: reg standard_deviation lib_con_avg college age male income [aw = V160101]
estimates store model5
esttab model4 model5 using 1_table.tex, label title(Ideological Consistency)

eststo: reg standard_deviation soc_avg college age male income [aw = V160101]
estimates store model6
eststo: reg standard_deviation econ_avg college age male income [aw = V160101]
estimates store model7
esttab model6 model7 using 0_table.tex, label title(Ideological Consistency)
