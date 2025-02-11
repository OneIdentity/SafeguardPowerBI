[Version = "2.0.2"]
section SafeguardSessions;

[DataSource.Kind = "SafeguardSessions", Publish = "SafeguardSessions.Publish"]
shared SafeguardSessions.Contents = Value.ReplaceType(SafeguardSessions.ContentsImpl, SafeguardSessions.ContentsType);

shared SafeguardSessions.ContentsImpl = (
    spsIP as text,
    optional skipVersionCheck as text,
    optional from as datetimezone,
    optional to as datetimezone,
    optional filterField1 as text,
    optional filterValue1 as text,
    optional filterField2 as text,
    optional filterValue2 as text,
    optional filterField3 as text,
    optional filterValue3 as text
) as table =>
    let
        sessions = FetchSessions(
            spsIP,
            Extension.CurrentCredential(),
            from,
            to,
            filterField1,
            filterValue1,
            filterField2,
            filterValue2,
            filterField3,
            filterValue3,
            skipVersionCheck
        )
    in
        sessions;

shared FetchSessions = (
    spsIp as text,
    credentials as record,
    from as nullable datetimezone,
    to as nullable datetimezone,
    filterField1 as nullable text,
    filterValue1 as nullable text,
    filterField2 as nullable text,
    filterValue2 as nullable text,
    filterField3 as nullable text,
    filterValue3 as nullable text,
    skipVersionCheck as nullable text,
    optional mocks as nullable record
) =>
    let
        qParameterInputPairList = {
            {filterField1, filterValue1},
            {filterField2, filterValue2},
            {filterField3, filterValue3}
        },
        query = [
            qInput = qParameterInputPairList,
            from = from,
            to = to
        ],
        data =
            if IsMocked(mocks, "ReturnParams") then
                [
                    SpsIp = spsIp,
                    Credentials = credentials,
                    Query = query,
                    SkipVersionCheck = skipVersionCheck,
                    Mocks = mocks
                ]
            else
                GetData(spsIp, credentials, query, skipVersionCheck, mocks)
    in
        data;

shared GetData = (
    spsIp as text,
    credentials as record,
    query as record,
    skipVersionCheck as nullable text,
    optional mocks as nullable record
) =>
    let
        startTime = DateTimeZone.LocalNow(),
        spsUrl = UrlBuilder.GenerateBaseUrl("https", spsIp),
        authResponse =
            if IsMocked(mocks, "Authenticate") then
                mocks[Authenticate][Value]
            else
                Authenticate(spsUrl, credentials, mocks),
        sessionId = ValidateSPSVersion(
            spsUrl,
            BaseAuthentication.MineSessionIdFromCookie(Request.GetHeader(Value.Metadata(authResponse), "Set-Cookie")),
            skipVersionCheck,
            mocks
        ),
        response =
            if IsMocked(mocks, "FetchData") then
                mocks[FetchData][Value]
            else
                FetchData(spsUrl, UrlBuilder.DefaultQuery & query, sessionId, mocks),
        data = HandleIfThereIsAnError(try (response)),
        result = BuildSPSResult(data, startTime)
    in
        result;

shared ValidateSPSVersion = (
    spsUrl as text, sessionId as text, skipVersionCheck as nullable text, optional mocks as nullable record
) =>
    let
        sessionIdOrError =
            if skipVersionCheck = Yes then
                sessionId
            else
                let
                    version = Version.GetVersion(spsUrl, sessionId, mocks),
                    checkedVersion = try Version.CheckVersion(version, SupportedVersions.Versions),
                    validatedVersion =
                        if checkedVersion[HasError] then
                            error checkedVersion[Error]
                        else if not checkedVersion[Value] then
                            let
                                notSupportedError = VersionErrors.NotSupportedVersion(version),
                                log = Logger.ErrorLog(
                                    "Connector tried to connect to an unsupported SPS", [
                                        Error = notSupportedError
                                    ]
                                )
                            in
                                error log[Error]
                        else
                            sessionId
                in
                    validatedVersion
    in
        sessionIdOrError;

shared Authenticate = (spsUrl as text, credentials as record, optional mocks as nullable record) as record =>
    let
        authUrl = UrlBuilder.GenerateUrl(spsUrl, AuthEndpoint),
        encodedCredentails = BaseAuthentication.EncodeCredentials(credentials[Username], credentials[Password]),
        response =
            if IsMocked(mocks, "AuthResponse") then
                Request.Generate(
                    authUrl, Request.GetAuthParameters(encodedCredentails), [Response = mocks[AuthResponse]]
                )
            else
                Request.Generate(authUrl, Request.GetAuthParameters(encodedCredentails))
    in
        response;

shared FetchData = (spsUrl as text, queryParams as record, sessionId as text, optional mocks as nullable record) as table =>
    let
        snapshot = OpenSnapshot.OpenSnapshot(spsUrl, sessionId, mocks),
        sessions = AdvancedSearch.AdvancedSearch(spsUrl, queryParams, snapshot, sessionId, mocks),
        expectedSessionsCount = try GetSessionsCount.GetSessionsCount(spsUrl, queryParams, sessionId, mocks),
        sessionsWithCountMetadata =
            if expectedSessionsCount[HasError] = true then
                error expectedSessionsCount[Error]
            else
                Value.ReplaceMetadata(sessions, Value.Metadata(sessions) & [Count = expectedSessionsCount[Value]])
    in
        sessionsWithCountMetadata;

shared HandleIfThereIsAnError = (input as record) =>
    if input[HasError] = true then
        if input[Error][Detail] is record and Record.HasFields(input[Error][Detail], "ManuallyHandled") then
            if input[Error][Detail][ManuallyHandled] = true then
                input
            else
                error input[Error]
        else
            let
                transformedError = TransformUnexpectedError(input[Error]),
                logNotExpectedError = Logger.ErrorLog(
                    "An unexpected error happend during execution", transformedError
                )
            in
                error logNotExpectedError
    else
        input;

shared TestSpsConnection = (dataSourcePath) =>
    let
        json = Json.Document(dataSourcePath), spsIP = json[spsIP], skipVersionCheck = json[skipVersionCheck]
    in
        {"SafeguardSessions.Contents", spsIP, skipVersionCheck, null, null, null, null, null, null, null, null};

SafeguardSessions = [
    TestConnection = TestSpsConnection,
    Authentication = [
        UsernamePassword = []
    ],
    Label = Extension.LoadString("DataSourceLabel")
];

SafeguardSessions.Publish = [
    Beta = true,
    Category = "Other",
    ButtonText = {Extension.LoadString("ButtonTitle"), Extension.LoadString("ButtonHelp")},
    LearnMoreUrl = "https://powerbi.microsoft.com/",
    SourceImage = SafeguardSessions.Icons,
    SourceTypeImage = SafeguardSessions.Icons
];

SafeguardSessions.Icons = [
    Icon16 = {
        Extension.Contents("OneIdentitySafeguardPowerBIConnector16.png"),
        Extension.Contents("OneIdentitySafeguardPowerBIConnector20.png"),
        Extension.Contents("OneIdentitySafeguardPowerBIConnector24.png"),
        Extension.Contents("OneIdentitySafeguardPowerBIConnector32.png")
    },
    Icon32 = {
        Extension.Contents("OneIdentitySafeguardPowerBIConnector32.png"),
        Extension.Contents("OneIdentitySafeguardPowerBIConnector40.png"),
        Extension.Contents("OneIdentitySafeguardPowerBIConnector48.png"),
        Extension.Contents("OneIdentitySafeguardPowerBIConnector64.png")
    }
];

//
// Load common library functions
//
shared SafeguardSessions.ImportModule = (name as text) =>
    let
        binary = Extension.Contents(name), asText = Text.FromBinary(binary)
    in
        Expression.Evaluate(asText, #shared);

shared SafeguardSessions.ImportFunction = (function_name as text, module_name as text) =>
    Record.Field(SafeguardSessions.ImportModule(module_name), function_name);

SafeguardSessions.ContentsType = SafeguardSessions.ImportFunction("ContentsType", "Types.pqm");

IsMocked = SafeguardSessions.ImportFunction("IsMocked", "CommonUtils.pqm");

BuildSPSResult = SafeguardSessions.ImportFunction("BuildSPSResult", "Utils.pqm");

BaseAuthentication = SafeguardSessions.ImportModule("BaseAuthentication.pqm");

BaseAuthentication.EncodeCredentials = BaseAuthentication[EncodeCredentials];
BaseAuthentication.MineSessionIdFromCookie = BaseAuthentication[MineSessionIdFromCookie];

Request.GetAuthParameters = SafeguardSessions.ImportFunction("GetAuthParameters", "Request.pqm");
Request.Generate = SafeguardSessions.ImportFunction("Generate", "Request.pqm");
Request.GetHeader = SafeguardSessions.ImportFunction("GetHeader", "CommonRequest.pqm");

Version = SafeguardSessions.ImportModule("Version.pqm");

Version.GetVersion = Version[GetVersion];
Version.CheckVersion = Version[CheckVersion];

SupportedVersions = SafeguardSessions.ImportModule("SupportedVersions.pqm");

SupportedVersions.Versions = SupportedVersions[Versions];

VersionErrors.NotSupportedVersion = SafeguardSessions.ImportFunction("NotSupportedVersion", "VersionErrors.pqm");

GetSessionsCount = SafeguardSessions.ImportModule("GetSessionsCount.pqm");

GetSessionsCount.GetSessionsCount = GetSessionsCount[GetSessionsCount];

OpenSnapshot = SafeguardSessions.ImportModule("OpenSnapshot.pqm");

OpenSnapshot.OpenSnapshot = OpenSnapshot[OpenSnapshot];

AdvancedSearch = SafeguardSessions.ImportModule("AdvancedSearch.pqm");

AdvancedSearch.AdvancedSearch = AdvancedSearch[AdvancedSearch];

UrlBuilder = SafeguardSessions.ImportModule("UrlBuilder.pqm");

UrlBuilder.GenerateBaseUrl = UrlBuilder[GenerateBaseUrl];
UrlBuilder.GenerateUrl = UrlBuilder[GenerateUrl];
UrlBuilder.DefaultQuery = UrlBuilder[DefaultQuery];

Logger.ErrorLog = SafeguardSessions.ImportFunction("ErrorLog", "CommonLogger.pqm");

Yes = SafeguardSessions.ImportFunction("Yes", "Constants.pqm");

AuthEndpoint = SafeguardSessions.ImportFunction("AuthEndpoint", "Constants.pqm");

TransformUnexpectedError = SafeguardSessions.ImportFunction("TransformUnexpectedError", "UnexpectedErrorWrapper.pqm");
