[Version = "1.0.0"]
section SafeguardPasswords;

loginToken = "";

[DataSource.Kind="SafeguardPasswords", Publish="SafeguardPasswords.Publish"]
shared SafeguardPasswords.Contents = Value.ReplaceType(SafeguardPasswords.SafeguardNavTable, SafeguardPasswords.ContentsType);

shared SafeguardPasswords.SafeguardNavTable = (
    applianceName as text, 
    optional resourcePath as text, 
    optional filter as text, 
    optional fields as text, 
    optional queryOptions as text,
    optional responseFormat as text
) as table =>
    let
        source = #table({"Name", "Data", "ItemKind", "ItemName", "IsLeaf"}, {
            { "Custom", SafeguardPasswords.GetDataTable(applianceName, resourcePath, filter, fields, queryOptions, responseFormat), "Table", "Table", true },
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
                SafeguardPasswords.GetDataTable(
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
                SafeguardPasswords.GetDataTable(
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
                SafeguardPasswords.GetDataTable(
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
                SafeguardPasswords.GetDataTable(
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
                SafeguardPasswords.GetDataTable(
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
                SafeguardPasswords.GetDataTable(
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
            { "Users", SafeguardPasswords.GetDataTable(applianceName, Constants[Endpoints][Users], filter, fields, queryOptions,responseFormat), "Table", "Table", true },
            { "User Groups", SafeguardPasswords.GetDataTable(applianceName, Constants[Endpoints][UserGroups], filter, fields, queryOptions,responseFormat), "Table", "Table", true },
            { "Identity Providers", SafeguardPasswords.GetDataTable(applianceName, Constants[Endpoints][IdentityProviders], filter, fields, queryOptions,responseFormat), "Table", "Table", true }
        }),
        navTable = Table.ToNavigationTable(source, {"Name"}, "Name", "Data", "ItemKind", "ItemName", "IsLeaf")
    in
        navTable;
        
SafeguardPolicyNavTable = (applianceName as text, optional resourcePath as text, optional filter as text, optional fields as text, optional queryOptions as text, optional responseFormat as text) as table =>
    let
        source = #table({"Name", "Data", "ItemKind", "ItemName", "IsLeaf"}, {
            { "Entitlements", SafeguardPasswords.GetDataTable(applianceName, Constants[Endpoints][Roles], filter, fields, queryOptions,responseFormat), "Table", "Table", true },
            { "Policies", SafeguardPasswords.GetDataTable(applianceName, Constants[Endpoints][AccessPolicies], filter, fields, queryOptions,responseFormat), "Table", "Table", true },
            { "Asset Groups", SafeguardPasswords.GetDataTable(applianceName, Constants[Endpoints][AssetGroups], filter, fields, queryOptions,responseFormat), "Table", "Table", true },
            { "Account Groups", SafeguardPasswords.GetDataTable(applianceName, Constants[Endpoints][AccountGroups], filter, fields, queryOptions,responseFormat), "Table", "Table", true }
        }),
        navTable = Table.ToNavigationTable(source, {"Name"}, "Name", "Data", "ItemKind", "ItemName", "IsLeaf")
    in
        navTable;
        
SafeguardAuditNavTable = (applianceName as text, optional resourcePath as text, optional filter as text, optional fields as text, optional queryOptions as text, optional responseFormat as text) as table =>
    let
        source = #table({"Name", "Data", "ItemKind", "ItemName", "IsLeaf"}, {
            { "Search", SafeguardPasswords.GetDataTable(applianceName, Constants[Endpoints][AuditLog][AccessRequests], filter, fields, queryOptions,responseFormat), "Table", "Table", true },
            { "Access Requests", SafeguardPasswords.GetDataTable(applianceName, Constants[Endpoints][AuditLog][AccessRequests], filter, fields, queryOptions,responseFormat), "Table", "Table", true },
            { "Access Request Activity", SafeguardPasswords.GetDataTable(applianceName, Constants[Endpoints][AuditLog][Activities], filter, fields, queryOptions,responseFormat), "Table", "Table", true },
            { "Access Request Session Activity", SafeguardPasswords.GetDataTable(applianceName, Constants[Endpoints][AuditLog][Sessions], filter, fields, queryOptions,responseFormat), "Table", "Table", true },
            { "Appliance", SafeguardPasswords.GetDataTable(applianceName, Constants[Endpoints][AuditLog][Appliances], filter, fields, queryOptions,responseFormat), "Table", "Table", true },
            { "Archives", SafeguardPasswords.GetDataTable(applianceName, Constants[Endpoints][AuditLog][Archives], filter, fields, queryOptions,responseFormat), "Table", "Table", true },
            { "Directory Synchronization", SafeguardPasswords.GetDataTable(applianceName, Constants[Endpoints][AuditLog][DirectorySync], filter, fields, queryOptions,responseFormat), "Table", "Table", true },
            { "Account Discovery", SafeguardPasswords.GetDataTable(applianceName, Constants[Endpoints][AuditLog][DiscoveredAccounts], filter, fields, queryOptions,responseFormat), "Table", "Table", true },
            { "Asset Discovery", SafeguardPasswords.GetDataTable(applianceName, Constants[Endpoints][AuditLog][DiscoveredAssets], filter, fields, queryOptions,responseFormat), "Table", "Table", true },
            { "Service Discovery", SafeguardPasswords.GetDataTable(applianceName, Constants[Endpoints][AuditLog][DiscoveredServices], filter, fields, queryOptions,responseFormat), "Table", "Table", true },
            { "SSH Key Discovery", SafeguardPasswords.GetDataTable(applianceName, Constants[Endpoints][AuditLog][DiscoveredSshKeys], filter, fields, queryOptions,responseFormat), "Table", "Table", true },
            { "Logins", SafeguardPasswords.GetDataTable(applianceName, Constants[Endpoints][AuditLog][Logins], filter, fields, queryOptions,responseFormat), "Table", "Table", true },
            { "Object Changes", SafeguardPasswords.GetDataTable(applianceName, Constants[Endpoints][AuditLog][ObjectChanges], filter, fields, queryOptions,responseFormat), "Table", "Table", true },
            { "Password Activity", SafeguardPasswords.GetDataTable(applianceName, Constants[Endpoints][AuditLog][Passwords], filter, fields, queryOptions,responseFormat), "Table", "Table", true }
        }),
        navTable = Table.ToNavigationTable(source, {"Name"}, "Name", "Data", "ItemKind", "ItemName", "IsLeaf")
    in
        navTable;
        
SafeguardReportNavTable = (applianceName as text, optional resourcePath as text, optional filter as text, optional fields as text, optional queryOptions as text, optional responseFormat as text) as table =>
    let
        source = #table({"Name", "Data", "ItemKind", "ItemName", "IsLeaf"}, {
            { "Entitlements - Account", SafeguardPasswords.GetDataTable(applianceName, Constants[Endpoints][Reports][AccountEntitlements], filter, fields, queryOptions,responseFormat), "Table", "Table", true },
            { "Entitlements - Asset", SafeguardPasswords.GetDataTable(applianceName, Constants[Endpoints][Reports][AssetEntitlements], filter, fields, queryOptions,responseFormat), "Table", "Table", true },
            { "Entitlements - User", SafeguardPasswords.GetDataTable(applianceName, Constants[Endpoints][Reports][UserEntitlements], filter, fields, queryOptions,responseFormat), "Table", "Table", true },
            { "Ownership - Account", SafeguardPasswords.ReportUtilities.GetAssetAccountOwnershipDataTable(applianceName), "Table", "Table", true },
            { "Ownership - Partition", SafeguardPasswords.ReportUtilities.GetAssetPartitionOwnershipDataTable(applianceName), "Table", "Table", true },
            { "Ownership - Asset", SafeguardPasswords.ReportUtilities.GetAssetOwnershipDataTable(applianceName), "Table", "Table", true },
            { "Account Task Summary", SafeguardPasswords.GetDataTable(applianceName, Constants[Endpoints][Reports][AccountTaskSummary], filter, fields, queryOptions,responseFormat), "Table", "Table", true },
            { "Failed Password Changes", SafeguardPasswords.GetDataTable(applianceName, Constants[Endpoints][Reports][FailedChangePassword], filter, fields, queryOptions,responseFormat), "Table", "Table", true },
            { "Failed Password Checks", SafeguardPasswords.GetDataTable(applianceName, Constants[Endpoints][Reports][FailedCheckPasswords], filter, fields, queryOptions,responseFormat), "Table", "Table", true },
            { "Failed SSH Key Changes", SafeguardPasswords.GetDataTable(applianceName, Constants[Endpoints][Reports][FailedChangeSshKey], filter, fields, queryOptions,responseFormat), "Table", "Table", true },
            { "Failed SSH Key Checks", SafeguardPasswords.GetDataTable(applianceName, Constants[Endpoints][Reports][FailedCheckSshKey], filter, fields, queryOptions,responseFormat), "Table", "Table", true },
            { "Failed Account Discovery", SafeguardPasswords.GetDataTable(applianceName, Constants[Endpoints][Reports][FailedDiscoverAccounts], filter, fields, queryOptions,responseFormat), "Table", "Table", true },
            { "Failed Service Discovery", SafeguardPasswords.GetDataTable(applianceName, Constants[Endpoints][Reports][FailedDiscoverServices], filter, fields, queryOptions,responseFormat), "Table", "Table", true }
        }),
        navTable = Table.ToNavigationTable(source, {"Name"}, "Name", "Data", "ItemKind", "ItemName", "IsLeaf")
    in
        navTable;
        
SafeguardClusterNavTable = (applianceName as text, optional resourcePath as text, optional filter as text, optional fields as text, optional queryOptions as text, optional responseFormat as text) as table =>
    let
        source = #table({"Name", "Data", "ItemKind", "ItemName", "IsLeaf"}, {
            { "Managed Networks", SafeguardPasswords.GetDataTable(applianceName, Constants[Endpoints][Cluster][ManagedNetworks], filter, fields, queryOptions,responseFormat), "Table", "Table", true },
            { "Members", SafeguardPasswords.GetDataTable(applianceName, Constants[Endpoints][Cluster][Members], filter, fields, queryOptions,responseFormat), "Table", "Table", true },
            { "Status   ", SafeguardPasswords.GetDataTable(applianceName, Constants[Endpoints][Cluster][Status], filter, fields, queryOptions,responseFormat), "Table", "Table", true },
            { "Platform Task Load Status", SafeguardPasswords.GetDataTable(applianceName, Constants[Endpoints][Cluster][PlatformTaskLoadStatus], filter, fields, queryOptions,responseFormat), "Table", "Table", true }
        }),
        navTable = Table.ToNavigationTable(source, {"Name"}, "Name", "Data", "ItemKind", "ItemName", "IsLeaf")
    in
        navTable;
        
SafeguardApplianceNavTable = (applianceName as text, optional resourcePath as text, optional filter as text, optional fields as text, optional queryOptions as text, optional responseFormat as text) as table =>
    let
        source = #table({"Name", "Data", "ItemKind", "ItemName", "IsLeaf"}, {
            { "Appliance Status", SafeguardPasswords.GetDataTable(applianceName, Constants[Endpoints][NotificationStatus], filter, fields, queryOptions,responseFormat), "Table", "Table", true },
            { "Appliance Health", SafeguardPasswords.GetDataTable(applianceName, Constants[Endpoints][Appliance][Health], filter, fields, queryOptions,responseFormat), "Table", "Table", true },
            { "Backups", SafeguardPasswords.GetDataTable(applianceName, Constants[Endpoints][Appliance][Backups], filter, fields, queryOptions,responseFormat), "Table", "Table", true },
            { "CPU Status", SafeguardPasswords.GetDataTable(applianceName, Constants[Endpoints][Appliance][CpuStatuses], filter, fields, queryOptions,responseFormat), "Table", "Table", true },
            { "Disk Status", SafeguardPasswords.GetDataTable(applianceName, Constants[Endpoints][Appliance][DiskStatus], filter, fields, queryOptions,responseFormat), "Table", "Table", true },
            { "Hardware Status", SafeguardPasswords.GetDataTable(applianceName, Constants[Endpoints][Appliance][HardwareStatus], filter, fields, queryOptions,responseFormat), "Table", "Table", true },
            { "Memory Status", SafeguardPasswords.GetDataTable(applianceName, Constants[Endpoints][Appliance][MemoryStatus], filter, fields, queryOptions,responseFormat), "Table", "Table", true },
            { "NTP Status", SafeguardPasswords.GetDataTable(applianceName, Constants[Endpoints][Appliance][NtpClientStatus], filter, fields, queryOptions,responseFormat), "Table", "Table", true }
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

SafeguardPasswords.GetDataTable = (applianceName as text, optional resourcePath as text, optional filter as text, optional fields as text, optional queryOptions as text, optional responseFormat as text) as table => 
    let
        validated = ValidateInput(applianceName,resourcePath,filter,fields,queryOptions),

        host = GetHost("https://" & applianceName),

        loginToken = if loginToken = null or Text.Length(loginToken) = 0 or loginToken = "" then GetLoginToken(host) else loginToken,

        hasFilter = if filter = null or Text.Length(filter) = 0 then false else true,
        hasFields = if fields = null or Text.Length(fields) = 0 or fields = "all" then false else true,
        hasQueryOptions = if queryOptions = null or Text.Length(queryOptions) = 0 then false else true,

        query1 = if resourcePath = null or Text.Length(resourcePath) = 0 then host & "?" else Uri.Combine(host, Text.Trim(resourcePath, "/")) & "?",
        query2 = if not hasFilter then query1 else query1 & "filter=" & Text.Trim(filter,"&") & "&",
        query3 = if not hasFields then query2 else query2 & "fields=" & Text.Trim(fields,"&") & "&",
        query4 = if not hasQueryOptions then query3 else query3 & Text.Trim(queryOptions, "&"),
        query = Text.Trim(Text.Trim(Text.Trim(query4, "/"), "?"), "&"),

        // we will never act on the else case - if validation fails we throw in the ValidateInput method.
        // But ValidateInput() doesn't evalute until the var is referenced.
       data =   if validated = true then 
                    if not (responseFormat = "CSV") or responseFormat = null or Text.Length(responseFormat) = 0 
                        then Logger.InfoLog("Executing JSON Query", GetResponse(query, [#"Content-Type"="application/json", Authorization="Bearer " & loginToken])) 
                    else Logger.InfoLog("Executing CSV Query", GetCsvResponse(query, [#"Content-Type"="text/csv", #"Accept"="text/csv", Authorization="Bearer " & loginToken])) 
                else null,

        // GetResponse returns either a list or value that needs to be parsed into a table.
        // GetCsvResponse returns a table where the first row is the column names. We need to parse out (promote) the headers in that case.
        a = if data is list 
                then Table.FromRecords(data) 
            else if data is table
                then Table.PromoteHeaders(data)
            else Table.FromValue(data)
    in
        a;

// Report Utilities //

// Retrieves table of asset IDs, then for each ID queries the Assets/ID/EffectiveManagedBy endpoint to retrieve owners
SafeguardPasswords.ReportUtilities.GetAssetOwnershipDataTable = (applianceName as text) as table => 
    let
        assetIds = SafeguardPasswords.GetDataTable(applianceName, Constants[Endpoints][Assets], null, "Id,Name", null, "JSON"),
        owners = Table.AddColumn(assetIds, "Owners", each SafeguardPasswords.GetDataTable(applianceName, Constants[Endpoints][Assets]&"/"&Number.ToText([Id])&"/EffectiveManagedBy", null, Constants[Fields][AssetOwnershipReport], null, "JSON")),
        expandedOwners = Table.ExpandTableColumn(owners,"Owners", {"Name", "EmailAddress","PrincipalKind","IdentityProviderName","Direct"}, {"Owners.Name", "Owners.EmailAddress", "Owners.PrincipalKind", "Owners.IdentityProviderName", "Owners.Direct"})
    in
        expandedOwners;

// Retrieves table of assetaccount IDs, then for each ID queries the AssetAccounts/ID/EffectiveManagedBy endpoint to retrieve owners
SafeguardPasswords.ReportUtilities.GetAssetAccountOwnershipDataTable = (applianceName as text) as table => 
    let
        assetAccountIds = SafeguardPasswords.GetDataTable(applianceName, Constants[Endpoints][AssetAccounts], null, "Id,Name", null, "JSON"),
        owners = Table.AddColumn(assetAccountIds, "Owners", each SafeguardPasswords.GetDataTable(applianceName, Constants[Endpoints][AssetAccounts]&"/"&Number.ToText([Id])&"/EffectiveManagedBy", null, Constants[Fields][AssetAccountOwnershipReport], null, "JSON")),
        expandedOwners = Table.ExpandTableColumn(owners,"Owners", {"Name", "EmailAddress","PrincipalKind","IdentityProviderName","Direct"}, {"Owners.Name", "Owners.EmailAddress", "Owners.PrincipalKind", "Owners.IdentityProviderName", "Owners.Direct"})
    in
        expandedOwners;

// Retrieves table of assetpartition IDs, then for each ID queries the AssetPartitions/ID/ManagedBy endpoint to retrieve owners
SafeguardPasswords.ReportUtilities.GetAssetPartitionOwnershipDataTable = (applianceName as text) as table => 
    let
        assetPartitionIds = SafeguardPasswords.GetDataTable(applianceName, Constants[Endpoints][AssetPartitions], null, "Id,Name", null, "JSON"),
        owners = Table.AddColumn(assetPartitionIds, "Owners", each SafeguardPasswords.GetDataTable(applianceName, Constants[Endpoints][AssetPartitions]&"/"&Number.ToText([Id])&"/ManagedBy", null, Constants[Fields][AssetPartitionOwnershipReport], null, "JSON")),
        expandedOwners = Table.ExpandTableColumn(owners,"Owners", {"Name", "EmailAddress","PrincipalKind","IdentityProviderName","Direct"}, {"Owners.Name", "Owners.EmailAddress", "Owners.PrincipalKind", "Owners.IdentityProviderName", "Owners.Direct"})
    in
        expandedOwners;

ValidateInput = (applianceName as text, optional resourcePath as text, optional filter as text, optional fields as text, optional queryOptions as text) => 
    // M Language does not support regex so validation is ugly. (◡︵◡)
    //
    // Filter validation and field validation are handled by SPP API.
    // So we really only need to ensure that no Resource Path is passed in
    // as part of the applianceName / FQDN / IP, 
    // and that the Resource Path doesn't contain a query. 

    if( Text.Contains(applianceName,"&") or 
        Text.Contains(applianceName,"?") or
        
        Text.Contains(resourcePath,"&") or 
        Text.Contains(resourcePath,"?") or
        Text.Contains(resourcePath, ".") or
        not Text.Contains(resourcePath,"service",Comparer.OrdinalIgnoreCase)
    ) then
        error "Appliance FQDN or Resource Path failed Validation. Appliance FQDN: " & applianceName & "; Resource Path: " & resourcePath
    else
        true;

GetLoginToken = (host) =>
    let
        creds = Extension.CurrentCredential(),
        user = User.GetDomain(creds[Username]),
        providerScope = User.GetProvider(host, user[Domain]),

        rstsResponse = GetResponse(host,[#"Content-Type"="application/json"], Constants[RstsRelativePath], Json.FromValue([
            grant_type="password",
            scope=providerScope,
            username=user[Username],
            password=creds[Password]
        ])),

        loginToken = Function.InvokeAfter(() => GetLoginResponse(host, rstsResponse), #duration(0,0,0,Number.RandomBetween(1,5)))
    in
        loginToken;

GetLoginResponse = (host as text, rstsResponse as any) =>
    let
        loginResponse = GetResponse(host, [#"Content-Type"="application/json"], Constants[Endpoints][LoginResponse], Json.FromValue([
            StsAccessToken=rstsResponse[#"access_token"]
        ])),

        loginToken = loginResponse[UserToken]
    in
        loginToken;

User.GetDomain = (fullUserName) =>
    let
        upnList = Text.Split(fullUserName, "@"),
        netbiosList = Text.Split(fullUserName, "\"),

        userName = if List.Count(upnList) = 2 then upnList{0} else if List.Count(netbiosList) = 2 then netbiosList{1} else fullUserName,
        domain = if List.Count(upnList) = 2 then upnList{1} else if List.Count(netbiosList) = 2 then netbiosList{0} else ""
    in
        [ Username = userName, Domain = domain ];

        
User.GetProvider = (host, domainName) =>
    let
        localOrDomainName = if domainName = "" then "local" else domainName,

        providers = GetResponse(host, [ #"Content-Type"="application/json" ], Constants[Endpoints][AuthenticationProviders],null, [filter = "Name ieq '" & localOrDomainName & "'"]),
        
        scope = if List.Count(providers) = 1 then providers{0}[RstsProviderScope] else "rsts:sts:primaryproviderid:local"
    in
        scope;

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

SafeguardPasswords.ContentsType = Extension.ImportFunction("ContentsType","Types.pqm");
Constants = Extension.ImportModule("Constants.pqm")[SppConstants];
GetHost = Extension.ImportFunction("GetSppHost","UrlBuilder.pqm");
GetResponse = Extension.ImportFunction("GetSppResponse","Request.pqm");
GetCsvResponse = Extension.ImportFunction("GetCsvSppResponse","Request.pqm");
Logger.ErrorLog = Extension.ImportFunction("ErrorLog","Logger.pqm");
Logger.InfoLog = Extension.ImportFunction("InfoLog", "Logger.pqm");

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
