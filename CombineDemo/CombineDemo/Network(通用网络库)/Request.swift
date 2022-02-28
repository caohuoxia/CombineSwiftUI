//
//  Request.swift
//  CombineDemo
//
//  Created by caohx on 2022/2/28.
//

import Foundation

public enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    
}

// 定义一个通用的请求网络协议
public protocol Request {
    var path: String { get }
    var method: HttpMethod { get }
    var contentType: String { get }
    var body: [String: Any]? { get }
    var headers: [String: String]? { get }
    // 此时的关联属性 很重要
    associatedtype ReturnType: Codable
}

// 扩展设置默认值
extension Request {
    // Defaults
    var method: HttpMethod { return .get }
    var contentType: String { return "application/json" }
    var body: [String: Any]? { return nil }
    var headers :[String: String]? { return nil }
    var queryParams: [String: String]? { return nil }
}

// 扩展可以给现有类型添加新的实例方法和类方法
// requestBodyFrom序列化字典对象，asURLRequest转换成一个URLRequest对象
extension Request {
    private func requestBodyFrom(params: [String: Any]?) -> Data? {
        guard let params = params else {
            return nil
        }
        guard let httpBody = try? JSONSerialization.data(withJSONObject: params, options: []) else {
            return nil
        }
        return httpBody
    }
    
    func asURLRequest(baseURL: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: baseURL) else {
            return nil
        }
        urlComponents.path = "\(urlComponents.path)\(path)"
        guard let finalURL = urlComponents.url else {
            return nil
        }
        var request = URLRequest(url: finalURL)
        request.httpMethod = method.rawValue
        request.httpBody = requestBodyFrom(params: body)
        request.allHTTPHeaderFields = headers
        return request
    }
}

// 扩展添加计算属性。model 转化成 字典
extension Encodable {
    var asDictionary: [String: Any] {
        guard let data = try? JSONEncoder().encode(self) else { return [:] }
        guard let dictionary = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            return [:]
        }
        return dictionary
    }
}
