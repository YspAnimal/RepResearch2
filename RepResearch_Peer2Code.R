#Set working directory and then download file, unzip it if it does not exist
setwd("C:/R_repositories/Coursera/RepResearch2")
library(data.table)
library(R.utils)
library(ggplot2)
library(plyr)
library(dplyr)
library(stringdist)
URL <- "https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2FStormData.csv.bz2"
destFile <- "StormData.csv.bz2"
DataFile <- "StormData.csv"
if (!file.exists(destFile)){
    download.file(URL, destfile = destFile, mode='wb')
}
bunzip2(destFile, DataFile)
StormData <- fread(DataFile)
str(StormData)

if (dim(StormData)[2] == 37) {
    StormData$year <- as.numeric(format(as.Date(StormData$BGN_DATE, format = "%m/%d/%Y %H:%M:%S"), "%Y"))
}
hist(StormData$year, breaks = 30)

#Aggregate data frame by EVType and sum of fatalities and injuries
StormDataAggFI <- ddply(StormData, "EVTYPE", function(x) data.frame(FATALITIES=sum(x$FATALITIES),INJURIES=sum(x$INJURIES)))

#We need only rows with FATALITIES or INJURIES insteand of 0
StormDataAggFI <- filter(StormDataAggFI, FATALITIES>0 | INJURIES>0)

StormDataAggDam <- ddply(StormData, "EVTYPE", function(x) data.frame(PROPDMG=x$PROPDMG, PROPDMGEXP=x$PROPDMGEXP, CROPDMG=x$CROPDMG, CROPDMGEXP=x$CROPDMGEXP))
StormDataAggDam <- filter(StormDataAggDam, PROPDMG>0 | CROPDMG>0)

# Sorting the property exponent data
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
# give 0 to invalid exponent data, so they not count in
StormDataAggDam$PROPEXP[StormDataAggDam$PROPDMGEXP == "+"] <- 0
StormDataAggDam$PROPEXP[StormDataAggDam$PROPDMGEXP == "-"] <- 0
StormDataAggDam$PROPEXP[StormDataAggDam$PROPDMGEXP == "?"] <- 0
# compute the property damage value
StormDataAggDam$PROPDMGVAL <- StormDataAggDam$PROPDMG * StormDataAggDam$PROPEXP

# Sorting the property exponent data
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
# compute the crop damage value
StormDataAggDam$CROPDMGVAL <- StormDataAggDam$CROPDMG * StormDataAggDam$CROPEXP

StormDataAggDam <- 

