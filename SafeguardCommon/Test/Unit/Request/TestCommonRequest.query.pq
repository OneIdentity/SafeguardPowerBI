section TestCommonRequest;

Request = SafeguardCommon.ImportModule("CommonRequest.pqm");

Request.GetHeader = Request[GetHeader];

requestMetaData = [
    Headers = [
        #"Set-Cookie" = "session_id=e8e5f0a0d3367043150187f81df3484e91e365d5; expires=Sat, 03 Dec 2022 02:27:48 GMT; HttpOnly; Max-Age=43200; Path=/; Secure"
    ]
];

TestGetHeader = () =>
    let
        AssertField = (fieldName as text, metaData as record, expectedValue as any) =>
            Fact(
                Text.Format("Check request get header value for field #[FieldName]", [FieldName = fieldName]),
                expectedValue,
                Request.GetHeader(metaData, fieldName)
            ),
        cases = {
            {
                "Set-Cookie",
                requestMetaData,
                "session_id=e8e5f0a0d3367043150187f81df3484e91e365d5; expires=Sat, 03 Dec 2022 02:27:48 GMT; HttpOnly; Max-Age=43200; Path=/; Secure"
            }
        },
        facts = ProvideDataForTest(cases, AssertField)
    in
        facts;

shared TestCommonRequest.UnitTest = [
    facts = {TestGetHeader()},
    report = Summarize(facts)
][report];
