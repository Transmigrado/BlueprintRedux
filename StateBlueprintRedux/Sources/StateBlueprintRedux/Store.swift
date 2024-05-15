//
//  File.swift
//  
//
//  Created by Jorge Acosta Alvarado on 14-05-24.
//

import Foundation
import SwiftUI
import Combine

public protocol Action {}
public protocol AppState {}
public typealias DispatchFunction = (Action) -> Void

public protocol Middleware {
    func process(action: Action, getState: @escaping () -> AppState?, dispatch: @escaping (Action) -> Void)
}

public class Store<T: AppState>: ObservableObject {
    @Published public var state: T
    private var reducer: (inout T, Action) -> Void
    private var middlewares: [Middleware]

    public init(initialState: T, reducer: @escaping (inout T, Action) -> Void, middlewares: [Middleware] = []) {
        state = initialState
        self.reducer = reducer
        self.middlewares = middlewares
    }

    public func dispatch(_ action: Action) {
        
  
        for middleware in middlewares {
            middleware.process(action: action, getState: { self.state }, dispatch: dispatch)
        }

        reducer(&state, action)
    }
    
}

public func select<T, U>(_ keyPath: KeyPath<T, U>, from store: Store<T>) -> U {
    return store.state[keyPath: keyPath]
}
