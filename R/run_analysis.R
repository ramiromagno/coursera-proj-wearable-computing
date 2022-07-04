##
## Script run_analysis.R
## Peer-graded Assignment: Getting and Cleaning Data Course Project
## Author: Ramiro Magno
## 04 July 2022
##


library(tidyverse)
library(here)
library(snakecase)

##
## Step 1
## Merges the training and the test sets to create one data set.
## 

# Import the subject identifiers
subject_test <-
  readLines(con = "data-raw/UCI HAR Dataset/test/subject_test.txt") |>
  as.integer()

subject_train <-
  readLines(con = "data-raw/UCI HAR Dataset/train/subject_train.txt") |>
  as.integer()

# Import the activity labels
activity_lbls_test <-
  readLines(con = "data-raw/UCI HAR Dataset/test/y_test.txt")

activity_lbls_train <-
  readLines(con = "data-raw/UCI HAR Dataset/train/y_train.txt")

# `line_to_numbers()`: converts line(s) of "textual" numbers separated by white
# spaces to numbers (numeric).
line_to_numbers <- function(x) {
  x1 <- stringr::str_split(x, "\\s+")
  lst <- lapply(x1, \(x) readr::parse_number(x[x != ""]))
  matrix(unlist(lst), ncol = length(lst[[1]]), byrow = TRUE)
}

# Import the test data set as a matrix: rows are observations and columns are
# features
dat_test <- readLines("data-raw/UCI HAR Dataset/test/X_test.txt") |>
  line_to_numbers()

# Idem for the train data set.
dat_train <- readLines("data-raw/UCI HAR Dataset/train/X_train.txt") |>
  line_to_numbers()

# `dat1` is one single data set that results from merging the training and test
# sets. In addition, three extra columns are prepended:
#   - `dataset`: either "test" or "training" to indicate its provenance
#   - `subject`: the subject identifier
#   - `activity`: the activity code
dat1 <- bind_rows(bind_cols(
  tibble(
    dataset = "test",
    subject = subject_test,
    activity_id = activity_lbls_test
  ),
  dat_test
),
bind_cols(
  tibble(
    dataset = "training",
    subject = subject_train,
    activity_id = activity_lbls_train
  ),
  dat_train
))

# Import the features' dictionary
features <-
  read_delim("data-raw/UCI HAR Dataset/features.txt",
             " ",
             col_names = c("feature_id", "feature"),
             show_col_types = FALSE)

# Name the (yet unnamed) features' columns in `dat1`.
# Note that the first three columns are already named ("dataset", "subject" and
# "activity")
colnames(dat1)[-(1:3)] <- features$feature

# To finalise step 1, I export the merged data set `dat1` to disk
write_csv(x = dat1, file = "data/dat1.csv")

##
## Step 2
## Extracts only the measurements on the mean and standard deviation for each
## measurement.
## 

# Determine the features of interest: measurements on the mean and standard
# deviation.
features_of_interest <-
  features |>
  filter(grepl(r"{mean\(\)|std\(\)}", feature))

# Now I use the indices to select the columns whose measurements are on the mean
# and standard deviation.
dat2 <- select(dat1, 1:3, 3 + features_of_interest$feature_id)

# To finalise step 2, I export the data set `dat2` to disk
write_csv(x = dat2, file = "data/dat2.csv")

##
## Step 3
## Uses descriptive activity names to name the activities in the data set
## 

# Activities' dictionary
activity_dict <-
  read_delim(
    "data-raw/UCI HAR Dataset/activity_labels.txt",
    delim = " ",
    col_names = c("activity_id", "activity"),
    col_types = "cc"
  )

# Here I join the dataset `dat2` with the `activity_dict` to translate the
# activity identifiers to activity names. After the join I relocate the
# "activity" column to nicely have the three "metadata" columns close together
# at the beginning and the remaining 66 mean/stdev columns afterwards. Finally I
# drop the activity_id as it is not needed anymore.
dat3 <- left_join(dat2, activity_dict, by = "activity_id") |>
  relocate(activity, .after = "subject") |>
  select(-activity_id)

# To finalise step 3, I export the data set `dat3` to disk
write_csv(x = dat3, file = "data/dat3.csv")

##
## Step 4
## Appropriately labels the data set with descriptive variable names. 
## 

# I think the variables in the data set `dat3` are already quite descriptive, as
# they are the feature names found in the features dictionary file
# (features.txt). So, with regards to further tidying the variable names I guess
# one could still transform the non-standard characters, and follow, e.g. snake
# case for the naming of these variables to ease the work of other developers. I
# will be using the `snakecase::to_snake_case()` function for this.

dat4 <- dat3
colnames(dat4) <- to_snake_case(colnames(dat4))

# To finalise step 4, I export the data set `dat4` to disk
write_csv(x = dat4, file = "data/dat4.csv")

##
## Step 5
## From the data set in step 4, creates a second, independent tidy data set with
## the average of each variable for each activity and each subject.
## 

# `wide_to_long_spec`: a data frame specifying how to translate the various
# variables encoded in the colnames of `dat4` into separate variable/columns.
# I think the code below reads nicely because each line of code shows how each
# column name gets converted to several independent variables.
wide_to_long_spec <-
  tribble(
    ~.name, ~.value, ~domain, ~acc_component, ~motion, ~derivative, ~axis, ~statistic,
    "t_body_acc_mean_z", "value", "time", "body", "linear", 2, "Z", "mean",
    "t_body_acc_std_x", "value", "time", "body", "linear", 2, "X", "sd",
    "t_body_acc_std_y", "value", "time", "body", "linear", 2, "Y", "sd",
    "t_body_acc_std_z", "value", "time", "body", "linear", 2, "Z", "sd",
    "t_gravity_acc_mean_x", "value", "time", "gravity", "linear", 2, "X", "mean",
    "t_gravity_acc_mean_y", "value", "time", "gravity", "linear", 2, "Y", "mean",
    "t_gravity_acc_mean_z", "value", "time", "gravity", "linear", 2, "Z", "mean",
    "t_gravity_acc_std_x", "value", "time", "gravity", "linear", 2, "X", "sd",
    "t_gravity_acc_std_y", "value", "time", "gravity", "linear", 2, "Y", "sd",
    "t_gravity_acc_std_z", "value", "time", "gravity", "linear", 2, "Z", "sd",
    "t_body_acc_jerk_mean_x", "value", "time", "body", "linear", 3, "X", "mean",
    "t_body_acc_jerk_mean_y", "value", "time", "body", "linear", 3, "Y", "mean",
    "t_body_acc_jerk_mean_z", "value", "time", "body", "linear", 3, "Z", "mean",
    "t_body_acc_jerk_std_x", "value", "time", "body", "linear", 3, "X", "sd",
    "t_body_acc_jerk_std_y", "value", "time", "body", "linear", 3, "Y", "sd",
    "t_body_acc_jerk_std_z", "value", "time", "body", "linear", 3, "Z", "sd",
    "t_body_gyro_mean_x", "value", "time", "body", "angular", 2, "X", "mean",
    "t_body_gyro_mean_y", "value", "time", "body", "angular", 2, "Y", "mean",
    "t_body_gyro_mean_z", "value", "time", "body", "angular", 2, "Z", "mean",
    "t_body_gyro_std_x", "value", "time", "body", "angular", 2, "X", "sd",
    "t_body_gyro_std_y", "value", "time", "body", "angular", 2, "Y", "sd",
    "t_body_gyro_std_z", "value", "time", "body", "angular", 2, "Z", "sd",
    "t_body_gyro_jerk_mean_x", "value", "time", "body", "angular", 3, "X", "mean",
    "t_body_gyro_jerk_mean_y", "value", "time", "body", "angular", 3, "Y", "mean",
    "t_body_gyro_jerk_mean_z", "value", "time", "body", "angular", 3, "Z", "mean",
    "t_body_gyro_jerk_std_x", "value", "time", "body", "angular", 3, "X", "sd",
    "t_body_gyro_jerk_std_y", "value", "time", "body", "angular", 3, "Y", "sd",
    "t_body_gyro_jerk_std_z", "value", "time", "body", "angular", 3, "Z", "sd",
    "t_body_acc_mag_mean", "value", "time", "body", "linear", 2, "XYZ", "mean",
    "t_body_acc_mag_std", "value", "time", "body", "linear", 2, "XYZ", "sd",
    "t_gravity_acc_mag_mean", "value", "time", "gravity", "linear", 2, "XYZ", "mean",
    "t_gravity_acc_mag_std", "value", "time", "gravity", "linear", 2, "XYZ", "sd",
    "t_body_acc_jerk_mag_mean", "value", "time", "body", "linear", 3, "XYZ", "mean",
    "t_body_acc_jerk_mag_std", "value", "time", "body", "linear", 3, "XYZ", "sd",
    "t_body_gyro_mag_mean", "value", "time", "body", "angular", 2, "XYZ", "mean",
    "t_body_gyro_mag_std", "value", "time", "body", "angular", 2, "XYZ", "sd",
    "t_body_gyro_jerk_mag_mean", "value", "time", "body", "angular", 3, "XYZ", "mean",
    "t_body_gyro_jerk_mag_std", "value", "time", "body", "angular", 3, "XYZ", "sd",
    "f_body_acc_mean_x", "value", "frequency", "body", "linear", 2, "X", "mean",
    "f_body_acc_mean_y", "value", "frequency", "body", "linear", 2, "Y", "mean",
    "f_body_acc_mean_z", "value", "frequency", "body", "linear", 2, "Z", "mean",
    "f_body_acc_std_x", "value", "frequency", "body", "linear", 2, "X", "sd",
    "f_body_acc_std_y", "value", "frequency", "body", "linear", 2, "Y", "sd",
    "f_body_acc_std_z", "value", "frequency", "body", "linear", 2, "Z", "sd",
    "f_body_acc_jerk_mean_x", "value", "frequency", "body", "linear", 3, "X", "mean",
    "f_body_acc_jerk_mean_y", "value", "frequency", "body", "linear", 3, "Y", "mean",
    "f_body_acc_jerk_mean_z", "value", "frequency", "body", "linear", 3, "Z", "mean",
    "f_body_acc_jerk_std_x", "value", "frequency", "body", "linear", 3, "X", "sd",
    "f_body_acc_jerk_std_y", "value", "frequency", "body", "linear", 3, "Y", "sd",
    "f_body_acc_jerk_std_z", "value", "frequency", "body", "linear", 3, "Z", "sd",
    "f_body_gyro_mean_x", "value", "frequency", "body", "angular", 2, "X", "mean",
    "f_body_gyro_mean_y", "value", "frequency", "body", "angular", 2, "Y", "mean",
    "f_body_gyro_mean_z", "value", "frequency", "body", "angular", 2, "Z", "mean",
    "f_body_gyro_std_x", "value", "frequency", "body", "angular", 2, "X", "sd",
    "f_body_gyro_std_y", "value", "frequency", "body", "angular", 2, "Y", "sd",
    "f_body_gyro_std_z", "value", "frequency", "body", "angular", 2, "Z", "sd",
    "f_body_acc_mag_mean", "value", "frequency", "body", "linear", 2, "XYZ", "mean",
    "f_body_acc_mag_std", "value", "frequency", "body", "linear", 2, "XYZ", "sd",
    "f_body_body_acc_jerk_mag_mean", "value", "frequency", "body", "linear", 3, "XYZ", "mean",
    "f_body_body_acc_jerk_mag_std", "value", "frequency", "body", "linear", 3, "XYZ", "sd",
    "f_body_body_gyro_mag_mean", "value", "frequency", "body", "angular", 2, "XYZ", "mean",
    "f_body_body_gyro_mag_std", "value", "frequency", "body", "angular", 2, "XYZ", "sd",
    "f_body_body_gyro_jerk_mag_mean", "value", "frequency", "body", "angular", 3, "XYZ", "mean",
    "f_body_body_gyro_jerk_mag_std", "value",  "frequency", "body",  "angular", 3, "XYZ",  "sd"
  )

# Group by the "subject" and "activity" columns, compute the mean for the
# quantitative variables (all except the first 3 columns), and "pivot" the data
# from wide to long, i.e. extract the implicit various variables in the column
# names into separate columns (this mapping/specification is given by
# `wide_to_long_spec` data frame.
dat5 <-
  dat4 |>
  group_by(subject, activity) |>
  summarise(across(-(1:3), mean), .groups = "drop") %>%
  pivot_longer_spec(spec = wide_to_long_spec)

# To finalise step 5, I export the data set `dat5` to disk
write_csv(x = dat5, file = "data/dat5.csv")
