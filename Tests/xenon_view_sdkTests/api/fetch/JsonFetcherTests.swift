//
// Created by Woydziak, Luke on 9/12/22.
//

import Foundation
import Quick
import Nimble
import Mockingbird
import AsyncObjects
import Dispatch
import SwiftyJSON
@testable import xenon_view_sdk

extension String: Error {
}


final class JsonFetcherTests: QuickSpec {
    override func spec() {
        var client = mock(JsonFetcherClient.self)
        var data: Dictionary<String, Any> = [:]
        let body: Dictionary<String, String> = ["test": "Body"]
        let expected: Dictionary<String, JSON> = ["result": JSON("success")]
        class OpResult {
            static var opResult_ = ""

            func set(result: String) {
                OpResult.opResult_ = result
            }

            func get() -> String {
                OpResult.opResult_
            }
        }
        class OpURLRequest {
            static var opResult_: URLRequest?

            func set(result: URLRequest) {
                OpURLRequest.opResult_ = result
            }

            func get() -> URLRequest {
                OpURLRequest.opResult_!
            }
        }
        class OpReturned {
            static var opResult_: JSON?
            func set(result: JSON) {
                OpReturned.opResult_ = result
            }

            func get() -> JSON {
                OpReturned.opResult_!
            }
        }
        let caught = OpResult()
        beforeEach {
            data = ["url": "https://example.blah/"]
        }
        afterEach {
            data = [:]
            client = mock(JsonFetcherClient.self)
            caught.set(result: "")
        }
        it("can be constructed") {
            expect(JsonFetcher()).notTo(beNil())
        }
        describe("when no url") {
            beforeEach {
                data["url"] = ""

                let opClient = client
                let opData = data
                let op = TaskOperation(queue: .global(qos: .background)) {
                    do {
                        let _ = try await JsonFetcher(client_: opClient).fetch(data: opData).value
                    } catch JsonFetcherErrors.clientUrlIncorrect(let reason) {
                        caught.set(result: reason)
                    }
                }
                op.start()
                op.waitUntilFinished()

            }

            it("then throws") {
                expect(caught.get()).to(equal(""))
            }
        }
        describe("when default fetch") {
            beforeEach {
                data["method"] = "GET"
            }
            describe("when default headers") {
                beforeEach {
                    caught.set(result: "")
                    let opClient = client
                    let opData = data
                    let op = TaskOperation(queue: .global(qos: .background)) {
                        given(try await opClient.data(for: any(), delegate: nil)).willReturn((Data(), URLResponse()))
                        do {
                            let _ = try await JsonFetcher(client_: opClient).fetch(data: opData).value
                        } catch JsonFetcherErrors.serverUnexpectedError {
                            caught.set(result: "serverUnexpectedError")
                        }
                    }
                    op.start()
                    op.waitUntilFinished()
                }
                it("then requests base url") {
                    let opURLRequest = OpURLRequest()
                    let opClient = client
                    let op = TaskOperation(queue: .global(qos: .background)) {
                        let request = ArgumentCaptor<URLRequest>()
                        verify(try await opClient.data(for: request.any(), delegate: nil)).wasCalled()
                        opURLRequest.set(result: request.value!)
                    }
                    op.start()
                    op.waitUntilFinished()

                    let requested: URLRequest = opURLRequest.get()
                    expect(requested.httpMethod).to(equal("GET"))
                    expect(requested.url).to(equal(URL(string: data["url"] as! String)!))
                    expect(requested.value(forHTTPHeaderField: "accept")).to(equal("application/json"))
                }
                it("then throws") {
                    expect(caught.get()).to(equal("serverUnexpectedError"))
                }
            }
            describe("when custom headers set") {
                beforeEach {
                    caught.set(result: "")
                    data["headers"] = ["x-custom1": "value1", "x-custom2": "value2"]
                    let opClient = client
                    let opData = data
                    let op = TaskOperation(queue: .global(qos: .background)) {
                        given(try await opClient.data(for: any(), delegate: nil)).willReturn((Data(), URLResponse()))
                        do {
                            let _ = try await JsonFetcher(client_: opClient).fetch(data: opData).value
                        } catch JsonFetcherErrors.serverUnexpectedError {
                            caught.set(result: "serverUnexpectedError")
                        }
                    }
                    op.start()
                    op.waitUntilFinished()
                }
                it("then request with custom headers ") {
                    let opURLRequest = OpURLRequest()
                    let opClient = client
                    let op = TaskOperation(queue: .global(qos: .background)) {
                        let request = ArgumentCaptor<URLRequest>()
                        verify(try await opClient.data(for: request.any(), delegate: nil)).wasCalled()
                        opURLRequest.set(result: request.value!)
                    }
                    op.start()
                    op.waitUntilFinished()
                    let requested: URLRequest = opURLRequest.get()
                    expect(requested.value(forHTTPHeaderField: "x-custom1")).to(equal("value1"))
                    expect(requested.value(forHTTPHeaderField: "x-custom2")).to(equal("value2"))
                }
                it("then throws") {
                    expect(caught.get()).to(equal("serverUnexpectedError"))
                }
            }
            describe("when the request is successful") {
                let returned = OpReturned()
                beforeEach {
                    returned.set(result: JSON([:]))
                    let opClient = client
                    let opData = data
                    let op = TaskOperation(queue: .global(qos: .background)) {
                        let encoder = JSONEncoder()
                        encoder.outputFormatting = .prettyPrinted
                        let responseData = try encoder.encode(expected)
                        let urlString: String = opData["url"] as! String
                        let url: URL = URL(string: urlString)!
                        let response: URLResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "1.1", headerFields: [:])!
                        given(try await opClient.data(for: any(), delegate: nil)).willReturn((responseData, response))
                        returned.set(result: try await JsonFetcher(client_: opClient).fetch(data: opData).value)
                    }
                    op.start()
                    op.waitUntilFinished()
                }
                it("then resolves the task with Json response") {
                    expect((returned.get().dictionaryValue)).to(equal(expected))
                }
            }
            describe("when the request is successful with bad JSON") {
                beforeEach {
                    caught.set(result: "")
                    let opClient = client
                    let opData = data
                    let op = TaskOperation(queue: .global(qos: .background)) {
                        let responseData: Data = "garbage".data(using: .utf8)!
                        let urlString: String = opData["url"] as! String
                        let url: URL = URL(string: urlString)!
                        let response: URLResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "1.1", headerFields: [:])!
                        given(try await opClient.data(for: any(), delegate: nil)).willReturn((responseData, response))
                        do {
                            let _  = try await JsonFetcher(client_: opClient).fetch(data: opData).value
                        } catch JsonFetcherErrors.serverInvalidJson(let description, _) {
                            caught.set(result: description)
                        }
                    }
                    op.start()
                    op.waitUntilFinished()
                }
                it("then throws") {
                    expect(caught.get()).to(equal("Server returned non-JSON response."))
                }
            }
            describe("when the request is not successful") {
                beforeEach {
                    caught.set(result: "")
                    let opClient = client
                    let opData = data
                    let op = TaskOperation(queue: .global(qos: .background)) {
                        let encoder = JSONEncoder()
                        encoder.outputFormatting = .prettyPrinted
                        let responseData = try encoder.encode(["error_message": "The server responded with an error."])
                        let urlString: String = opData["url"] as! String
                        let url: URL = URL(string: urlString)!
                        let response: URLResponse = HTTPURLResponse(url: url, statusCode: 400, httpVersion: "1.1", headerFields: [:])!
                        given(try await opClient.data(for: any(), delegate: nil)).willReturn((responseData, response))
                        do {
                            let _ = try await JsonFetcher(client_: opClient).fetch(data: opData).value
                        } catch JsonFetcherErrors.serverRejectedError(let description, _, _) {
                            caught.set(result: description)
                        }
                    }
                    op.start()
                    op.waitUntilFinished()
                }
                it("then throws") {
                    expect(caught.get()).to(equal("The server responded with an error."))
                }
            }
            describe("when the request has no data") {
                let returned = OpReturned()
                beforeEach {
                    returned.set(result: JSON([:]))
                    let opClient = client
                    let opData = data
                    let op = TaskOperation(queue: .global(qos: .background)) {
                        let encoder = JSONEncoder()
                        encoder.outputFormatting = .prettyPrinted
                        let urlString: String = opData["url"] as! String
                        let url: URL = URL(string: urlString)!
                        let response: URLResponse = HTTPURLResponse(url: url, statusCode: 204, httpVersion: "1.1", headerFields: [:])!
                        given(try await opClient.data(for: any(), delegate: nil)).willReturn((Data(), response))
                        returned.set(result: try! await JsonFetcher(client_: opClient).fetch(data: opData).value )
                    }
                    op.start()
                    op.waitUntilFinished()
                }
                it("then resolves the task with response") {
                    expect(returned.get().dictionaryValue).to(equal([:]))
                }
            }
            describe("when the request has no data and json array expected") {
                let returned = OpReturned()
                beforeEach {
                    returned.set(result: JSON([]))
                    let opClient = client
                    let opData = data
                    let op = TaskOperation(queue: .global(qos: .background)) {
                        let encoder = JSONEncoder()
                        encoder.outputFormatting = .prettyPrinted
                        let urlString: String = opData["url"] as! String
                        let url: URL = URL(string: urlString)!
                        let response: URLResponse = HTTPURLResponse(url: url, statusCode: 204, httpVersion: "1.1", headerFields: [:])!
                        given(try await opClient.data(for: any(), delegate: nil)).willReturn((Data(), response))
                        returned.set(result: try! await JsonFetcher(client_: opClient).fetch(data: opData).value)
                    }
                    op.start()
                    op.waitUntilFinished()
                }
                it("then resolves the task with response") {
                    expect(returned.get().arrayValue).to(equal([]))
                }
            }
            describe("when the request generally errors") {
                beforeEach {
                    caught.set(result: "")
                    let opClient = client
                    let opData = data
                    let op = TaskOperation(queue: .global(qos: .background)) {
                        let urlString: String = opData["url"] as! String
                        let url: URL = URL(string: urlString)!
                        let response: URLResponse = HTTPURLResponse(url: url, statusCode: 503, httpVersion: "1.1", headerFields: [:])!
                        given(try await opClient.data(for: any(), delegate: nil)).willReturn((Data(), response))
                        do {
                            let _  = try await JsonFetcher(client_: opClient).fetch(data: opData).value
                        } catch JsonFetcherErrors.serverResponseError(let description, _) {
                            caught.set(result: description)
                        }
                    }
                    op.start()
                    op.waitUntilFinished()
                }
                it("then throws") {
                    expect(caught.get()).to(equal("service unavailable"))
                }
            }
            describe("when the request unauthorized") {
                beforeEach {
                    caught.set(result: "")
                    let opClient = client
                    let opData = data
                    let op = TaskOperation(queue: .global(qos: .background)) {
                        let encoder = JSONEncoder()
                        encoder.outputFormatting = .prettyPrinted
                        let responseData = try encoder.encode(["error_message": "unauthorized"])
                        let urlString: String = opData["url"] as! String
                        let url: URL = URL(string: urlString)!
                        let response: URLResponse = HTTPURLResponse(url: url, statusCode: 401, httpVersion: "1.1", headerFields: [:])!
                        given(try await opClient.data(for: any(), delegate: nil)).willReturn((responseData, response))
                        do {
                            let _ = try await JsonFetcher(client_: opClient).fetch(data: opData).value
                        } catch JsonFetcherErrors.serverRejectedError(let description, _, _) {
                            caught.set(result: description)
                        }
                    }
                    op.start()
                    op.waitUntilFinished()
                }
                it("then throws") {
                    expect(caught.get()).to(equal("unauthorized"))
                }
            }
            describe("when the request unauthorized and corrupt") {
                beforeEach {
                    caught.set(result: "")
                    let opClient = client
                    let opData = data
                    let op = TaskOperation(queue: .global(qos: .background)) {
                        let encoder = JSONEncoder()
                        encoder.outputFormatting = .prettyPrinted
                        let responseData = try encoder.encode(["error_message": 1])
                        let urlString: String = opData["url"] as! String
                        let url: URL = URL(string: urlString)!
                        let response: URLResponse = HTTPURLResponse(url: url, statusCode: 401, httpVersion: "1.1", headerFields: [:])!
                        given(try await opClient.data(for: any(), delegate: nil)).willReturn((responseData, response))
                        do {
                            let _ = try await JsonFetcher(client_: opClient).fetch(data: opData).value
                        } catch JsonFetcherErrors.serverResponseError(let description, _) {
                            caught.set(result: description)
                        }
                    }
                    op.start()
                    op.waitUntilFinished()
                }
                it("then throws") {
                    expect(caught.get()).to(equal("unauthorized"))
                }
            }
            describe("when the network down") {
                beforeEach {
                    caught.set(result: "")
                    let opClient = client
                    let opData = data
                    let op = TaskOperation(queue: .global(qos: .background)) {
                        givenSwift(try await opClient.data(for: any(), delegate: nil)).will { (_, _) in
                            throw "network down"
                        }
                        do {
                            let _  = try await JsonFetcher(client_: opClient).fetch(data: opData).value
                        } catch JsonFetcherErrors.noNetworkError(let description) {
                            caught.set(result: description)
                        }
                    }
                    op.start()
                    op.waitUntilFinished()
                }
                it("then throws") {
                    expect(caught.get()).to(contain("The operation couldn’t be completed"))
                }
            }
            describe("when the server down"){
                beforeEach {
                    caught.set(result: "")
                    let opClient = client
                    let opData = data
                    let op = TaskOperation(queue: .global(qos: .background)) {
                        givenSwift(try await opClient.data(for: any(), delegate: nil)).will {
                            (_, _) in
                            throw NSError(domain: "", code: -1004, userInfo: [NSLocalizedDescriptionKey: "CustomError"]) as Error
                        }
                        do {
                            let _ = try await JsonFetcher(client_: opClient).fetch(data: opData).value
                        } catch JsonFetcherErrors.serverError(let description) {
                            caught.set(result: description)
                        }
                    }
                    op.start()
                    op.waitUntilFinished()
                }
                it("then throws") {
                    expect(caught.get()).to(contain("CustomError"))
                }
            }
        }
        describe("when posting fetch"){
            beforeEach {
                data["method"] = "POST"
                data["body"] = body
            }
            describe("when default") {
               beforeEach {
                   let opClient = client
                   let opData = data
                   let op = TaskOperation(queue: .global(qos: .background)) {
                       given(try await opClient.data(for: any(), delegate: nil)).willReturn((Data(), URLResponse()))
                       let _ = try await JsonFetcher(client_: opClient).fetch(data: opData).value
                   }
                   op.start()
                   op.waitUntilFinished()
               }
                it("then requests base Url") {
                    let opURLRequest = OpURLRequest()
                    let opClient = client
                    let op = TaskOperation(queue: .global(qos: .background)) {
                        let request = ArgumentCaptor<URLRequest>()
                        verify(try await opClient.data(for: request.any(), delegate: nil)).wasCalled()
                        opURLRequest.set(result: request.value!)
                    }
                    op.start()
                    op.waitUntilFinished()
                    let requested: URLRequest = opURLRequest.get()
                    expect(requested.httpMethod).to(equal("POST"))
                    let body = String(data: requested.httpBody!, encoding: String.Encoding.utf8)
                    expect(body).to(equal("{\"test\":\"Body\"}"))
                    expect(requested.value(forHTTPHeaderField: "accept")).to(equal("application/json"))
                    expect(requested.value(forHTTPHeaderField: "content-type")).to(equal("application/json; charset=utf-8"))
                }
            }
            describe("when bad body"){
                beforeEach {
                    caught.set(result: "")
                    data["body"] = "bad"
                    let opClient = client
                    let opData = data
                    let op = TaskOperation(queue: .global(qos: .background)) {
                        do {
                            let _ = try await JsonFetcher(client_: opClient).fetch(data: opData).value
                        } catch JsonFetcherErrors.clientBodyIncorrect(let reason) {
                            caught.set(result: reason)
                        }
                    }
                    op.start()
                    op.waitUntilFinished()
                }
                it("then throws") {
                    expect(caught.get()).to(equal("*** +[NSJSONSerialization dataWithJSONObject:options:error:]: Invalid top-level type in JSON write"))
                }
            }
            describe("when self signed allowed fetch"){
                let returned = OpReturned()
                beforeEach {
                    returned.set(result: JSON([:]))
                    data["ignore-certificate-errors"] = true
                    let opClient = client
                    let opData = data
                    let op = TaskOperation(queue: .global(qos: .background)) {
                        let encoder = JSONEncoder()
                        encoder.outputFormatting = .prettyPrinted
                        let responseData = try encoder.encode(expected)
                        let urlString: String = opData["url"] as! String
                        let url: URL = URL(string: urlString)!
                        let response: URLResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "1.1", headerFields: [:])!
                        given(try await opClient.data(for: any(), delegate: any())).willReturn((responseData, response))
                        returned.set(result: try await JsonFetcher(client_: opClient).fetch(data: opData).value)
                    }
                    op.start()
                    op.waitUntilFinished()
                }
                it("then resolves the task with Json response") {
                    expect(returned.get().dictionaryValue).to(equal(expected))
                }
            }
        }
        describe("Self Signed Handler"){
            let sender = mock(URLAuthenticationChallengeSender.self)
            let testCertFile = "./Tests/xenon_view_sdkTests/api/fetch/DigiCertTLSECCP384RootG5.crt"

            class TestURLProtectionSpace: Foundation.URLProtectionSpace {
                var internalServerTrust: SecTrust?
                override var serverTrust: SecTrust? {
                    internalServerTrust
                }
            }
            let protectionSpace = TestURLProtectionSpace(
                    host: "localhost", port: 80, protocol: "",
                    realm: "",
                    authenticationMethod: NSURLAuthenticationMethodServerTrust
            )
            it("then calls the handler correctly") {
                var optionalTrust: SecTrust?
                let data = try Data(contentsOf: URL(fileURLWithPath: testCertFile))
                let cfData = CFDataCreateWithBytesNoCopy(
                        nil,
                        (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count),
                        data.count, kCFAllocatorNull
                )
                let cert = SecCertificateCreateWithData(kCFAllocatorDefault, cfData!)
                let policy = SecPolicyCreateBasicX509()
                let status = SecTrustCreateWithCertificates(cert!,
                        policy,
                        &optionalTrust)
                guard status == errSecSuccess else {
                    throw "could not create SecTrust"
                }
                let serverTrust = optionalTrust!
                protectionSpace.internalServerTrust = serverTrust;
                let challenge = URLAuthenticationChallenge(
                        protectionSpace: protectionSpace,
                        proposedCredential: nil,
                        previousFailureCount: 0,
                        failureResponse: nil, error: nil,
                        sender: sender
                )
                JsonFetcherDelegate().urlSession(URLSession(), task: URLSessionTask(), didReceive: challenge) {
                    disposition, credential in
                    expect(disposition).to(beAKindOf(URLSession.AuthChallengeDisposition.self))
                    expect(credential).to(beAKindOf(URLCredential.self))
                }
            }
        }
    }
}
