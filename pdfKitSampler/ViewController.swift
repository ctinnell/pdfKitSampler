//
//  ViewController.swift
//  pdfKitSampler
//
//  Created by Tinnell, Clay on 10/7/17.
//  Copyright © 2017 Tinnell, Clay. All rights reserved.
//

import UIKit
import PDFKit

class ViewController: UIViewController {

    let pdfView = PDFView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pdfView)
        pdfView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        pdfView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        pdfView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        pdfView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func load(_ name: String) {
        let filename = name.replacingOccurrences(of: " ", with: "-").lowercased()
        guard let path = Bundle.main.url(forResource: filename, withExtension: "pdf") else { return }
        
        if let document = PDFDocument(url: path) {
            pdfView.document = document
            
            pdfView.goToFirstPage(nil)
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                title = name
            }
        }
    }
    
}

