//
//  NewImageViewController.swift
//  digidentity2
//
//  Created by Adam Lovastyik on 16/03/2019.
//  Copyright © 2019 Lovastyik. All rights reserved.
//

import UIKit
import SwiftyTesseract

class NewImageViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - Actions
    
    @IBAction func startButtonTapped(_ sender: Any) {
        
        if let image = imageView.image {
            
            let swiftyTesseract = SwiftyTesseract(language: .custom("enm"))
            swiftyTesseract.performOCR(on: image) { recognizedString in
                
                guard let recognizedString = recognizedString else { return }
                print(recognizedString)
                
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
