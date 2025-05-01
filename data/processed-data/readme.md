# processed-data

This folder contains data that has been processed and cleaned by code.

Any files located in here are based on the raw data and can be re-created running the various processing/cleaning code scripts in the `code` folder.

The processedata file is a cleaned and conjoined version of the raw data found in rawdata. Additionally, new columns were added from calculations, like total case count.

The processedcasedata file is a file containing a more complete version of case counts for plotting later. This is because a majority of the data is filtered out in processeddata. 




Data Dictionary for processeddata.rds

- Each row represent a different day for a given county.

- Columns 1-3 are used to identify the location of the given day observed.

- Column 4, date, is the date.

- Column 5, total_cases, is the measure of total cases up to that day.

- Column 6, retail_and_recreation_percent_change_from_baseline, is the change in mobility for retail and recreational areas measured in percent change from baseline.

- Column 7, grocery_and_pharmacy_percent_change_from_baseline, is the change in mobility for grocery and pharmaceutical areas measured in percent change from baseline.

- Column 8, workplaces_percent_change_from_baseline, is the change in mobility for workplace areas measured in percent change from baseline.

- Column 9, residential_percent_change_from_baseline, is the change in mobility for residential areas measured in percent change from baseline.

- Column 10, new_cases, is the change in case count from the day before to the current day. In other words, this measures the amount of new cases that occur on the given day.

- Column 11, year, is the year of the given day.

- Column 12, population_count, is the county's population count during that given year. Daily population count was unable to be found.

- Column 13, incidence_rate, is the rate of new cases per day per 10,000.

- Column 14, pop_density, is the population density calculated by dividing the population county by the county's km squared area.

Further feature engineering does occur in statistical-analysis.qmd.
