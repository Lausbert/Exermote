<a href="https://github.com/Lausbert/Exermote/tree/master/ExermotePreprocessingAndTraining">< Exermote Preprocessing and Training</a> | <a href="https://github.com/Lausbert/Exermote/tree/master/ExermoteInference">Exermote Overview ></a>

# Exermote Inference

The model is already built, so let's put it to work!

## Google Cloud ML

Before WWDC 2017 and CoreML I couldn't find a proper way for doing inference diretly on my iPhone. That's why I [implemented my model on Google Cloud ML](https://github.com/Lausbert/Exermote/tree/master/ExermoteInference/ExermoteMachineLearningEngine). Acceleration Data was sent 10 times per second to the cloud, while receiving inference results in the same frequency. This worked suprisingly well! At least for one minute, then it appeared that the iPhone was blocking any further network requests. What a lucky coincidence that Apple introduced CoreML a short time later :)

## CoreML

Since I already exported the model as .mlmodel file, implementing it was quite easy. The interesting line below is ```let predictionOutput = try _predictionModel.prediction(input: input)```, because that is where the calculation is done. Actually initialization of model inputs was the hardest part and as you can see below it is done in a not very ```swifty``` way. Let's hope that this is due the beta status of CoreML.

```swift
func makePredictionRequest(evaluationStep: EvaluationStep) {
        let data = _currentScaledMotionArrays.reduce([], +) //result is of type [Double] with 480 elements
        do {
            let accelerationsMultiArray = try MLMultiArray(shape:[40,1,12], dataType:MLMultiArrayDataType.double)
            for (index, element) in data.enumerated() {
                accelerationsMultiArray[index] = NSNumber(value: element)
            }
            let hiddenStatesMultiArray = try MLMultiArray(shape: [32], dataType: MLMultiArrayDataType.double)
            for index in 0..<32 {
                hiddenStatesMultiArray[index] = NSNumber(integerLiteral: 0)
            }
            let input = PredictionModelInput(accelerations: accelerationsMultiArray, lstm_1_h_in: hiddenStatesMultiArray, lstm_1_c_in: hiddenStatesMultiArray, lstm_2_h_in: hiddenStatesMultiArray, lstm_2_c_in: hiddenStatesMultiArray)
            let predictionOutput = try _predictionModel.prediction(input: input)
            if let scores = [predictionOutput.scores[0], predictionOutput.scores[1], predictionOutput.scores[2], predictionOutput.scores[3]] as? [Double] {
                evaluationStep.exercise = decodePredictionRequest(scores: scores)
            } else {
                print("Could not cast predictionOutput.scores to [Double].")
            }
        }
        catch {
            print(error.localizedDescription)
            self.stopPrediction()
        }
    }
```

The result of my project is a pretty stable exercise recognizer! :)

<p align="center">
<sub><sup>It will take some time until .gif is loaded. Have a look on youtube for the raw <a href="https://www.youtube.com/watch?v=ieoInbYI_TA&feature=youtu.be">video</a> with sound.</sup></sub>
<br>
<img src="https://github.com/Lausbert/Exermote/blob/master/ExermoteInference/ExermoteCoreML/ExampleGif/ExermoteGif.gif">
</p>
