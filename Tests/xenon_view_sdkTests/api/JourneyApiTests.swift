//
// Created by Woydziak, Luke on 9/26/22.
//

import Foundation
import Quick
import Nimble
import Mockingbird
import xenon_view_sdk


final class JourneyApiTests: QuickSpec {
    override func spec() {
        describe("JourneyApi") {
            let apiUrl = "https://app.xenonview.com"
            let JsonFetcher = mock(Fetchable.self)
            let dataWithoutJourney: Dictionary<String, Any> = [
                "id": "somevalue",
                "token": "<testToken>",
                "timestamp": 0.1
            ]
            let journeyData = ["step"]
            let dataWithJourney: Dictionary<String, Any> = [
                "id": "somevalue",
                "token": "<testToken>",
                "timestamp": 0.1,
                "journey": journeyData
            ]
            beforeEach {
                clearInvocations(on: JsonFetcher)
                given(try! JsonFetcher.fetch(data: any())).willReturn(Task {
                    [:]
                })
            }
            it("can be default constructed") {
                expect(JourneyApi(apiUrl: apiUrl)).notTo(beNil())
            }
            describe("when parameters do not include Journey") {
                beforeEach {
                    _ = try! JourneyApi(apiUrl: apiUrl, fetcher_: JsonFetcher).fetch(data: dataWithoutJourney)
                }
                it("then requests Journey Api") {
                    let fetchArgs = ArgumentCaptor<Dictionary<String, Any>>()
                    verify(try JsonFetcher.fetch(data: fetchArgs.any())).wasCalled()
                    let params = fetchArgs.value!
                    expect(params["method"] as? String).to(equal("POST"))
                    expect(params["url"] as? String).to(equal(apiUrl + "/journey"))
                    let body: Dictionary<String, Any> = params["body"] as! Dictionary<String, Any>
                    expect(body["name"] as? String).to(equal("ApiJourney"))
                    let headers: Dictionary<String, String> = params["requestHeaders"] as! Dictionary<String, String>
                    expect(headers["content-type"]).to(equal("application/json"))
                    expect(headers["authorization"]).to(equal("Bearer <testToken>"))
                }
                it("then creates parameters without journey") {
                    let fetchArgs = ArgumentCaptor<Dictionary<String, Any>>()
                    verify(try JsonFetcher.fetch(data: fetchArgs.any())).wasCalled()
                    let params = fetchArgs.value!
                    let body: Dictionary<String, Any> = params["body"] as! Dictionary<String, Any>
                    let parameters: Dictionary<String, Any> = body["parameters"] as! Dictionary<String, Any>
                    expect(parameters["uuid"] as? String).to(equal("somevalue"))
                    expect(parameters["timestamp"] as? Double).to(equal(0.1))
                }
            }
            describe("when parameters include Journey") {
                beforeEach {
                    _ = try! JourneyApi(apiUrl: apiUrl, fetcher_: JsonFetcher).fetch(data: dataWithJourney)
                }
                it("then creates parameters with journey") {
                    let fetchArgs = ArgumentCaptor<Dictionary<String, Any>>()
                    verify(try JsonFetcher.fetch(data: fetchArgs.any())).wasCalled()
                    let params = fetchArgs.value!
                    let body: Dictionary<String, Any> = params["body"] as! Dictionary<String, Any>
                    let parameters: Dictionary<String, Any> = body["parameters"] as! Dictionary<String, Any>
                    expect(parameters["uuid"] as? String).to(equal("somevalue"))
                    expect(parameters["timestamp"] as? Double).to(equal(0.1))
                    expect(parameters["journey"] as? Array).to(equal(journeyData))
                }
            }
        }
    }
}
