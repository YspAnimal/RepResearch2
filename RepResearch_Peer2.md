
# Analysis of impact, both economic as victims, of different weather events in the USA based on the NOAA Storm Database

By Nikolay Solovey (animal1986@mail.ru)
Date: 15-03-2016

###Assignment

The basic goal of this assignment is to explore the NOAA Storm Database and answer some basic questions about severe weather events. You must use the database to answer the questions below and show the code for your entire analysis. Your analysis can consist of tables, figures, or other summaries. You may use any R package you want to support your analysis.

###Synopsis
In this report, we aim to analyze the impact of different weather events on public health and economy based on the storm database collected from the U.S. National Oceanic and Atmospheric Administration's (NOAA) from 1950 - 2011. We will use the estimates of fatalities, injuries, property and crop damage to decide which types of event are most harmful to the population health and economy. From these data, we found that excessive heat and tornado are most harmful with respect to population health and Flooding & High surf, Wind & Storm have the greatest economic consequences.

###Data Processing

```
## R version 3.2.3 (2015-12-10)
## Platform: x86_64-w64-mingw32/x64 (64-bit)
## Running under: Windows 10 x64 (build 10240)
## 
## locale:
## [1] LC_COLLATE=Russian_Russia.1251  LC_CTYPE=Russian_Russia.1251   
## [3] LC_MONETARY=Russian_Russia.1251 LC_NUMERIC=C                   
## [5] LC_TIME=Russian_Russia.1251    
## 
## attached base packages:
## [1] stats     graphics  grDevices utils     datasets  methods   base     
## 
## loaded via a namespace (and not attached):
##  [1] magrittr_1.5    formatR_1.3     tools_3.2.3     htmltools_0.3  
##  [5] yaml_2.1.13     stringi_1.0-1   rmarkdown_0.9.5 knitr_1.12.3   
##  [9] stringr_1.0.0   digest_0.6.9    evaluate_0.8.3
```

##### 3.1. Load libraries
Necessary libraries to perform loading, computation, transformation and plotting of data

```r
library(data.table) # For loading data into a dataframe and for melt method
library(R.utils) # For bunzip2
library(ggplot2) # For plots
library(plyr) # For aggregate and summarise data
library(dplyr) # For aggregate and summarise data
library(grid) # for grids
library(gridExtra) # for advanced plots
```

##### 3.2. Load source file and extract it
Start loading the specified source files from URL and storing it locally

```r
URL <- "https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2FStormData.csv.bz2"
destFile <- "StormData.csv.bz2"
DataFile <- "StormData.csv"
if (!file.exists(destFile)){
    download.file(URL, destfile = destFile, mode='wb')
}
if (!file.exists(DataFile)){
    bunzip2(destFile, DataFile)
}
```

##### 3.3. Load the data
Read the source .csv file

```r
StormData <- fread(DataFile)
```

```
## 
Read 18.6% of 967216 rows
Read 35.2% of 967216 rows
Read 50.7% of 967216 rows
Read 62.0% of 967216 rows
Read 75.5% of 967216 rows
Read 82.7% of 967216 rows
Read 902297 rows and 37 (of 37) columns from 0.523 GB file in 00:00:09
```

##### 3.4. Remove unwanted colums (not used for this analysis)
Just keep the columns: BGN_DATE, EVTYPE, FATALITIES, INJURIES, PROPDMG, PROPDMGEXP, CROPDMG, CROPDMGEXP needed for analysis

```r
neededColumns <- c("BGN_DATE", "EVTYPE", "FATALITIES", "INJURIES", "PROPDMG", "PROPDMGEXP", "CROPDMG", "CROPDMGEXP")
StormData <- select(StormData, one_of(neededColumns))
```
















