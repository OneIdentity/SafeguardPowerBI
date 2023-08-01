section TestSafeguardSessions.HandleIfThereIsAnError;

AssertVersionCheck = (description as text, input as record, expectedValue as record) =>
    let
        handled = try HandleIfThereIsAnError(input),
        actualValue = if handled[HasError] = true then handled[Error] else handled[Value]
    in
        Fact(description, expectedValue, actualValue);

TestHandleIfThereIsAnError = () =>
    let
        cases = {
            {"Input is not an error", try ("Dummy"), [HasError = false, Value = "Dummy"]},
            {
                "Input is an unexpected error",
                try
                    (
                        error
                            [
                                Reason = "Wrong variable",
                                Message = "Variable type mismatch error",
                                Detail = "The variable badVariable is of the type text, but it should be of the type number"
                            ]
                    ),
                [
                    Reason = "Wrong variable",
                    Message = "Error 99999: Variable type mismatch error",
                    Detail = [
                        originalDetails = "The variable badVariable is of the type text, but it should be of the type number",
                        ManuallyHandled = false,
                        ErrorCode = 99999
                    ],
                    Message.Format = null,
                    Message.Parameters = null
                ]
            },
            {
                "Input is a manually not handled error error",
                try
                    (
                        error
                            [
                                Reason = "Filter Field Without Value",
                                Message = "Error: 10000: There is a field value missing from one or more of your filter fields.",
                                Detail = [Url = "dummy.url", ManuallyHandled = false, ErrorCode = 10000]
                            ]
                    ),
                [
                    Reason = "Filter Field Without Value",
                    Message = "Error: 10000: There is a field value missing from one or more of your filter fields.",
                    Detail = [Url = "dummy.url", ManuallyHandled = false, ErrorCode = 10000],
                    Message.Format = null,
                    Message.Parameters = null
                ]
            },
            {
                "Input is a manually handled error",
                try
                    (
                        error
                            [
                                Reason = "Bad Request",
                                Message = "Error 4000: The source IP interpreted a malformed request. Your filter parameter(s) might be invalid.",
                                Detail = [Url = "dummy.url", ManuallyHandled = true, ErrorCode = 4000]
                            ]
                    ),
                [
                    HasError = true,
                    Error = [
                        Reason = "Bad Request",
                        Message = "Error 4000: The source IP interpreted a malformed request. Your filter parameter(s) might be invalid.",
                        Detail = [Url = "dummy.url", ManuallyHandled = true, ErrorCode = 4000],
                        Message.Format = null,
                        Message.Parameters = null
                    ]
                ]
            }
        },
        facts = ProvideDataForTest(cases, AssertVersionCheck)
    in
        facts;

shared TestRequestErrors.UnitTest = [
    facts = {TestHandleIfThereIsAnError()},
    report = Facts.Summarize(facts)
][report];
