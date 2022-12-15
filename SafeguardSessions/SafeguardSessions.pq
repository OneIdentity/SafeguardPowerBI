// This file contains your Data Connector logic
[Version = "1.0.0"]
section SafeguardSessions;

[DataSource.Kind = "SafeguardSessions", Publish = "SafeguardSessions.Publish"]
shared SafeguardSessions.Contents = Value.ReplaceType(ContentsImpl, ContentsType);

ContentsType = type function (
    url as (
        type text meta [
            Documentation.FieldCaption = "SPS URL",
            Documentation.FieldDescription = "The SPS URL address identifies the appliance from which session data will be fetched.",
            Documentation.SampleValues = {"https://10.12.230.21"}
        ]
    )
) as table meta [
    Documentation.Name = "Safeguard for Privileged Sessions Connector",
    Documentation.LongDescription = "Enter required paramters to be able to fetch data from SPS."
];

ContentsImpl = (url as text) =>
    let
        url = Text.Combine({url, "/api"}),
        credentails = Extension.CurrentCredential(),
        encodedCredentails = BaseAuthentication.EncodeCredentials(credentails[Username], credentails[Password]),
        authResponse = Request.Generate(url, Request.GetAuthParameters(encodedCredentails)),
        cookie = Request.GetHeader(authResponse[RequestMetaData], "Set-Cookie"),
        sessionId = BaseAuthentication.GetSessionId(cookie),
        response = Request.Generate(url, Request.GetDefaultParameters("audit/sessions", sessionId))
    in
        response[Data];

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

BaseAuthentication = Extension.ImportModule("BaseAuthentication.pqm");

BaseAuthentication.EncodeCredentials = BaseAuthentication[EncodeCredentials];
BaseAuthentication.GetSessionId = BaseAuthentication[GetSessionId];

Request = Extension.ImportModule("Request.pqm");

Request.GetAuthParameters = Request[GetAuthParameters];
Request.GetDefaultParameters = Request[GetDefaultParameters];
Request.Generate = Request[Generate];
Request.GetHeader = Request[GetHeader];
