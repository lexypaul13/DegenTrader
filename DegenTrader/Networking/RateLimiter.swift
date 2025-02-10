import Foundation

actor RateLimiter {
    private var requestTimestamps: [Date] = []
    private let requestsPerMinute: Int
    private let queue = DispatchQueue(label: "com.degentrader.ratelimiter")
    
    init(requestsPerMinute: Int = 300) {
        self.requestsPerMinute = requestsPerMinute
    }
    
    func shouldAllowRequest() async -> Bool {
        let now = Date()
        let oneMinuteAgo = now.addingTimeInterval(-60)
        
        // Remove timestamps older than 1 minute
        requestTimestamps = requestTimestamps.filter { $0 > oneMinuteAgo }
        
        // Check if we're under the rate limit
        if requestTimestamps.count < requestsPerMinute {
            requestTimestamps.append(now)
            return true
        }
        
        return false
    }
    
    func waitForNextAllowedRequest() async throws {
        while true {
            if await shouldAllowRequest() {
                return
            }
            try await Task.sleep(nanoseconds: 1_000_000_000) // Sleep for 1 second
        }
    }
} 