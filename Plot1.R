source("downloading_data.R")

# Load the NEI & SCC data frames
NEI <- readRDS("summarySCC_PM25.rds")
SCC <- readRDS("Source_Classification_Code.rds")

# Aggregate by sum the total emissions by year
total_annual_emissions <- aggregate(Emissions ~ year, NEI, FUN = sum)

png("Plot1.png",width=480,height=480,units="px",bg="transparent")

with(total_annual_emissions, 
     barplot(height=Emissions/1000, names.arg = year, col = c(2:5), 
             xlab = "Year", ylab = expression('PM'[2.5]*' in Kilotons'),
             main = expression('Annual Emission PM'[2.5]*' from 1999 to 2008')))

dev.off()