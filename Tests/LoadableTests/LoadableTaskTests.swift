import XCTest

@testable import Loadable

final class LoadableTaskTests: XCTestCase {
	func test_loadableCancellation () async throws {
		// Given
		let task = VoidTask { }

		// When
		let loadable = Loadable<String>.loading(task: task)

		// Then
		XCTAssertEqual(loadable, .loading(task: task))
		XCTAssertFalse(task.isCancelled)

		// When
		loadable.cancel()

		// Then
		XCTAssertEqual(loadable, .loading(task: task))
		XCTAssertTrue(task.isCancelled)
	}

	func test_setLoading_cancellation () async throws {
		// Given
		let task = VoidTask { }
		var loadable = Loadable<String>.loading(task: task)

		// When
		loadable.setLoading()

		// Then
        _ = try? await loadable.loadingTask?.value

		XCTAssertEqual(loadable, .loading())
		XCTAssertTrue(task.isCancelled)
	}

	func test_setLoadingWithTask () async throws {
		// Given
		let initialTask = VoidTask { }
		let task = VoidTask { }
		var loadable = Loadable<String>.loading(task: initialTask)

		// When
		loadable.setLoading(task: task)

		// Then
        _ = try? await loadable.loadingTask?.value

		XCTAssertEqual(loadable, .loading(task: task))
		XCTAssertTrue(initialTask.isCancelled)
	}

	func test_setLoadingAction () async throws {
		// Given
		let initialValue = "initial"

		let initialTask = VoidTask { }
		let overwritingTask = VoidTask { }

		var loadable = Loadable<String>.successful(initialValue)

		// When
		loadable.setLoading(task: initialTask)

		// Then
		XCTAssertFalse(initialTask.isCancelled)

		// When
		loadable.setLoading(task: overwritingTask)

		// Then
		_ = try? await initialTask.value
        _ = try? await loadable.loadingTask?.value

		XCTAssertTrue(initialTask.isCancelled)
		XCTAssertEqual(loadable.loadingValue, initialValue)
	}

	func test_loading () async {
		// Given
		let initialValue = "initial"
		let initialTask = VoidTask { }
		let loadable = Loadable.loading(task: initialTask, value: initialValue)

		// When
		let newLoadable = loadable.loading()

		// Then
		XCTAssertEqual(newLoadable.loadingValue, initialValue)
		XCTAssertEqual(newLoadable.loadingTask, initialTask)
		XCTAssertFalse(initialTask.isCancelled)
	}

	func test_loadingWithNewTask () async {
		// Given
		let initialValue = "initial"
		let initialTask = VoidTask { }
		let overwritingTask = VoidTask { }
		let loadable = Loadable.loading(task: initialTask, value: initialValue)

		// When
		let newLoadable = loadable.loading(task: overwritingTask)

		// Then
		XCTAssertEqual(loadable.loadingValue, initialValue)
		XCTAssertEqual(newLoadable.loadingValue, initialValue)
		XCTAssertEqual(loadable.loadingTask, initialTask)
		XCTAssertEqual(newLoadable.loadingTask, overwritingTask)
		XCTAssertFalse(initialTask.isCancelled)
	}

	func test_loadingCancellationWithNewTask () async {
		// Given
		let initialValue = "initial"
		let initialTask = VoidTask { }
		let overwritingTask = VoidTask { }
		let loadable = Loadable.loading(task: initialTask, value: initialValue)

		// When
		let newLoadable = loadable.canceled().loading(task: overwritingTask)

		// Then
		XCTAssertEqual(loadable.loadingValue, initialValue)
		XCTAssertEqual(newLoadable.loadingValue, initialValue)
		XCTAssertEqual(loadable.loadingTask, initialTask)
		XCTAssertEqual(newLoadable.loadingTask, overwritingTask)
		XCTAssertTrue(initialTask.isCancelled)
	}
}
