//
//  ScannerViewController.swift
//  ios-TextDetectionSample
//
//  Created by Necati Alperen IŞIK on 2.08.2024.
//


import UIKit
import Vision
import AVFoundation

class ScannerViewController: UIViewController {
    
    private lazy var resultStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .center
        return stackView
    }()
    
    private lazy var resultBackground: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        return view
    }()
    
    private var captureSession: AVCaptureSession?
    private var detectedCardNumber: String?
    private var detectedSKT: String?
    private var detectedName: String?
    private var detectedIBAN: String?
    
    // Ignore list
    private let ignoreList = ["VALID", "THRU", "VALIO", "THRO","BANK","BANKA","CARD","KART","FINANS","IBAN"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        view.backgroundColor = .white
        
        setupCamera()
        setupUI()
        configureCameraSettings()
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "Kart Tarayıcı"
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshScan))
        navigationItem.rightBarButtonItem = refreshButton
    }
    
    @objc private func refreshScan() {
        resetResults()
        startSession()
    }
    
    private func resetResults() {
        detectedCardNumber = nil
        detectedSKT = nil
        detectedName = nil
        detectedIBAN = nil
        resultStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
    
    private func setupUI() {
        view.addSubview(resultBackground)
        view.addSubview(resultStackView)
        
        NSLayoutConstraint.activate([
            resultStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            resultStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            resultStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
            
            resultBackground.leadingAnchor.constraint(equalTo: resultStackView.leadingAnchor),
            resultBackground.trailingAnchor.constraint(equalTo: resultStackView.trailingAnchor),
            resultBackground.topAnchor.constraint(equalTo: resultStackView.topAnchor),
            resultBackground.bottomAnchor.constraint(equalTo: resultStackView.bottomAnchor)
        ])
    }
    private func startSession() {
        captureSession?.startRunning()
    }

    
    private func setupCamera() {
        captureSession = AVCaptureSession()
        guard let captureSession = captureSession else { return }
        
        guard let videoCaptureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            return
        }
        
        let videoOutput = AVCaptureVideoDataOutput()
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        view.layer.addSublayer(previewLayer)
        
        startSession()
    }
    
    private func configureCameraSettings() {
        guard let videoCaptureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return }
        
        do {
            try videoCaptureDevice.lockForConfiguration()
            
            if videoCaptureDevice.isWhiteBalanceModeSupported(.continuousAutoWhiteBalance) {
                videoCaptureDevice.whiteBalanceMode = .continuousAutoWhiteBalance
            }
            
            if videoCaptureDevice.isExposureModeSupported(.continuousAutoExposure) {
                videoCaptureDevice.exposureMode = .continuousAutoExposure
            }
            
            
            if videoCaptureDevice.isFocusModeSupported(.continuousAutoFocus) {
                videoCaptureDevice.focusMode = .continuousAutoFocus
            }
            
            videoCaptureDevice.unlockForConfiguration()
        } catch {
            print("Error configuring camera: \(error)")
        }
    }

    private func preprocessImage(_ image: CIImage) -> CIImage? {
        let filter = CIFilter(name: "CIExposureAdjust")
        filter?.setValue(image, forKey: kCIInputImageKey)
        filter?.setValue(0.7, forKey: kCIInputEVKey)

        if let outputImage = filter?.outputImage {
            let context = CIContext(options: nil)
            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                return CIImage(cgImage: cgImage)
            }
        }
        return nil
    }
    
    private func detectText(in image: CVPixelBuffer) {
        let request = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            
            for observation in observations {
                guard let recognizedText = observation.topCandidates(1).first?.string else { continue }
                
                // Kart numarası formatı (xxxx xxxx xxxx xxxx)
                if recognizedText.range(of: #"^\d{4} \d{4} \d{4} \d{4}$"#, options: .regularExpression) != nil, self.detectedCardNumber == nil {
                    self.detectedCardNumber = recognizedText
                    self.displayDetectedInfo("Kart Numarası: \(recognizedText)")
                }
                
                // SKT formatı
                if recognizedText.range(of: #"^(0[1-9]|1[0-2])\/([2-9][0-9]{1,3})$"#, options: .regularExpression) != nil, self.detectedSKT == nil {
                    self.detectedSKT = recognizedText
                    self.displayDetectedInfo("SKT: \(recognizedText)")
                }

                // İsim formatı
                if self.detectedName == nil,
                   !self.ignoreList.contains(where: recognizedText.contains),
                   recognizedText.range(of: #"^[A-ZÇĞİÖŞÜ]{2,}\s+[A-ZÇĞİÖŞÜ]{2,}(?:\s[A-ZÇĞİÖŞÜ]+)*$"#, options: .regularExpression) != nil {
                    self.detectedName = recognizedText
                    self.displayDetectedInfo("İsim: \(recognizedText)")
                }
                
                // IBAN
                if recognizedText.range(of: #"^TR\d{24}$"#, options: .regularExpression) != nil, self.detectedIBAN == nil {
                    self.detectedIBAN = recognizedText
                    self.displayDetectedInfo("IBAN: \(recognizedText)")
                }
            }
        }
        
        
        request.recognitionLevel = .accurate // .fast
        request.recognitionLanguages = ["tr-TR"]
        request.usesLanguageCorrection = true
        
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: image, options: [:])
        do {
            try requestHandler.perform([request])
        } catch {
            print("Failed to perform text detection: \(error.localizedDescription)")
        }
    }
    
    private func displayDetectedInfo(_ info: String) {
        DispatchQueue.main.async {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.numberOfLines = 0
            label.textAlignment = .center
            label.text = info
            self.resultStackView.addArrangedSubview(label)
        }
    }
}

extension ScannerViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        if detectedCardNumber == nil || detectedSKT == nil || detectedName == nil || detectedIBAN == nil {
            detectText(in: pixelBuffer)
        }
    }
}

