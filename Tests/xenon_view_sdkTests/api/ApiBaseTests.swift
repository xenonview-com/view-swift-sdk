//
// Created by Woydziak, Luke on 9/26/22.
//

import Foundation
import Quick
import Nimble
import Mockingbird
import xenon_view_sdk


final class ApiBaseTests: QuickSpec {
    override func spec() {
        describe("ApiBase") {
            let apiUrl = "https://app.xenonview.com"
            let JsonFetcher = mock(Fetchable.self)
            var props: Dictionary<String, Any> = [:]
            beforeEach {
                clearInvocations(on: JsonFetcher)
                given(try! JsonFetcher.fetch(data: any())).willReturn(Task {
                    [:]
                })
                props = [:]
            }
            describe("when calling fetch with default api") {
                beforeEach {
                    props["apiUrl"] = apiUrl
                    _ = try! ApiBase(props: props, fetcher_: JsonFetcher).fetch(data: [:])
                }
                it("requests base url") {
                    let fetchArgs = ArgumentCaptor<Dictionary<String, Any>>()
                    verify(try JsonFetcher.fetch(data: fetchArgs.any())).wasCalled()
                    let params = fetchArgs.value!
                    expect(params["method"] as? String).to(equal("POST"))
                    expect(params["url"] as? String).to(equal(apiUrl + "/"))
                    let body: Dictionary<String, Any> = params["body"] as! Dictionary<String, Any>
                    expect(body["name"] as? String).to(equal("ApiBase"))
                    expect((body["parameters"] as! Dictionary<String, String>)).to(equal([:]))
                    let headers: Dictionary<String, String> = params["requestHeaders"] as! Dictionary<String, String>
                    expect(headers["content-type"]).to(equal("application/json"))
                }
            }
            describe("when calling fetch with default api and ignoring self signed certs") {
                beforeEach {
                    props["apiUrl"] = apiUrl
                    _ = try! ApiBase(props: props, fetcher_: JsonFetcher).fetch(data: ["ignore-certificate-errors": true])
                }
                it("requests base url and ignores self signed certs") {
                    let fetchArgs = ArgumentCaptor<Dictionary<String, Any>>()
                    verify(try JsonFetcher.fetch(data: fetchArgs.any())).wasCalled()
                    let params = fetchArgs.value!
                    expect(params["ignore-certificate-errors"] as? Bool).to(beTrue())
                }
            }
            describe("when calling fetch with api parameters") {
                beforeEach {
                    props["apiUrl"] = apiUrl
                    props["name"] = "name"
                    props["method"] = "OPTIONS"
                    props["url"] = "url"
                    let headers = [
                        "header": "header",
                        "content-type": "application/json"
                    ]
                    props["headers"] = headers
                    _ = try! ApiBase(props: props, fetcher_: JsonFetcher).fetch(data: [:])
                }
                it("requests custom url") {
                    let fetchArgs = ArgumentCaptor<Dictionary<String, Any>>()
                    verify(try JsonFetcher.fetch(data: fetchArgs.any())).wasCalled()
                    let params = fetchArgs.value!
                    expect(params["method"] as? String).to(equal("OPTIONS"))
                    expect(params["url"] as? String).to(equal(apiUrl + "/url"))
                    let body: Dictionary<String, Any> = params["body"] as! Dictionary<String, Any>
                    expect(body["name"] as? String).to(equal("name"))
                    let headers: Dictionary<String, String> = params["requestHeaders"] as! Dictionary<String, String>
                    expect(headers["content-type"]).to(equal("application/json"))
                    expect(headers["header"]).to(equal("header"))
                }
            }
            describe("when calling fetch with authentication") {
                beforeEach {
                    props["authenticated"] = true
                }
                describe("when token") {
                    beforeEach {
                        _ = try! ApiBase(props: props, fetcher_: JsonFetcher).fetch(data: ["token": "<anAccessToken>"])
                    }
                    it("requests url") {
                        let fetchArgs = ArgumentCaptor<Dictionary<String, Any>>()
                        verify(try JsonFetcher.fetch(data: fetchArgs.any())).wasCalled()
                        let params = fetchArgs.value!
                        let headers: Dictionary<String, String> = params["requestHeaders"] as! Dictionary<String, String>
                        expect(headers["content-type"]).to(equal("application/json"))
                        expect(headers["authorization"]).to(equal("Bearer <anAccessToken>"))
                    }
                }
                describe("when no token") {
                    var caught: String = ""
                    beforeEach {
                        do {
                            _ = try ApiBase(props: props, fetcher_: JsonFetcher).fetch(data: [:])
                        } catch ApiBase.Errors.authenticationTokenError(let reason) {
                            caught = reason
                        } catch {
                            print (error)
                        }
                    }
                    it("throws") {
                      expect(caught).to(equal("No token and authenticated!"))
                    }
                }
                describe("when blank token") {
                    var caught: String = ""
                    beforeEach {
                        do {
                            _ = try ApiBase(props: props, fetcher_: JsonFetcher).fetch(data: ["token":""])
                        } catch ApiBase.Errors.authenticationTokenError(let reason) {
                            caught = reason
                        } catch {
                            print (error)
                        }
                    }
                    it("throws") {
                      expect(caught).to(equal("No token and authenticated!"))
                    }
                }
            }
            describe("when calling fetch with no body and get method") {
                beforeEach {
                    props["skipName"] = true
                    props["method"] = "GET"
                    let headers = [:]
                    props["headers"] = headers
                    _ = try! ApiBase(props: props, fetcher_: JsonFetcher).fetch(data: ["token": "<anAccessToken>"])
                }
                it("requests url") {
                    let fetchArgs = ArgumentCaptor<Dictionary<String, Any>>()
                    verify(try JsonFetcher.fetch(data: fetchArgs.any())).wasCalled()
                    let params = fetchArgs.value!
                    expect(params["method"] as? String).to(equal("GET"))
                    let headers: Dictionary<String, String> = params["requestHeaders"] as! Dictionary<String, String>
                    expect(headers["content-type"]).to(beNil())
                }
            }
            describe("when calling fetch with custom host") {
                beforeEach {
                    props["apiUrl"] = "https://example.com"
                    _ = try! ApiBase(props: props, fetcher_: JsonFetcher).fetch(data: [:])
                }
                it("requests url") {
                    let fetchArgs = ArgumentCaptor<Dictionary<String, Any>>()
                    verify(try JsonFetcher.fetch(data: fetchArgs.any())).wasCalled()
                    let params = fetchArgs.value!
                    expect(params["url"] as? String).to(equal("https://example.com/"))
                }
            }
            describe("when calling fetch with no name") {
                beforeEach {
                    class TestApi : ApiBase {
                        convenience init(fetcher_: Fetchable) {
                            self.init(props:["skipName": true], fetcher_: fetcher_)
                        }
                        override func params(data: Dictionary<String, Any>) throws -> Dictionary<String, Any> { ["hello":"world"] }
                    }
                    _ = try! TestApi(fetcher_: JsonFetcher).fetch(data: ["test":"value"])
                }
                it("requests url") {
                    let fetchArgs = ArgumentCaptor<Dictionary<String, Any>>()
                    verify(try JsonFetcher.fetch(data: fetchArgs.any())).wasCalled()
                    let params = fetchArgs.value!
                    let body: Dictionary<String, Any> = params["body"] as! Dictionary<String, Any>
                    expect(body["name"] as? String).to(beNil())
                    let parameters: Dictionary<String, String> = body["parameters"] as! Dictionary<String, String>
                    expect(parameters["hello"]).to(equal("world"))
                    expect(parameters["test"]).to(beNil())
                }

            }
            describe("when calling fetch and params throws error") {
                var caught: String = ""
                beforeEach {
                    class TestApi : ApiBase {
                        convenience init(fetcher_: Fetchable) {
                            self.init(props:[:], fetcher_: fetcher_)
                        }
                        override func params(data: Dictionary<String, Any>) throws -> Dictionary<String, Any> { throw "This is a test" }
                    }
                    do {
                        _ = try TestApi(fetcher_: JsonFetcher).fetch(data: ["test": "value"])
                    }catch{
                        caught = error as! String
                    }
                }
                it("then throws") {
                    expect(caught).to(equal("This is a test"))
                }

            }
            describe("when ") {
              
            }
        }
    }
}
