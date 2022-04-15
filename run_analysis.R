install.packages("tidyverse")
library(tidyverse)
library(data.table)
library(dplyr)


# 1 - Download & Unzip Dataset

url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"  
dataset <- c("dataset.zip")
download.file(url,destfile=dataset,mode='wb')
unzip(zipfile="./dataset.zip")

# 2 - Import Datasets

# Descriptions
features <- read.table("UCI HAR Dataset/features.txt",col.names=c("n","measure"))
activities <- read.table("UCI HAR Dataset/activity_labels.txt",col.names=c("code","activity"))
# Training Data
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt", col.names = "subject")
x_train <- read.table("UCI HAR Dataset/train/X_train.txt", col.names = features$measure)
y_train <- read.table("UCI HAR Dataset/train/y_train.txt", col.names = "code")
# Test Data
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt", col.names = "subject")
x_test <- read.table("UCI HAR Dataset/test/X_test.txt" , col.names = features$measure)
y_test <- read.table("UCI HAR Dataset/test/y_test.txt" , col.names = "code")

# 3 - Combine Datasets

# Bind Columns for Training & Test Sets
data_train <- bind_cols(subject_train,y_train,x_train)
data_test <- bind_cols(subject_test,y_test,x_test)
# Bind Training and Test Sets
data_all <- bind_rows(data_train,data_test)

# 4 - Subset & Transform Data

# Create data subset
data_tidy <- data_all %>% select (subject,code,contains("mean"),contains("std"))
# Create vector of column names
untidy_names <- colnames(data_tidy)

# Transform column Names
names(data_tidy) <- gsub("BodyBody","Body",names(data_tidy))
names(data_tidy) <- gsub("tBodyAcc","Time Body Accelerometer",names(data_tidy))
names(data_tidy) <- gsub("fBodyAcc","Frequency Body Accelerometer",names(data_tidy))
names(data_tidy) <- gsub("tGravityAcc","Time Gravity Accelerometer",names(data_tidy))
names(data_tidy) <- gsub("tBodyGyro","Time Body Gyroscope",names(data_tidy))
names(data_tidy) <- gsub("fBodyGyro","Frequency Body Gyroscope",names(data_tidy))

names(data_tidy) <- gsub(".mean...X"," Mean(X)",names(data_tidy))
names(data_tidy) <- gsub(".mean...Y"," Mean(Y)",names(data_tidy))
names(data_tidy) <- gsub(".mean...Z"," Mean(Z)",names(data_tidy))
names(data_tidy) <- gsub(".meanFreq...X"," Weighted Mean(X)",names(data_tidy))
names(data_tidy) <- gsub(".meanFreq...Y"," Weighted Mean(Y)",names(data_tidy))
names(data_tidy) <- gsub(".meanFreq...Z"," Weighted Mean(Z)",names(data_tidy))
names(data_tidy) <- gsub(".std...X"," Standard Deviation(X)",names(data_tidy))
names(data_tidy) <- gsub(".std...Y"," Standard Deviation(Y)",names(data_tidy))
names(data_tidy) <- gsub(".std...Z"," Standard Deviation(Z)",names(data_tidy))
names(data_tidy) <- gsub("angle.X.gravityMean.","Angle(X) Gravity Mean",names(data_tidy))
names(data_tidy) <- gsub("angle.Y.gravityMean.","Angle(Y) Gravity Mean",names(data_tidy))
names(data_tidy) <- gsub("angle.Z.gravityMean.","Angle(Z) Gravity Mean",names(data_tidy))

names(data_tidy) <- gsub("Mag.std.."," Mag Standard Deviation",names(data_tidy))
names(data_tidy) <- gsub("Mag","Magnitude",names(data_tidy))
names(data_tidy) <- gsub("Jerk"," Jerk",names(data_tidy))
names(data_tidy) <- gsub("AccelerometerMagnitude.mean..","Accelerometer Magnitude Mean",names(data_tidy))
names(data_tidy) <- gsub("JerkMagnitude.mean..","Jerk Magnitude Mean",names(data_tidy))
names(data_tidy) <- gsub("fBodyGyroMagnitude","Frequency Body Gyroscope Magnitude",names(data_tidy))
names(data_tidy) <- gsub("Meaneq..","Weighted Mean",names(data_tidy))
names(data_tidy) <- gsub("Magnitude.mean..","Magnitude Mean",names(data_tidy))
names(data_tidy) <- gsub("Meaneq..","Weighted Mean",names(data_tidy))

# Create copy of new column names
tidy_names <- colnames(data_tidy)
# Reference of old names / new names
name_changes <- tibble(untidy_names,tidy_names)

# Table of Variable Names
library(knitr)
kable(name_changes,caption="Variable Names")

# 5 - Create final dataset

# Final Dataset
data_final <- data_tidy %>%
        group_by(subject,code) %>%
        summarize_all(mean)
        
# Swap Code for Activity description
data_final$code <- activities[match(data_final$code,activities$code), ]$activity
data_final <- data_final %>% rename(Activity=code)

# Write txt file from summary
write.table(data_final, file = "Tidy.txt", row.names = FALSE)



