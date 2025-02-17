import Foundation

public class APIClient {
    private let session: URLSessionProtocol
    private let baseURL: URL
    private let requestEncoder: RequestEncoder
    private let interceptors: [RequestInterceptor]
    private let responseInterceptors: [ResponseInterceptor]
    private let logger: NetworkLogger?

    public convenience init(
        baseURL: URL,
        session: URLSession = .shared,
        interceptors: [RequestInterceptor] = [],
        responseInterceptors: [ResponseInterceptor] = []
    ) {
        self.init(baseURL: baseURL, session: session, interceptors: interceptors, responseInterceptors: responseInterceptors, logger: nil)
    }

    private init(
        baseURL: URL,
        session: URLSessionProtocol = URLSession.shared,
        interceptors: [RequestInterceptor],
        responseInterceptors: [ResponseInterceptor],
        logger: NetworkLogger?
    ) {
        self.session = session
        self.baseURL = baseURL
        self.requestEncoder = RequestEncoder()
        self.interceptors = interceptors
        self.responseInterceptors = responseInterceptors
        self.logger = logger
    }
    
    public func send<T: Endpoint>(_ endpoint: T) async throws -> T.Response {
        let url = baseURL.appendingPathComponent(endpoint.path)

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.allHTTPHeaderFields = endpoint.headers
        
        requestEncoder.encode(&request, with: endpoint.payload)

        interceptors.forEach { request = $0.intercept(request: request) }
        logger?.log(request: request)
        
        let (data, response) = try await session.data(for: request)

        var finalData = data
        responseInterceptors.forEach { finalData = $0.intercept(response: response, data: finalData) }
        logger?.log(response: response, data: finalData)
        
        return try JSONDecoder().decode(T.Response.self, from: finalData)
    }
}
