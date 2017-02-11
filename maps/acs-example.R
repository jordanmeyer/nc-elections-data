source("00-packages.R")

################################################################################
## Census tract maps colored by acs data

## get census shapes from tigris
census.shapes <- tracts(state="NC")

## create a geo for acs
geo<-geo.make(state=c("NC"), county="*", tract="*")

## Get income table from acs
income <- acs.fetch(endyear = 2015, span = 5, geography = geo,
                    table.number = "B19001", col.names = "pretty")

# Create a data.frame for merging. Keep total and add income bands under 30k.
income.df <-
  data.frame(paste0(str_pad(income@geography$state, 2, "left", pad="0"),
                    str_pad(income@geography$county, 3, "left", pad="0"),
                    str_pad(income@geography$tract, 6, "left", pad="0")),
             income@estimate[,1],
             income@estimate[,2] + income@estimate[,3] + income@estimate[,4] +
             income@estimate[,5] + income@estimate[,6],
             stringsAsFactors = FALSE)

names(income.df)<-c("GEOID", "total", "below.30k")
income.df$below.30k.percent <- 100*(income.df$below.30k/income.df$total)

## Merge the acs data with the census shapes
census.shapes <- merge(census.shapes, income.df)

###
## Quick leaflet plot of results
pal <- colorNumeric(
  palette = "Blues",
  domain = income.df$below.30k.percent
)

leaflet(census.shapes) %>%
  addProviderTiles("CartoDB.Positron") %>%
  addPolygons(
    stroke = TRUE, weight = 1, fillOpacity = 0.5, smoothFactor = 0.5,
    popup=~paste0(NAMELSAD, "<br>", below.30k.percent, "%"),
    color = ~pal(below.30k.percent)
  )
