## Troubleshooting

### Collect information

When you import or refresh data with the Power BI Connector, you will likely face one of the scenarios when an error occurs:

- The data import process finishes without any immediate signs of error.
- A pop-up appears indicating an error.
- An error occurs when connecting to SPS via the Power BI Service.

You can read about these scenarios below.

#### The data import process finishes without any immediate signs of error.

To see if there were any errors during the data import, you can check the **Info** table. When it indicates an error, you can read about the specific error by searching for the error code in the [Errors raised by the Power BI Connector] section of this document. The **Sessions** table will contain the exact error record that you can inspect in the [Data] pane of [Power Query Editor].

#### A pop-up appears indicating some type of error.

If the error is handled by the Power BI Connector, the pop-up will contain the error code and error message what you can find in [Errors raised by the Power BI Connector] section to learn more about the error.

#### An error occurs when connecting to SPS via the Power BI Service.

If an error occurs when a new connection is created, Power BI Service (Service) will show the specific error message.

If an error oocurs when an existing dataset is refreshed through an existing connection, the _Refresh history_ of that dataset will contain the error details.

### Creating a technical case

If you cannot resolve the error, reproduce it with trace logging enabled, collect the Power BI mashup trace logs, as described in the [Collecting Power BI mashup trace logs] documentation. If the error occurs in the Service, collect the Power BI Gateway logs, as described in the [Collecting Power BI Gateway logs] documentation.
Finally, create a [One Identity Technical Case]. Attach the collected trace logs for debugging purposes.

Make sure you include the version of your Power BI Desktop application, the version of the Power BI Connector and the version of the SPS appliance. If you are using the Service with a Gateway, also include the version of the Gateway. Attaching an SPS debug bundle may also help us troubleshooting the issue if it is related to SPS.

In the next sections, you can read about errors that you might run into when using the Power BI Connector.

## General errors

### I cannot find One Identity Safeguard under Home > Get data.

You might have forgotten to enable loading non-certified connectors. Make sure you enable this option, as described in the [Installation and usage] section in the README. **OR**

You have built your Power BI Connector from source code, but it contains one or more errors.

### I get the following error when trying to connect to SPS:

```
Unable to connect
We encountered an error while trying to connect. Details: "The underlying
connection was closed: Could not establish trust relationship for the SSL/TLS
secure channel."
```

You might have forgotten to import the CA X.509 certificate of your SPS appliance, as described in the [Installation and usage] section in the README.

## Errors raised by the Power BI Connector

### Error 4000: The source IP interpreted a malformed request.

Your filter might be invalid. Make sure you specify your filter parameters correctly. For more information on the available search fields, see **List of available search queries** in the **One Identity Safeguard for Privileged Sessions Administration Guide** on the [Technical documents for One Identity Safeguard for Privileged Sessions] page.

### Error 4010: The username or password you have specified is invalid.

Make sure you use a local user to access SPS with a valid username and password. One Identity recommends creating a dedicated local user for the purpose of importing data from SPS into Power BI.

### Error 4030: You are not authorized to access the specified resource.

In order to access audit data, the user you use to access SPS must have search access rights.

### Error 4040: The requested resource is not found.

In order to fetch audit data from SPS, the Power BI Connector relies on the advanced search method, which uses database snapshots to ensure data consistency throughout data fetching. If for some reason, the database snapshot disappears, this error can occur. To resolve the issue, try initiating the data fetching again.

### Error 4290: Snapshot quota exceeded.

This happens if multiple users from different computers or using different programs want to use advanced search relying on database snapshots at the same time. In this case, try initiating the data fetching process at least 5 minutes later so that an existing snapshot expires in the system, and a new one can be opened.

### Error 5000: The source IP responded with a server error.

This error indicates issues with the SPS appliance. One of the causes could be that the Search database on the SPS is unavailable. You can check whether it is available on SPS-UI by logging in with the user that the Power BI Connector uses for data fetching. You can also retry the data import several times as server errors might be only temporary.

If it does not help to locate and resolve the issue, create a technical case, as described in the [Creating a technical case] section.

### Error 10000: There is a field value missing from one or more of your filter fields.

If you provide a filter field, make sure you also provide a valid filter value for it. To get help with valid values for search fields, the **List of available search queries** section in the **One Identity Safeguard for Privileged Sessions Administration Guide** on the [Technical documents for One Identity Safeguard for Privileged Sessions] page may help.

### Error 10001: Your version of the connector (ConnectorVersion) is not compatible with your SPS version (SPSVersion). For a connector version that is compatible with your SPS version, visit the official release page of the connector: https://github.com/OneIdentity/SafeguardPowerBI/releases.

Revisit the [Upgrading the Power BI Connector] section.

### Error 10002: The source IP returned a response with missing fields.

A response returned by SPS does not contain a field that the Power BI Connector requires for processing data. Create a technical case, as described in the [Creating a technical case] section.

### Error 10003: The list contains other types than text.

This error can occur while the Power BI Connector transforms list values from REST response to single field by concatenating the its values. The Power BI Connector can concatenate lists containing only text values. This can indicate that SPS returned a response that is not in align with the schema. Create a technical case, as described in the [Creating a technical case] section.

### Error 10004: An error happened when applying schema.

In order to display the session records from SPS in a user-friendly way in Power BI, schema must be mapped to the session records. This error means that at least one session occurred in the SPS response that the schema application could not handle correctly and caused an unexpected error. Create a technical case, as described in the [Creating a technical case] section.

### Error 99999: <...>

This error wraps unexpected errors raised by the Power BI Connector. Create a technical case, as described in the [Creating a technical case] section.

<!-- Links -->

[Creating a technical case]: #creating-a-technical-case
[Errors raised by the Power BI Connector]: #errors-raised-by-the-power-bi-connector

[Installation and usage]: README.md#installation-and-usage
[Upgrading the Power BI Connector]: README.md#upgrading-the-power-bi-connector

[Technical documents for One Identity Safeguard for Privileged Sessions]: https://support.oneidentity.com/one-identity-safeguard-for-privileged-sessions/technical-documents
[One Identity Technical Case]: https://support.oneidentity.com/create-service-request

[Collecting Power BI mashup trace logs]: https://learn.microsoft.com/en-us/power-bi/fundamentals/desktop-diagnostics#collecting-mashup-traces
[Collecting Power BI Gateway logs]: https://learn.microsoft.com/en-us/data-integration/gateway/service-gateway-tshoot#collect-logs-from-the-on-premises-data-gateway-app

[Power Query Editor]: https://learn.microsoft.com/en-us/power-bi/transform-model/desktop-query-overview#power-query-editor
[Data]: https://learn.microsoft.com/en-us/power-bi/transform-model/desktop-query-overview#the-center-data-pane
[Query Settings]: https://learn.microsoft.com/en-us/power-bi/transform-model/desktop-query-overview#the-right-query-settings-pane

<!-- Links END -->
