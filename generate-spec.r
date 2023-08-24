#!/usr/bin/Rscript

format_requires <- function(df) {
  do.call(c, lapply(names(df), function(i) {
    distros <- strsplit(i, "_")[[1]]
    c(paste0("%if", paste0("0%{?", distros, "}", collapse=" || ")),
      sprintf("Requires:       %s", na.omit(df[[i]])),
      "%endif")
  }))
}

replace_pattern <- function(x, pattern, replacement) {
  idx <- grep(pattern, x)
  c(x[1:(idx-1)], replacement, x[(idx+1):length(x)])
}

sreq <- read.csv("sysreqs.csv", na.strings="") |> subset(build)
type <- read.csv("types.csv") |> subset(name %in% unique(sreq$type))

reqs <- c(
  sprintf("Requires:       %%{name}-%-8s= %%{version}-%%{release}", type$name),
  "", format_requires(subset(sreq, is.na(type))[,-(1:4)])
)

pkgs <- do.call(c, apply(type, 1, function(x) {
  c(sprintf("%%package        %s", x["name"]),
    sprintf("Summary:        %s", x["description"]),
    "BuildArch:      noarch",
    "", format_requires(subset(sreq, type==x["name"])[,-(1:4)]), "",
    sprintf("%%description %s", x["name"]),
    sprintf("%s.", x["description"]), "")
}, simplify=FALSE))

fils <- paste0("%files ", type$name, "\n", collapse="\n")

readLines("R-build-deps.spec.in") |>
  replace_pattern("@requires@", reqs) |>
  replace_pattern("@subpackages@", pkgs) |>
  replace_pattern("@files@", fils) |>
  writeLines("R-build-deps.spec")
