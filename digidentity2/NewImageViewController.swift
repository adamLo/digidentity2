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
    
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var uploadButton: UIButton!
    
    private var hud: MBProgressHUD?
    
    // MARK: - Controller Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        setupUI()
    }
    
    // MARK: - UI Customization
    
    private func setupUI() {
        
        title = NSLocalizedString("New Image", comment: "Navigation title on new image screen")
        
        setupButtons()
        setupImageView()
    }
    
    private func setupButtons() {
        
        selectButton.setTitle(NSLocalizedString("Select image", comment: "Select button title on new image screen"), for: .normal)
        uploadButton.setTitle(NSLocalizedString("Process & Upload", comment: "Upload button title on new image screen"), for: .normal)
    }
    
    private func setupImageView() {
        
        imageView.image = nil
        imageView.layer.borderWidth = 0.5
        imageView.layer.borderColor = UIColor.darkGray.cgColor
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor.clear
    }
    
    private func show(message: String) {
        
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK button title"), style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
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
        
        processImage()
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
            imageView.image = image
        }
    }
    
    // MARK: - Image Processing
    
    private func processImage() {
        
        if let image = imageView.image {
            
            hud = MBProgressHUD.showAdded(to: view, animated: true)
            hud?.label.text = NSLocalizedString("Processing image", comment: "HUD title while processing image")
            hud?.mode = .indeterminate
            
            let swiftyTesseract = SwiftyTesseract(language: .custom("enm"))
            swiftyTesseract.performOCR(on: image) {[weak self] (recognizedString) in
                
                guard let _self = self else {return}
                
                DispatchQueue.main.async {
                    
                    _self.hud?.hide(animated: true)
                    
                    if let _text = recognizedString, !_text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
                        _self.upload(image: image, text: _text)
                    }
                    else {
                        _self.show(message: NSLocalizedString("Image recognition failed", comment: "Error message when image recognition failed"))
                    }
                }
            }
        }
        else {
            
            show(message: NSLocalizedString("Please select an image!", comment: "Error message when no image selected"))
        }
    }
    
    // MARK: - Data integration
    
    private func upload(image: UIImage, text: String) {
        
        // FIXME: Implement upload
        print("Uploading image: \(image) with text: \(text)")
    }

}
