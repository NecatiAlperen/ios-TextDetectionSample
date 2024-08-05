//
//  HomeViewController.swift
//  ios-TextDetectionSample
//
//  Created by Necati Alperen IŞIK on 2.08.2024.
//

import UIKit
import Vision


class HomeViewController: UIViewController {


    var recognizedTextArray: [String] = []

    
    private let resultTable: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(ResultCell.self, forCellReuseIdentifier: ResultCell.identifier)
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        
        textDetection()
        

        view.addSubview(resultTable)
        resultTable.dataSource = self
        resultTable.delegate = self
        setupTableViewConstraints()
    }
    
    
    func textDetection() {
        guard let cgImage = UIImage(named: "ex1")?.cgImage else { return }
        
        let textRecognitionRequest = VNRecognizeTextRequest(completionHandler: recognizeTextHandler)
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try requestHandler.perform([textRecognitionRequest])
        } catch {
            print("İstek işlenirken hata  \(error).")
        }
    }
    
    
    func recognizeTextHandler(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNRecognizedTextObservation] else {
            return
        }
        
        let recognizedStrings = observations.compactMap { observation in
            return observation.topCandidates(1).first?.string
        }
        
        recognizedTextArray.append(contentsOf: recognizedStrings)
        
        
        DispatchQueue.main.async {
            self.resultTable.reloadData()
        }
    }

    
    private func setupTableViewConstraints() {
        NSLayoutConstraint.activate([
            resultTable.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            resultTable.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            resultTable.topAnchor.constraint(equalTo: view.topAnchor),
            resultTable.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}


extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recognizedTextArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ResultCell.identifier, for: indexPath) as? ResultCell else {
            return UITableViewCell()
        }
        let recognizedText = recognizedTextArray[indexPath.row]
        cell.configure(with: recognizedText)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
