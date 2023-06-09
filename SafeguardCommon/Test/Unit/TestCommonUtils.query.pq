section TestCommonUtils;

CommonUtils = SafeguardCommon.ImportModule("CommonUtils.pqm");

PaddedTable.FromRecords = CommonUtils[PaddedTable.FromRecords];
PaddedTable.FromRecords.Name = "PaddedTable.FromRecords";

GetOption = CommonUtils[GetOption];

GetOption.Name = "GetOption";

SetOption = CommonUtils[SetOption];

SetOption.Name = "SetOption";

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

TestGetOption = () =>
    let
        AssertOptionIsReturnedCorrectly = (
            description as text, options as record, selectedOption as text, expectedOutput as any
        ) =>
            Fact(
                Text.Format("#{0}: #{1}", {GetOption.Name, description}),
                expectedOutput,
                GetOption(options, selectedOption)
            ),
        options = [
            a = 1,
            b = [
                c = 2
            ]
        ],
        cases = {
            {"Returns first level simple option", options, "a", 1},
            {"Returns first level complex option", options, "b", [c = 2]},
            {"Returns second level option", options, "b.c", 2},
            {"Returns null if option does not exists", options, "not_existing_option", null}
        },
        facts = ProvideDataForTest(cases, AssertOptionIsReturnedCorrectly)
    in
        facts;

TestSetOption = () =>
    let
        AssertOptionIsSetCorrectly = (
            description as text, options as record, selectedOption as text, value as any, expectedOutput as record
        ) =>
            Fact(
                Text.Format("#{0}: #{1}", {SetOption.Name, description}),
                expectedOutput,
                SetOption(options, selectedOption, value)
            ),
        cases = {
            {
                "Sets first level option, keeps the others intact",
                [
                    do_not_touch = true
                ],
                "set",
                1,
                [
                    do_not_touch = true,
                    set = 1
                ]
            },
            {
                "Updates first level option, keeps the others intact",
                [
                    do_not_touch = true,
                    to_update = 0
                ],
                "to_update",
                1,
                [
                    do_not_touch = true,
                    to_update = 1
                ]
            },
            {
                "Sets second level option, keeps the others intact",
                [
                    do_not_touch = true,
                    update = [not_this = true]
                ],
                "update.set",
                1,
                [
                    do_not_touch = true,
                    update = [set = 1, not_this = true]
                ]
            },
            {
                "Updates second level option, keeps the others intact",
                [
                    do_not_touch = true,
                    update = [this = 0, not_this = true]
                ],
                "update.this",
                1,
                [
                    do_not_touch = true,
                    update = [this = 1, not_this = true]
                ]
            },
            {"Sets second level option without first level", [], "set.this", 1, [
                set = [this = 1]
            ]},
            {
                "Does not set null option, keeps the others intact",
                [
                    do_not_touch = true,
                    wont_update = true
                ],
                "wont_update",
                null,
                [
                    do_not_touch = true,
                    wont_update = true
                ]
            }
        },
        facts = ProvideDataForTest(cases, AssertOptionIsSetCorrectly)
    in
        facts;

shared TestCommonUtils.UnitTest = [
    facts = {TestPaddedTableFromRecords(), TestPaddedTableFromRecordsRaisesError(), TestGetOption(), TestSetOption()},
    report = Summarize(facts)
][report];
