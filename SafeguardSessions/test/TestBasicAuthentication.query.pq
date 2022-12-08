section TestBasicAuthentication;

shared TestBasicAuthentication.UnitTest = [
    encodedCredentails = BaseAuthentication.EncodeCredentials("alma", "szilva"),
    cookie = "session_id=47710719df1849b5b6aa2fd301e32a216cffe38b; expires=Thu, 01 Dec 2022 23:51:26 GMT; HttpOnly; Max-Age=43200; Path=/; Secure,
        ticket=X3AQ4DXMNQCBCEPQGRTO5MR2UYMCNPQTW5CKNEL4MJ3YEDEGTFID5T52WNHME2RH; expires=Thu, 01 Dec 2022 23:51:27 GMT; HttpOnly; Path=/; Secure",
    reveresedCookie = "ticket=X3AQ4DXMNQCBCEPQGRTO5MR2UYMCNPQTW5CKNEL4MJ3YEDEGTFID5T52WNHME2RH; expires=Thu, 01 Dec 2022 23:51:27 GMT; HttpOnly; Path=/; Secure,
        session_id=47710719df1849b5b6aa2fd301e32a216cffe38b; expires=Thu, 01 Dec 2022 23:51:26 GMT; HttpOnly; Max-Age=43200; Path=/; Secure",
    facts = {
        Fact(
            "Check encoded credentails string value:",
            "YWxtYTpzemlsdmE=",
            BaseAuthentication.EncodeCredentials("alma", "szilva")
        ),
        Fact(
            "Check extracted session_id string value from cookie where session_id is the first parameter:",
            "session_id=47710719df1849b5b6aa2fd301e32a216cffe38b",
            BaseAuthentication.GetSessionId(cookie)
        ),
        Fact(
            "Check extracted session_id string value from cookie where session_id is the second parameter:",
            "session_id=47710719df1849b5b6aa2fd301e32a216cffe38b",
            BaseAuthentication.GetSessionId(reveresedCookie)
        )
    },
    report = Facts.Summarize(facts)
][report];
