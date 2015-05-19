# seattle_building_permits.R | last updated: 5/19/15 | Tim Sneath

## Seattle building permits data
file.url <- "https://data.seattle.gov/api/views/mags-97de/rows.csv?accessType=DOWNLOAD"
download.file(file.url, destfile="permits.csv")

## Read data in and massage formats a little
permits <- read.csv("permits.csv", stringsAsFactors=FALSE)
permits$Category <- factor(permits$Category)
permits$Value <- as.numeric(substr(permits$Value, 2, nchar(permits$Value)-1))
permits$Application.Date <- as.Date(permits$Application.Date, format="%m/%d/%Y")

library(ggmap)
library(mapproj)

## Establish a bounding box for the permits data
bbox <- c(min(permits$Longitude, na.rm=TRUE), 
          min(permits$Latitude, na.rm=TRUE), 
          max(permits$Longitude, na.rm=TRUE), 
          max(permits$Latitude, na.rm=TRUE))

## Another alternative - zooming a little closer
## bbox <- c(quantile(permits$Longitude, probs=0.1, na.rm=TRUE), 
##           quantile(permits$Latitude, probs=0.25, na.rm=TRUE), 
##           quantile(permits$Longitude, probs=0.9, na.rm=TRUE), 
##           quantile(permits$Latitude, probs=0.75, na.rm=TRUE))

names(bbox) <- NULL

## Grab map from OpenStreetMaps.
map <- get_map(location=bbox,
               zoom=12, scale=OSM_scale_lookup(zoom=12),
               maptype="roadmap", 
               source="osm")


## ggplot2-like syntax - create a map and then plot points appropriately
ggmap(map) + geom_point(aes(x=permits$Longitude, 
                            y=permits$Latitude, 
                            colour=factor(permits$Category),
                            size=sqrt(permits$Value)),
                        data=permits, 
                        # alpha=.5, 
                        na.rm=TRUE)
