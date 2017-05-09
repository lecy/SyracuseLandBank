# Extracting Data from Census


#Census Data For Syracuse
This report will walk through the steps to collect and wrangle census data from the Census API. ACS data from 2011-2015 and dicennial census data from 2000 and 2010 are collected. 


## The censusapi package

The censusapi package is one of many packages that will allow you to retrieve data from any <a href="http://www.census.gov/data/developers/data-sets.html">Census API</a> as well as metadata about the <a href="http://api.census.gov/data.html">available datasets</a> and each API's <a href= "http://api.census.gov/data/2000/sf1/variables.html">variables</a> and <a href="http://api.census.gov/data/2000/sf1/geography.html">geographies</a>

##Installation
The installation of the censusapi package requires the devtools package.

```r
#install.packages("devtools")
devtools::install_github("hrecht/censusapi")
library(censusapi)
library(dplyr)
```



For any call to the Census API you will need an API Key. You can find it <a href="http://api.census.gov/data/key_signup.html">here</a> or at http://api.census.gov/data/key_signup.html

##Obtaining the data
The next steps use the censusapi package to obtain data from the Census given specific variable names. Variables names were retrieved from places such as https://www.censusreporter.com and https://www.census.gov/data.html

### The American Community Survey 
The American Community Survey (ACS) is an ongoing statistical survey by the U.S. Census Bureau, sent to approximately 250,000 addresses monthly (or 3 million per year). It regularly gathers information previously contained only in the long form of the decennial census. 
<br>
<br>
Click <a href="https://www.census.gov/programs-surveys/acs/about.html">here</a> for more information on the American Community Survey (ACS). 

###Obtain ACS DATA
This section will iterate how to download ACS Data from the years of 2011-2015. 
####API Key
Before we start, we need to obtain an API key from the US Census API. You can find it <a href="http://api.census.gov/data/key_signup.html">here</a> or at http://api.census.gov/data/key_signup.html
 
After you get your key, save it as a variable in R. 

```r
censuskey <- **yourAPIKEY**
```



####Loop the getCensus function
The next step is to use the getCensus function from the censusapi package in a loop to obtain data for the years of 2011-2015. Variables names were retrieved from places such as https://www.censusreporter.com and https://www.census.gov/data.html. We gather data for all census tracts ("tract:*") in Onondaga county and subset from there. See code and commented notes for more. 

```r
#loop to obtain data for years between 2011 and 2015
temp<- NULL
census<- NULL
for(i in 2011:2015)          
{
temp <- getCensus(name = "acs5", vintage = i, key = censuskey, 
                  vars = c("NAME","B01001_001E", 
                           "B19013_001E", "B19113_001E", 
                           "B01001B_001E","B01001D_001E",
                           "B01001I_001E","B01001A_001E",
                           "B23025_004E", "B23025_005E", 
                           "B23025_002E", "B17001_002E", 
                           "B25004_001E", "B25004_008E", 
                           "B25004_002E", "B25004_006E", 
                           "B25004_004E", "B22003_002E", 
                           "B11001_001E", "B25003_002E", 
                           "B25003_003E","B25051_001E", 
                           "B25051_003E", "B25047_003E", 
                           "B25105_001E", "B09001_001E", 
                           "B17010_017E", "B08136_001E", 
                           "B14001_002E"), region = "tract:*", regionin = "state: 36 + county:067")

#add a year variable 
temp <- mutate(temp, year = i) 

#add the data from the year to the full dataset
census<- rbind(census, temp) 
}

#create geoid and add to dataset
GEOID <- paste0(census$state, census$county, census$tract) 
census <- mutate(census, GEOID) 

#make nice labels
labels <- c("name", "state", "county", 
            "tract", "total", "medianHouseIncome", 
            "medianFamIncome", "black", "asian", 
            "hispanic", "white","employed", "unemployed", 
            "inLaborForce", "poverty", "vacantTotal", "otherVacant", 
            "vacantForRent", "seasonalVacant", "forSaleVacant","householdReceivedSnap",
            "households",  "ownerOccupied", "renterOccupied","totalHousingUnits",
            "lackingKitchenFacilities", "lackingPlumbing", "medianMonthlyHousingCosts",
            "less18", "singleMotherBelowPoverty", "travelTimeToWorkMin", "enrolledInSchool", 
            "year", "GEOID") 

#make labels uppercase
labels <- toupper(labels) 

#set labels
names(census) <- labels 

#make data frame a tibble
census <- tbl_df(census) 

#obtain just syracuse census tracts
syrCensus<- filter(census, as.numeric(TRACT)<10000) 
```


###Dicennial Census 2010
Next we obtain data for the Dicennial Census from 2010. Again, variable names are retrieved from places such as https://www.censusreporter.com and https://www.census.gov/data.html.Click code to the right for more info. 

```r
#get sf1 2010 census data
census2010 <- getCensus(name = "sf1", vintage = 2010, 
                        key = censuskey,
                        vars = c("NAME", "P0010001", "P0030002", 
                                 "P0030003", "P0030005", "P0040003", 
                                 "H0030003",  "H0050008", "H0050002", 
                                 "H0050006", "H0050004", "P0180001", "H0140002", 
                                 "H0040004", "H00010001", "P0160002"),
                        region = "tract:*", 
                        regionin = "state: 36 + county:067") 
#set year variable
census2010$YEAR <- 2010
#create geoid variable
census2010 <- tbl_df(census2010)
GEOID <- paste0(census2010$state, census2010$county, census2010$tract)
census2010 <- mutate(census2010, GEOID)

#set names
names(census2010) <- toupper(c("name","state", "county", "tract",
                       "total", "white", "black", "asian", 
                       "hispanic", "vacant", "otherVacant", 
                       "vacantForRent", "seasonalVacant", "forSaleVacant",
                       "households", "ownerOccupied", "renterOccupied", 
                       "totalHousingUnits", "less18", "year", "geoid")) 

#obtain just syracuse tracts
census2010<- filter(census2010, as.numeric(TRACT)<10000) 
```
###Dicennial Census 2000
Next we obtain data for the Dicennial Census from 2000. Again, variable names are retrieved from places such as https://www.censusreporter.com and https://www.census.gov/data.html. Click code to the right for more info.

```r
#getting the dicennial 2000 data
census2000 <- getCensus(name = "sf1", vintage = 2000, 
                        key = censuskey, 
                        vars = c("NAME", "P001001", "P003003", 
                                 "P003004", "P003006", "P004002", 
                                 "H005001", "H005007", "H005002", 
                                 "H005005", "H005003", "P015001", 
                                 "H004002", "H004003","H001001"), 
                        region = "tract:*", 
                        regionin = "state: 36 + county:067") 
census2000$YEAR <- 2000

#create one id for geography
GEOID <- paste0(census2000$state, census2000$county, census2000$tract) #create geoid 
census2000 <- mutate(census2000, GEOID)

#change names
names(census2000) <- toupper(c("name","state", "county", "tract",
                       "total", "white", "black", "asian", 
                       "hispanic", "vacant", "otherVacant", 
                       "vacantForRent", "seasonalVacant", 
                       "forSaleVacant", "households", 
                       "ownerOccupied", "renterOccupied", "totalHousingUnits", "year", "geoid")) 
#get just syracuse census tracts
census2000 <- tbl_df(census2000)
census2000<- filter(census2000, as.numeric(TRACT)<10000) 

#get more 2000 census data (different api)
moreCensus2000<- getCensus(name = "sf3", vintage = 2000, 
                           key = censuskey,
                           vars = c("NAME", "P053001", "P077001",
                                    "P043007", "P043014", "P043003",
                                    "P043010", "P087002", "P087001", 
                                    "H047003", "H050003", "P130003", "P038010", "H076001"), 
                           region = "tract:*", regionin = "state: 36 + county:067") 
moreCensus2000$year <- 2000
moreCensus2000 <- tbl_df(moreCensus2000)

GEOID <- paste0(moreCensus2000$state, moreCensus2000$county, moreCensus2000$tract)
moreCensus2000 <- mutate(moreCensus2000, GEOID)

#change names
names(moreCensus2000) <- toupper(c("name", "state", "county", "tract", 
                           "medianHouseIncome", "medianFamIncome", "maleUnemployed",
                           "femaleUnemployed", "maleLaborForce", "femaleLaborForce", 
                           "poverty", "totalForPoverty", "lackingPlumbing",
                           "lackingKitchenFacilities", "aggregateTravelTimeToWork",
                           "enrolledInSchool", "housingValues", "year", "geoid")) 

#obtain just syracuse census tracts
moreCensus2000<- filter(moreCensus2000, as.numeric(TRACT)<10000) 

#merge two frames together
totalCensus2000 <- merge(census2000, moreCensus2000)
```

##Merge all datasets together
Next we need to merge the 2011-2015, 2010, and 2000 data together into one dataframe. Year variables were created in earlier code to notate which data is which. 

```r
#find all unique names for all the datasets
all <- names(syrCensus)
all <- c(all, names(totalCensus2000))
all <- c(all, names(census2010))
all <- unique(all) 

#create an empty dataframe with 42 columns of unique names
df = data.frame(matrix(vector(), 0, 42,
                dimnames=list(c(), all)),
                stringsAsFactors=F) 
#merge datasets with empty frame
a <- merge(df, syrCensus, all = T) 
b <- merge(df, totalCensus2000, all = T)
c <- merge(df, census2010, all = T)

#add datasets together
fullFrame <- rbind(a, b)
fullFrame <- rbind(fullFrame, c)

#change tract names for later aggregation
fullFrame$TRACT<- as.numeric(fullFrame$TRACT)/100
names(fullFrame)[names(fullFrame)=="TRACT"] <- "TRACT1"
names(fullFrame)[names(fullFrame)=="GEOID"] <- "TRACT"
```

##Write dataset to .csv file
For data analysis, the full frame is written to a csv file. 

```r
#setwd("../..")
fullFrame <- arrange(fullFrame, YEAR, TRACT)
#write.csv(fullFrame, file = "./DATA/AGGREGATED_DATA/censusDataFromChris.csv")
```



##Load Shapefile for Descriptive Use
Next we obtain a shapefile of Syracuse Census tracts to be used for visual analysis.

```r
library( rgdal )
library( maptools )
library( geojsonio )
library(dplyr)
library(RColorBrewer)
library(maps)

syr <- readOGR(dsn = "https://raw.githubusercontent.com/lecy/SyracuseLandBank/master/SHAPEFILES/SYRCensusTracts.geojson")
```

```
## OGR data source with driver: GeoJSON 
## Source: "https://raw.githubusercontent.com/lecy/SyracuseLandBank/master/SHAPEFILES/SYRCensusTracts.geojson", layer: "OGRGeoJSON"
## with 55 features
## It has 12 fields
```

##Create shiny plot for descriptive use
Shiny is a web application framework for R created by RStudio. 

First, we must load the library

```r
#load shiny
library(shiny)
```

Then, we make certain descriptive statistics in percent form for certain variables.

```r
#make descriptive statistics in percent form for certain variables
forDescriptives <- select(fullFrame, -c(NAME, STATE, COUNTY, TRACT, TRACT1, YEAR))
forDescriptives$BLACK <- forDescriptives$BLACK/forDescriptives$TOTAL
forDescriptives$WHITE <- forDescriptives$WHITE/forDescriptives$TOTAL
forDescriptives$HISPANIC <- forDescriptives$HISPANIC/forDescriptives$TOTAL
forDescriptives$ASIAN <- forDescriptives$ASIAN/forDescriptives$TOTAL
forDescriptives$EMPLOYED <- forDescriptives$EMPLOYED/forDescriptives$INLABORFORCE
forDescriptives$UNEMPLOYED <- forDescriptives$UNEMPLOYED/forDescriptives$INLABORFORCE
forDescriptives$POVERTY <- forDescriptives$POVERTY/forDescriptives$TOTALFORPOVERTY
```
Next, we create the code for the dropdown boxes. More info can be gotten at https://shiny.rstudio.com/

```r
#create dropdown box for name
selectInput(
    inputId = "nameInput",
    label = "",
    choices = names(forDescriptives), 
    selected = "TOTAL",
    selectize = F, 
    width = "160px"
   
)

#create dropdown box for year
selectInput(
    inputId = "yearInput",
    label = "",
    choices = unique(fullFrame$YEAR), 
    selected = 2015,
    selectize = F, 
    width = "160px"
)
```
Next, we use the renderPlot() function to render the plot. Plotting takes the form like it would without shiny, except instead of using one variable name we use the inputs from the user to choose which variables to use. 

```r
#create shiny plot
renderPlot({
#reference the inputs from the user
myName <- input$nameInput
myYear <- input$yearInput
#subset by year
myData <- forDescriptives[fullFrame$YEAR==myYear, ]
#get variable for plot
myVar <- myData[, myName]
#remove NAs
myVar[is.na(myVar)] <- 0


#create color scheme for plot
color.function <- colorRampPalette( c("firebrick4","light gray", "steel blue") ) 
col.ramp <- color.function( 5 ) # number of groups you desire
color.vector <- cut( rank(myVar), breaks=5, labels=col.ramp )
color.vector <- as.character( color.vector )
this.order <- match( syr$GEOID10, fullFrame$TRACT)
color.vec.ordered <- color.vector[ this.order ]

#plot
plot(syr, col=color.vec.ordered, main = paste(myName, "in", myYear, sep = " "), cex.main = 2)
#create scale
map.scale( metric=F, ratio=F, relwidth = 0.15, cex=2 )


#create labels for legend
first <- round(quantile(myVar, probs = seq(0, .8, .2)), digits = 2)
last <- round(quantile(myVar, probs = seq(.2, 1, .2)), digits = 2)
legend.text <- paste(first, last, sep = "-")


#create legend
legend( "bottomright", bg="white",
        pch=19, pt.cex=2, cex=2,
        legend=legend.text, 
        col=col.ramp, 
        box.col="white",
        title= paste(myName, "in", myYear, sep = " ") 
       )
}, width = 959, height= 665)
```



<iframe src="https://chriswdavis.shinyapps.io/descriptives/" width = "100%" height = "800" scrolling = "no" frameborder = "0">
  <p>Your browser does not support iframes.</p>
</iframe>
