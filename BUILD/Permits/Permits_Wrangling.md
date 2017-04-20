Description of data Wrangling for Permits Dataset
================

``` r
#LOADING DAT 
dat <- read.csv("https://raw.githubusercontent.com/christine-brown/SyracuseLandBank/master/DATA/RAW_DATA/Permits_raw.csv", stringsAsFactors = F)

#Formatting the dataframe

#making valuation and fee variables to be numeric
x <- dat$Valuation
x <- gsub("$", "", x, fixed = T)
x <- gsub(",", "", x, fixed = T)
x <- as.numeric(x)
dat$Valuation <- x

x <- dat$Fee.Amount
x <- gsub("$", "", x, fixed = T)
x <- gsub(",", "", x, fixed = T)
x <- as.numeric(x)
dat$Fee.Amount <- x


#Creating a variable for the year
x <- dat$Issued
x <- gsub( "\\d{2}/\\d{2}/", "", x) #deleting everything except the year. btw: "\\d{2}" means any two digits
x <- as.numeric(x)
dat$Year <- x
dat <- dat[,c(1:6,9,7,8)]
```

Introducing the Dataset
=======================

The Permits Dataset was provided by the City of Syracuse. It contains information for 21,556 permits from 2012 - 2016. For each permit the Dataset inclueds variables like:

-   Type of Permit
-   Applicant name (can be either a person or a company)
-   Location
-   SBL
-   Date Issued
-   Valuation (cost of the activity the applicant is requesting permit for)
-   Fee Amount (the monies for the City)

We used the types of permits to construct 4 categories that we will aggregate as variables at the Census Tract level.

There are 32 types of permits:

    ##  [1] "Site Work"                 "Electric"                 
    ##  [3] "Sprinkler"                 "Sign"                     
    ##  [5] "HVAC/Mechanical"           "Fire Alarm"               
    ##  [7] "Elevator"                  "Antenna / Dish"           
    ##  [9] "Demolition"                "Com. Reno/Rem/Chg Occ"    
    ## [11] "Curb Cut"                  "Road Cut"                 
    ## [13] "Com. New Building"         "Electric (Meter Set)"     
    ## [15] "Res. Remodel/Chg Occ"      "Misc.(deck, fence,ramp)"  
    ## [17] "Sidewalk Replace"          "Security Alarm"           
    ## [19] "Tank"                      "Sidewalk Cafe"            
    ## [21] "Pool / Hot Tub"            "Liability Waiver"         
    ## [23] "Public Assembly"           "Loading Zone (Business)"  
    ## [25] "Encroach (Major)"          "Encroach (Deminimus)"     
    ## [27] "Footing / Foundation"      "Encroachment (Converted)" 
    ## [29] "Res. New 1-2 Family"       "Block Party (Business)"   
    ## [31] "Parking Meter Rental"      "Block Party (Residential)"

Categories created
==================

We have placed this types of Permits into 4 categories to analyze them separately. They are:

-   Residential Properties, 2 Types of permits in this category: "Res. Remodel/Chg Occ", "Res. New 1-2 Family"

-   Commercial Properties, 2 Types of permits in this category: "Com. New Building", "Com. Reno/Rem/Chg Occ"

-   Demolitions, 1 Type of permit in this category: Demolitions

-   Installations and Repairs (to public space, res and com), 9 Types of permits in this category: Electric, Elevator, Fire Alarm, HVAC/Mechanical, Misc.(deck, fence,ramp), Pool / Hot Tub, Security Alarm, Sprinkler, Tank.

Finally, 18 permit types have been ignored.

Description of Data wrangling
=============================

This process produced two datasets:

-   Permits\_Processed.csv
-   Permits\_aggregated.csv

Before geocoding and due to the size of the dataset, we will make subsetsand then proceed to batch geocode them.

``` r
#BEFORE GEOCODING, CREATING SUBSETS

#dividing by categories

#Found
x <- as.character(dat$Type)

df.F <- x == "Footing / Foundation"
df.F <- dat[df.F, ]

#Res
df.R <- x== "Res. Remodel/Chg Occ" | x == "Res. New 1-2 Family" 
df.R <- dat[df.R,]

#Com
df.C <- x== "Com. New Building" | x=="Com. Reno/Rem/Chg Occ"
df.C <- dat[df.C,]

#Dem
df.D <- x=="Demolition"
df.D <- dat[df.D,]

#Ins
df.I <- x=="Antenna / Dish" | x=="Electric" | x=="Electric (Meter Set)" | x=="Elevator" | x=="Fire Alarm" | x=="HVAC/Mechanical" | x=="Misc.(deck, fence,ramp)" | x=="Pool / Hot Tub" | x=="Security Alarm" | x=="Sprinkler" | x=="Tank"
df.I <- dat[df.I,]


#Ign - this is a subset of all the ignored permits
df.Ign <- x=="Block Party (Business)" | x=="Block Party (Residential)" | x=="Curb Cut" | x=="Encroach (Deminimus)" | x=="Encroach (Major)"  | x=="Encroachment (Converted)" | x=="Liability Waiver" | x=="Loading Zone (Business)" | x=="Parking Meter Rental" | x=="Public Assembly" | x=="Road Cut" | x=="Sidewalk Cafe" | x=="Sidewalk Replace" | x=="Sign" | x=="Site Work"
df.Ign <- dat[df.Ign,]  

#NOTE: In the data wrangling process 3 permit types were reassigned from a geocoded category to the Ignored category. These were:
#Footing foundations (from Found)
#Electric(meter set) and Antenna / Dish. (from Installation and repairs)
#this three ignored permit types were initially geocoded and therefore have tract id in the dataframe, but will not be used for aggregating the variables 

#save(df.Ign, file = "df.Ign.rda") #we save this subset separatelly
```

GEOCODING
---------

The following code chunks are not being evaluated because the process of geocoding is expensive

``` r
#GEOCODING the dataframes

#devtools::install_github("dkahle/ggmap") #Installing latest ggmap from the creators webpage. Need to download this in order for the code to work.

register_google(key = "YOUR KEY HERE", account_type = "premium", day_limit = 100000) #Need to put premium to fool the function. I did not have a premium, just a google API key that was authorized to bill me. NOTE: The key that I used was replaced by "YOUR KEY HERE"
ggmap_credentials() #this shows the credentials with which you are making the API request.
geocodeQueryCheck() #tells you how many geocode requests you have left.


#in what follows I geocoded 17,933 permits in approx 3h

#Found
df.F$Location2 <- paste(df.F$Location, ", Syracuse, New York", sep = "")
df.F <- mutate_geocode(df.F, Location2, source = "google")
save(df.F, file = "df.F.rda")

#Res
df.R$Location2 <- paste(df.R$Location, ", Syracuse, New York", sep = "")
df.R <- mutate_geocode(df.R, Location2, source = "google")
save(df.R, file = "df.R.rda")

#Com
df.C$Location2 <- paste(df.C$Location, ", Syracuse, New York", sep = "")
df.C <- mutate_geocode(df.C, Location2, source = "google")
save(df.C, file = "df.C.rda")

#Dem
df.D$Location2 <- paste(df.D$Location, ", Syracuse, New York", sep = "")
df.D <- mutate_geocode(df.D, Location2, source = "google")
save(df.D, file = "df.D.rda")

#Ins
df.I$Location2 <- paste(df.I$Location, ", Syracuse, New York")
df.I <- mutate_geocode(df.I, Location2, source = "google")
save(df.I, file = "df.I.rda")
```

After the first geocode, we had a considerable amount of NAs, mainly because of problems with the addresses. To fix this, we examined the addresses for the NAs and formatted them using the gsub function and regular expressions

Some Locations where given as intersections between Addresses or an extension between two addresses. This created problems in the geocoding so we dropped the second address. Other replacements were deleting information from the address.

``` r
#1. CLEANING ADDRESSES
#good source for regular expressions:
#https://rstudio-pubs-static.s3.amazonaws.com/74603_76cd14d5983f47408fdf0b323550b846.html
#https://www.rstudio.com/wp-content/uploads/2016/09/RegExCheatsheet.pdf

#FOUNDATIONS
load("df.F.rda") #loading the data frame 
x <- is.na(df.F$lat)
df.Fna <- df.F[x,]

miss <- df.Fna$Location2

miss <- gsub( " R \\d{1,} .*", "", miss)
miss <- gsub( " To .*", "", miss)
miss <- paste(miss, ", Syracuse, New York", sep = "")

df.Fna$Location2 <- miss

#RESIDENTIAL
load("df.R.rda") #loading the data frame 
x <- is.na(df.R$lat)
df.Rna <- df.R[x,]

miss <- df.Rna$Location2

miss <- gsub( " , Syracuse, New York", "", miss) # removing syra
miss <- gsub( "Skytop Housing ", "", miss)
miss <- gsub( "Rear", "", miss)
miss <- gsub( " To .*", "", miss)
miss <- gsub( " & .*", "", miss)
miss <- gsub( "Scott O'Grady ", "", miss)
miss <- gsub( " R \\d{1,} .*", "", miss)
miss <- paste(miss, ", Syracuse, New York",sep = "")

df.Rna$Location2 <- miss

#COMERCIAL
load("df.C.rda") #loading the data frame 
x <- is.na(df.C$lat)
df.Cna <- df.C[x,]

miss <- df.Cna$Location2

miss <- gsub( " , Syracuse, New York", "", miss) # removing syra
miss <- gsub( "\n", "", miss)

#if content replace whole address by name of building/location
miss <- gsub( ".*Flanagan Gym.*", "Flanagan Gym", miss)
miss <- gsub( ".*Falk College.*", "Falk College", miss)
miss <- gsub( ".*Hinds Hall.*", "Hinds Hall", miss)
miss <- gsub( ".*Graham Dining Hall.*", "Graham Dining Hall", miss)
miss <- gsub( ".*Bowne Hall.*", "Bowne Hall", miss)
miss <- gsub( ".*Flint Hall.*", "Flint Hall", miss)
miss <- gsub( ".*Physics Bldg.*", "Physics Building", miss)
miss <- gsub( ".*Hendricks Chapel.*", "Hendricks Chapel", miss)
miss <- gsub( ".*1320 Jamesville Ave.*", "1320 Jamesville Ave", miss)
miss <- gsub( ".*Carousel Center.*","Carousel Center Dr", miss)
miss <- gsub( ".*Hiawatha.*","306 Hiawatha Blvd W", miss)
miss <- gsub( ".*Destiny USA Dr.*","Destiny USA Dr", miss)
miss <- gsub( ".*Airport Boulevard.*", "Airport Boulevard", miss)
miss <- gsub( ".*Bird Library.*", "Bird Library", miss)

#Delete from string
miss <- gsub( "Rear", "", miss)
miss <- gsub( "Skytop Housing ", "", miss)
miss <- gsub( "Slocum Heights ", "", miss)
miss <- gsub( "Small Rd", "", miss)
miss <- gsub( "M17 Daycare ", "", miss)
miss <- gsub( "Lambreth Ln", "", miss)
miss <- gsub( "Farm Acre Rd", "", miss)
miss <- gsub( "Chinook Dr", "", miss)
miss <- gsub( "Life Science Center", "", miss)
miss <- gsub( "Playing Fields, Courts", "", miss)
miss <- gsub( "Newhouse 1 and 2", "", miss)
miss <- gsub( "Steam & Chilled Water", "", miss)
miss <- gsub( "Physical Plan & Commissary ", "", miss)
miss <- gsub( "Scott O'Grady ", "", miss)
miss <- gsub( "Sutherland Group ", "", miss)
miss <- gsub( "Unit \\d{1,3} ", "", miss)
miss <- gsub( "Watson Hall 306-12 ", "", miss)

miss <- gsub( " To .*", "", miss)
miss <- gsub( " to .*", "", miss)
miss <- gsub( "&.*", "", miss)
miss <- gsub( "\\d{3} \\(.*\\) ", "", miss)
miss <- gsub( "^ ", "", miss)

#adding back syracuse and new york
miss <- paste(miss, ", Syracuse, New York", sep = "")

df.Cna$Location2 <- miss


#DEMOLITION
load("df.D.rda") #loading the data frame 
x <- is.na(df.D$lat)
df.Dna <- df.D[x,]

miss <- df.Dna$Location2

miss <- gsub( " , Syracuse, New York", "", miss) # removing syra
miss <- gsub( "\n", "", miss)
miss <- gsub( "Woodframe Rental ", "", miss)
miss <- gsub( "VPA East Genesee St ", "", miss)
miss <- gsub( "Rear", "", miss)
miss <- gsub( " To .*", "", miss)
miss <- gsub( " to .*", "", miss)
miss <- gsub( "&.*", "", miss)

#adding back syracuse and new york
miss <- paste(miss, ", Syracuse, New York", sep = "")

df.Dna$Location2 <- miss

#INSTALATIONS AND REPAIRS
load("df.I.rda") #loading the data frame 
x <- is.na(df.I$lat)
df.Ina <- df.I[x,]

miss <- df.Ina$Location2

#delete content in string
miss <- gsub( " , Syracuse, New York", "", miss) # removing syra
miss <- gsub( "\n", "", miss)
miss <- gsub( "Rear", "", miss)

#if content replace whole address by name of building/location
miss <- gsub( ".*Flanagan Gym.*", "Flanagan Gym", miss)
miss <- gsub( ".*Falk College.*", "Falk College", miss)
miss <- gsub( ".*Hinds Hall.*", "Hinds Hall", miss)
miss <- gsub( ".*Graham Dining Hall.*", "Graham Dining Hall", miss)
miss <- gsub( ".*Bowne Hall.*", "Bowne Hall", miss)
miss <- gsub( ".*Flint Hall.*", "Flint Hall", miss)
miss <- gsub( ".*Physics Bldg.*", "Physics Building", miss)
miss <- gsub( ".*Hendricks Chapel.*", "Hendricks Chapel", miss)
miss <- gsub( ".*1320 Jamesville Ave.*", "1320 Jamesville Ave", miss)
miss <- gsub( ".*Carousel Center.*","Carousel Center Dr", miss)
miss <- gsub( ".*Hiawatha.*","306 Hiawatha Blvd W", miss)
miss <- gsub( ".*Destiny USA Dr.*","Destiny USA Dr", miss)
miss <- gsub( ".*Airport Boulevard.*", "Airport Boulevard", miss)
miss <- gsub( ".*Bird Library.*", "Bird Library", miss)
miss <- gsub( ".*1320 Jamesville Ave.*", "1320 Jamesville Ave", miss)
miss <- gsub( ".*Archbold Gym.*", "Archbold Gym", miss)
miss <- gsub( ".*Schine Student Center.*", "Schine Student Center", miss)

#delete content in string
miss <- gsub( "Shaffer Art ", "", miss)
miss <- gsub( "Tolley Humanities Bldg ", "", miss)
miss <- gsub( "Machinery Hall ", "", miss)
miss <- gsub( "Raynor Parking Lot ", "", miss)
miss <- gsub( "Henry Parking Lot ", "", miss)
miss <- gsub( "Newhouse 1 and 2 ", "", miss)
miss <- gsub( "Watson Hall ", "", miss)
miss <- gsub( "DellPlain and Ernie Davis Hall ", "", miss)
miss <- gsub( "Academic Bldg ", "", miss)
miss <- gsub( "Playing Fields, Courts", "", miss)
miss <- gsub( "Physical Plan & Commissary ", "", miss)
miss <- gsub( "R \\d{2,3} Xavier", "", miss)
miss <- gsub( "121 (253-260) Small Rd ", "", miss)
miss <- gsub( "Skytop Housing East ", "", miss)
miss <- gsub( "Skytop Housing West ", "", miss)
miss <- gsub( "Skytop Housing ", "", miss)
miss <- gsub( "Unit \\d{1,3} ", "", miss)
miss <- gsub( "\\d{3} \\(.*\\) ", "", miss)
miss <- gsub( "160 Small Rd ", "", miss)
miss <- gsub( "Small Rd ", "", miss)
miss <- gsub( "Slocum Heights ", "", miss)
miss <- gsub( "Winding Ridge Rd ", "", miss)
miss <- gsub( "Lambreth Ln ", "", miss)
miss <- gsub( "Farm Acre Rd ", "", miss)
miss <- gsub( "Chinook Dr ", "", miss)
miss <- gsub( "M17 Daycare ", "", miss)
miss <- gsub( "norman Jemal ", "", miss)
miss <- gsub( "Life Science Center ", "", miss)
miss <- gsub( " Comm #1-3A", "", miss)
miss <- gsub( " Condo [[:alpha:]]{3,4}", "", miss)
miss <- gsub( "Scott O'Grady", "", miss)
miss <- gsub( "R \\d{2} Nursery", "", miss)
miss <- gsub( "Unit 24 Sutherland Group ", "", miss)
miss <- gsub( "Unit 18 M/E Engineering ", "", miss)
miss <- gsub( "Irving Garage and Dineen Hall ", "", miss)
miss <- gsub( "VPA East Genesee St ", "", miss)
miss <- gsub( "Haft Hall ", "", miss)
miss <- gsub( "Sutherland Group ", "", miss)
miss <- gsub( "M/E Engineering ", "", miss)
miss <- gsub( "Steam & Chilled Water", "", miss)
miss <- gsub( "Physical Plan & Commissary ", "", miss)

miss <- gsub( " To .*", "", miss)
miss <- gsub( " to .*", "", miss)
miss <- gsub( "&.*", "", miss)
miss <- gsub( "^ ", "", miss)

#adding back syracuse and new york
miss <- paste(miss, ", Syracuse, New York", sep = "")

df.Ina$Location2 <- miss
```

Now that the addresses are clean, we geocode again and save the objects. After the second goecode, persisting NAs were fixed mannually.

``` r
#2. GEOCODING THE NAs

register_google(key = "YOUR KEY HERE", account_type = "premium", day_limit = 100000) #Need to put premium to fool the function. I did not have a premium, just a google API key that was authorized to bill me

#Found
df.Fna <- mutate_geocode(df.Fna, Location2, source = "google")
sum(is.na(df.Fna$lat)) 
#no NAs
save(df.Fna, file = "df.Fna.rda")

#Res
df.Rna <- mutate_geocode(df.Rna, Location2, source = "google")
sum(is.na(df.Rna$lat)) 
#1 NA left
x <- is.na(df.Rna$lat)
#manually fixing last addresses
df.Rna[x,11] <- "115 Marlett St, Syracuse, New York"
#geocoding
location <- geocode(df.Rna[x,11], source = "google")
#adding lon
df.Rna[x,12] <- location[,1]
#adding lat
df.Rna[x,13] <- location[,2]
save(df.Rna, file = "df.Rna.rda")

#Com
df.Cna <- mutate_geocode(df.Cna, Location2, source = "google")
sum(is.na(df.Cna$lat)) 
#4 NAs
x <- is.na(df.Cna$lat)
#manually fixing last addresses
df.Cna[x,11] <- c("914-22 Genesee St E, Syracuse, New York",
                  "Schine Student Center, Syracuse, New York",
                  "605-11 Raynor Ave E, Syracuse, New York",
                  "605-11 Raynor Ave E, Syracuse, New York")
#geocoding
location <- geocode(df.Cna[x,11], source = "google")
#adding lon
df.Cna[x,12] <- location[,1]
#adding lat
df.Cna[x,13] <- location[,2]
save(df.Cna, file = "df.Cna.rda")


#Dem
df.Dna <- mutate_geocode(df.Dna, Location2, source = "google")
sum(is.na(df.Dna$lat)) 
#no NAs
save(df.Dna, file = "df.Dna.rda")

#Installations
df.Ina <- mutate_geocode(df.Ina, Location2, source = "google")
sum(is.na(df.Ina$lat)) 
#2 NAs
x <- is.na(df.Ina$lat)
#manually fixing last addresses
df.Ina[x,11] <- c("104 Mc Allister Ave, Syracuse, New York","867 Emerson Ave, Syracuse, New York")
#geocoding
location <- geocode(df.Ina[x,11], source = "google")
#adding lon
df.Ina[x,12] <- location[,1]
#adding lat
df.Ina[x,13] <- location[,2]
save(df.Ina, file = "df.Ina.rda")
```

Now we add the geocode information to the NAs in the original subsets

``` r
#Adding the geocode information to the NAs in the  original subsets

#FOUND
load("df.F.rda")
dim(df.F)
x <- is.na(df.F$lat)
df.F[x,] <- df.Fna
save(df.F, file = "df.F.rda")

#RES
load("df.R.rda")
dim(df.R)
x <- is.na(df.R$lat)
sum(x)
dim(df.Rna)
df.R[x,] <- df.Rna
save(df.R, file = "df.R.rda")

#COM
load("df.C.rda")
dim(df.C)
x <- is.na(df.C$lat)
sum(x)
dim(df.Cna)
df.C[x,] <- df.Cna
save(df.C, file = "df.C.rda")

#DEM
load("df.D.rda")
dim(df.D)
x <- is.na(df.D$lat)
sum(x)
dim(df.Dna)
df.D[x,] <- df.Dna
save(df.D, file = "df.D.rda")

#INSTALLATION
load("df.I.rda")
dim(df.I)
x <- is.na(df.I$lat)
sum(x)
dim(df.Ina)
df.I[x,] <- df.Ina
save(df.I, file = "df.I.rda")
```

Merging all geocoded subets

``` r
#Merging ALL geocoded SUBSETS

dat <- rbind(df.R, df.C, df.I, df.D, df.F)

#write.csv(dat, file= "Permits_noNAs.csv", row.names = F) #this dataset is missing the Ignored permits which we will add later. we are saving it just in case.
```

Adding the tract id to the permits.
-----------------------------------

``` r
#Creating a TRACT variable for each permit in dat

#making the permit dat object a spatial object
dat <- SpatialPointsDataFrame(dat[ ,c( "lon", "lat") ], dat, proj4string=CRS("+proj=longlat +datum=WGS84")) #this is so that it does not lose the lat lon in the dataframe when transformed into a sp

#loading shape file
shapes <- geojson_read("https://raw.githubusercontent.com/christine-brown/SyracuseLandBank/master/SHAPEFILES/SYRCensusTracts.geojson", method="local", what="sp" )

#need to make CRS in both shapes and dat =
proj4string(dat)
proj4string(shapes)

shapes <- spTransform( shapes, CRS( "+proj=longlat +datum=WGS84")) #changing the CRS of the shape file to match the dat

# ORIGINALLY I USED POINTS IN POLY, BUT THIS MADE ME DROP 191 CASES. 
#dat <- point.in.poly( dat, shapes) #all the permits that were outside the tracks were dropped. 
#new dat file haD 16845
#16845 - 17036 = 191 lost

# SO I USED THE OVER function to determine what points are within the buffer
x <- over( dat, shapes ) #outputs a dummy variable
class(x) #x is a dataframe with only one column.
dat@data$Tract <- as.character(x[,1]) #we want the vector for column one to be added to de dataset

#now the dataset has tract numbers - points outside the tract polygons of our shape fileappear with an NA.
```

``` r
#merging the df.Ign and dat dataset (with the geocoded and tract id permits) 

#making dat a regular dataframe object to make the bind
dat <- dat@data

#formatting df.Ign
load("df.Ign.rda")
colnames(df.Ign)
df.Ign$Location2 <- NA
df.Ign$lon <- NA
df.Ign$lat <- NA
df.Ign$Tract <- NA

dat <- rbind(dat, df.Ign)
```

Sorting and saving the CSV file
-------------------------------

``` r
#sorting the dataset and saving it as a csv file. 
dat <- arrange(dat, Type, Year)

#removing unnecesarry columns
dat[,c("Antenna...Dish","SBL.")] <- NULL

#write.csv(dat, file= "Permits_processed.csv", row.names = F)
```

Generating aggregated dataframe
-------------------------------

First we divide the permits types that we want to use from the ingored ones creating two subsets.

``` r
dat <- read.csv("https://raw.githubusercontent.com/christine-brown/SyracuseLandBank/master/DATA/AGGREGATED_DATA/Permits_processed.csv", stringsAsFactors = F)

#Creating two subsets: dat and df.Ign

#1. df.Ign subset holds  the permit types we are not using.
#creating a vector that contains all the cases of ignored permit types.
x <- dat$Type
Ign <- x == "Antenna / Dish" | x =="Electric (Meter Set)" |  x=="Block Party (Business)" | x=="Block Party (Residential)" | x=="Curb Cut" | x=="Encroach (Deminimus)" | x=="Encroach (Major)"  | x=="Encroachment (Converted)" | x=="Footing / Foundation"  | x=="Liability Waiver" | x=="Loading Zone (Business)" | x=="Parking Meter Rental" | x=="Public Assembly" | x=="Road Cut" | x=="Sidewalk Cafe" | x=="Sidewalk Replace" | x=="Sign" | x=="Site Work"

#NOTE: In the data wrangling process 3 permit types were reassigned from a geocoded category to the Ignored category. These were:
#Footing foundations (from Found)
#Electric(meter set) and Antenna / Dish. (from Installation and repairs)
#this three ignored permit types were geocoded and have tract id in the dataframe

#subsetting it (18 ignored permit types)
df.Ign <- dat[Ign,]

#2. dat subset holds all permit types we are going to use. These are geocoded and have tract id (14 permit types)
dat <- dat[!Ign,]
```

Now we delete the permits that have no tract id assigned.

``` r
#CLIPPING all dat permits outside syracuse city
#use the tract variable, because of the over spatial function (described in the data wrangling rmd) the points outside the tracts have NA

x<- is.na(dat$Tract) #191 NAs, or points outside the tracts
dat <- dat[!x,] # eliminating the NAs
```

And now we aggregate the data to census tract to produce the final dataset

This dataset will have the following columns:

-   TRACT
-   YEAR
-   PER\_TOT\_FRQ
-   PER\_TOT\_VAL
-   PER\_RES\_FRQ
-   PER\_RES\_VAL
-   PER\_COM\_FRQ
-   PER\_COM\_VAL
-   PER\_INS\_FRQ
-   PER\_INS\_VAL
-   PER\_DEM\_FRQ
-   PER\_DEM\_VAL

Look at the data dictionary for more information about this variables.

``` r
#Aggregating the variables and binding them.

#TOTAL 
x <- group_by(dat, Tract, Year)
total <- summarize(x, 
                   PER_TOT_FRQ = n(),
                   PER_TOT_VAL = sum(Valuation)
                   )

#df.R
cat <- as.character(dat$Type)  #setting up indexes
df.R <- cat== "Res. Remodel/Chg Occ" | cat == "Res. New 1-2 Family" 
df.R <- dat[df.R,] 

x <- group_by(df.R, Tract, Year)
Res <- summarize(x, 
                   PER_RES_FRQ = n(),
                   PER_RES_VAL = sum(Valuation)
                   )

#df.C
df.C <- cat== "Com. New Building" | cat=="Com. Reno/Rem/Chg Occ"
df.C <- dat[df.C,] 

x <- group_by(df.C, Tract, Year)
Com <- summarize(x, 
                   PER_COM_FRQ = n(),
                   PER_COM_VAL = sum(Valuation)
                   )

#df.D
df.D <- cat=="Demolition"
df.D <- dat[df.D,] 

x <- group_by(df.D, Tract, Year)
Dem <- summarize(x, 
                   PER_DEM_FRQ = n(),
                   PER_DEM_VAL = sum(Valuation)
                   )

#df.I
df.I <- cat=="Electric" | cat=="Elevator" | cat=="Fire Alarm" | cat=="HVAC/Mechanical" | cat=="Misc.(deck, fence,ramp)" | cat=="Pool / Hot Tub" | cat=="Security Alarm" | cat=="Sprinkler" | cat=="Tank"
df.I <- dat[df.I,] 

x <- group_by(df.I, Tract, Year)
Ins <- summarize(x, 
                   PER_INS_FRQ = n(),
                   PER_INS_VAL = sum(Valuation)
                   )

#binding the different aggregates by variable
var <- merge(total, Res, all = T)
var <- merge(var,Com, all = T)
var <- merge(var,Ins, all = T)

colnames(var)[c(1,2)] <- c("TRACT", "YEAR")
getwd()
#write.csv(var, file = "Permits_aggregated.csv", row.names = FALSE) #writting the aggregated dataset!
```

Descriptives from the datasets
==============================

![](Permits_Wrangling_files/figure-markdown_github/unnamed-chunk-16-1.png)
