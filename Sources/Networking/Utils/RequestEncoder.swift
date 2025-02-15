import Foundation

struct RequestEncoder {
    func encode(_ request: inout URLRequest, with payload: RequestPayload) {
        switch payload {
        case .body(let encodable):
            request.httpBody = try? JSONEncoder().encode(encodable)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        case .query(let params):
            if var components = URLComponents(url: request.url!, resolvingAgainstBaseURL: false) {
                components.queryItems = params.map { URLQueryItem(name: $0.key, value: $0.value) }
                request.url = components.url
            }
        case .none:
            break
        }
    }
}
