//
//  ContentView.swift
//  BlueprintRedux
//
//  Created by Jorge Acosta Alvarado on 14-05-24.
//

import SwiftUI
import StateBlueprintRedux

struct ContentView: View {
    @EnvironmentObject var store: Store<ConcreteAppState>
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world! \(store.state.count)")
            Button("Increment"){
                store.dispatch(AsyncAction(sagaName: "CounterSaga", action: nil))
            }
        }
        .padding()
        .onAppear {
           
            
           
        }
        
    }
}

#Preview {
    ContentView()
}
