# Load the Necessary Data Packages
library( ggmap )



# Download the Zip File
## Set your working directory
setwd("~/Graduate School/PAI 690 Independent Study_DDM II/Group Project/NPO Variables")

## Download Source Data:
## DropBox .zip location     set dl=1 to download
download.file( "https://www.dropbox.com/s/w68lvzr2dgjmame/BMF_Aug_2016.zip?dl=1", "BMF_Aug_2016.zip" )
unzip( "BMF_Aug_2016.zip" )
file.remove( "BMF_Aug_2016.zip" )

## Load Source Data:
setwd("~/Graduate School/PAI 690 Independent Study_DDM II/Group Project/NPO Variables/data/extracts")
dat <- read.csv( "N2s8d2m.csv" )
# Data Dictionary for this data is: http://nccsweb.urban.org/PubApps/showDD.php#Business%20Master%20Files



# Filter Values:

## Load Filter Values: Zip Codes
zipc <- read.csv( "https://raw.githubusercontent.com/christine-brown/SyracuseLandBank/master/NPO%20Data/Zip%20Codes.csv", 
                  header = FALSE,
                  fileEncoding="UTF-8-BOM" )
names(zipc) <- "zipcode"
zipc <- zipc$zipcode

## Apply Filter Values: Zip Codes
### Returns a dataset of rows that have a value for zip5 within the zipc vector
dat <- dat[ dat$zip5 %in% zipc, ]
rm( zipc )

## Create Filter Values: "Syracuse"
cityNames <- as.character( unique( dat$CITY ) )
syrNames <- grep( "CUSE", cityNames, value = T )
rm( cityNames )

## Apply Filter Values: Variations of "Syracuse"
### Returns a dataset of rows that have a value for CITY within the syrNames vector
dat <- dat[ dat$CITY %in% syrNames, ]
rm( syrNames )


# Geocode the Addresses

## Compile home address info and clean the strings
address <- dat[ , c("ADDRESS","CITY", "STATE", "ZIP") ]
names( address ) <- c("a", "c", "s", "z" )
address$a <- gsub( ",", "", address$a )
address$a <- gsub( "\\.", "", address$a )

## Combine the strings in this order: Address, City, State, Zip. Separate with comma and space
addresses <- paste( address$a, address$c, address$s, address$z, sep=", " )
rm( address )

## Translate the address strings to latitude and longitude coordinates
lat.long <- geocode( addresses )
rm( addresses )
### Cool info on batching here: http://www.shanelynn.ie/massive-geocoding-with-r-and-google-maps/

## Bind the geocoded addresses to the dataset
dat <- cbind( dat, lat.long )



# Generate a .CSV file

setwd( "C:/Users/franc/Documents/GitHub/DDM-II/SyracuseLandBank/NPO Data" )
write.csv( dat, "NPO_Data.csv", row.names=F )



