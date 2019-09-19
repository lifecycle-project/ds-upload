# TROUBLESHOOTING
All kinds of stuff can go wrong 

## Install R
You need to have R installed on your system. This differs per operating system.

**For Windows**
Get R from: https://cran.r-project.org/bin/windows/base/. More specifically: https://cran.r-project.org/bin/windows/base/R-3.6.1-win.exe.

You can install the package with the default settings. 

**For Mac**
Get R from: https://cran.r-project.org/bin/macosx/. More specifically: https://cran.r-project.org/bin/macosx/R-3.6.1.pkg.

You can install the package with the default settings. 

**RStudio**
RStudio is nice to have but not a necessity. You can download it here: https://www.rstudio.com/products/rstudio/download/#download.

## Update your R version in RStudio
Sometimes you run an old version of R. You need to upgrade whenever that happens to the latest version. This will be different for Windows and Mac.

**For Windows**
Goto *Start* --> *Type 'R' within the Run field*. 
Click on *R x.x.x* to get to the commandline interface

```R
install.packages("installr") 
library(installr)

updateR()
```

You will get a wizard, please choose all the defaults and proceed with the installation.

**For Mac**

