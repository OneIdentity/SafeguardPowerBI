// Microsoft's Fact framework was used as the core of the Unit Test Framework.
// References: https://github.com/microsoft/DataConnectors/blob/master/samples/UnitTesting/UnitTesting.query.pq,
// https://learn.microsoft.com/en-us/power-query/handlingunittesting
// Version 1.0.0 was exactly the same as Microsoft's framework. Above this version number,
// it includes our changes and additions
[Version = "2.0.0"]
section UnitTestFramework;

// Utilities for loading external functions
shared UnitTestFramework.ImportModule = (name as text) =>
    let
        binary = Extension.Contents(name), asText = Text.FromBinary(binary)
    in
        Expression.Evaluate(asText, #shared);

shared UnitTestFramework.ImportFunction = (functionName as text, moduleName as text) =>
    Record.Field(UnitTestFramework.ImportModule(moduleName), functionName);

// Loading external functions and making them visible
shared ProvideDataForTest = UnitTestFramework.ImportFunction("ProvideDataForTest", "DataProvider.pqm");

Utilities = UnitTestFramework.ImportModule("Utilities.pqm");
shared ValueToText = Utilities[ValueToText];
shared CaseWrapper = Utilities[CaseWrapper];

Facts = UnitTestFramework.ImportModule("Facts.pqm");
shared Fact = Facts[Fact];
shared Summarize = Facts[Summarize];

Assertions = UnitTestFramework.ImportModule("Assertions.pqm");
shared AssertLogContent = Assertions[AssertLogContent];
shared AssertError = Assertions[AssertError];

Responses = UnitTestFramework.ImportModule("Responses.pqm");
shared FakeRawResponse = Responses[FakeRawResponse];
shared FakeResponse = Responses[FakeResponse];
