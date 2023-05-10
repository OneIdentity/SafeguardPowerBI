# One Identity Safeguard Power BI Connector

## Table of Contents

- [About the project](#about-the-project)
- [Installation and usage](#installation-and-usage)
- [Common errors](#common-errors)
- [Troubleshooting](#troubleshooting)
- [Release policy](#release-policy)
- [Contribution](#contribution)
- [License](#license)
- [References](#references)

## About the project

The aim of One Identity Safeguard Power BI Connector (Power BI Connector) is to provide a solution for customers to visualize their audit data captured by [One Identity Safeguard for Priviledged Sessions] (SPS) in a highly configurable way compared to the on-box reporting system of SPS. The Power BI Connector uses basic authentication with the local login method to connect to SPS, and imports sessions metadata that matches the criteria specified in the Power BI Connector's input parameters. After successful data retrieval, the Power BI Connector returns two tables:

- **Info**: contains information about the data fetching process for debugging purposes
- **Sessions**: contains the actual sessions metadata

The project also a includes the One Identity Safeguard Power BI Report Template (Report Template) to quickstart report creation and visualize your audit data.

## Installation and usage

To use the connector,

1. Get a connector MEZ file compatible with your SPS version from the [Releases] page, or build it from source code following the steps described in the [Contribution] guide.
2. Copy the file to your `%USERPROFILE%\Documents\Power BI Desktop\Custom Connectors` folder.
3. Log in to your SPS appliance, and go to **Basic Settings > Management**.
4. Open the **SSL** tab, and click on the link next to the **CA X.509 certificate** text.
5. Download the DER version. (This is recognized by default by Windows.)
6. Import the downloaded certificate to your local computer's certificate store as a trusted root certification authority. For more information, visit: [Install imported certificates].
7. Make sure you set up a dedicated local user for fetching data from SPS to Power BI under **Users & Access Control > Local Users** with search access rights.
8. In Power BI Desktop, go to **File > Options and settings > Options > Security > Data Extensions**, and select the **(Not Recommended) Allow any extension to load without validation or warning** option since the Power BI Connector is not signed.
9. Restart Power BI Desktop.
10. In Power BI Desktop, click **Home > Get data**, search for **One Identity Safeguard**, then click **Connect**.
11. Enter the input parameters for the Power BI Connector, and click **OK**.
12. Enter the credentials that will be used to authenticate to the SPS appliance, and click **Connect**.
13. Select both the **Info** and **Sessions** tables, then click **Load**.
14. Once data is imported into Power BI, you can start creating your reports by either creating them from scratch or by using the Report Template.

You can read a more comprehensive guide on using the Power BI Connector and the Report Template in the One Idenity Safeguard Power BI Connector Tutorial that can be found on the [Technical documents for One Identity Safeguard for Priviledged Sessions] page.

## Common errors

I cannot find **One Identity Safeguard** under **Home > Get data**.

A) You might have forgotten to enable loading non-certified connectors. Make sure you enable this option described in the [Installation and usage](#installation-and-usage) section.

B) You have built your Power BI Connector from source code, but it contains error(s).

---

I get the following error when trying to connect to SPS:

```
Unable to connect
We encountered an error while trying to connect. Details: "The underlying
connection was closed: Could not establish trust relationship for the SSL/TLS
secure channel."
```

You might have forgotten to import the CA X.509 certificate of your SPS appliance described in the [Installation and usage](#installation-and-usage) section.

---

I see "Error" in the **Status** column of the **Info** table, and the **Message** column contains the following:

**A) The source IP returned a response with missing fields.**

A response returned by SPS does not contain a field that the Power BI Connector requires for processing data.
Reproduce the error with trace logging enabled, and create a technical case, as described in the [Troubleshooting](#troubleshooting) section.
Attach the mashup trace logs to the issue.

**B) The source IP interpreted a malformed request.**

Your filter might be invalid. Make sure you specify your filter parameters correctly. For more information on the available search fields, see **List of available search queries** in the **One Identity Safeguard for Privileged Sessions Administration Guide** on the [Technical documents for One Identity Safeguard for Priviledged Sessions] page.

**C) The username or password you have specified is invalid.**

Make sure you use a local user to access SPS with a valid username and password. One Identity recommends creating a dedicated local user for the purpose of importing data from SPS into Power BI.

**D) You are not authorized to access the specified resource.**

In order to access audit data, the user you use to access SPS must have search access rights.

**E) The requested resource is not found.**

In order to fetch audit data from SPS, the Power BI Connector relies on the advanced search method, which uses database snapshots to ensure data consistency throughout data fetching. If for some reason, the database snapshot disappears, this error can occur. To resolve the issue, try initiating the data fetching again.

**F) Snapshot quota exceeded.**

This happens if multiple users from different computers or using different programs want to use advanced search relying on database snapshots at the same time. In this case, try initiating the data fetching process at least 5 minutes later so that an existing snapshot expires in the system, and a new one can be opened.

**G) The source IP responded with a server error.**

This error indicates issues with the SPS appliance. Try the suggestions written in the [Troubleshooting](#troubleshooting) section.

## Troubleshooting

If an error occurs during the data fetching process, you can check the **Info** table to see a descriptive message about the error type. In this case, the **Sessions** table will contain the exact error record that you can inspect if you go to **Home > Transform data** and select the **Sessions** table.

If you cannot resolve the issue, you can collect the Power BI mashup trace logs, as described in the [Collecting Power BI mashup trace logs] documentation, and create a [One Identity Technical Case]. Attach the collected trace logs for debugging purposes.

## Release policy

As of now, One Identity releases a new Power BI Connector with each feature release of SPS until 8 LTS.

Releases have the following rules:

- Release versioning follows the `v<connector-version>+sps-<sps-version>` convention
- Connector versioning follows the `v<major.minor.patch(pre)>` convention
    - `major`: the new version includes breaking changes compared to the previous version
    - `minor`: the new version includes new functionalities without breaking changes compared to the previous version
    - `patch`: the new version includes small, non-breaking changes compared to the previous version
    - `pre`: the new version is a pre-release version
- The release title should be the same as the tag
- Examples
    - v1.0.0+sps-7.3.0
    - v1.0.0pre1+sps7.3.0
    - v1.0.0+sps-8.0.3
- A Report Template of a release is not only compatible with the connector from the same release but also with other connectors having the same major version

When writing a release note, use the following template:

```
# Compatible SPS versions
...

# Breaking changes
...

# New features
...

# Bug fixes
...

# Other changes
...
```

If a section does not have related content, it can be left out.

Modifications to the Report Template must be listed in the appropriate sections, since they are part of the release.

## Contribution

For guidance on contribution and development quickstart, see [Contribution].

## License

Distributed under the One Identity - Open Source License. For more information, see [License].

## References

- [One Identity Safeguard for Priviledged Sessions]
- [Technical documents for One Identity Safeguard for Priviledged Sessions]
- Create a [One Identity Technical Case]
- [Releases] of the Power BI Connector
- [License] of the Power BI Connector
- [Contribution] to the Power BI Connector

<!-- Links -->

[One Identity Safeguard for Priviledged Sessions]: https://www.oneidentity.com/products/one-identity-safeguard-for-privileged-sessions/
[Technical documents for One Identity Safeguard for Priviledged Sessions]: https://support.oneidentity.com/one-identity-safeguard-for-privileged-sessions/technical-documents
[One Identity Technical Case]: https://support.oneidentity.com/create-service-request

[Releases]: https://github.com/OneIdentity/SafeguardPowerBI/releases
[License]: https://github.com/OneIdentity/SafeguardPowerBI/blob/main/LICENSE
[Contribution]: CONTRIBUTION.md

[Install imported certificates]: https://learn.microsoft.com/en-us/troubleshoot/windows-server/windows-security/install-imported-certificates
[Collecting Power BI mashup trace logs]: https://learn.microsoft.com/en-us/power-bi/fundamentals/desktop-diagnostics#collecting-mashup-traces

<!-- Links END -->
