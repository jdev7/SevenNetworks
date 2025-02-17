import Foundation

public protocol RequestInterceptor {
    func intercept(request: URLRequest) -> URLRequest
}
