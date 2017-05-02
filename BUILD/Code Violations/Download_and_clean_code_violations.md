# Code Violations



## Code Violations Data

Patterns of code violations across neighborhoods can be used to understand home values in those neighborhoods and how home values might change in specific areas. Many violations directly relate to the visual appeal of a home and by extension the aesthetics of its surrounding area. Others may be seen as a proxy for upkeep and homeowner investment. 

To examine the effects of these violations will use data obtained from the city that covers 2007 to 2016. The data from before 2012 and after 2015 is incomplete so we will work with only data from 2012 to 2015. The main aim of this piece of code is to wrangle the code violations data and join it to a shapefile for the city of Syracuse in order to visualize where code violations are taking place and to examine links between violations and other characteristics of these geographic locations.  

### 1. Load Data

This step loads the Syracuse shapefiles and the data on code violations provided by the city of Syracuse. We'll use code violation data from 2012-2015.    


```r
#Load shapefiles from Github
syr <- geojson_read("https://raw.githubusercontent.com/lecy/SyracuseLandBank/master/SHAPEFILES/SYRCensusTracts.geojson", method="local", what="sp" )
```



```r
#Load data on code violations from Githib
violations.dat <- read.csv("https://raw.githubusercontent.com/lecy/SyracuseLandBank/master/DATA/RAW_DATA/codeviolations.csv", header = TRUE)

#Drop all information besides complaint type, violation date, latitude, and longitude
violations.2 <- violations.dat[ , c("Complaint.Type","Violation.Date", "Address", "lat","lon") ]

#Transform date variable into workable format with seperate variables year
violations.2$Violation.Date <- as.Date( violations.2$Violation.Date, format="%m/%d/%Y" )

violations.3 <- mutate( violations.2, year = format(violations.2$Violation.Date, format = "%Y"))

#Drop data from before 2012 and after 2015 (before that time there were less than 60 violatiions logged in each year, after there were around 500. Between 2012 and 2015 each year has around 5,000 violations so we can assume the other data is incomplete)
violations.4 <- filter(violations.3, year > "2011" & year < "2016")

#Drop any rows with an NA for latitude or longitude.
violations.coordinates <- violations.4[!is.na(violations.4$lon) & !is.na(violations.4$lat), ]

#There are repeated entries in the data, keep only one copy of each of these
violations.coordinates.2 <- unique(violations.coordinates)
```

### 2. Wrangle Data

This step will join the violation data and the Syracuse shapefile. We will then aggregate the data up by census tract and year to create a data frame that reports census tract, year, and total number of code violations.


```r
###Spatial join of violation data and shapefile

#Pull out latitude and longitude from code violations data
violations.coordinates.3 <- violations.coordinates.2[ c("lon", "lat") ]

#Use latitude and longitude to turn data into Spatial points
violations.spatial <- SpatialPoints(violations.coordinates.3,
                     proj4string=CRS("+proj=longlat +datum=WGS84"))

#Project shapefiles so that CRS matches Spatial points
syr.2 <- spTransform(syr, CRS("+proj=longlat +datum=WGS84"))

#Use these spatial points to link violatons to the Syracuse city shapefile by geographic location
violations.over <- over(violations.spatial , syr.2)

#Combine this linking with the orginal code violations data. We now have a data frame with rows that have code violation information and information about the tract that the violation is located within
violations.shape <- cbind(violations.coordinates.2, violations.over)
```



```r
###Aggregate up by census tract and year

#Create a data frame that lists the number of code violations in each census tract by year
violations <- count(violations.shape, GEOID10 , year)

#Rename the frequency column
colnames(violations)[3] <- "Code.Violations"

#Rename the year and tract column for consistancy
colnames(violations)[1] <- "TRACT"

colnames(violations)[2] <- "YEAR"

violations 
```

<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":["TRACT"],"name":[1],"type":["fctr"],"align":["left"]},{"label":["YEAR"],"name":[2],"type":["chr"],"align":["left"]},{"label":["Code.Violations"],"name":[3],"type":["int"],"align":["right"]}],"data":[{"1":"36067000100","2":"2012","3":"11"},{"1":"36067000100","2":"2013","3":"8"},{"1":"36067000100","2":"2014","3":"7"},{"1":"36067000100","2":"2015","3":"7"},{"1":"36067000200","2":"2012","3":"234"},{"1":"36067000200","2":"2013","3":"166"},{"1":"36067000200","2":"2014","3":"187"},{"1":"36067000200","2":"2015","3":"137"},{"1":"36067000300","2":"2012","3":"23"},{"1":"36067000300","2":"2013","3":"21"},{"1":"36067000300","2":"2014","3":"18"},{"1":"36067000300","2":"2015","3":"36"},{"1":"36067000400","2":"2012","3":"61"},{"1":"36067000400","2":"2013","3":"60"},{"1":"36067000400","2":"2014","3":"64"},{"1":"36067000400","2":"2015","3":"58"},{"1":"36067000501","2":"2012","3":"178"},{"1":"36067000501","2":"2013","3":"105"},{"1":"36067000501","2":"2014","3":"132"},{"1":"36067000501","2":"2015","3":"99"},{"1":"36067000600","2":"2012","3":"274"},{"1":"36067000600","2":"2013","3":"136"},{"1":"36067000600","2":"2014","3":"159"},{"1":"36067000600","2":"2015","3":"95"},{"1":"36067000700","2":"2012","3":"111"},{"1":"36067000700","2":"2013","3":"88"},{"1":"36067000700","2":"2014","3":"83"},{"1":"36067000700","2":"2015","3":"50"},{"1":"36067000800","2":"2012","3":"91"},{"1":"36067000800","2":"2013","3":"112"},{"1":"36067000800","2":"2014","3":"102"},{"1":"36067000800","2":"2015","3":"73"},{"1":"36067000900","2":"2012","3":"36"},{"1":"36067000900","2":"2013","3":"40"},{"1":"36067000900","2":"2014","3":"27"},{"1":"36067000900","2":"2015","3":"34"},{"1":"36067001000","2":"2012","3":"40"},{"1":"36067001000","2":"2013","3":"57"},{"1":"36067001000","2":"2014","3":"48"},{"1":"36067001000","2":"2015","3":"82"},{"1":"36067001400","2":"2012","3":"183"},{"1":"36067001400","2":"2013","3":"149"},{"1":"36067001400","2":"2014","3":"188"},{"1":"36067001400","2":"2015","3":"94"},{"1":"36067001500","2":"2012","3":"134"},{"1":"36067001500","2":"2013","3":"133"},{"1":"36067001500","2":"2014","3":"136"},{"1":"36067001500","2":"2015","3":"107"},{"1":"36067001600","2":"2012","3":"42"},{"1":"36067001600","2":"2013","3":"26"},{"1":"36067001600","2":"2014","3":"50"},{"1":"36067001600","2":"2015","3":"16"},{"1":"36067001701","2":"2012","3":"85"},{"1":"36067001701","2":"2013","3":"86"},{"1":"36067001701","2":"2014","3":"82"},{"1":"36067001701","2":"2015","3":"76"},{"1":"36067001702","2":"2012","3":"90"},{"1":"36067001702","2":"2013","3":"74"},{"1":"36067001702","2":"2014","3":"77"},{"1":"36067001702","2":"2015","3":"70"},{"1":"36067001800","2":"2012","3":"34"},{"1":"36067001800","2":"2013","3":"24"},{"1":"36067001800","2":"2014","3":"21"},{"1":"36067001800","2":"2015","3":"42"},{"1":"36067001900","2":"2012","3":"46"},{"1":"36067001900","2":"2013","3":"49"},{"1":"36067001900","2":"2014","3":"51"},{"1":"36067001900","2":"2015","3":"47"},{"1":"36067002000","2":"2012","3":"62"},{"1":"36067002000","2":"2013","3":"70"},{"1":"36067002000","2":"2014","3":"88"},{"1":"36067002000","2":"2015","3":"77"},{"1":"36067002101","2":"2012","3":"150"},{"1":"36067002101","2":"2013","3":"155"},{"1":"36067002101","2":"2014","3":"182"},{"1":"36067002101","2":"2015","3":"131"},{"1":"36067002300","2":"2012","3":"83"},{"1":"36067002300","2":"2013","3":"54"},{"1":"36067002300","2":"2014","3":"58"},{"1":"36067002300","2":"2015","3":"47"},{"1":"36067002400","2":"2012","3":"85"},{"1":"36067002400","2":"2013","3":"64"},{"1":"36067002400","2":"2014","3":"87"},{"1":"36067002400","2":"2015","3":"68"},{"1":"36067002700","2":"2012","3":"23"},{"1":"36067002700","2":"2013","3":"33"},{"1":"36067002700","2":"2014","3":"43"},{"1":"36067002700","2":"2015","3":"38"},{"1":"36067002901","2":"2012","3":"53"},{"1":"36067002901","2":"2013","3":"56"},{"1":"36067002901","2":"2014","3":"58"},{"1":"36067002901","2":"2015","3":"51"},{"1":"36067003000","2":"2012","3":"39"},{"1":"36067003000","2":"2013","3":"36"},{"1":"36067003000","2":"2014","3":"54"},{"1":"36067003000","2":"2015","3":"35"},{"1":"36067003200","2":"2012","3":"58"},{"1":"36067003200","2":"2013","3":"59"},{"1":"36067003200","2":"2014","3":"104"},{"1":"36067003200","2":"2015","3":"67"},{"1":"36067003400","2":"2012","3":"28"},{"1":"36067003400","2":"2013","3":"30"},{"1":"36067003400","2":"2014","3":"27"},{"1":"36067003400","2":"2015","3":"34"},{"1":"36067003500","2":"2012","3":"73"},{"1":"36067003500","2":"2013","3":"47"},{"1":"36067003500","2":"2014","3":"106"},{"1":"36067003500","2":"2015","3":"80"},{"1":"36067003601","2":"2012","3":"65"},{"1":"36067003601","2":"2013","3":"72"},{"1":"36067003601","2":"2014","3":"75"},{"1":"36067003601","2":"2015","3":"78"},{"1":"36067003602","2":"2012","3":"29"},{"1":"36067003602","2":"2013","3":"56"},{"1":"36067003602","2":"2014","3":"61"},{"1":"36067003602","2":"2015","3":"34"},{"1":"36067003800","2":"2012","3":"168"},{"1":"36067003800","2":"2013","3":"91"},{"1":"36067003800","2":"2014","3":"127"},{"1":"36067003800","2":"2015","3":"111"},{"1":"36067003900","2":"2012","3":"291"},{"1":"36067003900","2":"2013","3":"242"},{"1":"36067003900","2":"2014","3":"296"},{"1":"36067003900","2":"2015","3":"198"},{"1":"36067004000","2":"2012","3":"101"},{"1":"36067004000","2":"2013","3":"66"},{"1":"36067004000","2":"2014","3":"90"},{"1":"36067004000","2":"2015","3":"59"},{"1":"36067004200","2":"2012","3":"11"},{"1":"36067004200","2":"2013","3":"13"},{"1":"36067004200","2":"2014","3":"18"},{"1":"36067004200","2":"2015","3":"12"},{"1":"36067004301","2":"2012","3":"2"},{"1":"36067004301","2":"2014","3":"5"},{"1":"36067004301","2":"2015","3":"1"},{"1":"36067004302","2":"2012","3":"9"},{"1":"36067004302","2":"2013","3":"11"},{"1":"36067004302","2":"2014","3":"28"},{"1":"36067004302","2":"2015","3":"15"},{"1":"36067004400","2":"2012","3":"71"},{"1":"36067004400","2":"2013","3":"43"},{"1":"36067004400","2":"2014","3":"58"},{"1":"36067004400","2":"2015","3":"52"},{"1":"36067004500","2":"2012","3":"103"},{"1":"36067004500","2":"2013","3":"94"},{"1":"36067004500","2":"2014","3":"114"},{"1":"36067004500","2":"2015","3":"84"},{"1":"36067004600","2":"2012","3":"30"},{"1":"36067004600","2":"2013","3":"27"},{"1":"36067004600","2":"2014","3":"34"},{"1":"36067004600","2":"2015","3":"32"},{"1":"36067004800","2":"2012","3":"17"},{"1":"36067004800","2":"2013","3":"22"},{"1":"36067004800","2":"2014","3":"19"},{"1":"36067004800","2":"2015","3":"25"},{"1":"36067004900","2":"2012","3":"68"},{"1":"36067004900","2":"2013","3":"51"},{"1":"36067004900","2":"2014","3":"49"},{"1":"36067004900","2":"2015","3":"45"},{"1":"36067005000","2":"2012","3":"52"},{"1":"36067005000","2":"2013","3":"29"},{"1":"36067005000","2":"2014","3":"41"},{"1":"36067005000","2":"2015","3":"38"},{"1":"36067005100","2":"2012","3":"172"},{"1":"36067005100","2":"2013","3":"148"},{"1":"36067005100","2":"2014","3":"174"},{"1":"36067005100","2":"2015","3":"116"},{"1":"36067005200","2":"2012","3":"154"},{"1":"36067005200","2":"2013","3":"115"},{"1":"36067005200","2":"2014","3":"152"},{"1":"36067005200","2":"2015","3":"109"},{"1":"36067005300","2":"2012","3":"66"},{"1":"36067005300","2":"2013","3":"68"},{"1":"36067005300","2":"2014","3":"70"},{"1":"36067005300","2":"2015","3":"70"},{"1":"36067005400","2":"2012","3":"161"},{"1":"36067005400","2":"2013","3":"159"},{"1":"36067005400","2":"2014","3":"209"},{"1":"36067005400","2":"2015","3":"161"},{"1":"36067005500","2":"2012","3":"45"},{"1":"36067005500","2":"2013","3":"49"},{"1":"36067005500","2":"2014","3":"56"},{"1":"36067005500","2":"2015","3":"61"},{"1":"36067005601","2":"2012","3":"12"},{"1":"36067005601","2":"2013","3":"10"},{"1":"36067005601","2":"2014","3":"13"},{"1":"36067005601","2":"2015","3":"23"},{"1":"36067005602","2":"2012","3":"1"},{"1":"36067005602","2":"2013","3":"1"},{"1":"36067005602","2":"2015","3":"2"},{"1":"36067005700","2":"2012","3":"78"},{"1":"36067005700","2":"2013","3":"76"},{"1":"36067005700","2":"2014","3":"90"},{"1":"36067005700","2":"2015","3":"79"},{"1":"36067005800","2":"2012","3":"200"},{"1":"36067005800","2":"2013","3":"155"},{"1":"36067005800","2":"2014","3":"187"},{"1":"36067005800","2":"2015","3":"157"},{"1":"36067005900","2":"2012","3":"134"},{"1":"36067005900","2":"2013","3":"102"},{"1":"36067005900","2":"2014","3":"148"},{"1":"36067005900","2":"2015","3":"112"},{"1":"36067006000","2":"2012","3":"76"},{"1":"36067006000","2":"2013","3":"61"},{"1":"36067006000","2":"2014","3":"78"},{"1":"36067006000","2":"2015","3":"71"},{"1":"36067006101","2":"2012","3":"105"},{"1":"36067006101","2":"2013","3":"101"},{"1":"36067006101","2":"2014","3":"147"},{"1":"36067006101","2":"2015","3":"126"},{"1":"36067006102","2":"2012","3":"4"},{"1":"36067006102","2":"2013","3":"11"},{"1":"36067006102","2":"2014","3":"5"},{"1":"36067006102","2":"2015","3":"8"},{"1":"36067006103","2":"2012","3":"27"},{"1":"36067006103","2":"2013","3":"34"},{"1":"36067006103","2":"2014","3":"31"},{"1":"36067006103","2":"2015","3":"39"},{"1":"NA","2":"2012","3":"596"},{"1":"NA","2":"2013","3":"542"},{"1":"NA","2":"2014","3":"670"},{"1":"NA","2":"2015","3":"599"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>

### 3. Add data frame to GitHub

Add new data frame to Processed Data folder on Github.


```r
setwd( "../../DATA/AGGREGATED_DATA" )
write.csv( violations, "codeviolations_aggregated.csv", row.names=F )
```

### 4. Analysis

First, create a map of Syracuse with census tracts colored by the frequency of code violations occurring within them in 2015. Red tracts have the highest occurrences of violations within them, blue tracts have the least, grey tracts fall in between these extremes. Then, Create a gif that shows frequency of code violations from 2012-2015.


```r
###Create a map of code violation frequency by census tract in 2015

#Create a color palette to display frequency of code violations on a map: red will represent high values, blue will represnt low
color.function <- colorRampPalette( c("steel blue","light gray", "firebrick4" ) )

#There will be 5 colors between blue and red to demonstrate increasing intensity
col.ramp <- color.function( 5 )

#Group number of code violations into 5 levels of intensity. 'color.vector' will display the code for the color of the group that each census tract now belongs to 
color.vector <- cut( rank(violations$Code.Violations), breaks=5 , labels=col.ramp )

#Change class from factor to character
color.vector <- as.character( color.vector )

#The order of these entries has been perserved, so a simple cbind will match each row with the color code corresponds to it (based on the number of code violations in that row)
violations.colors <- cbind(as.data.frame(violations), color.vector)

#Drop data from unknown tracts to facilitate merge
violations.colors.2 <- violations.colors[!is.na(violations.colors$TRACT), ]

#Choose a specific year
violations.colors.year <- filter(violations.colors.2, YEAR == "2015" )

#Merge data on fequency of code violations (that includes a color designation) with the syracuse shapefile 
syr.violations <- merge(syr, violations.colors.year, by.x="GEOID10", by.y="TRACT")

#create a color vector that matches the order of the tracts listed in this newly merged data frame
color.vector.2 <- as.character(syr.violations$color.vector)

#Plot the map
plot(syr.violations , col= color.vector.2)

#Add a title and legend to the map
title( main="Frequency of Code Violations 2015")

#Creates a vector that lists the break points used to create the quantiles
breaks.violations <-classIntervals(violations$Code.Violations, n=5, style="quantile")

#Rounds break points
breaks.violations$brks <- round(breaks.violations$brks, 0)

#Add a legend
legend( "bottomright", bg="white",
        pch=19, pt.cex=1.5, cex=0.7,
        legend=leglabs(breaks.violations$brks), 
        col=col.ramp, 
        box.col="white",
        title="Frequency of Code Violations" 
)
```

![](Download_and_clean_code_violations_files/figure-html/unnamed-chunk-6-1.png)<!-- -->


```r
###Create gif

saveGIF({


{
#Map of 2012 violations (code similar to code used in the inital Analysis section)
violations.colors.year.2012 <- filter(violations.colors.2, YEAR == "2012" )
syr.violations.2012 <- merge(syr, violations.colors.year.2012, by.x="GEOID10", by.y="TRACT")
color.vector.2012.2 <- as.character(syr.violations.2012$color.vector)
plot(syr.violations.2012 , col= color.vector.2012.2)
title( main="Frequency of Code Violations 2012")

breaks.violations <-classIntervals(violations$Code.Violations, n=5, style="quantile")
breaks.violations$brks <- round(breaks.violations$brks, 0)
legend( "bottomright", bg="white",
        pch=19, pt.cex=1.5, cex=0.7,
        legend=leglabs(breaks.violations$brks), 
        col=col.ramp, 
        box.col="white",
        title="Frequency of Code Violations" 
)

#Map of 2013
violations.colors.year.2013 <- filter(violations.colors.2, YEAR == "2013" )
syr.violations.2013 <- merge(syr, violations.colors.year.2013, by.x="GEOID10", by.y="TRACT")
color.vector.2013.2 <- as.character(syr.violations.2013$color.vector)
plot(syr.violations.2013 , col= color.vector.2013.2)
title( main="Frequency of Code Violations 2013")
legend( "bottomright", bg="white",
        pch=19, pt.cex=1.5, cex=0.7,
        legend=leglabs(breaks.violations$brks), 
        col=col.ramp, 
        box.col="white",
        title="Frequency of Code Violations" 
)

#Map of 2014
violations.colors.year.2014 <- filter(violations.colors.2, YEAR == "2014" )
syr.violations.2014 <- merge(syr, violations.colors.year.2014, by.x="GEOID10", by.y="TRACT")
color.vector.2014.2 <- as.character(syr.violations.2014$color.vector)
plot(syr.violations.2014 , col= color.vector.2014.2)
title( main="Frequency of Code Violations 2014")
legend( "bottomright", bg="white",
        pch=19, pt.cex=1.5, cex=0.7,
        legend=leglabs(breaks.violations$brks), 
        col=col.ramp, 
        box.col="white",
        title="Frequency of Code Violations" 
)

#Map of 2015
violations.colors.year.2015 <- filter(violations.colors.2, YEAR == "2015" )
syr.violations.2015 <- merge(syr, violations.colors.year.2015, by.x="GEOID10", by.y="TRACT")
color.vector.2015.2 <- as.character(syr.violations.2015$color.vector)
plot(syr.violations.2015 , col= color.vector.2015.2)
title( main="Frequency of Code Violations 2015")
legend( "bottomright", bg="white",
        pch=19, pt.cex=1.5, cex=0.7,
        legend=leglabs(breaks.violations$brks), 
        col=col.ramp, 
        box.col="white",
        title="Frequency of Code Violations" 
)

  
  }


}, 

movie.name = "code_violations.gif",   # name of your gif
interval = 1.5,                  # controls the animation speed
ani.width = 800,                 # size of the gif in pixels
ani.height = 800 )               # size of the git in pixels
```

```
## [1] TRUE
```
![]( gifs/code_violations.gif )
