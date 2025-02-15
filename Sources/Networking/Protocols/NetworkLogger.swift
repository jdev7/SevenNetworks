import Foundation

protocol NetworkLogger {
    func log(request: URLRequest)
    func log(response: URLResponse, data: Data?)
    func log(error: Error)
}
