//
//  BlueprintReduxApp.swift
//  BlueprintRedux
//
//  Created by Jorge Acosta Alvarado on 14-05-24.
//

import SwiftUI
import StateBlueprintRedux

struct IncrementAction: Action {}
struct DecrementAction: Action {}

class ConcreteAppState: AppState {
    var count: Int

    init(count: Int) {
        self.count = count
    }
}

class CounterSaga: Saga {
  
    override func run(getState: @escaping () -> AppState?, dispatch: @escaping DispatchFunction, action: Action) -> DispatchWorkItem? {
        
        let item = DispatchWorkItem {
           
            for _ in 0..<5 {
              
                Thread.sleep(forTimeInterval: 1)

                DispatchQueue.main.async {
                    
                    dispatch(IncrementAction())
                }
            }
        }

        DispatchQueue.global().async(execute: item)

        return item
        
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

