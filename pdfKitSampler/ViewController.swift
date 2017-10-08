//
//  ViewController.swift
//  pdfKitSampler
//
//  Created by Tinnell, Clay on 10/7/17.
//  Copyright © 2017 Tinnell, Clay. All rights reserved.
//

import UIKit
import PDFKit
import SafariServices

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
        
        let previous = UIBarButtonItem(barButtonSystemItem: .rewind, target: pdfView, action: #selector(PDFView.goToPreviousPage(_:)))
        let next = UIBarButtonItem(barButtonSystemItem: .fastForward, target: pdfView, action: #selector(PDFView.goToNextPage(_:)))
        let search = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(promptForSearch))
        let share = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareSelection))
        navigationItem.leftBarButtonItems = [previous, next, search, share]

        pdfView.autoScales = true
        pdfView.delegate = self
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
    
    @objc func promptForSearch() {
        let alert = UIAlertController(title: "Search", message: nil, preferredStyle: .alert)
        
        alert.addTextField()
        alert.addAction(UIAlertAction(title: "Search", style: .default, handler: { (action) in
            guard let searchText = alert.textFields?[0].text else { return }
            
            guard let match = self.pdfView.document?.findString(searchText, withOptions: .caseInsensitive) else { return }
            
            self.pdfView.highlightedSelections = match
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    @objc func shareSelection(sender: UIBarButtonItem) {
        guard let selection = pdfView.currentSelection?.attributedString else {
            let alert = UIAlertController(title: "Please select some text to share.", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true)
            return
        }
        
        let vc = UIActivityViewController(activityItems: [selection], applicationActivities: nil)
        vc.popoverPresentationController?.barButtonItem = sender
        present(vc, animated: true)
    }
}

extension ViewController: PDFViewDelegate {
    func pdfViewWillClick(onLink sender: PDFView, with url: URL) {
        let vc = SFSafariViewController(url: url)
        vc.modalPresentationStyle = .formSheet
        present(vc, animated: true)
    }
}

