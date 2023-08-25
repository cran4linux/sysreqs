#!/usr/bin/Rscript

sreqs <- read.csv("sysreqs.csv", na.strings="")
pkgdb <- read.csv("pkgdb.csv", na.strings="")

check <- function(type, sreqs.v, pkgdb.v) {
  if (any(miss <- !pkgdb.v %in% sreqs.v))
    message("Undefined ", type, " sysreqs:\n",
            paste("  -", pkgdb.v[miss], collapse="\n"))

  if (any(miss <- !sreqs.v %in% pkgdb.v))
    message("Unused ", type, " sysreqs:\n",
            paste("  -", sreqs.v[miss], collapse="\n"))
}

check("build", subset(sreqs, build)$name,
      sort(unique(do.call(c, strsplit(na.omit(pkgdb$build), " ")))))
check("run", subset(sreqs, run)$name,
      sort(unique(do.call(c, strsplit(na.omit(pkgdb$run), " ")))))
