[https://www.youtube.com/watch?v=x9_BG2q7XYw&t=4258s](https://www.youtube.com/watch?v=x9_BG2q7XYw&t=4258s)

```swift
// CreateML => Makes Model
// CoreML => Consumes Model
import CreateML
import Foundation

// Load JSON File into MLDataTable
let data = try MLDataTable(contentsOf: URL(fileURLWithPath: "/Users/paige/Desktop/JSONMLTraining.playground/Resources/better-sleep.json"))

// 80% of my data to be trained , 20% of my data to be tested
// 80% is common value
let (trainingData, testingData) = data.randomSplit(by: 0.8)

// target column => what data to be figured out based on other columns
// Use an MLRegressor to estimate continuous values like price, time, or temperature.
/*
 {
     "wake": 32400,
     "estimatedSleep": 5,
     "coffee": 2,
     "actualSleep": 20180
 }
 */
let regressor = try MLRegressor(trainingData: trainingData, targetColumn: "actualSleep")
// Testing Data..
let evaluationMetrics = regressor.evaluation(on: testingData)

// How far the average is off, Mean Error
// 3, 3, 3 = 3 + 3 + 3 = 9 = sqrt(9) = 3
// 2, 3, 4 => 4, 9, 16 => 29 => sqrt(29) => 3.2, bigger the number is, bigger the weight
print(evaluationMetrics.rootMeanSquaredError) //179.64540784526716

// Evaluates how good this data is, find the biggest possible value
// Largest Difference
print(evaluationMetrics.maximumError) //698.6751010852458

// Give Metadata
let metadata = MLModelMetadata(author: "Paige Shin", shortDescription: "A model trained to predict optimum sleep times for coffee drinkers", version: "1.0")

// Crete mlmodel
try regressor.write(to: URL(fileURLWithPath: "/Users/paige/Desktop/JSONMLTraining.playground/Resources/SleepCalculator.mlmodel"), metadata: metadata)
```

- Drag and Drop on Xcode Project

```swift
//
//  ViewController.swift
//  BetterRest
//
//  Created by paige on 2021/12/13.
//

import UIKit

class ViewController: UIViewController {

    private var wakeUpTime: UIDatePicker!
    private var sleepAmountTime: UIStepper!
    private var sleepAmountLabel: UILabel!
    private var coffeeAmountStepper: UIStepper!
    private var coffeeAmountLabel: UILabel!

    override func loadView() {
        view = UIView()
        view.backgroundColor = .white

        let mainStackView = UIStackView()
        mainStackView.axis = .vertical
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainStackView)

        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 20),
            mainStackView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor)
        ])

        let wakeUpTitle = UILabel()
        wakeUpTitle.font = UIFont.preferredFont(forTextStyle: .headline)
        wakeUpTitle.numberOfLines = 0
        wakeUpTitle.text = "When do you want to wake up?"
        mainStackView.addArrangedSubview(wakeUpTitle)

        wakeUpTime = UIDatePicker()
        wakeUpTime.datePickerMode = .time
        wakeUpTime.minuteInterval = 15
        wakeUpTime.preferredDatePickerStyle = .wheels
        mainStackView.addArrangedSubview(wakeUpTime)

        var components = Calendar.current.dateComponents([.hour, .minute], from: Date())
        components.hour = 8
        components.minute = 0
        wakeUpTime.date = Calendar.current.date(from: components) ?? Date()

        let sleepTitle = UILabel()
        sleepTitle.font = UIFont.preferredFont(forTextStyle: .headline)
        sleepTitle.numberOfLines = 0
        sleepTitle.text = "What's the minimum amount of sleep you need?"
        mainStackView.addArrangedSubview(sleepTitle)

        sleepAmountTime = UIStepper()
        sleepAmountTime.addTarget(self, action: #selector(sleepAmountChanged), for: .valueChanged)
        sleepAmountTime.stepValue = 0.25
        sleepAmountTime.value = 8
        sleepAmountTime.minimumValue = 4
        sleepAmountTime.maximumValue = 12

        sleepAmountLabel = UILabel()
        sleepAmountLabel.font = UIFont.preferredFont(forTextStyle: .body)

        let sleepStackView = UIStackView()
        sleepStackView.spacing = 20
        sleepStackView.addArrangedSubview(sleepAmountTime)
        sleepStackView.addArrangedSubview(sleepAmountLabel)
        mainStackView.addArrangedSubview(sleepStackView)

        let coffeeTitle = UILabel()
        coffeeTitle.font = UIFont.preferredFont(forTextStyle: .headline)
        coffeeTitle.numberOfLines = 0
        coffeeTitle.text = "How much coffee do you drink each day?"
        mainStackView.addArrangedSubview(coffeeTitle)

        coffeeAmountStepper = UIStepper()
        coffeeAmountStepper.addTarget(self, action: #selector(coffeeAmountChanged), for: .valueChanged)
        coffeeAmountStepper.maximumValue = 1
        coffeeAmountStepper.maximumValue = 20

        coffeeAmountLabel = UILabel()
        coffeeAmountLabel.font = UIFont.preferredFont(forTextStyle: .body)

        let coffeeStackView = UIStackView()
        coffeeStackView.spacing = 20
        coffeeStackView.addArrangedSubview(coffeeAmountStepper)
        coffeeStackView.addArrangedSubview(coffeeAmountLabel)
        mainStackView.addArrangedSubview(coffeeStackView)

        mainStackView.setCustomSpacing(10, after: sleepTitle)
        mainStackView.setCustomSpacing(20, after: sleepStackView)
        mainStackView.setCustomSpacing(10, after: coffeeTitle)

        sleepAmountChanged()
        coffeeAmountChanged()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Better Rest"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Calculate", style: .plain, target: self, action: #selector(calculateBedtime))
    }

    @objc
    private func sleepAmountChanged() {
        sleepAmountLabel.text = String(format: "%g hours", sleepAmountTime.value)
    }

    @objc
    private func coffeeAmountChanged() {
        if coffeeAmountStepper.value == 1 {
            coffeeAmountLabel.text = "1 cup"
        } else {
            coffeeAmountLabel.text = "\(Int(coffeeAmountStepper.value)) cups"
        }
    }

    @objc
    private func calculateBedtime() {

        let title: String
        let message: String

        do {

            let model = try SleepCalculator.init(configuration: .init()) // Auto generated class

            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUpTime.date)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60

            let prediction = try model.prediction(coffee: coffeeAmountStepper.value, estimatedSleep: sleepAmountTime.value, wake: Double(hour + minute))

            let formatter = DateFormatter()
            formatter.timeStyle = .short

            let wakeDate = wakeUpTime.date - prediction.actualSleep
            message = formatter.string(from: wakeDate)

            title = "Your ideal bedtime is..."
        } catch {

            title = "Error"
            message = "Sorry, there was a problem calculating your bedtime."

        }

        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)

    }

}
```
