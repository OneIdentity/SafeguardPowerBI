section TestRequest;

requestMetaData = [
    Content.Type = "application/json",
    Content.Uri = "[Function]",
    Content.Name = " 10.12.230.132",
    Headers = [
        Connection = "keep-alive",
        #"Content-Language" = "en",
        Allow = "GET",
        #"X-Frame-Options" = "SAMEORIGIN,SAMEORIGIN",
        #"Content-Security-Policy" = "frame-ancestors 'self',object-src 'none'; img-src 'self' data:; font-src 'self' data:",
        #"Cross-Origin-Resource-Policy" = "same-origin",
        Pragma = "no-cache",
        #"Content-Disposition" = "attachment; filename=response",
        #"X-Content-Type-Options" = "nosniff",
        #"Referrer-Policy" = "same-origin",
        #"X-XSS-Protection" = "1; mode=block",
        #"Strict-Transport-Security" = "max-age=31536000; includeSubDomains",
        #"Content-Length" = "915",
        #"Cache-Control" = "no-cache, no-store",
        #"Content-Type" = "application/json",
        Date = "Fri, 02 Dec 2022 14:27:48 GMT",
        Expires = "0",
        #"Set-Cookie" = "session_id=e8e5f0a0d3367043150187f81df3484e91e365d5; expires=Sat, 03 Dec 2022 02:27:48 GMT; HttpOnly; Max-Age=43200; Path=/; Secure",
        Server = "REST"
    ],
    Request.Options = [
        RelativePath = "info",
        Headers = [
            Accept = "application/json",
            Connection = "keep-alive",
            Cookie = "session_id=e4d836546263b4983d9c9537dfb2fe8119ab89f1"
        ],
        IsRetry = true
    ],
    Response.Status = 200
];

TestRequestGeneration = () =>
    let
        fakeresponse = FakeResponse("{""dummy_field"": ""value"", ""dummy_list"": [0, 1, 2]}"),
        expected_body = #table(type table [dummy_field = any, dummy_list = any], {{"value", {0, 1, 2}}}),
        expected_meta = [Content.Type = "application/json", Response.Status = 200],
        response = Request.Generate("dummy_url", [], [Response = fakeresponse]),
        facts = {
            Fact("Response body as table is correct", expected_body, response[Data]),
            Fact("Response meta is correct", expected_meta, response[RequestMetaData])
        }
    in
        facts;

shared TestRequest.UnitTest = [
    facts = {
        Fact(
            "Check authentication request parameters:",
            [
                RelativePath = "authentication",
                Query = [return = "/api/authentication"],
                Headers = [
                    #"Authorization" = "Basic YWxtYTpzemlsdmE=",
                    #"Accept" = "*/*",
                    #"Connection" = "keep-alive",
                    #"Cache-Control" = "no-cache, no-store, must-revalidate"
                ]
            ],
            Request.GetAuthParameters("YWxtYTpzemlsdmE=")
        ),
        Fact(
            "Check default request parameters:",
            [
                RelativePath = "info",
                Headers = [
                    #"Accept" = "application/json",
                    #"Connection" = "keep-alive",
                    #"Cookie" = "session_id=47710719df1849b5b6aa2fd301e32a216cffe38b"
                ],
                IsRetry = true
            ],
            Request.GetDefaultParameters("info", "session_id=47710719df1849b5b6aa2fd301e32a216cffe38b")
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
