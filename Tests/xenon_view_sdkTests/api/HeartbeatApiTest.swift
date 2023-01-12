//
// Created by Woydziak, Luke on 9/26/22.
//

import Foundation
import Quick
import Nimble
import Mockingbird
@testable import xenon_view_sdk


final class HeartbeatApiTests: QuickSpec {
    override func spec() {
        describe("HeartbeatApi") {
            let apiUrl = "https://app.xenonview.com"
            let JsonFetcher = mock(Fetchable.self)
            let dataWithoutJourney: Dictionary<String, Any> = [
                "id": "somevalue",
                "token": "<testToken>",
                "timestamp": 0.1,
                "tags":[],
                "platform": [:]
            ]
            let dataWithoutJourneyWithTagAndPlatform: Dictionary<String, Any> = [
                "id": "somevalue",
                "token": "<testToken>",
                "timestamp": 0.1,
                "tags":["tag"],
                "platform": ["os":"ios"]
            ]
            let journeyData = ["step"]
            let dataWithJourney: Dictionary<String, Any> = [
                "id": "somevalue",
                "token": "<testToken>",
                "timestamp": 0.1,
                "journey": journeyData,
                "tags":[],
                "platform": [:]
            ]
            beforeEach {
                clearInvocations(on: JsonFetcher)
                given(try! JsonFetcher.fetch(data: any())).willReturn(Task {
                    [:]
                })
            }
            it("can be default constructed") {
                expect(HeartbeatApi()).notTo(beNil())
            }
            describe("when parameters do not include Journey") {
                beforeEach {
                    _ = try! HeartbeatApi(fetcher_: JsonFetcher).fetch(data: dataWithoutJourney)
                }
                it("then requests Heartbeat Api") {
                    let fetchArgs = ArgumentCaptor<Dictionary<String, Any>>()
                    verify(try JsonFetcher.fetch(data: fetchArgs.any())).wasCalled()
                    let params = fetchArgs.value!
                    expect(params["method"] as? String).to(equal("POST"))
                    expect(params["url"] as? String).to(equal(apiUrl + "/heartbeat"))
                    let body: Dictionary<String, Any> = params["body"] as! Dictionary<String, Any>
                    expect(body["name"] as? String).to(equal("ApiHeartbeat"))
                    let headers: Dictionary<String, String> = params["headers"] as! Dictionary<String, String>
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
                    expect(parameters["journey"]).to(beNil())
                    expect((parameters["platform"] as! Dictionary<String, Any>).description).to(equal("[:]"))
                    expect((parameters["tags"] as! Array<Any>).description).to(equal("[]"))
                }
            }
            describe("when parameters include Journey") {
                beforeEach {
                    _ = try! HeartbeatApi(fetcher_: JsonFetcher).fetch(data: dataWithJourney)
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
                    expect((parameters["platform"] as! Dictionary<String, Any>).description).to(equal("[:]"))
                    expect((parameters["tags"] as! Array<Any>).description).to(equal("[]"))
                }
            }
            describe("when parameters include tags and platform") {
                beforeEach {
                    _ = try! HeartbeatApi(fetcher_: JsonFetcher).fetch(data: dataWithoutJourneyWithTagAndPlatform)
                }
                it("then creates parameters with tags and platform") {
                    let fetchArgs = ArgumentCaptor<Dictionary<String, Any>>()
                    verify(try JsonFetcher.fetch(data: fetchArgs.any())).wasCalled()
                    let params = fetchArgs.value!
                    let body: Dictionary<String, Any> = params["body"] as! Dictionary<String, Any>
                    let parameters: Dictionary<String, Any> = body["parameters"] as! Dictionary<String, Any>
                    expect((parameters["platform"] as! Dictionary<String, Any>).description).to(equal("[\"os\": \"ios\"]"))
                    expect((parameters["tags"] as! Array<Any>).description).to(equal("[\"tag\"]"))
                }
            }
        }
    }
}
