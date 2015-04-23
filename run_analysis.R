## use http instead of https
url <- "http://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
dataDir="data"

check.create.dir <- function(dir="data") {
    if (!file.exists(dir)) {
        dir.create(dir)
    }
}

check.create.dir(dir=dataDir)
outfile <- "human.activity.zip"
out.file <- paste(dataDir, outfile, sep="/")

if (!file.exists(out.file)){
    download.file(url, destfile=out.file, method = "curl")
}

## zip.df: all text files in archive
zip.df <- unzip(zipfile=out.file, list = TRUE)
zip.df <- zip.df[grep("txt$", zip.df$Name), ]

## zip.feature: name of features.txt in archive
zip.feature <- zip.df[grep("features.txt", zip.df$Name), "Name"]
## features: data frame (fn, Feature, name), 561 rows
features <- read.table(unz(out.file, zip.feature), header=F, col.names=c("fn", "Feature"))
features$name <- gsub("[-,()]+", "_", features$Feature)

## zip.activity: name of activity_labels.txt in archive
zip.activity <- zip.df[grep("activity_labels", zip.df$Name), "Name"]
## activity_labels: data frame containing the map between activity number (an) and its descrtipion (Activity) 
activity.labels <- read.table(unz(out.file, zip.activity), header=F, col.names=c("an", "Activity"))

## zip.subject.t*: name of subject_t* file in archive
zip.subject.test <- zip.df[grep("subject_test", zip.df$Name), "Name"]
zip.subject.train <- zip.df[grep("subject_train", zip.df$Name), "Name"]
## subject.test: 2947 obs, Subject number; subject.train has 7352 obs
subject.test <- read.table(unz(out.file, zip.subject.test), header=F, col.names="Subject")
subject.train <- read.table(unz(out.file, zip.subject.train), header=F, col.names="Subject")

## names of y_t*.txt files in archive
zip.y.test <- zip.df[grep("/y_test", zip.df$Name), "Name"]
zip.y.train <- zip.df[grep("/y_train", zip.df$Name), "Name"]
## y.test, 2947 activities, Y is converted into a factor using activity.labels$Activity
y.test <- read.table(unz(out.file, zip.y.test), header=F, col.names="Y")
y.train <- read.table(unz(out.file, zip.y.train), header=F, col.names="Y")

## names of x test and train files, read into 
zip.x.test <- zip.df[grep("X_test", zip.df$Name), "Name"]
zip.x.train <- zip.df[grep("X_train", zip.df$Name), "Name"]
x.test <- read.table(unz(out.file, zip.x.test), header=F, col.names=features$name)
x.train <- read.table(unz(out.file, zip.x.train), header=F, col.names=features$name)

## list of files in inertial directory
zip.inertial <- zip.df[grep("Inertial", zip.df$Name), ]
zip.inertial.test <- as.list(zip.inertial[grep("test", zip.inertial$Name), "Name"])
zip.inertial.train <- as.list(zip.inertial[grep("train", zip.inertial$Name), "Name"])

create.reading.df <- function(x, zip){
    # x should be a 128 col table
    xf <- sub("^.+/", "", x)
    xf <- sub("_(test|train)\\.txt", "", xf)
    cn <- paste(xf, 1:128, sep="_")
    tab <- read.table(unz(zip, x), header=F, col.names=cn)
    tab$nobs <- 1:nrow(tab)
    tab
}

## df.128.t* list of test and train data frames read from inertial
df.128.test <- lapply(zip.inertial.test, create.reading.df, zip=out.file)
df.128.train <- lapply(zip.inertial.train, create.reading.df, zip=out.file)

## add nobs to every data frame
subject.test$nobs <- 1:nrow(subject.test)
y.test$nobs <- 1:nrow(y.test)
x.test$nobs <- 1:nrow(x.test)
subject.train$nobs <- 1:nrow(subject.train)
y.train$nobs <- 1:nrow(y.train)
x.train$nobs <- 1:nrow(x.train)

## throw the inertial, subject, y and x frames into a list of 12 data frames
df.test <- c(df.128.test, list(subject.test, y.test, x.test))
df.train <- c(df.128.train, list(subject.train, y.train, x.train))

## 1. Merges the training and the test sets to create one data set
library(plyr)
test <- join_all(df.test)
train <- join_all(df.train)
df <- rbind(test, train)

## 2. extract mean and std measurements (create a string of variable names that contain _mean_ or _std_ used to extract the appropriate variables
features.mean.sd <- as.character(features[grep("_(mean|std)_", features$name), "name"])

## 3. use descriptive activity labels for activities in data frames
df$activity <- factor(df$Y, labels=activity.labels$Activity)

## 4. use descriptive labels (or variable names)
## this was done using col.names, saving an analysis data frame with activity, subject and the _mean_, _std_ variables
## NOTE: features$name is being used to name the _mean_ and _std_ variables
analysis <- df[, c("activity", "Subject", features.mean.sd)]

## 5. find the average of each variable (mean and std) for each activity and each subject
tidy <- aggregate(by=list(Activity=analysis$activity, Subject=analysis$Subject), FUN="mean", na.rm=TRUE, x=analysis[, features.mean.sd])

## names BodyBody -> Body
names.tidy <- names(tidy)
names.tidy <- sub("BodyBody", "Body", names.tidy)
names(tidy) <- names.tidy

## make long
library(reshape2)
## names.tidy[3:length(names.tidy)]
tidy.melt <- melt(tidy, id=c("Activity", "Subject"), measure.vars=names.tidy[3:length(names.tidy)])
## tf= t/f
tidy.melt$tf <- substr(tidy.melt$variable, start=1, stop=1)
## stat = mean/std
tidy.melt$stat <- sapply(strsplit(as.character(tidy.melt$variable), split="_"), "[[", 2)
## plane = X/Y/Z/N, N=none
tidy.melt$plane <- sub(".+_(.)?$", "\\1", tidy.melt$variable)
tidy.melt$plane <- sub("^$", "N", tidy.melt$plane)
## bodgrav = Body/Gravity
tidy.melt$bodgrav <- sub(".+?(Body|Gravity).+$", "\\1", tidy.melt$variable, perl=TRUE)
## Jerk = Jerk/
tidy.melt$Jerk <- grepl("Jerk", x=tidy.melt$variable)
## Mag = Mag/
tidy.melt$Mag <- grepl("Mag", x=tidy.melt$variable)
## Acc = Acc/
tidy.melt$Acc <- grepl("Acc", x=tidy.melt$variable)
## Gyro = Gryo/
tidy.melt$Gyro <- grepl("Gyro", x=tidy.melt$variable)

## gyroacc = Gyro/Acc
tidy.melt$gyroacc <- sub(".+?(Gyro|Acc).+$", "\\1", tidy.melt$variable, perl=TRUE)
tidy.melt$gyroacc[-which(tidy.melt$Jerk | tidy.melt$Mag)] <- " "
## jerk = Jerk
tidy.melt$jerk = as.character(" ")
tidy.melt$jerk[which(tidy.melt$Jerk & tidy.melt$Mag)] <- "Jerk"

## take out the t/f and then take out the mean/std
tidy.melt$Name <- sub("^.", "", tidy.melt$variable)
tidy.melt$Name <- sub("_(mean|std)_", "", tidy.melt$Name)

tidy.cast <- dcast(tidy.melt, Activity + Subject + tf + stat ~ Name)
names.cast <- names(tidy.cast)
names.cast[3:4] <- c("time_frequency", "Statistic")
names(tidy.cast) <- names.cast
write.table(tidy.cast, file="tidy.txt", row.names=FALSE)
