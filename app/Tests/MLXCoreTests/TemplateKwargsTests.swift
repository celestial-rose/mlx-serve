import XCTest
@testable import MLXCore

/// `chat_template_kwargs` rows are typed from their spelling: the server hands
/// the object to Jinja verbatim, so "true" must land as a bool and "8" as a number.
final class TemplateKwargsTests: XCTestCase {
    func testTypedValueFromText() {
        XCTAssertEqual(TemplateKwargs.parse("true") as? Bool, true)
        XCTAssertEqual(TemplateKwargs.parse("False") as? Bool, false)
        XCTAssertEqual(TemplateKwargs.parse("8") as? Int, 8)
        XCTAssertEqual(TemplateKwargs.parse("0.5") as? Double, 0.5)
        XCTAssertEqual(TemplateKwargs.parse("low") as? String, "low")
        XCTAssertEqual(TemplateKwargs.parse(" xhigh ") as? String, "xhigh")
        XCTAssertNil(TemplateKwargs.parse("   "))
        // JSONSerialization throws an uncatchable ObjC exception on a non-finite number.
        XCTAssertEqual(TemplateKwargs.parse("nan") as? String, "nan")
        XCTAssertEqual(TemplateKwargs.parse("inf") as? String, "inf")
    }

    func testDisplayRoundTripsTheSpelling() {
        XCTAssertEqual(TemplateKwargs.display(true), "true")
        XCTAssertEqual(TemplateKwargs.display(8), "8")
        XCTAssertEqual(TemplateKwargs.display("low"), "low")
        XCTAssertEqual(TemplateKwargs.display(["a": 1]), "{\"a\":1}")
    }

    /// The rows the sheet edits ARE the object the server reads.
    func testRowsAreTheOverridesObject() {
        var o = ModelOverride()
        o.templateKwargs["preserve_thinking"] = true
        o.templateKwargs["custom"] = "x"
        XCTAssertEqual(o.sortedKwargKeys, ["custom", "preserve_thinking"])
        XCTAssertTrue(o.hasSettings)
        let kw = o.json["chat_template_kwargs"] as? [String: Any]
        XCTAssertEqual(kw?["preserve_thinking"] as? Bool, true)
        XCTAssertEqual(kw?["custom"] as? String, "x")
    }
}
