# Public Housing



## Public Housing Data

To examine the effects of public housing avaliability on home values we will use data on the number of subsidized units avaliable in each census tract every year between 2010 and 2015. This data was obtained from HUD (https://www.huduser.gov/portal/datasets/assthsg.html#2009-2016_query).

## 1. Load public housing data from Github

Data from each year is stored in its own csv. We'll first read in each csv and then will combine them and clean the data.


```r
#Read in 2010 data
pubhous.2010 <- read.csv("https://raw.githubusercontent.com/lecy/SyracuseLandBank/master/DATA/RAW_DATA/publichousing%202010.csv", header = TRUE)

#Read in 2011 data
pubhous.2011 <- read.csv("https://raw.githubusercontent.com/lecy/SyracuseLandBank/master/DATA/RAW_DATA/publichousing%202011.csv", header = TRUE)

#Read in 2012 data
pubhous.2012 <- read.csv("https://raw.githubusercontent.com/lecy/SyracuseLandBank/master/DATA/RAW_DATA/publichousing%202012.csv", header = TRUE)

#Read in 2013 data
pubhous.2013 <- read.csv("https://raw.githubusercontent.com/lecy/SyracuseLandBank/master/DATA/RAW_DATA/publichousing%202013.csv", header = TRUE)

#Read in 2014 data
pubhous.2014 <- read.csv("https://raw.githubusercontent.com/lecy/SyracuseLandBank/master/DATA/RAW_DATA/publichousing%202014.csv", header = TRUE)

#Read in 2015 data
pubhous.2015 <- read.csv("https://raw.githubusercontent.com/lecy/SyracuseLandBank/master/DATA/RAW_DATA/publichousing%202015.csv", header = TRUE)

#Load in Syracuse shapefile 
syr <- geojson_read("https://raw.githubusercontent.com/lecy/SyracuseLandBank/master/SHAPEFILES/SYRCensusTracts.geojson", method="local", what="sp" )
```

## 2.  Add a year column into each data set


```r
#For each data set add a column with the year the data corresponds to 
pubhous.2010.1 <- mutate( pubhous.2010 , year = "2010")

pubhous.2011.1 <- mutate( pubhous.2011 , year = "2011")

pubhous.2012.1 <- mutate( pubhous.2012 , year = "2012")

pubhous.2013.1 <- mutate( pubhous.2013 , year = "2013")

pubhous.2014.1 <- mutate( pubhous.2014 , year = "2014")

pubhous.2015.1 <- mutate( pubhous.2015 , year = "2015")
```

## 3. Rename census tracts

The same general steps are followed for each year: drop unnecessary columns, filter the data to include only Onondaga county, and create a new column with a numeric variable for census tract. Different years varied slightly in formatting in the original data so these steps are done for specific years before all the data is combined.


```r
#Rename 2010 census tracts

#First drop all columns except program (which identifies it as public housing), name (census tract), units avaliable, and year
pubhous.2010.2 <- pubhous.2010.1[ , c("Program.label","Name", "Subsidized.units.available", "year") ]

#Next filter the data to include only census tracts inside Onondaga county
pubhous.2010.3 <- filter( pubhous.2010.2 , Name %in% grep( "Onondaga", pubhous.2010.2$Name, value = T ) )

#Finally create a new column with a numeric variable for census tract
pubhous.2010.4 <- mutate( pubhous.2010.3, tract = as.numeric( substring(pubhous.2010.3$Name , 33) ) )


#Rename 2011 census tracts

pubhous.2011.2 <- pubhous.2011.1[ , c("Program.label","Name", "Subsidized.units.available", "year") ]

pubhous.2011.3 <- filter( pubhous.2011.2 , Name %in% grep( "Onondaga", pubhous.2011.2$Name, value = T ) )

pubhous.2011.4 <- mutate( pubhous.2011.3, tract = as.numeric( substring(pubhous.2011.3$Name , 33) ) )


#Rename 2012 census tracts

pubhous.2012.2 <- pubhous.2012.1[ , c("Program.label","Name", "Subsidized.units.available", "year") ]

pubhous.2012.3 <- filter( pubhous.2012.2 , Name %in% grep( "Onondaga", pubhous.2012.2$Name, value = T ) )

pubhous.2012.4 <- mutate( pubhous.2012.3, tract = as.numeric( str_sub(pubhous.2012.3$Name , -5) ) / 100 )


#Rename 2013 census tracts

pubhous.2013.2 <- pubhous.2013.1[ , c("Program.label","Name", "Subsidized.units.available", "year") ]

pubhous.2013.3 <- filter( pubhous.2013.2 , Name %in% grep( "Onondaga", pubhous.2013.2$Name, value = T ) )

pubhous.2013.4 <- mutate( pubhous.2013.3, tract = as.numeric( str_sub(pubhous.2013.3$Name , -5) ) / 100 )


#Rename 2014 census tracts

pubhous.2014.2 <- pubhous.2014.1[ , c("Program.label","Name", "Subsidized.units.available", "year") ]

pubhous.2014.3 <- filter( pubhous.2014.2 , Name %in% grep( "Onondaga", pubhous.2014.2$Name, value = T ) )

pubhous.2014.4 <- mutate( pubhous.2014.3, tract = as.numeric( str_sub(pubhous.2014.3$Name , -5) ) / 100 )


#Rename 2015 census tracts

pubhous.2015.2 <- pubhous.2015.1[ , c("Program.label","Name", "Subsidized.units.available", "year") ]

pubhous.2015.3 <- filter( pubhous.2015.2 , Name %in% grep( "Onondaga", pubhous.2015.2$Name, value = T ) )

pubhous.2015.4 <- mutate( pubhous.2015.3, tract = as.numeric( str_sub(pubhous.2015.3$Name , -5) ) / 100 )
```

## 4. Combine years into one data set


```r
#Combine years 2010 to 2015
pubhous.1 <- rbind(pubhous.2010.4, pubhous.2011.4, pubhous.2012.4, pubhous.2013.4, pubhous.2014.4, pubhous.2015.4)
```

## 3. Drop unnecessary rows and columns


```r
#Filter to drop all programs besides public housing
pubhous.2 <- filter(pubhous.1 , Program.label == "Public Housing")

#Filter to drop all tracts outside of Syracuse
pubhous.3 <- filter(pubhous.2 , as.numeric(tract) < 62)

#Drop all rows with NA units available
pubhous.4 <- pubhous.3[!is.na(pubhous.3$Subsidized.units.available), ]

#For consistancy, change the tract id to the full FIPs code. First, grab the full codes from the shapefiles
ids <- as.data.frame(syr[, c("GEOID10", "NAME10")])

#Add full code to public hosuing data
pubhous.5 <- merge( pubhous.4 , ids, by.x = "tract", by.y = "NAME10")

#Drop all columns except for year, tract
public.housing <- pubhous.5[ , c("year","GEOID10", "Subsidized.units.available") ]

#Rename columns for consistancy 
colnames(public.housing)[1] <- "YEAR"

colnames(public.housing)[2] <- "TRACT"
```

## 4. Add data frame to Processed Data folder in GitHub


```r
setwd( "../../DATA/AGGREGATED_DATA" )
write.csv( public.housing, "publichousing_aggregated.csv", row.names=F )
```

