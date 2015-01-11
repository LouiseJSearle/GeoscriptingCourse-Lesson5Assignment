## Louise Searle
## January 10 2015
## Team Jennifer

## Load packages.
library(downloader)
library(sp)
library(rgdal)
library(rgeos)

## Load required data.

# Create directory to store data.
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

## Spatial analysis.

# Selects the industrial type railways.
ind <- railways[railways$type == "industrial",]

# Reproject places and industrial railways to RD.
projRD <- CRS("+proj=sterea +lat_0=52.15616055555555 +lon_0=5.38763888888889 +k=0.9999079 +x_0=155000 +y_0=463000 +ellps=bessel +towgs84=565.2369,50.0087,465.658,-0.406857330322398,0.350732676542563,-1.8703473836068,4.0812 +units=m +no_defs")
indRD <- spTransform(ind, projRD)
placesRD <- spTransform(places, projRD)

# Buffer the industrial railways with a buffer of 1000m.
indBuf <- gBuffer(indRD, byid=T, width=1000)

# Find the coordinates of the spatial points from Places that intersect with the buffer.
intPlace <- gIntersection(placesRD, indBuf, byid=T)
coord <- coordinates(intPlace)

# Match the coordinates of the intersected point with its corresponding point in the places dataset, and store the row position. 
for(i in 1:nrow(placesRD)){
     if((as.integer(placesRD@coords[i, 1]) == coord[1]) & (as.integer(placesRD@coords[i, 2]) == coord[2])) position <- i
}

# Extract the relevant data from places and store in spatial points data frame.
citydata <- data.frame(Name = placesRD$name[position], Population = placesRD$population[position])
cityspdata <- SpatialPointsDataFrame(coords = coord, citydata, proj4string=projRD, match.ID=F)

## Plot results.

# Create a plot that shows the buffer, the points, and the name of the city.
plot(indBuf, lty=2, lwd=1.5, col='snow2', axes=T)
box()
plot(cityspdata, cex=1.5, pch=19, col='violetred3', add=T)
mtext(side=3, "Exercise 5:\nIntroduction to Vector Handling in R", cex=1.1, line=1, adj=0)
mtext(side=1, "Longitude", line=2.5)
mtext(side=2, "Latitude", line=2.5)
text(cityspdata@coords, labels=as.character(cityspdata$Name), cex=1.1, font=2, pos=2, offset=0.8)

# Write down the name of the city and the population of that city as one comment at the end of the script.
print(paste('City :', cityspdata$Name))
print(paste('Population :', cityspdata$Population))
# 'City : Utrecht'
# 'Population : 100000'


