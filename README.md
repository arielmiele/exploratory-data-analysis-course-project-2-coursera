Exploratory Data Analysis - Course Project 2
================

## Introduction

Fine particulate matter (PM2.5) is an ambient air pollutant for which
there is strong evidence that it is harmful to human health. In the
United States, the Environmental Protection Agency (EPA) is tasked with
setting national ambient air quality standards for fine PM and for
tracking the emissions of this pollutant into the atmosphere.
Approximatly every 3 years, the EPA releases its database on emissions
of PM2.5. This database is known as the National Emissions Inventory
(NEI). You can read more information about the NEI at the EPA National
Emissions Inventory web site.

For each year and for each type of PM source, the NEI records how many
tons of PM2.5 were emitted from that source over the course of the
entire year. The data that you will use for this assignment are for
1999, 2002, 2005, and 2008.

## Data

The data for this assignment are available from the course web site as a
single zip file. The zip file contains two files:

PM2.5 Emissions Data (summarySCC\_PM25.rds): This file contains a data
frame with all of the PM2.5 emissions data for 1999, 2002, 2005, and
2008. For each year, the table contains number of tons of PM2.5 emitted
from a specific type of source for the entire year.

* fips: A five-digit number (represented as a string) indicating the U.S. county 
* SCC: The name of the source as indicated by a digit string (see source code classification table) 
* Pollutant: A string indicating the pollutant
* Emissions: Amount of PM2.5 emitted, in tons type: The type of source (point, non-point, on-road, or non-road) 
* year: The year of emissions recorded

Source Classification Code Table (Source\_Classification\_Code.rds):
This table provides a mapping from the SCC digit strings in the
Emissions table to the actual name of the PM2.5 source. The sources are
categorized in a few different ways from more general to more specific
and you may choose to explore whatever categories you think are most
useful. For example, source “10100101” is known as “Ext Comb /Electric
Gen /Anthracite Coal /Pulverized Coal”.

You can read each of the two files using the readRDS() function in R.

## Making and Submitting Plots

For each plot you should

  - Construct the plot and save it to a PNG file.
  - Create a separate R code file (plot1.R, plot2.R, etc.) that
    constructs the corresponding plot, i.e. code in plot1.R constructs
    the plot1.png plot. Your code file should include code for reading
    the data so that the plot can be fully reproduced. You must also
    include the code that creates the PNG file. Only include the code
    for a single plot (i.e. plot1.R should only include code for
    producing plot1.png)
  - Upload the PNG file on the Assignment submission page
  - Copy and paste the R code from the corresponding R file into the
    text box at the appropriate point in the peer assessment.
    
We first download the data:

```{r}
# Verifies if the file exists, if not downloads the archive file
filename <- "exdata-data-NEI_data.zip"

if (!file.exists(filename)) {
  downloadurl <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip"
  download.file(downloadurl, destfile = filename)
  unzip (zipfile = filename)
}

if (!exists("NEI")) {
  NEI <- readRDS("summarySCC_PM25.rds") 
}

if (!exists("SCC")) {
  SCC <- readRDS("Source_Classification_Code.rds")
}
```

## Assignment

The overall goal of this assignment is to explore the National Emissions
Inventory database and see what it say about fine particulate matter
pollution in the United states over the 10-year period 1999–2008. You
may use any R package you want to support your analysis.

Questions You must address the following questions and tasks in your
exploratory analysis. For each question/task you will need to make a
single plot. Unless specified, you can use any plotting system in R to
make your plot.

1.  Have total emissions from PM2.5 decreased in the United States from
    1999 to 2008? Using the base plotting system, make a plot showing
    the total PM2.5 emission from all sources for each of the years
    1999, 2002, 2005, and 2008.

```{r}
total_annual_emissions <- aggregate(Emissions ~ year, NEI, FUN = sum)
with(total_annual_emissions, 
     barplot(height=Emissions/1000, names.arg = year, col = c(2:5), 
             xlab = "Year", ylab = expression('PM'[2.5]*' in Kilotons'),
             main = expression('Annual Emission PM'[2.5]*' from 1999 to 2008')))
```

2.  Have total emissions from PM2.5 decreased in the Baltimore City,
    Maryland (fips == “24510”) from 1999 to 2008? Use the base plotting
    system to make a plot answering this question.

```{r}
# Subset NEI data by Baltimore's fip.
baltimoreNEI <- NEI[NEI$fips=="24510",]

# Aggregate using sum the Baltimore emissions data by year
aggTotalsBaltimore <- aggregate(Emissions ~ year, baltimoreNEI,sum)

png("plot2.png",width=480,height=480,units="px",bg="transparent")

with(aggTotalsBaltimore,
     barplot(height=Emissions/1000, names.arg = year, col = c(3:6), 
             xlab = "Year", ylab = expression('PM'[2.5]*' in Kilotons'),
             main = expression('Baltimore, Maryland Emissions from 1999 to 2008'))
)
```

3.  Of the four types of sources indicated by the type (point, nonpoint,
    onroad, nonroad) variable, which of these four sources have seen
    decreases in emissions from 1999–2008 for Baltimore City? Which have
    seen increases in emissions from 1999–2008? Use the ggplot2 plotting
    system to make a plot answer this question.

```{r}
# Subset NEI data by Baltimore's fip.
baltimoreNEI <- NEI[NEI$fips=="24510",]

# Aggregate using sum the Baltimore emissions data by year
aggTotalsBaltimore <- aggregate(Emissions ~ year, baltimoreNEI,sum)

png("plot3.png",width=480,height=480,units="px",bg="transparent")

library(ggplot2)

ggp <- ggplot(baltimoreNEI,aes(factor(year),Emissions,fill=type)) +
  geom_bar(stat="identity") +
  guides(fill=FALSE)+
  facet_grid(.~type,scales = "free",space="free") + 
  labs(x="year", y=expression("Total PM"[2.5]*" Emission (Tons)")) + 
  labs(title=expression("PM"[2.5]*" Emissions, Baltimore City 1999-2008 by Source Type"))

print(ggp)
```

4.  Across the United States, how have emissions from coal
    combustion-related sources changed from 1999–2008?
    
```{r}
# Subset coal combustion related NEI data
combustionRelated <- grepl("comb", SCC$SCC.Level.One, ignore.case=TRUE)
coalRelated <- grepl("coal", SCC$SCC.Level.Four, ignore.case=TRUE) 
coalCombustion <- (combustionRelated & coalRelated)
combustionSCC <- SCC[coalCombustion,]$SCC
combustionNEI <- NEI[NEI$SCC %in% combustionSCC,]

png("plot4.png",width=480,height=480,units="px",bg="transparent")

library(ggplot2)

ggp <- ggplot(combustionNEI,aes(factor(year),Emissions/10^5)) +
  geom_bar(stat="identity",fill="grey",width=0.75) +
  guides(fill=FALSE) +
  labs(x="year", y=expression("Total PM"[2.5]*" Emission (10^5 Tons)")) + 
  labs(title=expression("PM"[2.5]*" Coal Combustion Source Emissions Across US from 1999-2008"))

print(ggp)
```

5.  How have emissions from motor vehicle sources changed from 1999–2008
    in Baltimore City?

```{r}
# Gather the subset of the NEI data which corresponds to vehicles
vehicles <- grepl("vehicle", SCC$SCC.Level.Two, ignore.case=TRUE)
vehiclesSCC <- SCC[vehicles,]$SCC
vehiclesNEI <- NEI[NEI$SCC %in% vehiclesSCC,]

# Subset the vehicles NEI data to Baltimore's fip
baltimoreVehiclesNEI <- vehiclesNEI[vehiclesNEI$fips=="24510",]

png("plot5.png",width=480,height=480,units="px",bg="transparent")

library(ggplot2)

ggp <- ggplot(baltimoreVehiclesNEI,aes(factor(year),Emissions)) +
  geom_bar(stat="identity",fill="grey",width=0.75) +
  guides(fill=FALSE) +
  labs(x="year", y=expression("Total PM"[2.5]*" Emission (10^5 Tons)")) + 
  labs(title=expression("PM"[2.5]*" Motor Vehicle Source Emissions in Baltimore from 1999-2008"))

print(ggp)
```

6.  Compare emissions from motor vehicle sources in Baltimore City with
    emissions from motor vehicle sources in Los Angeles County,
    California (fips == “06037”). Which city has seen greater changes
    over time in motor vehicle emissions?

```{r}
# Gather the subset of the NEI data which corresponds to vehicles
vehicles <- grepl("vehicle", SCC$SCC.Level.Two, ignore.case=TRUE)
vehiclesSCC <- SCC[vehicles,]$SCC
vehiclesNEI <- NEI[NEI$SCC %in% vehiclesSCC,]

# Subset the vehicles NEI data by each city's fip and add city name.
vehiclesBaltimoreNEI <- vehiclesNEI[vehiclesNEI$fips=="24510",]
vehiclesBaltimoreNEI$city <- "Baltimore City"

vehiclesLANEI <- vehiclesNEI[vehiclesNEI$fips=="06037",]
vehiclesLANEI$city <- "Los Angeles County"

# Combine the two subsets with city name into one data frame
bothNEI <- rbind(vehiclesBaltimoreNEI,vehiclesLANEI)

png("plot6.png",width=480,height=480,units="px",bg="transparent")

library(ggplot2)

ggp <- ggplot(bothNEI, aes(x=factor(year), y=Emissions, fill=city)) +
  geom_bar(aes(fill=year),stat="identity") +
  facet_grid(scales="free", space="free", .~city) +
  guides(fill=FALSE) + 
  labs(x="year", y=expression("Total PM"[2.5]*" Emission (Kilo-Tons)")) + 
  labs(title=expression("PM"[2.5]*" Motor Vehicle Source Emissions in Baltimore & LA, 1999-2008"))

print(ggp)
```
