#!/bin/bash

if [[ ${TRAVIS_COMMIT_MESSAGE} =~ "[release skip]" ]]; then
  git checkout master
  Rscript -e "usethis::use_version('${RELEASE_SCOPE}')"
  TAG=$(grep Version DESCRIPTION | head -n1 | cut -d':' -f2 | xargs)
  PACKAGE=$(grep Package DESCRIPTION | head -n1 | cut -d':' -f2 | xargs)
  git commit -a -m "[release skip] Created release: ${TAG}"
  echo "Releasing ${PACKAGE} ${TAG}"
  R CMD build .
  Rscript -e "devtools::check_built(path = './${PACKAGE}_${TAG}.tar.gz', remote=TRUE, force_suggests = TRUE)"
  set +x; curl -v --user "${NEXUS_USER}:${NEXUS_PASS}" --upload-file "${PACKAGE}_${TAG}".tar.gz "${REGISTRY}"/src/contrib/"${PACKAGE}_${TAG}".tar.gz
  git tag "${TAG}"
  git push origin "${TAG}"
  echo "Creating new development version"
  Rscript -e "usethis::use_version('dev')"
  git commit -a -m '[ci skip]: Increment dev-version number'
  git push origin master
fi