setwd("~/Projects/CogImpAfterBreastCaACT")
library(checkpoint)
checkpoint("2016-07-05", use.knitr = TRUE)
f <- "make.log"
sink(f)
rmarkdown::render("MASTER.Rmd", output_file="index.html")
file.rename("index.md", "README.md")
file.info(c("index.html", "README.md"))
sink(NULL)
