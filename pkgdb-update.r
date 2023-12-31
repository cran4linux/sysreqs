#!/usr/bin/Rscript

dbnm <- "pkgdb.csv"
deps <- read.csv(dbnm, na.strings="")
cran <- tools::CRAN_package_db()[, c("Package", "SystemRequirements")]
cran <- cran[!duplicated(cran), ]

pgsub <- function(x, pattern, replacement, ...) gsub(pattern, replacement, x, ...)
creplace <- function(x, pattern, replacement) replace(x, x==pattern, replacement)

cran$SystemRequirements <- cran$SystemRequirements |>
  pgsub("\n", "") |> # newline
  pgsub(" [\\(]*[>= \\.[:digit:]]+[\\)]*", "") |> # versions
  pgsub("C\\+\\+[[:digit:]]+[,;.]*", "") |> # C++xx
  pgsub("GNU [mM]ake[,;]*", "") |>
  pgsub("gfortran[,;]*", "") |>
  pgsub("gcc[,;]*", "") |>
  pgsub("clang[\\+,;]*", "") |>
  trimws() |>
  creplace("", NA)

cran <- na.omit(cran) |>
  merge(deps[, c("name", "revised", "comment")], by.x="Package", by.y="name", all=TRUE) |>
  transform(revised = is.na(SystemRequirements) | (
    !is.na(revised) & revised & SystemRequirements == comment)) |>
  transform(comment = SystemRequirements) |>
  transform(SystemRequirements = NULL)

deps <- merge(deps[, 1:3], cran, by.x="name", by.y="Package", all=TRUE)
data.table::fwrite(deps, dbnm)
