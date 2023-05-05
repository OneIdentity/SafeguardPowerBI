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
        cellValue = try withFlattenedLists{[session_id = "id2"]}[list_field],
        withErrorsReplaced = Table.ReplaceErrorValues(withFlattenedLists, {"list_field", "error_replaced"}),
        facts = {
            TestErrorIsRaised(
                cellValue,
                "List To Text Conversion Error",
                "The list contains other types than text.",
                [
                    ManuallyHandled = true,
                    Cause = "[""3"",4]",
                    RequestUrl = null
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
        AssertFieldNames = (description as text, listOfRecords as list, t as type, expectedFieldNames as list) =>
            Fact(description, expectedFieldNames, SchemaUtils.FieldNamesOfType(listOfRecords, t)),
        listOfRecords = {
            [
                text_field = "text",
                number_field = 1,
                number_field_2 = 2,
                logical_field = true,
                datetimezone_field = #datetimezone(2023, 2, 23, 16, 28, 42, 1, 0),
                list_field = {},
                record_field = []
            ]
        },
        listOfRecordsWithNull = {[text_field = null], [text_field = "text_value"]},
        cases = {
            {"Empty list is handled", {}, Any.Type, {}},
            {"Text field names are returned", listOfRecords, Text.Type, {"text_field"}},
            {"Number field names are returned", listOfRecords, Number.Type, {"number_field", "number_field_2"}},
            {"Logical field names are returned", listOfRecords, Logical.Type, {"logical_field"}},
            {"DateTimeZone field names are returned", listOfRecords, DateTimeZone.Type, {"datetimezone_field"}},
            {"List field names are returned", listOfRecords, List.Type, {"list_field"}},
            {"Record field names are returned", listOfRecords, Record.Type, {"record_field"}},
            {
                "All field names are returned",
                listOfRecords,
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
            {"No field names are returned for non-existing type", listOfRecords, Function.Type, {}},
            {
                "Field type is correctly determined if nulls are present",
                listOfRecordsWithNull,
                Text.Type,
                {"text_field"}
            }
        },
        facts = ProvideDataForTest(cases, AssertFieldNames)
    in
        facts;

TestFlatness = () =>
    let
        AssertFlatness = (description as text, listOfRecords as list, expected_result as logical) as record =>
            Fact(description, expected_result, SchemaUtils.IsFlat(listOfRecords)),
        cases = {
            {"No data is flat", {}, true},
            {"Flat", {[flat = 1], [flat = 2]}, true},
            {"Contains record", {[
                nonflat = [value = 1],
                flat = 1
            ], [
                nonflat = [value = 2],
                flat = 2
            ]}, false},
            {"Contains list", {[
                nonflat = {"1", "2"},
                flat = 1
            ], [
                nonflat = {"3", "4"},
                flat = 2
            ]}, false}
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
                "Columns are removed",
                {[flat = 1, to_remove = "a"], [flat = 2, to_remove = "b"]},
                {"to_remove"},
                #table(type table [flat = any], {{1}, {2}})
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
    report = Facts.Summarize(facts)
][report];
