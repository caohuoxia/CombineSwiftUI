//
//  APIClient.swift
//  CombineDemo
//
//  Created by caohx on 2022/2/28.
//

import Foundation
import Combine

struct APIClient {
    static let shared = APIClient(baseURL: "https://jsonplaceholder.typicode.com")
    
    var baseURL: String!
    var networkDispatcher: NetworkDispatcher!
    init(baseURL: String,
                networkDispatcher: NetworkDispatcher = NetworkDispatcher()) {
        self.baseURL = baseURL
        self.networkDispatcher = networkDispatcher
    }
    /// Dispatches a Request and returns a publisher
    /// - Parameter request: Request to Dispatch
    /// - Returns: A publisher containing decoded data or an error
    func dispatch<R: Request>(_ request: R) -> AnyPublisher<R.ReturnType, NetworkRequestError> {
        guard let urlRequest = request.asURLRequest(baseURL: baseURL) else {
            return Fail(outputType: R.ReturnType.self, failure: NetworkRequestError.badRequest).eraseToAnyPublisher()
        }
        typealias RequestPublisher = AnyPublisher<R.ReturnType, NetworkRequestError>
        let requestPublisher: RequestPublisher = networkDispatcher.dispatch(request: urlRequest)
        return requestPublisher.eraseToAnyPublisher()
    }
}
