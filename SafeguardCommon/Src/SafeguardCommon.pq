[Version = "1.0.0"]
section SafeguardCommonCode;

//
// Load common library functions
//
shared SafeguardCommon.ImportModule = (name as text) =>
    let
        binary = Extension.Contents(name), asText = Text.FromBinary(binary)
    in
        Expression.Evaluate(asText, #shared);

shared SafeguardCommon.ImportFunction = (function_name as text, module_name as text) =>
    Record.Field(SafeguardCommon.ImportModule(module_name), function_name);
