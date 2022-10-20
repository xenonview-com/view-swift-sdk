//
// Created by Woydziak, Luke on 9/12/22.
//

import Foundation
import SwiftyJSON

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)

public class Xenon {
    public enum Errors: Error {
        case authenticationTokenError(String)
    }

    private var journeyApi: Api
    private var deanonApi: Api
    private static var _id: String = UUID().uuidString
    private static var _journey: Array<Any> = []
    private static var apiUrl: String = "https://app.xenonview.com"
    private static var apiKey: String = ""
    private static var allowSelfSigned: Bool = false
    private static var platform_: Dictionary<String, Any> = [:]
    private var restoreJourney: Array<Any> = []

    public init() {
        journeyApi = JourneyApi()
        deanonApi = DeanonymizeApi()
    }

    convenience init(apiKey: String) {
        self.init()
        Xenon.apiKey = apiKey
        Xenon.apiUrl = "https://app.xenonview.com"
    }

    convenience init(apiKey: String, _journeyApi: Api) {
        self.init(apiKey: apiKey)
        journeyApi = _journeyApi
    }

    convenience init(apiKey: String, _allowSelfSigned: Bool) {
        self.init(apiKey: apiKey)
        Xenon.allowSelfSigned = _allowSelfSigned
    }

    convenience init(apiKey: String, apiUrl: String) {
        self.init(apiKey: apiKey)
        Xenon.apiUrl = apiUrl
    }


    convenience init(apiKey: String, apiUrl: String, _allowSelfSigned: Bool) {
        self.init(apiKey: apiKey, apiUrl: apiUrl)
        Xenon.allowSelfSigned = _allowSelfSigned
    }

    convenience init(apiKey: String, apiUrl: String, _journeyApi: Api) {
        self.init(apiKey: apiKey, apiUrl: apiUrl)
        journeyApi = _journeyApi
    }

    convenience init(_journeyApi: Api) {
        self.init()
        journeyApi = _journeyApi
    }

    convenience init(apiKey: String, apiUrl: String, _allowSelfSigned: Bool, _journeyApi: Api) {
        self.init(apiKey: apiKey, apiUrl: apiUrl, _allowSelfSigned: _allowSelfSigned)
        journeyApi = _journeyApi
    }

    convenience init(apiKey: String, apiUrl: String, _allowSelfSigned: Bool, _journeyApi: Api, _deanonApi: Api) {
        self.init(apiKey: apiKey, apiUrl: apiUrl, _allowSelfSigned: _allowSelfSigned, _journeyApi: _journeyApi)
        deanonApi = _deanonApi
    }

    convenience init(apiKey: String, apiUrl: String, _journeyApi: Api, _deanonApi: Api) {
        self.init(apiKey: apiKey, apiUrl: apiUrl, _journeyApi: _journeyApi)
        deanonApi = _deanonApi
    }

    public func id() -> String {
        Xenon._id
    }

    public func id(_id: String) {
        Xenon._id = _id
    }

    public func journey() -> Array<Any> {
        Xenon._journey
    }


    public func initialize(apiKey: String, apiUrl: String) {
        if (apiUrl.count > 0) {
            Xenon.apiUrl = apiUrl
        }
        if (apiKey.count > 0) {
            Xenon.apiKey = apiKey
        }
    }

    public func initialize(apiKey: String) {
        initialize(apiKey: apiKey, apiUrl: "")
    }


    public func add(pageView: String) throws {
        let content = [
            "category": "Page View",
            "action": pageView
        ]
        try journeyAdd(content: content)
    }

    public func add(funnelStage: String, action: String) throws {
        let content = [
            "funnel": funnelStage,
            "action": action
        ]
        try journeyAdd(content: content)
    }

    public func add(outcome: String, action: String) throws {
        var content: Dictionary<String, Any> = [
            "outcome": outcome,
            "action": action
        ]
        if (!Xenon.platform_.isEmpty) {
            content["platform"] = Xenon.platform_
        };
        try journeyAdd(content: content)
    }

    public func platform(softwareVersion: String, deviceModel: String, operatingSystemVersion: String) throws {
        Xenon.platform_ = [
            "softwareVersion": softwareVersion,
            "deviceModel": deviceModel,
            "operatingSystemVersion": operatingSystemVersion
        ]
    }

    public func add(event: Dictionary<String, Any>) throws {
        var content: Dictionary<String, Any> = event
        if (content["action"] == nil) {
            if let theJSONData = try? JSONSerialization.data(
                    withJSONObject: event,
                    options: []) {
                let theJSONText = String(data: theJSONData,
                        encoding: .ascii)
                content["action"] = theJSONText
            }
        }
        if (content["category"] == nil &&
                content["funnel"] == nil &&
                content["outcome"] == nil) {
            content["category"] = "Event";
        }
        try journeyAdd(content: content)
    }

    private func timestamp() -> Double {
        NSDate().timeIntervalSince1970
    }

    private func journeyAdd(content: Dictionary<String, Any>) throws {
        var contentToSave = content;
        var journey = journey();
        contentToSave["timestamp"] = timestamp()
        if (journey.count > 0) {
            var last = journey.last as! Dictionary<String, Any>

            if ((last["funnel"] != nil && contentToSave["funnel"] != nil) ||
                    (last["category"] != nil && contentToSave["category"] != nil)) {
                if (last["action"] as? String != contentToSave["action"] as? String) {
                    journey.append(contentToSave)
                } else {
                    let count: Int = last["count"] != nil ? last["count"] as! Int : 1
                    last["count"] = count + 1
                    journey.indices.last.map {
                        journey[$0] = last
                    }
                }
            } else {
                journey.append(contentToSave)
            }
        } else {
            journey = [contentToSave]
        }
        storeJourney(journey: journey)
    }

    private func storeJourney(journey: Array<Any>) {
        Xenon._journey = journey
    }

    public func reset() {
        restoreJourney = journey()
        Xenon._journey = []
    }

    public func restore() throws {
        let currentJourney = journey()
        if (currentJourney.count > 0) {
            var result: Array<Any> = []
            for item in restoreJourney {
                result.append(item)
            }
            for item in currentJourney {
                result.append(item)
            }
            restoreJourney = result;
        }
        storeJourney(journey: restoreJourney)
        restoreJourney = []
    }

    public func commit() throws -> Task<JSON, Error> {
        let params: Dictionary<String, Any> = [
            "id": id(),
            "journey": journey(),
            "token": Xenon.apiKey,
            "timestamp": timestamp(),
            "ignore-certificate-errors": Xenon.allowSelfSigned
        ]
        if (Xenon.apiKey == "") { throw Errors.authenticationTokenError("API Key not set.")}

        reset()

        return Task {
            var result = JSON([:])
            do {
                result = try await journeyApi.with(apiUrl: Xenon.apiUrl).fetch(data: params).value
            } catch {
                try restore()
                throw error
            }
            return result
        }
    }
    public func deanonymize(person:Dictionary<String,Any>) throws -> Task<JSON, Error> {
        let params: Dictionary<String, Any> = [
            "id": id(),
            "person": person,
            "token": Xenon.apiKey,
            "timestamp": timestamp(),
            "ignore-certificate-errors": Xenon.allowSelfSigned
        ]
        if (Xenon.apiKey == "") { throw Errors.authenticationTokenError("API Key not set.")}

        return try deanonApi.with(apiUrl: Xenon.apiUrl).fetch(data: params)
    }

    public func selfSignedAllowed() -> Bool {
        Xenon.allowSelfSigned
    }

    public func removePlatform(){
        Xenon.platform_ = [:]
    }

    public func newId() {
        Xenon._id = UUID().uuidString
    }
}
