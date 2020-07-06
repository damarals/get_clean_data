# Code Book
generated 2020-07-06 12:13:51 during sourcing of `run_analysis.R`

## Actions performed on data:
* create data dir `./data`
* downloading zip file: [http://archive.ics.uci.edu/ml/machine-learning-databases/00240/UCI%20HAR%20Dataset.zip](http://archive.ics.uci.edu/ml/machine-learning-databases/00240/UCI%20HAR%20Dataset.zip) to `./data`
* extracting zip file: `./data/UCI_HAR_Dataset.zip` to `./data`
* merging all *_train.txt and *_test.txt files into one dataset: `mergedData`
* `mergedData` loaded in memory, dimensions: 10299 x 563
* subsetted `data` keeping only the key columns and features containing `std` or `mean`, dimensions : 10299 x 68
* merged `activity_labels.txt` contents with correct `activity_num` column, effectivly appending `activity_name` to `data`, dimensions : 10299 x 69
* gathered `data` into `finalData`, based on key columns, dimensions : 679734 x 11
* split feature column `variable` into 7 seperate colums (for each sub feature) in `finalData`, dimensions : 679734 x 11
* write `finalData` to file  `'./data/finalData.txt'`
* summarise `data` into **`tidyData`** with the average of each variable for each activity and each subject dimensions :180 x 68
* write `tidyData` to file  `'./data/tidyData.txt'`

## `resultData` variable

### key columns

Variable name       | Description
--------------------|------------
`subject`           | ID of subject, int (1-30)
`activity_num`      | ID of activity, int (1-6)
`activity_name`     | Label of activity, Factor w/ 6 levels
### non-key columns

Variable name       | Description
--------------------|------------
`variable`          | complete name of the feature, Factor w/ 66 levels (eg. tBodyAcc-mean()-X) 
`value`             | the actual value, num (range: -1:1)
`dimension`         | dimension of measurement, Factor w/ 2 levels: `Time` or `Frequency`
`source`            | source of measurement, Factor w/ 3 levels: `Body`,`BodyBody` or `Gravity`
`type`              | type of measurement, Factor w/ 2 levels: `Accelerometer` or `Gyroscope`
`jerk`              | is 'Jerk' signal , Boolean:  TRUE or FALSE
`magnitude`         | is 'Magnitude' value , Boolean:  TRUE or FALSE
`method`            | result from method , Factor w/ 2 levels:  `Mean` (average) or `Std` (standard deviation)
`axis`              | FFT exrapolated to axis , Factor w/ 2 levels:  `` (no FFT-axis) or `X`, `Y` or `Z`

## `tidyData` variable

### key columns

Variable name       | Description
--------------------|------------
`activity_name`     | Label of activity, Factor w/ 6 levels
`subject`           | ID of subject, int (1-30)
### non-key columns

Variable name       | Description
--------------------|------------
`tBodyAcc-mean()-X`   | the average value for this feature, num (range: -1:1)
`tBodyAcc-mean()-Y`   | the average value for this feature, num (range: -1:1)
`tBodyAcc-mean()-Z`   | the average value for this feature, num (range: -1:1)
`tBodyAcc-std()-X`   | the average value for this feature, num (range: -1:1)
`tBodyAcc-std()-Y`   | the average value for this feature, num (range: -1:1)
`tBodyAcc-std()-Z`   | the average value for this feature, num (range: -1:1)
`tGravityAcc-mean()-X`   | the average value for this feature, num (range: -1:1)
`tGravityAcc-mean()-Y`   | the average value for this feature, num (range: -1:1)
`tGravityAcc-mean()-Z`   | the average value for this feature, num (range: -1:1)
`tGravityAcc-std()-X`   | the average value for this feature, num (range: -1:1)
`tGravityAcc-std()-Y`   | the average value for this feature, num (range: -1:1)
`tGravityAcc-std()-Z`   | the average value for this feature, num (range: -1:1)
`tBodyAccJerk-mean()-X`   | the average value for this feature, num (range: -1:1)
`tBodyAccJerk-mean()-Y`   | the average value for this feature, num (range: -1:1)
`tBodyAccJerk-mean()-Z`   | the average value for this feature, num (range: -1:1)
`tBodyAccJerk-std()-X`   | the average value for this feature, num (range: -1:1)
`tBodyAccJerk-std()-Y`   | the average value for this feature, num (range: -1:1)
`tBodyAccJerk-std()-Z`   | the average value for this feature, num (range: -1:1)
`tBodyGyro-mean()-X`   | the average value for this feature, num (range: -1:1)
`tBodyGyro-mean()-Y`   | the average value for this feature, num (range: -1:1)
`tBodyGyro-mean()-Z`   | the average value for this feature, num (range: -1:1)
`tBodyGyro-std()-X`   | the average value for this feature, num (range: -1:1)
`tBodyGyro-std()-Y`   | the average value for this feature, num (range: -1:1)
`tBodyGyro-std()-Z`   | the average value for this feature, num (range: -1:1)
`tBodyGyroJerk-mean()-X`   | the average value for this feature, num (range: -1:1)
`tBodyGyroJerk-mean()-Y`   | the average value for this feature, num (range: -1:1)
`tBodyGyroJerk-mean()-Z`   | the average value for this feature, num (range: -1:1)
`tBodyGyroJerk-std()-X`   | the average value for this feature, num (range: -1:1)
`tBodyGyroJerk-std()-Y`   | the average value for this feature, num (range: -1:1)
`tBodyGyroJerk-std()-Z`   | the average value for this feature, num (range: -1:1)
`tBodyAccMag-mean()`   | the average value for this feature, num (range: -1:1)
`tBodyAccMag-std()`   | the average value for this feature, num (range: -1:1)
`tGravityAccMag-mean()`   | the average value for this feature, num (range: -1:1)
`tGravityAccMag-std()`   | the average value for this feature, num (range: -1:1)
`tBodyAccJerkMag-mean()`   | the average value for this feature, num (range: -1:1)
`tBodyAccJerkMag-std()`   | the average value for this feature, num (range: -1:1)
`tBodyGyroMag-mean()`   | the average value for this feature, num (range: -1:1)
`tBodyGyroMag-std()`   | the average value for this feature, num (range: -1:1)
`tBodyGyroJerkMag-mean()`   | the average value for this feature, num (range: -1:1)
`tBodyGyroJerkMag-std()`   | the average value for this feature, num (range: -1:1)
`fBodyAcc-mean()-X`   | the average value for this feature, num (range: -1:1)
`fBodyAcc-mean()-Y`   | the average value for this feature, num (range: -1:1)
`fBodyAcc-mean()-Z`   | the average value for this feature, num (range: -1:1)
`fBodyAcc-std()-X`   | the average value for this feature, num (range: -1:1)
`fBodyAcc-std()-Y`   | the average value for this feature, num (range: -1:1)
`fBodyAcc-std()-Z`   | the average value for this feature, num (range: -1:1)
`fBodyAccJerk-mean()-X`   | the average value for this feature, num (range: -1:1)
`fBodyAccJerk-mean()-Y`   | the average value for this feature, num (range: -1:1)
`fBodyAccJerk-mean()-Z`   | the average value for this feature, num (range: -1:1)
`fBodyAccJerk-std()-X`   | the average value for this feature, num (range: -1:1)
`fBodyAccJerk-std()-Y`   | the average value for this feature, num (range: -1:1)
`fBodyAccJerk-std()-Z`   | the average value for this feature, num (range: -1:1)
`fBodyGyro-mean()-X`   | the average value for this feature, num (range: -1:1)
`fBodyGyro-mean()-Y`   | the average value for this feature, num (range: -1:1)
`fBodyGyro-mean()-Z`   | the average value for this feature, num (range: -1:1)
`fBodyGyro-std()-X`   | the average value for this feature, num (range: -1:1)
`fBodyGyro-std()-Y`   | the average value for this feature, num (range: -1:1)
`fBodyGyro-std()-Z`   | the average value for this feature, num (range: -1:1)
`fBodyAccMag-mean()`   | the average value for this feature, num (range: -1:1)
`fBodyAccMag-std()`   | the average value for this feature, num (range: -1:1)
`fBodyBodyAccJerkMag-mean()`   | the average value for this feature, num (range: -1:1)
`fBodyBodyAccJerkMag-std()`   | the average value for this feature, num (range: -1:1)
`fBodyBodyGyroMag-mean()`   | the average value for this feature, num (range: -1:1)
`fBodyBodyGyroMag-std()`   | the average value for this feature, num (range: -1:1)
`fBodyBodyGyroJerkMag-mean()`   | the average value for this feature, num (range: -1:1)
`fBodyBodyGyroJerkMag-std()`   | the average value for this feature, num (range: -1:1)
