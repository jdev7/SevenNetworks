import Foundation

protocol RequestInterceptor {
    func intercept(request: URLRequest) -> URLRequest
}
