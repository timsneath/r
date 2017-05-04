# seattle_building_permits.R | last updated: 5/4/17 | Tim Sneath

## Seattle building permits data
file.url <- "https://data.seattle.gov/api/views/mags-97de/rows.csv?accessType=DOWNLOAD"
download.file(file.url, destfile = "permits.csv")

## Read data in and massage formats a little
permits <- read.csv("permits.csv", stringsAsFactors = FALSE)
permits$Category <- factor(permits$Category)
permits$Value <- as.numeric(substr(permits$Value, 2, nchar(permits$Value) - 1))
permits$Application.Date <- as.Date(permits$Application.Date, format = "%m/%d/%Y")

## Subset to just the last three months and ignore uncategorized permits
recentPermits <- subset(permits, Application.Date > (Sys.Date() - 90) &
                                 Category != "")

library(ggmap)
library(mapproj)

## Establish a bounding box for the permits data
bbox <- c(min(recentPermits$Longitude, na.rm = TRUE),
          min(recentPermits$Latitude, na.rm = TRUE),
          max(recentPermits$Longitude, na.rm = TRUE),
          max(recentPermits$Latitude, na.rm = TRUE))

names(bbox) <- NULL

## Grab map from Google Maps
map <- get_map(location = bbox,
               scale = 2,
               maptype = "roadmap",
               source = "google")

## ggplot2-like syntax - create a map and then plot points appropriately
ggmap(map) + geom_point(aes(x = recentPermits$Longitude,
                            y = recentPermits$Latitude,
                            colour = factor(recentPermits$Category),
                            size = sqrt(recentPermits$Value)),
                        data  = recentPermits,
                        alpha = .5, 
                        na.rm = TRUE)
