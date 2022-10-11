//
// Created by Woydziak, Luke on 9/26/22.
//

import Foundation

open class JourneyApi: ApiBase {
    public convenience init() {
        self.init(props:[
            "name": "ApiJourney",
            "url": "journey",
            "authenticated": true,
        ])
    }
    public convenience init(fetcher_: Fetchable) {
        self.init()
        fetcher = fetcher_
    }

    open override func params(data: Dictionary<String, Any>) throws -> Dictionary<String, Any> {
        let local = try super.params(data: data);
        var formated: Dictionary<String, Any> = [:]
        formated["uuid"] = local["id"]
        formated["timestamp"] = local["timestamp"]
        if (local["journey"] == nil) {
            return formated
        }
        formated["journey"] = local["journey"]
        return formated
    }
}
