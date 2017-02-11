################################################################################
## Download and unzip files from NCSBE
download_ncsbe_data <- function(dir, file.name, ex.dir = "./") {
  data.dir <- "./"
  download.file(paste0("http://dl.ncsbe.gov.s3.amazonaws.com/", dir, file.name),
                paste0(data.dir, file.name))
  unzip(paste0(data.dir, file.name), exdir=ex.dir)
  file.remove(paste0(data.dir, file.name))
}

################################################################################
## Download and convert NCSBE Shapefiles
download_ncsbe_shapes <- function(file.name, dl.dir) {
  file.path <- paste0("http://dl.ncsbe.gov.s3.amazonaws.com/",
                      "ShapeFiles/Map_Data/",
                      file.name)

  shapes.csv <- read_csv(file.path)
  names(shapes.csv) <- c("x", "y", "district")

  district.polygons <-
    shapes.csv %>%
    group_by(district) %>%
    do(poly=select(., x, y) %>% Polygon()) %>%
    rowwise() %>%
    do(polys=Polygons(list(.$poly),.$district)) %>%
    {SpatialPolygons(.$polys)}

  proj4string(district.polygons) <-
    CRS(paste("+proj=lcc +lat_1=34.33333333333334 +lat_2=36.16666666666666",
              "+lat_0=33.75 +lon_0=-79 +x_0=609601.2199999997 +y_0=0",
              "+datum=NAD83 +units=us-ft +no_defs +ellps=GRS80 +towgs84=0,0,0"))

  district.polygons <-
    spTransform(district.polygons,
                CRS("+proj=longlat +datum=NAD83 +no_defs +ellps=GRS80 +towgs84=0,0,0"))

  district.data <- data.frame(district = 1:length(district.polygons))
  district.shapes <- SpatialPolygonsDataFrame(district.polygons, district.data)

  writeOGR(district.shapes, paste0("ncsbe_maps/", dl.dir),
           dl.dir, driver="ESRI Shapefile")
}

################################################################################
## Parse HTML tables from NCGA website member directories
get_ncga_reps <- function(chamber){
  reps.page <-
    read_html(paste0("http://www.ncleg.net/",
                     "gascripts/members/memberListNoPic.pl",
                     "?sChamber=", chamber))

  reps.df <-
    reps.page %>%
    html_node("#mainBody table") %>%
    html_table()

  names(reps.df) <- c("party", "district", "member", "counties")

  rep.links <-
    reps.page %>%
    html_nodes("#mainBody table a") %>%
    html_attr("href")

  rep.links <- rep.links[str_detect(rep.links, "/gascripts/members/viewMember")]

  reps.df$link <- paste0("http://www.ncleg.net", rep.links)

  reps.df$district <- as.numeric(str_replace_all(reps.df$district,
                                                 "District ",
                                                 ""))

  reps.df$party <- str_replace_all(reps.df$party, "[()]", "")

  reps.df <- reps.df %>%
    group_by(district) %>%
    mutate(district.count = n()) %>%
    filter(!(str_detect(member, "Resigned") & (district.count > 1)),
           !(str_detect(member, "Deceased") & (district.count > 1))) %>%
    select(-district.count)

  reps.df$member <- str_replace_all(reps.df$member, " ", " ")

  return(reps.df)
}

################################################################################
## Parse HTML of NC directory table from US House website
get_us_house <- function(){
  reps.page <-
    read_html("http://www.house.gov/representatives/")

  district <-
    reps.page %>%
    html_nodes("#state_nc+ .directory td:nth-child(1)") %>%
    html_text()

  member <-
    reps.page %>%
    html_nodes("#state_nc+ .directory td:nth-child(2)") %>%
    html_text() %>%
    str_replace_all("\\n", "") %>%
    str_replace_all(" $", "")

  link <-
    reps.page %>%
    html_nodes("#state_nc+ .directory td:nth-child(2) a") %>%
    html_attr("href")

  party <-
    reps.page %>%
    html_nodes("#state_nc+ .directory td:nth-child(3)") %>%
    html_text()

  us.house <- data.frame(district = district,
                         member = member,
                         party = party,
                         link = link,
                         stringsAsFactors = FALSE)

  return(us.house)
}

################################################################################
## Get Early Voting Sites

## Helper function to get lat/lon for voting sites
geocodeAdddress <- function(address) {
  url <- "http://maps.google.com/maps/api/geocode/json?address="
  url <- URLencode(paste(url, address, "&sensor=false", sep = ""))
  x <- fromJSON(url, simplify = FALSE)
  if (x$status == "OK") {
    out <- c(x$results[[1]]$geometry$location$lng,
             x$results[[1]]$geometry$location$lat)
  } else {
    out <- NA
  }
  Sys.sleep(0.2)  # API allows 5 requests per second
  out
}

## Pull early voting site tsv, geocode and save
get_early_voting <- function(){
  early.voting <- read_tsv("https://vt.ncsbe.gov/ossite/GetStatewideList/",
                           col_names=FALSE)

  names(early.voting) <- c("election.date",
                           "county",
                           "unknown.flag",
                           "name",
                           "addr.line.1",
                           "addr.line.2",
                           "open.date",
                           "hours")

  addresses <-
    early.voting %>%
    select(addr.line.1, addr.line.2) %>%
    distinct() %>%
    ## Google doesn't seem to like the # signs used in several addresses
    mutate(full.addr = str_replace(paste(addr.line.1, addr.line.2), "#", ""))

  ## manual clean-up for geocoding, these showed empty our outside of NC
  addresses[25,"full.addr"] <- "1044 SABBATH HOME RD SUPPLY, NC 28462"
  addresses[94,"full.addr"] <- "2694 GENERAL HOWE HWY RIEGELWOOD, NC 28456"

  address.geos <-
  lapply(1:nrow(addresses),
         function(x) geocodeAdddress(addresses$full.addr[x]))

  addresses$lon <- sapply(address.geos, function(x) x[1])
  addresses$lat <- sapply(address.geos, function(x) x[2])
  addresses$full.addr <- NULL

  early.voting <- inner_join(early.voting, addresses)

  return(early.voting)
}
