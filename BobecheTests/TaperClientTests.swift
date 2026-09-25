import XCTest
@testable import Bobeche

private struct ProbeDTO: Decodable {
    var status: Int?
    var span: WickLooseNumber?
}

private actor ScriptedCarrier: WickCarrier {
    private var results: [Result<(Data, URLResponse), Error>]
    private var requests: [URLRequest] = []

    init(results: [Result<(Data, URLResponse), Error>]) {
        self.results = results
    }

    func carry(_ request: URLRequest) async throws -> (Data, URLResponse) {
        requests.append(request)
        guard !results.isEmpty else { throw URLError(.cannotConnectToHost) }
        return try results.removeFirst().get()
    }

    func recordedRequests() -> [URLRequest] {
        requests
    }
}

final class TaperClientTests: XCTestCase {
    private let url = URL(string: "https://bobeche-wick.pro/probe")!

    func test_setsUserAgentOnEveryRequest() async throws {
        let carrier = ScriptedCarrier(results: [
            .success((Data("{\"span\":1}".utf8), http(200))),
        ])
        let client = TaperClient(carrier: carrier)
        _ = try await client.pull(ProbeDTO.self, at: url)
        let request = await carrier.recordedRequests().first
        XCTAssertEqual(request?.value(forHTTPHeaderField: "User-Agent"), TaperClient.userAgent)
        XCTAssertEqual(request?.timeoutInterval, 15)
        XCTAssertEqual(TaperClient.userAgent, "Bobeche/1.0 (iOS; +https://bobeche-wick.pro)")
        XCTAssertEqual(TaperClient.contactURL.absoluteString, "https://bobeche-wick.pro/contact-us")
    }

    func test_retriesTransientTransportOnce() async throws {
        let carrier = ScriptedCarrier(results: [
            .failure(URLError(.timedOut)),
            .success((Data("{\"span\":\"4.5\"}".utf8), http(200))),
        ])
        let client = TaperClient(carrier: carrier)
        let dto = try await client.pull(ProbeDTO.self, at: url)
        XCTAssertEqual(dto.span?.value, 4.5)
        let count = await carrier.recordedRequests().count
        XCTAssertEqual(count, 2)
    }

    func test_doesNotRetry404() async {
        let carrier = ScriptedCarrier(results: [
            .success((Data(), http(404))),
            .success((Data("{\"span\":1}".utf8), http(200))),
        ])
        let client = TaperClient(carrier: carrier)
        do {
            _ = try await client.pull(ProbeDTO.self, at: url)
            XCTFail("expected absent")
        } catch {
            XCTAssertEqual(error as? WickWire, .absent)
        }
        let count = await carrier.recordedRequests().count
        XCTAssertEqual(count, 1)
    }

    func test_malformedJSONIsGarbled() async {
        let carrier = ScriptedCarrier(results: [
            .success((Data("{".utf8), http(200))),
        ])
        let client = TaperClient(carrier: carrier)
        do {
            _ = try await client.pull(ProbeDTO.self, at: url)
            XCTFail("expected garbled")
        } catch {
            XCTAssertEqual(error as? WickWire, .garbled)
        }
    }

    func test_looseNumberAcceptsNumberAndString() throws {
        let number = try JSONDecoder().decode(ProbeDTO.self, from: Data("{\"span\":12.5}".utf8))
        let string = try JSONDecoder().decode(ProbeDTO.self, from: Data("{\"span\":\"12.5\"}".utf8))
        let missing = try JSONDecoder().decode(ProbeDTO.self, from: Data("{\"span\":null}".utf8))
        XCTAssertEqual(number.span?.value, 12.5)
        XCTAssertEqual(string.span?.value, 12.5)
        XCTAssertNil(missing.span?.value)
    }

    func test_statusZeroIsAbsent() throws {
        XCTAssertThrowsError(try WickCatalog.accept(status: 0)) { error in
            XCTAssertEqual(error as? WickWire, .absent)
        }
        XCTAssertNoThrow(try WickCatalog.accept(status: 1))
    }

    private func http(_ status: Int) -> HTTPURLResponse {
        HTTPURLResponse(url: url, statusCode: status, httpVersion: nil, headerFields: nil)!
    }
}
