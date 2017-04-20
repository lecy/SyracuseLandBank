# CensusData
Chris Davis  
3/23/2017  




```r
library(censusapi)
library(dplyr)
censuskey <- "b431c35dad89e2863681311677d12581e8f24c24"

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

temp <- mutate(temp, year = i)

census<- rbind(census, temp)
}

GEOID <- paste0(census$state, census$county, census$tract)
census <- mutate(census, GEOID)



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

labels <- toupper(labels)

names(census) <- labels
census <- tbl_df(census)

syrCensus<- filter(census, as.numeric(TRACT)<10000)


census2010 <- getCensus(name = "sf1", vintage = 2010, 
                        key = censuskey,
                        vars = c("NAME", "P0010001", "P0030002", 
                                 "P0030003", "P0030005", "P0040003", 
                                 "H0030003",  "H0050008", "H0050002", 
                                 "H0050006", "H0050004", "P0180001", "H0140002", 
                                 "H0040004", "H00010001", "P0160002"),
                        region = "tract:*", 
                        regionin = "state: 36 + county:067")

names(census2010) <- toupper(c("name","state", "county", "tract",
                       "total", "white", "black", "asian", 
                       "hispanic", "vacant", "otherVacant", 
                       "vacantForRent", "seasonalVacant", "forSaleVacant",
                       "households", "ownerOccupied", "renterOccupied", 
                       "totalHousingUnits", "less18"))
census2010 <- tbl_df(census2010)
census2010<- filter(census2010, as.numeric(TRACT)<10000)

census2000 <- getCensus(name = "sf1", vintage = 2000, 
                        key = censuskey, 
                        vars = c("NAME", "P001001", "P003003", 
                                 "P003004", "P003006", "P004002", 
                                 "H005001", "H005007", "H005002", 
                                 "H005005", "H005003", "P015001", 
                                 "H004002", "H004003","H001001"), 
                        region = "tract:*", 
                        regionin = "state: 36 + county:067")

names(census2000) <- toupper(c("name","state", "county", "tract",
                       "total", "white", "black", "asian", 
                       "hispanic", "vacant", "otherVacant", 
                       "vacantForRent", "seasonalVacant", 
                       "forSaleVacant", "households", 
                       "ownerOccupied", "renterOccupied", "totalHousingUnits"))

census2000 <- tbl_df(census2000)
census2000<- filter(census2000, as.numeric(TRACT)<10000)

moreCensus2000<- getCensus(name = "sf3", vintage = 2000, 
                           key = censuskey,
                           vars = c("NAME", "P053001", "P077001",
                                    "P043007", "P043014", "P043003",
                                    "P043010", "P087002", "P087001", 
                                    "H047003", "H050003", "P130003", "P038010", "H076001"), 
                           region = "tract:*", regionin = "state: 36 + county:067")

names(moreCensus2000) <- toupper(c("name", "state", "county", "tract", 
                           "medianHouseIncome", "medianFamIncome", "maleUnemployed",
                           "femaleUnemployed", "maleLaborForce", "femaleLaborForce", 
                           "poverty", "totalForPoverty", "lackingPlumbing",
                           "lackingKitchenFacilities", "aggregateTravelTimeToWork",
                           "enrolledInSchool", "housingValues"))

moreCensus2000 <- tbl_df(moreCensus2000)
moreCensus2000<- filter(moreCensus2000, as.numeric(TRACT)<10000)



#availablevars <- listCensusMetadata(name="sf1", vintage=2010)

#poverty_possible_vars <- subset(availablevars, 
  #grepl("value", availablevars$label, 
  #ignore.case = TRUE))
```


```r
all <- names(syrCensus)
all <- c(all, names(census2000))
all <- c(all, names(moreCensus2000))
all <- c(all, names(census2010))
all <- unique(all)

df = data.frame(matrix(vector(), 1, 42,
                dimnames=list(c(), all)),
                stringsAsFactors=F)

a <- merge(df, syrCensus, all = T)
b <- merge(df, census2000, all = T)
c <- merge(df, moreCensus2000, all = T)
d <- merge(df, census2010, all = T)

fullFrame <- rbind(a, b)
fullFrame <- rbind(fullFrame, c)
fullFrame <- rbind(fullFrame, d)
```


```r
write.csv(fullFrame, file = "censusDataFromChris.csv")
```


