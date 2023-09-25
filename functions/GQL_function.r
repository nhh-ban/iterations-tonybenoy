
# This script contains a function for posting GraphQL-queries. 
# 
# In order to use the function you must have the following 
# packages loaded: 
# httr
# jsonlite

GQL <- function(query,
                ...,
                .token = NULL,
                .variables = NULL,
                .operationName = NULL,
                .url = url) {
  pbody <-
    list(query = query,
         variables = .variables,
         operationName = .operationName)
  if (is.null(.token)) {
    res <- POST(.url, body = pbody, encode = "json", ...)
  } else {
    auth_header <- paste("bearer", .token)
    res <-
      POST(
        .url,
        body = pbody,
        encode = "json",
        add_headers(Authorization = auth_header),
        ...
      )
  }
  res <- content(res, as = "parsed", encoding = "UTF-8")
  if (!is.null(res$errors)) {
    warning(toJSON(res$errors))
  }
  res$data
}
