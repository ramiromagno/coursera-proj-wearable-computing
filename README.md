
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Wearable Computing

The goal of this repository is to show how to clean a data set as per
the *Peer-graded Assignment: Getting and Cleaning Data Course Project*
of the Coursera course on *Getting and Cleaning Data*.

## Data

### Original data set

The original data set is the [Human Activity Recognition Using
Smartphones Data
Set](https://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones).

An immutable copy is provided by Coursera:
<https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip>.

The raw data can also be found in this repository in the folder
`data-raw/`. The data has been manually downloaded.

### Tidy data set

The tidy data set is provided in tabular format in `data/dat5.csv`. It
is named dat5 because it is the result of step 5 of the analysis here
performed (see steps’ description below). The intermediate steps’ data
sets are also provided in `data/`.

## Data tidying

The data tidying is performed in the R script `R/run_analysis.R`.

As per the assignment, the workflow in `run_analysis.R` is divided in
five steps:

1.  Merging of the training and the test sets to create one data set.
2.  Selection of only the measurements on the mean and standard
    deviation for each measurement.
3.  Use of descriptive activity names to name the activities in the data
    set.
4.  Appropriately labels the data set with descriptive variable names.
5.  From the data set in step 4, creates a second, independent tidy data
    set with the average of each variable for each activity and each
    subject.

The final result of this data tidying workflow is data set —
`data/dat5.csv` — which is a table with the following characteristics:

-   Each row corresponds to an observation which is an average of
    measurements (acceleration or jerk). Each average is over a group
    defined on the combination of the `subject` (individual identifier)
    and `activity` (type of activity ).
-   Each column corresponds to one variable which can be divided in
    three groups:
    -   Group 1: metadata columns `subject` and `activity` (used for the
        summarizing groups)
    -   Group 2: metadata columns about the measurements’ average:
        `domain`, `acc_component`, `motion`, `derivative`, `axis` and
        `statistic`.
    -   Group 3: column `value`, i.e. the measurements’ average.

For details about the meaning of each individual variable and units see
the code book (CodeBook.md).
