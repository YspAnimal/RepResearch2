
# Analysis of impact, both economic as victims, of different weather events in the USA based on the NOAA Storm Database

By Nikolay Solovey (animal1986@mail.ru)
Date: 15-03-2016

### 1. Assignment

The basic goal of this assignment is to explore the NOAA Storm Database and answer some basic questions about severe weather events. You must use the database to answer the questions below and show the code for your entire analysis. Your analysis can consist of tables, figures, or other summaries. You may use any R package you want to support your analysis.

### 2. Synopsis
In this report, we aim to analyze the impact of different weather events on public health and economy based on the storm database collected from the U.S. National Oceanic and Atmospheric Administration's (NOAA) from 1950 - 2011. We will use the estimates of fatalities, injuries, property and crop damage to decide which types of event are most harmful to the population health and economy. From these data, we found that excessive heat and tornado are most harmful with respect to population health and Flooding & High surf, Wind & Storm have the greatest economic consequences.

### 3. Data Processing
Display software enviroment.

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

#### 3.1. Load libraries
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

#### 3.2. Load source file and extract it
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

#### 3.3. Load the data
Read the source .csv file

```r
StormData <- fread(DataFile)
```

#### 3.4. Remove unwanted colums (not used for this analysis)
Just keep the columns: BGN_DATE, EVTYPE, FATALITIES, INJURIES, PROPDMG, PROPDMGEXP, CROPDMG, CROPDMGEXP needed for analysis

```r
neededColumns <- c("BGN_DATE", "EVTYPE", "FATALITIES", "INJURIES", "PROPDMG", "PROPDMGEXP", "CROPDMG", "CROPDMGEXP")
StormData <- select(StormData, one_of(neededColumns))
```

#### 3.5. Refactor EVTYPE into 11 levels
The EVTYPE contains ca. 985 unique source events. Many of them can be reduced to similar instances. 
In this instance there are 11 levels defined, covering effectifly the majority and all useful data records (summaries and combinations are skipped)

```r
StormData$CleanEVTYPE <- NA_character_
StormData[grepl("precipitation|rain|hail|drizzle|wet|percip|burst|depression|fog|wall cloud",
                StormData$EVTYPE, ignore.case = TRUE), "CleanEVTYPE"] <- "Precipitation & Fog"
StormData[grepl("wind|storm|wnd|hurricane|typhoon",
                StormData$EVTYPE, ignore.case = TRUE), "CleanEVTYPE"] <- "Wind & Storm"
StormData[grepl("slide|erosion|slump",
                StormData$EVTYPE, ignore.case = TRUE), "CleanEVTYPE"] <- "Landslide & Erosion"
StormData[grepl("warmth|warm|heat|dry|hot|drought|thermia|temperature record|record temperature|record high",
                StormData$EVTYPE, ignore.case = TRUE), "CleanEVTYPE"] <- "Heat & Drought"
StormData[grepl("cold|cool|ice|icy|frost|freeze|snow|winter|wintry|wintery|blizzard|chill|freezing|avalanche|glaze|sleet",
                StormData$EVTYPE, ignore.case = TRUE), "CleanEVTYPE"] <- "Snow & Ice"
StormData[grepl("flood|surf|blow-out|swells|fld|dam break",
                StormData$EVTYPE, ignore.case = TRUE), "CleanEVTYPE"] <- "Flooding & High Surf"
StormData[grepl("seas|high water|tide|tsunami|wave|current|marine|drowning",
                StormData$EVTYPE, ignore.case = TRUE), "CleanEVTYPE"] <- "High seas"
StormData[grepl("dust|saharan",
                StormData$EVTYPE, ignore.case = TRUE), "CleanEVTYPE"] <- "Dust & Saharan winds"  
StormData[grepl("tstm|thunderstorm|lightning",
                StormData$EVTYPE, ignore.case = TRUE), "CleanEVTYPE"] <- "Thunderstorm & Lightning"
StormData[grepl("tornado|spout|funnel|whirlwind",
                StormData$EVTYPE, ignore.case = TRUE), "CleanEVTYPE"] <- "Tornado"
StormData[grepl("fire|smoke|volcanic",
                StormData$EVTYPE, ignore.case = TRUE), "CleanEVTYPE"] <- "Fire & Volcanic activity"
 # remove uncategorized records (CleanEVTYPE == NA)
StormData <- StormData[complete.cases(StormData$CleanEVTYPE), ]
StormData$CleanEVTYPE <- as.factor(StormData$CleanEVTYPE) # cast as factor
```

#### 3.6. Create aggregated datasets and variables for plots
The final data frames must be recast to be used in certain plot funtions.
Create the aggregated dataset for Injuries and Fatalities

```r
#Aggregate data frame by EVType and sum of fatalities and injuries
StormDataAggFI <- ddply(StormData, "CleanEVTYPE", 
                        function(x) data.frame(FATALITIES=sum(x$FATALITIES),INJURIES=sum(x$INJURIES)))
#We need only rows with FATALITIES or INJURIES insteand of 0
StormDataAggFI <- filter(StormDataAggFI, FATALITIES>0 | INJURIES>0)
```

Then create the dataset for Crop and Property damages.
We will convert the property damage and crop damage data into comparable numerical forms according to the meaning of units described in the code book (Storm Events). Both PROPDMGEXP and CROPDMGEXP columns record a multiplier for each observation where we have Hundred (H), Thousand (K), Million (M) and Billion (B).

```r
#We need only rows with PROPDMG or CROPDMG insteand of 0
StormDataAggDam <- filter(StormData, PROPDMG>0 | CROPDMG>0)
# Convert symbol to a power of 10 (for use with PROPDMGEXP & CROPDMGEXP)
StormDataAggDam$PROPEXP[StormDataAggDam$PROPDMGEXP == "K"] <- 1000
StormDataAggDam$PROPEXP[StormDataAggDam$PROPDMGEXP == "M"] <- 1e+06
StormDataAggDam$PROPEXP[StormDataAggDam$PROPDMGEXP == ""] <- 1
StormDataAggDam$PROPEXP[StormDataAggDam$PROPDMGEXP == "B"] <- 1e+09
StormDataAggDam$PROPEXP[StormDataAggDam$PROPDMGEXP == "m"] <- 1e+06
StormDataAggDam$PROPEXP[StormDataAggDam$PROPDMGEXP == "0"] <- 1
StormDataAggDam$PROPEXP[StormDataAggDam$PROPDMGEXP == "5"] <- 1e+05
StormDataAggDam$PROPEXP[StormDataAggDam$PROPDMGEXP == "6"] <- 1e+06
StormDataAggDam$PROPEXP[StormDataAggDam$PROPDMGEXP == "4"] <- 10000
StormDataAggDam$PROPEXP[StormDataAggDam$PROPDMGEXP == "2"] <- 100
StormDataAggDam$PROPEXP[StormDataAggDam$PROPDMGEXP == "3"] <- 1000
StormDataAggDam$PROPEXP[StormDataAggDam$PROPDMGEXP == "h"] <- 100
StormDataAggDam$PROPEXP[StormDataAggDam$PROPDMGEXP == "7"] <- 1e+07
StormDataAggDam$PROPEXP[StormDataAggDam$PROPDMGEXP == "H"] <- 100
StormDataAggDam$PROPEXP[StormDataAggDam$PROPDMGEXP == "1"] <- 10
StormDataAggDam$PROPEXP[StormDataAggDam$PROPDMGEXP == "8"] <- 1e+08
# 0 to invalid exponent data, so they not count in
StormDataAggDam$PROPEXP[StormDataAggDam$PROPDMGEXP == "+"] <- 0
StormDataAggDam$PROPEXP[StormDataAggDam$PROPDMGEXP == "-"] <- 0
StormDataAggDam$PROPEXP[StormDataAggDam$PROPDMGEXP == "?"] <- 0

StormDataAggDam$CROPEXP[StormDataAggDam$CROPDMGEXP == "M"] <- 1e+06
StormDataAggDam$CROPEXP[StormDataAggDam$CROPDMGEXP == "K"] <- 1000
StormDataAggDam$CROPEXP[StormDataAggDam$CROPDMGEXP == "m"] <- 1e+06
StormDataAggDam$CROPEXP[StormDataAggDam$CROPDMGEXP == "B"] <- 1e+09
StormDataAggDam$CROPEXP[StormDataAggDam$CROPDMGEXP == "0"] <- 1
StormDataAggDam$CROPEXP[StormDataAggDam$CROPDMGEXP == "k"] <- 1000
StormDataAggDam$CROPEXP[StormDataAggDam$CROPDMGEXP == "2"] <- 100
StormDataAggDam$CROPEXP[StormDataAggDam$CROPDMGEXP == ""] <- 1
# give 0 to invalid exponent data, so they not count in
StormDataAggDam$CROPEXP[StormDataAggDam$CROPDMGEXP == "?"] <- 0

# compute the crop and property damage value
StormDataAggDam$PROPDMGVAL <- StormDataAggDam$PROPDMG * StormDataAggDam$PROPEXP
StormDataAggDam$CROPDMGVAL <- StormDataAggDam$CROPDMG * StormDataAggDam$CROPEXP
```

Then create the aggregated dataset for Crop and Property damages

```r
StormDataAggDam <- ddply(StormDataAggDam, "CleanEVTYPE", 
                         function(x) data.frame(CROPDMGVAL=sum(x$CROPDMGVAL), PROPDMGVAL=sum(x$PROPDMGVAL)))
meltStormDataAggDam <- melt(StormDataAggDam) # Melt data frame for plot
```

```
## Using CleanEVTYPE as id variables
```
 
For the impact on public health, we have got two sorted tables of weather events below by the number of people badly affected. 

```r
fatalities <- arrange(StormDataAggFI, desc(FATALITIES))
injuries <- arrange(StormDataAggFI, desc(INJURIES))
```

For the impact on economy, we have got two sorted tables below by the amount of money cost by damages.

```r
propDAM <- arrange(StormDataAggDam, desc(PROPDMGVAL))
cropDAM <- arrange(StormDataAggDam, desc(CROPDMGVAL))
```


### 4. Results
#### 4.1. Show the first & last 5 lines of the new data sets
Display a few records of the cleaned, reformatted tables to be used for analysis

Public health

```r
head(select(fatalities, CleanEVTYPE, FATALITIES), 3)
```

```
##            CleanEVTYPE FATALITIES
## 1              Tornado       5665
## 2       Heat & Drought       2969
## 3 Flooding & High Surf       1715
```

```r
head(select(injuries, CleanEVTYPE, INJURIES), 3)
```

```
##                CleanEVTYPE INJURIES
## 1                  Tornado    91439
## 2 Thunderstorm & Lightning    14775
## 3     Flooding & High Surf     8931
```

Impact on economy 

```r
head(select(propDAM, CleanEVTYPE, PROPDMGVAL), 3)
```

```
##            CleanEVTYPE   PROPDMGVAL
## 1 Flooding & High Surf 168386072463
## 2         Wind & Storm 142713420293
## 3              Tornado  58613101167
```

```r
head(select(cropDAM, CleanEVTYPE, CROPDMGVAL), 3)
```

```
##            CleanEVTYPE  CROPDMGVAL
## 1       Heat & Drought 14871450280
## 2 Flooding & High Surf 12390067200
## 3           Snow & Ice  8721965400
```
#### 4.2. Injuries vs. Fatalities
Pair of graphs of total fatalities and total injuries affected by these weather events.

```r
fatalitiesPlot <- qplot(reorder(CleanEVTYPE, FATALITIES), data = StormDataAggFI, weight=FATALITIES, geom = "bar") + 
    scale_y_continuous("Number of Fatalities") + 
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) + xlab("Event Type") + 
    ggtitle("Total Fatalities by Weather\n Events in the U.S.")

injuriesPlot <- qplot(reorder(CleanEVTYPE, INJURIES), data = StormDataAggFI, weight=INJURIES, geom = "bar") + 
    scale_y_continuous("Number of Injuries") + 
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) + xlab("Event Type") +
    ggtitle("Total Injuries by Weather\n Events in the U.S.")
    
grid.arrange(fatalitiesPlot, injuriesPlot, ncol = 2)    
```

![](RepResearch_Peer2_files/figure-html/unnamed-chunk-14-1.png)

Based on the above graphs, we find that excessive "Heat & Drought" and "Tornado" cause most fatalities; "Tornado" causes most injuries in the United States from 1950 to 2011.

#### 4.3. Economic Damage
Graphic of crop and property damages by these weather events.

```r
ggplot(meltStormDataAggDam, aes(x=reorder(CleanEVTYPE, value), y=value/1000000, fill=variable)) +
    geom_bar(stat="identity") + 
    scale_y_continuous("Total Damage (millions of USD)") + 
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) + 
    xlab("Event Type") + 
    ggtitle("Aggregated property and crop damage for weather events") +
    scale_fill_discrete(name="Damage type", labels=c("Crop Damages", "Property Damages"))
```

![](RepResearch_Peer2_files/figure-html/unnamed-chunk-15-1.png)

Based on the above graph, we find that "Flooding & High Surf" cause most property damage. "Heat & Drought" causes most crop damage in the United States from 1950 to 2011.
