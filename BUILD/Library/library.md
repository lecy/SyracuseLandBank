# Libraries



### Data Acquisition and Preparation
This section of the project draws on the parcel spatial data set. The data set includes a land use variable that has a category for "Libraries." Once acquired, it must be cleaned and aggregated in order to be included in the analysis of all variables collected for this project. 

```r
#Load Packages
library( dplyr )
library( geojsonio )
library( ggmap )
library( maps )
library( maptools )
library( raster )
library( rgdal )
library( rgeos )
library( sp )

#Load Shapefiles
syr_tracts <- geojson_read( "../../SHAPEFILES/SYRCensusTracts.geojson" , method = "local" , what = "sp" )
syr_tracts <- spTransform( syr_tracts , CRS( "+proj=longlat +datum=WGS84" ) )
syr_parcels <- geojson_read( "../../SHAPEFILES/syr_parcels.geojson" , method = "local" , what = "sp" )
syr_parcels <- spTransform( syr_parcels , CRS( "+proj=longlat +datum=WGS84" ) )

#Create a variable for the FIPS code
syr_parcels$TRACT <- as.numeric( as.character( syr_parcels$CensusTrac ) )
syr_parcels <- syr_parcels[ !is.na( syr_parcels$TRACT ), ]
syr_parcels$TRACT <- as.character( syr_parcels$TRACT*100 )
flag <- nchar( syr_parcels$TRACT ) == 3
syr_parcels$TRACT[ flag ] <- paste0( "0" , syr_parcels$TRACT[ flag ] )
syr_parcels$TRACT <- paste( "3606700" , syr_parcels$TRACT , sep = "" )

#Identify library parcels and add coordinates
libraries_sp <- syr_parcels[ syr_parcels$LUCODE == 611 , ]
libraries_centroid <- gCentroid( libraries_sp , byid = TRUE )
libraries <- cbind( as.data.frame( libraries_sp ), as.data.frame( libraries_centroid ) )
libraries <- libraries[ , c( "TRACT" , "x" , "y" ) ]
names( libraries ) <- c( "TRACT" , "LON" , "LAT" )

#Export processed data to a CSV file
write.csv( libraries , file = "../../DATA/PROCESSED_DATA/libraries_processed.csv" , row.names = F )

#Aggregate the data at the tract level
libraries_tract <- as.data.frame( table( libraries$TRACT ) )
libraries_tract$YEAR <- 2017
names( libraries_tract ) <- c( "TRACT" , "LIBRARY" , "YEAR" )

#Export aggregated date to a CSV file
write.csv( libraries_tract , file = "../../DATA/AGGREGATED_DATA/libraries_aggregated.csv" , row.names = F )
```

### Data Visualization
The visualization below shows the location of the Syracuse libraries represented by red dots.  The interstates are included for spatial context.

```r
#Load road data
roads <- geojson_read( "../../SHAPEFILES/roads.geojson" , method = "local" , what = "sp" )
roads <- spTransform( roads , CRS( "+proj=longlat +datum=WGS84" ) )

#Subset the interstates
interstate <- roads[ roads$RTTYP == "I" , ]

#Clip the interstates to the Syracuse border
syr_outline <- gBuffer( syr_tracts , width = .000 , byid = F )
interstate_clipped <- gIntersection( syr_outline , interstate , byid = TRUE , drop_lower_td = TRUE)

#Plot the visualization
par( mar = c( 0 , 0 , 1 , 0 ) )
plot( syr_tracts , main = "Libraries" )
plot( interstate_clipped , col = "#dd7804" , lwd = 1.75 , add = T )
points( libraries_centroid , pch = 19 , col = "#93071d" , cex = 1.5 )
map.scale( x = -76.22 , y = 42.994 , metric = F , ratio = F , relwidth = 0.1 , cex = 1 )
```

![](library_files/figure-html/unnamed-chunk-2-1.png)<!-- -->
