// This file contains your Data Connector logic
[Version = "1.0.0"]
section SafeguardSessions;

[DataSource.Kind = "SafeguardSessions", Publish = "SafeguardSessions.Publish"]
shared SafeguardSessions.Contents = Value.ReplaceType(ContentsImpl, ContentsType);

ContentsType = type function (
    url as (
        type text meta [
            Documentation.FieldCaption = "SPS IP",
            Documentation.FieldDescription = "The SPS IP address identifies the appliance from which session data will be fetched.",
            Documentation.SampleValues = {"10.12.230.21"}
        ]
    )
) as table meta [
    Documentation.Name = "Safeguard for Privileged Sessions Connector",
    Documentation.LongDescription = "Enter required paramters to be able to fetch data from SPS."
];

ContentsImpl = (sps_ip as text) =>
    let
        data = GetData(sps_ip, Extension.CurrentCredential())
    in
        data;

shared GetData = (sps_ip as text, credentials as record, optional mocks as record) =>
    let
        _start_time = DateTime.LocalNow(),
        base_url = Uri.Combine(Text.Combine({"https://", sps_ip}), "api/"),
        auth_url = Uri.Combine(base_url, "authentication"),
        fetch_url = Uri.Combine(base_url, "audit/sessions"),
        authResponse = (try Authenticate(auth_url, credentials, mocks)) meta [Url = auth_url],
        response =
            if authResponse[HasError] then
                authResponse
            else
                (
                    try
                        FetchData(
                            fetch_url,
                            BaseAuthentication.MineSessionIdFromCookie(
                                Request.GetHeader(Value.Metadata(authResponse[Value]), "Set-Cookie")
                            ),
                            mocks
                        )
                ) meta [Url = fetch_url],
        result =
            if response[HasError] then
                ErrorLog(
                    "Error response of the http request",
                    SPSResult(
                        response[Error],
                        FetchInfo(
                            ErrorStatus, response[Error][Message], _start_time, 0, true, Value.Metadata(
                                response
                            )[Url]
                        )
                    )
                )
            else
                SPSResult(
                    response[Value],
                    FetchInfo(
                        SuccessStatus,
                        "Data fetch succeeded",
                        _start_time,
                        Table.RowCount(response[Value]),
                        false,
                        Value.Metadata(response)[Url]
                    )
                )
    in
        result;

shared Authenticate = (url as text, credentials as record, optional mocks as nullable record) as table =>
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

shared FetchData = (url as text, session_id as text, optional mocks as nullable record) as table =>
    let
        response =
            if IsMocked(mocks, "FetchResponse") then
                Request.Generate(url, Request.GetDefaultParameters(session_id), [Response = mocks[FetchResponse]])
            else
                Request.Generate(url, Request.GetDefaultParameters(session_id))
    in
        RaiseErrorOrReturn(response);

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

Utils = Extension.ImportModule("Utils.pqm");

IsMocked = Utils[IsMocked];
FetchInfo = Utils[FetchInfo];
SPSResult = Utils[SPSResult];
SuccessStatus = Utils[SuccessStatus];
ErrorStatus = Utils[ErrorStatus];
ErrorLog = Utils[ErrorLog];

BaseAuthentication = Extension.ImportModule("BaseAuthentication.pqm");

BaseAuthentication.EncodeCredentials = BaseAuthentication[EncodeCredentials];
BaseAuthentication.MineSessionIdFromCookie = BaseAuthentication[MineSessionIdFromCookie];

RaiseErrorOrReturn = Extension.ImportFunction("RaiseErrorOrReturn", "CustomErrors.pqm");

Request = Extension.ImportModule("Request.pqm");

Request.GetAuthParameters = Request[GetAuthParameters];
Request.GetDefaultParameters = Request[GetDefaultParameters];
Request.Generate = Request[Generate];
Request.GetHeader = Request[GetHeader];
