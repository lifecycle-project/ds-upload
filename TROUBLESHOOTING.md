# TROUBLESHOOTING
All kinds of stuff can go wrong 

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

