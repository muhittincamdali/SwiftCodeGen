import Foundation

/// Built-in templates for mock generation.
///
/// Provides default template strings used by `MockGenerator`
/// for different parts of the mock implementation.
public enum MockTemplate {

    /// Template for the mock class header.
    public static let classHeader = """
    {{headerComment}}

    import Foundation

    class Mock{{protocolName}}: {{protocolName}} {

    """

    /// Template for a tracked method property.
    public static let methodTracking = """
        var {{methodName}}CallCount = 0
        var {{methodName}}Called: Bool { {{methodName}}CallCount > 0 }
    """

    /// Template for argument capture storage.
    public static let argumentCapture = """
        var {{methodName}}Received{{paramNameCapitalized}}: {{paramType}}?
    """

    /// Template for return value stub.
    public static let returnValueStub = """
        var {{methodName}}ReturnValue: {{returnType}}!
    """

    /// Template for a throwing method error stub.
    public static let errorStub = """
        var {{methodName}}ThrowableError: Error?
    """

    /// Template for closure-based stub.
    public static let closureStub = """
        var {{methodName}}Closure: (({{closureParams}}){{throwsClause}} -> {{returnType}})?
    """

    /// Template for method implementation body.
    public static let methodBody = """
        func {{signature}} {
            {{methodName}}CallCount += 1
            {{argumentCapture}}
            {{throwCheck}}
            {{closureOrReturn}}
        }
    """

    /// Template for the reset method.
    public static let resetMethod = """
        func resetMock() {
            {{#methods}}
            {{methodName}}CallCount = 0
            {{/methods}}
        }
    """

    /// Template for the class footer.
    public static let classFooter = """
    }
    """

    /// Returns the complete default template for mock generation.
    public static var defaultTemplate: String {
        [
            classHeader,
            methodTracking,
            argumentCapture,
            returnValueStub,
            errorStub,
            closureStub,
            methodBody,
            resetMethod,
            classFooter
        ].joined(separator: "\n\n")
    }
}
