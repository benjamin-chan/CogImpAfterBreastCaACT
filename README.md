# Cognitive Impairment
[Benjamin Chan](http://careers.stackoverflow.com/benjaminchan)  
`r Sys.time()`  

`source` the R script, `make.R` to generate the project document.

```
> source("make.R")
```

This document was generated on **2015-12-11 21:23:17**.


# Project repository

*Live* version is stored here. *Static* version is this document.

* [Main](https://github.com/benjamin-chan/AEAfterBreastCaACT)
    * [Wiki](https://github.com/benjamin-chan/AEAfterBreastCaACT/wiki)
    * [Issues](https://github.com/benjamin-chan/AEAfterBreastCaACT/issues)
* Cognitive Impairment adverse event
    * [Wiki](https://github.com/benjamin-chan/AEAfterBreastCaACT/wiki/Cognitive-impairment)
    * [Meta-analysis](https://github.com/benjamin-chan/AEAfterBreastCaACT/tree/master/CognitiveImpairment#pooled-effects-by-domain)
    * [Forest plots](https://github.com/benjamin-chan/AEAfterBreastCaACT/tree/master/CognitiveImpairment#plots-of-effect-sizes-by-domain)
    * [Funnel plots](https://github.com/benjamin-chan/AEAfterBreastCaACT/tree/master/CognitiveImpairment#plots-to-assess-publication-bias)


This document is for the **Cognitive Impairment** topic.

For other topics, see links from the project [repository](https://github.com/benjamin-chan/AEAfterBreastCaACT).


# Scripts

Sequence of scripts:



prologue.Rmd %>% runMetaAnalysis.Rmd %>% epilogue.Rmd

<!--html_preserve--><div id="htmlwidget-4558" style="width:192px;height:480px;" class="grViz"></div>
<script type="application/json" data-for="htmlwidget-4558">{ "x": {
 "diagram": "digraph {\n\ngraph [layout=dot]\n\nnode [fontname=\"Lato\"]\n\n  \"a\" [label = \"prologue.Rmd\", style = \"filled\", fontcolor = \"white\", color = \"#014386ff\", shape = \"oval\"] \n  \"b\" [label = \"runMetaAnalysis.Rmd\", style = \"filled\", fontcolor = \"white\", color = \"#014386ff\", shape = \"oval\"] \n  \"c\" [label = \"epilogue.Rmd\", style = \"filled\", fontcolor = \"white\", color = \"#014386ff\", shape = \"oval\"] \n  \"a\"->\"b\" \n  \"b\"->\"c\" \n}",
"config": {
 "engine": "dot",
"options": null 
} 
},"evals": [  ] }</script><!--/html_preserve-->


# Prologue

1. Set path of input data sources
1. Load [`devtools`](https://github.com/hadley/devtools)
1. Source the [`loadPkg`](https://gist.github.com/benjamin-chan/3b59313e8347fffea425) function
1. Load packages
1. Source the [`makeMetadata`](https://gist.github.com/benjamin-chan/091209ab4eee1f171540) function
1. Start the job timer


```
## Sourcing https://gist.githubusercontent.com/benjamin-chan/3b59313e8347fffea425/raw/84a146f3cde6330b901521710d513fa9d0b96951/loadPkg.R
## SHA-1 hash of file is 7bdcd4569a86aa9fff8ced241327992c550a16ce
## Sourcing https://gist.githubusercontent.com/benjamin-chan/091209ab4eee1f171540/raw/5043f40fb0c15036b0ce53079045d7d1beae5609/makeMetadata.R
## SHA-1 hash of file is 66a9fa7f31fa5e4e4448ed18f18db768a1c5a70f
```

# Meta-analysis

Cognitive impairment is modeled with a multilevel mixed effects model.
Fixed effect for cognitive domain is modeled, one effect size for each of the 8 domains.
The random effects model assumes each data point is a random observation from a large population of studies.
The single-level random effects model additionally assumes each data point is independent.
The multilevel random effects model relaxes the independence assumption,
allowing for data points to be correlated.
In our study, we have multiple measurements within cognitive domain.
So, data points are correlated within study.

Models were estimated using the `rma.mv()` function from the `metafor` package for R.
[Viechtbauer](http://www.jstatsoft.org/v36/i03/), W. (2010).
Conducting meta-analyses in R with the metafor package. *Journal of Statistical Software*, 36(3), 1-48.

Load tidy data.


```r
f <- sprintf("%s/%s", pathOut, "AllStudies.RData")
load(f, verbose=TRUE)
```

```
## Loading objects:
##   D
##   metadata
```

```r
metadata$timeStamp
```

```
## [1] "2015-12-11 14:55:19 PST"
```

```r
metadata$colNames
```

```
##  [1] "author"             "domain"             "test"              
##  [4] "isHigherWorse"      "scoreType"          "monthsPostTxPre"   
##  [7] "treatmentGroupPre"  "nPre"               "meanPre"           
## [10] "sdPre"              "monthsPostTxPost"   "treatmentGroupPost"
## [13] "nPost"              "meanPost"           "sdPost"            
## [16] "yi"                 "vi"
```

Remove studies with missing data.


```r
unique(D[is.na(yi), .(author, domain, test, yi)])
```

```
##    author              domain     test yi
## 1:    Fan Attn/Wkg Mem/Concen Trails A NA
## 2:    Fan            Exec Fxn Trails B NA
```

```r
D <- D[!is.na(yi)]
```

## Pooled domain effects


```r
M <- rma.mv(yi ~ domain - 1,
            vi,
            random = list(~ test | author,
                          ~ 1 | author),
            struct=c("CS", "ID"),
            data=D,
            slab=sprintf("%s: %s", author, test))
```


```r
summary <- data.frame(studies = D[, .(studies = uniqueN(author)), domain][, studies],
                      tests = D[, .N, domain][, N],
                      M[c("b", "se", "zval", "pval", "ci.lb", "ci.ub")])
rownames(summary) <- gsub("domain", "", rownames(summary))
print(xtable(summary, digits=c(0, rep(0, 2), rep(3, 3), 4, rep(3, 2))), type="html")
```

<!-- html table generated in R 3.2.2 by xtable 1.7-4 package -->
<!-- Fri Dec 11 21:23:20 2015 -->
<table border=1>
<tr> <th>  </th> <th> studies </th> <th> tests </th> <th> b </th> <th> se </th> <th> zval </th> <th> pval </th> <th> ci.lb </th> <th> ci.ub </th>  </tr>
  <tr> <td align="right"> Attn/Wkg Mem/Concen </td> <td align="right"> 8 </td> <td align="right"> 41 </td> <td align="right"> 0.018 </td> <td align="right"> 0.071 </td> <td align="right"> 0.253 </td> <td align="right"> 0.8006 </td> <td align="right"> -0.122 </td> <td align="right"> 0.158 </td> </tr>
  <tr> <td align="right"> Exec Fxn </td> <td align="right"> 6 </td> <td align="right"> 14 </td> <td align="right"> 0.095 </td> <td align="right"> 0.114 </td> <td align="right"> 0.838 </td> <td align="right"> 0.4023 </td> <td align="right"> -0.127 </td> <td align="right"> 0.318 </td> </tr>
  <tr> <td align="right"> Info Proc Speed </td> <td align="right"> 6 </td> <td align="right"> 10 </td> <td align="right"> 0.101 </td> <td align="right"> 0.132 </td> <td align="right"> 0.761 </td> <td align="right"> 0.4467 </td> <td align="right"> -0.159 </td> <td align="right"> 0.360 </td> </tr>
  <tr> <td align="right"> Motor Speed </td> <td align="right"> 4 </td> <td align="right"> 10 </td> <td align="right"> -0.069 </td> <td align="right"> 0.139 </td> <td align="right"> -0.500 </td> <td align="right"> 0.6168 </td> <td align="right"> -0.341 </td> <td align="right"> 0.203 </td> </tr>
  <tr> <td align="right"> Verb Ability/Lang </td> <td align="right"> 5 </td> <td align="right"> 10 </td> <td align="right"> 0.275 </td> <td align="right"> 0.134 </td> <td align="right"> 2.046 </td> <td align="right"> 0.0408 </td> <td align="right"> 0.012 </td> <td align="right"> 0.538 </td> </tr>
  <tr> <td align="right"> Verb Mem </td> <td align="right"> 6 </td> <td align="right"> 17 </td> <td align="right"> 0.515 </td> <td align="right"> 0.108 </td> <td align="right"> 4.751 </td> <td align="right"> 0.0000 </td> <td align="right"> 0.303 </td> <td align="right"> 0.727 </td> </tr>
  <tr> <td align="right"> Vis Mem </td> <td align="right"> 4 </td> <td align="right"> 11 </td> <td align="right"> 0.646 </td> <td align="right"> 0.140 </td> <td align="right"> 4.634 </td> <td align="right"> 0.0000 </td> <td align="right"> 0.373 </td> <td align="right"> 0.920 </td> </tr>
  <tr> <td align="right"> Visuospatial </td> <td align="right"> 4 </td> <td align="right"> 4 </td> <td align="right"> 0.299 </td> <td align="right"> 0.216 </td> <td align="right"> 1.382 </td> <td align="right"> 0.1670 </td> <td align="right"> -0.125 </td> <td align="right"> 0.723 </td> </tr>
   </table>


```r
summary(M)
```

```
## 
## Multivariate Meta-Analysis Model (k = 117; method: REML)
## 
##   logLik  Deviance       AIC       BIC      AICc  
## -97.2434  194.4868  216.4868  246.0917  219.2085  
## 
## Variance Components: 
## 
##             estim    sqrt  nlvls  fixed  factor
## sigma^2    0.0446  0.2113      8     no  author
## 
## outer factor: author (nlvls = 8)
## inner factor: test   (nlvls = 110)
## 
##              estim    sqrt  fixed
## tau^2       0.0791  0.2812     no
## rho        -0.5361             no
## 
## Test for Residual Heterogeneity: 
## QE(df = 109) = 397.1480, p-val < .0001
## 
## Test of Moderators (coefficient(s) 1,2,3,4,5,6,7,8): 
## QM(df = 8) = 48.5833, p-val < .0001
## 
## Model Results:
## 
##                            estimate      se     zval    pval    ci.lb
## domainAttn/Wkg Mem/Concen    0.0180  0.0714   0.2526  0.8006  -0.1218
## domainExec Fxn               0.0951  0.1135   0.8375  0.4023  -0.1274
## domainInfo Proc Speed        0.1006  0.1322   0.7609  0.4467  -0.1585
## domainMotor Speed           -0.0694  0.1388  -0.5004  0.6168  -0.3414
## domainVerb Ability/Lang      0.2750  0.1344   2.0458  0.0408   0.0115
## domainVerb Mem               0.5150  0.1084   4.7512  <.0001   0.3026
## domainVis Mem                0.6464  0.1395   4.6335  <.0001   0.3730
## domainVisuospatial           0.2992  0.2165   1.3819  0.1670  -0.1252
##                             ci.ub     
## domainAttn/Wkg Mem/Concen  0.1579     
## domainExec Fxn             0.3176     
## domainInfo Proc Speed      0.3597     
## domainMotor Speed          0.2025     
## domainVerb Ability/Lang    0.5385    *
## domainVerb Mem             0.7275  ***
## domainVis Mem              0.9198  ***
## domainVisuospatial         0.7235     
## 
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```


Save working data tables to file.


```r
metadata <- makeMetadata(D)
f <- sprintf("%s/%s", pathOut, "metaAnalysisCognitiveImpairment.RData")
save(D, metadata, M, summary, file=f)
message(sprintf("%s saved on: %s\nFile size: %s KB", 
                f,
                file.mtime(f),
                file.size(f) / 1e3))
```

```
## Output/metaAnalysisCognitiveImpairment.RData saved on: 2015-12-11 21:23:21
## File size: 49.624 KB
```

```r
f <- sprintf("%s/%s", pathOut, "metaAnalysisCognitiveImpairment-Data.csv")
write.csv(D, file=f, row.names=FALSE)
f <- sprintf("%s/%s", pathOut, "metaAnalysisCognitiveImpairment-summary.csv")
write.csv(summary, file=f, row.names=FALSE)
```


## Plot of effect sizes

The `xlim` settings require fine-tuning.




```
## png 
##   2
```

Full resolution file is [here](Output/forest.png).


## Plot to assess publication bias

See [*BMJ* 2011;342:d4002](http://www.bmj.com/content/343/bmj.d4002) for a guide to interpret funnel plots.

![](index_files/figure-html/funnel-1.png) 

# Epilogue


```
## Sourcing https://gist.githubusercontent.com/benjamin-chan/80149dd4cdb16b2760ec/raw/a1fafde5c5086024dd01d410cc2f72fb82e93f26/sessionInfo.R
## SHA-1 hash of file is 41209357693515acefb05d4b209340e744a1cbe4
```

```
## $timeStart
## [1] "2015-12-11 21:23:19"
## 
## $timeEnd
## [1] "2015-12-11 21:23:24 PST"
## 
## $timeElapsed
## [1] "4.242946 secs"
## 
## $Sys.info
##        sysname        release        version       nodename        machine 
##      "Windows"        "7 x64"   "build 9200"     "FAMILYPC"       "x86-64" 
##          login           user effective_user 
##          "Ben"          "Ben"          "Ben" 
## 
## $sessionInfo
## R version 3.2.2 (2015-08-14)
## Platform: x86_64-w64-mingw32/x64 (64-bit)
## Running under: Windows 8 x64 (build 9200)
## 
## locale:
## [1] LC_COLLATE=English_United States.1252 
## [2] LC_CTYPE=English_United States.1252   
## [3] LC_MONETARY=English_United States.1252
## [4] LC_NUMERIC=C                          
## [5] LC_TIME=English_United States.1252    
## 
## attached base packages:
## [1] stats     graphics  grDevices utils     datasets  methods   base     
## 
## other attached packages:
##  [1] extrafont_0.17     DiagrammeR_0.8     metafor_1.9-9     
##  [4] Matrix_1.2-2       xtable_1.7-4       haven_0.2.0       
##  [7] googlesheets_0.1.0 openxlsx_3.0.0     data.table_1.9.6  
## [10] devtools_1.7.0    
## 
## loaded via a namespace (and not attached):
##  [1] Rcpp_0.11.6       cellranger_1.0.0  formatR_1.2      
##  [4] bitops_1.0-6      tools_3.2.2       digest_0.6.8     
##  [7] jsonlite_0.9.16   evaluate_0.8      lattice_0.20-33  
## [10] DBI_0.3.1         rstudioapi_0.3.1  yaml_2.1.13      
## [13] parallel_3.2.2    Rttf2pt1_1.3.3    dplyr_0.4.3      
## [16] httr_0.6.1        stringr_1.0.0     knitr_1.11       
## [19] htmlwidgets_0.3.2 grid_3.2.2        R6_2.0.1         
## [22] rmarkdown_0.8     RJSONIO_1.3-0     extrafontdb_1.0  
## [25] magrittr_1.5      htmltools_0.2.6   assertthat_0.1   
## [28] stringi_0.4-1     RCurl_1.95-4.6    chron_2.3-47
```
