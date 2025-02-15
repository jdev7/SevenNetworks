enum RequestPayload {
    case query([String: String])
    case body(Encodable)
    case none
}
