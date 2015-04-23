Code Book

The tidy data frame contains 720 observations and 24 variables.

The variables are

* Identifiers
Activity         factor indicating type of activity: WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING
Subject          An identifier of the subject who carried out the experiment
time_frequency   indicates whether the measurement is a time domain signal (t) or a frequency domain signal (f)
Statistic        indicates whether the measurement is a mean or standard deviation (std)

* Acceleration Measures 
GravityAccX      Gravity Acceleration Signal in the X-plane
GravityAccY	 Gravity Acceleration Signal in the Y-plane
GravityAccZ    	 Gravity Acceleration Signal in the Z-plane
BodyAccX         Body Linear Acceleration Signal in the X-plane
BodyAccY         Body Linear Acceleration Signal in the Y-plane
BodyAccZ         Body Linear Acceleration Signal in the Z-plane

* Angular Velocity
BodyGyroX        Body Angular Velocity Signal in the X-plane
BodyGyroY        Body Angular Velocity Signal in the Y-plane
BodyGyroZ        Body Angular Velocity Signal in the Z-plane

* Jerk (acceleration of)
BodyAccJerkX     Body Linear Acceleration Signal in the X-plane 
BodyAccJerkY     Body Linear Acceleration Signal in the Y-plane 
BodyAccJerkZ     Body Linear Acceleration Signal in the Z-plane 
BodyGyroJerkX    Angular Velocity Signal in the X-plane
BodyGyroJerkY    Angular Velocity Signal in the Y-plane
BodyGyroJerkZ    Angular Velocity Signal in the Z-plane

* Magnitude (measured as a Euclidan Norm) of
GravityAccMag    Gravity Acceleration Signal
BodyAccMag       Body Linear Acceleration Signal
BodyGyroMag      Body Angular Velocity Signal
BodyAccJerkMag   Jerk of Body Linear Acceleration Signal
BodyGyroJerkMag  Jerk of Body Angular Velocity Signal

Summary Choices or how the dataset was created

Download the Raw data from https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip. It contains a partitioned sample (test and train); then for each partition

 - use the values in the features.txt file to label each of the measures
 - use the values in the activity_labels.txt file to label the activity code (Y in the raw data)
 - load the subject_t*.txt files which contain the subject associated with each observation
 - load the x_t*.txt files which contain the a 561-feature vector with time and frequency domain variables
 - load the body_*t*.txt and total_*t*.txt files 
 - merge test data files by observation number, repeat for train data files
 - extract the variables whose names contain mean and std variables. NOTE: only the statistics containing -mean() were used. Other measures contained the string mean but for this study, I limited the scope to use only -mean() and not -meanFreq(). 
 - label activity codes
 - create the analysis data frame by stacking the test and train samples and extracting only the standard deviation and mean statistics
 - use aggregate to create a data frame containing the average values by activity and suject
 - revise the names of variables containing the string "BodyBody" to "Body"; the original name did not match the labels in the features.info file
 - melt the dataset by Activity and Subject
 - identify time/frequency and Statistic (mean/std)
 - re-cast the dataset by Activity, Subject, time/frequency, Statistic for each of the acceleration, angular velocity, jerk and magnitude measures
 - output the data set to file

NOTE: Conceivably the dataset could have been re-cast to output only Accleration, Angular Velocity, Jerk and Magnitude variables which would be labeled by other variables to identify whether the observation is Gravity or Body Linear Accelaration, etc. Since a unit can be compound, i.e. acceleration along the x-axis, and that I am not familiar with how physicists like to define their units in datasets, I chose to use time/frequency and statistic as observation identifiers. 

Experimental Study Design

from http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

The experiments have been carried out with a group of 30 volunteers within an age bracket of 19-48 years. Each person performed six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a smartphone (Samsung Galaxy S II) on the waist. Using its embedded accelerometer and gyroscope, we captured 3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz. The experiments have been video-recorded to label the data manually. The obtained dataset has been randomly partitioned into two sets, where 70% of the volunteers was selected for generating the training data and 30% the test data. 

The sensor signals (accelerometer and gyroscope) were pre-processed by applying noise filters and then sampled in fixed-width sliding windows of 2.56 sec and 50% overlap (128 readings/window). The sensor acceleration signal, which has gravitational and body motion components, was separated using a Butterworth low-pass filter into body acceleration and gravity. The gravitational force is assumed to have only low frequency components, therefore a filter with 0.3 Hz cutoff frequency was used. From each window, a vector of features was obtained by calculating variables from the time and frequency domain.

