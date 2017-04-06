# Load the Necessary Data Packages




# Download the Zip File
## Set your working directory
setwd("~/Graduate School/PAI 690 Independent Study_DDM II/Group Project/NPO Variables")

## Download Source Data:
## DropBox .zip location     set dl=1 to download
download.file( "https://www.dropbox.com/s/w68lvzr2dgjmame/BMF_Aug_2016.zip?dl=1", "BMF_Aug_2016.zip" )
unzip( "BMF_Aug_2016.zip" )
file.remove( "BMF_Aug_2016.zip" )

## Load Source Data:
setwd("~data/extracts")
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




