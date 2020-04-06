//
//  ViewController.swift
//  Paknsave Checker
//
//  Created by Charles on 6/04/20.
//  Copyright © 2020 SKY. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var displayLabel: UILabel!
    var timer: Timer!
    var triedTimes: Int! = 0
    let url = URL(string: "https://www.paknsaveonline.co.nz/CommonApi/Delivery/GetClickCollectTimeSlot?id=c0f80e87-16be-4488-9553-da437e8c6c2a")!
    let userNotificationCenter = UNUserNotificationCenter.current()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.displayLabel.text = "Click start button to start checking!"
        
        userNotificationCenter.delegate = self
        let authOptions = UNAuthorizationOptions(arrayLiteral: .alert, .badge, .sound)
        userNotificationCenter.requestAuthorization(options: authOptions) { (success, error) in
            if let error = error {
                print("Error = \(error)")
            }
        }
    }

    @IBAction func start(_ sender: UIButton) {
        startButton.isEnabled = false
        
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { [unowned self] timer in
            self.triedTimes = self.triedTimes + 1
            let task = URLSession.shared.dataTask(with: self.url) { (data, response, error) in
                DispatchQueue.main.async {
                    guard let data = data,
                        error == nil else {
                            return
                    }
                    
                    do {
                        let slots = try JSONDecoder().decode(model.self, from: data).slots
                        for slot in slots {
                            for timeSlot in slot.timeSlots {
                                if timeSlot.available > 0 {
                                    self.sendNotification()
                                    self.displayLabel.text = "You got a slot at \(Date())"
                                    self.timer.invalidate()
                                    return
                                }
                            }
                        }
                        
                        self.displayLabel.text = "tried \(self.triedTimes ?? 0)"
                    } catch {
                        print(error)
                    }
                }
            }
            task.resume()
        })
        
        timer.fire()
    }
    
    
    @IBAction func stop(_ sender: UIButton) {
        startButton.isEnabled = true
        triedTimes = 0
        timer.invalidate()
        self.displayLabel.text = "Click start button to start checking!"
    }
    
    func sendNotification() {
        let content = UNMutableNotificationContent()
        content.title = "PakNSave checker"
        content.body = "You got a slot at \(Date())"
        content.badge = NSNumber(value: 1)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let reqeust = UNNotificationRequest(identifier: "PakNSave checker", content: content, trigger: trigger)
        userNotificationCenter.add(reqeust) { (error) in
            if let error = error {
                print("Notification Error: \(error)")
            }
        }
    }
}


extension ViewController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
}
