section TestRequest;

Request = SafeguardPasswords.ImportModule("Request.pqm");
Request.GetAuthParameters = Request[GetAuthParameters];
Request.GetDefaultParameters = Request[GetDefaultParameters];
Request.GetSppResponse = Request[GetSppResponse];
Request.ConvertQueryToRecord = Request[ConvertQueryToRecord];

TestRequestGeneration = () =>
    let

        fakeresponse = FakeRawResponse([dummy_field = "value", dummy_list = {0, 1, 2}]),
        expected_body = [dummy_field = "value", dummy_list = {0, 1, 2}],
        expected_meta = [
                            Content.Type = "application/json", 
                            Response.Status = 200, 
                            RequestUrl = "https://dummy_url", 
                            RelativePath = "service/core/v4/fakePath",
                            Query = [filter="fake ieq 'foo'", fields="fake,foo"]
                        ],
        response = Request.GetSppResponse("dummy_url", "fakeLoginToken", "service/core/v4/fakePath", null, "filter=fake ieq 'foo'&fields=fake,foo", [Response=fakeresponse]),

        facts = {
            Fact("Response body as json is correct", expected_body, response),
            Fact("Response meta is correct", expected_meta, Value.Metadata(response))
        }
    in
        facts;
    
TestQueryParsing = () =>
    let
        query = "filter=fake ieq 'foo'&fields=fake,foo",
        expected = [filter="fake ieq 'foo'", fields="fake,foo"],
        response = Request.ConvertQueryToRecord(query),

        facts = {
            Fact("Query parsed correctly", expected, response)
        }
    in
        facts;

shared TestRequest.UnitTest = [
    facts = {
        TestRequestGeneration(),
        TestQueryParsing()
    },
    report = Summarize(facts)
][report];
