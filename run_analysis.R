# SCRIPT run_analysis.R

## 0. Loading and preprocessing the data
urlData <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
fileData <- "getdata-projectfiles-UCI HAR Dataset.zip"
download.file(url = urlData, destfile = fileData, method = "curl")
unzip(fileData)


## 1. Merges the training and the test sets to create one data set.
### build filepaths, read files and combine dataframes by my order
dataDir <- file.path(getwd(), "UCI HAR Dataset")
myOrder <- c("subject", "y", "X") # my order for the columns
DF <- do.call(rbind, lapply(c("test","train"), FUN = function(dType){ do.call(cbind, lapply(file.path(dataDir, dType, paste(myOrder, "_", dType, ".txt", sep = "")), FUN = read.table)) } ))
### More descriptive names for the 3 + 561 = 563 columns
names(DF) <- c("SUBJECT_ID","ACTIVITY_ID", read.table(file.path(dataDir,"features.txt"), stringsAsFactors = FALSE)[[2]])


## 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
theMeasurements <- grep(pattern = "-mean\\(|-std\\(", x = names(DF), value =  FALSE)
DF2 <- DF[, c(1, 2, theMeasurements) ] # and columns SUBJECT_ID & ACTIVITY_ID


## 3. Uses descriptive activity names to name the activities in the data set
activities <- read.table(file.path(dataDir,"activity_labels.txt"), stringsAsFactors = FALSE, col.names = c("ACTIVITY_ID", "ACTIVITY"))
DF3 <- merge(x = activities, y = DF2, by = "ACTIVITY_ID")

## 4. Appropriately labels the data set with descriptive variable names. 
ACTNAMES <- names(DF3)
ACTNAMES <- sub("^t", replacement = "TIME_", x = ACTNAMES)
ACTNAMES <- sub("^f", replacement = "FREQUENCY_", x = ACTNAMES)
ACTNAMES <- sub("BodyBody|Body", replacement = "BODY_", x = ACTNAMES)
ACTNAMES <- sub("Gravity", replacement = "GRAVITY_", x = ACTNAMES)
ACTNAMES <- sub("\\(\\)", replacement = "", x = ACTNAMES)
ACTNAMES <- sub("Acc", replacement = "ACCELERATION_", x = ACTNAMES)
ACTNAMES <- sub("Jerk", replacement = "JERK_", x = ACTNAMES)
ACTNAMES <- sub("Mag", replacement = "MAGNITUDE_", x = ACTNAMES)
ACTNAMES <- sub("Gyro", replacement = "ANGULAR_VELOCITY_", x = ACTNAMES)
ACTNAMES <- sub("-mean", replacement = "MEAN", x = ACTNAMES)
ACTNAMES <- sub("-std", replacement = "STD", x = ACTNAMES)
ACTNAMES <- sub("-", replacement = "_", x = ACTNAMES)
names(DF3) <- ACTNAMES

# 5. From the data set in step 4, creates a second, independent tidy data set 
# with the average of each variable for each activity and each subject.
DF5 <- DF3
DF5$ACTIVITY_ID <- NULL  # remove unnecesary column
DF5 <- transform(DF5, SUBJECT_ID = factor(SUBJECT_ID)) # column is really of factor type
DF5 <- transform(DF5, ACTIVITY = factor(ACTIVITY)) # column is really of factor type
DF6 <- aggregate(. ~ ACTIVITY + SUBJECT_ID, DF5, FUN = mean) # tidy data set
write.table(x = DF6, file = "step5_dataset.txt", row.names = FALSE)
