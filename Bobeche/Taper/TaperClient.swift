import Foundation

/// Role: Taper. Typed transport failures. This product has no remote catalog.
enum WickWire: Error, Equatable, Sendable {
    case absent
    case garbled
    case dropped
    case halted
    case odd
}

/// Role: Taper. One HTTP exchange. Tests inject a script.
protocol WickCarrier: Sendable {
    func carry(_ request: URLRequest) async throws -> (Data, URLResponse)
}

/// Role: Taper. 15 s timeout and the app User-Agent on every request.
struct WickSession: WickCarrier, Sendable {
    let session: URLSession

    init(session: URLSession) {
        self.session = session
    }

    init() {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = WickHeaders.timeout
        configuration.timeoutIntervalForResource = WickHeaders.timeout
        configuration.httpAdditionalHeaders = ["User-Agent": WickHeaders.userAgent]
        self.session = URLSession(configuration: configuration)
    }

    func carry(_ request: URLRequest) async throws -> (Data, URLResponse) {
        try await session.data(for: request)
    }
}

enum WickHeaders {
    static let userAgent = "Bobeche/1.0 (iOS; +https://bobeche-wick.pro)"
    static let timeout: TimeInterval = 15
}

/// Role: Taper. JSON number or numeric string. Missing stays nil.
struct WickLooseNumber: Sendable, Equatable {
    var value: Double?
}

extension WickLooseNumber: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            value = nil
            return
        }
        if let number = try? container.decode(Double.self) {
            value = number
            return
        }
        if let number = try? container.decode(Int.self) {
            value = Double(number)
            return
        }
        if let text = try? container.decode(String.self) {
            value = Double(text)
            return
        }
        value = nil
    }
}

/// Role: Taper. status 0 means absent. No Open Food Facts catalog is wired.
enum WickCatalog {
    static func accept(status: Int) throws {
        if status == 0 { throw WickWire.absent }
    }
}

/// Role: Taper. Owns the session. Decode DTO then map. Never into domain types. Contact is a Settings link.
actor TaperClient {
    static let userAgent = WickHeaders.userAgent
    /// Programmer constant; the domain string is fixed in SPEC.md.
    static let contactURL = URL(string: "https://bobeche-wick.pro/contact-us")!

    private let carrier: any WickCarrier

    init(carrier: any WickCarrier) {
        self.carrier = carrier
    }

    init() {
        self.carrier = WickSession()
    }

    func pull<DTO: Decodable>(_ type: DTO.Type, at url: URL) async throws -> DTO {
        try Task.checkCancellation()
        let body = try await cargo(request(at: url), attempt: 0)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        do {
            return try decoder.decode(DTO.self, from: body)
        } catch is CancellationError {
            throw WickWire.halted
        } catch {
            throw WickWire.garbled
        }
    }

    private func request(at url: URL) -> URLRequest {
        var request = URLRequest(url: url, timeoutInterval: WickHeaders.timeout)
        request.setValue(WickHeaders.userAgent, forHTTPHeaderField: "User-Agent")
        return request
    }

    private func cargo(_ request: URLRequest, attempt: Int) async throws -> Data {
        do {
            return try await fire(request)
        } catch let wire as WickWire {
            throw wire
        } catch is CancellationError {
            throw WickWire.halted
        } catch {
            if wickHalted(error) { throw WickWire.halted }
            guard attempt == 0, wickTransient(error) else { throw WickWire.dropped }
            return try await cargo(request, attempt: 1)
        }
    }

    private func fire(_ request: URLRequest) async throws -> Data {
        try Task.checkCancellation()
        let (data, response) = try await carrier.carry(request)
        guard let http = response as? HTTPURLResponse else {
            throw WickWire.odd
        }
        if http.statusCode == 404 {
            throw WickWire.absent
        }
        guard (200 ..< 300).contains(http.statusCode) else {
            throw WickWire.dropped
        }
        return data
    }
}

func wickTransient(_ error: Error) -> Bool {
    guard let urlError = error as? URLError else { return false }
    switch urlError.code {
    case .timedOut, .networkConnectionLost, .notConnectedToInternet,
         .cannotConnectToHost, .cannotFindHost, .dnsLookupFailed:
        return true
    default:
        return false
    }
}

func wickHalted(_ error: Error) -> Bool {
    if error is CancellationError { return true }
    return (error as? URLError)?.code == .cancelled
}
