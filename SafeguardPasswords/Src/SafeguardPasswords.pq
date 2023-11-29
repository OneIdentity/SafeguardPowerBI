[Version = "1.0.0"]
section SafeguardPasswords;

ReportUtilities.GetAssetOwnershipDataTable = Extension.ImportFunction("GetAssetOwnershipDataTable","ReportUtilities.pqm");
ReportUtilities.GetAssetAccountOwnershipDataTable = Extension.ImportFunction("GetAssetAccountOwnershipDataTable","ReportUtilities.pqm");
ReportUtilities.GetAssetPartitionOwnershipDataTable = Extension.ImportFunction("GetAssetPartitionOwnershipDataTable","ReportUtilities.pqm");
Types.ContentsType = Extension.ImportFunction("ContentsType","Types.pqm");
Data.GetDataTable = Extension.ImportFunction("GetDataTable","Data.pqm");
Constants = Extension.ImportModule("Constants.pqm")[SppConstants];
GetHost = Extension.ImportFunction("GetSppHost","UrlBuilder.pqm");
GetResponse = Extension.ImportFunction("GetSppResponse","Request.pqm");
GetUnauthenticatedResponse = Extension.ImportFunction("GetUnauthenticatedSppResponse","Request.pqm");
GetRstsResponse = Extension.ImportFunction("GetRstsResponse","Request.pqm");
GetLoginResponse = Extension.ImportFunction("GetLoginResponse","Request.pqm");
Logger.ErrorLog = Extension.ImportFunction("ErrorLog","CommonLogger.pqm");
Logger.InfoLog = Extension.ImportFunction("InfoLog", "CommonLogger.pqm");

[DataSource.Kind="SafeguardPasswords", Publish="SafeguardPasswords.Publish"]
shared SafeguardPasswords.Contents = Value.ReplaceType(SafeguardPasswords.SafeguardNavTable, Types.ContentsType);

shared SafeguardPasswords.SafeguardNavTable = (
    applianceName as text, 
    optional resourcePath as text, 
    optional filter as text, 
    optional fields as text, 
    optional queryOptions as text//,
   // optional responseFormat as text
) as table =>
    let
        // Hard-coded to JSON for now, but Nav Tables are framed to accept CSV since SPP API supports it. Not critical at this juncture but if sufficient interest exists, 
        // support could be added by uncommenting responseFormat arg above, uncommenting the ResponseFormat declaration in Types.pqm, and testing / updating 
        // Request.pqm and ResponseHandler.pqm to support CSV responses.
        responseFormat = "JSON",
        source = #table({"Name", "Data", "ItemKind", "ItemName", "IsLeaf"}, {
            { "Custom", Data.GetDataTable(applianceName, resourcePath, filter, fields, queryOptions, responseFormat), "Table", "Table", true },
            { "Asset Management", SafeguardAssetNavTable(applianceName, resourcePath, filter, fields, queryOptions, responseFormat), "Function", "Function", false },
            { "User Management", SafeguardUserNavTable(applianceName, resourcePath, filter, fields, queryOptions,responseFormat), "Function", "Function", false },
            { "Policy Management", SafeguardPolicyNavTable(applianceName, resourcePath, filter, fields, queryOptions,responseFormat), "Function", "Function", false },
            { "Audit", SafeguardAuditNavTable(applianceName, resourcePath, filter, fields, queryOptions,responseFormat), "Function", "Function", false },
            { "Reports", SafeguardReportNavTable(applianceName, resourcePath, filter, fields, queryOptions,responseFormat), "Function", "Function", false },
            { "Cluster", SafeguardClusterNavTable(applianceName, resourcePath, filter, fields, queryOptions,responseFormat), "Function", "Function", false },
            { "Appliance", SafeguardApplianceNavTable(applianceName, resourcePath, filter, fields, queryOptions,responseFormat), "Function", "Function", false }
        }),
        navTable = Table.ToNavigationTable(source, {"Name"}, "Name", "Data", "ItemKind", "ItemName", "IsLeaf")
    in
        navTable;

SafeguardAssetNavTable = (applianceName as text, optional resourcePath as text, optional filter as text, optional fields as text, optional queryOptions as text, optional responseFormat as text) as table =>
    let
        fieldsNullOrEmpty = fields = null or Text.Length(fields) = 0,
        source = #table({"Name", "Data", "ItemKind", "ItemName", "IsLeaf"}, {
            {
                "Assets", 
                Data.GetDataTable(
                    applianceName, 
                    Constants[Endpoints][Assets], 
                    filter, 
                    if fieldsNullOrEmpty then Constants[Fields][Assets] else fields, 
                    queryOptions,
                    responseFormat),
                "Table",
                "Table",
                true
            },
            {
                "Asset Accounts",
                Data.GetDataTable(
                    applianceName, 
                    Constants[Endpoints][AssetAccounts], 
                    filter, 
                    if fieldsNullOrEmpty then Constants[Fields][AssetAccounts] else fields, 
                    queryOptions,responseFormat), 
                "Table", 
                "Table", 
                true 
            },
            { 
                "Asset Partitions", 
                Data.GetDataTable(
                    applianceName, 
                    Constants[Endpoints][AssetPartitions], 
                    filter, 
                    if fieldsNullOrEmpty then Constants[Fields][AssetPartitions] else fields,
                    queryOptions,
                    responseFormat),
                "Table", 
                "Table",
                true 
            },
            {
                "Discovered Accounts",
                Data.GetDataTable(
                    applianceName, 
                    Constants[Endpoints][DiscoveredAccounts], 
                    filter, 
                    fields, 
                    queryOptions,
                    responseFormat), 
                "Table", 
                "Table", 
                true
            },
            {
                "Discovered Services", 
                Data.GetDataTable(
                    applianceName, 
                    Constants[Endpoints][DiscoveredServices], 
                    filter, 
                    fields, 
                    queryOptions,responseFormat), 
                "Table", 
                "Table", 
                true
            },
            { 
                "Discovered SSH Keys", 
                Data.GetDataTable(
                    applianceName, 
                    Constants[Endpoints][DiscoveredSshKeys], 
                    filter, 
                    fields, 
                    queryOptions,responseFormat), 
                "Table", 
                "Table", 
                true
            }
        }),
        navTable = Table.ToNavigationTable(source, {"Name"}, "Name", "Data", "ItemKind", "ItemName", "IsLeaf")
    in
        navTable;
        
SafeguardUserNavTable = (applianceName as text, optional resourcePath as text, optional filter as text, optional fields as text, optional queryOptions as text, optional responseFormat as text) as table =>
    let
        source = #table({"Name", "Data", "ItemKind", "ItemName", "IsLeaf"}, {
            { "Users", Data.GetDataTable(applianceName, Constants[Endpoints][Users], filter, fields, queryOptions,responseFormat), "Table", "Table", true },
            { "User Groups", Data.GetDataTable(applianceName, Constants[Endpoints][UserGroups], filter, fields, queryOptions,responseFormat), "Table", "Table", true },
            { "Identity Providers", Data.GetDataTable(applianceName, Constants[Endpoints][IdentityProviders], filter, fields, queryOptions,responseFormat), "Table", "Table", true }
        }),
        navTable = Table.ToNavigationTable(source, {"Name"}, "Name", "Data", "ItemKind", "ItemName", "IsLeaf")
    in
        navTable;
        
SafeguardPolicyNavTable = (applianceName as text, optional resourcePath as text, optional filter as text, optional fields as text, optional queryOptions as text, optional responseFormat as text) as table =>
    let
        source = #table({"Name", "Data", "ItemKind", "ItemName", "IsLeaf"}, {
            { "Entitlements", Data.GetDataTable(applianceName, Constants[Endpoints][Roles], filter, fields, queryOptions,responseFormat), "Table", "Table", true },
            { "Policies", Data.GetDataTable(applianceName, Constants[Endpoints][AccessPolicies], filter, fields, queryOptions,responseFormat), "Table", "Table", true },
            { "Asset Groups", Data.GetDataTable(applianceName, Constants[Endpoints][AssetGroups], filter, fields, queryOptions,responseFormat), "Table", "Table", true },
            { "Account Groups", Data.GetDataTable(applianceName, Constants[Endpoints][AccountGroups], filter, fields, queryOptions,responseFormat), "Table", "Table", true }
        }),
        navTable = Table.ToNavigationTable(source, {"Name"}, "Name", "Data", "ItemKind", "ItemName", "IsLeaf")
    in
        navTable;
        
SafeguardAuditNavTable = (applianceName as text, optional resourcePath as text, optional filter as text, optional fields as text, optional queryOptions as text, optional responseFormat as text) as table =>
    let
        source = #table({"Name", "Data", "ItemKind", "ItemName", "IsLeaf"}, {
            { "Search", Data.GetDataTable(applianceName, Constants[Endpoints][AuditLog][AccessRequests], filter, fields, queryOptions,responseFormat), "Table", "Table", true },
            { "Access Requests", Data.GetDataTable(applianceName, Constants[Endpoints][AuditLog][AccessRequests], filter, fields, queryOptions,responseFormat), "Table", "Table", true },
            { "Access Request Activity", Data.GetDataTable(applianceName, Constants[Endpoints][AuditLog][Activities], filter, fields, queryOptions,responseFormat), "Table", "Table", true },
            { "Access Request Session Activity", Data.GetDataTable(applianceName, Constants[Endpoints][AuditLog][Sessions], filter, fields, queryOptions,responseFormat), "Table", "Table", true },
            { "Appliance", Data.GetDataTable(applianceName, Constants[Endpoints][AuditLog][Appliances], filter, fields, queryOptions,responseFormat), "Table", "Table", true },
            { "Archives", Data.GetDataTable(applianceName, Constants[Endpoints][AuditLog][Archives], filter, fields, queryOptions,responseFormat), "Table", "Table", true },
            { "Directory Synchronization", Data.GetDataTable(applianceName, Constants[Endpoints][AuditLog][DirectorySync], filter, fields, queryOptions,responseFormat), "Table", "Table", true },
            { "Account Discovery", Data.GetDataTable(applianceName, Constants[Endpoints][AuditLog][DiscoveredAccounts], filter, fields, queryOptions,responseFormat), "Table", "Table", true },
            { "Asset Discovery", Data.GetDataTable(applianceName, Constants[Endpoints][AuditLog][DiscoveredAssets], filter, fields, queryOptions,responseFormat), "Table", "Table", true },
            { "Service Discovery", Data.GetDataTable(applianceName, Constants[Endpoints][AuditLog][DiscoveredServices], filter, fields, queryOptions,responseFormat), "Table", "Table", true },
            { "SSH Key Discovery", Data.GetDataTable(applianceName, Constants[Endpoints][AuditLog][DiscoveredSshKeys], filter, fields, queryOptions,responseFormat), "Table", "Table", true },
            { "Logins", Data.GetDataTable(applianceName, Constants[Endpoints][AuditLog][Logins], filter, fields, queryOptions,responseFormat), "Table", "Table", true },
            { "Object Changes", Data.GetDataTable(applianceName, Constants[Endpoints][AuditLog][ObjectChanges], filter, fields, queryOptions,responseFormat), "Table", "Table", true },
            { "Password Activity", Data.GetDataTable(applianceName, Constants[Endpoints][AuditLog][Passwords], filter, fields, queryOptions,responseFormat), "Table", "Table", true }
        }),
        navTable = Table.ToNavigationTable(source, {"Name"}, "Name", "Data", "ItemKind", "ItemName", "IsLeaf")
    in
        navTable;
        
SafeguardReportNavTable = (applianceName as text, optional resourcePath as text, optional filter as text, optional fields as text, optional queryOptions as text, optional responseFormat as text) as table =>
    let
        source = #table({"Name", "Data", "ItemKind", "ItemName", "IsLeaf"}, {
            { "Entitlements - Account", Data.GetDataTable(applianceName, Constants[Endpoints][Reports][AccountEntitlements], filter, fields, queryOptions,responseFormat), "Table", "Table", true },
            { "Entitlements - Asset", Data.GetDataTable(applianceName, Constants[Endpoints][Reports][AssetEntitlements], filter, fields, queryOptions,responseFormat), "Table", "Table", true },
            { "Entitlements - User", Data.GetDataTable(applianceName, Constants[Endpoints][Reports][UserEntitlements], filter, fields, queryOptions,responseFormat), "Table", "Table", true },
            { "Ownership - Account", ReportUtilities.GetAssetAccountOwnershipDataTable(applianceName), "Table", "Table", true },
            { "Ownership - Partition", ReportUtilities.GetAssetPartitionOwnershipDataTable(applianceName), "Table", "Table", true },
            { "Ownership - Asset", ReportUtilities.GetAssetOwnershipDataTable(applianceName), "Table", "Table", true },
            { "Account Task Summary", Data.GetDataTable(applianceName, Constants[Endpoints][Reports][AccountTaskSummary], filter, fields, queryOptions,responseFormat), "Table", "Table", true },
            { "Failed Password Changes", Data.GetDataTable(applianceName, Constants[Endpoints][Reports][FailedChangePassword], filter, fields, queryOptions,responseFormat), "Table", "Table", true },
            { "Failed Password Checks", Data.GetDataTable(applianceName, Constants[Endpoints][Reports][FailedCheckPassword], filter, fields, queryOptions,responseFormat), "Table", "Table", true },
            { "Failed SSH Key Changes", Data.GetDataTable(applianceName, Constants[Endpoints][Reports][FailedChangeSshKey], filter, fields, queryOptions,responseFormat), "Table", "Table", true },
            { "Failed SSH Key Checks", Data.GetDataTable(applianceName, Constants[Endpoints][Reports][FailedCheckSshKey], filter, fields, queryOptions,responseFormat), "Table", "Table", true },
            { "Failed Account Discovery", Data.GetDataTable(applianceName, Constants[Endpoints][Reports][FailedDiscoverAccounts], filter, fields, queryOptions,responseFormat), "Table", "Table", true },
            { "Failed Service Discovery", Data.GetDataTable(applianceName, Constants[Endpoints][Reports][FailedDiscoverServices], filter, fields, queryOptions,responseFormat), "Table", "Table", true }
        }),
        navTable = Table.ToNavigationTable(source, {"Name"}, "Name", "Data", "ItemKind", "ItemName", "IsLeaf")
    in
        navTable;
        
SafeguardClusterNavTable = (applianceName as text, optional resourcePath as text, optional filter as text, optional fields as text, optional queryOptions as text, optional responseFormat as text) as table =>
    let
        source = #table({"Name", "Data", "ItemKind", "ItemName", "IsLeaf"}, {
            { "Managed Networks", Data.GetDataTable(applianceName, Constants[Endpoints][Cluster][ManagedNetworks], filter, fields, queryOptions,responseFormat), "Table", "Table", true },
            { "Members", Data.GetDataTable(applianceName, Constants[Endpoints][Cluster][Members], filter, fields, queryOptions,responseFormat), "Table", "Table", true },
            { "Status   ", Data.GetDataTable(applianceName, Constants[Endpoints][Cluster][Status], filter, fields, queryOptions,responseFormat), "Table", "Table", true },
            { "Platform Task Load Status", Data.GetDataTable(applianceName, Constants[Endpoints][Cluster][PlatformTaskLoadStatus], filter, fields, queryOptions,responseFormat), "Table", "Table", true }
        }),
        navTable = Table.ToNavigationTable(source, {"Name"}, "Name", "Data", "ItemKind", "ItemName", "IsLeaf")
    in
        navTable;
        
SafeguardApplianceNavTable = (applianceName as text, optional resourcePath as text, optional filter as text, optional fields as text, optional queryOptions as text, optional responseFormat as text) as table =>
    let
        source = #table({"Name", "Data", "ItemKind", "ItemName", "IsLeaf"}, {
            { "Appliance Status", Data.GetDataTable(applianceName, Constants[Endpoints][NotificationStatus], filter, fields, queryOptions,responseFormat), "Table", "Table", true },
            { "Appliance Health", Data.GetDataTable(applianceName, Constants[Endpoints][Appliance][Health], filter, fields, queryOptions,responseFormat), "Table", "Table", true },
            { "Backups", Data.GetDataTable(applianceName, Constants[Endpoints][Appliance][Backups], filter, fields, queryOptions,responseFormat), "Table", "Table", true },
            { "CPU Status", Data.GetDataTable(applianceName, Constants[Endpoints][Appliance][CpuStatuses], filter, fields, queryOptions,responseFormat), "Table", "Table", true },
            { "Disk Status", Data.GetDataTable(applianceName, Constants[Endpoints][Appliance][DiskStatus], filter, fields, queryOptions,responseFormat), "Table", "Table", true },
            { "Hardware Status", Data.GetDataTable(applianceName, Constants[Endpoints][Appliance][HardwareStatus], filter, fields, queryOptions,responseFormat), "Table", "Table", true },
            { "Memory Status", Data.GetDataTable(applianceName, Constants[Endpoints][Appliance][MemoryStatus], filter, fields, queryOptions,responseFormat), "Table", "Table", true },
            { "NTP Status", Data.GetDataTable(applianceName, Constants[Endpoints][Appliance][NtpClientStatus], filter, fields, queryOptions,responseFormat), "Table", "Table", true }
        }),
        navTable = Table.ToNavigationTable(source, {"Name"}, "Name", "Data", "ItemKind", "ItemName", "IsLeaf")
    in
        navTable;

// Data Source Kind description
SafeguardPasswords = [
    // TestConnection is required to enable the connector through the Gateway
    TestConnection = (dataSourcePath) =>
        let
            _host = GetHost(dataSourcePath)
        in
            { "SafeguardPasswords.Custom", _host, Constants[Endpoints][Me], null, null, null },

    Authentication = [        
        UsernamePassword = []
    ],
    Label = Extension.LoadString("DataSourceLabel")
];

// Data Source UI publishing description
SafeguardPasswords.Publish = [
    Beta = true,
    Category = "Other",
    ButtonText = { Extension.LoadString("ButtonTitle"), Extension.LoadString("ButtonHelp") },
    LearnMoreUrl = "https://powerbi.microsoft.com/",
    SourceImage = SafeguardPasswords.Icons,
    SourceTypeImage = SafeguardPasswords.Icons
];

SafeguardPasswords.Icons = [
    Icon16 = {
        Extension.Contents("OneIdentitySafeguardForPrivilegedPasswordsPowerBIConnector.png"),
        Extension.Contents("OneIdentitySafeguardForPrivilegedPasswordsPowerBIConnector.png"),
        Extension.Contents("OneIdentitySafeguardForPrivilegedPasswordsPowerBIConnector.png"),
        Extension.Contents("OneIdentitySafeguardForPrivilegedPasswordsPowerBIConnector.png")
    },
    Icon32 = {
        Extension.Contents("OneIdentitySafeguardForPrivilegedPasswordsPowerBIConnector.png"),
        Extension.Contents("OneIdentitySafeguardForPrivilegedPasswordsPowerBIConnector.png"),
        Extension.Contents("OneIdentitySafeguardForPrivilegedPasswordsPowerBIConnector.png"),
        Extension.Contents("OneIdentitySafeguardForPrivilegedPasswordsPowerBIConnector.png")
    }
];

//
// Load common library functions
//
shared Extension.ImportModule = (name as text) =>
    let
        binary = Extension.Contents(name), asText = Text.FromBinary(binary)
    in
        Expression.Evaluate(asText, #shared);

shared Extension.ImportFunction = (function_name as text, module_name as text) =>
    Record.Field(Extension.ImportModule(module_name), function_name);

Table.ToNavigationTable = (
    table as table,
    keyColumns as list,
    nameColumn as text,
    dataColumn as text,
    itemKindColumn as text,
    itemNameColumn as text,
    isLeafColumn as text
) as table =>
    let
        tableType = Value.Type(table),
        newTableType = Type.AddTableKey(tableType, keyColumns, true) meta 
        [
            NavigationTable.NameColumn = nameColumn, 
            NavigationTable.DataColumn = dataColumn,
            NavigationTable.ItemKindColumn = itemKindColumn, 
            Preview.DelayColumn = itemNameColumn, 
            NavigationTable.IsLeafColumn = isLeafColumn
        ],
        navigationTable = Value.ReplaceType(table, newTableType)
    in
        navigationTable;
