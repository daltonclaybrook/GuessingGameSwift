import Combine
import Foundation

extension Future where Failure == Never {
	static func `async`(_ block: @escaping () async -> Output) -> Future {
		Future { promise in
			Task {
				let result = await block()
				promise(.success(result))
			}
		}
	}
}
