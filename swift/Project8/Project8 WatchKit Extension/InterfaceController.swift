//
//  InterfaceController.swift
//  Project8 WatchKit Extension
//
//  Created by Jinwoo Kim on 1/27/21.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    @IBOutlet weak var numbersLabel: WKInterfaceLabel!
    @IBOutlet weak var safeValue: WKInterfaceSlider!
    @IBOutlet weak var nextButton: WKInterfaceButton!
    @IBOutlet weak var timer: WKInterfaceTimer!
    
    var currentSafeValue: Float = 50
    var targetSafeValue = 0
    
    var allSafeNumbers = [Int]()
    var correctValues = [String]()

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        startNewGame()
    }
    
    override func didAppear() {
        super.didAppear()
        crownSequencer.focus()
        crownSequencer.delegate = self
    }
    
    func startNewGame() {
        // reset and start the timer
        timer.setDate(Date())
        timer.start()
        
        // create an array of random numbers from 0 to 100
        allSafeNumbers = Array(0...10)
        allSafeNumbers.shuffle()
        
        // reset the current value
        currentSafeValue = 50
        safeValue.setValue(50)
        
        // remove all their previous answers and reset the text
        correctValues.removeAll()
        numbersLabel.setText("Safe Crack")
        
        // pick the first number to guess
        pickNumber()
    }
    
    func pickNumber() {
        targetSafeValue = allSafeNumbers.removeFirst()
        print(targetSafeValue)
        numberIsWrong()
    }
    
    func numberIsWrong() {
        safeValue.setColor(UIColor.red)
        numbersLabel.setTextColor(UIColor.white)
        nextButton.setEnabled(false)
    }

    @IBAction func nextTapped() {
        guard Int(currentSafeValue) == targetSafeValue else { return }
        
        correctValues.append(String(targetSafeValue))
        numbersLabel.setText(correctValues.joined(separator: ", "))
        
        if correctValues.count == 4 {
            timer.stop()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let playAgain = WKAlertAction(title: "Play again", style: .default) {
                    self.startNewGame()
                }
                self.presentAlert(withTitle: "You win!", message: nil, preferredStyle: .alert, actions: [playAgain])
            }
        } else {
            pickNumber()
        }
    }
}

extension InterfaceController: WKCrownDelegate {
    func crownDidRotate(_ crownSequencer: WKCrownSequencer?, rotationalDelta: Double) {
        currentSafeValue += Float(rotationalDelta)
        currentSafeValue = min(max(0, currentSafeValue), 100)
        safeValue.setValue(currentSafeValue)
        nextButton.setTitle("Enter \(Int(currentSafeValue))")
        
        if Int(currentSafeValue) == targetSafeValue {
            // this is the right number - tap their wrist
            WKInterfaceDevice.current().play(.click)
            
            // now update the UI to show this is good
            safeValue.setColor(UIColor.green)
            numbersLabel.setTextColor(UIColor.green)
            nextButton.setEnabled(true)
        } else {
            // wrong number; make the UI show this is bad
            numberIsWrong()
        }
    }
}
