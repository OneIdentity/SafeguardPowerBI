# One Identity Safeguard Power BI Connector

## Table of Contents

- [About the project]
- [Installation and usage]
- [Common errors]
- [Troubleshooting]
- [Release policy]
- [Refreshing your preloaded data]
- [Upgrading the Power BI Connector]
- [Contribution]
- [License]
- [References]

## About the project

The aim of One Identity Safeguard Power BI Connector (Power BI Connector) is to provide a solution for customers to visualize their audit data captured by [One Identity Safeguard for Priviledged Sessions] (SPS) in a highly configurable way compared to the on-box reporting system of SPS. The Power BI Connector uses basic authentication with the local login method to connect to SPS, and imports sessions metadata that matches the criteria specified in the Power BI Connector's input parameters. After successful data retrieval, the Power BI Connector returns the following two tables.

### Info

This table contains information about the data fetching process for debugging purposes, and the version of the Power BI Connector.

### Sessions

This table contains the actual sessions metadata. The Power BI Connector fetches all sessions from SPS. Fetched data will contain only the following session fields:

- active
- analytics.interesting_events
- analytics.score.aggregated
- analytics.score.details.command.score
- analytics.score.details.fis.score
- analytics.score.details.hostlogin.score
- analytics.score.details.logintime.score
- analytics.score.details.keystroke.score
- analytics.score.details.mouse.score
- analytics.score.details.windowtitle.score
- analytics.scripted
- analytics.similar_sessions
- analytics.bucketed_duration
- analytics.bucketed_starting_hour
- analytics.tags
- client.ip
- client.name
- client.port
- creation_time
- duration
- end_time
- log.adapter_name
- log.auth_method
- log.syslog_time
- node_id
- origin
- protocol
- recording.archive.date
- recording.archive.path
- recording.archive.policy
- recording.archive.server
- recording.archived
- trail_download_link
- recording.auth_method
- recording.channel_policy
- recording.command_extracted
- recording.connection_policy
- recording.connection_policy_id
- recording.content_reference_id
- recording.deny_reason
- recording.index_status
- recording.network_id
- recording.server_local.ip
- recording.server_local.name
- recording.server_local.port
- recording.session_id
- recording.target.ip
- recording.target.name
- recording.target.port
- recording.verdict
- recording.window_title_extracted
- server.address
- server.ip
- server.id
- server.name
- server.port
- start_time
- user.gateway_username
- user.gateway_username_domain
- user.id
- user.name
- user.name_domain
- user.server_username
- user.server_username_domain
- verdict

The project also a includes the One Identity Safeguard Power BI Report Template (Report Template) to quickstart report creation and visualize your audit data.

### Data Security

One Identity Safeguard Power BI Connector uses https protocol to fetch data from SPS meaning that data is encrypted at the network level. Apart from this, One Identity does not implement additional data protection on top of Microsoft Power BI's security solutions. When using the Power BI Connector, consider applying the security options Microsoft provides for Power BI.

To help you get started, we would like to draw your attention to the following details:

- To have local files protected with encryption you will need to apply appropriately configured sensitivity labels.
- When using Power BI connector with Power BI Desktop or Power BI Mobile, ensure cache files are also protected appropriately or data caching is turned off.
- When using Power BI Service check if key management solution in use is sufficient for your needs.

For further information, please refer to the Microsoft documentation on the topic.

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

### Fetching data from multiple SPS instances

You can fetch data from multiple SPS instances by repeating steps 10. to 13. from [Installation and usage]. If you want to append your queries, follow the [Append queries] official tutorial.

## Common errors

I cannot find **One Identity Safeguard** under **Home > Get data**.

**A)** You might have forgotten to enable loading non-certified connectors. Make sure you enable this option, as described in the [Installation and usage] section.

**B)** You have built your Power BI Connector from source code, but it contains one or more errors.

---

I get the following error when trying to connect to SPS:

```
Unable to connect
We encountered an error while trying to connect. Details: "The underlying
connection was closed: Could not establish trust relationship for the SSL/TLS
secure channel."
```

You might have forgotten to import the CA X.509 certificate of your SPS appliance, as described in the [Installation and usage] section.

---

If you have successfully upgraded your custom connector and tried to fetch data, but receive the following message, revisit the [Upgrading the Power BI Connector] section.

```
Your version of the connector (ConnectorVersion) is not compatible with your SPS version (SPSVersion). For a connector version that is compatible with your SPS
version, visit the official release page of the connector:
https://github.com/OneIdentity/SafeguardPowerBI/releases
```

---

I see "Error" in the **Status** column of the **Info** table, and the **Message** column contains the following:

**A)** Error 10003: The source IP returned a response with missing fields.

A response returned by SPS does not contain a field that the Power BI Connector requires for processing data.
Reproduce the error with trace logging enabled, and create a technical case, as described in the [Troubleshooting] section.
Attach the mashup trace logs to the issue.

**B)** Error 4000: The source IP interpreted a malformed request.

Your filter might be invalid. Make sure you specify your filter parameters correctly. For more information on the available search fields, see **List of available search queries** in the **One Identity Safeguard for Privileged Sessions Administration Guide** on the [Technical documents for One Identity Safeguard for Priviledged Sessions] page.

**C)** Error 4010: The username or password you have specified is invalid.

Make sure you use a local user to access SPS with a valid username and password. One Identity recommends creating a dedicated local user for the purpose of importing data from SPS into Power BI.

**D)** Error 4030: You are not authorized to access the specified resource.

In order to access audit data, the user you use to access SPS must have search access rights.

**E)** Error 4040: The requested resource is not found.

In order to fetch audit data from SPS, the Power BI Connector relies on the advanced search method, which uses database snapshots to ensure data consistency throughout data fetching. If for some reason, the database snapshot disappears, this error can occur. To resolve the issue, try initiating the data fetching again.

**F)** Error 4290: Snapshot quota exceeded.

This happens if multiple users from different computers or using different programs want to use advanced search relying on database snapshots at the same time. In this case, try initiating the data fetching process at least 5 minutes later so that an existing snapshot expires in the system, and a new one can be opened.

**G)** Error 5000: The source IP responded with a server error.

This error indicates issues with the SPS appliance. Try the suggestions written in the [Troubleshooting] section.

**H)** Error 10005: An error happened when applying schema.

In order to display the session records from SPS in a user-friendly way in Power BI, schema must be mapped to the session records. This error means that at least one session occurred in the SPS response that the schema application could not handle correctly and caused an unexpected error.
Reproduce the error with trace logging enabled, and create a technical case, as described in the [Troubleshooting] section.
Attach the mashup trace logs to the issue.

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

Modifications to the Report Template are a part of the release, and must be listed in the appropriate sections. To solve the issue, make sure your modifications are listed in the appropriate sections.

## Refreshing your preloaded data

Using a .pbix file, you can refresh your previously downloaded data without having to create a new data source.

If you are a new user and haven't used the custom connector yet, we strongly suggest that you follow the steps of [Installation and usage].

If you want to upgrade your custom connector, see [Upgrading the Power BI Connector].

**To refresh your preloaded data**
1. Open your previously saved .pbix file in Power BI Desktop.
2. In Power BI Desktop, click **Home > Refresh**.

If an error occurs after refreshing your data, discard your changes to keep your data intact.

## Upgrading the Power BI Connector

If you are a new user and haven't used the custom connector yet, we strongly suggest that you follow the steps of [Installation and usage].

You can safely upgrade to a new version of the Power BI Connector if the major version number of the new Power BI Connector does not differ from the one you are currently using. If the major version is different, we strongly suggest that you view the Breaking changes section for the new Power BI Connector on the [Releases] page.

You can check the current version number of your Power BI connector from the **Info** table described in the [About the project] section. 

**To upgrade the connector**

1. Get a connector MEZ file compatible with your SPS version from the [Releases] page, or build it from source code following the steps described in the [Contribution] guide.
2. Copy the file to your `%USERPROFILE%\Documents\Power BI Desktop\Custom Connectors` folder.

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

[About the project]: #about-the-project
[Installation and usage]: #installation-and-usage
[Common errors]: #common-errors
[Troubleshooting]: #troubleshooting
[Release policy]: #release-policy
[Refreshing your preloaded data]: #refreshing-your-preloaded-data
[Upgrading the Power BI Connector]: #upgrading-the-power-bi-connector
[Contribution]: #contribution
[License]: #license
[References]: #references

[One Identity Safeguard for Priviledged Sessions]: https://www.oneidentity.com/products/one-identity-safeguard-for-privileged-sessions/
[Technical documents for One Identity Safeguard for Priviledged Sessions]: https://support.oneidentity.com/one-identity-safeguard-for-privileged-sessions/technical-documents
[One Identity Technical Case]: https://support.oneidentity.com/create-service-request

[Releases]: https://github.com/OneIdentity/SafeguardPowerBI/releases
[License]: https://github.com/OneIdentity/SafeguardPowerBI/blob/main/LICENSE
[Contribution]: CONTRIBUTION.md

[Append queries]: https://learn.microsoft.com/en-us/power-query/append-queries

[Install imported certificates]: https://learn.microsoft.com/en-us/troubleshoot/windows-server/windows-security/install-imported-certificates
[Collecting Power BI mashup trace logs]: https://learn.microsoft.com/en-us/power-bi/fundamentals/desktop-diagnostics#collecting-mashup-traces

<!-- Links END -->
