## Unreleased
 - 

##  2016-06-29 1.2.0
### Summary
This release contains updates for testing including platform test matrix.

#### Features
 - drop testing on old Puppet 3.x versions, keeping only 3.8.7
 - improve manifest test coverage

## 2016-06-20 1.1.0
### Summary
This release contains a change in dependency for sysctl.  The two modules
should co-exist without issue, but the new dependency must be present.

#### Features
 - drop duritong/sysctl in favor of herculesteam-augeasproviders_sysctl

## 2016-05-19 1.0.0
### Summary
This release contains a backwards incompatible dependency change.  Please see
the metadata for the new dependency list.

#### Features
 - drop shell_config in favor of augeas_providers
 - begin changelog
