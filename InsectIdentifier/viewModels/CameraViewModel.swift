//
//  CameraViewModel.swift
//  InsectIdentifier
//
//  Created by Hussnain on 13/03/2025.
//

import AVFoundation
import UIKit

class CameraViewModel: NSObject, ObservableObject {
    @Published var isFlashOn = false
     let session = AVCaptureSession()
    private let output = AVCapturePhotoOutput()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var captureDevice: AVCaptureDevice?
    private var photoCaptureDelegate: PhotoCaptureDelegate?
    
   

     func setupCamera() {
            DispatchQueue.global(qos: .background).async {
                self.session.beginConfiguration()
                
                guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
                    print("No camera found")
                    return
                }
                self.captureDevice = device
                
                do {
                    let input = try AVCaptureDeviceInput(device: device)
                    if self.session.canAddInput(input) { self.session.addInput(input) }
                    if self.session.canAddOutput(self.output) { self.session.addOutput(self.output) }
                } catch {
                    print("Error setting up camera: \(error)")
                    return
                }
                
                self.session.commitConfiguration() 
                
                DispatchQueue.main.async {
                    self.startSession()
                }
            }
        }

    func startSession() {
        DispatchQueue.global(qos: .background).async {
            if !self.session.isRunning {
                self.session.startRunning()
            }
        }
    }

    func stopSession() {
        DispatchQueue.global(qos: .background).async {
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }

    func toggleFlash() {
        guard let device = captureDevice, device.hasTorch else { return }
        do {
            try device.lockForConfiguration()
            if device.torchMode == .on {
                device.torchMode = .off
                isFlashOn = false
            } else {
                device.torchMode = .on
                isFlashOn = true
            }
            device.unlockForConfiguration()
        } catch {
            print("Flash error: \(error)")
        }
    }

    func capturePhoto(completion: @escaping (String?) -> Void) {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = isFlashOn ? .on : .off
        
        // Retain the delegate
        photoCaptureDelegate = PhotoCaptureDelegate(completion: { [weak self] path in
            completion(path)
            self?.photoCaptureDelegate = nil // Release after capture
        })
        
        output.capturePhoto(with: settings, delegate: photoCaptureDelegate!)
    }
}

class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    private let completion: (String?) -> Void

    init(completion: @escaping (String?) -> Void) {
        self.completion = completion
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation() else {
            completion(nil)
            return
        }

        let filename = "Image_\(Date().timeIntervalSince1970).jpeg"
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documents.appendingPathComponent(filename)

        do {
            try data.write(to: fileURL)
            completion(fileURL.path)
        } catch {
            print("Failed to save image: \(error)")
            completion(nil)
        }
    }
}
