section TestGetResponseWithSchema;

SchemaUtils = Extension.ImportModule("SchemaUtils.pqm");
CreateSchema = SchemaUtils[CreateSchema];
GetResponseWithSchema = SchemaUtils[GetResponseWithSchema];

TestGetResponseWithSchema = () =>
    let
        AssertTransformation = (caseName as text, tableToTransform as table, schema as table, expectedTable as table) =>
            Fact(caseName, expectedTable, GetResponseWithSchema(tableToTransform, schema)),
        cases = {
            {"Empty table", #table({}, {{}}), CreateSchema({}), #table(type table, {{}})},
            {
                "Simple table with one text column and one number column",
                #table({"text_col", "number_col"}, {{"text_value", 0}}),
                CreateSchema({{"text_col", type text}, {"number_col", type number}}),
                #table(type table [text_col = text, number_col = number], {{"text_value", 0}})
            },
            {
                "Simple table with one text column and one missing number column",
                #table({"text_col"}, {{"text_value"}}),
                CreateSchema({{"text_col", type text}, {"number_col", type number}}),
                #table(type table [text_col = text, number_col = number], {{"text_value", null}})
            },
            {
                "Simple table with one text column and one extra number column",
                #table({"text_col", "number_col"}, {{"text_value", 0}}),
                CreateSchema({{"text_col", type text}}),
                #table(type table [text_col = text], {{"text_value"}})
            },
            {
                "Columns are reordered",
                #table({"text_col", "number_col"}, {{"text_value", 0}}),
                CreateSchema({{"number_col", type number}, {"text_col", type text}}),
                #table(type table [number_col = number, text_col = text], {{0, "text_value"}})
            }
        },
        facts = ProvideDataForTest(cases, AssertTransformation)
    in
        facts;

shared TestGetResponseWithSchema.UnitTest = [
    facts = {TestGetResponseWithSchema()},
    report = Summarize(facts)
][report];
