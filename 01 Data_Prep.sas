options compress=yes;

data train;
format flag $20.;
set 'ADULT.DATA'n;
flag = 'train';
run;

data test (rename=('|1x3 Cross validator'n = F1));
format flag $20.;
set 'ADULT.TEST'n;
flag = 'test';
run;

data rg.df (rename=(
F1 = age
F2 = workclass
F3 = fnlwgt
F4 = education
F5 = education_num
F6 = marital_status
F7 = occupation
F8 = relationship
F9 = race
F10 = sex
F11 = capital_gain
F12 = capital_loss
F13 = hours_per_week
F14 = native_country
F15 = income
));
set train test;
if compress(F15) ^= "";
run;

data rg.df;
set rg.df;
if compress(income) in (">50K",">50K.") then y = 1; 
else y = 0;
run;

/*age*/
data rg.df;
format age_bin $20.;
set rg.df;
if age <= 25 then age_bin = 'a. 0-25';
else if age <= 30 then age_bin = 'b. 26-30 & 71-100';
else if age <= 35 then age_bin = 'c. 31-35 & 61-70';
else if age <= 40 then age_bin = 'd. 36-40 & 56-60';
else if age <= 55 then age_bin = 'e. 40-55';
else if age <= 60 then age_bin = 'd. 36-40 & 56-60';
else if age <= 70 then age_bin = 'c. 31-35 & 61-70';
else age_bin = 'b. 26-30 & 71-100';
run;

/*workclass*/
data rg.df;
format workclass_bin $20.;
set rg.df; 
if workclass in ('?','Never-worked','Without-pay') then workclass_bin = 'a. no income';
else workclass_bin = 'b. income';
run;

/*education*/
data rg.df;
format education_bin $20.;
set rg.df; 
if education in ('10th','11th','12th','1st-4th','5th-6th','7th-8th','9th','Preschool') then education_bin = 'a. Low';
else if education in ('HS-grad','Some-college','Assoc-acdm','Assoc-voc') then education_bin = 'b. Mid';
else if education in ('Bachelors') then education_bin = 'c. Bachelors';
else if education in ('Masters') then education_bin = 'd. Masters';
else education_bin = 'e. High';
run;

/*education_num*/
data rg.df;
format education_num_bin $20.;
set rg.df;
if education_num <= 8 then education_num_bin = 'a. 0-8';
else if education_num <= 12 then education_num_bin = 'b. 9-12';
else if education_num <= 13 then education_num_bin = 'c. 13';
else if education_num <= 14 then education_num_bin = 'd. 14';
else education_num_bin = 'e. 15+';
run;

/*race & sex*/
data rg.df;
format race_sex $50.;
format race_sex_bin $20.;
set rg.df; 
race_sex = compress(race)||' - '||compress(sex);
if race_sex in ('Asian-Pac-Islander - Male','White - Male') then race_sex_bin = 'c. High';
else if race_sex in ('White - Female','Asian-Pac-Islander - Female','Amer-Indian-Eskimo - Male','Other - Male','Black - Male') then race_sex_bin = 'b. Mid';
else race_sex_bin = 'a. Low';
run;

/*capital_gain & capital_loss*/
data rg.df;
format capital_gl_bin $20.;
set rg.df; 
if capital_gain = . then capital_gain = 0;
if capital_loss = . then capital_loss = 0;
capital_gl = capital_gain - capital_loss;
if capital_gl > 0 then capital_gl_bin = "c. > 0";
else if capital_gl < 0 then capital_gl_bin = "b. < 0";
else capital_gl_bin = "a. = 0";
run;

/*marital_status & relationship*/
data rg.df;
format msr $50.;
format msr_bin $20.;
set rg.df; 
msr = compress(marital_status)||' - '||compress(relationship);
if msr in ('Married-AF-spouse - Wife','Married-civ-spouse - Husband','Married-civ-spouse - Wife','Married-AF-spouse - Husband') then msr_bin = 'c. High';
else if msr in ('Widowed - Not-in-family','Divorced - Unmarried','Never-married - Not-in-family','Widowed - Unmarried','Separated - Not-in-family','Married-spouse-absent - Not-in-family','Divorced - Not-in-family','Married-civ-spouse - Other-relative','Married-civ-spouse - Own-child','Married-civ-spouse - Not-in-family') then msr_bin = 'b. Mid';
else msr_bin = 'a. Low';
run;

/*occupation*/
data rg.df;
format occupation_bin $20.;
set rg.df; 
if occupation in ('Priv-house-serv','Other-service','Handlers-cleaners') then occupation_bin = 'a. Low';
else if occupation in ('Armed-Forces','?','Farming-fishing','Machine-op-inspct','Adm-clerical') then occupation_bin = 'b. Mid - Low';
else if occupation in ('Transport-moving','Craft-repair','Sales') then occupation_bin = 'c. Mid - Mid';
else if occupation in ('Tech-support','Protective-serv') then occupation_bin = 'd. Mid - High';
else occupation_bin = 'e. High';
run;

/*hours_per_week*/
data rg.df;
format hours_per_week_bin $20.;
set rg.df; 
if hours_per_week <= 30 then hours_per_week_bin = 'a. 0-30';
else if hours_per_week <= 40 then hours_per_week_bin = 'b. 31-40';
else if hours_per_week <= 50 then hours_per_week_bin = 'd. 41-50 & 61-70';
else if hours_per_week <= 60 then hours_per_week_bin = 'e. 51-60';
else if hours_per_week <= 70 then hours_per_week_bin = 'd. 41-50 & 61-70';
else hours_per_week_bin = 'c. 71-100';
run;

%macro rg_bin (var);
proc sql;
select &var., count(y) as cnt_y, mean(y) as avg_y
from rg.df
group by &var.;
quit;
%mend;

%rg_bin(age_bin);
%rg_bin(workclass_bin);
%rg_bin(education_bin);
%rg_bin(education_num_bin);
%rg_bin(race_sex_bin);
%rg_bin(capital_gl_bin);
%rg_bin(msr_bin);
%rg_bin(occupation_bin);
%rg_bin(hours_per_week_bin);

data rg.df (keep=
y
flag
age_bin
workclass_bin
education_bin
education_num_bin
race_sex_bin
capital_gl_bin
msr_bin
occupation_bin
hours_per_week_bin
);
set rg.df;
run;