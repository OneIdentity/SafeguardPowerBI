section TestSafeguardPasswords.Authentication;

GetRstsResponse = Extension.ImportFunction("GetRstsResponse","Request.pqm");
GetLoginResponse = Extension.ImportFunction("GetLoginResponse","Request.pqm");
Constants = Extension.ImportModule("Constants.pqm")[SppConstants];

TestSafeguardPasswords.URL = "dummy_url";

TestSafeguardPasswords.AuthenticationCredentials = [
    Username = "dummy",
    Password = "pwd"
];

TestAuthenticateIsSuccessful = () =>
    let
        fakeRstsResponse = FakeRawResponse(
            [token = "FakeToken"]
        ),
        expectedRstsResponse = [token = "FakeToken"],

        fakeLoginResponse = FakeRawResponse(
            [UserToken = "FakeLoginToken"]
        ),
        expectedLoginResponse = "FakeLoginToken",

        rstsResponse = GetRstsResponse(TestSafeguardPasswords.URL, "local", 
            TestSafeguardPasswords.AuthenticationCredentials[Username], 
            TestSafeguardPasswords.AuthenticationCredentials[Password],
            [Response=fakeRstsResponse]),

        loginResponse = GetLoginResponse(TestSafeguardPasswords.URL, rstsResponse, [Response=fakeLoginResponse]),

        facts = {
            Fact("RSTS response data correct", expectedRstsResponse, rstsResponse),
            Fact("Login Token response data correct", expectedLoginResponse, loginResponse)
        }
    in
        facts;

TestAuthenticateRaisesError = () =>
    let
        expectedReason = "invalid_request",
        expectedMessage = "Access denied.",
        errorCode = 400,
        expectedResponse = [ 
                    HasError = true, 
                    Error = [ 
                                Reason = "Authentication Error", 
                                Message = "Error 4010: The username or password you have specified is invalid.", 
                                Detail = [ 
                                            Cause = [ 
                                                        fakeError = expectedReason, 
                                                        error_description = expectedMessage 
                                                    ],
                                            RequestUrl = "https://dummy_url", 
                                            RelativePath = "RSTS/oauth2/token", 
                                            ManuallyHandled = true, 
                                            ErrorCode = 4010 
                                        ], 
                                Message.Format = null, 
                                Message.Parameters = null 
                            ]
                ],
        fakeRstsResponse = FakeRawResponse([fakeError = expectedReason, error_description = expectedMessage], [Response.Status = 400]),

        rstsResponse = try GetRstsResponse(TestSafeguardPasswords.URL, "local", 
            TestSafeguardPasswords.AuthenticationCredentials[Username], 
            TestSafeguardPasswords.AuthenticationCredentials[Password],
            [Response=fakeRstsResponse]
        ),

        facts = {
            Fact("RSTS error response is correct", expectedResponse, rstsResponse)
        }
    in
        facts;

shared TestSafeguardSessions.IntegrationTest = [
    facts = {TestAuthenticateIsSuccessful(), TestAuthenticateRaisesError()},
    report = Facts.Summarize(facts)
][report];
