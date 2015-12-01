f <- "make.log"
sink(f)
rmarkdown::render("MASTER.Rmd")
file.rename("MASTER.html", "index.html")
file.rename("MASTER.md", "README.md")
file.info("index.html")
sink(NULL)
