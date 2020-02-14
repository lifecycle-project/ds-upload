#!/usr/bin/env sh

choco install -y r.project &&
  export R_VERSION=`ls 'C:\Program Files\R\'` &&
    export PATH=$PATH:';C:\Program Files\R\'$R_VERSION'\bin\x64' &&
echo 'options(repos = "https://cloud.r-project.org")' > ~/.Rprofile.site &&
export R_PROFILE=~/.Rprofile.site &&

curl -Ls https://cran.r-project.org/bin/windows/Rtools/Rtools35.exe && 
Rtools.exe /VERYSILENT /SP- /NORESTART &&
Rscript.exe -e 'sessionInfo()' &&
Rscript.exe -e 'install.packages(c("devtools"));if (!all("devtools" %in% installed.packages())) { q(status = 1, save = "no")}' &&
Rscript.exe -e 'deps <- devtools::dev_package_deps(dependencies = NA);devtools::install_deps(dependencies = TRUE)' &&
Rscript.exe -e 'devtools::session_info(installed.packages()[, "Package"])' &&


export PKG_TARBALL="$(perl -ne '$version = $1 if (/^Version:\s(\S+)/); $package = $1 if (/^Package:\s*(\S+)/); END { print "${package}_$version.tar.gz" }' DESCRIPTION)" 