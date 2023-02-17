// This file contains your Data Connector logic
[Version = "1.0.0"]
section SafeguardSessions;

[DataSource.Kind = "SafeguardSessions", Publish = "SafeguardSessions.Publish"]
shared SafeguardSessions.Contents = Value.ReplaceType(SafeguardSessions.ContentsImpl, SafeguardSessions.ContentsType);

shared SafeguardSessions.ContentsImpl = (
    sps_ip as text,
    from as nullable datetimezone,
    to as nullable datetimezone,
    filterField1 as nullable text,
    filterValue1 as nullable text,
    filterField2 as nullable text,
    filterValue2 as nullable text,
    filterField3 as nullable text,
    filterValue3 as nullable text
) as record =>
    let
        sessions = FetchSessions(
            sps_ip,
            Extension.CurrentCredential(),
            from,
            to,
            filterField1,
            filterValue1,
            filterField2,
            filterValue2,
            filterField3,
            filterValue3
        )
    in
        sessions;

shared FetchSessions = (
    sps_ip as text,
    credentials as record,
    from as nullable datetimezone,
    to as nullable datetimezone,
    filterField1 as nullable text,
    filterValue1 as nullable text,
    filterField2 as nullable text,
    filterValue2 as nullable text,
    filterField3 as nullable text,
    filterValue3 as nullable text,
    optional mocks as record
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
        data = GetData(sps_ip, credentials, query, mocks)
    in
        data;

shared GetData = (sps_ip as text, credentials as record, query as record, optional mocks as nullable record) =>
    let
        start_time = DateTimeZone.LocalNow(),
        base_url = UrlBuilder.GenerateBaseUrl("https", sps_ip),
        auth_url = UrlBuilder.GenerateUrl(base_url, "api/authentication"),
        authResponse =
            if IsMocked(mocks, "Authenticate") then
                mocks[Authenticate][Value]
            else
                Authenticate(auth_url, credentials, mocks),
        response =
            if IsMocked(mocks, "FetchData") then
                mocks[FetchData][Value]
            else
                FetchData(
                    UrlBuilder.GenerateUrl(base_url, "api/audit/sessions", UrlBuilder.GetDefaultQuery() & query),
                    BaseAuthentication.MineSessionIdFromCookie(
                        Request.GetHeader(Value.Metadata(authResponse), "Set-Cookie")
                    ),
                    mocks
                ),
        normalizedResponse = NormalizeResponse(response, mocks),
        data = HandleIfThereIsAnError(try (normalizedResponse)),
        result = BuildSPSResult(data, start_time, mocks)
    in
        result;

shared Authenticate = (url as text, credentials as record, optional mocks as nullable record) as record =>
    let
        encodedCredentails = BaseAuthentication.EncodeCredentials(credentials[Username], credentials[Password]),
        response =
            if IsMocked(mocks, "AuthResponse") then
                Request.Generate(
                    url, Request.GetAuthParameters(encodedCredentails), [Response = mocks[AuthResponse]]
                )
            else
                Request.Generate(url, Request.GetAuthParameters(encodedCredentails))
    in
        RaiseErrorOrReturn(response);

shared FetchData = (url as text, session_id as text, optional mocks as nullable record) as record =>
    let
        response =
            if IsMocked(mocks, "FetchResponse") then
                Request.Generate(url, Request.GetDefaultParameters(session_id), [Response = mocks[FetchResponse]])
            else
                Request.Generate(url, Request.GetDefaultParameters(session_id))
    in
        RaiseErrorOrReturn(response);

NormalizeResponse = (response as record, optional mocks as nullable record) =>
    let
        normalizedResponse =
            let
                transformedResponse = SchemaUtils.TransformResponse(response),
                sessions = SubTable.Create(Schema.Sessions, transformedResponse),
                subTableNames =
                    if IsMocked(mocks, "SubTables") then
                        mocks[SubTables]
                    else
                        Schema.GetSubTables(Schema.Sessions),
                normalizedSubTables =
                    if IsMocked(mocks, "NormalizeResult") then
                        mocks[NormalizeResult]
                    else
                        Normalize.Normalize(sessions, subTableNames, Schema.GetIdentifierColumn(Schema.Sessions)),
                withSchema = List.Transform(
                    normalizedSubTables,
                    (subTable) =>
                        SubTable.TransformData(
                            subTable,
                            (data) =>
                                SchemaUtils.TransformTable(
                                    data,
                                    if IsMocked(mocks, "Schema") then
                                        Record.Field(mocks[Schema], SubTable.GetName(subTable))
                                    else
                                        Schema.GetSchema(SubTable.GetName(subTable))
                                )
                        )
                ),
                asTable = Table.Buffer(Table.FromRecords(withSchema)),
                withMeta = Value.ReplaceMetadata(asTable, Value.Metadata(response))
            in
                withMeta
    in
        try normalizedResponse catch (e) => NormalizeError(response, e[Message]);

HandleIfThereIsAnError = (input as record) =>
    if input[HasError] = true then
        if input[Error][Detail] is record and Record.HasFields(input[Error][Detail], "ManuallyHandled") then
            if input[Error][Detail][ManuallyHandled] = true then
                input
            else
                error input[Error]
        else
            let
                logNotExpectedError = Logger.ErrorLog("An unexpected error happend during execution", input[Error])
            in
                error logNotExpectedError
    else
        input;

SafeguardSessions = [
    Authentication = [
        // Key = [],
        UsernamePassword = []
        // Windows = [],
        // Anonymous = []
    ],
    Label = Extension.LoadString("DataSourceLabel")
];

// Data Source UI publishing description
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
        Extension.Contents("SafeguardSessions16.png"),
        Extension.Contents("SafeguardSessions20.png"),
        Extension.Contents("SafeguardSessions24.png"),
        Extension.Contents("SafeguardSessions32.png")
    },
    Icon32 = {
        Extension.Contents("SafeguardSessions32.png"),
        Extension.Contents("SafeguardSessions40.png"),
        Extension.Contents("SafeguardSessions48.png"),
        Extension.Contents("SafeguardSessions64.png")
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

SafeguardSessions.ContentsType = Extension.ImportFunction("ContentsType", "Types.pqm");

Utils = Extension.ImportModule("Utils.pqm");

IsMocked = Utils[IsMocked];
BuildSPSResult = Utils[BuildSPSResult];

BaseAuthentication = Extension.ImportModule("BaseAuthentication.pqm");

BaseAuthentication.EncodeCredentials = BaseAuthentication[EncodeCredentials];
BaseAuthentication.MineSessionIdFromCookie = BaseAuthentication[MineSessionIdFromCookie];

RaiseErrorOrReturn = Extension.ImportFunction("RaiseErrorOrReturn", "RequestErrors.pqm");

Request = Extension.ImportModule("Request.pqm");

Request.GetAuthParameters = Request[GetAuthParameters];
Request.GetDefaultParameters = Request[GetDefaultParameters];
Request.Generate = Request[Generate];
Request.GetHeader = Request[GetHeader];

UrlBuilder = Extension.ImportModule("UrlBuilder.pqm");

UrlBuilder.GenerateBaseUrl = UrlBuilder[GenerateBaseUrl];
UrlBuilder.GenerateUrl = UrlBuilder[GenerateUrl];
UrlBuilder.GetDefaultQuery = UrlBuilder[GetDefaultQuery];

Logger.ErrorLog = Extension.ImportFunction("ErrorLog", "Logger.pqm");

SchemaUtils.TransformResponse = Extension.ImportFunction("TransformResponse", "SchemaUtils.pqm");
SchemaUtils.TransformTable = Extension.ImportFunction("TransformTable", "SchemaUtils.pqm");

Schema = Extension.ImportModule("Schema.pqm");

Schema.Sessions = Schema[Sessions];
Schema.GetSchema = Schema[GetSchema];
Schema.GetIdentifierColumn = Schema[GetIdentifierColumn];
Schema.GetSubTables = Schema[GetSubTables];

SubTable = Extension.ImportModule("SubTable.pqm");

NormalizeError = Extension.ImportFunction("NormalizeError", "SchemaErrors.pqm");

SubTable.Create = SubTable[Create];
SubTable.GetName = SubTable[GetName];
SubTable.GetData = SubTable[GetData];
SubTable.TransformData = SubTable[TransformData];

Normalize.Normalize = Extension.ImportFunction("Normalize", "Normalize.pqm");
