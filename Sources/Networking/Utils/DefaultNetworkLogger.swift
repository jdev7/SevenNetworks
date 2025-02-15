import Foundation

final class ConsoleNetworkLogger: NetworkLogger {
    func log(request: URLRequest) {
        let httpMethod = request.httpMethod ?? "No HTTP Method"
        let path = request.url?.absoluteString ?? "No path"
        let headers = request.allHTTPHeaderFields ?? [:]
        let bodyData = request.httpBody

        log(header: .request(.start, httpMethod: httpMethod))
        print(path)

        log(header: .headers(.start))
        for (key, value) in headers {
            print("== \(key): \(value) ==")
        }
        log(header: .headers(.end))

        do {
            try log(data: bodyData)
        } catch {
            log(error: error)
        }

        log(header: .request(.end, httpMethod: httpMethod))
    }

    func log(response: URLResponse, data: Data?) {
        guard let response = response as? HTTPURLResponse else { return }
        let path = response.url?.absoluteString ?? "No path"
        let headers = response.allHeaderFields

        log(header: .response(.start, statusCode: response.statusCode))
        print(path)

        log(header: .headers(.start))
        for (key, value) in headers {
            print("== \(key): \(value)")
        }
        log(header: .headers(.end))

        do {
            try log(data: data)
        } catch {
            log(error: error)
        }
        log(header: .response(.end, statusCode: response.statusCode))
    }

    func log(error: Error) {
        log(header: .error(.start))
        print(error.localizedDescription)
        log(header: .error(.end))
    }
}

// MARK: - Private Methods
private extension ConsoleNetworkLogger {
    enum LogHeader {
        enum Phase: String, CustomStringConvertible {
            case start
            case end

            var description: String { rawValue.uppercased() }
        }
        case request(Phase, httpMethod: String)
        case response(Phase, statusCode: Int)
        case headers(Phase)
        case body(Phase)
        case error(Phase)
    }

    func log(data: Data?) throws {
        guard let jsonObject = try data.flatMap({ try JSONSerialization.jsonObject(with: $0, options: []) }),
              let jsonString = try String(data: JSONSerialization.data(
                withJSONObject: jsonObject,
                options: .prettyPrinted
              ), encoding: .utf8)
        else { return }

        log(header: .body(.start))
        print(jsonString)
        log(header: .body(.end))
    }

    func log(header: LogHeader) {
        switch header {
        case let .request(phase, httpMethod):
            print("\(phase) \(httpMethod) REQUEST")
        case let .response(phase, statusCode):
            print("================ \(phase) RESPONSE (\(statusCode)) ================")
        case let .headers(phase):
            print("================ \(phase) HEADERS ================")
        case let .body(phase):
            print("================ \(phase) BODY ================")
        case let .error(phase):
            print("================ \(phase) ERROR ================")
        }
    }
}
