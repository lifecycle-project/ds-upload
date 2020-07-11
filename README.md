![Build status](https://travis-ci.org/lifecycle-project/analysis-protocols.svg?branch=master)

# DataSHIELD upload tools
This is a collections of tools used to upload data into DataSHIELD backends. It aids data mangers in the initial stages of uploading data to DataSHIELD backends.

## Usage
Please check the [references](./references/index.html) and [articles](./articles/index.html) above.

## Troubleshooting
Please check the [troubleshooting guide]().

## Adding new variables
Please check: [adding new variables](https://github.com/lifecycle-project/ds-dictionaries/blob/master/README.md)

## Releases
Releasing the artifact can be done by curling to the following address:

**For source packages**

```bash
curl -v --user 'user:password' --upload-file dsUpload_3.0.0.tar.gz https://registry.molgenis.org/repository/r-hosted/src/contrib/dsUpload_3.0.0.tar.gz 
```

*URL clarification: https://registry.molgenis.org/repository/r-hosted/src/contrib/*package_version*.tar.gz*

**For binary packages**

First upload the source package to https://win-builder.r-project.org/
Then download the zip-file build bij win-builder. Then upload it into the registry by executing this command:

```bash
curl -v --user 'user:password' --upload-file dsUpload_3.0.0.zip https://registry.molgenis.org/repository/r-hosted/bin/windows/contrib/3.6/dsUpload_3.0.0.zip
```

*URL clarification: https://registry.molgenis.org/repository/r-hosted/bin/windows/contrib/*r-version*/*package_version*.zip*

Also create a git-tag and push this to the remote, based upon the `dsUpload` DESCRIPTION-file.

```
git tag x.x.x
git push origin tags/x.x.x
```

This is used to download the data dictionaries, so do not forget to do this!

Soon this wqill be replaced by travis-ci.
