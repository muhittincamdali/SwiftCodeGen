import XCTest
@testable import SwiftCodeGen

final class MockGeneratorTests: XCTestCase {

    private var parser: SwiftParser!

    override func setUp() {
        super.setUp()
        parser = SwiftParser()
    }

    override func tearDown() {
        parser = nil
        super.tearDown()
    }

    // MARK: - Protocol Parsing

    func testParseSimpleProtocol() {
        let source = """
        protocol UserService {
            func fetchUser(id: String) -> User
        }
        """

        let protocols = parser.parseProtocols(from: source)
        XCTAssertEqual(protocols.count, 1)
        XCTAssertEqual(protocols.first?.name, "UserService")
        XCTAssertEqual(protocols.first?.methods.count, 1)
    }

    func testParseMethodWithMultipleParameters() {
        let source = """
        protocol AuthService {
            func login(username: String, password: String) async throws -> Token
        }
        """

        let protocols = parser.parseProtocols(from: source)
        let method = protocols.first?.methods.first

        XCTAssertEqual(method?.name, "login")
        XCTAssertEqual(method?.parameters.count, 2)
        XCTAssertTrue(method?.isAsync ?? false)
        XCTAssertTrue(method?.isThrowing ?? false)
        XCTAssertEqual(method?.returnType, "Token")
    }

    func testParseProtocolWithProperties() {
        let source = """
        protocol SettingsProvider {
            var theme: String { get }
            var fontSize: Int { get set }
        }
        """

        let protocols = parser.parseProtocols(from: source)
        let properties = protocols.first?.properties ?? []

        XCTAssertEqual(properties.count, 2)
        XCTAssertTrue(properties[0].isReadOnly)
        XCTAssertFalse(properties[1].isReadOnly)
    }

    func testParseMultipleProtocols() {
        let source = """
        protocol ServiceA {
            func doWork()
        }

        protocol ServiceB {
            func process(data: Data) -> Result
        }
        """

        let protocols = parser.parseProtocols(from: source)
        XCTAssertEqual(protocols.count, 2)
    }

    func testTemplateEngineRender() {
        let engine = TemplateEngine()
        let template = "Hello {{name}}, you have {{count}} items."
        let context: [String: Any] = ["name": "World", "count": 5]

        let result = engine.render(template, context: context)
        XCTAssertEqual(result, "Hello World, you have 5 items.")
    }

    func testTemplateEngineSectionBlock() {
        let engine = TemplateEngine()
        let template = "{{#show}}visible{{/show}}"

        let visible = engine.render(template, context: ["show": true])
        XCTAssertEqual(visible, "visible")

        let hidden = engine.render(template, context: ["show": false])
        XCTAssertEqual(hidden, "")
    }

    func testTemplateEngineInvertedSection() {
        let engine = TemplateEngine()
        let template = "{{^empty}}has content{{/empty}}"

        let result = engine.render(template, context: ["empty": false])
        XCTAssertEqual(result, "has content")
    }
}
