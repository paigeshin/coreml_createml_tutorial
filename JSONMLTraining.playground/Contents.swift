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



