section TestPaddedTableFromRecords;

PaddedTable.FromRecords = Extension.ImportFunction("PaddedTable.FromRecords", "Utils.pqm");

PaddedTable.FromRecords.Name = "PaddedTable.FromRecords";

TestPaddedTableFromRecords = () =>
    let
        AssertTableIsCreatedCorrectly = (description as text, listOfRecords as list, expectedOutput as table) =>
            Fact(
                Text.Format("#{0}: #{1}", {PaddedTable.FromRecords.Name, description}),
                expectedOutput,
                PaddedTable.FromRecords(listOfRecords)
            ),
        cases = {
            {"Empty list is converted correctly", {}, #table({}, {})},
            {"List with empty record is converted correctly", {[]}, #table(type table, {{}})},
            {
                "List with complete records is converted correctly",
                {[a = 1, b = 2, c = 3], [a = 4, b = 5, c = 6]},
                #table(type table [a = any, b = any, c = any], {{1, 2, 3}, {4, 5, 6}})
            },
            {
                "List with complete first record is converted correctly",
                {[a = 1, b = 2, c = 3], [a = 4]},
                #table(type table [a = any, b = any, c = any], {{1, 2, 3}, {4, null, null}})
            },
            {
                "List with incomplete records is converted correctly",
                {[a = 1], [b = 2], [c = 3]},
                #table(type table [a = any, b = any, c = any], {{1, null, null}, {null, 2, null}, {null, null, 3}})
            }
        },
        facts = ProvideDataForTest(cases, AssertTableIsCreatedCorrectly)
    in
        facts;

TestPaddedTableFromRecordsRaisesError = () =>
    let
        records = {"not_a_record"},
        result = try PaddedTable.FromRecords(records),
        facts = {
            Fact(Text.Format("#{0}: Error is raised", {PaddedTable.FromRecords.Name}), result[HasError], true),
            Fact(
                Text.Format("#{0}: Error reason is correct", {PaddedTable.FromRecords.Name}),
                result[Error][Reason],
                "Expression.Error"
            ),
            Fact(
                Text.Format("#{0}: Error details are correct", {PaddedTable.FromRecords.Name}),
                result[Error][Detail],
                [
                    Value = "not_a_record",
                    Type = type record
                ]
            )
        }
    in
        facts;

shared TestPaddedTableFromRecords.UnitTest = [
    facts = {TestPaddedTableFromRecords(), TestPaddedTableFromRecordsRaisesError()},
    report = Facts.Summarize(facts)
][report];
