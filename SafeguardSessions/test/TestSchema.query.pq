section TestSchema;

SchemaUtils = Extension.ImportModule("SchemaUtils.pqm");
CreateSchema = SchemaUtils[CreateSchema];

Schema = Extension.ImportModule("Schema.pqm");

Schema.GenerateSchemaMap = Schema[GenerateSchemaMap];
Schema.SchemaMap = Schema[SchemaMap];
Schema.GetSchema = Schema[GetSchema];
Schema.GetSubSchema = Schema[GetSubSchema];

TestCreateSchema = () =>
    let
        rules = {{"rule_1", type text}, {"rule_2", type number}},
        schema = CreateSchema(rules),
        expectedSchema = #table(
            type table [Name = text, Type = type], {{"rule_1", type text}, {"rule_2", type number}}
        )
    in
        Fact("Created schema is correct", expectedSchema, schema);

TestGenerateSchemaMap = () =>
    let
        subSchema1 = [a = 1, b = 2, c = 3], subSchema2 = [d = 4], expectedSchemaMap = [a = 1, b = 2, c = 3, d = 4]
    in
        Fact(
            "Generated schema map is correct", expectedSchemaMap, Schema.GenerateSchemaMap({subSchema1, subSchema2})
        );

TestSessionsSchemaIsCorrect = () =>
    let
        AssertSchema = (schemaName as text, assetFile as text) =>
            let
                expectedSchema = UnitTestFramework.ImportFunction(schemaName, assetFile)
            in
                Fact(Text.Format("#{0} schema matches", {schemaName}), expectedSchema, Schema.GetSchema(schemaName)),
        assetFile = "SessionsSchemaAsset.pqm",
        sessionsSchemaNames = List.Select(
            Record.FieldNames(Schema.SchemaMap), (schemaName) => Text.StartsWith(schemaName, "sessions")
        ),
        cases = List.Transform(sessionsSchemaNames, (schemaName) => {schemaName, assetFile}),
        facts = ProvideDataForTest(cases, AssertSchema)
    in
        facts;

shared TestSchema.UnitTest = [
    facts = {TestCreateSchema(), TestGenerateSchemaMap(), TestSessionsSchemaIsCorrect()},
    report = Facts.Summarize(facts)
][report];
