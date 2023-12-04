# One Identity Safeguard Power BI Connector

## Table of Contents

- [About the project]
- [Installation and usage]
- [Troubleshooting errors]
- [Contributing to the project]
- [Licensing of the project]
- [References]

## About the project

The aim of the One Identity Safeguard for Privileged Passwords Power BI Connector (Power BI Connector) is to provide a solution for customers to visualize their data captured by [One Identity Safeguard for Privileged Passwords] in a highly configurable way compared to the on-box reporting system of SPP. 

The SPP Power BI Connector uses basic local authentication to connect to SPP. After connection users are prompted to enter API query options and may select data from a variety of SPP API endpoints. This data is returned in a table. 

Several SPP report templates are included:

- **Entitlement report**: equivalent to SPP UI built-in Entitlement Report
- **Asset Ownership report**: equivalent to SPP UI built-in Asset Ownership Report
- **Account Ownership report**: equivalent to SPP UI built-in Account Ownership Report
- **Metrics Report**: presents data about password management activity

## Installation and usage

First configure a trusted SSL Certificate on your SPP appliance. Refer to the Admin guide for additional details. 

Once SSL Certificate trust is established, to use the SPP connector:

1. Get a connector MEZ file compatible with your SPP version from the [Releases] page, or build it from source code following the steps described in the [Contribution] guide.
2. Copy the file to your `%USERPROFILE%\Documents\Power BI Desktop\Custom Connectors` folder.
3. In Power BI Desktop, go to **File > Options and settings > Options > Security > Data Extensions**, and select the **(Not Recommended) Allow any extension to load without validation or warning** option since the Power BI Connector is not signed.
4. Restart Power BI Desktop.
5. In Power BI Desktop, click **Home > Get data**, search for **One Identity Safeguard for Privileged Passwords**, then click **Connect**.
6. Enter the input parameters for the Power BI Connector, and click **OK**.
7. Enter the credentials that will be used to authenticate to the SPP appliance and click **Connect**.
8. Select the API endpoints to query. 
9. Once data is imported into Power BI, you can start creating your reports by either creating them from scratch or by using the Report Template.

## Troubleshooting errors

See the [Troubleshooting] guide.

## Contribution

For guidance on contribution and development quickstart, see [Contribution].

## Licensing of the project

Distributed under the One Identity - Open Source License. For more information, see [License].

## References

- [One Identity Safeguard for Privileged Passwords]
- [Technical documents for One Identity Safeguard for Privileged Passwords]
- [Releases] of the Power BI Connector
- [License] of the Power BI Connector
- [Contribution] to the Power BI Connector
- [Troubleshooting] errors of the Power BI Connector

<!-- Links -->

[About the project]: #about-the-project
[Installation and usage]: #installation-and-usage
[Troubleshooting errors]: #troubleshooting-errors
[Contributing to the project]: #contributing-to-the-project
[Licensing of the project]: #license-of-the-project
[References]: #references

[One Identity Technical Case]: https://support.oneidentity.com/create-service-request

[One Identity Safeguard for Privileged Passwords]: https://www.oneidentity.com/products/one-identity-safeguard-for-privileged-passwords/
[Technical documents for One Identity Safeguard for Privileged Passwords]: https://support.oneidentity.com/one-identity-safeguard-for-privileged-passwords/technical-documents

[Releases]: https://github.com/OneIdentity/SafeguardPowerBI/releases

[License]: ../LICENSE
[Contribution]: CONTRIBUTION.md
[Troubleshooting]: TROUBLESHOOTING.md

[Install imported certificates]: https://learn.microsoft.com/en-us/troubleshoot/windows-server/windows-security/install-imported-certificates
[Collecting Power BI mashup trace logs]: https://learn.microsoft.com/en-us/power-bi/fundamentals/desktop-diagnostics#collecting-mashup-traces

<!-- Links END -->
