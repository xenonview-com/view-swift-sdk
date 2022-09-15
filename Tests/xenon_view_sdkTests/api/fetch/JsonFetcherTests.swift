//
// Created by Woydziak, Luke on 9/12/22.
//

import Quick
import Nimble
import Mockingbird
import xenon_view_sdk

extension String: Error {}

final class JsonFetcherTests: XCTestCase {
//describe("JsonFetcher")
    var client = mock(JsonFetcherClient.self)
    var data: Dictionary<String, Any> = [:]
    var returned: Dictionary<String, Any> = [:]
    var caught: String = ""
    let expected: Dictionary<String, String> = ["result": "success"]
    func beforeEachTop() {
        data = ["url": "https://example.blah/"]
    }
    func afterEachTop() {
        data = [:]
        returned = [:]
        client = mock(JsonFetcherClient.self)
        caught = ""
    }
    func testJsonFetcherCanBeConstructed() {
        beforeEachTop()
        expect(JsonFetcher()).notTo(beNil())
        afterEachTop()
    }
    //describe("when no url") {
    func beforeEachWhenNoUrl() async throws {
        beforeEachTop()
        data["url"] = ""
        do {
            let _ = try await JsonFetcher(client_: client).fetch(data: data).value
        } catch JsonFetcher.Errors.clientUrlIncorrect(let reason){
            caught = reason
        }
    }
    func testWhenNoUrlThenThrows() async throws {
        try await beforeEachWhenNoUrl()

        expect(self.caught).to(equal(""))

        afterEachTop()
    }
    //describe("when default fetch") {
    func beforeEachWhenDefaultFetch() async throws {
        beforeEachTop()
        data["method"] =  "GET"
    }
    func justBeforeEachWhenDefaultFetch() async throws {
        try await beforeEachWhenDefaultFetch()
        given(try await client.data(for: any(), delegate: nil)).willReturn((Data(), URLResponse()))
        let _ = try? await JsonFetcher(client_: client).fetch(data: data).value
    }
    func testWhenDefaultFetchThenRequestsBaseUrl() async throws {
        try await justBeforeEachWhenDefaultFetch()

        let request = ArgumentCaptor<URLRequest>()
        verify(try await client.data(for: request.any(), delegate: nil)).wasCalled()
        expect(request.value!.url).to(equal(URL(string: data["url"] as! String)!))

        afterEachTop()
    }
        //describe("when the request is successful") {
    func beforeEachWhenTheRequestIsSuccessful() async throws {
        try await beforeEachWhenDefaultFetch()
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let responseData = try encoder.encode(expected)
        let urlString: String = data["url"] as! String
        let url: URL = URL(string: urlString)!
        let response: URLResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "1.1", headerFields: [:])!
        given(try await client.data(for: any(), delegate: nil)).willReturn((responseData, response))
        returned = try await JsonFetcher(client_: client).fetch(data: data).value
    }
    func testWhenDefaultFetchWhenTheRequestIsSuccessfulThenResolvesTheTaskWithJsonResponse() async throws {
        try await beforeEachWhenTheRequestIsSuccessful()

        expect((self.returned as! Dictionary<String, String>)).to(equal(expected))

        afterEachTop()
    }
        //describe("when the request is successful with bad JSON") {
    func beforeEachWhenTheRequestIsSuccessfulWithBadJson() async throws {
        try await beforeEachWhenDefaultFetch()
        let responseData: Data = "garbage".data(using: .utf8)!
        print("here")
        let urlString: String = data["url"] as! String
        let url: URL = URL(string: urlString)!
        let response: URLResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "1.1", headerFields: [:])!
        given(try await client.data(for: any(), delegate: nil)).willReturn((responseData, response))
        do {
            let _ = try await JsonFetcher(client_: client).fetch(data: data).value
        } catch JsonFetcher.Errors.serverInvalidJson(let description, _){
            caught = description
        }
    }
    func testWhenDefaultFetchWhenTheRequestIsSuccessfulWithBadJsonThenResolvesTheTaskWithJsonResponse() async throws {
        try await beforeEachWhenTheRequestIsSuccessfulWithBadJson()

        expect(self.caught).to(equal("Server returned non-JSON response."))

        afterEachTop()
    }
        //describe("when the request is not successful") {
    func beforeEachWhenTheRequestIsNotSuccessful() async throws     {
        try await beforeEachWhenDefaultFetch()
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let responseData = try encoder.encode(["error_message": "The server responded with an error."])
        let urlString: String = data["url"] as! String
        let url: URL = URL(string: urlString)!
        let response: URLResponse = HTTPURLResponse(url: url, statusCode: 400, httpVersion: "1.1", headerFields: [:])!
        given(try await client.data(for: any(), delegate: nil)).willReturn((responseData, response))
        do {
            let _ = try await JsonFetcher(client_: client).fetch(data: data).value
        } catch JsonFetcher.Errors.serverRejectedError(let description, _, _){
            caught = description
        }
    }
    func testWhenDefaultFetchWhenTheRequestIsNotSuccessfulThenRejectsTheTaskWithError() async throws {
        try await beforeEachWhenTheRequestIsNotSuccessful()

        expect(self.caught).to(equal("The server responded with an error."))

        afterEachTop()
    }
        //describe("when the request has no data") {
    func beforeEachWhenTheRequestHasNoData() async throws {
        try await beforeEachWhenDefaultFetch()
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let urlString: String = data["url"] as! String
        let url: URL = URL(string: urlString)!
        let response: URLResponse = HTTPURLResponse(url: url, statusCode: 204, httpVersion: "1.1", headerFields: [:])!
        given(try await client.data(for: any(), delegate: nil)).willReturn((Data(), response))
        returned = try await JsonFetcher(client_: client).fetch(data: data).value
    }
    func testWhenDefaultFetchWhenTheRequestHasNoDataThenResolvesTheTaskWithResponse() async throws {
        try await beforeEachWhenTheRequestHasNoData()

        expect((self.returned as! Dictionary<String, String>)).to(equal([:]))

        afterEachTop()
    }
        //describe("when the request generally errors") {
    func beforeEachWhenTheRequestGenerallyErrors() async throws {
        try await beforeEachWhenDefaultFetch()
        let urlString: String = data["url"] as! String
        let url: URL = URL(string: urlString)!
        let response: URLResponse = HTTPURLResponse(url: url, statusCode: 503, httpVersion: "1.1", headerFields: [:])!
        given(try await client.data(for: any(), delegate: nil)).willReturn((Data(), response))
        do {
            let _ = try await JsonFetcher(client_: client).fetch(data: data).value
        } catch JsonFetcher.Errors.serverResponseError(let description, _){
            caught = description
        }
    }
    func testWhenDefaultFetchWhenTheRequestGenerallyErrorsThenRejectsTheTaskWithError() async throws {
        try await beforeEachWhenTheRequestGenerallyErrors()

        expect(self.caught).to(equal("service unavailable"))

        afterEachTop()
    }
        //describe("when the request unauthorized"){
    func beforeEachWhenTheRequestUnauthorized() async throws {
        try await beforeEachWhenDefaultFetch()
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let responseData = try encoder.encode(["error_message": "unauthorized"])
        let urlString: String = data["url"] as! String
        let url: URL = URL(string: urlString)!
        let response: URLResponse = HTTPURLResponse(url: url, statusCode: 401, httpVersion: "1.1", headerFields: [:])!
        given(try await client.data(for: any(), delegate: nil)).willReturn((responseData, response))
        do {
            let _ = try await JsonFetcher(client_: client).fetch(data: data).value
        } catch JsonFetcher.Errors.serverRejectedError(let description, _, _){
            caught = description
        }
    }
    func testWhenDefaultFetchbeforeEachWhenTheRequestUnauthorizedThenRejectsTheTaskWithError() async throws {
        try await beforeEachWhenTheRequestUnauthorized()

        expect(self.caught).to(equal("unauthorized"))

        afterEachTop()
    }
        //describe("when the request unauthorized and corrupt"){
    func beforeEachWhenTheRequestUnauthorizedAndCorrupt() async throws {
        try await beforeEachWhenDefaultFetch()
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let responseData = try encoder.encode(["error_message": 1])
        let urlString: String = data["url"] as! String
        let url: URL = URL(string: urlString)!
        let response: URLResponse = HTTPURLResponse(url: url, statusCode: 401, httpVersion: "1.1", headerFields: [:])!
        given(try await client.data(for: any(), delegate: nil)).willReturn((responseData, response))
        do {
            let _ = try await JsonFetcher(client_: client).fetch(data: data).value
        } catch JsonFetcher.Errors.serverResponseError(let description, _){
            caught = description
        }
    }
    func testWhenDefaultFetchWhenTheRequestUnauthorizedAndCorruptThenRejectsTheTaskWithError() async throws {
        try await beforeEachWhenTheRequestUnauthorizedAndCorrupt()

        expect(self.caught).to(equal("unauthorized"))

        afterEachTop()
    }
        //describe("when the network down")
    func beforeEachWhenTheNetworkDown() async throws {
        try await beforeEachWhenDefaultFetch()
        givenSwift(try await client.data(for: any(), delegate: nil)).will{(_,_) in throw "network down"}
        do {
            let _ = try await JsonFetcher(client_: client).fetch(data: data).value
        } catch JsonFetcher.Errors.noNetworkError(let description){
            caught = description
        }
    }
    func testWhenDefaultFetchbeforeEachWhenTheNetworkDownThenRequestsBaseUrl() async throws {
        try await beforeEachWhenTheNetworkDown()

        expect(self.caught).to(equal("Your internet connection appears to have gone down."))

        afterEachTop()
    }

}


