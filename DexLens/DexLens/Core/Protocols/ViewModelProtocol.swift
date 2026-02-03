import Foundation
import Combine

@MainActor
protocol ViewModelProtocol: ObservableObject {
    var isLoading: Bool { get set }
    var errorMessage: String? { get set }
    func handleError(_ error: Error)
}

extension ViewModelProtocol {
    func handleError(_ error: Error) {
        if let networkError = error as? NetworkError {
            errorMessage = networkError.errorDescription
        } else {
            errorMessage = error.localizedDescription
        }
    }
}
