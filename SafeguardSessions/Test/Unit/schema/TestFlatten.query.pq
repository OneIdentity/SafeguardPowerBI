section TestFlatten;

SchemaUtils = Extension.ImportModule("SchemaUtils.pqm");

SchemaUtils.FieldNamesOfType = SchemaUtils[FieldNamesOfType];
SchemaUtils.IsFlat = SchemaUtils[IsFlat];
SchemaUtils.FlattenLists = SchemaUtils[FlattenLists];
SchemaUtils.FlattenRecords = SchemaUtils[FlattenRecords];
SchemaUtils.Flatten = SchemaUtils[Flatten];

TestFlatteningLists = () =>
    let
        AssertResult = (description as text, t as table, fieldNames as list, expectedTable as table) =>
            Fact(description, expectedTable, SchemaUtils.FlattenLists(t, fieldNames)),
        fieldNames = {"list_field"},
        cases = {
            {
                "List field is flattened correctly",
                #table({"list_field"}, {{{"1", "2"}}, {{"3", "4"}}}),
                fieldNames,
                #table(type table [list_field = any], {{"1,2"}, {"3,4"}})
            },
            {
                "List field with empty list is flattened correctly",
                #table({"list_field"}, {{{}}, {{"3", "4"}}}),
                fieldNames,
                #table(type table [list_field = any], {{""}, {"3,4"}})
            },
            {
                "List field with null value is flattened correctly",
                #table({"list_field"}, {{{"1", "2"}}, {null}}),
                fieldNames,
                #table(type table [list_field = any], {{"1,2"}, {null}})
            },
            {
                "Multiple list fields are flattened correctly",
                #table({"list_field_1", "list_field_2"}, {{{"1", "2"}, {"4", "3"}}, {{"3", "4"}, {"2", "1"}}}),
                {"list_field_1", "list_field_2"},
                #table(type table [list_field_1 = any, list_field_2 = any], {{"1,2", "4,3"}, {"3,4", "2,1"}})
            }
        },
        facts = ProvideDataForTest(cases, AssertResult)
    in
        facts;

TestFlattenListsHandlesListWithNonTextValue = () =>
    let
        t = #table({"session_id", "list_field"}, {{"id1", {"1", "2"}}, {"id2", {"3", 4}}}),
        fieldNames = {"list_field"},
        withFlattenedLists = SchemaUtils.FlattenLists(t, fieldNames),
        cellValue = () => withFlattenedLists{[session_id = "id2"]}[list_field],
        withErrorsReplaced = Table.ReplaceErrorValues(withFlattenedLists, {"list_field", "error_replaced"}),
        facts = {
            AssertError(
                "Error is raised when a list with non-text value is present",
                cellValue,
                {},
                [
                    Reason = "List To Text Conversion Error",
                    Message = "Error 10003: The list contains other types than text.",
                    Detail = [
                        Cause = "[""3"",4]",
                        RequestUrl = null,
                        ManuallyHandled = true,
                        ErrorCode = 10003
                    ]
                ]
            ),
            Fact(
                "The rest of the response is correct",
                #table(type table [session_id = any, list_field = any], {{"id1", "1,2"}, {"id2", "error_replaced"}}),
                withErrorsReplaced
            )
        }
    in
        facts;

TestFlatteningRecords = () =>
    let
        AssertResult = (description as text, t as table, fieldNames as list, expectedTable as table) =>
            Fact(description, expectedTable, SchemaUtils.FlattenRecords(t, fieldNames)),
        cases = {
            {
                "Record field is flattened correctly",
                #table({"record_field"}, {{[a = 1]}, {[b = 2]}}),
                {"record_field"},
                #table(type table [record_field.a = any, record_field.b = any], {{1, null}, {null, 2}})
            },
            {
                "Record field with empty record is flattened correctly",
                #table({"record_field"}, {{[]}, {[b = 2]}}),
                {"record_field"},
                #table(type table [record_field.b = any], {{null}, {2}})
            },
            {
                "Record field with null record is flattened correctly",
                #table({"record_field"}, {{[a = 1]}, {null}}),
                {"record_field"},
                #table(type table [record_field.a = any], {{1}, {null}})
            },
            {
                "Record with complex structure is flattened correctly",
                #table({"record_field"}, {{[a = 2, b = 10]}, {[]}, {[b = 2]}, {null}}),
                {"record_field"},
                #table(
                    type table [record_field.a = any, record_field.b = any],
                    {{2, 10}, {null, null}, {null, 2}, {null, null}}
                )
            },
            {
                "Multiple record fields are flattened correctly",
                #table({"record_field_1", "record_field_2"}, {{[a = 1], [c = 3]}, {[b = 2], [d = 4]}}),
                {"record_field_1", "record_field_2"},
                #table(
                    type table [
                        record_field_1.a = any, record_field_1.b = any, record_field_2.c = any, record_field_2.d = any
                    ],
                    {{1, null, 3, null}, {null, 2, null, 4}}
                )
            }
        },
        facts = ProvideDataForTest(cases, AssertResult)
    in
        facts;

TestGettingFieldNamesOfType = () =>
    let
        AssertFieldNames = (description as text, _table as table, t as type, expectedFieldNames as list) =>
            Fact(description, expectedFieldNames, SchemaUtils.FieldNamesOfType(_table, t)),
        _table = #table(
            {
                "text_field",
                "number_field",
                "number_field_2",
                "logical_field",
                "datetimezone_field",
                "list_field",
                "record_field"
            },
            {{"text", 1, 2, true, #datetimezone(2023, 2, 23, 16, 28, 42, 1, 0), {}, []}}
        ),
        _tableWithNull = #table({"text_field"}, {{null}, {"text_value"}}),
        cases = {
            {"Empty list is handled", #table({}, {}), Any.Type, {}},
            {"Text field names are returned", _table, Text.Type, {"text_field"}},
            {"Number field names are returned", _table, Number.Type, {"number_field", "number_field_2"}},
            {"Logical field names are returned", _table, Logical.Type, {"logical_field"}},
            {"DateTimeZone field names are returned", _table, DateTimeZone.Type, {"datetimezone_field"}},
            {"List field names are returned", _table, List.Type, {"list_field"}},
            {"Record field names are returned", _table, Record.Type, {"record_field"}},
            {
                "All field names are returned",
                _table,
                Any.Type,
                {
                    "text_field",
                    "number_field",
                    "number_field_2",
                    "logical_field",
                    "datetimezone_field",
                    "list_field",
                    "record_field"
                }
            },
            {"No field names are returned for non-existing type", _table, Function.Type, {}},
            {"Field type is correctly determined if nulls are present", _tableWithNull, Text.Type, {"text_field"}}
        },
        facts = ProvideDataForTest(cases, AssertFieldNames)
    in
        facts;

TestFlatness = () =>
    let
        AssertFlatness = (description as text, _table as table, expected_result as logical) as record =>
            Fact(description, expected_result, SchemaUtils.IsFlat(_table)),
        cases = {
            {"No data is flat", #table({}, {}), true},
            {"Flat", #table({"flat"}, {{1}, {2}}), true},
            {"Contains record", #table({"notflat", "flat"}, {{[value = 1], 1}, {[value = 2], 2}}), false},
            {"Contains list", #table({"nontflat", "flat"}, {{{"1", "2"}, 1}, {{"3", "4"}, 2}}), false}
        },
        facts = ProvideDataForTest(cases, AssertFlatness)
    in
        facts;

TestFlattening = () =>
    let
        AssertFlattening = (
            description as text, listOfRecords as list, columnsToRemove as list, expectedResult as table
        ) as record =>
            Fact(description, expectedResult, SchemaUtils.Flatten(listOfRecords, columnsToRemove)),
        cases = {
            {"No data is handled", {}, {}, #table(type table, {})},
            {
                "Data remains untouched if there is nothing to flatten",
                {[flat = 1], [flat = 2]},
                {},
                #table(type table [flat = any], {{1}, {2}})
            },
            {
                "Empty records are flattened",
                {[
                    nonflat = [],
                    flat = 1
                ], [
                    nonflat = [],
                    flat = 2
                ]},
                {},
                #table(type table [flat = any], {{1}, {2}})
            },
            {
                "Records are flattened",
                {[
                    nonflat = [value1 = 1, value2 = 3],
                    flat = 1
                ], [
                    nonflat = [value1 = 2, value2 = 4],
                    flat = 2
                ]},
                {},
                #table(type table [nonflat.value1 = any, nonflat.value2 = any, flat = any], {{1, 3, 1}, {2, 4, 2}})
            },
            {
                "Records with different fields are flattened",
                {[
                    nonflat = [value1 = 1],
                    flat = 1
                ], [
                    nonflat = [value2 = 2],
                    flat = 2
                ]},
                {},
                #table(
                    type table [nonflat.value1 = any, nonflat.value2 = any, flat = any], {{1, null, 1}, {null, 2, 2}}
                )
            },
            {
                "Lists are flattened",
                {[
                    nonflat = {"1", "2"},
                    flat = 1
                ], [
                    nonflat = {"3", "4"},
                    flat = 2
                ]},
                {},
                #table(type table [nonflat = any, flat = any], {{"1,2", 1}, {"3,4", 2}})
            },
            {
                "Multi-level records are flattened",
                {
                    [
                        nonflat = [
                            second_level = [value = 1]
                        ],
                        flat = 1
                    ],
                    [
                        nonflat = [
                            second_level = [value = 2]
                        ],
                        flat = 2
                    ]
                },
                {},
                #table(type table [nonflat.second_level.value = any, flat = any], {{1, 1}, {2, 2}})
            },
            {
                "Simple column is removed",
                {[flat = 1, to_remove = "a"], [flat = 2, to_remove = "b"]},
                {"to_remove"},
                #table(type table [flat = any], {{1}, {2}})
            },
            {
                "List type column is removed",
                {[flat = 1, to_remove = {"a", "b"}], [flat = 2, to_remove = {"b", "c"}]},
                {"to_remove"},
                #table(type table [flat = any], {{1}, {2}})
            },
            {
                "Record type column is removed",
                {[
                    flat = 1,
                    to_remove = [apple = "a"]
                ], [
                    flat = 2,
                    to_remove = [banana = "b"]
                ]},
                {"to_remove"},
                #table(type table [flat = any], {{1}, {2}})
            },
            {
                "Inner simple column is removed",
                {
                    [
                        flat = 1,
                        not_flat = [apple = "a", to_remove = "b"]
                    ],
                    [
                        flat = 2,
                        not_flat = [apple = "b", to_remove = "b"]
                    ]
                },
                {"not_flat.to_remove"},
                #table(type table [flat = any, not_flat.apple = any], {{1, "a"}, {2, "b"}})
            },
            {
                "Inner record column is removed",
                {
                    [
                        flat = 1,
                        not_flat = [
                            apple = "a",
                            to_remove = [apple = "a", banana = "b"]
                        ]
                    ],
                    [
                        flat = 2,
                        not_flat = [
                            apple = "b",
                            to_remove = [grape = "g"]
                        ]
                    ]
                },
                {"not_flat.to_remove"},
                #table(type table [flat = any, not_flat.apple = any], {{1, "a"}, {2, "b"}})
            },
            {
                "Inner list column is removed",
                {
                    [
                        flat = 1,
                        not_flat = [
                            apple = {"a", "b", "c"},
                            to_remove = {"a", "b", "c"}
                        ]
                    ],
                    [
                        flat = 2,
                        not_flat = [
                            apple = {"a", "b", "c"}
                        ]
                    ]
                },
                {"not_flat.to_remove"},
                #table(type table [flat = any, not_flat.apple = any], {{1, "a,b,c"}, {2, "a,b,c"}})
            }
        },
        facts = ProvideDataForTest(cases, AssertFlattening)
    in
        facts;

shared TestFlatten.UnitTest = [
    facts = {
        TestGettingFieldNamesOfType(),
        TestFlatness(),
        TestFlatteningLists(),
        TestFlattenListsHandlesListWithNonTextValue(),
        TestFlatteningRecords(),
        TestFlattening()
    },
    report = Summarize(facts)
][report];
