## Troubleshooting

### Collect information

When you import or refresh data with the Power BI Connector, you may face one of the following scenarios when error occurs:

- The Preview pane contains an error. 
- A pop-up appears indicating an error.
- An error occurs when connecting to SPP via the Power BI Service.

You can read about these scenarios below.

#### The Preview pane contains an error.

If the error is handled by the Power BI Connector, the Preview pane will contain the error code and error message which you can find in [Errors raised by the Power BI Connector] section to learn more about the error.

#### A pop-up appears indicating some type of error.

If the error is handled by the Power BI Connector, the pop-up will contain the error code and error message which you can find in [Errors raised by the Power BI Connector] section to learn more about the error.

#### An error occurs when connecting to SPP via the Power BI Service.

If an error occurs when a new connection is created, Power BI Service (Service) will show the specific error message.

If an error oocurs when an existing dataset is refreshed through an existing connection, the _Refresh history_ of that dataset will contain the error details.

### Creating a technical case

If you cannot resolve the error, reproduce it with trace logging enabled, collect the Power BI mashup trace logs, as described in the [Collecting Power BI mashup trace logs] documentation, and create a [One Identity Technical Case]. Attach the collected trace logs for debugging purposes. Make sure you include the version of your Power BI desktop application, the Power BI Connector and SPP appliance. Attaching an SPP support bundle may also help us troubleshoot the issue if it is related to SPP.

In the next sections you can read about errors that you might run into when using the Power BI Connector.

## General errors

### I cannot find One Identity Safeguard for Privileged Passwords under Home > Get data.

You might have forgotten to enable loading non-certified connectors. Make sure you enable this option, as described in the [Installation and usage] section in the README. **OR**

You have built your Power BI Connector from source code, but it contains one or more errors.

### I get the following error when trying to connect to SPP:

```
Unable to connect
We encountered an error while trying to connect. Details: "The underlying
connection was closed: Could not establish trust relationship for the SSL/TLS
secure channel."
```

You might have forgotten to configure a trusted SSL certificate on your SPP appliance, or to import the CA of your SSL certificate, as described in the [Installation and usage] section in the README.

## Errors raised by the Power BI Connector

### Web.Contents failed to get contents from 'https://10.3.62.127/RSTS/oauth2/token' (400): Bad Request

Ensure that you use an enabled local SPP user to connect to SPP, and that the username and password are correct. One Identity recommends creating a dedicated local user for the purpose of importing data from SPP into Power BI.

### Access to the resource is forbidden.

This error indicates that the SPP user that PowerBI is configured to use lacks permission to view the API endpoint it attempted to query. 

Ensure that the SPP user that PowerBI is configured to use has the Auditor Role.

<!-- Links -->

[Creating a technical case]: #creating-a-technical-case
[Errors raised by the Power BI Connector]: #errors-raised-by-the-power-bi-connector

[Installation and usage]: README.md#installation-and-usage
[Upgrading the Power BI Connector]: README.md#upgrading-the-power-bi-connector

[Technical documents for One Identity Safeguard for Privileged Sessions]: https://support.oneidentity.com/one-identity-safeguard-for-privileged-sessions/technical-documents
[One Identity Technical Case]: https://support.oneidentity.com/create-service-request

[Collecting Power BI mashup trace logs]: https://learn.microsoft.com/en-us/power-bi/fundamentals/desktop-diagnostics#collecting-mashup-traces

<!-- Links END -->
