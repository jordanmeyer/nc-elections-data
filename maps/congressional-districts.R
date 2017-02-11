source("00-packages.R")

###
## NC House.
nc.house <- read_csv("../data/nc_house.csv")
house.shapes <- readOGR("../data/ncsbe_maps/nc_house/nc_house.shp",
                              layer="nc_house")

house.shapes <- merge(house.shapes, nc.house)
house.shapes$color <- ifelse(house.shapes$party == "D", "blue", "red")

leaflet(house.shapes) %>%
  addProviderTiles("CartoDB.Positron") %>%
  addPolygons(
    stroke = TRUE, weight = 1, fillOpacity = 0.5, smoothFactor = 0.5,
    popup=~paste0("NC House District ", district, "<br>",
                 "<a href='", link, "' target='_blank'>", member,
                 " (", party, ") </a>"),
    color = ~color
  )

###
## NC Senate
nc.senate <- read_csv("../data/nc_senate.csv")
senate.shapes <- readOGR("../data/ncsbe_maps/nc_senate/nc_senate.shp",
                              layer="nc_senate")

senate.shapes <- merge(senate.shapes, nc.senate)
senate.shapes$color <- ifelse(senate.shapes$party == "D", "blue", "red")

leaflet(senate.shapes) %>%
  addProviderTiles("CartoDB.Positron") %>%
  addPolygons(
    stroke = TRUE, weight = 1, fillOpacity = 0.5, smoothFactor = 0.5,
    popup=~paste0("NC Senate District ", district, "<br>",
                 "<a href='", link, "' target='_blank'>", member,
                 " (", party, ") </a>"),
    color = ~color
  )

###
## US House.
us.house <- read_csv("../data/us_house.csv")
us.house.shapes <- readOGR("../data/ncsbe_maps/us_house/us_house.shp",
                              layer="us_house")

us.house.shapes <- merge(us.house.shapes, us.house)
us.house.shapes$color <-
  ifelse(us.house.shapes$party == "D", "blue", "red")

leaflet(us.house.shapes) %>%
  addProviderTiles("CartoDB.Positron") %>%
  addPolygons(
    stroke = TRUE, weight = 1, fillOpacity = 0.5, smoothFactor = 0.5,
    popup=~paste0("US House District ", district, "<br>",
                 "<a href='", link, "', target='_blank'>", member,
                 " (", party, ") </a>"),
    color = ~color
  )
