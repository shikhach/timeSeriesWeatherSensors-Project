Description
===========
This project contains phase2 folder with 3 sub-folders:
1- code
2- report
3- results


1. Files in 'results' folder

Under results folder, are two folders, one called temperature and the other called humidity.

For each dataset, for each active inference approach, and for each of the following budget cases, generated a csv file that has the same format(.csv) as the test file, except instead of actual sensor readings, it contains observed/predicted sensor readings.

Active inference budgets: [0, 5, 10, 20, 25]. These budgets indicate how many sensors at time t can communicate their readings to the central server. These are not percentages. These are actual counts.

Total files in humidity and temeprature folders:
 dataset(2) x active inference approach (2) x Phase1 x Phase2-Model1 x Phase2-Model1  x budget (5) = 40 csv files.
-------------------------------------------------------------------------
Under the temperature folder, have the following 20, .csv files

d-w0.csv, d-w5.csv, d-w10.csv, d-w20.csv and d-w25.csv
-------------------------------------------------------------------------
d-v0.csv, d-v5.csv, d-v10.csv, d-v20.csv and d-v25.csv
-------------------------------------------------------------------------

h-w0.csv, h-w5.csv, h-w10.csv, h-w20.csv and h-w25.csv
-------------------------------------------------------------------------
h-v0.csv, h-v5.csv, h-v10.csv, h-v20.csv and h-v25.csv
-------------------------------------------------------------------------
w[b].csv files correspond to window active inference with budget b and  v[b].csv files correspond to variance active inference with budget b.
(h) is for Phase2 model1 (where time is stationary)
(d) is for Phase2 model1 (where day is stationary)

Same is for the humidity folder, It has the following 20, .csv files
d-w0.csv, d-w5.csv, d-w10.csv,  d-w20.csv and d-w25.csv
-------------------------------------------------------------------------
d-v0.csv, d-v5.csv, d-v10.csv, d-v20.csv and d-v25.csv
-------------------------------------------------------------------------


h-w0.csv, h-w5.csv, h-w10.csv, h-w20.csv and h-w25.csv
-------------------------------------------------------------------------
h-v0.csv, h-v5.csv, h-v10.csv, h-v20.csv and h-v25.csv
-----------------------------------------------------------------------

2. Report

Report has total 10 plots comparing different active inference strategies at each budget level with models from phase 1 and phase2. Bar graphs where x axis is Phase1,Phase2 models,Y axis is mean absolute error.


3. Code

Files named phase2.R, phase2model2.R


Programming language and technology used:
_________________________________________
R (version 3.2.4) , RStudio

OS- Windows 10

Packages used- gdata

MS Excel 