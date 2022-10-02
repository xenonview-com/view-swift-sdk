//
// Created by Woydziak, Luke on 9/26/22.
//

import Foundation

public protocol Api:Fetchable{
    func with(apiUrl: String) -> Fetchable
}

open class ApiBase: Api {
    public enum Errors: Error {
        case authenticationTokenError(String)
    }
    open var fetcher: Fetchable
    private var name: String
    private var method: String
    private var headers: Dictionary<String, String>
    private var path_: String
    private var apiUrl: String
    private var skipName: Bool
    private var authenticated: Bool

    public init(props: Dictionary<String, Any>) {
        fetcher = JsonFetcher()
        name = props["name"] != nil ? props["name"] as! String : "ApiBase"
        method = props["method"] != nil ? props["method"] as! String : "POST"
        let defaultHeaders = ["content-type": "application/json"]
        headers = props["headers"] != nil ? props["headers"] as! Dictionary<String, String> : defaultHeaders;
        path_ = props["url"] != nil ? props["url"] as! String : ""
        apiUrl = props["apiUrl"] != nil ? props["apiUrl"] as! String : "https://app.xenonview.com"
        skipName = props["skipName"] != nil && props["skipName"] as! Bool
        authenticated = props["authenticated"] != nil && props["authenticated"] as! Bool
    }

    public convenience init(props: Dictionary<String, Any>, fetcher_: Fetchable) {
        self.init(props: props)
        fetcher = fetcher_
    }

    public func with(apiUrl: String) -> Fetchable {
        self.apiUrl = apiUrl
        return self
    }


    open func params(data: Dictionary<String, Any>) throws -> Dictionary<String, Any> { data }

    open func path(data: Dictionary<String, Any>) -> String { path_ }

    open func fetch(data: Dictionary<String, Any>) throws -> Task<[String: Any], Error> {
        let fetchUrl: String  = apiUrl + "/" + path(data: data);
        var fetchParameters: Dictionary<String, Any> = [
            "url": fetchUrl,
            "method": method
        ]
        if(data["ignore-certificate-errors"] != nil){
            fetchParameters["ignore-certificate-errors"] = data["ignore-certificate-errors"]
        }

        if (data.count > 0 || !skipName) {
            var bodyObject: Dictionary<String, Any> = [:]
            if (!skipName) { bodyObject["name"] = name }
            let parameters: Dictionary<String, Any> = try params(data: data)
            bodyObject["parameters"] = parameters
            fetchParameters["body"] = bodyObject
        }
        var requestHeaders: Dictionary<String, Any> = headers

        if (authenticated) {
            let error = Errors.authenticationTokenError("No token and authenticated!")
            if (data["token"] == nil) {throw error}
            let token: String = data["token"] as! String
            if (token == "") {throw error}
            requestHeaders["authorization"] = "Bearer " + token
        }

        fetchParameters["headers"] =  requestHeaders;
        return try fetcher.fetch(data: fetchParameters)
    }
}
