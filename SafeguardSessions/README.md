# Safeguard for Previleged Sessions Power BI Connector developer documentation

This document describes the steps to be aware of to use and develop the Safeguard for Privileged Session Power BI connector code.

The current functionality of the connector is as follows after the user has entered an SPS Url and logged in with baisc athentication:

- Displays the details of the REST API info endpoint in a table.

## Development environment

Two supported development environments are currently available for Power BI custom connector creation. These are:

-  **Visual Studio 2017 and 2019**
-  **Visual Studio Code**

In themselves, development environments do not support connector development. Both require the **Power Query SDK** extension. It was released for Visual Studio in 2017, and for Visual Studio Code (later VS Code) in 2022, currently in preview. Microsoft encourages all developers to install and use the newly released Visual Studio Code Power Query SDK (Preview) as this version will eventually be the default SDK going forward. Therefore, this was used to develop the current Safeguard for Previleged Session Power BI connector.

The following steps are required to set up a VS Code development environment:

- [Install Visual Studio Code]
- After starting Visual Studio Code, you can install the Power Query SDK via the Extensions tab. (This will also install the Power Query / M Language extension.) (At the bottom of the Explorer tab, you will see a Power Query SDK drop-down menu.)

## Building

The connector can be accessed locally by running the following git command. (It is necessary to have [git installed].)

```sh
git clone https://github.com/OneIdentity/SafeguardPowerBI.git
```

The connector is located in the SafeguardSession folder, which should be opened in VS Code as well.

The connector code can be built with two different tools:

- **MakePQX:** This is the default. A .mez file will be created during the build using all of the files at the top level of the project directory, with a few exceptions (these are not user configurable). You may want to specify the directory of MakePQX.exe as a system path variable, so you can easily build from the terminal.
- **MSBuild:** This is not available by default. It must be [installed] separately, and the folder added to the system variable path where msbuild.exe is located. Here you also have the option to manually specify which files you want to include in the .mez file. This requires modifying the .proj file. (The .proj file is not used by makepqx.)

Building is available in VS Code under **Terminal > Run Build Task...**, where you can choose from the build options listed above if you have msbuild on your machine.

## Testing

Currently, running tests is only available from the command line, as the test framework has been decoupled from the connector code. The tests and the unit test framework can be found under the test subfolder. This is actually a separate Power Query SDK project. So it is also necessary to build here.

Testing is done by running PQTest.exe. You may also want to include the exe file directory in the system path variables. PQTest.exe needs an extension (.mez file) and a .query.pq file (which contains the tests). Because the test framework, which is based on Microsoft's Fact unit test framework, and its connector functionality are in two different places, both extensions must be given to PQTest, which is not possible from the VS Code interface.

The following command is an example of a unit test file run:

```sh
PQTest.exe --extension ".\bin\SafeguardSessions.mez" --extension ".\test\bin\UnitTestFramework.mez"  run-test -q ".\test\TestBasicAuthentication.query.pq" --prettyPrint
```

## Installation and Deployment

In order to use the newly built connector in Power BI, the following steps are required:

1. Login to your SPS.
2. Go to Basic Settings > Management.
3. Open the SSL tab and clcik on the link next to the "CA X.509 certificate"  text.
4. Download the DER version. (This is recognised by default by Windows.)
5. [Install the downloaded certificate].
6. Create a Custom Connectors folder under Documents > Power BI Desktop.
7. Copy the connector's .mez file here. (Not the test's!)
8. In Power BI Desktop, select the (Not Recommended) Allow any extension to load without validation or warning option under File > Options and settings > Options > Security > Data Extensions.
9. Restart Power BI Desktop.

## Useful documentations

- [Power Query SDK]
- [VS Code Power Query SDK Git Hub page]
- [Power Query M formula lanaguage]

[Install Visual Studio Code]: <https://code.visualstudio.com/>
[git installed]: <https://git-scm.com/downloads>
[installed]: <https://github.com/microsoft/vscode-powerquery-sdk/issues/192#issuecomment-1311882460>
[Install the downloaded certificate]: <https://learn.microsoft.com/en-us/troubleshoot/windows-server/windows-security/install-imported-certificates>
[Power Query SDK]: <https://learn.microsoft.com/en-us/power-query/installingsdk>
[VS Code Power Query SDK Git Hub page]: <https://github.com/microsoft/vscode-powerquery-sdk/>
[Power Query M formula lanaguage]: <https://learn.microsoft.com/en-us/powerquery-m/>
