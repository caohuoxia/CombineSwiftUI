//
//  NetworkService.swift
//  CombineDemo
//
//  Created by caohx on 2022/2/28.
//

import Foundation
import Combine

enum NetworkError: Error, CustomStringConvertible {
    case URLError
    case DecodingError
    case ResponseError(error: Error)
    case Unknown
    
    var description: String {
        switch self {
        case .URLError:
            return "无效的URL"
        case .DecodingError:
            return "解码错误"
        case .ResponseError(let error):
            return "网络错误\(error.localizedDescription)"
        case .Unknown:
            return "未知错误"
        }
    }
}

public let BaseUrl = "https://jsonplaceholder.typicode.com"
let UserPath = "/users/"
let PostPath = "/posts/"

final class NetworkService {
    // 单例
    static let shared = NetworkService()
    
    // 请求user信息
    func fetchUser(index : String) -> AnyPublisher<UserModel, Error> {
        guard let url = URL(string: BaseUrl + UserPath + index) else {
            return Fail(error: NetworkError.URLError).eraseToAnyPublisher()
        }
        return requestNetWithURL(url: url)
    }

    // 请求post信息
    func fetchPost(userid : String) -> AnyPublisher<PostModel, Error> {
        guard let url = URL(string: BaseUrl + PostPath + userid) else {
            return Fail(error: NetworkError.URLError).eraseToAnyPublisher()
        }
        return requestNetWithURL(url: url)
    }
    
    // 底层网络请求及解析
    private func requestNetWithURL<ReturnType: Codable>(url: URL) -> AnyPublisher<ReturnType,Error> {
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { element -> Data in
                guard let httpRespose = element.response as? HTTPURLResponse, httpRespose.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return element.data
            }
            .decode(type: ReturnType.self, decoder: JSONDecoder())
            .mapError{ error -> NetworkError in
                switch error {
                case is URLError:
                    return .ResponseError(error: error)
                case is DecodingError:
                    return .DecodingError
                default:
                    return error as? NetworkError ?? .Unknown
                }
                
            }
            .eraseToAnyPublisher()
    }
 
}
