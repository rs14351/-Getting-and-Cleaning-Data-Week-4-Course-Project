## Show current directory
getwd()

## Configure the directory where the file is

setwd("C:/Users/rs14351/Desktop/TRACE/Coursera/Modulo 3/Week 4")

## Installing the packages

install.packages("dplyr")
install.packages("data.table")

## Run the packages

library(dplyr)
library(data.table)

## Input UCI HAR Dataset downloaded from https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
## #Download UCI data files from the web, unzip them, and specify time/date settings

URL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
destFile <- "CourseDataset.zip"
if (!file.exists(destFile)){
        download.file(URL, destfile = destFile, mode='wb')
}
if (!file.exists("./UCI_HAR_Dataset")){
        unzip(destFile)
}
dateDownloaded <- date()

## Read the file in the directory

setwd("./UCI_HAR_Dataset")

##At this point the code will read the files in the folder

## File 1 - Activity files

ActivityTest <- read.table("./test/y_test.txt", header = F)
ActivityTrain <- read.table("./train/y_train.txt", header = F)

## File 2 - Features files

FeaturesTest <- read.table("./test/X_test.txt", header = F)
FeaturesTrain <- read.table("./train/X_train.txt", header = F)

## File 3 - Subject files

SubjectTest <- read.table("./test/subject_test.txt", header = F)
SubjectTrain <- read.table("./train/subject_train.txt", header = F)

## File 4 - Activity Labels

ActivityLabels <- read.table("./activity_labels.txt", header = F)

## File 5 - Feature Names

FeaturesNames <- read.table("./features.txt", header = F)

## Merge the training and the test sets to create just one data set

FeaturesData <- rbind(FeaturesTest, FeaturesTrain)
SubjectData <- rbind(SubjectTest, SubjectTrain)
ActivityData <- rbind(ActivityTest, ActivityTrain)

## Renaming colums and get factor of Activity names

names(ActivityData) <- "ActivityN"
names(ActivityLabels) <- c("ActivityN", "Activity")
Activity <- left_join(ActivityData, ActivityLabels, "ActivityN")[, 2]
names(SubjectData) <- "Subject"
names(FeaturesData) <- FeaturesNames$V2

##Create one large Dataset with the variables 'SubjectData', 'Activity' and 'FeaturesData'

DataSet <- cbind(SubjectData, Activity)
DataSet <- cbind(DataSet, FeaturesData)

## Create a new data set using only the mean and standard deviation

subFeaturesNames <- FeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", FeaturesNames$V2)]
DataNames <- c("Subject", "Activity", as.character(subFeaturesNames))
DataSet <- subset(DataSet, select=DataNames)

## Rename the columns using descriptive activity names

names(DataSet)<-gsub("^t", "time", names(DataSet))
names(DataSet)<-gsub("^f", "frequency", names(DataSet))
names(DataSet)<-gsub("Acc", "Accelerometer", names(DataSet))
names(DataSet)<-gsub("Gyro", "Gyroscope", names(DataSet))
names(DataSet)<-gsub("Mag", "Magnitude", names(DataSet))
names(DataSet)<-gsub("BodyBody", "Body", names(DataSet))

## Creates a second, independent tidy data set with the average of each variable for each activity and each subject

SecondDataSet<-aggregate(. ~Subject + Activity, DataSet, mean)
SecondDataSet<-SecondDataSet[order(SecondDataSet$Subject,SecondDataSet$Activity),]

## Export tidyData set 

write.table(SecondDataSet, file = "tidydata.txt",row.name=FALSE)
