section TestUtils;

Logger = Extension.ImportModule("Logger.pqm");
Utils = Extension.ImportModule("Utils.pqm");

Logger.InfoLog = Logger[InfoLog];
Logger.ErrorLog = Logger[ErrorLog];

Utils.SPSResult = Utils[SPSResult];
Utils.FetchInfo = Utils[FetchInfo];

TestInfoLogWithNumberInput = () =>
    let
        input = [Prefix = "iphone", Value = 12, Delayed = null, IsTesting = true],
        expectedLogValues = [LogLevel = TraceLevel.Information, Output = "iphone: 12", Value = 12, Delayed = null],
        logValues = Logger.InfoLog(input[Prefix], input[Value], input[Delayed], input[IsTesting]),
        facts = TestLogging(logValues, expectedLogValues, "number")
    in
        facts;

TestInfoLogWithTextInput = () =>
    let
        input = [Prefix = "iphone", Value = "pro", Delayed = null, IsTesting = true],
        expectedLogValues = [
            LogLevel = TraceLevel.Information,
            Output = "iphone: ""pro""",
            Value = "pro",
            Delayed = null
        ],
        logValues = Logger.InfoLog(input[Prefix], input[Value], input[Delayed], input[IsTesting]),
        facts = TestLogging(logValues, expectedLogValues, "text")
    in
        facts;

TestInfoLogWithListInput = () =>
    let
        input = [Prefix = "iphone", Value = {11, 12, 13}, Delayed = null, IsTesting = true],
        expectedLogValues = [
            LogLevel = TraceLevel.Information,
            Output = "iphone: {11, 12, 13} ",
            Value = {11, 12, 13},
            Delayed = null
        ],
        logValues = Logger.InfoLog(input[Prefix], input[Value], input[Delayed], input[IsTesting]),
        facts = TestLogging(logValues, expectedLogValues, "list")
    in
        facts;

TestInfoLogWithRecordInput = () =>
    let
        input = [
            Prefix = "say",
            Value = [One = "Apple tree", Two = "Ladybug", Three = "Little ducks"],
            Delayed = null,
            IsTesting = true
        ],
        expectedLogValues = [
            LogLevel = TraceLevel.Information,
            Output = "say: [ One = ""Apple tree"", Two = ""Ladybug"", Three = ""Little ducks"" ] ",
            Value = [One = "Apple tree", Two = "Ladybug", Three = "Little ducks"],
            Delayed = null
        ],
        logValues = Logger.InfoLog(input[Prefix], input[Value], input[Delayed], input[IsTesting]),
        facts = TestLogging(logValues, expectedLogValues, "record")
    in
        facts;

TestInfoLogWithTableInput = () =>
    let
        input = [
            Prefix = "say",
            Value = #table(
                type table [#"Number" = number, #"Value" = text],
                {{1, "Apple Tree"}, {2, "Ladybug"}, {3, "Little ducks"}}
            ),
            Delayed = null,
            IsTesting = true
        ],
        expectedLogValues = [
            LogLevel = TraceLevel.Information,
            Output = "say: #table( type table [Number = number, Value = text] , {{1, ""Apple Tree""} , {2, ""Ladybug""} , {3, ""Little ducks""} } ) ",
            Value = #table({"Number", "Value"}, {{1, "Apple Tree"}, {2, "Ladybug"}, {3, "Little ducks"}}),
            Delayed = null
        ],
        logValues = Logger.InfoLog(input[Prefix], input[Value], input[Delayed], input[IsTesting]),
        facts = TestLogging(logValues, expectedLogValues, "table")
    in
        facts;

TestErrorLogWithSPSResultInput = () =>
    let
        input = [
            Prefix = "error",
            Value = Utils.SPSResult(
                "error",
                Utils.FetchInfo("status", "message", #datetimezone(2023, 1, 18, 9, 47, 55, 2, 0), 42, true, "query")
            ),
            Delayed = null,
            IsTesting = true
        ],
        expectedLogValues = [
            LogLevel = TraceLevel.Error,
            Output = "error: #table( type table [Name = any, Data = any, ItemKind = any, ItemName = any, IsLeaf = any] , {{""Sessions"", ""error"", ""Table"", ""Table"", true} , {""Info"", #table( type table [Start = any, Url = any, Status = any, ExpectedCount = any, Message = any, Failed = any] , {{#datetimezone(2023, 1, 18, 9, 47, 55, 2, 0), ""query"", ""status"", 42, ""message"", true} } ) , ""Table"", ""Table"", true} } ) ",
            Value = #table(
                type table [Name = any, Data = any, ItemKind = any, ItemName = any, IsLeaf = any],
                {
                    {"Sessions", "error", "Table", "Table", true},
                    {
                        "Info",
                        #table(
                            type table [
                                Start = any, Url = any, Status = any, ExpectedCount = any, Message = any, Failed = any
                            ],
                            {{#datetimezone(2023, 1, 18, 9, 47, 55, 2, 0), "query", "status", 42, "message", true}}
                        ),
                        "Table",
                        "Table",
                        true
                    }
                }
            ),
            Delayed = null
        ],
        logValues = Logger.ErrorLog(input[Prefix], input[Value], input[Delayed], input[IsTesting]),
        facts = TestLogging(logValues, expectedLogValues, "SPSResult")
    in
        facts;

shared TestUtils.UnitTest = [
    facts = {
        TestInfoLogWithNumberInput(),
        TestInfoLogWithTextInput(),
        TestInfoLogWithListInput(),
        TestInfoLogWithRecordInput(),
        TestInfoLogWithTableInput(),
        TestErrorLogWithSPSResultInput()
    },
    report = Facts.Summarize(facts)
][report];
