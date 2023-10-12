# This file contains tests to be applied to
# the Vegvesen stations-data *after* being transformed
# to a data frame.
#
# All tests are packed in a function test_stations_metadata that apples
# all the aforementioned tests

test_stations_metadata_colnames <-
  function(df) {
    # The function checks if the data frame has the correct column names
    # and prints a PASS or FAIL message accordingly
    expected_colnames <- c("id", "name", "latestData", "lat", "lon")

    if (all(colnames(df) == expected_colnames) == TRUE) {
      print("PASS: Data has the correct columns")
    } else {
      print("FAIL: Columns do not match the correct specification")
    }
  }

test_stations_metadata_nrows <-
  function(df) {
    # The function checks if the data frame has a reasonable number of rows
    # between 5000 and 10000 rows and prints a PASS or FAIL message accordingly
    min_expected_rows <- 5000
    max_expected_rows <- 10000

    if (nrow(df) > min_expected_rows & nrow(df) < max_expected_rows) {
      print("PASS: Data has a reasonable number of rows")
    } else if (nrow(df) <= min_expected_rows) {
      print("FAIL: Data has suspiciously few rows")
    } else {
      print("FAIL: Data has suspiciously many rows")
    }
  }

test_stations_metadata_coltypes <-
  function(df) {
    # The function checks if the data frame has the correct column types
    # and prints a PASS or FAIL message accordingly
    expected_coltypes <-
      c("character", "character", "double", "double", "double")

    if (all(df %>%
      map_chr(~ typeof(.)) == expected_coltypes) == TRUE) {
      print("PASS: All cols have the correct specifications")
    } else {
      print("FAIL: Columns do not have the correct specification")
    }
  }

test_stations_metadata_nmissing <-
  function(df) {
    # The function checks if the data frame has too many missing values
    # and prints a PASS or FAIL message accordingly
    max_miss_vals <- 200

    if (df %>% map_int(~ sum(is.na((.)))) %>% sum(.) < max_miss_vals) {
      print("PASS: Amount of missing values is reasonable")
    } else {
      print("FAIL: Too many missing values in data set")
    }
  }

test_stations_metadata_latestdata_timezone <-
  function(df) {
    # The function checks if the data frame has the correct time zone
    # and prints a PASS or FAIL message accordingly
    if (attr(df$latestData, "tzone") == "UTC") {
      print("PASS: latestData has UTC-time zone")
    } else {
      print("FAIL: latestData does not have expected UTC-time zone")
    }
  }


test_stations_metadata <-
  function(df) {
    # The function applies all tests to the data frame
    test_stations_metadata_colnames(df)
    test_stations_metadata_coltypes(df)
    test_stations_metadata_nmissing(df)
    test_stations_metadata_nrows(df)
    test_stations_metadata_latestdata_timezone(df)
  }
