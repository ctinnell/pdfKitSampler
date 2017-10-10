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
    let textView = UITextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let viewMode = UISegmentedControl(items: ["PDF","Text"])
        viewMode.addTarget(self, action: #selector(changeViewMode), for: .valueChanged)
        viewMode.selectedSegmentIndex = 0
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: viewMode)
        navigationItem.rightBarButtonItem?.width = 150
        
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pdfView)
        pdfView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        pdfView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        pdfView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        pdfView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        textView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textView)
        textView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        textView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        textView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        textView.isEditable = false
        textView.isHidden = true
        textView.textContainerInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)

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
    
    @objc func changeViewMode(segmentedControl: UISegmentedControl) {
        
        if segmentedControl.selectedSegmentIndex == 0 {
            pdfView.isHidden = false
            textView.isHidden = true
        }
        else {
            pdfView.isHidden = true
            textView.isHidden = false
            loadText()
        }
    }
    
    func loadText() {
        guard let pageCount = pdfView.document?.pageCount else { return }
        
        let documentContent = NSMutableAttributedString()
        
        for i in 1 ..< pageCount {
            guard let page = pdfView.document?.page(at: i) else { continue }
            guard let pageContent = page.attributedString else { continue }
            
            let spacer = NSAttributedString(string: "\n\n")
            documentContent.append(spacer)
            documentContent.append(pageContent)
        }
        
        let pattern = "www.hackingwithswift.com [0-9]{1,2}"
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSMakeRange(0, documentContent.string.utf16.count)
        
        if let matches = regex?.matches(in: documentContent.string, options: [], range: range) {
            for match in matches.reversed() {
                documentContent.replaceCharacters(in: match.range, with: "")
            }
        }
        
        textView.attributedText = documentContent
    }
}

extension ViewController: PDFViewDelegate {
    func pdfViewWillClick(onLink sender: PDFView, with url: URL) {
        let vc = SFSafariViewController(url: url)
        vc.modalPresentationStyle = .formSheet
        present(vc, animated: true)
    }
}

