#Set working directory and then download file, unzip it if it does not exist
setwd("C:/R_repositories/Coursera/RepResearch2")
library(data.table)
library(R.utils)
library(ggplot2)
library(plyr)
library(dplyr)
library(stringdist)
library(grid) # for grids
library(gridExtra) # for advanced plots

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

neededColumns <- c("BGN_DATE", "EVTYPE", "FATALITIES", "INJURIES", "PROPDMG", "PROPDMGEXP", "CROPDMG", "CROPDMGEXP")
StormData <- select(StormData, one_of(neededColumns))


StormData$CleanEVTYPE <- NA_character_
StormData[grepl("precipitation|rain|hail|drizzle|wet|percip|burst|depression|fog|wall cloud", StormData$EVTYPE, ignore.case = TRUE), "CleanEVTYPE"] <- "Precipitation & Fog"
StormData[grepl("wind|storm|wnd|hurricane|typhoon", StormData$EVTYPE, ignore.case = TRUE), "CleanEVTYPE"] <- "Wind & Storm"
StormData[grepl("slide|erosion|slump", StormData$EVTYPE, ignore.case = TRUE), "CleanEVTYPE"] <- "Landslide & Erosion"
StormData[grepl("warmth|warm|heat|dry|hot|drought|thermia|temperature record|record temperature|record high", StormData$EVTYPE, ignore.case = TRUE), "CleanEVTYPE"] <- "Heat & Drought"
StormData[grepl("cold|cool|ice|icy|frost|freeze|snow|winter|wintry|wintery|blizzard|chill|freezing|avalanche|glaze|sleet", StormData$EVTYPE, ignore.case = TRUE), "CleanEVTYPE"] <- "Snow & Ice"
StormData[grepl("flood|surf|blow-out|swells|fld|dam break", StormData$EVTYPE, ignore.case = TRUE), "CleanEVTYPE"] <- "Flooding & High Surf"
StormData[grepl("seas|high water|tide|tsunami|wave|current|marine|drowning", StormData$EVTYPE, ignore.case = TRUE), "CleanEVTYPE"] <- "High seas"
StormData[grepl("dust|saharan", StormData$EVTYPE, ignore.case = TRUE), "CleanEVTYPE"] <- "Dust & Saharan winds"  
StormData[grepl("tstm|thunderstorm|lightning", StormData$EVTYPE, ignore.case = TRUE), "CleanEVTYPE"] <- "Thunderstorm & Lightning"
StormData[grepl("tornado|spout|funnel|whirlwind", StormData$EVTYPE, ignore.case = TRUE), "CleanEVTYPE"] <- "Tornado"
StormData[grepl("fire|smoke|volcanic", StormData$EVTYPE, ignore.case = TRUE), "CleanEVTYPE"] <- "Fire & Volcanic activity"

# remove uncategorized records (CleanEVTYPE == NA) & cast as factor
StormData <- StormData[complete.cases(StormData$CleanEVTYPE), ]
StormData$CleanEVTYPE <- as.factor(StormData$CleanEVTYPE)


#Aggregate data frame by EVType and sum of fatalities and injuries
StormDataAggFI <- ddply(StormData, "CleanEVTYPE", function(x) data.frame(FATALITIES=sum(x$FATALITIES),INJURIES=sum(x$INJURIES)))

#We need only rows with FATALITIES or INJURIES insteand of 0
StormDataAggFI <- filter(StormDataAggFI, FATALITIES>0 | INJURIES>0)

#Drop columns that doesn't need in analyse
StormDataAggDam <- ddply(StormData, "CleanEVTYPE", function(x) data.frame(PROPDMG=x$PROPDMG, PROPDMGEXP=x$PROPDMGEXP, CROPDMG=x$CROPDMG, CROPDMGEXP=x$CROPDMGEXP))
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
# 0 to invalid exponent data, so they not count in
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

StormDataAggDam <- ddply(StormDataAggDam, "CleanEVTYPE", function(x) data.frame(PROPDMGVAL=sum(x$PROPDMGVAL),CROPDMGVAL=sum(x$CROPDMGVAL)))
meltStormDataAggDam <- melt(StormDataAggDam)

#Transform value in EVTYPE column. We will use this rule: The EVTYPE contains ca. 985 unique source events. 
#Many of them can be reduced to similar instances. 
#In this instance there are 11 levels defined, covering effectifly the majority and all useful data records (summaries and combinations are skipped)

fatalitiesPlot <- qplot(reorder(CleanEVTYPE, FATALITIES), data = StormDataAggFI, weight=FATALITIES, geom = "bar") + 
    scale_y_continuous("Number of Fatalities") + 
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) + xlab("Event Type") + 
    ggtitle("Total Fatalities by Severe Weather\n Events in the U.S.")

injuriesPlot <- qplot(reorder(CleanEVTYPE, INJURIES), data = StormDataAggFI, weight=INJURIES, geom = "bar") + 
    scale_y_continuous("Number of Injuries") + 
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) + xlab("Event Type") +
    ggtitle("Total Injuries by Severe Weather\n Events in the U.S.")
    
grid.arrange(fatalitiesPlot, injuriesPlot, ncol = 2)    


ggplot(meltStormDataAggDam, aes(x=reorder(CleanEVTYPE, value), y=value/1000000, fill=variable)) +
    geom_bar(stat="identity") + 
    scale_y_continuous("Total Damage (millions of USD)") + 
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) + 
    xlab("Event Type") + 
    ggtitle("Aggregated property and crop damage for weather events") +
    scale_fill_discrete(name="Damage type", labels=c("Property Damages", "Crop Damages"))




