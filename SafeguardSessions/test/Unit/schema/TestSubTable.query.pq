section TestSubTables;

SubTable = Extension.ImportModule("SubTable.pqm");

SubTable.GetPath = SubTable[GetPath];

SubTable.FieldNamesOfType = SubTable[FieldNamesOfType];
SubTable.IsFlat = SubTable[IsFlat];
SubTable.Flatten = SubTable[Flatten];

SubTable.ToSubTables = SubTable[ToSubTables];
SubTable.SubTableNames = SubTable[SubTableNames];
SubTable.Select = SubTable[Select];
SubTable.Remove = SubTable[Remove];

TestGettingFieldNamesOfType = () =>
    let
        AssertFieldNames = (description as text, subTable as record, t as type, expectedFieldNames as list) =>
            Fact(description, expectedFieldNames, SubTable.FieldNamesOfType(subTable, t)),
        subTable = [
            Name = "dummy_subtable",
            Data = {
                [
                    text_field = "text",
                    number_field = 1,
                    number_field_2 = 2,
                    logical_field = true,
                    datetimezone_field = #datetimezone(2023, 2, 23, 16, 28, 42, 1, 0),
                    list_field = {},
                    record_field = []
                ]
            }
        ],
        cases = {
            {"Text field names are returned", subTable, Text.Type, {"text_field"}},
            {"Number field names are returned", subTable, Number.Type, {"number_field", "number_field_2"}},
            {"Logical field names are returned", subTable, Logical.Type, {"logical_field"}},
            {"DateTimeZone field names are returned", subTable, DateTimeZone.Type, {"datetimezone_field"}},
            {"List field names are returned", subTable, List.Type, {"list_field"}},
            {"Record field names are returned", subTable, Record.Type, {"record_field"}},
            {
                "All field names are returned",
                subTable,
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
            {"No field names are returned for non-existing type", subTable, Function.Type, {}}
        },
        facts = ProvideDataForTest(cases, AssertFieldNames)
    in
        facts;

TestSubTableFlatness = () =>
    let
        AssertFlatness = (description as text, subTable as record, expected_result as logical) as record =>
            Fact(description, expected_result, SubTable.IsFlat(subTable)),
        cases = {
            {"Subtable is flat", [
                Name = "flat_subtable",
                Data = {[flat = 1], [flat = 2]}
            ], true},
            {
                "Subtable contains record",
                [
                    Name = "nonflat_subtable",
                    Data = {[
                        nonflat = [value = 1],
                        flat = 1
                    ], [
                        nonflat = [value = 2],
                        flat = 2
                    ]}
                ],
                false
            },
            {
                "Subtable contains list",
                [
                    Name = "nonflat_subtable",
                    Data = {[
                        nonflat = {"1", "2"},
                        flat = 1
                    ], [
                        nonflat = {"3", "4"},
                        flat = 2
                    ]}
                ],
                false
            }
        },
        facts = ProvideDataForTest(cases, AssertFlatness)
    in
        facts;

TestGettingPath = () =>
    let
        AssertPath = (description as text, name as text, expected_path as text) as record =>
            Fact(description, expected_path, SubTable.GetPath(name)),
        cases = {
            {"Path for empty name is correct", "", ""},
            {"Path for simple name is correct", "simple", ""},
            {"Path for two-level name is correct", "two-level.name", "two-level"},
            {"Path for multi-level name is correct", "this.is.a.multi-level.name", "this.is.a.multi-level"}
        },
        facts = ProvideDataForTest(cases, AssertPath)
    in
        facts;

TestSubTableConvertedToSubTables = () =>
    let
        AssertSubTables = (
            description as text,
            subTable as record,
            subTableNames as list,
            identifierColumn as nullable text,
            expectedTables as list
        ) as record =>
            Fact(description, expectedTables, SubTable.ToSubTables(subTable, subTableNames, identifierColumn)),
        cases = {
            {
                "Subtable is correctly converted to subtables with no subtable specified",
                [
                    Name = "parent",
                    Data = {
                        [
                            dummy_id = "dummy_id_1",
                            column_to_not_select = "not_selected_1"
                        ],
                        [
                            dummy_id = "dummy_id_2",
                            column_to_not_select = "not_selected_2"
                        ]
                    }
                ],
                {},
                "dummy_id",
                {
                    [
                        Name = "parent",
                        Data = {
                            [
                                dummy_id = "dummy_id_1",
                                column_to_not_select = "not_selected_1"
                            ],
                            [
                                dummy_id = "dummy_id_2",
                                column_to_not_select = "not_selected_2"
                            ]
                        }
                    ]
                }
            },
            {
                "Subtable is correctly converted to subtables with 1 subtable specified",
                [
                    Name = "parent",
                    Data = {
                        [
                            dummy_id = "dummy_id_1",
                            column_to_select = "selected_1",
                            column_to_not_select = "not_selected_1"
                        ],
                        [
                            dummy_id = "dummy_id_2",
                            column_to_select = "selected_2",
                            column_to_not_select = "not_selected_2"
                        ]
                    }
                ],
                {"column_to_select"},
                "dummy_id",
                {
                    [
                        Name = "parent",
                        Data = {
                            [
                                dummy_id = "dummy_id_1",
                                column_to_not_select = "not_selected_1"
                            ],
                            [
                                dummy_id = "dummy_id_2",
                                column_to_not_select = "not_selected_2"
                            ]
                        }
                    ],
                    [
                        Name = "parent.column_to_select",
                        Data = {
                            [
                                column_to_select = "selected_1",
                                dummy_id = "dummy_id_1"
                            ],
                            [
                                column_to_select = "selected_2",
                                dummy_id = "dummy_id_2"
                            ]
                        }
                    ]
                }
            },
            {
                "Subtable is correctly converted to subtables with multiple subtable specified",
                [
                    Name = "parent",
                    Data = {
                        [
                            dummy_id = "dummy_id_1",
                            column_to_select = "selected_1",
                            column_to_select_2 = "selected_2_1",
                            column_to_not_select = "not_selected_1"
                        ],
                        [
                            dummy_id = "dummy_id_2",
                            column_to_select = "selected_2",
                            column_to_select_2 = "selected_2_2",
                            column_to_not_select = "not_selected_2"
                        ]
                    }
                ],
                {"column_to_select", "column_to_select_2"},
                "dummy_id",
                {
                    [
                        Name = "parent",
                        Data = {
                            [
                                dummy_id = "dummy_id_1",
                                column_to_not_select = "not_selected_1"
                            ],
                            [
                                dummy_id = "dummy_id_2",
                                column_to_not_select = "not_selected_2"
                            ]
                        }
                    ],
                    [
                        Name = "parent.column_to_select",
                        Data = {
                            [
                                column_to_select = "selected_1",
                                dummy_id = "dummy_id_1"
                            ],
                            [
                                column_to_select = "selected_2",
                                dummy_id = "dummy_id_2"
                            ]
                        }
                    ],
                    [
                        Name = "parent.column_to_select_2",
                        Data = {
                            [
                                column_to_select_2 = "selected_2_1",
                                dummy_id = "dummy_id_1"
                            ],
                            [
                                column_to_select_2 = "selected_2_2",
                                dummy_id = "dummy_id_2"
                            ]
                        }
                    ]
                }
            }
        },
        facts = ProvideDataForTest(cases, AssertSubTables)
    in
        facts;

TestFlatteningSubTable = () =>
    let
        AssertFlatness = (description as text, subTable as record, expected_result as record) as record =>
            Fact(description, expected_result, SubTable.Flatten(subTable)),
        cases = {
            {
                "Subtable remains untouched if there is nothing to flatten",
                [
                    Name = "flat_subtable",
                    Data = {[flat = 1], [flat = 2]}
                ],
                [
                    Name = "flat_subtable",
                    Data = {[flat = 1], [flat = 2]}
                ]
            },
            {
                "Record are flattened",
                [
                    Name = "nonflat_subtable",
                    Data = {[
                        nonflat = [value = 1],
                        flat = 1
                    ], [
                        nonflat = [value = 2],
                        flat = 2
                    ]}
                ],
                [
                    Name = "nonflat_subtable",
                    Data = {[nonflat.value = 1, flat = 1], [nonflat.value = 2, flat = 2]}
                ]
            },
            {
                "Lists are flattened",
                [
                    Name = "nonflat_subtable",
                    Data = {[
                        nonflat = {"1", "2"},
                        flat = 1
                    ], [
                        nonflat = {"3", "4"},
                        flat = 2
                    ]}
                ],
                [
                    Name = "nonflat_subtable",
                    Data = {[nonflat = "1,2", flat = 1], [nonflat = "3,4", flat = 2]}
                ]
            },
            {
                "Multi-level records are flattened",
                [
                    Name = "nonflat_subtable",
                    Data = {
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
                    }
                ],
                [
                    Name = "nonflat_subtable",
                    Data = {[nonflat.second_level.value = 1, flat = 1], [nonflat.second_level.value = 2, flat = 2]}
                ]
            }
        },
        facts = ProvideDataForTest(cases, AssertFlatness)
    in
        facts;

TestGettingSubTableNames = () =>
    let
        AssertSubtableNames = (description as text, subTables as list, expectedNames as list) as record =>
            Fact(description, expectedNames, SubTable.SubTableNames(subTables)),
        cases = {
            {"Names for empty list", {}, {}},
            {"Names for one subtable", {[Name = "a", Data = {}]}, {"a"}},
            {"Names for multiple subtables", {[Name = "a", Data = {}], [Name = "b", Data = {}]}, {"a", "b"}}
        },
        facts = ProvideDataForTest(cases, AssertSubtableNames)
    in
        facts;

TestSelectingSubTables = () =>
    let
        AssertSelection = (description as text, subTables as list, selectedNames as list, expectedSubTables as list) as record =>
            Fact(description, expectedSubTables, SubTable.Select(subTables, selectedNames)),
        subTables = {
            [
                Name = "a",
                Data = {"dummy_value_a"}
            ],
            [
                Name = "b",
                Data = {"dummy_value_b"}
            ],
            [
                Name = "c",
                Data = {"dummy_value_c"}
            ]
        },
        cases = {
            {"Nothing is selected", subTables, {}, {}},
            {"One existing item is selected", subTables, {"a"}, {[Name = "a", Data = {"dummy_value_a"}]}},
            {
                "Multiple existing items are selected",
                subTables,
                {"a", "c"},
                {[Name = "a", Data = {"dummy_value_a"}], [Name = "c", Data = {"dummy_value_c"}]}
            },
            {"Not existing item is selected", subTables, {"d"}, {}},
            {
                "Both existing and not existing items are select",
                subTables,
                {"b", "d"},
                {[Name = "b", Data = {"dummy_value_b"}]}
            }
        },
        facts = ProvideDataForTest(cases, AssertSelection)
    in
        facts;

TestRemovingSubTables = () =>
    let
        AssertRemoval = (description as text, subTables as list, selectedNames as list, expectedSubTables as list) as record =>
            Fact(description, expectedSubTables, SubTable.Remove(subTables, selectedNames)),
        subTables = {
            [
                Name = "a",
                Data = {"dummy_value_a"}
            ],
            [
                Name = "b",
                Data = {"dummy_value_b"}
            ],
            [
                Name = "c",
                Data = {"dummy_value_c"}
            ]
        },
        cases = {
            {"Nothing is removed", subTables, {}, subTables},
            {
                "One existing item is removed",
                subTables,
                {"a"},
                {[Name = "b", Data = {"dummy_value_b"}], [Name = "c", Data = {"dummy_value_c"}]}
            },
            {"Multiple existing items are removed", subTables, {"a", "c"}, {[Name = "b", Data = {"dummy_value_b"}]}},
            {
                "Not existing item is to be removed",
                subTables,
                {"d"},
                {
                    [
                        Name = "a",
                        Data = {"dummy_value_a"}
                    ],
                    [
                        Name = "b",
                        Data = {"dummy_value_b"}
                    ],
                    [
                        Name = "c",
                        Data = {"dummy_value_c"}
                    ]
                }
            },
            {
                "Both existing and not existing items are removed",
                subTables,
                {"b", "d"},
                {[Name = "a", Data = {"dummy_value_a"}], [Name = "c", Data = {"dummy_value_c"}]}
            }
        },
        facts = ProvideDataForTest(cases, AssertRemoval)
    in
        facts;

shared TestSubTables.UnitTest = [
    facts = {
        TestGettingFieldNamesOfType(),
        TestSubTableFlatness(),
        TestGettingPath(),
        TestFlatteningSubTable(),
        TestSubTableConvertedToSubTables(),
        TestGettingSubTableNames(),
        TestSelectingSubTables(),
        TestRemovingSubTables()
    },
    report = Facts.Summarize(facts)
][report];
