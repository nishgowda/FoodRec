//
//  ViewController.swift
//  FoodRec
//
//  Created by Nish Gowda on 5/9/20.
//  Copyright © 2020 Nish Gowda. All rights reserved.
//
import UIKit
import AVKit
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    var text : String = ""
    override func viewDidLoad() {
       
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        guard let captureDevice = AVCaptureDevice.default(for: .video) else{return}
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else {return}
        
        captureSession.addInput(input)
        
        captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)

        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "Video"))
        captureSession.addOutput(dataOutput)
        
        let label = UILabel()
        label.frame = CGRect(x: 150, y: 150, width: 100, height: 20)
        label.text = text
        
    }
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        //print("Camera was able to capture a frame", Date())
        guard let pixelBuffer : CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else{return}
       guard let model = try?VNCoreMLModel(for: FoodClassifier().model)
        else{return}
        let request = VNCoreMLRequest(model: model){
            (finishedReq,err) in
            //print(finishedReq.results)
            
            guard let results = finishedReq.results as? [VNClassificationObservation] else{return}
            guard let firstObservation = results.first else{return}
            
            self.text.append("\(firstObservation.identifier)")
        }
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
        
    }


}


