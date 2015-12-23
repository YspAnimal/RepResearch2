#Set working directory and then download file, unzip it if it does not exist
setwd("C:/Users/soloveynv/Documents/R Scripts/Coursera/RepResearch2")
library(data.table)
library(R.utils)
library(ggplot2)
library(plyr)
library(dplyr)
URL <- "https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2FStormData.csv.bz2"
destFile <- "StormData.csv.bz2"
DataFile <- "StormData.csv"
if (!file.exists(destFile)){
  download.file(URL, destfile = destFile, mode='wb')
}
bunzip2(destFile, DataFile)
StormData <- fread(DataFile)
str(StormData)
StormData$BGN_DATE <- as.Date(StormData$BGN_DATE, format = "%m/%d/%Y %H:%M:%S")

#Aggregate data frame by EVType and sum of fatalities and injuries

StormDataAGG <- ddply(StormData, "EVTYPE", function(X) data.frame(FATALITIES=sum(X$FATALITIES),INJURIES=sum(X$INJURIES)))
StormDataAGG <- filter(StormDataAGG, FATALITIES>0 | INJURIES>0)

