section TestRequest;

Request = Extension.ImportModule("Request.pqm");

Request.GetAuthParameters = Request[GetAuthParameters];
Request.GetDefaultParameters = Request[GetDefaultParameters];
Request.Generate = Request[Generate];
Request.GetHeader = Request[GetHeader];

requestMetaData = [
    Headers = [
        #"Set-Cookie" = "session_id=e8e5f0a0d3367043150187f81df3484e91e365d5; expires=Sat, 03 Dec 2022 02:27:48 GMT; HttpOnly; Max-Age=43200; Path=/; Secure"
    ]
];

TestRequestGeneration = () =>
    let
        fakeresponse = FakeResponse("{""dummy_field"": ""value"", ""dummy_list"": [0, 1, 2]}"),
        expected_body = #table(type table [dummy_field = any, dummy_list = any], {{"value", {0, 1, 2}}}),
        expected_meta = [Content.Type = "application/json", Response.Status = 200],
        response = Request.Generate("dummy_url", [], [Response = fakeresponse]),
        facts = {
            Fact("Response body as table is correct", expected_body, response),
            Fact("Response meta is correct", expected_meta, Value.Metadata(response))
        }
    in
        facts;

shared TestRequest.UnitTest = [
    facts = {
        Fact(
            "Check authentication request parameters:",
            [
                Query = [return = "/api/authentication"],
                Headers = [
                    #"Authorization" = "Basic YWxtYTpzemlsdmE=",
                    #"Accept" = "*/*",
                    #"Connection" = "keep-alive",
                    #"Cache-Control" = "no-cache, no-store, must-revalidate"
                ],
                IsRetry = true
            ],
            Request.GetAuthParameters("YWxtYTpzemlsdmE=")
        ),
        Fact(
            "Check default request parameters:",
            [
                Headers = [
                    #"Accept" = "application/json",
                    #"Connection" = "keep-alive",
                    #"Cookie" = "session_id=47710719df1849b5b6aa2fd301e32a216cffe38b"
                ],
                IsRetry = true
            ],
            Request.GetDefaultParameters("session_id=47710719df1849b5b6aa2fd301e32a216cffe38b")
        ),
        Fact(
            "Check request get header value:",
            "session_id=e8e5f0a0d3367043150187f81df3484e91e365d5; expires=Sat, 03 Dec 2022 02:27:48 GMT; HttpOnly; Max-Age=43200; Path=/; Secure",
            Request.GetHeader(requestMetaData, "Set-Cookie")
        ),
        TestRequestGeneration()
    },
    report = Facts.Summarize(facts)
][report];
