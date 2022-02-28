//
//  ContentView.swift
//  CombineDemo
//
//  Created by caohx on 2022/2/28.
//

import SwiftUI
import Combine

struct ContentView: View {
    @StateObject var vm = ViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10){
            Text(vm.errMessage).bold()
            HStack {
                TextField("input index", text: $vm.index)
                    .frame(width: 100)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .padding()
                Button(action: {
//                    vm.getUserSubject.send(index)
                    vm.subject2()
                }, label: {
                    Text("Get user and post")
                })
                .frame(width: 150, height: 50)
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(3.0)
                .padding()
            }
            Text(vm.message).bold()
        }
    }
}

extension ContentView {
    class ViewModel: ObservableObject {
        // 这里不能用@State,用@Published；
        // 且绑定取值的时候由vm.$index改成$vm.index
        @Published var index: String = ""
        
        @Published var message: String = ""
        @Published var errMessage: String = ""
        var cancelables = Set<AnyCancellable>()
        var getUserSubject = PassthroughSubject<String,Never>()
        init() {
            subject1()
        }
        
        // 第二种网络请求方式
        func subject2() {
            APIClient.shared.dispatch(GetUser(index: index))
                .flatMap({ user in
                    APIClient.shared.dispatch(GetPost(userid: String(user.id)))
                })
                .sink { _ in
                } receiveValue: { [weak self] post in
                    print("请求到的post.body为\(post.body)")
                    self?.message = post.body
                }.store(in: &cancelables)
        }
        
        // 第一种网络请求方式
        func subject1() {
            getUserSubject
                .map { NetworkService.shared.fetchUser(index: $0) }
                .switchToLatest()
                .catch { error -> AnyPublisher<UserModel,Error> in
                    Fail(error: error).eraseToAnyPublisher()
                }.flatMap { userModel -> AnyPublisher<PostModel,Error> in
                    print("begin get post")
                    return NetworkService.shared.fetchPost(userid: String(userModel.id))
                }.catch { error -> AnyPublisher<PostModel,Error> in
                    Fail(error: error).eraseToAnyPublisher()
                }.receive(on: RunLoop.main)
                .sink { completion in
                    switch completion {
                    case .failure(let error):
                        self.errMessage = (error as! NetworkError).description
                    default:
                        print(completion)
                    }
                } receiveValue: { [weak self] postModel in
                    self?.message = postModel.body
                }.store(in: &cancelables)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
