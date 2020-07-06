# Packages
require(dplyr)
require(stringr)
require(tidyr)
require(utils)
require(dataMaid)

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
deletefile <- function(files_) {
  for(fn in files_) {
    if (file.exists(fn)) {
      file.remove(fn)
    }
  }
}

## Download Zip Files
datapath <- './data'
zippath <- makepath(datapath, 'UCI_HAR_Dataset.zip')
download.file("http://archive.ics.uci.edu/ml/machine-learning-databases/00240/UCI%20HAR%20Dataset.zip", 
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
data_train <- cbind(subject_train, X_train, y_train)
data_test <- cbind(subject_test, X_test, y_test)
data <- rbind(data_train, data_test)
colnames(data) <- c('subject', features$V2, 'activity_num')
message('Files merged')

rm(data_test, data_train, dataFile, datapath, dirList, 
   features, fileName, makepath, script.dir, subject_test, 
   subject_train, txtFile, X_test, X_train,          
   y_test, y_train, zippath, zipped_data_names)

# 2. Extracts only the measurements on the mean and 
# standard deviation for each measurement.
data <- data[, which(grepl("(subject|activity)|(mean|std)\\(\\)", 
                           colnames(data)))]
message('Extracted measurements that contains mean and std')

# 3. Uses descriptive activity names to name the 
# activities in the data set
data <- merge(data, activity_labels, 
              by = "activity_num", all.x = TRUE)
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
  rename(subject_ = subject, activity_name_ = activity_name) %>%
  group_by(subject_, activity_name_) %>%
  summarise_all("mean")
message('tidyData file created')
write.table(tidyData, './data/tidyData.txt',
            row.names = FALSE, 
            quote = FALSE,
            col.names = TRUE)
rm(data)

# Codebook
codebook <- function(data, reportTitle) {
  for(df in data) {
    makeCodebook(eval(parse(text = df)),
                 reportTitle = reportTitle, openResult = F,
                 file = df, render = F, quiet = 'silent')
  }
  markfile <- readLines('finalData.Rmd')
  tidydatafile <- readLines('tidyData.Rmd')
  markfile[4] <- ""
  markfile <- c(markfile, "\\newpage", tidydatafile[-c(1:25)])
  file.create('CodeBook.Rmd')
  writeLines(markfile, 'CodeBook.Rmd')
  knitr::knit("CodeBook.Rmd", quiet = T)
  deletefile(c('CodeBook.Rmd', 'tidyData.Rmd', 'finalData.Rmd'))
}
codebook(data = c('finalData', 'tidyData'), 
         reportTitle = 'Codebook for finalData and tidyData')
message('CodeBook.md created')


## delete folder UCI_HAR_Dataset
unlink("./data/UCI HAR Dataset", recursive = T)