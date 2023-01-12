//
// Created by Woydziak, Luke on 9/26/22.
//

import Foundation

@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
open class HeartbeatApi: ApiBase {
    public convenience init() {
        self.init(props:[
            "name": "ApiHeartbeat",
            "url": "heartbeat",
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
        formated["tags"] = local["tags"]
        formated["platform"] = local["platform"]
        
        if (local["journey"] == nil) {
            return formated
        }
        formated["journey"] = local["journey"]
        return formated
    }
}
