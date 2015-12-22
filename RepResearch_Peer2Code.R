#Set working directory and then download file, unzip it if it does not exist
setwd("C:/Users/soloveynv/Documents/R Scripts/Coursera/RepResearch2")
library(data.table)
library(R.utils)
URL <- "https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2FStormData.csv.bz2"
destFile <- "StormData.csv.bz2"
DataFile <- "StormData.csv"
if (!file.exists(destFile)){
  download.file(URL, destfile = destFile, mode='wb')
}
bunzip2(destFile, DataFile)
StormData <- fread(DataFile)

