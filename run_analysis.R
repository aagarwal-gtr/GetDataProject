# load reshpae2 and data.table packages. install if not present.

if (!require("data.table")) {
  install.packages("data.table")
}

if (!require("reshape2")) {
  install.packages("reshape2")
}

require("data.table")
require("reshape2")

# load all data
X_test <- read.table("UCI HAR Dataset/test/X_test.txt")
Y_test <- read.table("UCI HAR Dataset/test/y_test.txt")
X_train <- read.table("UCI HAR Dataset/train/X_train.txt")
Y_train <- read.table("UCI HAR Dataset/train/y_train.txt")
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt")
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt")
features <- read.table("UCI HAR Dataset/features.txt")[,2]
activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt")[,2]

# extract only mean and s.d. measurements
extract_features <- grepl("mean|std", features)

names(X_test) <- features
names(X_train) <- features

X_test <- X_test[,extract_features]
X_train <- X_train[,extract_features]

# load labels
Y_test[,2] = activity_labels[Y_test[,1]]
names(Y_test) = c("Activity_ID", "Activity_Label")
names(subject_test) = "subject"

Y_train[,2] = activity_labels[Y_train[,1]]
names(Y_train) = c("Activity_ID", "Activity_Label")
names(subject_train) = "subject"

# merge x y datasets
test_data <- cbind(as.data.table(subject_test), Y_test, X_test)
train_data <- cbind(as.data.table(subject_train), Y_train, X_train)

# merge test train data
data = rbind(test_data, train_data)

id_labels   = c("subject", "Activity_ID", "Activity_Label")
data_labels = setdiff(colnames(data), id_labels)
melt_data      = melt(data, id = id_labels, measure.vars = data_labels)

# average dataset
tidy_data   = dcast(melt_data, subject + Activity_Label ~ variable, mean)

# write final tidy data to file
write.table(tidy_data, file = "./tidy_data.txt")