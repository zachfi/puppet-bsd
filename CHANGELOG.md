## Unreleased

## 2019-08-15 2.4.0
 - tidy up ruby style
 - fix issue with cloned interface detection for multi-digit interface names

## 2018-02-10 2.2.1
### Summary

Fixes to usage of raw_values for interfaces on FreeBSD.

## 2018-02-10 2.2.0
### Summary

This release contains adjustments to dependencies and new files to support
pushing released versions to the forge.

## 2017-10-15 2.1.1
### Summary
This release contains fixes to cloned_interfaces to ensure proper detection of
those interfaces that need to be created at boot.

## 2017-09-30 2.1.0
### Summary
This release contains improvements to FreeBSD support to include lagg(4)
support through the trunk classes, and fixes addressing issues on the vlan
interfaces for FreeBSD.

## 2016-11-10 2.0.0
### Summary
This release contains contains backwards incompatible parameter name and data
type changes.  Also here, is native Puppet 4 support, dropping Puppet 3
support, and lots of plumbing changes to make configuration validation a bit
cleaner.

#### Features
  - Drop Puppet 3.x support, leveraging native Puppet 4.x type validation
    - Validation change, VLAN IDs are now integers.
    - Validation change, address parameters are arrays.
  - The old 'values' param has been renamed to 'raw_values' to make it clear
    that the items will be written unmodified.
  - Library code has been much improved, centralizing the configuration
    validation between the BSDs to allow for easier addition of interface
    types, or future configuration changes.  The PuppetX::BSD::PuppetInterface
    parent class is now used to create a new interface type and provide the
    necessary validation.  This reduces the interface type specific code
    considerably.
  - 'network_key' has been renamed to 'wpa_key' on wifi interfaces
  - Add support for managing interface MTU

#### Bugfixes
  - Fix an issue where MTU is not properly read from the output of ifconfig

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
