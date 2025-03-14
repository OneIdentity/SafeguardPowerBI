# Changelog

## [v2.0.2+sps8.1.0] - 2025-02-11

### Compatible SPS Versions

* Feature: 7.3.0 - 8.1.0
* LTS: 8.0.0 - 8.0.1

## [v2.0.1+sps8.0.0] - 2024-08-05

### Compatible SPS Versions

* 7.3.0, 7.4.0, 7.5.0, 8.0.0

### Bug fixes

* Fix shared function name collision among Safeguard Password, Sessions and Common projects that made loading Safeguard for Privileged Password and Safeguard for Privileged Sessions connectors unable to be loaded simultaneously in Power BI Desktop.

## [v2.0.0+sps7.5.0] - 2024-03-05

### Compatible SPS Versions

* 7.3.0, 7.4.0, 7.5.0

### Breaking changes

* Power BI Service support has been implemented and the order and type of the input parameters have changed. Before the upgrade, we recommend that you check what input parameters were used when connecting to your SPS, so that after replacing the old version of the connector with the new version, you know how to fix the order and type of the input parameters. To ensure compatibility with the new versions of the One Identity Safeguard Power BI Connector and One Identity Safeguard Power BI Report Template, we recommend that after the upgrade, you modify the input parameters of previously saved .pbix files according to your observations.

*Checking the parameters*: In Power BI Desktop, you can check the input parameters of the Source query on the [Query Settings] pane of [Power Query Editor].

*Modifying the parameters*: In Power BI Desktop, you can modify the parameter list of *SafeguardSessions.Contents* (Source query) in the [Data] pane of [Power Query Editor].

The following tables list the order, names, types and allowed values of the parameters before and after the breaking change.

**Parameter changes**

| **Order** | **Before change**                    | **After change**                  |
|-----------|--------------------------------------|-----------------------------------|
|         1 | url as text                          | spsIP as text                     |
|         2 | from as nullable datetime            | optional skipVersionCheck as text |
|         3 | to as nullable datetime              | optional from as datetime         |
|         4 | filterField1 as nullable text        | optional to as datetime           |
|         5 | filterValue1 as nullable text        | optional filterField1 as text     |
|         6 | filterField2 as nullable text        | optional filterValue1 as text     |
|         7 | filterValue2 as nullable text        | optional filterField2 as text     |
|         8 | filterField3 as nullable text        | optional filterValue2 as text     |
|         9 | filterValue3 as nullable text        | optional filterField3 as text     |
|        10 | skipVersionCheck as nullable logical | optional filterValue3 as text     |       

**Allowed values**

| **Parameter**    | **Before**        | **After**         |
|------------------|-------------------|-------------------|
| skipVersionCheck | null, False, True | null, "No", "Yes" |

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

<!-- Links -->

[Power Query Editor]: https://learn.microsoft.com/en-us/power-bi/transform-model/desktop-query-overview#power-query-editor
[Data]: https://learn.microsoft.com/en-us/power-bi/transform-model/desktop-query-overview#the-center-data-pane
[Query Settings]: https://learn.microsoft.com/en-us/power-bi/transform-model/desktop-query-overview#the-right-query-settings-pane

<!-- Links END -->