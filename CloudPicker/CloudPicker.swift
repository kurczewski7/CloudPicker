//
//  CloudPicker.swift
//  CloudPicker
//
//  Created by Slawek Kurczewski on 25/02/2020.
//  Copyright © 2020 Slawomir Kurczewski. All rights reserved.
//

import UIKit
import MobileCoreServices

protocol CloudPickerDeleate {
    func documentsPicked(documents: [CloudPicker.Document]?)
}
class CloudPicker: NSObject {
    var delegate: CloudPickerDeleate?
    private var pickerController: UIDocumentPickerViewController?
    private weak var presentationController: UIViewController?
    private var folderUrl: URL?
    private var typeOfSource: TypeOfSource!
    private var documents = [Document]()
    
    enum TypeOfSource: Int {
        case folders
        case files
    }
    class Document: UIDocument {
        var data: Data?
        override func contents(forType typeName: String) throws -> Any {
            guard let data = data else {  return Data()   }
            return try NSKeyedArchiver.archivedData(withRootObject: data, requiringSecureCoding: true)
        }
        override func load(fromContents contents: Any, ofType typeName: String?) throws {
            guard let data = contents as? Data else {   return   }
            self.data = data
        }
    }

    init(presentationController: UIViewController) {
        super.init()
        self.presentationController = presentationController
    }
    public func folderAction(for type: TypeOfSource, title: String) -> UIAlertAction? {
        let action = UIAlertAction(title: title, style: .default) { (alertAction) in
            self.pickerController = UIDocumentPickerViewController(documentTypes: [kUTTypeFolder as String], in:    .open)
            self.pickerController?.delegate = self
            self.typeOfSource = type
            self.presentationController?.present(self.pickerController!, animated: true)
        }
        return action
    }
    public func fileAction(for type: TypeOfSource, title: String) -> UIAlertAction? {
        let action = UIAlertAction(title: title, style: .default) { (alertAction) in
            //let keyArray = [kUTTypePDF, kUTTypeText,kUTTypeBMP, kUTTypePNG, kUTTypeArchive, kUTTypeZipArchive] as [String]
            let keyArray = [kUTTypeMovie as String, kUTTypeImage as String]
            self.pickerController = UIDocumentPickerViewController(documentTypes: keyArray, in:    .open)
            self.pickerController?.delegate = self
            self.pickerController?.allowsMultipleSelection = true
            self.typeOfSource = type
            self.presentationController?.present(self.pickerController!, animated: true)
        }
        return action
    }
    public func present(from soureView: UIView) {
        let allertController = UIAlertController(title: "Select from", message: nil, preferredStyle: .actionSheet)
        if let action = self.folderAction(for: .files, title: "Files") {
            allertController.addAction(action)
        }
        if let action = self.folderAction(for: .folders, title: "Folder") {
            allertController.addAction(action)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        allertController.addAction(cancel)

        if UIDevice.current.userInterfaceIdiom == .pad {
            allertController.popoverPresentationController?.sourceView = soureView
            allertController.popoverPresentationController?.sourceRect = soureView.bounds
            allertController.popoverPresentationController?.permittedArrowDirections = [ .down, .up]
        }
        self.presentationController?.present(allertController, animated: true)
    }
}
extension CloudPicker: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else {  return  }
        print("urls:\(urls), count:\(urls.count)")
        documentFromURL(pickedURL: url)
        delegate?.documentsPicked(documents: documents)
        print("documents count:\(documents.count)")
    }
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("Cancel picker")
        delegate?.documentsPicked(documents: nil)
    }
    private func documentFromURL(pickedURL: URL) {
        let shouldStopAccessing = pickedURL.startAccessingSecurityScopedResource()
        defer {
            if shouldStopAccessing {
                pickedURL.stopAccessingSecurityScopedResource()
            }
        }
        
        NSFileCoordinator().coordinate(readingItemAt: pickedURL, error: NSErrorPointer.none) { (folderURL) in

        do {
            let keys: [URLResourceKey] = [.nameKey, .isDirectoryKey]
            let fileList = try FileManager.default.enumerator(at: pickedURL, includingPropertiesForKeys: keys)

            switch typeOfSource {
                case .files:
                    let document = Document(fileURL: pickedURL)
                    documents.append(document)
                
                case .folders:
                    for case let fileURL as URL in fileList! {
                        if !isUrlDirectory(fileURL) {
                            let document = Document(fileURL: fileURL)
                            documents.append(document)
                        }
                    }
                case .none:
                    break
            }

        } catch let error {
            print("error: ", error.localizedDescription)
        }

      }
    }
//   private func documentFromURL(pickedURL: URL) {
//          let shouldStopAccessing = pickedURL.startAccessingSecurityScopedResource()
//          defer {
//              if shouldStopAccessing {
//                  pickedURL.stopAccessingSecurityScopedResource()
//              }
//          }
//          NSFileCoordinator().coordinate(readingItemAt: pickedURL, error: NSErrorPointer.none) { (folderURL) in
//                  do {
//                      let keys: [URLResourceKey] = [.nameKey, .isDirectoryKey]
//                      let fileList = FileManager.default.enumerator(at: pickedURL, includingPropertiesForKeys: keys)
//
//                      switch typeOfSource {
//                      case .files:
//                          let document = Document(fileURL: pickedURL)
//                          documents.append(document)
//
//                      case .folders:
//                          for case let fileURL as URL in fileList! {
//                              if !isUrlDirectory(fileURL) {
//                                  let document = Document(fileURL: fileURL)
//                                  documents.append(document)
//                              }
//                          }
//                      case .none:
//                          break
//                    }
//                  }
//
//            }
    func isUrlDirectory(_ url: URL) -> Bool {
        let resUrl = try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory
        if let myUrl = resUrl {
            return myUrl
        }
        else {
            return false
        }
    }
}
