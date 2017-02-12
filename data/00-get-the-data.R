library(readr)
library(dplyr)
library(rvest)
library(stringr)
library(sp)
library(RJSONIO)
library(rgdal)

source("00-functions.R")

################################################################################
## Download large data not in the github repo
## CAUTION: Unzipped these are over 7GB

## Voter registration data - ~3GB
download_ncsbe_data("data/", "ncvoter_Statewide.zip")

## Get address lat long lookup ~500MB
download_ncsbe_data("ShapeFiles/", "address_points_sboe.zip")

## Voter history data - ~4GB
## Any use in this? Propensity to vote in mid-terms? Persuadability?
## download_ncsbe_data("data/", "ncvhis_Statewide.zip")

################################################################################
## The following are optional downloads. They are included in the github repo.

###
## Get precinct maps
## download_ncsbe_data("PrecinctMaps/", "SBE_PRECINCTS_20161004.zip",
##                     "ncsbe_maps/precincts")

## download_ncsbe_shapes("NC_House.txt", "nc_house")
## download_ncsbe_shapes("NC_Senate.txt", "nc_senate")
## download_ncsbe_shapes("US_Congress.txt", "us_house")

###
## Get Early Voting Sites
## Geocoding takes a while...
## early.voting <- get_early_voting()
## write_csv(early.voting, "early_voting.csv")

###
## Get NCGA Reps
## nc.house <- get_ncga_reps("House")
## nc.senate <- get_ncga_reps("Senate")

## write_csv(nc.house, "nc_house.csv")
## write_csv(nc.senate, "nc_senate.csv")

###
## Get US House Reps
## us.house <- get_us_house()
## write_csv(us.house, "us_house.csv")
