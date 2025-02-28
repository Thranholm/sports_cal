## Pakker og api info

rm(list = ls())

library(pacman)
p_load(tidyverse, httr2, jsonlite, calendar, gmailr)


base_url <- "https://allsportsapi2.p.rapidapi.com/api"

header <- c("X-RapidAPI-Host" = "allsportsapi2.p.rapidapi.com",
            "X-RapidAPI-Key" = secret_decrypt(Sys.getenv("PASS"), "FODBOLD_KEY"))


