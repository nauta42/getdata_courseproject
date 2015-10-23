# get_data.R

## download and unzip the data set
urlData <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
fileData <- "getdata-projectfiles-UCI HAR Dataset.zip"
download.file(url = urlData, destfile = fileData, method = "curl")
unzip(fileData)
file.path(getwd(), "UCI HAR Dataset") # print info about the data set directory
