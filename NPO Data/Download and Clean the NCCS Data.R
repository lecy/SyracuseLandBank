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
str(dat)

# Load Filter Values:

## Filter Values: Zip Codes
setwd("~data/extracts")
zipc <- read.csv( "Zip Codes.csv" )
names(zipc) <- "zipcode"
zipc <- zipc$zipcode
