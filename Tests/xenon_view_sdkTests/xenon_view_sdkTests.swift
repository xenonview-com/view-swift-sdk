//
// Created by Woydziak, Luke on 9/12/22.
//

import Quick
import Nimble
@testable import class xenon_view_sdk.Xenon

final class xenon_view_sdkTests: QuickSpec {
    override func spec() {
        describe("Xenon SDK") {
            it("then") {
                expect(Xenon().text).to(contain("Hello, World!"))
            }
        }
    }
}