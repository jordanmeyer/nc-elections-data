source("00-packages.R")

## Early voting sites
early.voting <- read_csv("../data/early_voting.csv")

## Csv has one row per site per day
## Distinct for sites and map
early.voting %>%
  select(name, addr.line.1, addr.line.2, lon, lat) %>%
  distinct() %>%
  leaflet() %>%
  addProviderTiles("CartoDB.Positron") %>%
  addCircles(lng=~lon, lat=~lat,
             popup=~paste0(name,
                           "<br>",
                           addr.line.1,
                           "<br>",
                           addr.line.2))
