//
//  NewImageViewController.swift
//  digidentity2
//
//  Created by Adam Lovastyik on 16/03/2019.
//  Copyright © 2019 Lovastyik. All rights reserved.
//

import UIKit
import SwiftyTesseract
import MBProgressHUD

class NewImageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var confidenceLabel: UILabel!
    @IBOutlet weak var confidenceTextField: UITextField!
    
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var uploadButton: UIButton!
    
    private var hud: MBProgressHUD?
    
    private let maxImageSize = CGSize(width: 512, height: 512)
    
    // MARK: - Controller Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        setupUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        finishEditing()
        hud?.hide(animated: false)
    }
    
    // MARK: - UI Customization
    
    private func setupUI() {
        
        title = NSLocalizedString("New Image", comment: "Navigation title on new image screen")
        
        setupButtons()
        setupImageView()
        setupTextView()
        setupConfidence()
    }
    
    private func setupButtons() {
        
        selectButton.setTitle(NSLocalizedString("Select image", comment: "Select button title on new image screen"), for: .normal)
        uploadButton.setTitle(NSLocalizedString("Upload", comment: "Upload button title on new image screen"), for: .normal)
    }
    
    private func setupImageView() {
        
        imageView.image = nil
        imageView.layer.borderWidth = 0.5
        imageView.layer.borderColor = UIColor.darkGray.cgColor
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor.clear
    }
    
    private func setupTextView() {
        
        textView.text = nil
        textView.layer.borderWidth = 0.5
        textView.layer.borderColor = UIColor.darkGray.cgColor
        textView.clipsToBounds = true
        textView.backgroundColor = UIColor.clear
    }
    
    private func setupConfidence() {
        
        confidenceLabel.text = NSLocalizedString("Confidence:", comment: "Confidence static label title")
        
        confidenceTextField.text = nil
        confidenceTextField.placeholder = NSLocalizedString("Enter confidence", comment: "Confidence text field placeholder")
    }
    
    private func show(message: String) {
        
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK button title"), style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func finishEditing() {
        
        confidenceTextField.resignFirstResponder()
        textView.resignFirstResponder()
    }
    
    private func toggleUserInteraction(enabled: Bool) {
        
        confidenceTextField.isEnabled = enabled
        textView.isUserInteractionEnabled = enabled
        selectButton.isEnabled = enabled
        uploadButton.isEnabled = enabled
    }
    
    // MARK: - Actions
    
    @IBAction func selectButtonTapped(_ sender: Any) {
        
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera)) {
            
            let alert = UIAlertController(title: NSLocalizedString("Select source", comment: "Alert title when multiple sources present"), message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Take a photo", comment: "Camera option title"), style: .default, handler: { (_) in
                self.selectImage(source: .camera)
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Photo library", comment: "Photom library option title"), style: .default, handler: { (_) in
                self.selectImage(source: .photoLibrary)
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel button title"), style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        }
        else {
            selectImage(source: UIImagePickerController.SourceType.photoLibrary)
        }
    }
    
    @IBAction func uploadButtonTapped(_ sender: Any) {
        
        upload()
    }
    
    @IBAction func textFieldDidEndOnExit(_ sender: UITextField) {
        
        sender.resignFirstResponder()
    }
    
    // MARK: Image Picker
    
    private func selectImage(source: UIImagePickerController.SourceType) {
        
        let picker = UIImagePickerController()
        picker.sourceType = source
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        if let image = (info[UIImagePickerController.InfoKey.editedImage] ?? info[UIImagePickerController.InfoKey.originalImage]) as? UIImage {
            
            if image.size.width <= maxImageSize.width && image.size.height <= maxImageSize.height {
                imageView.image = image
                processImage()
            }
            else {
                show(message: NSLocalizedString("Image too big!\nMaximum size is \(maxImageSize.width)x\(maxImageSize.height) px", comment: "Error message when selected image is too big"))
            }
        }
    }
    
    // MARK: - Image Processing
    
    private func processImage() {
        
        finishEditing()
        
        if let image = imageView.image {
            
            toggleUserInteraction(enabled: false)
            
            hud = MBProgressHUD.showAdded(to: view, animated: true)
            hud?.label.text = NSLocalizedString("Processing image", comment: "HUD title while processing image")
            hud?.mode = .indeterminate
            
            let swiftyTesseract = SwiftyTesseract(language: .custom("enm"))
            swiftyTesseract.performOCR(on: image) {[weak self] (recognizedString) in
                
                guard let _self = self else {return}
                
                DispatchQueue.main.async {
                    
                    _self.hud?.hide(animated: true)
                    
                    _self.toggleUserInteraction(enabled: true)
                    
                    if let _text = recognizedString, !_text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
                        
                        _self.textView.text = _text
                        _self.confidenceTextField.text = "1"
                    }
                    else {
                        
                        _self.textView.text = nil
                        _self.confidenceTextField.text = nil
                        
                        _self.show(message: NSLocalizedString("Image recognition failed", comment: "Error message when image recognition failed"))
                    }
                }
            }
        }
    }
    
    // MARK: - Data integration
    
    private func upload() {
        
        finishEditing()
        
        guard let __text = textView.text, !__text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty, let _image = imageView.image, let _confText = confidenceTextField.text, let _confidence = Double(_confText), _confidence > 0.0 else {
            show(message: NSLocalizedString("Missing image, text or confidence!", comment: "Error message when not everyting set on new image upload"))
            return
        }
        
        toggleUserInteraction(enabled: false)
        
        let _text = __text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        if hud == nil {
            hud = MBProgressHUD.showAdded(to: view, animated: true)
            hud?.mode = .indeterminate
        }
        hud?.label.text = NSLocalizedString("Uploading image", comment: "HUD title while uploading image")
        
        Network.shared.upload(image: _image, text: _text, confidence: _confidence) {[weak self] (success, _) in
            
            guard let _self = self else {return}
            
            _self.toggleUserInteraction(enabled: true)
            
            if success {
                _self.hud?.label.text = NSLocalizedString("Success!", comment: "HUD title when uploaded image")
                _self.hud?.mode = .text
                _self.hud?.hide(animated: true, afterDelay: 0.7)
                _self.navigationController?.popViewController(animated: true)
            }
            else {
                _self.hud?.hide(animated: true)
                _self.show(message: NSLocalizedString("Failed to upload image!", comment: "Error message when upload failed"))
            }
        }
    }

}
