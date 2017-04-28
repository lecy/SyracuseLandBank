
setwd( "C:/Users/jdlecy/Dropbox/02 - CLASSES/02 - MASTERS/09 - DDM II/02 - IND STUDY/03 - SYR Data/Neighborhood Shapefiles" )

library( maptools )
library( sp )
library( rgdal )
library( geojsonio )


# Download shapefiles from Community Geography Site

download.file("http://communitygeography.org/wp-content/uploads/2013/09/2015socpa_neighborhoods_utm.zip", "syr_neighborhoods.zip" )

unzip( "syr_neighborhoods.zip" )

file.remove( "syr_neighborhoods.zip" )




syr <- readOGR( dsn=".", layer="2015socpa_neighborhoods_utm" )

plot( syr )

text( getSpPPolygonsLabptSlots(syr), labels=syr$NAME, cex=0.4 )



# GET AND CHANGE PROJECTION to WGS84
# http://gis.stackexchange.com/questions/31743/projecting-sp-objects-in-r

is.projected( syr )
proj4string( syr )

syr <- spTransform( syr, CRS("+proj=longlat +datum=WGS84") )
proj4string( syr )


# WRITE TO GEOJSON FORMAT

geojson_write( syr, geometry="polygon", file="syr_neighborhoods.geojson" )





### READ IN FROM GEOJSON FORMAT

library( geojsonio )
library( sp )
library( rgdal )

url <- "https://raw.githubusercontent.com/lecy/SyracuseLandBank/master/SHAPEFILES/syr_neighborhoods.geojson"
syr <- geojson_read( url, method="local", what="sp" )

plot( syr, border="light gray" )
text( getSpPPolygonsLabptSlots(syr), labels=syr$NAME, cex=0.4 )

