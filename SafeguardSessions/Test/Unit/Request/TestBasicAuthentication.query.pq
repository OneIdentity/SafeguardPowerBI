section TestBasicAuthentication;

BaseAuthentication = Extension.ImportModule("BaseAuthentication.pqm");

BaseAuthentication.EncodeCredentials = BaseAuthentication[EncodeCredentials];
BaseAuthentication.MineSessionIdFromCookie = BaseAuthentication[MineSessionIdFromCookie];

encodedCredentails = BaseAuthentication.EncodeCredentials("alma", "szilva");

TestSessionIdExtraction = () =>
    let
        AssertSessionId = (description as text, cookie as text, expectedId) =>
            Fact(
                Text.Format("Extracted session id is correct for #[Case]", [Case = description]),
                expectedId,
                BaseAuthentication.MineSessionIdFromCookie(cookie)
            ),
        expectedSessionId = "session_id=47710719df1849b5b6aa2fd301e32a216cffe38b",
        cases = {
            {
                "Simple cookie",
                "session_id=47710719df1849b5b6aa2fd301e32a216cffe38b; expires=Thu, 01 Dec 2022 23:51:26 GMT; HttpOnly; Max-Age=43200; Path=/; Secure",
                expectedSessionId
            },
            {"Cookie with no session id", "malice=valid;date=Fri, 09 Dec 2022 09:57:08 +0100", ""},
            {
                "Cookie with many fields and session id at the end",
                "ticket=X3AQ4DXMNQCBCEPQGRTO5MR2UYMCNPQTW5CKNEL4MJ3YEDEGTFID5T52WNHME2RH; expires=Thu, 01 Dec 2022 23:51:27 GMT; HttpOnly; Path=/; Secure,
                malice=valid;date=Fri, 09 Dec 2022 09:57:08 +0100,
                session_id=47710719df1849b5b6aa2fd301e32a216cffe38b; expires=Thu, 01 Dec 2022 23:51:26 GMT; HttpOnly; Max-Age=43200; Path=/; Secure",
                expectedSessionId
            },
            {
                "Cookie with many fields and session id in the middle",
                "ticket=X3AQ4DXMNQCBCEPQGRTO5MR2UYMCNPQTW5CKNEL4MJ3YEDEGTFID5T52WNHME2RH; expires=Thu, 01 Dec 2022 23:51:27 GMT; HttpOnly; Path=/; Secure,
                session_id=47710719df1849b5b6aa2fd301e32a216cffe38b; expires=Thu, 01 Dec 2022 23:51:26 GMT; HttpOnly; Max-Age=43200; Path=/; Secure,
                malice=valid;date=Fri, 09 Dec 2022 09:57:08 +0100",
                expectedSessionId
            },
            {
                "Cookie with many fields and session id at the beginning",
                "session_id=47710719df1849b5b6aa2fd301e32a216cffe38b; expires=Thu, 01 Dec 2022 23:51:26 GMT; HttpOnly; Max-Age=43200; Path=/; Secure,
                ticket=X3AQ4DXMNQCBCEPQGRTO5MR2UYMCNPQTW5CKNEL4MJ3YEDEGTFID5T52WNHME2RH; expires=Thu, 01 Dec 2022 23:51:27 GMT; HttpOnly; Path=/; Secure,
                malice=valid;date=Fri, 09 Dec 2022 09:57:08 +0100",
                expectedSessionId
            },
            {
                "Cookie with many simple value fields",
                "ticket=X3AQ4DXMNQCBCEPQGRTO5MR2UYMCNPQTW5CKNEL4MJ3YEDEGTFID5T52WNHME2RH, session_id=47710719df1849b5b6aa2fd301e32a216cffe38b, malic=valid",
                expectedSessionId
            }
        },
        facts = ProvideDataForTest(cases, AssertSessionId)
    in
        facts;

shared TestBasicAuthentication.UnitTest = [
    facts = {
        Fact(
            "Check encoded credentails string value:",
            "YWxtYTpzemlsdmE=",
            BaseAuthentication.EncodeCredentials("alma", "szilva")
        ),
        TestSessionIdExtraction()
    },
    report = Summarize(facts)
][report];
