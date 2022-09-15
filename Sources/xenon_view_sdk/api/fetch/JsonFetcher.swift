//
// Created by Woydziak, Luke on 9/12/22.
//

import Foundation

public protocol JsonFetcherClient {
    func data(for request: URLRequest, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse)
}

extension URLSession: JsonFetcherClient {
}

public class JsonFetcher {
    public enum Errors: Error {
        case clientUrlIncorrect(String)
        case serverRejectedError(description: String, response: HTTPURLResponse, details: Dictionary<String, String>)
        case serverResponseError(description: String, response: HTTPURLResponse)
        case serverUnexpectedError
        case serverInvalidJson(description: String, response: HTTPURLResponse)
        case noNetworkError(String)
    }

    private var client: JsonFetcherClient

    public init() {
        client = URLSession.shared;
    }

    public init(client_: JsonFetcherClient) {
        client = client_
    }

    public func fetch(data: Dictionary<String, Any>) throws -> Task<[String: Any], Error> {
        let urlString: String = data["url"] as! String
        guard let url = URL(string: urlString) else {
            throw Errors.clientUrlIncorrect("\(urlString)")
        }
        var mutatableRequest = URLRequest(url: url)
        mutatableRequest.setValue("application/json", forHTTPHeaderField: "accept")
        if (data["accessToken"] != nil) {
            mutatableRequest.setValue("Bearer \(data["accessToken"] as! String)", forHTTPHeaderField: "authorization")
        }
        if (data["headers"] != nil){
            let headers: Dictionary<String, String> = data["headers"] as! Dictionary<String, String>
            for (header, value) in headers {
                mutatableRequest.setValue(value, forHTTPHeaderField: header)
            }
        }
        let urlRequest = mutatableRequest;
        return Task {
            var data: Data;
            var response: URLResponse;
            do {
                let (data_, response_) = try await self.client.data(for: urlRequest, delegate: nil)
                data = data_
                response = response_
            } catch {
                throw Errors.noNetworkError("Your internet connection appears to have gone down.")
            }
            guard let httpResponse: HTTPURLResponse = response as? HTTPURLResponse else {
                throw Errors.serverUnexpectedError
            }

            switch (httpResponse.statusCode) {
            case 200:
                break
            case 204, 304:
                return [:]
            case 400..<500:
                let decoded = try JSONSerialization.jsonObject(with: data, options: [])
                guard let details = decoded as? [String: String] else {
                    throw Errors.serverResponseError(
                            description:
                            HTTPURLResponse.localizedString(
                                    forStatusCode: (response as! HTTPURLResponse).statusCode
                            ),
                            response: httpResponse)
                }
                let description: String = details["error_message"]!
                throw Errors.serverRejectedError(
                        description: description,
                        response: httpResponse,
                        details: details)

            default:
                throw Errors.serverResponseError(
                        description:
                        HTTPURLResponse.localizedString(
                                forStatusCode: (response as! HTTPURLResponse).statusCode
                        ),
                        response: httpResponse)
            }
            do {
                let decoded = try JSONSerialization.jsonObject(with: data, options: [])
                if let dictFromJSON = decoded as? [String: Any] {
                    return dictFromJSON
                }
            } catch {
            }
            throw Errors.serverInvalidJson(
                    description: "Server returned non-JSON response.",
                    response: httpResponse)
        }
    }
}