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

    func run(getState: @escaping () -> AppState?, dispatch: @escaping DispatchFunction, action: Action, cancel: CancellationToken) -> AnyPublisher<Any, Error>?
}

public class CancellationToken {
    private var _isCancelled: Bool = false
    public var isCancelled: Bool {
        return _isCancelled
    }

    func cancel() {
        _isCancelled = true
    }
}

class SagaManager {
   
    var publishers: [AnyCancellable] = []

    func run(getState: @escaping () -> (any AppState)?, dispatch: @escaping DispatchFunction, action: Action, saga: Saga) {
      
        publishers.forEach {
            $0.cancel()
        }
        publishers = []
        let cancellationToken = CancellationToken()
        guard let item =  saga.run(getState: getState, dispatch: dispatch, action: action, cancel: cancellationToken)?
            .handleEvents(receiveCancel: {
                  cancellationToken.cancel()
              })
            .sink(receiveCompletion: { item in
        
            }, receiveValue: { item in
               
            }) else { return  }
      
        
        publishers.append(item)
   }
}


public class SagaMiddleware<T: AppState>: Middleware {
    
    private var sagaManager = SagaManager()
   
    private var sagas: [String: Saga] = [:]
    
    public init(){
        
    }

    public func addSaga(name: String, saga: Saga) {
        sagas[name] = saga
    }

    public func process(action: Action, getState: @escaping () -> (any AppState)?, dispatch: @escaping (any Action) -> Void) {
      
        if let startSagaAction = action as? AsyncAction {
 
            if let saga = sagas[startSagaAction.sagaName] {
                sagaManager.run(getState: getState, dispatch: dispatch, action: action, saga: saga)
            }
        }
    }
}
