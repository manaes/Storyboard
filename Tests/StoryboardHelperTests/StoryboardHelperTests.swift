import Testing
@testable import StoryboardHelper

@Test func testLoadSuccess() async throws {
    #expect(try await Storyboard.controller(TestViewController.self) != nil)
    #expect(await Storyboard.instance(TestViewController.self) != nil)
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

@Test func testLoadInstanceCreatorSuccess() async throws {
    Task { @MainActor in
        let vc = Storyboard.instance(TestViewModelController.self) { coder in
            TestViewModelController(
                viewModel: TestViewModel(),
                coder: coder
            )
        }
        #expect(vc != nil)
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
