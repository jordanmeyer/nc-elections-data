source("00-packages.R")

################################################################################
## Geolocate voters using address points file from ncsbe
voters <- read_tsv("../data/ncvoter_Statewide.txt")
addresses <- read_tsv("../data/address_points_sboe.txt")

## Remove addresses with missing geocodes
addresses <- addresses[!(is.na(addresses$x_st_plane_ft) |
                         is.na(addresses$y_st_plane_ft)),]

## Transform coordinates to lat lon
address.coords <- select(addresses, x_st_plane_ft, y_st_plane_ft)
crs <-
  CRS(paste("+proj=lcc +lat_1=34.33333333333334 +lat_2=36.16666666666666",
            "+lat_0=33.75 +lon_0=-79 +x_0=609601.2199999997 +y_0=0",
            "+datum=NAD83 +units=us-ft +no_defs +ellps=GRS80 +towgs84=0,0,0"))

p <- SpatialPoints(address.coords, proj4string=crs)
g <- spTransform(p, CRS("+proj=longlat +datum=WGS84"))
new.coords <- as.data.frame(coordinates(g))
names(new.coords) <- c("lon", "lat")
addresses <- cbind(addresses, new.coords)

## Left join geo codes by street address and zip code
addresses <- select(addresses, res_street_address, res_zip, lon, lat)
voters <-
  voters %>%
  mutate(res_street_address = str_replace(res_street_address, " +", " ")) %>%
  left_join(addresses,
            by = c("mail_addr1" = "res_street_address",
                   "zip_code" = "res_zip"))

sum(!is.na(voters$lon))/nrow(voters) ## 80% matched!
## using google geocode at 5 per second, we'd need 85 hours to get the rest
(nrow(voters) - sum(!is.na(voters$lon))) / (5 * 3600)

###
## Map a random sample of 10,000 voters
voters$color <-
  sapply(voters$party_cd,
         function(party) switch(party,
                                "DEM" = "blue",
                                "REP" = "red",
                                "grey"))

voters %>%
  filter(!(is.na(lat) | is.na(lon))) %>%
  sample_n(10000) %>%
  leaflet() %>%
  addProviderTiles("CartoDB.Positron") %>%
  addCircles(lng=~lon, lat=~lat, color=~color,
             popup=~paste0(first_name,
                           " ",
                           last_name,
                           "<br>",
                           res_street_address,
                           "<br>",
                           res_city_desc,
                           " ",
                           zip_code))
