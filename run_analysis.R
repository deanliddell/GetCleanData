# ------------------------------------------------------------------------------
# Getting and Cleaning Data Course Project
# ------------------------------------------------------------------------------
# The purpose  of  this  project is to demonstrate your ability to collect, work 
# with, and clean a data set. The  goal is to prepare tidy data that can be used 
# for later analysis. You  will  be  graded  by your peers on a series of yes/no 
# questions related to the project. You will be required  to  submit:  1) a tidy 
# data set as described below, 2) a link to a Github repository with your script 
# for performing the analysis, and 3) a code  book that describes the variables, 
# the data, and  any transformations or work that you  performed to clean up the 
# data called CodeBook.md.  You should also include a README.md in the repo with 
# your scripts. This repo  explains how all of the scripts work and how they are 
# connected. 
#
# One of the  most  exciting  areas in all of data science right now is wearable 
# computing - see for example this article .  Companies  like  Fitbit, Nike, and 
# Jawbone Up are racing to develop the most advanced algorithms to  attract  new 
# users.  The  data  linked  to from the course website represent data collected 
# from  the accelerometers from the Samsung  Galaxy  S  smartphone.  A full des-
# scription is available at the site where the data was obtained:
#  
# http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones
#
# Here are the data for the project:
#  
# https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
#
# You should create one R script called run_analysis.R that does the following. 
#
# 1) Merges the training and the test sets to create one data set.
#
# 2) Extracts only the measurements on the mean and standard deviation for each 
#    measurement.
#
# 3) Uses descriptive activity names to name the activities in the data set.
#
# 4) Appropriately labels the data set with descriptive variable names.
#
# 5) From the data set in step 4, creates a second, independent tidy data set 
#    with the average of each variable for each activity and each subject.
#

archiveUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
archiveFile <- basename(URLdecode(archiveUrl))

if (!(file.exists(archiveFile))) {
    # Download and Unzip the archive file containing the project data.
    #
    filePath <- file.path(getwd(), archiveFile)
    download.file(url = archiveUrl, destfile = filePath, method = "curl")
}

if (file.exists(archiveFile)) {
    archiveList <- unzip(archiveFile)
    #
    # NOTE: This instruction  assigns  a vector that contains an indexed list of
    # the fully-qualified file names in  the  archive file. You could mess about
    # trying to search this vector for the file index of interest, or  just  use
    # it here as documentation, and refer to it in any subsequent code.
    #
    # [ 1] "./UCI HAR Dataset/activity_labels.txt"                         
    # [ 2] "./UCI HAR Dataset/features.txt"                                
    # [ 3] "./UCI HAR Dataset/features_info.txt"                           
    # [ 4] "./UCI HAR Dataset/README.txt"                                  
    # [ 5] "./UCI HAR Dataset/test/Inertial Signals/body_acc_x_test.txt"   
    # [ 6] "./UCI HAR Dataset/test/Inertial Signals/body_acc_y_test.txt"   
    # [ 7] "./UCI HAR Dataset/test/Inertial Signals/body_acc_z_test.txt"   
    # [ 8] "./UCI HAR Dataset/test/Inertial Signals/body_gyro_x_test.txt"  
    # [ 9] "./UCI HAR Dataset/test/Inertial Signals/body_gyro_y_test.txt"  
    # [10] "./UCI HAR Dataset/test/Inertial Signals/body_gyro_z_test.txt"  
    # [11] "./UCI HAR Dataset/test/Inertial Signals/total_acc_x_test.txt"  
    # [12] "./UCI HAR Dataset/test/Inertial Signals/total_acc_y_test.txt"  
    # [13] "./UCI HAR Dataset/test/Inertial Signals/total_acc_z_test.txt"  
    # [14] "./UCI HAR Dataset/test/subject_test.txt"                       
    # [15] "./UCI HAR Dataset/test/X_test.txt"                             
    # [16] "./UCI HAR Dataset/test/y_test.txt"                             
    # [17] "./UCI HAR Dataset/train/Inertial Signals/body_acc_x_train.txt" 
    # [18] "./UCI HAR Dataset/train/Inertial Signals/body_acc_y_train.txt" 
    # [19] "./UCI HAR Dataset/train/Inertial Signals/body_acc_z_train.txt" 
    # [20] "./UCI HAR Dataset/train/Inertial Signals/body_gyro_x_train.txt"
    # [21] "./UCI HAR Dataset/train/Inertial Signals/body_gyro_y_train.txt"
    # [22] "./UCI HAR Dataset/train/Inertial Signals/body_gyro_z_train.txt"
    # [23] "./UCI HAR Dataset/train/Inertial Signals/total_acc_x_train.txt"
    # [24] "./UCI HAR Dataset/train/Inertial Signals/total_acc_y_train.txt"
    # [25] "./UCI HAR Dataset/train/Inertial Signals/total_acc_z_train.txt"
    # [26] "./UCI HAR Dataset/train/subject_train.txt"                     
    # [27] "./UCI HAR Dataset/train/X_train.txt"                           
    # [28] "./UCI HAR Dataset/train/y_train.txt"               }
} else {
    stop("The project archive file is missing and was not downloaded by this
         script. Download manually and restart this script.", call. = FALSE)
}

# ------------------------------------------------------------------------------
# B E G I N   D A T A S E T
# ------------------------------------------------------------------------------
# To the extent possible we want to use the "dplyr" package over base R notation
# to perform  our  data operations. (This is also preferable to using the 'data.
# table' package.) So, we  need  to be  sure we have the  package and that it is
# loaded in our namespace.

if (!("dplyr" %in% installed.packages())) {
    message("One moment... need to install \"dplyr\" package.")
    install.packages("dplyr", quiet = TRUE)
}

if (!("dplyr" %in% loadedNamespaces())) {
    library(dplyr, quietly = TRUE)
}

# ------------------------------------------------------------------------------
# S M A R T P H O N E   F E A T U R E   S E T
# ------------------------------------------------------------------------------
# Smartphone accelerometer and gyroscope features (a set of 561).

message("Reading in \"features\" table.")
features <- read.table(archiveList[2], colClasses = "character", 
                      col.names = c("featureId","featureType"))

# ------------------------------------------------------------------------------
# E X P E R I M E N T   A C T I V I T I E S
# ------------------------------------------------------------------------------
# Activities performed by experiment volunteers (a set of 6).

message("Reading in \"activity_labels\" table.")
activityLabels <- read.table(archiveList[1], colClasses = "character", 
                             col.names = c("activityClass","activityName"))

# ------------------------------------------------------------------------------
# T R A I N I N G   D A T A
# ------------------------------------------------------------------------------
# The  data  is  not  normalized. It just appears to be separated into different
# files. Rather than creating multiple objects and later  binding them together,
# we can shorten the process  of  reconstituting  the  data  (according  to  the 
# README.txt instructions)  by  column-appending data on  consecutive reads. The
# result will be "these smartphone features (561) detected this subject (1) per-
# forming this activity (1). The overal set is 7352 records.

message("Reading in \"X_train\" table (as training).")
training <- read.table(archiveList[27], col.names = features[,"featureType"])

message("Reading in \"Y_train\" table (column-appending to training).")
training[,562] <- read.table(archiveList[28], colClasses = c("character"),
                     col.names = c("activityClass"))

message("Reading in \"subject_train\" table (column-appending to training).")
training[,563] <- read.table(archiveList[26], colClasses = "character", 
                           col.names = c("subjectId"))

# ------------------------------------------------------------------------------
# T E S T I N G   D A T A
# ------------------------------------------------------------------------------
# Like the 'training data' above, we  can  reconstitute  the data set by column-
# appending consequtive data reads,  such that "these  smartphone features (561)
# detected this  test subject (1)  performing this activity (1) during this test
# run. THe overall set is 2947 records.

message("Reading in \"X_test\" table (as testing).")
testing <- read.table(archiveList[15], col.names = features[,"featureType"])

message("Reading in \"Y_test\" table (column-appending to testing).")
testing[,562] <- read.table(archiveList[16], colClasses = c("character"),
                            col.names = c("activityClass"))

message("Reading in \"subject_test\" table (column-appending to testing).")
testing[,563] <- read.table(archiveList[14], colClasses = c("character"),
                            col.names = c("subjectId"))

# ------------------------------------------------------------------------------
# C O M B I N E  -  R E D U C E  -  E X T R A C T   D A T A
# ------------------------------------------------------------------------------
# 1) Merges the training and the test sets to create one data set.
#       UNION(TABLE,TABLE) %>%
#
# 2) Extracts only the measurements on the mean and standard deviation for each 
#    measurement.
#       SELECT(MATCHES(REGEXP,IGNORE.CASE=TRUE)) %>
#
# 3) Uses descriptive activity names to name the activities in the data set.
#       LEFT_JOIN(TABLE,TABLE,BY=ACTIVITYCLASS) %>%
#

df <- union(training, testing) %>%
        select(matches("mean|std|activityClass|subjectId",ignore.case = TRUE)) %>%
            left_join(activityLabels, by = c("activityClass")) %>%
                select(-activityClass)

# 4) Appropriately labels the data set with descriptive variable names.
#       NAMES(DF) <- GSUB(REGEXP,NAMES(DF))
#
names(df) <- gsub("[Mm]ean","Mean",names(df))
names(df) <- gsub("[Ss]td","StdDev",names(df))
names(df) <- gsub("\\.\\.\\.","_",names(df))
names(df) <- gsub("\\.\\.","",names(df))
names(df) <- gsub("\\.$)","",names(df))
names(df) <- gsub("[Gg]ravity","Gravity",names(df))
names(df) <- gsub("[Bb]ody[Bb]ody|[Bb]ody","Body",names(df))

# ------------------------------------------------------------------------------
# O U T P U T   T I D Y   D A T A
# ------------------------------------------------------------------------------
# 5) From the data set in step 4, creates a second,  independent  tidy  data set 
#    with the average of each variable for each activity and each subject.
#
tidyData <- df %>%
        group_by(activityName,subjectId) %>%
            summarise_each(funs(mean))

# NOTE: the 'subjectId' group comes out in ASCII sequence.  The  'dplyr' command
# arrange(tidyData,activityName,(as.numeric(subjectId))) will output the correct
# result to the console but will not save this ordering in  the  data.frame.  We
# would have  to convert (mutate) our categorical data (subjectId) to numeric to
# get the correct sort order, though as categorical data we don't expect to add,
# multiply, or divide the subjects, so numeric data type is questionable.
#
# Write the 'tidyData' table to the working directory.
#
write.table(tidyData, "./tidyData.txt", row.names = FALSE)

# ------------------------------------------------------------------------------
# E P I L O G U E
# ------------------------------------------------------------------------------
# To execute this script in its  entirety  (no  data files present; however with 
# the  dplyr  package installed) on a Windows 7 machine with a fast downlink re-
# sults in the following timing:
#
#  user  system elapsed 
# 24.71   00.52   31.42
