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
import xenon_view_sdk

final class xenon_view_sdkTests: QuickSpec {
    override func spec() {
        describe("View SDK Uninitialized") {
            it("throws upon commit") {
                expect(try Xenon().commit()).to(throwError())
            }
            it("throws upon commit") {
                expect(try Xenon().deanonymize(person: [:])).to(throwError())
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
            let deanonApi = mock(Api.self)
            beforeEach {
                clearInvocations(on: journeyApi)
                clearInvocations(on: deanonApi)
                given(try! journeyApi.fetch(data: any())).willReturn(Task {
                    [:]
                })
                given(try! deanonApi.fetch(data: any())).willReturn(Task {
                    [:]
                })
                given(journeyApi.with(apiUrl: any())).willReturn(journeyApi)
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
                    try! Xenon().add(pageView: "test")
                    subject = Xenon(apiKey: apiKey, apiUrl: apiUrl)
                }
                it("then has previous journey") {
                    let journey = subject!.journey()
                    expect(journey.description).to(contain("\"action\": \"test\""))
                    expect(journey.description).to(contain("\"category\": \"Page View\""))
                    expect(journey.description).to(contain("\"timestamp\": "))
                }
                afterEach {
                    Xenon().reset()
                }
            }
            describe("when adding a page view") {
                beforeEach {
                    try! Xenon().add(pageView: "test")
                }
                it("then has a journey with a page view") {
                    let journey = Xenon().journey()
                    expect(journey.description).to(contain("\"action\": \"test\""))
                    expect(journey.description).to(contain("\"category\": \"Page View\""))
                    expect(journey.description).to(contain("\"timestamp\": "))
                }
                afterEach {
                    Xenon().reset()
                }
            }
            describe("when adding a funnel stage") {
                let stage = "<stage in funnel>"
                let action = "<custom action>"
                beforeEach {
                    try! Xenon().add(funnelStage: stage, action: action)
                }
                it("then has a journey with a funnel stage") {
                    let journey = Xenon().journey()
                    expect(journey.description).to(contain("\"action\": \"<custom action>\""))
                    expect(journey.description).to(contain("\"funnel\": \"<stage in funnel>\""))
                    expect(journey.description).to(contain("\"timestamp\": "))
                }
            }
            describe("when adding an outcome") {
                let softwareVersion = "5.1.9.alpha"
                let deviceModel = "Google Pixel 4 XL"
                let operatingSystemVersion = "Google - 12"
                let outcome = "<outcome>"
                let action = "<custom action>"
                describe("when no action provided") {
                    beforeEach {
                        try! Xenon().add(outcome: outcome, action: "")
                    }
                    it("then adds an outcome to journey") {
                        let journey = Xenon().journey()
                        expect(journey.description).to(contain("\"outcome\": \"<outcome>\""))
                        expect(journey.description).to(contain("\"timestamp\": "))
                    }
                }
                describe("when no platform set and action") {
                    beforeEach {
                        try! Xenon().add(outcome: outcome, action: action)
                    }
                    it("then adds an outcome to journey") {
                        let journey = Xenon().journey()
                        expect(journey.description).to(contain("\"outcome\": \"<outcome>\""))
                        expect(journey.description).to(contain("\"action\": \"<custom action>\""))
                        expect(journey.description).to(contain("\"timestamp\": "))
                    }
                }
                describe("when platform set and then unset") {
                    beforeEach {
                        try! Xenon().platform(softwareVersion: softwareVersion, deviceModel: deviceModel, operatingSystemVersion: operatingSystemVersion)
                        Xenon().removePlatform()
                        try! Xenon().add(outcome: outcome, action: action)
                    }
                    it("then adds an outcome to journey") {
                        let journey = Xenon().journey()
                        expect(journey.description).to(contain("\"outcome\": \"<outcome>\""))
                        expect(journey.description).to(contain("\"action\": \"<custom action>\""))
                        expect(journey.description).to(contain("\"timestamp\": "))
                    }
                }
                describe("when platform set") {
                    beforeEach {
                        try! Xenon().platform(softwareVersion: softwareVersion, deviceModel: deviceModel, operatingSystemVersion: operatingSystemVersion)
                        try! Xenon().add(outcome: outcome, action: action)
                    }
                    it("then adds an outcome to journey") {
                        let journey = Xenon().journey()
                        expect(journey.description).to(contain("\"outcome\": \"<outcome>\""))
                        expect(journey.description).to(contain("\"action\": \"<custom action>\""))
                        expect(journey.description).to(contain("\"timestamp\": "))
                    }
                    it("then has platform details on the outcome") {
                        let journey = Xenon().journey()
                        expect(journey.description).to(contain("\"platform\""))
                        expect(journey.description).to(contain("\"operatingSystemVersion\": \"Google - 12\""))
                        expect(journey.description).to(contain("\"deviceModel\": \"Google Pixel 4 XL\""))
                        expect(journey.description).to(contain("\"softwareVersion\": \"5.1.9.alpha\""))
                    }
                    afterEach {
                        Xenon().removePlatform()
                    }
                }
            }
            describe("when adding an event") {
                let event = [
                    "category": "Event",
                    "action": "test"
                ]
                beforeEach {
                    try! Xenon().add(event: event)
                }
                it("then has a journey with an event") {
                    let journey = Xenon().journey()
                    expect(journey.description).to(contain("\"category\": \"Event\""))
                    expect(journey.description).to(contain("\"action\": \"test\""))
                    expect(journey.description).to(contain("\"timestamp\": "))
                }
            }
            describe("when adding multiple events") {
                let event = [
                    "funnel": "funnel",
                    "action": "test"
                ]
                let event2 = [
                    "category": "category",
                    "action": "test"
                ]
                describe("when duplicate funnels") {
                    beforeEach {
                        try! Xenon().add(event: event)
                        try! Xenon().add(event: event)
                    }
                    it("then has a journey with a count of 2") {
                        let journey = Xenon().journey()
                        expect(journey.description).to(contain("\"funnel\": \"funnel\""))
                        expect(journey.description).to(contain("\"action\": \"test\""))
                        expect(journey.description).to(contain("\"count\": 2"))
                        expect(journey.description).to(contain("\"timestamp\": "))
                        expect(Xenon().journey().count).to(equal(1))
                    }
                }
                describe("when duplicate categories") {
                    beforeEach {
                        try! Xenon().add(event: event2)
                        try! Xenon().add(event: event2)
                    }
                    it("then has a journey with a count of 2") {
                        let journey = Xenon().journey()
                        expect(journey.description).to(contain("\"category\": \"category\""))
                        expect(journey.description).to(contain("\"action\": \"test\""))
                        expect(journey.description).to(contain("\"count\": 2"))
                        expect(journey.description).to(contain("\"timestamp\": "))
                        expect(Xenon().journey().count).to(equal(1))
                    }
                }
                describe("when multiple duplicate categories") {
                    beforeEach {
                        try! Xenon().add(event: event2)
                        try! Xenon().add(event: event2)
                        try! Xenon().add(event: event2)
                    }
                    it("then has a journey with a count of 3") {
                        let journey = Xenon().journey()
                        expect(journey.description).to(contain("\"count\": 3"))
                        expect(Xenon().journey().count).to(equal(1))
                    }
                }
                describe("when duplicate categories but separate actions") {
                    beforeEach {
                        try! Xenon().add(event: event2)
                        let event3 = [
                            "category": "category",
                            "action": "different"
                        ]
                        try! Xenon().add(event: event3)
                    }
                    it("then has a journey with both events") {
                        let journey = Xenon().journey()
                        expect(journey.description).to(contain("\"category\": \"category\""))
                        expect(journey.description).to(contain("\"action\": \"test\""))
                        expect(journey.description).to(contain("\"timestamp\": "))
                        expect(journey.description).to(contain("\"action\": \"different\""))
                        expect(Xenon().journey().count).to(equal(2))
                    }
                }
                describe("when different") {
                    beforeEach {
                        try! Xenon().add(event: event2)
                        let event3 = [
                            "outcome": "different",
                            "action": "different"
                        ]
                        try! Xenon().add(event: event3)
                    }
                    it("then has a journey with both events") {
                        let journey = Xenon().journey()
                        expect(journey.description).to(contain("\"category\": \"category\""))
                        expect(journey.description).to(contain("\"action\": \"test\""))
                        expect(journey.description).to(contain("\"timestamp\": "))
                        expect(journey.description).to(contain("\"outcome\": \"different\""))
                        expect(journey.description).to(contain("\"action\": \"different\""))
                        expect(Xenon().journey().count).to(equal(2))
                    }
                }
            }
            describe("when adding generic event") {
                let event = ["action": "test"]
                beforeEach {
                    try! Xenon().add(event: event)
                }
                it("then has a journey with a generic event") {
                    let journey = Xenon().journey()
                    expect(journey.description).to(contain("\"category\": \"Event\""))
                    expect(journey.description).to(contain("\"action\": \"test\""))
                    expect(journey.description).to(contain("\"timestamp\": "))
                }
            }
            describe("when adding custom event") {
                let event = ["custom": "test"]
                beforeEach {
                    try! Xenon().add(event: event)
                }
                it("then has a journey with a generic event") {
                    let journey = Xenon().journey()
                    expect(journey.description).to(contain("\"category\": \"Event\""))
                    expect(journey.description).to(contain("\"action\": \"{\\\"custom\\\":\\\"test\\\"}\""))
                    expect(journey.description).to(contain("\"timestamp\": "))
                }
            }
            describe("when resetting") {
                var subject: Xenon?
                let event = [
                    "category": "Event",
                    "action": "test"
                ]

                beforeEach {
                    subject = Xenon()
                    try! subject!.add(event: event)
                    try! subject!.reset()
                }
                describe("when restoring") {
                    beforeEach {
                        try! subject!.restore()
                    }
                    it("then has a journey with added event") {
                        let journey = subject!.journey()
                        expect(journey.description).to(contain("\"category\": \"Event\""))
                        expect(journey.description).to(contain("\"action\": \"test\""))
                        expect(journey.description).to(contain("\"timestamp\": "))
                    }
                }
                describe("when restoring after another event was added") {
                    let anotherEvent = [
                        "category": "Event",
                        "action": "another"
                    ]
                    beforeEach {
                        try! subject!.add(event: anotherEvent)
                        try! subject!.restore()
                    }

                    it("then adds new event at end of previous journey") {
                        let journey = subject!.journey()
                        expect(journey.description).to(contain("\"category\": \"Event\""))
                        expect(journey.description).to(contain("\"action\": \"test\""))
                        expect(journey.description).to(contain("\"action\": \"another\""))
                        expect(journey.description).to(contain("\"timestamp\": "))
                    }
                }
            }
            describe("when committing a journey") {
                var subject: Xenon?
                let event = [
                    "category": "Event",
                    "action": "test"
                ]
                beforeEach {
                    subject = Xenon(apiKey: apiKey, apiUrl: apiUrl, _journeyApi: journeyApi)
                    try! subject!.add(event: event)
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
                        let journey = params["journey"] as! Array<Any>
                        expect(journey.description).to(contain("\"category\": \"Event\""))
                        expect(journey.description).to(contain("\"action\": \"test\""))
                        expect(journey.description).to(contain("\"timestamp\": "))
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
                        let journey = subject!.journey()
                        expect(journey.description).to(contain("\"category\": \"Event\""))
                        expect(journey.description).to(contain("\"action\": \"test\""))
                        expect(journey.description).to(contain("\"timestamp\": "))
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