//
// Created by Woydziak, Luke on 9/27/22.
//

import Foundation

@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
open class DeanonymizeApi: ApiBase {
    public enum Errors: Error {
        case parameterError(String)
    }
    public convenience init() {
        self.init(props:[
            "name": "ApiDeanonymize",
            "url": "deanonymize",
            "authenticated": true,
        ])
    }
    public convenience init(fetcher_: Fetchable) {
        self.init()
        fetcher = fetcher_
    }

    open override func params(data: Dictionary<String, Any>) throws -> Dictionary<String, Any> {
        let local = try super.params(data: data);
        if (local["person"] == nil) {throw Errors.parameterError("No person data received.")}
        return [
            "uuid": local["id"]!,
            "timestamp": local["timestamp"]!,
            "person": local["person"]!
        ]
    }
}
