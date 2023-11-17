section TestCommonLogger;

Logger = Extension.ImportModule("CommonLogger.pqm");

Logger.InfoLog = Logger[InfoLog];

TestLogging = () =>
    let
        AssertLogging = (description, input, expectedLogValues) =>
            let
                isTesting = true
            in
                AssertLogContent(
                    description,
                    Logger.InfoLog(input[Prefix], input[Value], input[Delayed], isTesting),
                    expectedLogValues
                ),
        cases = {
            {
                "Input value is number",
                [
                    Prefix = "iphone",
                    Value = 12,
                    Delayed = null
                ],
                [
                    LogLevel = TraceLevel.Information,
                    Output = "iphone: 12",
                    Value = 12,
                    Delayed = null
                ]
            },
            {
                "Input value is text",
                [
                    Prefix = "iphone",
                    Value = "pro",
                    Delayed = null
                ],
                [
                    LogLevel = TraceLevel.Information,
                    Output = "iphone: ""pro""",
                    Value = "pro",
                    Delayed = null
                ]
            },
            {
                "Input value is a list",
                [
                    Prefix = "iphone",
                    Value = {11, 12, 13},
                    Delayed = null
                ],
                [
                    LogLevel = TraceLevel.Information,
                    Output = "iphone: {11, 12, 13} ",
                    Value = {11, 12, 13},
                    Delayed = null
                ]
            },
            {
                "Input value is a record",
                [
                    Prefix = "say",
                    Value = [One = "Apple tree", Two = "Ladybug", Three = "Little ducks"],
                    Delayed = null
                ],
                [
                    LogLevel = TraceLevel.Information,
                    Output = "say: [ One = ""Apple tree"", Two = ""Ladybug"", Three = ""Little ducks"" ] ",
                    Value = [One = "Apple tree", Two = "Ladybug", Three = "Little ducks"],
                    Delayed = null
                ]
            },
            {
                "Input value is a table",
                [
                    Prefix = "say",
                    Value = #table(
                        type table [#"Number" = number, #"Value" = text],
                        {{1, "Apple Tree"}, {2, "Ladybug"}, {3, "Little ducks"}}
                    ),
                    Delayed = null
                ],
                [
                    LogLevel = TraceLevel.Information,
                    Output = "say: #table( type table [Number = number, Value = text] , {{1, ""Apple Tree""} , {2, ""Ladybug""} , {3, ""Little ducks""} } ) ",
                    Value = #table({"Number", "Value"}, {{1, "Apple Tree"}, {2, "Ladybug"}, {3, "Little ducks"}}),
                    Delayed = null
                ]
            }
        },
        facts = ProvideDataForTest(cases, AssertLogging)
    in
        facts;

shared TestCommonLogger.UnitTest = [
    facts = {TestLogging()},
    report = Summarize(facts)
][report];
