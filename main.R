## Louise Searle
## January 09 2015

## Load packages and functions.
library(downloader)
library(sp)
library(rgdal)

## Load required data.
dir.create('data/', showWarnings = FALSE)

# Download data.
download('http://www.mapcruzin.com/download-shapefile/netherlands-railways-shape.zip', "data/netherlands-railways-shape.zip", quiet = T, mode = "wb")
download('http://www.mapcruzin.com/download-shapefile/netherlands-places-shape.zip', "data/netherlands-places-shape.zip", quiet = T, mode = "wb")

# Unzip data.
unzip('data/netherlands-railways-shape.zip', exdir='data/railways/')
unzip('data/netherlands-places-shape.zip', exdir='data/places/')

# Select data.
railfile <- list.files('data/railways/', pattern=glob2rx('*.shp'), full.names=T)
placefile <- list.files('data/places/', pattern=glob2rx('*.shp*'), full.names=T)

# Load data. 
railways <- readOGR(railfile, layer=ogrListLayers(railfile))
places <- readOGR(placefile, layer=ogrListLayers(placefile))

# # Project data. ALREADY GOT PROJECTION!
# proj4string(railways) <- CRS("+proj=longlat +datum=WGS84")
# proj4string(places) <-CRS("+proj=longlat +datum=WGS84")

class(railways)


