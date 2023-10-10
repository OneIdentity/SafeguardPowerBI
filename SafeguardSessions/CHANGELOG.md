# Changelog

## [Unreleased]

## [v1.1.1+sps7.4.0] - 2023-10-11

### Compatible SPS versions

* 7.3.0, 7.4.0

### New features

* Version check has been implemented. One Identity Safeguard Power BI Connector only works with supported SPS versions, however this can be bypassed by the setting the newly introduced Check version option to False.

### Bug fixes

* ResponseHandler.GetDataFromResponse passes on the meta in recursive calls.
* Fix memory consumption of the Power BI Connector and enable importing large number of sessions into Power BI.

### Other changes

* Custom errors have been extended with an error code.
* Only Source IP is taken into account when determining data source path. As a result, credentials must only be re-entered, when data is fetched from a different data source than before.

## [v1.0.0+sps7.3.0] - 2023-06-09

### Compatible SPS versions

* 7.3.0

### New features

* Custom Power BI connector named One Identity Safeguard Power BI Connector to provide a solution for customers to visualize their audit data captured by SPS.
* Power BI report template to quickstart report creation and visualize your audit data.
