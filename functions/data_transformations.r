transform_metadata_to_df <- function(stations_metadata) {
  stations_metadata[[1]] |>
    map(as_tibble) |>
    list_rbind() |>
    mutate(latestData = map_chr(latestData, 1, .default = NA_character_)) |>
    mutate(latestData = as_datetime(latestData, tz = "UTC")) |>
    unnest_wider(location) |>
    unnest_wider(latLon)
}

to_iso8601 <- function(date, offset) {
  paste(format_ISO8601(date + days(offset)), "Z", sep = "")
}


transform_volumes <- function(traffic_data) {
  list_of_tibbles <- map(traffic_data$trafficData$volume$byHour$edges, ~ {
    .x$node |>
      as_tibble() |>
      unnest_wider(total) |>
      select(from, volume)
  })

  final_tibble <- bind_rows(list_of_tibbles)

  return(final_tibble)
}
