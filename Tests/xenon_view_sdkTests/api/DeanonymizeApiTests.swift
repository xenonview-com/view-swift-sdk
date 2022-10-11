//
// Created by Woydziak, Luke on 9/27/22.
//

import Foundation
import Quick
import Nimble
import Mockingbird
@testable import xenon_view_sdk


final class DeanonymizeApiTest: QuickSpec {
    override func spec() {
        describe("DeanonymizeApi") {
            let apiUrl = "https://app.xenonview.com"
            let JsonFetcher = mock(Fetchable.self)
            let dataWithoutPerson: Dictionary<String, Any> = [
                "id": "somevalue",
                "token": "<testToken>",
                "timestamp": 0.1
            ]
            let personData = [
                "name": "Test Name",
                "email": "test@example.com"
            ]
            let dataWithPerson: Dictionary<String, Any> = [
                "id": "somevalue",
                "token": "<testToken>",
                "timestamp": 0.1,
                "person": personData
            ]
            beforeEach {
                clearInvocations(on: JsonFetcher)
                given(try! JsonFetcher.fetch(data: any())).willReturn(Task {
                    [:]
                })
            }
            it("can be default constructed") {
                expect(DeanonymizeApi()).notTo(beNil())
            }
            describe("when parameters do not include person") {
                var caught: String = ""
                beforeEach {
                    do {
                        _ = try DeanonymizeApi(fetcher_: JsonFetcher).fetch(data: dataWithoutPerson)
                    } catch DeanonymizeApi.Errors.parameterError(let reason) {
                        caught = reason
                    } catch {
                        print (error)
                    }
                }
                it("then throws") {
                    expect(caught).to(equal("No person data received."))
                }
            }
            describe("when parameters include person") {
                beforeEach {
                    _ = try! DeanonymizeApi(fetcher_: JsonFetcher).fetch(data: dataWithPerson)
                }
                it("then requests deanonymize") {
                    let fetchArgs = ArgumentCaptor<Dictionary<String, Any>>()
                    verify(try JsonFetcher.fetch(data: fetchArgs.any())).wasCalled()
                    let params = fetchArgs.value!
                    expect(params["method"] as? String).to(equal("POST"))
                    expect(params["url"] as? String).to(equal(apiUrl + "/deanonymize"))
                    let body: Dictionary<String, Any> = params["body"] as! Dictionary<String, Any>
                    expect(body["name"] as? String).to(equal("ApiDeanonymize"))
                    let headers: Dictionary<String, String> = params["headers"] as! Dictionary<String, String>
                    expect(headers["content-type"]).to(equal("application/json"))
                    expect(headers["authorization"]).to(equal("Bearer <testToken>"))
                }
                it("then creates parameters with person") {
                    let fetchArgs = ArgumentCaptor<Dictionary<String, Any>>()
                    verify(try JsonFetcher.fetch(data: fetchArgs.any())).wasCalled()
                    let params = fetchArgs.value!
                    let body: Dictionary<String, Any> = params["body"] as! Dictionary<String, Any>
                    let parameters: Dictionary<String, Any> = body["parameters"] as! Dictionary<String, Any>
                    expect(parameters["uuid"] as? String).to(equal("somevalue"))
                    expect(parameters["timestamp"] as? Double).to(equal(0.1))
                    expect(parameters["person"] as? Dictionary<String, String>).to(equal(personData))
                }
            }
        }
    }
}
