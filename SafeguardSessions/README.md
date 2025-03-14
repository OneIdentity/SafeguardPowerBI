# One Identity Safeguard Power BI Connector

## Table of Contents

- [About the project]
- [Installation and usage]
- [Troubleshooting errors]
- [Release policy]
- [Refreshing your preloaded data]
- [Upgrading the Power BI Connector]
- [Contributing to the project]
- [Licensing of the project]
- [References]

## About the project

The aim of One Identity Safeguard Power BI Connector (Power BI Connector) is to provide a solution for customers to visualize their audit data captured by [One Identity Safeguard for Privileged Sessions] (SPS) in a highly configurable way compared to the on-box reporting system of SPS. The Power BI Connector uses basic authentication with the local login method to connect to SPS, and imports sessions metadata that matches the criteria specified in the Power BI Connector's input parameters. After successful data retrieval, the Power BI Connector returns the following two tables.

The Power BI Connector is usable with Power BI Desktop and Power BI Service.

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

The project also includes the One Identity Safeguard Power BI Report Template (Report Template) to quickstart report creation and visualize your audit data.

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

You can read a more comprehensive guide on using the Power BI Connector and the Report Template in the One Idenity Safeguard Power BI Connector Tutorial that can be found on the [Technical documents for One Identity Safeguard for Privileged Sessions] page.

### Fetching data from multiple SPS instances

You can fetch data from multiple SPS instances by repeating steps 10. to 13. from [Installation and usage]. If you want to append your queries, follow the [Append queries] official tutorial.

## Troubleshooting errors

See the [Troubleshooting] guide.

## Release policy

One Identity releases a new Power BI Connector with each feature release.

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

## Contributing to the project

For guidance on contribution and development quickstart, see [Contribution].

## Licensing of the project

Distributed under the One Identity - Open Source License. For more information, see [License].

## References

- [One Identity Safeguard for Privileged Sessions]
- [Technical documents for One Identity Safeguard for Privileged Sessions]
- [Releases] of the Power BI Connector
- [License] of the Power BI Connector
- [Contribution] to the Power BI Connector
- [Troubleshooting] errors of the Power BI Connector

<!-- Links -->

[About the project]: #about-the-project
[Installation and usage]: #installation-and-usage
[Troubleshooting errors]: #troubleshooting-errors
[Release policy]: #release-policy
[Refreshing your preloaded data]: #refreshing-your-preloaded-data
[Upgrading the Power BI Connector]: #upgrading-the-power-bi-connector
[Contributing to the project]: #contributing-to-the-project
[Licensing of the project]: #licensing-of-the-project
[References]: #references

[One Identity Safeguard for Privileged Sessions]: https://www.oneidentity.com/products/one-identity-safeguard-for-privileged-sessions/
[Technical documents for One Identity Safeguard for Privileged Sessions]: https://support.oneidentity.com/one-identity-safeguard-for-privileged-sessions/technical-documents

[Releases]: https://github.com/OneIdentity/SafeguardPowerBI/releases

[License]: ../LICENSE
[Contribution]: CONTRIBUTION.md
[Troubleshooting]: TROUBLESHOOTING.md

[Append queries]: https://learn.microsoft.com/en-us/power-query/append-queries

[Install imported certificates]: https://learn.microsoft.com/en-us/troubleshoot/windows-server/windows-security/install-imported-certificates

<!-- Links END -->
