# Useful functions
makepath = function(path, file){
  pathfull <- paste0(path, '/', file)
  if(!dir.exists(path)) {
    dir.create(dirname(pathfull), recursive=TRUE)
  }
  return(pathfull)
}

# Load Data
## Download Zip Files
zippath <- makepath('./data', 'UCI_HAR_Dataset.zip')
download.file("http://archive.ics.uci.edu/ml/machine-learning-databases/00240/UCI%20HAR%20Dataset.zip", 
              destfile = zippath, 
              method = 'curl', quiet = T)
message('Directory created at ./data')
## Extract files
if(file.exists(zippath)) {
  # Get path names of data files
  zipped_data_names <- grep('/((subject|X|y)_t(.+)|features).txt$', 
                            unzip(zippath, list = TRUE)$Name, 
                            ignore.case = TRUE, value = TRUE)
  # Extract only data files
  unzip(zippath, exdir = './data', files = zipped_data_names)
  # Delete original Zip file if it exists
  invisible(file.remove(zippath))
  message('Data files ready for use in ', 
          str_split(zippath, '.zip')[[1]][1])
}

# Load Datasets
message('Loading data')
dirList <- list.files('./data', recursive=TRUE)
features <- read.table(file.path('./data/', dirList[1]),
                       stringsAsFactors = F)
for(dataFile in dirList[-1]){
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

# 2. Extracts only the measurements on the mean and 
# standard deviation for each measurement.
data <- data[, which(grepl("(mean|std)\\(\\)", colnames(data)))]

# 3. Uses descriptive activity names to name the 
# activities in the data set






