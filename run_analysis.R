# Packages
require(dplyr)
require(stringr)
require(tidyr)
require(utils)

# Set working directory to source file location
script.dir <- getSrcDirectory(function(x) {x})
setwd(script.dir)

# Useful functions
makepath = function(path, file){
  pathfull <- paste0(path, '/', file)
  if(!dir.exists(path)) {
    dir.create(dirname(pathfull), recursive=TRUE)
  }
  return(pathfull)
}
codebook <- function(...){
  cat(..., "\n",file=targetCodebookFilePath,append=TRUE, sep="")
}

# Start with CodeBook
targetCodebookFilePath <- "CodeBook.md"
file.remove(targetCodebookFilePath)
codebook("# Code Book")
codebook("generated ", as.character(Sys.time())," during sourcing of `run_analysis.R`")
codebook("")  
codebook("## Actions performed on data:")

## Download Zip Files
datapath <- './data'
fileUrl <- "http://archive.ics.uci.edu/ml/machine-learning-databases/00240/UCI%20HAR%20Dataset.zip"
codebook("* create data dir `",datapath,"`")
zippath <- makepath(datapath, 'UCI_HAR_Dataset.zip')
codebook("* downloading zip file: [",fileUrl,"](",fileUrl,") to `",datapath,"`")
download.file(fileUrl, 
              destfile = zippath, 
              method = 'curl', quiet = T)
message('Directory created at ./data')
## Extract files
if(file.exists(zippath)) {
  # Get path names of data files
  zipped_data_names <- grep('/((subject|X|y)_t(.+)|features|activity_labels).txt$', 
                            unzip(zippath, list = TRUE)$Name, 
                            ignore.case = TRUE, value = TRUE)
  # Extract only data files
  unzip(zippath, exdir = datapath, files = zipped_data_names)
  # Delete original Zip file if it exists
  invisible(file.remove(zippath))
  message('Data files ready for use in ', 
          str_split(zippath, '.zip')[[1]][1])
}
codebook("* extracting zip file: `",zippath,"` to `",datapath,"`")

# Load Datasets
message('Loading data')
## Directory list
dirList <- list.files(datapath, recursive=TRUE)
activity_labels <- read.table(file.path('./data/', dirList[1]),
                              stringsAsFactors = F, 
                              col.names = c("activity_num", 
                                            "activity_name"))
message('...file activity_labels.txt loaded sucessfuly')
features <- read.table(file.path('./data/', dirList[2]),
                       stringsAsFactors = F)
message('...file features.txt loaded sucessfuly')
for(dataFile in dirList[-(1:2)]){
  txtFile <- file.path('./data/', dataFile)
  fileName <- strsplit(dataFile, '(st|in)\\/|\\.txt')[[1]][2]
  eval(parse(text = paste(fileName, '<- read.table(txtFile)')))
  message(paste0('...file ', fileName, '.txt loaded succesfully'))
}

# Assignments
# 1. Merges the training and the test sets to 
# create one data set.
codebook("* merging all *_train.txt and *_test.txt files into one dataset: `mergedData`")
data_train <- cbind(subject_train, X_train, y_train)
data_test <- cbind(subject_test, X_test, y_test)
data <- rbind(data_train, data_test)
colnames(data) <- c('subject', features$V2, 'activity_num')
message('Files merged')
codebook("* `mergedData` loaded in memory, dimensions: ", nrow(data)," x ",ncol(data))

rm(data_test, data_train, dataFile, datapath, dirList, 
   features, fileName, makepath, script.dir, subject_test, 
   subject_train, txtFile, X_test, X_train,          
   y_test, y_train, zippath, zipped_data_names)

# 2. Extracts only the measurements on the mean and 
# standard deviation for each measurement.
data <- data[, which(grepl("(subject|activity)|(mean|std)\\(\\)", 
                           colnames(data)))]
codebook("* subsetted `data` keeping only the key columns and features containing `std` or `mean`, dimensions : ", nrow(data)," x ",ncol(data))

message('Extracted measurements that contains mean and std')

# 3. Uses descriptive activity names to name the 
# activities in the data set
data <- merge(data, activity_labels, 
              by = "activity_num", all.x = TRUE)
codebook("* merged `activity_labels.txt` contents with correct `activity_num` column, effectivly appending `activity_name` to `data`, dimensions : ", nrow(data)," x ",ncol(data))
message('Applied descriptive names to dataset')

rm(activity_labels)

# 4. Appropriately labels the data set with descriptive 
# variable names. 

## Gather all variable except subject and activitys. After, 
## split the gathered variable in domain, source, ..., axis.
finalData <- data %>%
  select(subject, activity_num, activity_name, 
         `tBodyAcc-mean()-X`:`fBodyBodyGyroJerkMag-std()`) %>%
  gather(variable, value, -c(subject, activity_num, activity_name)) %>%
  mutate(vlist_gsub = gsub("^((f|t)(Body|BodyBody|Gravity)(Gyro|Acc|Body)[\\-]*(Jerk)?(Mag)?[\\-]*(mean|std)[\\(\\)\\-]*(X|Y|Z)?)", "\\2|\\3|\\4|\\5|\\6|\\7|\\8|\\1", variable),
         domain = sapply(str_split(vlist_gsub, "\\|"), 
                         function(l) if_else(l[1] == 't', 'Time', 'Frequency')),
         source = sapply(str_split(vlist_gsub, "\\|"), 
                         function(l) l[2]),
         type = sapply(str_split(vlist_gsub, "\\|"), 
                         function(l) if_else(l[3] == 'Acc', 'Accelerometer', 
                                             'Giroscopy')),
         jerk = sapply(str_split(vlist_gsub, "\\|"), 
                       function(l) l[4] == 'Jerk'),
         magnitude = sapply(str_split(vlist_gsub, "\\|"), 
                       function(l) l[5] == 'Mag'),
         method = sapply(str_split(vlist_gsub, "\\|"), 
                       function(l) str_to_title(l[6])),
         axis = sapply(str_split(vlist_gsub, "\\|"), 
                       function(l) if_else(l[7] == '', 'NA', l[7]))) %>%
  select(subject, activity_name, variable, domain, source, type, jerk, 
         magnitude, method, axis, value)
codebook("* gathered `data` into `finalData`, based on key columns, dimensions : ", nrow(finalData)," x ",ncol(finalData))
codebook("* split feature column `variable` into 7 seperate colums (for each sub feature) in `finalData`, dimensions : ", nrow(finalData)," x ",ncol(finalData))
codebook("* write `finalData` to file  `'./data/finalData.txt'`")
write.table(finalData, './data/finalData.txt',
            row.names = FALSE, 
            quote = FALSE,
            col.names = TRUE)
message('dataFinal file created')

# 5. From the data set in step 4, creates a second, 
# independent tidy data set with the average of each variable 
# for each activity and each subject.
tidyData <- data %>%
  select(subject, activity_name, 
         `tBodyAcc-mean()-X`:`fBodyBodyGyroJerkMag-std()`) %>%
  group_by(subject, activity_name) %>%
  summarise_all("mean")
codebook("* summarise `data` into **`tidyData`** with the average of each variable for each activity and each subject dimensions :", nrow(tidyData)," x ",ncol(tidyData))
message('tidyData file created')
codebook("* write `tidyData` to file  `'./data/tidyData.txt'`")
write.table(tidyData, './data/tidyData.txt',
            row.names = FALSE, 
            quote = FALSE,
            col.names = TRUE)
rm(data)

## delete folder UCI_HAR_Dataset
unlink("./data/UCI HAR Dataset", recursive = T)


# writing variable properties
codebook("") 
codebook("## `resultData` variable\n")
codebook("### key columns\n")
codebook("Variable name       | Description")
codebook("--------------------|------------")
codebook("`subject`           | ID of subject, int (1-30)")
codebook("`activity_num`      | ID of activity, int (1-6)")
codebook("`activity_name`     | Label of activity, Factor w/ 6 levels")

codebook("### non-key columns\n")
codebook("Variable name       | Description")
codebook("--------------------|------------")
codebook("`variable`          | complete name of the feature, Factor w/ 66 levels (eg. tBodyAcc-mean()-X) ")
codebook("`value`             | the actual value, num (range: -1:1)")
codebook("`dimension`         | dimension of measurement, Factor w/ 2 levels: `Time` or `Frequency`")
codebook("`source`            | source of measurement, Factor w/ 3 levels: `Body`,`BodyBody` or `Gravity`")
codebook("`type`              | type of measurement, Factor w/ 2 levels: `Accelerometer` or `Gyroscope`")
codebook("`jerk`              | is 'Jerk' signal , Boolean:  TRUE or FALSE")
codebook("`magnitude`         | is 'Magnitude' value , Boolean:  TRUE or FALSE")
codebook("`method`            | result from method , Factor w/ 2 levels:  `Mean` (average) or `Std` (standard deviation)")
codebook("`axis`              | FFT exrapolated to axis , Factor w/ 2 levels:  `` (no FFT-axis) or `X`, `Y` or `Z`")

codebook("") 
codebook("## `tidyData` variable\n")
codebook("### key columns\n")
codebook("Variable name       | Description")
codebook("--------------------|------------")
codebook("`activity_name`     | Label of activity, Factor w/ 6 levels")
codebook("`subject`           | ID of subject, int (1-30)")


codebook("### non-key columns\n")
codebook("Variable name       | Description")
codebook("--------------------|------------")
tidyDataCols <- names(tidyData)[3:68]
for(tdc in tidyDataCols){
  codebook("`",tdc,"`   | the average value for this feature, num (range: -1:1)")
}