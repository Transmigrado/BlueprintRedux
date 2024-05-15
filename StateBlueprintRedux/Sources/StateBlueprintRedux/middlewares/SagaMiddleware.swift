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

public protocol SagaProtocol {
    func cancel()
    func run(getState: @escaping () -> AppState?, dispatch: @escaping DispatchFunction, action: Action) -> DispatchWorkItem?
}

open class Saga: SagaProtocol {
    
    private var dispatchWorkItems: [DispatchWorkItem] = []
    
    public init(){}
    
    public func cancel() {
        dispatchWorkItems.forEach{ $0.cancel()}
    }
    
    public func addDispatchWorkItems(workItem: DispatchWorkItem){
        dispatchWorkItems.append(workItem)
    }
    
    open func run(getState: @escaping () -> (any AppState)?, dispatch: @escaping DispatchFunction, action: any Action) -> DispatchWorkItem? {
        return nil
    }
    
    
}

class SagaManager {
   

    func run(getState: @escaping () -> (any AppState)?, dispatch: @escaping DispatchFunction, action: Action, saga: Saga) {
      
        saga.cancel()
        guard let item =  saga.run(getState: getState, dispatch: dispatch, action: action) else { return  }
        saga.addDispatchWorkItems(workItem: item)
        
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
