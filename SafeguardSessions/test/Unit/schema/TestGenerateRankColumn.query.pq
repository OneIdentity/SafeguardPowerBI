section TestGenerateRankColumn;

Normalize.GenerateRankColumn = Extension.ImportFunction("GenerateRankColumn", "Normalize.pqm");

TestIdGeneration = () as list =>
    let
        AssertIdColumn = (
            description as text, subTable as record, excludedColumns as nullable list, expectedTable as record
        ) as record =>
            Fact(description, expectedTable, Normalize.GenerateRankColumn(subTable, excludedColumns)),
        cases = {
            {
                "Generate rank for one-column table with no duplicate rows",
                [
                    Name = "dummy_name",
                    Data = {[text_column = "t1"], [text_column = "t2"]}
                ],
                null,
                [
                    Name = "dummy_name",
                    Data = #table(type table [text_column = any, dummy_name_id = number], {{"t1", 1}, {"t2", 2}})
                ]
            },
            {
                "Generate rank for one-column table with duplicate rows",
                [
                    Name = "dummy_name",
                    Data = {[text_column = "t1"], [text_column = "t2"], [text_column = "t1"]}
                ],
                null,
                [
                    Name = "dummy_name",
                    Data = #table(type table [text_column = any, dummy_name_id = number], {{"t1", 1}, {"t2", 2}})
                ]
            },
            {
                "Generate rank for two-column table with no duplicate rows",
                [
                    Name = "dummy_name",
                    Data = {
                        [
                            text_column = "t1",
                            number_column = 1
                        ],
                        [
                            text_column = "t2",
                            number_column = 2
                        ],
                        [
                            text_column = "t1",
                            number_column = 2
                        ]
                    }
                ],
                null,
                [
                    Name = "dummy_name",
                    Data = #table(
                        type table [text_column = any, number_column = any, dummy_name_id = number],
                        {{"t1", 1, 1}, {"t1", 2, 2}, {"t2", 2, 3}}
                    )
                ]
            },
            {
                "Generate rank for two-column table with missing value",
                [
                    Name = "dummy_name",
                    Data = {
                        [
                            text_column = "t1",
                            number_column = 1
                        ],
                        [
                            text_column = "t2",
                            number_column = 2
                        ],
                        [
                            text_column = "t3"
                        ]
                    }
                ],
                null,
                [
                    Name = "dummy_name",
                    Data = #table(
                        type table [text_column = any, number_column = any, dummy_name_id = number],
                        {{"t1", 1, 1}, {"t2", 2, 2}, {"t3", null, 3}}
                    )
                ]
            },
            {
                "Generate rank for two-column table with duplicate rows",
                [
                    Name = "dummy_name",
                    Data = {
                        [
                            text_column = "t1",
                            number_column = 1
                        ],
                        [
                            text_column = "t2",
                            number_column = 2
                        ],
                        [
                            text_column = "t2",
                            number_column = 2
                        ]
                    }
                ],
                null,
                [
                    Name = "dummy_name",
                    Data = #table(
                        type table [text_column = any, number_column = any, dummy_name_id = number],
                        {{"t1", 1, 1}, {"t2", 2, 2}}
                    )
                ]
            },
            {
                "Generate rank with excluded column",
                [
                    Name = "dummy_name",
                    Data = {[
                        number_column = 1,
                        text_column = "t2"
                    ], [
                        number_column = 2,
                        text_column = "t1"
                    ]}
                ],
                {"number_column"},
                [
                    Name = "dummy_name",
                    Data = #table(
                        type table [text_column = any, number_column = any, dummy_name_id = number],
                        {{"t1", 2, 1}, {"t2", 1, 2}}
                    )
                ]
            },
            {
                "Generate rank with excluded column and duplicate rows",
                [
                    Name = "dummy_name",
                    Data = {
                        [
                            number_column = 1,
                            text_column = "t2"
                        ],
                        [
                            number_column = 2,
                            text_column = "t1"
                        ],
                        [
                            number_column = 3,
                            text_column = "t1"
                        ]
                    }
                ],
                {"number_column"},
                [
                    Name = "dummy_name",
                    Data = #table(
                        type table [number_column = any, text_column = any, dummy_name_id = number],
                        {{2, "t1", 1}, {3, "t1", 1}, {1, "t2", 2}}
                    )
                ]
            }
        },
        facts = ProvideDataForTest(cases, AssertIdColumn)
    in
        facts;

shared TestGenerateIdColumns.UnitTest = [
    facts = {TestIdGeneration()},
    report = Facts.Summarize(facts)
][report];
