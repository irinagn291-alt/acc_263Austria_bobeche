import XCTest
@testable import Bobeche

final class BobecheTests: XCTestCase {
    func test_appModuleImports() {
        XCTAssertEqual(String(describing: BobecheApp.self), "BobecheApp")
        XCTAssertEqual(WickInk.face, "SF Pro")
        XCTAssertEqual(WickInk.Hex.background, "#141F1A")
        XCTAssertEqual(WickInk.Hex.surface, "#1C2B25")
        XCTAssertEqual(WickInk.Hex.ink, "#EDF2F0")
        XCTAssertEqual(WickInk.Hex.accent, "#69D3A7")
        XCTAssertEqual(WickInk.Hex.muted, "#91ACA0")
        XCTAssertEqual(WickFace.Step.allCases.count, 6)
        XCTAssertEqual(WickFace.cardRadius, 18)
        XCTAssertEqual(WickFace.chipRadius, 12)
        XCTAssertEqual(String(describing: RitualPane.self), "RitualPane")
        XCTAssertEqual(String(describing: HistoryPane.self), "HistoryPane")
        XCTAssertEqual(String(describing: WickSettings.self), "WickSettings")
        XCTAssertEqual(String(describing: CueSnuffPane.self), "CueSnuffPane")
    }
}
