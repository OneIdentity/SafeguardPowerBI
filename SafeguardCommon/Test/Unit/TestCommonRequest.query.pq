section TestCommonRequest;

Request = Extension.ImportModule("CommonRequest.pqm");

Request.GetHeader = Request[GetHeader];

requestMetaData = [
    Headers = [
        #"Set-Cookie" = "session_id=e8e5f0a0d3367043150187f81df3484e91e365d5; expires=Sat, 03 Dec 2022 02:27:48 GMT; HttpOnly; Max-Age=43200; Path=/; Secure"
    ]
];

shared TestCommonRequest.UnitTest = [
    facts = {
        Fact(
            "Check request get header value:",
            "session_id=e8e5f0a0d3367043150187f81df3484e91e365d5; expires=Sat, 03 Dec 2022 02:27:48 GMT; HttpOnly; Max-Age=43200; Path=/; Secure",
            Request.GetHeader(requestMetaData, "Set-Cookie")
        )
    },
    report = Facts.Summarize(facts)
][report];
