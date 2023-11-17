section TestTemplateName;

// A dummy function is used in this template
// The function to be tested should be imported here
TestableFunction = (value as any) => value;

TestCaseTemplate = () => let facts = {Fact("Case description", 0, TestableFunction(0))} in facts;

TestCaseTemplateWithProvider = () =>
    let
        AssertTemplate = (description as text, value as any, expectedValue as any) =>
            Fact(
                Text.Format("Case description for #[Case]", [Case = description]),
                expectedValue,
                TestableFunction(value)
            ),
        cases = {{"Test case 1", 1, 1}, {"Test case 2", 2}},
        facts = ProvideDataForTest(cases, AssertTemplate)
    in
        facts;

shared TestTemplateName.UnitTest = [
    facts = {TestCaseTemplate(), TestCaseTemplateWithProvider()},
    report = Summarize(facts)
][report];
