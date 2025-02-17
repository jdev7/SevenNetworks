import Foundation

public protocol ResponseInterceptor {
    func intercept(response: URLResponse, data: Data) -> Data
}
