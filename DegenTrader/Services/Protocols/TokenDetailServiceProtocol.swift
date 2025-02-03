import Foundation

protocol TokenDetailServiceProtocol {
    func fetchTokenDetails(address: String) async throws -> TokenDetail
} 