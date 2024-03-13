section TestCommonUtils;

PaddedTable.FromRecords = SafeguardCommon.ImportFunction("PaddedTable.FromRecords", "CommonUtils.pqm");

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
        records = {{"not_a_record"}},
        facts = AssertError(
            Text.Format(
                "#[MethodName] raises error if the data provided is not a record",
                [
                    MethodName = PaddedTable.FromRecords.Name
                ]
            ),
            PaddedTable.FromRecords,
            records,
            [
                Reason = "Expression.Error",
                Message = "We cannot convert the value ""not_a_record"" to type Record.",
                Detail = [
                    Value = "not_a_record",
                    Type = type record
                ]
            ]
        )
    in
        facts;

shared TestCommonUtils.UnitTest = [
    facts = {TestPaddedTableFromRecords(), TestPaddedTableFromRecordsRaisesError()},
    report = Summarize(facts)
][report];
