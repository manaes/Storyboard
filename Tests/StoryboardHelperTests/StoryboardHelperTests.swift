import Testing
@testable import StoryboardHelper

@Test func testLoadSuccess() async throws {
    #expect(try await Storyboard.controller(TestViewController.self) != nil)
}

@Test func testLoadCreatorSuccess() async throws {
    Task { @MainActor in
        do {
            let vc = try Storyboard.controller(TestViewModelController.self) { coder in
                TestViewModelController(
                    viewModel: TestViewModel(),
                    coder: coder
                )
            }
            #expect(vc != nil)
        }
    }
}

@Test func testLoadFail() async {
    Task { @MainActor in
        do {
            _ = try Storyboard.controller(TestFailViewController.self)
        } catch {
            #expect(error as? StoryboardError == .notFound)
        }
    }
}
