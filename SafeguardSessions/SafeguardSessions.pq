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
        response = Request.Generate(url, Request.GetDefaultParameters("info", sessionId))
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
Extension.LoadFunction = (name as text) =>
    let
        binary = Extension.Contents(name), asText = Text.FromBinary(binary)
    in
        Expression.Evaluate(asText, #shared);

BaseAuthentication = Extension.LoadFunction("BaseAuthentication.pqm");

shared BaseAuthentication.EncodeCredentials = BaseAuthentication[EncodeCredentials];
shared BaseAuthentication.GetSessionId = BaseAuthentication[GetSessionId];

Request = Extension.LoadFunction("Request.pqm");

shared Request.GetAuthParameters = Request[GetAuthParameters];
shared Request.GetDefaultParameters = Request[GetDefaultParameters];
shared Request.Generate = Request[Generate];
shared Request.GetHeader = Request[GetHeader];
