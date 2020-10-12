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