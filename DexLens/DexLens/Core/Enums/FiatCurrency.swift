import Foundation

/// Represents supported fiat currencies for price display and API queries
///
/// ## Supported Currencies
/// - USD: United States Dollar ($)
/// - EUR: Euro (€)
///
/// ## Usage
/// ```swift
/// let currency = FiatCurrency.usd
/// print(currency.rawValue) // "USD"
/// print(currency.sign) // "$"
/// ```
enum FiatCurrency: String, CaseIterable {
    case usd = "USD"
    case eur = "EUR"

    /// Currency symbol for display
    var sign: String {
        switch self {
        case .usd:
            "$"
        case .eur:
            "€"
        }
    }

    /// Full currency name
    var displayName: String {
        switch self {
        case .usd:
            "US Dollar"
        case .eur:
            "Euro"
        }
    }
}

// MARK: - CustomStringConvertible

extension FiatCurrency: CustomStringConvertible {
    var description: String {
        displayName
    }
}
