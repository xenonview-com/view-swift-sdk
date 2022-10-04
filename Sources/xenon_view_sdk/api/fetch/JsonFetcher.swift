//
// Created by Woydziak, Luke on 9/12/22.
//

import Foundation
import ExceptionCatcher


public protocol JsonFetcherClient {
    func data(for request: URLRequest, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse)
}

extension URLSession: JsonFetcherClient {
}

public protocol Fetchable {
    func fetch(data: Dictionary<String, Any>) throws -> Task<Any, Error>
}

public enum JsonFetcherErrors: Error {
    case clientUrlIncorrect(String)
    case clientBodyIncorrect(String)
    case serverRejectedError(description: String, response: HTTPURLResponse, details: Dictionary<String, String>)
    case serverResponseError(description: String, response: HTTPURLResponse)
    case serverUnexpectedError
    case serverError(String)
    case serverInvalidJson(description: String, response: HTTPURLResponse)
    case noNetworkError(String)
    case noDefault(String)
}


public class JsonFetcher<T> : Fetchable {

    private var client: JsonFetcherClient

    public init() {
        client = URLSession.shared;
    }

    public init(client_: JsonFetcherClient) {
        client = client_
    }



    public func fetch(data: Dictionary<String, Any>) throws -> Task<Any, Error> {
        let urlString: String = data["url"] as! String
        guard let url = URL(string: urlString) else {
            throw JsonFetcherErrors.clientUrlIncorrect("\(urlString)")
        }
        var mutatableRequest = URLRequest(url: url)
        mutatableRequest.setValue("application/json", forHTTPHeaderField: "accept")
        if (data["headers"] != nil){
            let headers: Dictionary<String, String> = data["headers"] as! Dictionary<String, String>
            for (header, value) in headers {
                mutatableRequest.setValue(value, forHTTPHeaderField: header)
            }
        }
        let method: String = (data["method"] as! String)
        mutatableRequest.httpMethod = method
        if (method == "POST"){
            mutatableRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "content-type")
            if (data["body"] != nil) {
                do {
                    let body = (data["body"] as Any)
                    try ExceptionCatcher.catch {
                        let httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
                        mutatableRequest.httpBody = httpBody
                    }
                } catch {
                    throw JsonFetcherErrors.clientBodyIncorrect("\(error.localizedDescription)")
                }
            }
        }

        var delegate: URLSessionTaskDelegate? = nil;
        if (data["ignore-certificate-errors"] != nil && data["ignore-certificate-errors"] as! Bool){
            delegate = JsonFetcherDelegate();
        }


        let urlRequest = mutatableRequest;
        let sessionDelegate = delegate;
        return Task {
            var data: Data;
            var response: URLResponse;
            do {
                let (data_, response_) = try await self.client.data(for: urlRequest, delegate: sessionDelegate)
                data = data_
                response = response_
            } catch {
                switch (error._code){
                case -1004:
                    throw JsonFetcherErrors.serverError(error.localizedDescription)
                default:
                    throw JsonFetcherErrors.noNetworkError(error.localizedDescription)
                }
            }
            guard let httpResponse: HTTPURLResponse = response as? HTTPURLResponse else {
                throw JsonFetcherErrors.serverUnexpectedError
            }

            switch (httpResponse.statusCode) {
            case 200:
                break
            case 204, 304:
                switch (T.self){
                case is Dictionary<String, Any>.Type:
                    return [:] as! T
                case is Array<Any>.Type:
                    return [] as! T
                default:
                    throw JsonFetcherErrors.noDefault("\(type(of: T.self)) not yet supported")
                }
            case 400..<500:
                let decoded = try JSONSerialization.jsonObject(with: data, options: [])
                guard let details = decoded as? [String: String] else {
                    throw JsonFetcherErrors.serverResponseError(
                            description:
                            HTTPURLResponse.localizedString(
                                    forStatusCode: (response as! HTTPURLResponse).statusCode
                            ),
                            response: httpResponse)
                }
                let description: String = details["error_message"]!
                throw JsonFetcherErrors.serverRejectedError(
                        description: description,
                        response: httpResponse,
                        details: details)

            default:
                throw JsonFetcherErrors.serverResponseError(
                        description:
                        HTTPURLResponse.localizedString(
                                forStatusCode: (response as! HTTPURLResponse).statusCode
                        ),
                        response: httpResponse)
            }
            do {
                let decoded = try JSONSerialization.jsonObject(with: data, options: [])
                if let dictFromJSON = decoded as? T {
                    return dictFromJSON
                }
            } catch {
            }
            throw JsonFetcherErrors.serverInvalidJson(
                    description: "Server returned non-JSON response.",
                    response: httpResponse)
        }
    }
}

public class JsonFetcherDelegate : NSObject {}

extension JsonFetcherDelegate: URLSessionTaskDelegate{
    public func urlSession(_ session: URLSession,
                           task: URLSessionTask,
                           didReceive challenge: URLAuthenticationChallenge,
                           completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
}