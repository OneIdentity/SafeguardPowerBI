section TestCreateSchema;

SchemaUtils = SafeguardSessions.ImportModule("SchemaUtils.pqm");
CreateSchema = SchemaUtils[CreateSchema];

TestCreateSchema = (case as text, rules as list, expectedSchema as table) as record =>
    Fact(Text.Format("Created schema is correct for #[Case]", [Case = case]), expectedSchema, CreateSchema(rules));

TestSchemaCreation = () =>
    let
        cases = {
            {"Empty schema", {}, #table(type table [Name = text, Type = type], {})},
            {
                "Schema with basic rules",
                {{"rule_1", type text}, {"rule_2", type number}},
                #table(type table [Name = text, Type = type], {{"rule_1", type text}, {"rule_2", type number}})
            }
        },
        facts = ProvideDataForTest(cases, TestCreateSchema)
    in
        facts;

shared TestCreateSchema.UnitTest = [
    facts = {TestSchemaCreation()},
    report = Summarize(facts)
][report];
