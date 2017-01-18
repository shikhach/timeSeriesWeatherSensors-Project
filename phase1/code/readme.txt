Description
===========
This project contains phase1 folder with 3 sub-folders:
1- code
2- report
3- results


1. Files in 'result' folder

Under results folder, are two folders, one called temperature and the other called humidity.

For each dataset, for each active inference approach, and for each of the following budget cases, generated a csv file that has the same format(.csv) as the test file, except instead of actual sensor readings, it contains observed/predicted sensor readings.

Active inference budgets: [0, 5, 10, 20, 25]. These budgets indicate how many sensors at time t can communicate their readings to the central server. These are not percentages. These are actual counts.

Total files in humidity and temeprature folders:
 dataset(2) x active inference approach (2) x budget (5) = 20 csv files.
-------------------------------------------------------------------------
Under the temperature folder, have the following 20, .csv files

w0.csv, w5.csv, w10.csv, w20.csv and w25.csv
-------------------------------------------------------------------------
v0.csv, v5.csv, v10.csv, v20.csv and v25.csv
-------------------------------------------------------------------------
w[b].csv files correspond to window active inference with budget b and  vb].csv files correspond to variance active inference with budget b.

Same is for the humidity folder, It has the following 20, .csv files

w0.csv, w5.csv, w10.csv, w20.csv and w25.csv
-------------------------------------------------------------------------
v0.csv, v5.csv, v10.csv, v20.csv and v25.csv
-------------------------------------------------------------------------

2. Report

Report has total 8 plots including two plots (one per dataset) comparing different active inference strategies at each budget level. Bar graphs where x axis is buget, Y axis is mean absolute error.

3. Code

Programming language and technology used:
_________________________________________
R (version 3.2.4) , RStudio

OS- Windows 10

Packages used- gdata

MS Excel 