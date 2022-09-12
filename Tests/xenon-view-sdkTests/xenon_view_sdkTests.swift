//Swift
import Quick
import Nimble
import xenon_view_sdk

final class xenon_view_sdkTests: QuickSpec {
    override func spec() {
        describe("Xenon SDK") {
            it("then") {
                expect(xenon_view_sdk().text).to(contain("Hello, World!"))
            }
        }
    }
}