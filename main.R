## Louise Searle
## January 09 2015

## Load packages and functions.
library(downloader)
library(sp)
library(rgdal)
library(rgeos)

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

# Selects the industrial type railways.
ind <- railways[railways$type == "industrial",]

# Reproject places and industrial railways to RD.
indRD <- spTransform(ind, CRS("+proj=sterea +lat_0=52.15616055555555 +lon_0=5.38763888888889 +k=0.9999079 +x_0=155000 +y_0=463000 +ellps=bessel +towgs84=565.2369,50.0087,465.658,-0.406857330322398,0.350732676542563,-1.8703473836068,4.0812 +units=m +no_defs"))
placesRD <- spTransform(places, CRS("+proj=sterea +lat_0=52.15616055555555 +lon_0=5.38763888888889 +k=0.9999079 +x_0=155000 +y_0=463000 +ellps=bessel +towgs84=565.2369,50.0087,465.658,-0.406857330322398,0.350732676542563,-1.8703473836068,4.0812 +units=m +no_defs"))

# Buffer the industrial railways with a buffer of 1000m.
indBuf <- gBuffer(indRD, byid=T, width=1000)

# Find the coordinates of the spatial point from Places that intersects with the buffer.
intPlace <- gIntersection(placesRD, indBuf, byid=T)
x <- as.integer(coordinates(intPlace)[1])
y <- as.integer(coordinates(intPlace)[2])

# Extract the data for the point at these coordinates from Places.
for(i in 1:nrow(placesRD)){
     if((as.integer(placesRD@coords[i, 1]) == x) & (as.integer(placesRD@coords[i, 2]) == y)) position <- i
}

# match(x, c(as.integer(placesRD@coords[i,1]), as.integer(placesRD@coords[i,2])), nomatch = NA)
# Find location of corresponding point in Places data frame to retrieve point data.
# match <- CorrPoints(intPlace, placesRD)
# city <- placesRD@data[match[2]]

# Create a plot that shows the buffer, the points, and the name of the city.
spplot()

# Write down the name of the city and the population of that city as one comment at the end of the script.
print('City :', city[2])
print('Population :', city[4])

# 'City : Utrecht'
# 'Population : '


