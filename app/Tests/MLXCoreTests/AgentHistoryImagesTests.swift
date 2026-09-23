import XCTest

@testable import MLXCore

/// The server renders every image in the conversation where it was sent, so
/// the agent history carries every user message's images, not only the last
/// one's; Gemma's raw-pixel format is ~9 MB an image and stays latest-only.
@MainActor
final class AgentHistoryImagesTests: XCTestCase {
    private func history(historyImages: Bool) -> [[String: Any]] {
        var first = ChatMessage(role: .user, content: "page one")
        first.images = [ChatImage(data: Data([0x89, 0x50, 0x4E, 0x47]))]
        var second = ChatMessage(role: .user, content: "page two")
        second.images = [ChatImage(data: Data([0x89, 0x50, 0x4E, 0x47]))]
        return AgentEngine.buildAgentHistory(
            messages: [first, ChatMessage(role: .assistant, content: "seen"), second],
            contextLength: 32768, maxTokens: 4096,
            buildMultimodalContent: { text, _ in [["type": "text", "text": text]] },
            historyImages: historyImages)
    }

    private func multimodalUsers(_ h: [[String: Any]]) -> Int {
        h.filter { ($0["role"] as? String) == "user" && $0["content"] is [[String: Any]] }.count
    }

    func testEveryUserMessageCarriesItsImages() {
        XCTAssertEqual(multimodalUsers(history(historyImages: true)), 2)
    }

    func testRawPixelModelsKeepOnlyTheLatestImages() {
        XCTAssertEqual(multimodalUsers(history(historyImages: false)), 1)
    }
}
