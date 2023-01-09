section TestBasicAuthentication;

BaseAuthentication = Extension.ImportModule("BaseAuthentication.pqm");

BaseAuthentication.EncodeCredentials = BaseAuthentication[EncodeCredentials];
BaseAuthentication.MineSessionIdFromCookie = BaseAuthentication[MineSessionIdFromCookie];

encodedCredentails = BaseAuthentication.EncodeCredentials("alma", "szilva");
simpleCookie = "session_id=47710719df1849b5b6aa2fd301e32a216cffe38b; expires=Thu, 01 Dec 2022 23:51:26 GMT; HttpOnly; Max-Age=43200; Path=/; Secure";
cookieWithNoSessionId = "malice=valid;date=Fri, 09 Dec 2022 09:57:08 +0100";
cookiWithManyFieldsAndSessionIdAtTheEnd = "ticket=X3AQ4DXMNQCBCEPQGRTO5MR2UYMCNPQTW5CKNEL4MJ3YEDEGTFID5T52WNHME2RH; expires=Thu, 01 Dec 2022 23:51:27 GMT; HttpOnly; Path=/; Secure,
        malice=valid;date=Fri, 09 Dec 2022 09:57:08 +0100,
        session_id=47710719df1849b5b6aa2fd301e32a216cffe38b; expires=Thu, 01 Dec 2022 23:51:26 GMT; HttpOnly; Max-Age=43200; Path=/; Secure";
cookiWithManyFieldsAndSessionIdInTheMiddle = "ticket=X3AQ4DXMNQCBCEPQGRTO5MR2UYMCNPQTW5CKNEL4MJ3YEDEGTFID5T52WNHME2RH; expires=Thu, 01 Dec 2022 23:51:27 GMT; HttpOnly; Path=/; Secure,
        session_id=47710719df1849b5b6aa2fd301e32a216cffe38b; expires=Thu, 01 Dec 2022 23:51:26 GMT; HttpOnly; Max-Age=43200; Path=/; Secure,
        malice=valid;date=Fri, 09 Dec 2022 09:57:08 +0100";
cookiWithManyFieldsAndSessionIdAtTheBegining = "session_id=47710719df1849b5b6aa2fd301e32a216cffe38b; expires=Thu, 01 Dec 2022 23:51:26 GMT; HttpOnly; Max-Age=43200; Path=/; Secure,
        ticket=X3AQ4DXMNQCBCEPQGRTO5MR2UYMCNPQTW5CKNEL4MJ3YEDEGTFID5T52WNHME2RH; expires=Thu, 01 Dec 2022 23:51:27 GMT; HttpOnly; Path=/; Secure,
        malice=valid;date=Fri, 09 Dec 2022 09:57:08 +0100";
cookiWithManyOnlyOneKeyValuePairFields = "ticket=X3AQ4DXMNQCBCEPQGRTO5MR2UYMCNPQTW5CKNEL4MJ3YEDEGTFID5T52WNHME2RH, session_id=47710719df1849b5b6aa2fd301e32a216cffe38b, malic=valid";
SessionIdCases = {
    {"session_id=47710719df1849b5b6aa2fd301e32a216cffe38b", BaseAuthentication.MineSessionIdFromCookie(simpleCookie)},
    {"", BaseAuthentication.MineSessionIdFromCookie(cookieWithNoSessionId)},
    {
        "session_id=47710719df1849b5b6aa2fd301e32a216cffe38b",
        BaseAuthentication.MineSessionIdFromCookie(cookiWithManyFieldsAndSessionIdAtTheEnd)
    },
    {
        "session_id=47710719df1849b5b6aa2fd301e32a216cffe38b",
        BaseAuthentication.MineSessionIdFromCookie(cookiWithManyFieldsAndSessionIdInTheMiddle)
    },
    {
        "session_id=47710719df1849b5b6aa2fd301e32a216cffe38b",
        BaseAuthentication.MineSessionIdFromCookie(cookiWithManyFieldsAndSessionIdAtTheBegining)
    },
    {
        "session_id=47710719df1849b5b6aa2fd301e32a216cffe38b",
        BaseAuthentication.MineSessionIdFromCookie(cookiWithManyOnlyOneKeyValuePairFields)
    }
};

shared TestBasicAuthentication.UnitTest = [
    facts = {
        Fact(
            "Check encoded credentails string value:",
            "YWxtYTpzemlsdmE=",
            BaseAuthentication.EncodeCredentials("alma", "szilva")
        ),
        Facts("Check extracted session_id string value from cookie:", SessionIdCases)
    },
    report = Facts.Summarize(facts)
][report];
