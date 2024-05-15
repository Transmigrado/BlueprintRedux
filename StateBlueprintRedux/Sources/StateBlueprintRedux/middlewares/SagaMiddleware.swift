//
//  File.swift
//  
//
//  Created by Jorge Acosta Alvarado on 14-05-24.
//

import SwiftUI
import Combine

public struct AsyncAction: Action {
    public let sagaName: String
    public let action: Action?
    
    public init(sagaName: String, action: Action? = nil) {
        self.sagaName = sagaName
        self.action = action
    }
}

public protocol Saga {
    func run(getState: @escaping () -> AppState?, dispatch: @escaping DispatchFunction, action: Action)
}

public class SagaMiddleware<T: AppState>: Middleware {
    
    private var runningEffects: [AnyCancellable] = []
    private var sagas: [String: Saga] = [:]
    
    public init(){
        
    }

    public func addSaga(name: String, saga: Saga) {
        sagas[name] = saga
    }

    public func process(action: Action, getState: @escaping () -> (any AppState)?, dispatch: @escaping (any Action) -> Void) {
      
        if let startSagaAction = action as? AsyncAction {
 
            if let saga = sagas[startSagaAction.sagaName] {
                saga.run(getState: getState, dispatch: dispatch, action: action)
            }
        }
    }
}
