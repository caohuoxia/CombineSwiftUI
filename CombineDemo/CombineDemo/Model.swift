//
//  Model.swift
//  CombineDemo
//
//  Created by caohx on 2022/2/28.
//

import Foundation

struct UserModel: Codable {
    var id: Int
}

struct PostModel: Codable {
    var body: String
}

/* ========= 以下是测试通用网络库 =========*/
struct GetUser: Request {
    typealias ReturnType = UserModel
    var path = "/users/"
    
    var index: String
    init(index: String) {
        self.index = index
        self.path = self.path + self.index
    }
}

struct GetPost: Request {
    typealias ReturnType = PostModel
    var path = "/posts/"
    
    var userid: String
    init(userid: String) {
        self.userid = userid
        self.path = self.path + self.userid
    }
}

struct GetUsers: Request {
    typealias ReturnType = [UserModel]
    var path = "/users/"
}


