section TestNormalize;

Normalize.Normalize = Extension.ImportFunction("Normalize", "Normalize.pqm");

TestSubtablesAreNormalized = () =>
    let
        AssertSubTables = (
            description as text,
            subTable as record,
            newTableNames as list,
            identifierColumn as text,
            expectedSubTables as list
        ) as record =>
            Fact(description, expectedSubTables, Normalize.Normalize(subTable, newTableNames, identifierColumn)),
        cases = {
            {
                "Table without duplicates is normalized correctly",
                [
                    Name = "sessions",
                    Rows = {
                        [
                            session_id = "dummy_id_1",
                            user = [name = "name_1", dummy_field = "value1"],
                            client = [ip = "1.1.1.1"],
                            dummy_number = 1
                        ],
                        [
                            session_id = "dummy_id_2",
                            user = [name = "name_2", dummy_field = "value2"],
                            client = [ip = "2.2.2.2"],
                            dummy_number = 2
                        ]
                    }
                ],
                {"user", "client"},
                "session_id",
                {
                    [
                        Name = "sessions",
                        Data = #table(
                            type table [session_id = any, dummy_number = any], {{"dummy_id_1", 1}, {"dummy_id_2", 2}}
                        )
                    ],
                    [
                        Name = "sessions.user",
                        Data = #table(
                            type table [user.name = any, user.dummy_field = any, sessions.user_id = number],
                            {{"name_1", "value1", 1}, {"name_2", "value2", 2}}
                        )
                    ],
                    [
                        Name = "sessions.user_to_sessions",
                        Data = #table(
                            type table [session_id = any, sessions.user_id = number],
                            {{"dummy_id_1", 1}, {"dummy_id_2", 2}}
                        )
                    ],
                    [
                        Name = "sessions.client",
                        Data = #table(
                            type table [client.ip = any, sessions.client_id = number], {
                                {"1.1.1.1", 1},
                                {"2.2.2.2", 2}
                            }
                        )
                    ],
                    [
                        Name = "sessions.client_to_sessions",
                        Data = #table(
                            type table [session_id = any, sessions.client_id = number],
                            {{"dummy_id_1", 1}, {"dummy_id_2", 2}}
                        )
                    ]
                }
            },
            {
                "Duplicates are removed from subtables during normalization",
                [
                    Name = "sessions",
                    Rows = {
                        [
                            session_id = "dummy_id_1",
                            user = [name = "name_1", dummy_field = "value1"],
                            client = [ip = "1.1.1.1"],
                            dummy_number = 1
                        ],
                        [
                            session_id = "dummy_id_2",
                            user = [name = "name_2", dummy_field = "value2"],
                            client = [ip = "2.2.2.2"],
                            dummy_number = 2
                        ],
                        [
                            session_id = "dummy_id_3",
                            user = [name = "name_3", dummy_field = "value3"],
                            client = [ip = "1.1.1.1"],
                            dummy_number = 3
                        ]
                    }
                ],
                {"user", "client"},
                "session_id",
                {
                    [
                        Name = "sessions",
                        Data = #table(
                            type table [session_id = any, dummy_number = any],
                            {{"dummy_id_1", 1}, {"dummy_id_2", 2}, {"dummy_id_3", 3}}
                        )
                    ],
                    [
                        Name = "sessions.user",
                        Data = #table(
                            type table [user.name = any, user.dummy_field = any, sessions.user_id = number],
                            {{"name_1", "value1", 1}, {"name_2", "value2", 2}, {"name_3", "value3", 3}}
                        )
                    ],
                    [
                        Name = "sessions.user_to_sessions",
                        Data = #table(
                            type table [session_id = any, sessions.user_id = number],
                            {{"dummy_id_1", 1}, {"dummy_id_2", 2}, {"dummy_id_3", 3}}
                        )
                    ],
                    [
                        Name = "sessions.client",
                        Data = #table(
                            type table [client.ip = any, sessions.client_id = number], {
                                {"1.1.1.1", 1},
                                {"2.2.2.2", 2}
                            }
                        )
                    ],
                    [
                        Name = "sessions.client_to_sessions",
                        Data = #table(
                            type table [session_id = any, sessions.client_id = number],
                            {{"dummy_id_1", 1}, {"dummy_id_3", 1}, {"dummy_id_2", 2}}
                        )
                    ]
                }
            },
            {
                "Table is normalized correctly without subtables",
                [
                    Name = "sessions",
                    Rows = {
                        [
                            session_id = "dummy_id_1",
                            user = [name = "name_1", dummy_field = "value1"],
                            client = [ip = "1.1.1.1"],
                            dummy_number = 1
                        ],
                        [
                            session_id = "dummy_id_2",
                            user = [name = "name_2", dummy_field = "value2"],
                            client = [ip = "2.2.2.2"],
                            dummy_number = 2
                        ]
                    }
                ],
                {},
                "session_id",
                {
                    [
                        Name = "sessions",
                        Data = #table(
                            type table [
                                session_id = any,
                                user.name = any,
                                user.dummy_field = any,
                                client.ip = any,
                                dummy_number = any
                            ],
                            {
                                {"dummy_id_1", "name_1", "value1", "1.1.1.1", 1},
                                {"dummy_id_2", "name_2", "value2", "2.2.2.2", 2}
                            }
                        )
                    ]
                }
            },
            {
                "Subtable with many-to-many relations is normalized correctly",
                [
                    Name = "sessions",
                    Rows = {
                        [
                            session_id = "dummy_id_1",
                            client = [ip = "1.1.1.1"],
                            dummy_number = 1
                        ],
                        [
                            session_id = "dummy_id_1",
                            client = [ip = "2.2.2.2"],
                            dummy_number = 1
                        ],
                        [
                            session_id = "dummy_id_2",
                            client = [ip = "1.1.1.1"],
                            dummy_number = 2
                        ],
                        [
                            session_id = "dummy_id_2",
                            client = [ip = "2.2.2.2"],
                            dummy_number = 2
                        ]
                    }
                ],
                {"client"},
                "session_id",
                {
                    [
                        Name = "sessions",
                        Data = #table(
                            type table [session_id = any, dummy_number = any], {{"dummy_id_1", 1}, {"dummy_id_2", 2}}
                        )
                    ],
                    [
                        Name = "sessions.client",
                        Data = #table(
                            type table [client.ip = any, sessions.client_id = number], {
                                {"1.1.1.1", 1},
                                {"2.2.2.2", 2}
                            }
                        )
                    ],
                    [
                        Name = "sessions.client_to_sessions",
                        Data = #table(
                            type table [session_id = any, sessions.client_id = number],
                            {{"dummy_id_1", 1}, {"dummy_id_2", 1}, {"dummy_id_1", 2}, {"dummy_id_2", 2}}
                        )
                    ]
                }
            }
        },
        facts = ProvideDataForTest(cases, AssertSubTables)
    in
        facts;

shared TestNormalize.UnitTest = [
    facts = {TestSubtablesAreNormalized()},
    report = Facts.Summarize(facts)
][report];
