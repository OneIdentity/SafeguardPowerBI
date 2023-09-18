section TestCommonLogger;

Logger = Extension.ImportModule("CommonLogger.pqm");

Logger.InfoLog = Logger[InfoLog];

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

shared TestCommonLogger.UnitTest = [
    facts = {
        TestInfoLogWithNumberInput(),
        TestInfoLogWithTextInput(),
        TestInfoLogWithListInput(),
        TestInfoLogWithRecordInput(),
        TestInfoLogWithTableInput()
    },
    report = Facts.Summarize(facts)
][report];
