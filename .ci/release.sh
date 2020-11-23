#!/bin/bash

Rscript -e "usethis::use_version('${RELEASE_SCOPE}')"
TAG=$(grep Version DESCRIPTION | head -n1 | cut -d':' -f2)
PACKAGE=$(grep Package DESCRIPTION | head -n1 | cut -d':' -f2)
git commit -a -m 'Created release: ${TAG}'
echo "Releasing ${PACKAGE} v${TAG}"
R CMD build .
Rscript -e 'devtools::check_built(path = "./${PACKAGE}_${TAG}.tar.gz", remote=TRUE, force_suggests = TRUE)'
set +x; curl -v --user '${NEXUS_USER}:${NEXUS_PASS}' --upload-file ${PACKAGE}_${TAG}.tar.gz ${REGISTRY}/src/contrib/${PACKAGE}_${TAG}.tar.gz
git tag v${TAG}
git push --tags origin master
echo "Creating new development version"
Rscript -e "usethis::use_version('dev')"
git commit -a -m 'Increment dev-version number'
git push --tags origin master