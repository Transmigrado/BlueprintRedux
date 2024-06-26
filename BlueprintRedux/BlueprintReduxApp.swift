//
//  BlueprintReduxApp.swift
//  BlueprintRedux
//
//  Created by Jorge Acosta Alvarado on 14-05-24.
//

import SwiftUI
import StateBlueprintRedux
import Combine

struct IncrementAction: Action {}
struct DecrementAction: Action {}

class ConcreteAppState: AppState {
    var count: Int

    init(count: Int) {
        self.count = count
    }
}

class CounterSaga: Saga {
    func run(
        getState: @escaping () -> (any StateBlueprintRedux.AppState)?,
        dispatch: @escaping StateBlueprintRedux.DispatchFunction,
        action: any StateBlueprintRedux.Action,
        cancel: CancellationToken
    ) -> AnyPublisher<Any, any Error>? {
        return Future { promise in
            
              DispatchQueue.global().async {
                  for _ in 0..<5 {
                      if cancel.isCancelled {
                          break 
                      }
                      
                      Thread.sleep(forTimeInterval: 1)
                   
                      DispatchQueue.main.async {
                          dispatch(IncrementAction())
                      }
                  }
                  promise(.success(()))
              }
          }
          .eraseToAnyPublisher()
    }
    
  

}

func createStore() -> Store<ConcreteAppState> {
    
    let initialState = ConcreteAppState(count: 0)
    
    let sagaMiddleware = SagaMiddleware<ConcreteAppState>()
    sagaMiddleware.addSaga(name: "CounterSaga", saga: CounterSaga())

    let store = Store<ConcreteAppState>(initialState: initialState, reducer: { state, action in
        switch action {
        case _ as IncrementAction:
            state.count += 1
        case _ as DecrementAction:
            state.count -= 1
        default:
            break
        }
    }, middlewares: [sagaMiddleware])

    return store
}

@main
struct BlueprintReduxApp: App {
    
    let store = createStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(store)
        }
    }
}

