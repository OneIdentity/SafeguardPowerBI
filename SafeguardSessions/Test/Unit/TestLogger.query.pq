section TestUtils;

Logger = Extension.ImportModule("CommonLogger.pqm");
Utils = Extension.ImportModule("Utils.pqm");

Logger.ErrorLog = Logger[ErrorLog];

Utils.SPSResult = Utils[SPSResult];
Utils.FetchInfo = Utils[FetchInfo];

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
            Output = "error: #table( type table [Name = any, Data = any, ItemKind = any, ItemName = any, IsLeaf = any] , {{""Sessions"", ""error"", ""Table"", ""Table"", true} , {""Info"", #table( type table [Start = any, Url = any, ConnectorVersion = any, Status = any, ExpectedCount = any, Message = any, Failed = any] , {{#datetimezone(2023, 1, 18, 9, 47, 55, 2, 0), ""query"", ""v1.1.1pre2+sps7.4.0"", ""status"", 42, ""message"", true} } ) , ""Table"", ""Table"", true} } ) ",
            Value = #table(
                type table [Name = any, Data = any, ItemKind = any, ItemName = any, IsLeaf = any],
                {
                    {"Sessions", "error", "Table", "Table", true},
                    {
                        "Info",
                        #table(
                            type table [
                                Start = any,
                                Url = any,
                                ConnectorVersion = any,
                                Status = any,
                                ExpectedCount = any,
                                Message = any,
                                Failed = any
                            ],
                            {
                                {
                                    #datetimezone(2023, 1, 18, 9, 47, 55, 2, 0),
                                    "query",
                                    "v1.1.1pre2+sps7.4.0",
                                    "status",
                                    42,
                                    "message",
                                    true
                                }
                            }
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
    facts = {TestErrorLogWithSPSResultInput()},
    report = Facts.Summarize(facts)
][report];
