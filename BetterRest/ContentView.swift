//
//  ContentView.swift
//  BetterRest
//
//  Created by Raoul Gioia on 29/05/2020.
//  Copyright © 2020 Raoul Gioia. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }
    
    let model = SleepCalculator()
    
    @State private var wakeUp = Self.defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    private var coffeeAmounts = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    var sleepTime: String {
        guard let sleepTime = calculateBedtime() else {
            showingAlert = true
            return ""
        }
        return sleepTime
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Your ideal bedtime is…")
                    .font(.largeTitle)
                    .fontWeight(.regular)) {
                        Text("\(sleepTime)")
                }
                
                Section(header: Text("When do you want to wake up?").font(.headline)) {
                   DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .datePickerStyle(WheelDatePickerStyle())
                }
                
                Section(header: Text("Desired amount of sleep").font(.headline)) {
                    Stepper(value: $sleepAmount, in: 4...12, step: 0.25) {
                        Text("\(sleepAmount, specifier: "%g") hours")
                    }
                }
                
                Section(header: Text("Daily coffee intake").font(.headline)) {
                    Picker("\(coffeeAmount+1) " + (coffeeAmount == 0 ?  "cup" : "cups"), selection: $coffeeAmount) {
                        ForEach(0 ..< coffeeAmounts.count) {
                            Text("\(self.coffeeAmounts[$0])")
                        }
                    }
                }
            }
            .navigationBarTitle("BetterRest")
            .alert(isPresented: $showingAlert) {
                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    func calculateBedtime() -> String? {
        do {
            let actualSleep = try model.prediction(wake: { let components = Calendar.current.dateComponents([.hour, .minute], from: $0)
                                                          let hour = (components.hour ?? 0) * 3600
                                                          let minute = (components.minute ?? 0) * 60
                                                          return Double(hour + minute)
                                                        }(wakeUp),
                                                  estimatedSleep: sleepAmount,                
                                                  coffee: Double(coffeeAmount)).actualSleep
            
            return { let formatter = DateFormatter()
                formatter.timeStyle = .short
                return formatter.string(from: $0)
            }(wakeUp - actualSleep)
                       
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime."
        }
        
        return nil
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
