section TestUrlBuilder;

GenerateBaseUrl = SafeguardSessions.ImportFunction("GenerateBaseUrl", "UrlBuilder.pqm");
GenerateUrl = SafeguardSessions.ImportFunction("GenerateUrl", "UrlBuilder.pqm");
GetBaseUrlFromUrl = SafeguardSessions.ImportFunction("GetBaseUrlFromUrl", "UrlBuilder.pqm");
GetQueryFromUrl = SafeguardSessions.ImportFunction("GetQueryFromUrl", "UrlBuilder.pqm");

TestGenerateBaseUrl = () =>
    let
        cases = {
            {"Check base url with http scheme", "http://dummy", GenerateBaseUrl("http", "dummy")},
            {"Check base url with https scheme", "https://dummy", GenerateBaseUrl("https", "dummy")}
        },
        facts = ProvideDataForTest(cases, Fact)
    in
        facts;

TestGenerateUrl = () =>
    let
        cases = {
            {"Check base url append with path", "https://dummy/api/dummy", GenerateUrl("https://dummy", "api/dummy")},
            {"Check base url append with empty path", "https://dummy", GenerateUrl("https://dummy", "")},
            {"Check base url append with null path", "https://dummy", GenerateUrl("https://dummy", null)},
            {
                "Check base url append with path and empty query",
                "https://dummy/api/dummy",
                GenerateUrl("https://dummy", "api/dummy", [])
            },
            {
                "Check base url append with path and one query parameter",
                "https://dummy/api/dummy?valami=2",
                GenerateUrl("https://dummy", "api/dummy", [valami = "2"])
            },
            {
                "Check base url append with path and multiple query parameters",
                "https://dummy/api/dummy?valami=2&something=dummy",
                GenerateUrl("https://dummy", "api/dummy", [valami = "2", something = "dummy"])
            },
            {
                "Check base url append with path and query has null parameter",
                "https://dummy/api/dummy",
                GenerateUrl("https://dummy", "api/dummy", [valami = null])
            },
            {
                "Check base url append with path and query has multiple null and not null parameters",
                "https://dummy/api/dummy?something=dummy&peach=peach",
                GenerateUrl(
                    "https://dummy", "api/dummy", [valami = null, something = "dummy", apple = null, peach = "peach"]
                )
            },
            {
                "Check base url append with path and query has transformable parameters",
                "https://dummy/api/dummy?q=protocol%3ASSH%20AND%20user.name%3Abalabit&start=2022-12-12T00%3A00%3A00.0000000%2B00%3A00&end=2022-12-12T12%3A12%3A12.0000000%2B10%3A00",
                GenerateUrl(
                    "https://dummy",
                    "api/dummy",
                    [
                        qInput = {{"protocol", "SSH"}, {"user.name", "balabit"}},
                        from = #datetimezone(2022, 12, 12, 0, 0, 0, 0, 0),
                        to = #datetimezone(2022, 12, 12, 12, 12, 12, 10, 0)
                    ]
                )
            },
            {
                "Check base url append with path and query has qInput parameter where one filter value is missing",
                "https://dummy/api/dummy?q=user.name%3Abalabit",
                GenerateUrl("https://dummy", "api/dummy", [
                    qInput = {{null, "SSH"}, {"user.name", "balabit"}}
                ])
            },
            {
                "Check base url append with path and query has qInput parameter where one filter field is missing",
                [
                    HasError = true,
                    Error = [
                        Reason = "Filter Field Without Value",
                        Message = "Error 10000: There is a field value missing from one or more of your filter fields.",
                        Detail = [ManuallyHandled = false, Cause = "protocol", RequestUrl = null, ErrorCode=10000],
                        Message.Format = null,
                        Message.Parameters = null
                    ]
                ],
                try
                    (
                        GenerateUrl(
                            "https://dummy", "api/dummy", [
                                qInput = {{"protocol", null}, {"user.name", "balabit"}}
                            ]
                        )
                    )
            }
        },
        facts = ProvideDataForTest(cases, Fact)
    in
        facts;

TestGetBaseUrlFromUrl = () =>
    let
        cases = {
            {
                "Get baseUrl back from baseUrl with query",
                "https://dummy",
                GetBaseUrlFromUrl("https://dummy?valami=something")
            },
            {
                "Get baseUrl back from url with path",
                "https://dummy",
                GetBaseUrlFromUrl("https://dummy/api/something")
            },
            {
                "Get baseUrl back from url with path and query",
                "https://dummy",
                GetBaseUrlFromUrl("https://dummy/api/something?q=SSH")
            }
        },
        facts = ProvideDataForTest(cases, Fact)
    in
        facts;

TestGetQueryFromUrl = () =>
    let
        cases = {
            {
                "Get query form url with one query parameter",
                [
                    valami = "something"
                ],
                GetQueryFromUrl("https://dummy?valami=something")
            },
            {
                "Get query form url with multiple query parameters",
                [
                    valami = "something",
                    something = "valami"
                ],
                GetQueryFromUrl("https://dummy?valami=something&something=valami")
            },
            {"Get query form url with no query", [], GetQueryFromUrl("https://dummy/api")}
        },
        facts = ProvideDataForTest(cases, Fact)
    in
        facts;

shared TestUrlBuilder.UnitTest = [
    facts = {TestGenerateBaseUrl(), TestGenerateUrl(), TestGetBaseUrlFromUrl(), TestGetQueryFromUrl()},
    report = Summarize(facts)
][report];
