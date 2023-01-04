section TestSafeguardSessions;

TestGetData = () =>
    let
        fake_auth_response = FakeResponse(
            "{}",
            [
                Response.Status = 200,
                Headers = [
                    #"Set-Cookie" = "session_id=e8e5f0a0d3367043150187f81df3484e91e365d5; expires=Sat, 03 Dec 2022 02:27:48 GMT; HttpOnly; Max-Age=43200; Path=/; Secure"
                ]
            ]
        ),
        fake_response = FakeResponse("{""dummy_field"": ""value"", ""dummy_list"": [0, 1, 2]}"),
        expected_body = #table(type table [dummy_field = any, dummy_list = any], {{"value", {0, 1, 2}}}),
        expected_meta = [Content.Type = "application/json", Response.Status = 200],
        response = GetData(
            "dummy_url",
            [
                Username = "dummy",
                Password = "pwd"
            ],
            [
                AuthResponse = fake_auth_response,
                FetchResponse = fake_response
            ]
        ),
        facts = {
            Fact("Reponse data is correct", expected_body, response),
            Fact("Reponse meta is correct", expected_meta, Value.Metadata(response))
        }
    in
        facts;

TestAuthenticate = () =>
    let
        fake_auth_response = FakeResponse(
            "{}",
            [
                Response.Status = 200,
                Headers = [
                    #"Set-Cookie" = "session_id=e8e5f0a0d3367043150187f81df3484e91e365d5; expires=Sat, 03 Dec 2022 02:27:48 GMT; HttpOnly; Max-Age=43200; Path=/; Secure"
                ]
            ]
        ),
        response = Authenticate(
            "dummy_url", [
                Username = "dummy",
                Password = "pwd"
            ], [
                AuthResponse = fake_auth_response
            ]
        ),
        facts = {
            Fact("Authentication response data correct", #table(type table, {{}}), response),
            Fact(
                "Authentication response meta is correct",
                [
                    Response.Status = 200,
                    Headers = [
                        #"Set-Cookie" = "session_id=e8e5f0a0d3367043150187f81df3484e91e365d5; expires=Sat, 03 Dec 2022 02:27:48 GMT; HttpOnly; Max-Age=43200; Path=/; Secure"
                    ]
                ],
                Value.Metadata(response)
            )
        }
    in
        facts;

TestFetchData = () =>
    let
        fake_response = FakeResponse("{""dummy_field"": ""value"", ""dummy_list"": [0, 1, 2]}", []),
        response = FetchData("dummy_url", "e8e5f0a0d3367043150187f81df3484e91e365d5", [
            FetchResponse = fake_response
        ]),
        facts = {
            Fact(
                "Data fetch response is correct",
                #table(type table [dummy_field = any, dummy_list = any], {{"value", {0, 1, 2}}}),
                response
            ),
            Fact("Test data fetch meta is correct", [], Value.Metadata(response))
        }
    in
        facts;

shared TestSafeguardSessions.UnitTest = [
    facts = {TestGetData(), TestAuthenticate(), TestFetchData()},
    report = Facts.Summarize(facts)
][report];
