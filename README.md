[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-24ddc0f5d75046c5622901739e7c5dd533143b0c8e959d652212380cedb1ea36.svg)](https://classroom.github.com/a/mJpP5ERB)
# :wave: Welcome to the iteration assignment in BAN400!
This is the iteration assignment in BAN400. As you know -- given that you have come this far -- the assignments in BAN400 will be organized through Github and Github Classroom. By accepting this assignment, the repository will be copied to your Github user so that you can clone it to your own personal machine and work on it. Then, you simply commit your changes and push back to Github when you are done. You can commit and push as much as you want before the deadline.

**Date:**

**Name:**

**Student number:**

## :information_source: Problem 1
Update the personal information above.

## :milky_way: Problem 2

In the lecture we worked with road traffic sensor data from Vegvesenet. This repo contains similar items as we used in class: 

- The script `iterations.r` contains code with the same functionality as the code discussed in class. However, 
this file calls some other files for loading in functions - see explanations in following bullet points. 
- The file `functions/GQL_function.r` contains the GQL-function we used in class for posting GQL-queries and reading data
- `vegvesen_configs.yml` contains configs for the project. Currently only the url to the Vegvesen-API. 
- The folder `gql_queries` has the gql-queries we'll use stored as separate files. Currently only the metadata query in  `station_metadata.gql`. 

If you run the code in `iterations.r` up to seciton *2: Transforming metadata* you will get an object in memory with data on all the Vegvesen-sensors. We want this data over to a data-frame format. In the first assignment, you should: 

- Add a *new file* in the `functions`-folder called `data_transformations.r`. 
- This file should contain a *function* called `transform_metadata_to_df`. 
- The function `transform_metadata_to_df` should complete the transformation of `stations_metadata` to a data frame that looks similar to the example rows below: 

Note that `latestData` should be converted to *UTC* format. 

```
# A tibble: 4,444 x 6
   id            name                          latestData            lat   lon
   <chr>         <chr>                         <dttm>              <dbl> <dbl>
 1 97411V72313   Myrsund                       2022-05-08 00:00:00  63.4 10.2 
 2 20036V605081  PILESTREDET                   2009-11-22 00:00:00  59.9 10.7 
 3 01492V971789  GRENSEN ENDE                  2015-11-12 00:00:00  59.0 11.5 
 4 54013V2352341 ØRGENVIKAKRYSSET RAMPE NORDG. 2022-05-08 00:00:00  60.3  9.68
 5 15322V971307  STOREBAUG                     2022-05-08 00:00:00  59.4 10.7 
```

After completing this assignment you should verify that you can run the lines below in `iterations.r`. 

```r
source("functions/data_transformations.r")

stations_metadata_df <- 
  stations_metadata %>% 
  transform_metadata_to_df(.)
```

## :milky_way: Problem 3: Testing metadata

When developing code, we should write *test* that verify that the results from our calculations
were indeed as we expected (more on this later in the course!). 

The file `functions/data_tests.r` contains tests to be applied to `stations_metadata_df`. Your tasks 
are the following: 

1. The functions in `functions/data_tests.r` are missing comments. Add a brief comment to *each* function, briefly explaining the purpose of each function. 
2. Verify that you have solved assignment 2 correctly by running lines `44-46` in `iterations.r`.

If you have solved assignment 2 and 3, you should see four lines starting with "PASS" (see below). If 
you see anything else, a test has failed, and you should go back to assignment 2 and improve your code. 

```
[1] "PASS: Data has the correct columns"
[1] "PASS: All cols have the correct specifications"
[1] "PASS: Amount of missing values is reasonable"
[1] "PASS: Data has a reasonable number of rows"
[1] "PASS: latestData has UTC-time zone"
```


## :car: Problem 4 - getting volume data

In the following exercises, we'll extract volume data from the Vegvesenet API, based
on the station metadata from assignment 1-3. You can try to go to 
www.vegvesen.no/trafikkdata/api, and execute the query below: 

```
{
  trafficData(trafficRegistrationPointId: "97411V72313") {
    volume {
      byHour(from: "2022-05-01T06:55:47Z", to: "2022-05-08T06:55:47Z") {
        edges {
          node {
            from
            to
            total {
              volumeNumbers {
                volume
              }
            }
          }
        }
      }
    }
  }
}
```



This query gives you hourly traffic volumes (i.e. count of cars) for a given station 
with id 97411V72313. Note also that the query has an argument for time - i.e. which 
time period we want data. There are limitations on the API, so we can only 
extract a few days of data. 


The end goal is to have an easy way of plotting volume data for *any* of the 
stations currently in `stations_df`. Let's break this task down into 
components: 

### Task 4a - time-function

- Add a function to the file `functions/data_transformations.r` called `to_iso8601` 
- The function should take *two* arguments: a date time variable and an offset measured in days. 
- The function should *return* the date time variable in ISO8601 format, with the offset added. There should be a letter "Z" appended to the end of the date string, to indicate the the time zone is UTC. 

As examples, calling
```r
to_iso8601(as_datetime("2016-09-01 10:11:12"),0)
```

should return 
```
[1] "2016-09-01T10:11:12Z"
```

and 
```r
to_iso8601(as_datetime("2016-09-01 10:11:12"),-4)
```
should return 
```
[1] "2016-08-28T10:11:12Z"
```

*(Hint: look at the functions iso8601 from the anytime-package, and days from lubridate)*

- We need a function that can create from- and to times as strings. The time formats of the vegvesen-api are different than the ones we have stored. So we need a method for converting times in `stations_metadata_df` into the Vegvesen-format. 
- We need a function that creates volume queries similar to the one above, 
but where station id and from- and to-dates are inserted as arguments.


### Task 4b - GQL for volumes

We can now write a GQL-function. Write a function ``vol_qry(id, from, to)``. The function should return a query similar to the one listed above, but where the values of the arguments  `id`, `from` and `to` replace `97411V72313`, `2022-05-01T06:55:47.172Z` and `2022-05-08T06:55:47.172Z` respectively. 


Once you have completed this assignment, *verify* that it works by calling 

```r 
GQL(
  vol_qry(
    id=stations_metadata_df$id[1], 
    from=to_iso8601(stations_metadata_df$latestData[1],-4),
    to=to_iso8601(stations_metadata_df$latestData[1],0)
  ),
  .url = configs$vegvesen_url
)

```

*Save* the function as a file `vol_qry.r` in folder `gql-queries` (check that you can run line 51 in `iterations.r`). 

*Hints: use the function ``glue::glue()`` to replace the relevant items in the string. Note that braces are usually identifiers of values to replace - this does not work well with graphQL-queries! See particularly the arguments `.open` and `.close`.*



## Task 5 - finalizing a traffic volume call!

After completing task number 5 you should be able to run the entire `iterations.r`-script. In order to do that you must add a function `transform_volumes()` (see line 62) to the file `functions/data_transformations.r`, that transforms the json-return from the API to a data frame that can be used for plotting. 



## Task 6 - making the plot prettier

The plotting function in task 5 plots a volumes from a random station. Make changes as necessary so that we have appropriate legends to the plot - particularly the name of the traffic station. 