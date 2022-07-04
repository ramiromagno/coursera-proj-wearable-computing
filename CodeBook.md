
# Code book

This files describes briefly the data transformations involved in
tidying the [Human Activity Recognition Using Smartphones Data
Set](https://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones)
and the meaning of the variables present in the final tidy data set.

As mentioned in the README file, the raw data set is transformed into a
tidy data set (`data/dat5.csv`) in five main steps (`R/run_analysis.R`).
I describe them now briefly.

## Data transformation

### Step 1

Step 1 consisted in merging the training and the test sets to create one
data set.

The raw data comes split into training and test sets:

-   `"data-raw/UCI HAR Dataset/test/X_test.txt"`
-   `"data-raw/UCI HAR Dataset/train/X_train.txt"`

Each line of those two files corresponded to an observation, i.e. a
recorded instance of the feature vector (the set of quantitative
variables). The variable values were simply separated by spaces. Hence,
the data was first imported to R using `readLines()` and afterwards
parsed as numeric matrix using the bespoke function `line_to_numbers()`.
This resulted in two matrices `dat_test` and `dat_train`.

The subject identifiers and activities were provided in their own files,
also split by training and test, and were imported using `readLines()`
and base R type coercion resulting in the following variables:

-   `subject_test` and `subject_train`, R vectors containing the subject
    identifiers (integer type), for the test and training data sets,
    respectively.

-   `activity_lbls_test` and `activity_lbls_train`, also R vectors
    containing the activity codes (integer type), for the test and
    training data sets, respectively.

All these data were combined by column binding. In addition, the
provenance of each data set (i.e., training or test) was also recorded
as a new variable `dataset`.

Finally, the names of the quantitative variables (feature vector) were
imported from `"data-raw/UCI HAR Dataset/features.txt"` and used to
overwrite the automatically generated names in `dat1` (the resulting
data set for step 1).

``` r
dat1 <- read_csv(file = "data/dat1.csv", show_col_types = FALSE, name_repair = 'minimal')
head(dat1)
#> # A tibble: 6 × 564
#>   dataset subject activity_id `tBodyAcc-mean…` `tBodyAcc-mean…` `tBodyAcc-mean…`
#>   <chr>     <dbl>       <dbl>            <dbl>            <dbl>            <dbl>
#> 1 test          2           5            0.257          -0.0233          -0.0147
#> 2 test          2           5            0.286          -0.0132          -0.119 
#> 3 test          2           5            0.275          -0.0261          -0.118 
#> 4 test          2           5            0.270          -0.0326          -0.118 
#> 5 test          2           5            0.275          -0.0278          -0.130 
#> 6 test          2           5            0.279          -0.0186          -0.114 
#> # … with 558 more variables: `tBodyAcc-std()-X` <dbl>,
#> #   `tBodyAcc-std()-Y` <dbl>, `tBodyAcc-std()-Z` <dbl>,
#> #   `tBodyAcc-mad()-X` <dbl>, `tBodyAcc-mad()-Y` <dbl>,
#> #   `tBodyAcc-mad()-Z` <dbl>, `tBodyAcc-max()-X` <dbl>,
#> #   `tBodyAcc-max()-Y` <dbl>, `tBodyAcc-max()-Z` <dbl>,
#> #   `tBodyAcc-min()-X` <dbl>, `tBodyAcc-min()-Y` <dbl>,
#> #   `tBodyAcc-min()-Z` <dbl>, `tBodyAcc-sma()` <dbl>, …
```

### Step 2

In step 2 I selected the features (i.e. variables) of interest:
measurements on the mean and standard deviation. To achieve this, the
columns whose name matched the regular expression
`r"{mean\(\)|std\(\)}"` were determined and used for sub-setting `dat1`,
which resulted in `dat2`:

``` r
dat2 <- read_csv(file = "data/dat2.csv", show_col_types = FALSE, name_repair = 'minimal')
head(dat2)
#> # A tibble: 6 × 69
#>   dataset subject activity_id `tBodyAcc-mean…` `tBodyAcc-mean…` `tBodyAcc-mean…`
#>   <chr>     <dbl>       <dbl>            <dbl>            <dbl>            <dbl>
#> 1 test          2           5            0.257          -0.0233          -0.0147
#> 2 test          2           5            0.286          -0.0132          -0.119 
#> 3 test          2           5            0.275          -0.0261          -0.118 
#> 4 test          2           5            0.270          -0.0326          -0.118 
#> 5 test          2           5            0.275          -0.0278          -0.130 
#> 6 test          2           5            0.279          -0.0186          -0.114 
#> # … with 63 more variables: `tBodyAcc-std()-X` <dbl>, `tBodyAcc-std()-Y` <dbl>,
#> #   `tBodyAcc-std()-Z` <dbl>, `tGravityAcc-mean()-X` <dbl>,
#> #   `tGravityAcc-mean()-Y` <dbl>, `tGravityAcc-mean()-Z` <dbl>,
#> #   `tGravityAcc-std()-X` <dbl>, `tGravityAcc-std()-Y` <dbl>,
#> #   `tGravityAcc-std()-Z` <dbl>, `tBodyAccJerk-mean()-X` <dbl>,
#> #   `tBodyAccJerk-mean()-Y` <dbl>, `tBodyAccJerk-mean()-Z` <dbl>,
#> #   `tBodyAccJerk-std()-X` <dbl>, `tBodyAccJerk-std()-Y` <dbl>, …
```

### Step 3

In step 3 I converted the activity codes to respective activity names.
The file `"data-raw/UCI HAR Dataset/activity_labels.txt"` provided the
dictionary. Therefore, all was needed was to import this dictionary as a
data frame and then perform a left join between `dat2` and the imported
dictionary. This resulted in `dat3`:

``` r
dat3 <- read_csv(file = "data/dat3.csv", show_col_types = FALSE, name_repair = 'minimal')
head(dat3)
#> # A tibble: 6 × 69
#>   dataset subject activity `tBodyAcc-mean()-X` `tBodyAcc-mean…` `tBodyAcc-mean…`
#>   <chr>     <dbl> <chr>                  <dbl>            <dbl>            <dbl>
#> 1 test          2 STANDING               0.257          -0.0233          -0.0147
#> 2 test          2 STANDING               0.286          -0.0132          -0.119 
#> 3 test          2 STANDING               0.275          -0.0261          -0.118 
#> 4 test          2 STANDING               0.270          -0.0326          -0.118 
#> 5 test          2 STANDING               0.275          -0.0278          -0.130 
#> 6 test          2 STANDING               0.279          -0.0186          -0.114 
#> # … with 63 more variables: `tBodyAcc-std()-X` <dbl>, `tBodyAcc-std()-Y` <dbl>,
#> #   `tBodyAcc-std()-Z` <dbl>, `tGravityAcc-mean()-X` <dbl>,
#> #   `tGravityAcc-mean()-Y` <dbl>, `tGravityAcc-mean()-Z` <dbl>,
#> #   `tGravityAcc-std()-X` <dbl>, `tGravityAcc-std()-Y` <dbl>,
#> #   `tGravityAcc-std()-Z` <dbl>, `tBodyAccJerk-mean()-X` <dbl>,
#> #   `tBodyAccJerk-mean()-Y` <dbl>, `tBodyAccJerk-mean()-Z` <dbl>,
#> #   `tBodyAccJerk-std()-X` <dbl>, `tBodyAccJerk-std()-Y` <dbl>, …
```

### Step 4

In step 4, I changed the variable names to more idiomatic standard
variable names, i.e. I removed non-standard characters, and converted to
snake case using `snakecase::to_snake_case`:

``` r
dat4 <- read_csv(file = "data/dat4.csv", show_col_types = FALSE, name_repair = 'minimal')
head(dat4)
#> # A tibble: 6 × 69
#>   dataset subject activity t_body_acc_mean_x t_body_acc_mean_y t_body_acc_mean_z
#>   <chr>     <dbl> <chr>                <dbl>             <dbl>             <dbl>
#> 1 test          2 STANDING             0.257           -0.0233           -0.0147
#> 2 test          2 STANDING             0.286           -0.0132           -0.119 
#> 3 test          2 STANDING             0.275           -0.0261           -0.118 
#> 4 test          2 STANDING             0.270           -0.0326           -0.118 
#> 5 test          2 STANDING             0.275           -0.0278           -0.130 
#> 6 test          2 STANDING             0.279           -0.0186           -0.114 
#> # … with 63 more variables: t_body_acc_std_x <dbl>, t_body_acc_std_y <dbl>,
#> #   t_body_acc_std_z <dbl>, t_gravity_acc_mean_x <dbl>,
#> #   t_gravity_acc_mean_y <dbl>, t_gravity_acc_mean_z <dbl>,
#> #   t_gravity_acc_std_x <dbl>, t_gravity_acc_std_y <dbl>,
#> #   t_gravity_acc_std_z <dbl>, t_body_acc_jerk_mean_x <dbl>,
#> #   t_body_acc_jerk_mean_y <dbl>, t_body_acc_jerk_mean_z <dbl>,
#> #   t_body_acc_jerk_std_x <dbl>, t_body_acc_jerk_std_y <dbl>, …
```

Note: the assignment required the names to be descriptive at this point.
In all honesty, I think it makes more sense to leave changing the names
to step 5 where we separate the variables into their own columns.

### Step 5

From the data set in step 4, I create a second one now, independent tidy
data set with the average of each variable for each activity and each
subject. Moreover, I separate the multiple variables encoded in single
columns into their respective column, and change the column names in a
way that I think best conveys its meaning (although this subjective).

Step 5 can be divided in two:

1.  Split-apply-combine to calculate the averages, i.e., I use
    `dplyr::grou_by()` and `dplyr::sumarise()` to find the averages for
    each combination of `subject` and `activity`.

2.  Transform `dat4` quantitative columns (wide format) into separate
    independent variables (long format). This is achieved using
    `pivot_longer_spec()`. This transformation is best understood by
    looking at the specification given to `pivot_longer_spec()`,
    i.e. data frame `wide_to_long_spec` (see `R/run_analysis.R`).

In the end, the tidy data set `dat5` consists of `11520` observations
(averages for the combination `subject`/`activity`) and `9` columns.

``` r
dat5 <- read_csv(file = "data/dat5.csv", show_col_types = FALSE, name_repair = 'minimal')
dat5
#> # A tibble: 11,520 × 9
#>    subject activity domain acc_component motion derivative axis  statistic
#>      <dbl> <chr>    <chr>  <chr>         <chr>       <dbl> <chr> <chr>    
#>  1       1 LAYING   time   body          linear          2 Z     mean     
#>  2       1 LAYING   time   body          linear          2 X     sd       
#>  3       1 LAYING   time   body          linear          2 Y     sd       
#>  4       1 LAYING   time   body          linear          2 Z     sd       
#>  5       1 LAYING   time   gravity       linear          2 X     mean     
#>  6       1 LAYING   time   gravity       linear          2 Y     mean     
#>  7       1 LAYING   time   gravity       linear          2 Z     mean     
#>  8       1 LAYING   time   gravity       linear          2 X     sd       
#>  9       1 LAYING   time   gravity       linear          2 Y     sd       
#> 10       1 LAYING   time   gravity       linear          2 Z     sd       
#> # … with 11,510 more rows, and 1 more variable: value <dbl>
```

## Tidy data set variables

| Variable        | Description                                                                                                                                                                                                                                           | Type        |
|-----------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------|
| `subject`       | The subject identifier. A surrogate integer value representation a person involved in the study, 1 thru 30.                                                                                                                                           | Categorical |
| `activity`      | The activity the person was performing when the measurements were taken: LAYING, SITTING, STANDING, WALKING_DOWNSTAIRS or WALKING_UPSTAIRS.                                                                                                           | Categorical |
| `domain`        | Time domain or frequency domain signal.                                                                                                                                                                                                               | Categorical |
| `acc_component` | Acceleration component. Either the body autonomous movement (`"body"`) or acceleration due to `"gravity"`.                                                                                                                                            | Categorical |
| `motion`        | Whether the measurement refers to `"linear"` movement (i.e. measured with the accelerometer) or `"angular"` motion (rotation, i.e. measured with the gyroscope).                                                                                      | Categorical |
| `derivative`    | The kind of physical quantity measured, expressed as [nth derivative of position](https://en.wikipedia.org/wiki/Fourth,_fifth,_and_sixth_derivatives_of_position). 2nd derivative (`2`) is acceleration and 3rd derivative (`3`) corresponds to jerk. | Categorical |
| `axis`          | The axis (or direction) along which the measurement is taken. Either `"X"`, `"Y"` or `"Z"`, for the x-, y- or z- axis, or `"XYZ"` for the norm (vector’s magnitude).                                                                                  | Categorical |
| `statistic`     | Mean (`"mean"`) or standard deviation (`"sd"`).                                                                                                                                                                                                       | Categorical |
| `value`         | The infamous average of measurements for the combination `subject`-`activity`. This variable is unitless, as it has been normalised to the range \[-1, 1\]                                                                                            | Numeric     |
