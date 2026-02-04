import Foundation

@MainActor
protocol HomeViewModelProtocol: ViewModelProtocol {
    var coins: [Coin] { get }
    var lastRefreshTime: Date { get }
    func fetchTopCoins() async
    func loadAllCoinImages() async
}
