import Foundation

protocol ResponseInterceptor {
    func intercept(response: URLResponse, data: Data) -> Data
}
