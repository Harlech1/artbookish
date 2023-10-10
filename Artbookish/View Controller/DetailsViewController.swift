//
//  DetailsViewController.swift
//  Artbookish
//
//  Created by Türker Kızılcık on 4.10.2023.
//

import UIKit
import CoreData

class DetailsViewController: UIViewController , UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    
    var chosenNote = ""
    var chosenNoteId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleTextField.layer.borderColor = UIColor.gray.cgColor
        
        contentTextView.isScrollEnabled = true
        contentTextView.layer.cornerRadius = 10.0
        contentTextView.layer.borderWidth = 0.1
        contentTextView.layer.borderColor = UIColor.systemGray.cgColor
        contentTextView.layer.masksToBounds = true
        placeholderLabel.text = "Content"
        placeholderLabel.textColor = UIColor.lightGray
        contentTextView.delegate = self
        
        if chosenNote != "" {
                
        //saveButton.isEnabled = false
        saveButton.isHidden = true
                
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Notes")
                
        let idString = chosenNoteId?.uuidString
                
        fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
                
        fetchRequest.returnsObjectsAsFaults = false
                
        do {
            let results = try context.fetch(fetchRequest)
                    
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                if let title = result.value(forKey: "title") as? String {
                    titleTextField.text = title
                }
                if let content = result.value(forKey: "content")as? String {
                    contentTextView.text = content
                }
                if let imageData = result.value(forKey: "image")as? Data {
                    let image = UIImage(data: imageData)
                    imageView.image = image
                }
            }
        }
            
        } catch {
            print("error")
        }
    } else {
            saveButton.isHidden = false
            saveButton.isEnabled = false
            titleTextField.text = ""
            contentTextView.text = ""
    }
            
        //Recognizers

        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
            
        imageView.isUserInteractionEnabled = true
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
                
        imageView.addGestureRecognizer(imageTapRecognizer)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        showPlaceholderIfNeeded()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        showPlaceholderIfNeeded()
    }

        // Placeholder'ı göster veya gizle
    func showPlaceholderIfNeeded() {
        placeholderLabel.isHidden = !contentTextView.text.isEmpty
    }
    
    
    @objc func selectImage() {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .photoLibrary
            picker.allowsEditing = true
            present(picker, animated: true, completion: nil)
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            imageView.image = info[.originalImage] as? UIImage
            saveButton.isEnabled = true
            self.dismiss(animated: true, completion: nil)
        }
        
        @objc func hideKeyboard() {
            view.endEditing(true)
        }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                
                let newNote = NSEntityDescription.insertNewObject(forEntityName: "Notes", into: context)
                
                //Attributes
                
                newNote.setValue(titleTextField.text!, forKey: "title")
                newNote.setValue(contentTextView.text!, forKey: "content")
                
                newNote.setValue(UUID(), forKey: "id")
                
                let data = imageView.image!.jpegData(compressionQuality: 0.5)
                
                newNote.setValue(data, forKey: "image")
                
                do {
                    try context.save()
                    print("success")
                } catch {
                    print("error")
                }
                
                NotificationCenter.default.post(name: NSNotification.Name("newData"), object:nil)
                self.navigationController?.popViewController(animated: true)
    }
    
}
