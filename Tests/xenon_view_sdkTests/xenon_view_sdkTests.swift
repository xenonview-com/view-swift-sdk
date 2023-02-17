//
// Created by Woydziak, Luke on 9/12/22.
//

import Foundation
import Quick
import Nimble
import Mockingbird
import AsyncObjects
import Dispatch
@testable import class xenon_view_sdk.Xenon
@testable import xenon_view_sdk

final class xenon_view_sdkTests: QuickSpec {
    override func spec() {
        describe("View SDK Uninitialized") {
            it("throws upon commit") {
                expect(try Xenon().commit()).to(throwError())
            }
            it("throws upon deanonymize") {
                expect(try Xenon().deanonymize(person: [:])).to(throwError())
            }
            it("throws upon heartbeat") {
                expect(try Xenon().heartbeat()).to(throwError())
            }
        }
        describe("View SDK Concurrency") {
            let journeyApi = mock(Api.self)
            let apiKey = "someThing"

            beforeEach {
                given(try! journeyApi.fetch(data: any())).willReturn(Task {
                    [:]
                })
                given(journeyApi.with(apiUrl: any())).willReturn(journeyApi)
            }

            it("then gets API key from other thread") {
                let op = TaskOperation(queue: .global(qos: .background)) {
                    _ = Xenon(apiKey: apiKey, _journeyApi: journeyApi)
                }

                let op2 = TaskOperation(queue: .global(qos: .background)) {
                    do {
                        _ = try Xenon(_journeyApi: journeyApi).commit()
                    } catch {
                        fail()
                    }
                }
                op.start()
                op2.start()
                op.waitUntilFinished()
                op2.waitUntilFinished()
            }
        }
        describe("Xenon SDK") {
            let apiKey = "<token>"
            let apiUrl = "https://localhost"
            let journeyApi = mock(Api.self)
            let heartbeatApi = mock(Api.self)
            let deanonApi = mock(Api.self)
            beforeEach {
                clearInvocations(on: journeyApi)
                clearInvocations(on: deanonApi)
                given(try! journeyApi.fetch(data: any())).willReturn(Task {
                    [:]
                })
                given(try! heartbeatApi.fetch(data: any())).willReturn(Task {
                    [:]
                })
                given(try! deanonApi.fetch(data: any())).willReturn(Task {
                    [:]
                })
                given(journeyApi.with(apiUrl: any())).willReturn(journeyApi)
                given(heartbeatApi.with(apiUrl: any())).willReturn(heartbeatApi)
                given(deanonApi.with(apiUrl: any())).willReturn(deanonApi)
                Xenon().reset()
            }
            it("can be default constructed") {
                let x1 = Xenon()
                let x2 = Xenon()
                expect(x1.id()).to(equal(x2.id()))
            }
            it("then has default id") {
                expect(Xenon().id()).notTo(equal(""))
            }
            it("can be constructed using self signed cert") {
                let v1 = Xenon(apiKey: apiKey, _allowSelfSigned: true)
                let v2 = Xenon(apiKey: apiKey, apiUrl: apiUrl, _allowSelfSigned: true)
                let v3 = Xenon(apiKey: apiKey, apiUrl: apiUrl, _allowSelfSigned: true, _journeyApi: journeyApi)
                let v4 = Xenon(apiKey: apiKey, apiUrl: apiUrl, _allowSelfSigned: true, _journeyApi: journeyApi, _deanonApi: deanonApi)
                expect(v1.selfSignedAllowed()).to(beTrue())
                expect(v2.selfSignedAllowed()).to(beTrue())
                expect(v3.selfSignedAllowed()).to(beTrue())
                expect(v4.selfSignedAllowed()).to(beTrue())
            }
            describe("when id set") {
                let testId = "<some random uuid>"
                let subject = Xenon()
                beforeEach {
                    subject.id(_id: testId)
                }
                it("then has set id") {
                    expect(subject.id()).to(equal(testId))
                }
                it("then persists id") {
                    expect(Xenon().id()).to(equal(testId))
                }
                afterEach {
                    subject.newId()
                }
            }
            describe("when id regenerated") {
                it("then has set id") {
                    let previousId = Xenon().id()
                    Xenon().newId()
                    expect(previousId).notTo(equal(Xenon().id()))
                    expect(Xenon().id()).notTo(equal(""))
                }
            }
            describe("when initialized and previous journey") {
                var subject: Xenon? = nil
                beforeEach {
                    try! Xenon().leadCaptured(specifier: "Phone Number")
                    subject = Xenon(apiKey: apiKey, apiUrl: apiUrl)
                }
                it("then has previous journey") {
                    let journey = subject!.journey()
                    expect(journey.description).to(contain("\"superOutcome\": \"Lead Capture\""))
                    expect(journey.description).to(contain("\"outcome\": \"Phone Number\""))
                    expect(journey.description).to(contain("\"result\": \"success\""))
                    expect(journey.description).to(contain("\"timestamp\": "))
                }
                afterEach {
                    Xenon().reset()
                }
            }
            describe("when adding outcome after platform reset") {
                it("then journey doesn't contain platform"){
                    let journey = Xenon().journey()[0] as! Dictionary<String, Any>
                    expect([String](journey.keys)).notTo(contain("platform"))
                }
                beforeEach {
                    let softwareVersion = "5.1.5"
                    let deviceModel = "Pixel 4 XL"
                    let operatingSystemName = "Android"
                    let operatingSystemVersion = "12.0"
                    try! Xenon().platform(softwareVersion: softwareVersion, deviceModel: deviceModel,
                            operatingSystemName: operatingSystemName, operatingSystemVersion: operatingSystemVersion)
                    Xenon().removePlatform()
                    try! Xenon().applicationInstalled()
                }
            }
            describe("when adding outcome after platform set") {
                it("then journey contains platform") {
                    let journey = Xenon().journey()[0] as! Dictionary<String, Any>
                    let platform = journey["platform"] as! Dictionary<String, String>
                    expect(platform["softwareVersion"]).to(equal("5.1.5"))
                    expect(platform["deviceModel"]).to(equal("Pixel 4 XL"))
                    expect(platform["operatingSystemName"]).to(equal("Android"))
                    expect(platform["operatingSystemVersion"]).to(equal("12.0"))
                }
                beforeEach {
                    let softwareVersion = "5.1.5"
                    let deviceModel = "Pixel 4 XL"
                    let operatingSystemName = "Android"
                    let operatingSystemVersion = "12.0"
                    try! Xenon().platform(softwareVersion: softwareVersion, deviceModel: deviceModel,
                            operatingSystemName: operatingSystemName, operatingSystemVersion: operatingSystemVersion)
                    try! Xenon().applicationInstalled()
                }
            }
            describe("when adding outcome after variants reset") {
                it("then journey doesn't contain tags") {
                    let journey = Xenon().journey()[0] as! Dictionary<String, Any>
                    expect([String](journey.keys)).notTo(contain("tags"))
                }
                beforeEach {
                    let variants = ["variant"]
                    Xenon().variant(names: variants)
                    Xenon().resetVariants()
                    try! Xenon().applicationInstalled()
                }
            }
            describe("when adding outcome after variants") {
                it("then journey contains tags") {
                    let journey = Xenon().journey()[0] as! Dictionary<String, Any>
                    let variants = journey["tags"] as! Array<String>
                    expect(variants).to(equal(["variant"]))
                }
                beforeEach {
                    let variants = ["variant"]
                    Xenon().variant(names: variants)
                    try! Xenon().applicationInstalled()
                }
            }
            // Stock Business Outcomes tests
            describe("when leadCaptured") {
                let phone = "Phone Number"
                it("then creates journey with outcome") {
                    let journey = Xenon().journey()[0] as! Dictionary<String, Any>
                    expect(journey["superOutcome"] as! String).to(equal("Lead Capture"))
                    expect(journey["outcome"] as! String).to(equal(phone))
                    expect(journey["result"] as! String).to(equal("success"))
                }
                beforeEach {
                    try! Xenon().leadCaptured(specifier: phone)
                }
            }
            describe("when leadCaptureDeclined") {
                let phone = "Phone Number"
                it("then creates journey with outcome") {
                    let journey = Xenon().journey()[0] as! Dictionary<String, Any>
                    expect(journey["superOutcome"] as! String).to(equal("Lead Capture"))
                    expect(journey["outcome"] as! String).to(equal(phone))
                    expect(journey["result"] as! String).to(equal("fail"))
                }
                beforeEach {
                    try! Xenon().leadCaptureDeclined(specifier: phone)
                }
            }
            describe("when accountSignup") {
                let viaFacebook = "Facebook"
                it("then creates journey with outcome") {
                    let journey = Xenon().journey()[0] as! Dictionary<String, Any>
                    expect(journey["superOutcome"] as! String).to(equal("Account Signup"))
                    expect(journey["outcome"] as! String).to(equal(viaFacebook))
                    expect(journey["result"] as! String).to(equal("success"))
                }
                beforeEach {
                    try! Xenon().accountSignup(specifier: viaFacebook)
                }
            }
            describe("when accountSignupDeclined") {
                let viaFacebook = "Facebook"
                it("then creates journey with outcome") {
                    let journey = Xenon().journey()[0] as! Dictionary<String, Any>
                    expect(journey["superOutcome"] as! String).to(equal("Account Signup"))
                    expect(journey["outcome"] as! String).to(equal(viaFacebook))
                    expect(journey["result"] as! String).to(equal("fail"))
                }
                beforeEach {
                    try! Xenon().accountSignupDeclined(specifier: viaFacebook)
                }
            }
            describe("when applicationInstalled") {
                it("then creates journey with outcome") {
                    let journey = Xenon().journey()[0] as! Dictionary<String, Any>
                    expect(journey["superOutcome"] as! String).to(equal("Application Installation"))
                    expect(journey["outcome"] as! String).to(equal("Installed"))
                    expect(journey["result"] as! String).to(equal("success"))
                }
                beforeEach {
                    try! Xenon().applicationInstalled()
                }
            }
            describe("when applicationNotInstalled") {
                it("then creates journey with outcome") {
                    let journey = Xenon().journey()[0] as! Dictionary<String, Any>
                    expect(journey["superOutcome"] as! String).to(equal("Application Installation"))
                    expect(journey["outcome"] as! String).to(equal("Not Installed"))
                    expect(journey["result"] as! String).to(equal("fail"))
                }
                beforeEach {
                    try! Xenon().applicationNotInstalled()
                }
            }
            describe("when initialSubscription"){
                let Silver = "Silver Monthly"
                let method = "Stripe" // optional
                describe("when has method"){
                    it("then creates journey with outcome"){
                        let journey = Xenon().journey()[0] as! Dictionary<String, Any>
                        expect(journey["superOutcome"] as! String).to(equal("Initial Subscription"))
                        expect(journey["outcome"] as! String).to(equal("Subscribe - " + Silver))
                        expect(journey["result"] as! String).to(equal("success"))
                        expect(journey["method"] as! String).to(equal(method))
                    }
                    beforeEach{
                        try! Xenon().initialSubscription(tier: Silver, method: method)
                    }
                }
                describe("when no method"){
                    it("then creates journey with outcome"){
                        let journey = Xenon().journey()[0] as! Dictionary<String, Any>
                        expect(journey["superOutcome"] as! String).to(equal("Initial Subscription"))
                        expect(journey["outcome"] as! String).to(equal("Subscribe - " + Silver))
                        expect(journey["result"] as! String).to(equal("success"))
                        expect([String](journey.keys)).notTo(contain("method"))
                    }
                    beforeEach{
                        try! Xenon().initialSubscription(tier: Silver)
                    }
                }
            }
            describe("when subscriptionDeclined"){
                let Silver = "Silver Monthly"
                let method = "Stripe" // optional
                describe("when has method"){
                    it("then creates journey with outcome"){
                        let journey = Xenon().journey()[0] as! Dictionary<String, Any>
                        expect(journey["superOutcome"] as! String).to(equal("Initial Subscription"))
                        expect(journey["outcome"] as! String).to(equal("Decline - " + Silver))
                        expect(journey["result"] as! String).to(equal("fail"))
                        expect(journey["method"] as! String).to(equal(method))
                    }
                    beforeEach{
                        try! Xenon().subscriptionDeclined(tier: Silver, method: method)
                    }
                }
                describe("when no method"){
                    it("then creates journey with outcome"){
                        let journey = Xenon().journey()[0] as! Dictionary<String, Any>
                        expect(journey["superOutcome"] as! String).to(equal("Initial Subscription"))
                        expect(journey["outcome"] as! String).to(equal("Decline - " + Silver))
                        expect(journey["result"] as! String).to(equal("fail"))
                        expect([String](journey.keys)).notTo(contain("method"))
                    }
                    beforeEach{
                        try! Xenon().subscriptionDeclined(tier: Silver)
                    }
                }
            }
            describe("when subscriptionRenewed") {
                let Silver = "Silver Monthly"
                let method = "Stripe" // optional
                describe("when has method") {
                    it("then creates journey with outcome") {
                        let journey = Xenon().journey()[0] as! Dictionary<String, Any>
                        expect(journey["superOutcome"] as! String).to(equal("Subscription Renewal"))
                        expect(journey["outcome"] as! String).to(equal("Renew - " + Silver))
                        expect(journey["result"] as! String).to(equal("success"))
                        expect(journey["method"] as! String).to(equal(method))
                    }
                    beforeEach{
                        try! Xenon().subscriptionRenewed(tier: Silver, method: method)
                    }
                }
                describe("when no method") {
                    it("then creates journey with outcome") {
                        let journey = Xenon().journey()[0] as! Dictionary<String, Any>
                        expect(journey["superOutcome"] as! String).to(equal("Subscription Renewal"))
                        expect(journey["outcome"] as! String).to(equal("Renew - " + Silver))
                        expect(journey["result"] as! String).to(equal("success"))
                        expect([String](journey.keys)).notTo(contain("method"))

                    }
                    beforeEach{
                        try! Xenon().subscriptionRenewed(tier: Silver)
                    }
                }

            }
            describe("when subscriptionCanceled") {
                let Silver = "Silver Monthly"
                let method = "Stripe" // optional
                describe("when has method") {
                    it("then creates journey with outcome") {
                        let journey = Xenon().journey()[0] as! Dictionary<String, Any>
                        expect(journey["superOutcome"] as! String).to(equal("Subscription Renewal"))
                        expect(journey["outcome"] as! String).to(equal("Cancel - " + Silver))
                        expect(journey["result"] as! String).to(equal("fail"))
                        expect(journey["method"] as! String).to(equal(method))
                    }
                    beforeEach{
                        try! Xenon().subscriptionCanceled(tier: Silver, method: method)
                    }
                }
                describe("when no method") {
                    it("then creates journey with outcome") {
                        let journey = Xenon().journey()[0] as! Dictionary<String, Any>
                        expect(journey["superOutcome"] as! String).to(equal("Subscription Renewal"))
                        expect(journey["outcome"] as! String).to(equal("Cancel - " + Silver))
                        expect(journey["result"] as! String).to(equal("fail"))
                        expect([String](journey.keys)).notTo(contain("method"))
                    }
                    beforeEach{
                        try! Xenon().subscriptionCanceled(tier: Silver)
                    }
                }
            }
            describe("when subscriptionUpsold"){
                let Silver = "Silver Monthly"
                let method = "Stripe" // optional
                describe("when has method"){
                    it("then creates journey with outcome"){
                        let journey = Xenon().journey()[0] as! Dictionary<String, Any>
                        expect(journey["superOutcome"] as! String).to(equal("Subscription Upsold"))
                        expect(journey["outcome"] as! String).to(equal("Upsold - " + Silver))
                        expect(journey["result"] as! String).to(equal("success"))
                        expect(journey["method"] as! String).to(equal(method))
                    }
                    beforeEach{
                        try! Xenon().subscriptionUpsold(tier: Silver, method: method)
                    }
                }
                describe("when no method"){
                    it("then creates journey with outcome"){
                        let journey = Xenon().journey()[0] as! Dictionary<String, Any>
                        expect(journey["superOutcome"] as! String).to(equal("Subscription Upsold"))
                        expect(journey["outcome"] as! String).to(equal("Upsold - " + Silver))
                        expect(journey["result"] as! String).to(equal("success"))
                        expect([String](journey.keys)).notTo(contain("method"))
                    }
                    beforeEach{
                        try! Xenon().subscriptionUpsold(tier: Silver)
                    }
                }
            }
            describe("when subscriptionUpsellDeclined"){
                let Silver = "Silver Monthly"
                let method = "Stripe" // optional
                describe("when has method"){
                    it("then creates journey with outcome"){
                        let journey = Xenon().journey()[0] as! Dictionary<String, Any>
                        expect(journey["superOutcome"] as! String).to(equal("Subscription Upsold"))
                        expect(journey["outcome"] as! String).to(equal("Declined - " + Silver))
                        expect(journey["result"] as! String).to(equal("fail"))
                        expect(journey["method"] as! String).to(equal(method))
                    }
                    beforeEach{
                        try! Xenon().subscriptionUpsellDeclined(tier: Silver, method: method)
                    }
                }
                describe("when no method"){
                    it("then creates journey with outcome"){
                        let journey = Xenon().journey()[0] as! Dictionary<String, Any>
                        expect(journey["superOutcome"] as! String).to(equal("Subscription Upsold"))
                        expect(journey["outcome"] as! String).to(equal("Declined - " + Silver))
                        expect(journey["result"] as! String).to(equal("fail"))
                        expect([String](journey.keys)).notTo(contain("method"))
                    }
                    beforeEach{
                        try! Xenon().subscriptionUpsellDeclined(tier: Silver)
                    }
                }
            }
            describe("when referral"){
                let kind = "Share"
                let detail = "Review" // optional
                describe("when has detail"){
                    it("then creates journey with outcome"){
                        let journey = Xenon().journey()[0] as! Dictionary<String, Any>
                        expect(journey["superOutcome"] as! String).to(equal("Referral"))
                        expect(journey["outcome"] as! String).to(equal("Referred - " + kind))
                        expect(journey["result"] as! String).to(equal("success"))
                        expect(journey["details"] as! String).to(equal(detail))
                    }
                    beforeEach{
                        try! Xenon().referral(kind: kind, detail: detail)
                    }
                }
                describe("when no detail"){
                    it("then creates journey with outcome"){
                        let journey = Xenon().journey()[0] as! Dictionary<String, Any>
                        expect(journey["superOutcome"] as! String).to(equal("Referral"))
                        expect(journey["outcome"] as! String).to(equal("Referred - " + kind))
                        expect(journey["result"] as! String).to(equal("success"))
                        expect([String](journey.keys)).notTo(contain("details"))
                    }
                    beforeEach{
                        try! Xenon().referral(kind: kind)
                    }
                }
            }
            describe("when referralDeclined"){
                let kind = "Share"
                let detail = "Review" // optional
                describe("when has detail"){
                    it("then creates journey with outcome"){
                        let journey = Xenon().journey()[0] as! Dictionary<String, Any>
                        expect(journey["superOutcome"] as! String).to(equal("Referral"))
                        expect(journey["outcome"] as! String).to(equal("Declined - " + kind))
                        expect(journey["result"] as! String).to(equal("fail"))
                        expect(journey["details"] as! String).to(equal(detail))
                    }
                    beforeEach{
                        try! Xenon().referralDeclined(kind: kind, detail: detail)
                    }
                }
                describe("when no detail"){
                    it("then creates journey with outcome"){
                        let journey = Xenon().journey()[0] as! Dictionary<String, Any>
                        expect(journey["superOutcome"] as! String).to(equal("Referral"))
                        expect(journey["outcome"] as! String).to(equal("Declined - " + kind))
                        expect(journey["result"] as! String).to(equal("fail"))
                        expect([String](journey.keys)).notTo(contain("details"))
                    }
                    beforeEach{
                        try! Xenon().referralDeclined(kind: kind)
                    }
                }
            }
            // Ecommerce Related Outcomes tests
            describe("when productAddedToCart") {
                let laptop = "Dell XPS"
                it("then creates journey with outcome") {
                    let journey = Xenon().journey()[0] as! Dictionary<String, Any>
                    expect(journey["superOutcome"] as! String).to(equal("Add Product To Cart"))
                    expect(journey["outcome"] as! String).to(equal("Add - " + laptop))
                    expect(journey["result"] as! String).to(equal("success"))
                }
                beforeEach{
                    try! Xenon().productAddedToCart(product: laptop)
                }
            }
            describe("when productNotAddedToCart") {
                let laptop = "Dell XPS"
                it("then creates journey with outcome") {
                    let journey = Xenon().journey()[0] as! Dictionary<String, Any>
                    expect(journey["superOutcome"] as! String).to(equal("Add Product To Cart"))
                    expect(journey["outcome"] as! String).to(equal("Ignore - " + laptop))
                    expect(journey["result"] as! String).to(equal("fail"))
                }
                beforeEach{
                    try! Xenon().productNotAddedToCart(product: laptop)
                }
            }
            describe("when upsold") {
                let laptop = "Dell XPS"
                it("then creates journey with outcome") {
                    let journey = Xenon().journey()[0] as! Dictionary<String, Any>
                    expect(journey["superOutcome"] as! String).to(equal("Upsold Product"))
                    expect(journey["outcome"] as! String).to(equal("Upsold - " + laptop))
                    expect(journey["result"] as! String).to(equal("success"))
                }
                beforeEach{
                    try! Xenon().upsold(product: laptop)
                }
            }
            describe("when upsellDismissed") {
                let laptop = "Dell XPS"
                it("then creates journey with outcome") {
                    let journey = Xenon().journey()[0] as! Dictionary<String, Any>
                    expect(journey["superOutcome"] as! String).to(equal("Upsold Product"))
                    expect(journey["outcome"] as! String).to(equal("Dismissed - " + laptop))
                    expect(journey["result"] as! String).to(equal("fail"))
                }
                beforeEach{
                    try! Xenon().upsellDismissed(product: laptop)
                }
            }
            describe("when checkedOut"){
                it("then creates journey with outcome"){
                    let journey = Xenon().journey()[0] as! Dictionary<String, Any>
                    expect(journey["superOutcome"] as! String).to(equal("Customer Checkout"))
                    expect(journey["outcome"] as! String).to(equal("Checked Out"))
                    expect(journey["result"] as! String).to(equal("success"))
                }
                beforeEach{
                    try! Xenon().checkedOut()
                }
            }
            describe("when checkoutCanceled"){
                it("then creates journey with outcome"){
                    let journey = Xenon().journey()[0] as! Dictionary<String, Any>
                    expect(journey["superOutcome"] as! String).to(equal("Customer Checkout"))
                    expect(journey["outcome"] as! String).to(equal("Canceled"))
                    expect(journey["result"] as! String).to(equal("fail"))
                }
                beforeEach{
                    try! Xenon().checkoutCanceled()
                }
            }
            describe("when productRemoved"){
                let laptop = "Dell XPS"
                it("then creates journey with outcome"){
                    let journey = Xenon().journey()[0] as! Dictionary<String, Any>
                    expect(journey["superOutcome"] as! String).to(equal("Customer Checkout"))
                    expect(journey["outcome"] as! String).to(equal("Product Removed - " + laptop))
                    expect(journey["result"] as! String).to(equal("fail"))
                }
                beforeEach{
                    try! Xenon().productRemoved(product: laptop)
                }
            }
            describe("when purchased") {
                let method = "Stripe"
                it("then creates journey with outcome") {
                    let journey = Xenon().journey()[0] as! Dictionary<String, Any>
                    expect(journey["superOutcome"] as! String).to(equal("Customer Purchase"))
                    expect(journey["outcome"] as! String).to(equal("Purchase - " + method))
                    expect(journey["result"] as! String).to(equal("success"))
                }
                beforeEach {
                    try! Xenon().purchased(method: method)
                }
            }
            describe("when purchaseCanceled") {
                let method = "Stripe"
                describe("when method") {
                    it("then creates journey with outcome") {
                        let journey = Xenon().journey()[0] as! Dictionary<String, Any>
                        expect(journey["superOutcome"] as! String).to(equal("Customer Purchase"))
                        expect(journey["outcome"] as! String).to(equal("Canceled - " + method))
                        expect(journey["result"] as! String).to(equal("fail"))
                    }
                    beforeEach {
                        try! Xenon().purchaseCanceled(method: method)
                    }
                }
                describe("when without method") {
                    it("then creates journey with outcome") {
                        let journey = Xenon().journey()[0] as! Dictionary<String, Any>
                        expect(journey["superOutcome"] as! String).to(equal("Customer Purchase"))
                        expect(journey["outcome"] as! String).to(equal("Canceled"))
                        expect(journey["result"] as! String).to(equal("fail"))
                    }
                    beforeEach {
                        try! Xenon().purchaseCanceled()
                    }
                }
            }
            describe("when promiseFulfilled") {
                it("then creates journey with outcome") {
                    let journey = Xenon().journey()[0] as! Dictionary<String, Any>
                    expect(journey["superOutcome"] as! String).to(equal("Promise Fulfillment"))
                    expect(journey["outcome"] as! String).to(equal("Fulfilled"))
                    expect(journey["result"] as! String).to(equal("success"))
                }
                beforeEach{
                    try! Xenon().promiseFulfilled()
                }
            }
            describe("when promiseUnfulfilled") {
                it("then creates journey with outcome") {
                    let journey = Xenon().journey()[0] as! Dictionary<String, Any>
                    expect(journey["superOutcome"] as! String).to(equal("Promise Fulfillment"))
                    expect(journey["outcome"] as! String).to(equal("Unfulfilled"))
                    expect(journey["result"] as! String).to(equal("fail"))
                }
                beforeEach{
                    try! Xenon().promiseUnfulfilled()
                }
            }
            describe("when productKept"){
                let laptop = "Dell XPS"
                it("then creates journey with outcome"){
                    let journey = Xenon().journey()[0] as! Dictionary<String, Any>
                    expect(journey["superOutcome"] as! String).to(equal("Product Disposition"))
                    expect(journey["outcome"] as! String).to(equal("Kept - " + laptop))
                    expect(journey["result"] as! String).to(equal("success"))
                }
                beforeEach {
                    try! Xenon().productKept(product: laptop)
                }
            }
            describe("when productReturned"){
                let laptop = "Dell XPS"
                it("then creates journey with outcome"){
                    let journey = Xenon().journey()[0] as! Dictionary<String, Any>
                    expect(journey["superOutcome"] as! String).to(equal("Product Disposition"))
                    expect(journey["outcome"] as! String).to(equal("Returned - " + laptop))
                    expect(journey["result"] as! String).to(equal("fail"))
                }
                beforeEach {
                    try! Xenon().productReturned(product: laptop)
                }
            }
            // Stock Milestones tests
            describe("when featureAttempted"){
                let name = "Scale Recipe"
                let detail = "x2" // optional
                describe("when has detail"){
                    it("then has a milestone"){
                        let journey = Xenon().journey()[0] as! Dictionary<String, Any>
                        expect(journey["category"] as! String).to(equal("Feature"))
                        expect(journey["action"] as! String).to(equal("Attempted"))
                        expect(journey["name"] as! String).to(equal(name))
                        expect(journey["details"] as! String).to(equal(detail))
                    }
                    beforeEach {
                        try! Xenon().featureAttempted(feature: name, detail: detail)
                    }
                }
                describe("when has no detail"){
                    it("then has a milestone"){
                        let journey = Xenon().journey()[0] as! Dictionary<String, Any>
                        expect(journey["category"] as! String).to(equal("Feature"))
                        expect(journey["action"] as! String).to(equal("Attempted"))
                        expect(journey["name"] as! String).to(equal(name))
                        expect([String](journey.keys)).notTo(contain("details"))
                    }
                    beforeEach {
                        try! Xenon().featureAttempted(feature: name)
                    }
                }
            }
            describe("when featureCompleted"){
                let name = "Scale Recipe"
                let detail = "x2" // optional
                describe("when has detail"){
                    it("then has a milestone"){
                        let journey = Xenon().journey()[0] as! Dictionary<String, Any>
                        expect(journey["category"] as! String).to(equal("Feature"))
                        expect(journey["action"] as! String).to(equal("Completed"))
                        expect(journey["name"] as! String).to(equal(name))
                        expect(journey["details"] as! String).to(equal(detail))
                    }
                    beforeEach {
                        try! Xenon().featureCompleted(feature: name, detail: detail)
                    }
                }
                describe("when has no detail"){
                    it("then has a milestone"){
                        let journey = Xenon().journey()[0] as! Dictionary<String, Any>
                        expect(journey["category"] as! String).to(equal("Feature"))
                        expect(journey["action"] as! String).to(equal("Completed"))
                        expect(journey["name"] as! String).to(equal(name))
                        expect([String](journey.keys)).notTo(contain("details"))
                    }
                    beforeEach {
                        try! Xenon().featureCompleted(feature: name)
                    }
                }
            }
            describe("when featureFailed"){
                let name = "Scale Recipe"
                let detail = "x2" // optional
                describe("when has detail"){
                    it("then has a milestone"){
                        let journey = Xenon().journey()[0] as! Dictionary<String, Any>
                        expect(journey["category"] as! String).to(equal("Feature"))
                        expect(journey["action"] as! String).to(equal("Failed"))
                        expect(journey["name"] as! String).to(equal(name))
                        expect(journey["details"] as! String).to(equal(detail))
                    }
                    beforeEach {
                        try! Xenon().featureFailed(feature: name, detail: detail)
                    }
                }
                describe("when has no detail"){
                    it("then has a milestone"){
                        let journey = Xenon().journey()[0] as! Dictionary<String, Any>
                        expect(journey["category"] as! String).to(equal("Feature"))
                        expect(journey["action"] as! String).to(equal("Failed"))
                        expect(journey["name"] as! String).to(equal(name))
                        expect([String](journey.keys)).notTo(contain("details"))
                    }
                    beforeEach {
                        try! Xenon().featureFailed(feature: name)
                    }
                }
            }
            describe("when contentViewed"){
                let contentType = "Blog Post"
                let identifier = "how-to-install-xenon-view" // optional
                describe("when has identifier"){
                    it("then has a milestone"){
                        let journey = Xenon().journey()[0] as! Dictionary<String, Any>
                        expect(journey["category"] as! String).to(equal("Content"))
                        expect(journey["action"] as! String).to(equal("Viewed"))
                        expect(journey["type"] as! String).to(equal(contentType))
                        expect(journey["identifier"] as! String).to(equal(identifier))
                    }
                    beforeEach {
                        try! Xenon().contentViewed(type: contentType, identifier: identifier)
                    }
                }
                describe("when has no identifier"){
                    it("then has a milestone"){
                        let journey = Xenon().journey()[0] as! Dictionary<String, Any>
                        expect(journey["category"] as! String).to(equal("Content"))
                        expect(journey["action"] as! String).to(equal("Viewed"))
                        expect(journey["type"] as! String).to(equal(contentType))
                        expect([String](journey.keys)).notTo(contain("identifier"))
                    }
                    beforeEach {
                        try! Xenon().contentViewed(type: contentType)
                    }
                }
            }
            describe("when contentEdited"){
                let contentType = "Blog Post"
                let identifier = "how-to-install-xenon-view" // optional
                let detail = "Rewrote" //optional
                describe("when has details"){
                    it("then has a milestone"){
                        let journey = Xenon().journey()[0] as! Dictionary<String, Any>
                        expect(journey["category"] as! String).to(equal("Content"))
                        expect(journey["action"] as! String).to(equal("Edited"))
                        expect(journey["type"] as! String).to(equal(contentType))
                        expect(journey["identifier"] as! String).to(equal(identifier))
                        expect(journey["details"] as! String).to(equal(detail))
                    }
                    beforeEach {
                        try! Xenon().contentEdited(type: contentType, identifier: identifier, detail: detail)
                    }
                }
                describe("when has identifier"){
                    it("then has a milestone"){
                        let journey = Xenon().journey()[0] as! Dictionary<String, Any>
                        expect(journey["category"] as! String).to(equal("Content"))
                        expect(journey["action"] as! String).to(equal("Edited"))
                        expect(journey["type"] as! String).to(equal(contentType))
                        expect(journey["identifier"] as! String).to(equal(identifier))
                        expect([String](journey.keys)).notTo(contain("details"))
                    }
                    beforeEach {
                        try! Xenon().contentEdited(type: contentType, identifier: identifier)
                    }
                }
                describe("when has no identifier"){
                    it("then has a milestone"){
                        let journey = Xenon().journey()[0] as! Dictionary<String, Any>
                        expect(journey["category"] as! String).to(equal("Content"))
                        expect(journey["action"] as! String).to(equal("Edited"))
                        expect(journey["type"] as! String).to(equal(contentType))
                        expect([String](journey.keys)).notTo(contain("identifier"))
                        expect([String](journey.keys)).notTo(contain("details"))
                    }
                    beforeEach {
                        try! Xenon().contentEdited(type: contentType)
                    }
                }
            }
            describe("when contentCreated"){
                let contentType = "Blog Post"
                let identifier = "how-to-install-xenon-view" // optional
                describe("when has identifier"){
                    it("then has a milestone"){
                        let journey = Xenon().journey()[0] as! Dictionary<String, Any>
                        expect(journey["category"] as! String).to(equal("Content"))
                        expect(journey["action"] as! String).to(equal("Created"))
                        expect(journey["type"] as! String).to(equal(contentType))
                        expect(journey["identifier"] as! String).to(equal(identifier))
                    }
                    beforeEach {
                        try! Xenon().contentCreated(type: contentType, identifier: identifier)
                    }
                }
                describe("when has no identifier"){
                    it("then has a milestone"){
                        let journey = Xenon().journey()[0] as! Dictionary<String, Any>
                        expect(journey["category"] as! String).to(equal("Content"))
                        expect(journey["action"] as! String).to(equal("Created"))
                        expect(journey["type"] as! String).to(equal(contentType))
                        expect([String](journey.keys)).notTo(contain("identifier"))
                    }
                    beforeEach {
                        try! Xenon().contentCreated(type: contentType)
                    }
                }
            }
            describe("when contentDeleted"){
                let contentType = "Blog Post"
                let identifier = "how-to-install-xenon-view" // optional
                describe("when has identifier"){
                    it("then has a milestone"){
                        let journey = Xenon().journey()[0] as! Dictionary<String, Any>
                        expect(journey["category"] as! String).to(equal("Content"))
                        expect(journey["action"] as! String).to(equal("Deleted"))
                        expect(journey["type"] as! String).to(equal(contentType))
                        expect(journey["identifier"] as! String).to(equal(identifier))
                    }
                    beforeEach {
                        try! Xenon().contentDeleted(type: contentType, identifier: identifier)
                    }
                }
                describe("when has no identifier"){
                    it("then has a milestone"){
                        let journey = Xenon().journey()[0] as! Dictionary<String, Any>
                        expect(journey["category"] as! String).to(equal("Content"))
                        expect(journey["action"] as! String).to(equal("Deleted"))
                        expect(journey["type"] as! String).to(equal(contentType))
                        expect([String](journey.keys)).notTo(contain("identifier"))
                    }
                    beforeEach {
                        try! Xenon().contentDeleted(type: contentType)
                    }
                }
            }
            describe("when contentRequested"){
                let contentType = "Blog Post"
                let identifier = "how-to-install-xenon-view" // optional
                describe("when has identifier"){
                    it("then has a milestone"){
                        let journey = Xenon().journey()[0] as! Dictionary<String, Any>
                        expect(journey["category"] as! String).to(equal("Content"))
                        expect(journey["action"] as! String).to(equal("Requested"))
                        expect(journey["type"] as! String).to(equal(contentType))
                        expect(journey["identifier"] as! String).to(equal(identifier))
                    }
                    beforeEach {
                        try! Xenon().contentRequested(type: contentType, identifier: identifier)
                    }
                }
                describe("when has no identifier"){
                    it("then has a milestone"){
                        let journey = Xenon().journey()[0] as! Dictionary<String, Any>
                        expect(journey["category"] as! String).to(equal("Content"))
                        expect(journey["action"] as! String).to(equal("Requested"))
                        expect(journey["type"] as! String).to(equal(contentType))
                        expect([String](journey.keys)).notTo(contain("identifier"))
                    }
                    beforeEach {
                        try! Xenon().contentRequested(type: contentType)
                    }
                }
            }
            describe("when contentSearched"){
                let contentType = "Blog Post"
                it("then has a milestone"){
                    let journey = Xenon().journey()[0] as! Dictionary<String, Any>
                    expect(journey["category"] as! String).to(equal("Content"))
                    expect(journey["action"] as! String).to(equal("Searched"))
                    expect(journey["type"] as! String).to(equal(contentType))
                }
                beforeEach {
                    try! Xenon().contentSearched(type: contentType)
                }
            }
            // Custom Milestones tests
            describe("when custom milestone"){
                let category = "Function"
                let operation = "Called"
                let name = "Query Database"
                let detail = "User Lookup"
                it("then has a milestone"){
                    let journey = Xenon().journey()[0] as! Dictionary<String, Any>
                    expect(journey["category"] as! String).to(equal(category))
                    expect(journey["action"] as! String).to(equal(operation))
                    expect(journey["name"] as! String).to(equal(name))
                    expect(journey["details"] as! String).to(equal(detail))
                }
                beforeEach {
                    try! Xenon().milestone(category: category, operation: operation, name: name, detail: detail)
                }
            }
            // Internals tests
            describe("when adding duplicate feature"){
                let feature = "duplicate"
                it("then has a journey with a single event"){
                    let journey = Xenon().journey()[0] as! Dictionary<String, Any>
                    expect(journey["count"] as! Int).to(equal(2))
                    expect(Xenon().journey().count).to(equal(1))
                }
                describe("when adding third duplicate"){
                    it("then has a count of 3"){
                        let journey = Xenon().journey()[0] as! Dictionary<String, Any>
                        expect(journey["count"] as! Int).to(equal(3))
                        expect(Xenon().journey().count).to(equal(1))
                    }
                    beforeEach{
                        try! Xenon().featureAttempted(feature: feature)
                    }
                }
                describe("when adding new milestone"){
                    it("then has a count of 2"){
                        let journey = Xenon().journey()[0] as! Dictionary<String, Any>
                        expect(journey["count"] as! Int).to(equal(2))
                        expect(Xenon().journey().count).to(equal(2))
                    }
                    beforeEach{
                        try! Xenon().milestone(category: "category", operation: "operation", name: "name", detail: "detail")
                    }
                }
                beforeEach{
                    try! Xenon().featureAttempted(feature: feature)
                    try! Xenon().featureAttempted(feature: feature)
                }
            }
            describe("when adding duplicate content") {
                let name = "duplicate"
                it("then has a journey with a single event") {
                    let journey = Xenon().journey()[0] as! Dictionary<String, Any>
                    expect(journey["count"] as? Int).to(equal(2))
                    expect(Xenon().journey().count).to(equal(1))
                }
                beforeEach{
                    try! Xenon().contentSearched(type: name)
                    try! Xenon().contentSearched(type: name)
                }
            }
            describe("when adding duplicate content with identifier") {
                let name = "duplicate"
                it("then has a journey with a single event") {
                    let journey = Xenon().journey()[0] as! Dictionary<String, Any>
                    expect(journey["count"] as? Int).to(equal(2))
                    expect(Xenon().journey().count).to(equal(1))
                }
                beforeEach {
                    try! Xenon().contentEdited(type: name, identifier: "identifier")
                    try! Xenon().contentEdited(type: name, identifier: "identifier")
                }
            }
            describe("when adding duplicate content with detail") {
                let name = "duplicate"
                it("then has a journey with a single event") {
                    let journey = Xenon().journey()[0] as! Dictionary<String, Any>
                    expect(journey["count"] as? Int).to(equal(2))
                    expect(Xenon().journey().count).to(equal(1))
                }
                beforeEach {
                    try! Xenon().contentEdited(type: name, identifier: "identifier", detail: "detail")
                    try! Xenon().contentEdited(type: name, identifier: "identifier", detail: "detail")
                }
            }
            describe("when adding duplicate milestone"){
                let category = "Function"
                let operation = "Called"
                let name = "Query Database"
                let detail = "User Lookup"
                it("then has a journey with a single event"){
                    let journey = Xenon().journey()[0] as! Dictionary<String, Any>
                    expect(journey["count"] as? Int).to(equal(2))
                    expect(Xenon().journey().count).to(equal(1))
                }
                beforeEach {
                    try! Xenon().milestone(category: category, operation: operation, name: name, detail: detail)
                    try! Xenon().milestone(category: category, operation: operation, name: name, detail: detail)
                }
            }
            describe("when adding almost duplicate feature"){
                let feature = "almostDup"
                it("then has a journey with a 2 events"){
                    expect(Xenon().journey().count).to(equal(2))
                }
                beforeEach {
                    try! Xenon().featureAttempted(feature: feature)
                    try! Xenon().featureCompleted(feature: feature)
                }
            }
            describe("when adding almost duplicate content"){
                let name = "Scale Recipe"
                it("then has a journey with a 2 events"){
                    expect(Xenon().journey().count).to(equal(2))
                }
                beforeEach {
                    try! Xenon().contentViewed(type: name)
                    try! Xenon().contentSearched(type: name)
                }
            }
            describe("when adding almost duplicate content with identifier") {
                let name = "Scale Recipe"
                it("then has a journey with a 2 events") {
                    expect(Xenon().journey().count).to(equal(2))
                }
                beforeEach{
                    try! Xenon().contentEdited(type: name, identifier: "identifier")
                    try! Xenon().contentEdited(type: name, identifier: "identifier2")
                }
            }
            describe("when adding almost duplicate content with detail") {
                let name = "Scale Recipe"
                it("then has a journey with a 2 events") {
                    expect(Xenon().journey().count).to(equal(2))
                }
                beforeEach{
                    try! Xenon().contentEdited(type: name, identifier: "identifier", detail: "detail")
                    try! Xenon().contentEdited(type: name, identifier: "identifier", detail: "detail2")
                }
            }
            describe("when adding almost duplicate milestone"){
                let category = "Function"
                let operation = "Called"
                let name = "Query Database"
                let detail = "User Lookup"
                it("then has a journey with a single event"){
                    expect(Xenon().journey().count).to(equal(2))
                }
                beforeEach{
                    try! Xenon().milestone(category: category, operation: operation, name: name, detail: detail);
                    try! Xenon().milestone(category: category, operation: operation, name: name, detail: detail+"2");
                }
            }
            describe("when handling other duplicates") {
                var subject: Xenon?
                beforeEach {
                    subject = Xenon()
                }
                describe("when almost duplicate but no categories") {
                    beforeEach {
                        let content = [
                            "random": "Feature",
                        ]
                        try! subject!.journeyAdd(content: content)
                        try! subject!.journeyAdd(content: content)
                    }
                    it("then has two journeys") {
                        expect(Xenon().journey().count).to(equal(2))
                    }
                }
                describe("when almost duplicate but different categories") {
                    beforeEach {
                        try! subject!.journeyAdd(content:  [
                            "category": "1",
                        ])
                        try! subject!.journeyAdd(content:  [
                            "category": "2",
                        ])
                    }
                    it("then has two journeys") {
                        expect(Xenon().journey().count).to(equal(2))
                    }
                }
                describe("when almost duplicate but no actions") {
                    beforeEach {
                        try! subject!.journeyAdd(content:  [
                            "category": "1"
                        ])
                        try! subject!.journeyAdd(content:  [
                            "category": "1"
                        ])
                    }
                    it("then has two journeys") {
                        expect(Xenon().journey().count).to(equal(2))
                    }
                }
                describe("when almost duplicate but different actions") {
                    beforeEach {
                        try! subject!.journeyAdd(content:  [
                            "category": "1",
                            "action": "1",
                        ])
                        try! subject!.journeyAdd(content:  [
                            "category": "1",
                            "action": "2",
                        ])
                    }
                    it("then has two journeys") {
                        expect(Xenon().journey().count).to(equal(2))
                    }
                }
                describe("when almost duplicate content but no type") {
                    beforeEach {
                        try! subject!.journeyAdd(content:  [
                            "category": "Content",
                            "action": "1",
                        ])
                        try! subject!.journeyAdd(content:  [
                            "category": "Content",
                            "action": "1",
                        ])
                    }
                    it("then is duplicate") {
                        expect(Xenon().journey().count).to(equal(1))
                    }
                }
                describe("when almost duplicate content but different types") {
                    beforeEach {
                        try! subject!.journeyAdd(content:  [
                            "category": "Content",
                            "action": "1",
                            "type": "1"
                        ])
                        try! subject!.journeyAdd(content:  [
                            "category": "Content",
                            "action": "1",
                            "type": "2"
                        ])
                    }
                    it("then has two journeys") {
                        expect(Xenon().journey().count).to(equal(2))
                    }
                }
                describe("when Features with different names") {
                    beforeEach {
                        try! subject!.journeyAdd(content:  [
                            "category": "Feature",
                            "action": "1",
                            "name":"1"
                        ])
                        try! subject!.journeyAdd(content:  [
                            "category": "Feature",
                            "action": "1",
                            "name":"2"
                        ])
                    }
                    it("then has two journeys") {
                        expect(Xenon().journey().count).to(equal(2))
                    }
                }
                describe("when custom milestone and names different") {
                    beforeEach {
                        try! subject!.journeyAdd(content:  [
                            "category": "Milestone",
                            "action": "1",
                            "name": "1"
                        ])
                        try! subject!.journeyAdd(content:  [
                            "category": "Milestone",
                            "action": "1",
                            "name": "2"
                        ])
                    }
                    it("then has two journeys") {
                        expect(Xenon().journey().count).to(equal(2))
                    }
                }

            }
            describe("when resetting") {
                var subject: Xenon?
                let feature = "resetting"
                beforeEach {
                    subject = Xenon()
                    try! subject!.featureAttempted(feature: feature)
                    try! subject!.reset()
                }
                describe("when restoring") {
                    beforeEach {
                        try! subject!.restore()
                    }
                    it("then has a journey with added event") {
                        let journey = Xenon().journey()[0] as! Dictionary<String, Any>
                        expect(journey["name"] as! String).to(equal(feature))
                        expect(Xenon().journey().count).to(equal(1))
                    }
                }
                describe("when restoring after another event was added") {
                    beforeEach {
                        try! subject!.featureCompleted(feature: feature)
                        try! subject!.restore()
                    }
                    it("then adds new event at end of previous journey") {
                        let journey = Xenon().journey()[1] as! Dictionary<String, Any>
                        expect(journey["name"] as! String).to(equal(feature))
                        expect(journey["action"] as! String).to(equal("Completed"))
                        expect(Xenon().journey().count).to(equal(2))
                    }
                }
            }
            // API Communication tests
            describe("when committing a journey") {
                var subject: Xenon?
                let name = "committing"
                beforeEach {
                    subject = Xenon(apiKey: apiKey, apiUrl: apiUrl, _journeyApi: journeyApi)
                    try! subject!.featureCompleted(feature: name)
                }
                afterEach {
                    reset(journeyApi)
                }
                describe("when default api key") {
                    beforeEach {
                        given(try! journeyApi.fetch(data: any())).willReturn(Task {
                            ["result": "success"]
                        })

                        let opSubject = subject!
                        let op = TaskOperation(queue: .global(qos: .background)) {
                            try! await opSubject.commit().value
                        }
                        op.start()
                        op.waitUntilFinished()
                    }
                    it("then calls the view journey API") {
                        let fetchArgs = ArgumentCaptor<Dictionary<String, Any>>()
                        verify(try journeyApi.fetch(data: fetchArgs.any())).wasCalled()
                        let params = fetchArgs.value!
                        expect(params["id"] as? String).notTo(equal(""))
                        expect(params["token"] as? String).to(equal(apiKey))
                        expect(params["timestamp"] as? Double).to(beAKindOf(Double.self))
                        let journeys = params["journey"] as! Array<Any>
                        let journey = journeys[0] as! Dictionary<String, Any>
                        expect(journey["category"] as! String).to(equal("Feature"))
                        expect(journey["action"] as! String).to(equal("Completed"))
                        expect(journey["name"] as! String).to(equal(name))

                    }
                    it("then uses correct api url") {
                        verify(journeyApi.with(apiUrl: apiUrl)).wasCalled()
                    }
                    it("then resets journey") {
                        expect(subject!.journey().count).to(equal(0))
                    }
                }
                describe("when custom api key") {
                    let customKey = "<custom>"
                    beforeEach {
                        given(try! journeyApi.fetch(data: any())).willReturn(Task {
                            ["result": "success"]
                        })
                        subject!.initialize(apiKey: customKey)
                        let opSubject = subject!
                        let op = TaskOperation(queue: .global(qos: .background)) {
                            try! await opSubject.commit().value
                        }
                        op.start()
                        op.waitUntilFinished()
                    }
                    it("then calls the view journey API") {
                        let fetchArgs = ArgumentCaptor<Dictionary<String, Any>>()
                        verify(try journeyApi.fetch(data: fetchArgs.any())).wasCalled()
                        let params = fetchArgs.value!
                        expect(params["token"] as? String).to(equal(customKey))
                    }
                }
                describe("when custom api url") {
                    let customUrl = "<custom url>"
                    beforeEach {
                        given(try! journeyApi.fetch(data: any())).willReturn(Task {
                            ["result": "success"]
                        })
                        subject!.initialize(apiKey: "", apiUrl: customUrl)
                        let opSubject = subject!
                        let op = TaskOperation(queue: .global(qos: .background)) {
                            try! await opSubject.commit().value
                        }
                        op.start()
                        op.waitUntilFinished()
                    }
                    it("then uses correct api url") {
                        verify(journeyApi.with(apiUrl: customUrl)).wasCalled()
                    }
                }
                describe("when API fails") {
                    let result = ["Error": "Failed"]

                    class OpResult {
                        static var opResult_ = ""
                        func set(result: String) {
                            OpResult.opResult_ = result
                        }
                        func get() -> String {
                            OpResult.opResult_
                        }
                    }

                    let opResult = OpResult()

                    beforeEach {
                        given(try! journeyApi.fetch(data: any())).willReturn(Task {
                            throw result.description
                        })
                        let opSubject = subject!
                        let op = TaskOperation(queue: .global(qos: .background)) {
                            do {
                                _ = try await opSubject.commit().value
                            } catch {
                                opResult.set(result: error as! String)
                            }
                        }
                        op.start()
                        op.waitUntilFinished()
                    }
                    it("then has correct error text") {
                        expect(opResult.get()).to(equal("[\"Error\": \"Failed\"]"))
                    }
                    it("then restores journey") {
                        let journey = subject!.journey()[0] as! Dictionary<String, Any>
                        expect(journey["category"] as! String).to(equal("Feature"))
                        expect(journey["action"] as! String).to(equal("Completed"))
                        expect(journey["name"] as! String).to(equal(name))
                    }
                }
            }
            describe("when heartbeating") {
                var subject: Xenon?
                let name = "heartbeating"
                beforeEach {
                    subject = Xenon(apiKey: apiKey, apiUrl: apiUrl, _journeyApi: journeyApi, _deanonApi: deanonApi, _heartbeatApi: heartbeatApi)
                    try! subject!.featureCompleted(feature: name)
                }
                afterEach {
                    reset(heartbeatApi)
                }
                describe("when default api key") {
                    beforeEach {
                        given(try! heartbeatApi.fetch(data: any())).willReturn(Task {
                            ["result": "success"]
                        })

                        let opSubject = subject!
                        let op = TaskOperation(queue: .global(qos: .background)) {
                            try! await opSubject.heartbeat().value
                        }
                        op.start()
                        op.waitUntilFinished()
                    }
                    it("then calls the view heartbeat API") {
                        let fetchArgs = ArgumentCaptor<Dictionary<String, Any>>()
                        verify(try heartbeatApi.fetch(data: fetchArgs.any())).wasCalled()
                        let params = fetchArgs.value!
                        expect(params["id"] as? String).notTo(equal(""))
                        expect(params["token"] as? String).to(equal(apiKey))
                        expect(params["timestamp"] as? Double).to(beAKindOf(Double.self))
                        let journeys = params["journey"] as! Array<Any>
                        let journey = journeys[0] as! Dictionary<String, Any>
                        expect(journey["category"] as! String).to(equal("Feature"))
                        expect(journey["action"] as! String).to(equal("Completed"))
                        expect(journey["name"] as! String).to(equal(name))

                    }
                    it("then uses correct api url") {
                        verify(heartbeatApi.with(apiUrl: apiUrl)).wasCalled()
                    }
                    it("then resets journey") {
                        expect(subject!.journey().count).to(equal(0))
                    }
                }
                describe("when custom api key") {
                    let customKey = "<custom>"
                    beforeEach {
                        given(try! heartbeatApi.fetch(data: any())).willReturn(Task {
                            ["result": "success"]
                        })
                        subject!.initialize(apiKey: customKey)
                        let opSubject = subject!
                        let op = TaskOperation(queue: .global(qos: .background)) {
                            try! await opSubject.heartbeat().value
                        }
                        op.start()
                        op.waitUntilFinished()
                    }
                    it("then calls the view heartbeat API") {
                        let fetchArgs = ArgumentCaptor<Dictionary<String, Any>>()
                        verify(try heartbeatApi.fetch(data: fetchArgs.any())).wasCalled()
                        let params = fetchArgs.value!
                        expect(params["token"] as? String).to(equal(customKey))
                    }
                }
                describe("when custom api url") {
                    let customUrl = "<custom url>"
                    beforeEach {
                        given(try! heartbeatApi.fetch(data: any())).willReturn(Task {
                            ["result": "success"]
                        })
                        subject!.initialize(apiKey: "", apiUrl: customUrl)
                        let opSubject = subject!
                        let op = TaskOperation(queue: .global(qos: .background)) {
                            try! await opSubject.heartbeat().value
                        }
                        op.start()
                        op.waitUntilFinished()
                    }
                    it("then uses correct api url") {
                        verify(heartbeatApi.with(apiUrl: customUrl)).wasCalled()
                    }
                }
                describe("when API fails") {
                    let result = ["Error": "Failed"]

                    class OpResult {
                        static var opResult_ = ""
                        func set(result: String) {
                            OpResult.opResult_ = result
                        }
                        func get() -> String {
                            OpResult.opResult_
                        }
                    }

                    let opResult = OpResult()

                    beforeEach {
                        given(try! heartbeatApi.fetch(data: any())).willReturn(Task {
                            throw result.description
                        })
                        let opSubject = subject!
                        let op = TaskOperation(queue: .global(qos: .background)) {
                            do {
                                _ = try await opSubject.heartbeat().value
                            } catch {
                                opResult.set(result: error as! String)
                            }
                        }
                        op.start()
                        op.waitUntilFinished()
                    }
                    it("then has correct error text") {
                        expect(opResult.get()).to(equal("[\"Error\": \"Failed\"]"))
                    }
                    it("then restores journey") {
                        let journey = subject!.journey()[0] as! Dictionary<String, Any>
                        expect(journey["category"] as! String).to(equal("Feature"))
                        expect(journey["action"] as! String).to(equal("Completed"))
                        expect(journey["name"] as! String).to(equal(name))
                    }
                }
            }
            describe("when deanonymizing"){
                var subject: Xenon?
                let person = [
                    "name": "Test User",
                    "email": "test@example.com"
                ]
                beforeEach {
                    subject = Xenon(apiKey: apiKey, apiUrl: apiUrl, _journeyApi: journeyApi, _deanonApi: deanonApi)
                }
                afterEach {
                    reset(deanonApi)
                }
                describe("when default"){
                    beforeEach{
                        given(try! deanonApi.fetch(data: any())).willReturn(Task {
                            ["result": "success"]
                        })

                        let opSubject = subject!
                        let op = TaskOperation(queue: .global(qos: .background)) {
                            try! await opSubject.deanonymize(person: person).value
                        }
                        op.start()
                        op.waitUntilFinished()
                    }

                    it("then calls the view deanon API") {
                        let fetchArgs = ArgumentCaptor<Dictionary<String, Any>>()
                        verify(try deanonApi.fetch(data: fetchArgs.any())).wasCalled()
                        let params = fetchArgs.value!
                        expect(params["id"] as? String).notTo(equal(""))
                        expect(params["token"] as? String).to(equal(apiKey))
                        expect(params["timestamp"] as? Double).to(beAKindOf(Double.self))
                        let observedPerson = params["person"] as! Dictionary<String, String>
                        expect(observedPerson).to(equal(person))
                    }
                }
                describe("when custom api key"){
                    let customKey = "<custom>"
                    beforeEach{
                        given(try! deanonApi.fetch(data: any())).willReturn(Task {
                            ["result": "success"]
                        })
                        subject!.initialize(apiKey: customKey)
                        let opSubject = subject!
                        let op = TaskOperation(queue: .global(qos: .background)) {
                            try! await opSubject.deanonymize(person: person).value
                        }
                        op.start()
                        op.waitUntilFinished()
                    }
                    it("then calls the view deanon API"){
                        let fetchArgs = ArgumentCaptor<Dictionary<String, Any>>()
                        verify(try deanonApi.fetch(data: fetchArgs.any())).wasCalled()
                        let params = fetchArgs.value!
                        expect(params["token"] as? String).to(equal(customKey))
                    }
                }
                describe("when custom api url"){
                    let customUrl = "<custom url>"
                    beforeEach{
                        given(try! deanonApi.fetch(data: any())).willReturn(Task {
                            ["result": "success"]
                        })
                        subject!.initialize(apiKey: "", apiUrl: customUrl)
                        let opSubject = subject!
                        let op = TaskOperation(queue: .global(qos: .background)) {
                            try! await opSubject.deanonymize(person: person).value
                        }
                        op.start()
                        op.waitUntilFinished()
                    }
                    it("then uses correct api url") {
                        verify(deanonApi.with(apiUrl: customUrl)).wasCalled()
                    }
                }
                describe("when API fails"){
                    let result = ["Error": "Failed"]

                    class OpResult {
                        static var opResult_ = ""
                        func set(result: String) {
                            OpResult.opResult_ = result
                        }
                        func get() -> String {
                            OpResult.opResult_
                        }
                    }

                    let opResult = OpResult()

                    beforeEach{
                        given(try! deanonApi.fetch(data: any())).willReturn(Task {
                            throw result.description
                        })
                        let opSubject = subject!
                        let op = TaskOperation(queue: .global(qos: .background)) {
                            do {
                                _ = try await opSubject.deanonymize(person: person).value
                            } catch {
                                opResult.set(result: error as! String)
                            }
                        }
                        op.start()
                        op.waitUntilFinished()
                    }
                    it("then has correct error text") {
                        expect(opResult.get()).to(equal("[\"Error\": \"Failed\"]"))
                    }
                }
            }
        }
    }
}
