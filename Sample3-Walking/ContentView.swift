//
//  ContentView.swift
//  Sample3-Walking
//
//  Created by keiji yamaki on 2021/01/04.
//

import SwiftUI
import CoreMotion

class MyPedometer: NSObject, ObservableObject {
    
    @Published var isStarted = false
    @Published var isWalking = false
    @Published var count = 0
    @Published var distance = 0.0
    
    let pedometer = CMPedometer()

    func start() {
        
        guard !isStarted else {
            return
        }
        isStarted = true
            
        pedometer.startEventUpdates { (event, error) in
            guard error == nil else {
                print("error: \(String(describing: error))")
                return
            }
            
            DispatchQueue.main.async {
                if event!.type == CMPedometerEventType.pause {
                    self.isWalking = false
                } else {
                    self.isWalking = true
                }
            }
        }
        
        pedometer.startUpdates(from: Date()) { (data, error) in
            guard error == nil else {
                print("error \(String(describing: error))")
                return
            }
            
            DispatchQueue.main.async {
                self.count = data?.numberOfSteps as! Int
                self.distance = data?.distance as! Double
            }
        }
        
    }
    
    func stop() {
        
        guard isStarted else {
            return
        }
        
        isStarted = false
        
        pedometer.stopUpdates()
        pedometer.stopEventUpdates()
    }
    
}

struct ContentView: View {
    @ObservedObject var pedometer = MyPedometer()
    
    var body: some View {
        VStack {
            if self.pedometer.isWalking {
                Text("WALKING")
            } else {
                Text("STOPPED")
            }
            Text("\(self.pedometer.count)")
            Text("\(self.pedometer.distance)")
            Button(action: {
                if !self.pedometer.isStarted {
                    self.pedometer.start()
                } else {
                    self.pedometer.stop()
                }
            }) {
                if !self.pedometer.isStarted {
                    Text("スタート")
                } else {
                    Text("ストップ")
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
