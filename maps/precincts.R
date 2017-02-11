source("00-packages.R")

###
## Precincts require transorm from the NCSBE shapefiles
precinct.shapes <- readOGR("../data/ncsbe_maps/precincts/Precincts.shp",
                              layer="Precincts")
precinct.shapes <-spTransform(precinct.shapes,
                                 CRS("+proj=longlat +datum=WGS84"))

leaflet(precinct.shapes) %>%
  addProviderTiles("CartoDB.Positron") %>%
  addPolygons(
    stroke = TRUE, weight = 1, fillOpacity = 0.5, smoothFactor = 0.5,
    popup=~PREC_ID
  )

###
## Some precincts span house districts
nc.house <- read_csv("../data/nc_house.csv")
house.shapes <- readOGR("../data/ncsbe_maps/nc_house/nc_house.shp",
                              layer="nc_house")

leaflet(precinct.shapes) %>%
  addProviderTiles("CartoDB.Positron") %>%
  addPolygons(
    data = house.shapes,
    stroke = TRUE, weight = 1, fillOpacity = 0, color = "black"
  ) %>%
  addPolygons(
    stroke = TRUE, weight = 1, fillOpacity = 0, color="red",
    popup=~PREC_ID
  )
