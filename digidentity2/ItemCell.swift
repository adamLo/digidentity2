//
//  ItemCell.swift
//  digidentity2
//
//  Created by Adam Lovastyik on 14/03/2019.
//  Copyright © 2019 Lovastyik. All rights reserved.
//

import UIKit

class ItemCell: UITableViewCell {
    
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var confidenceLabel: UILabel!
    @IBOutlet weak var itemTextLabel: UILabel!
    
    static let reuseId = "itemCell"

    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        selectionStyle = .none
        contentView.backgroundColor = UIColor.clear
        backgroundColor = UIColor.clear
        
        itemImageView.backgroundColor = UIColor.white
        itemImageView.layer.borderColor = UIColor.darkGray.cgColor
        itemImageView.layer.borderWidth = 0.5
    }

    func setup(with item: Item) {
        
        idLabel.text = String(format: NSLocalizedString("ID: %@", comment: "Item id label format"), item.identifier ?? "N/A")
        confidenceLabel.text = String(format: NSLocalizedString("Confidence: %0.3f", comment: "Item confidence label format"), item.confidence)
        
        let updateText: ((_ text: String?) -> ()) = {[weak self] (text) in
        
            self?.itemTextLabel.text = String(format: NSLocalizedString("Text: %@", comment: "Item text label format"), (text ?? "").trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
        }
        
        if item.encrypted, let _text = item.text {
        
            updateText(nil)
            
            DispatchQueue.global(qos: .background).async {

                var text: String?
                
                if let decryptedText = Encryption.shared.decrypt(base64String: _text) {
                    text = decryptedText
                }
                else {
                    text = NSLocalizedString("Unable to decrypt", comment: "Placeholder for non-decryptable texts")
                }
                
                DispatchQueue.main.async {
                    updateText(text)
                }
            }
        }
        else {
            updateText(item.text)
        }
        
        itemImageView.image = nil
        if let _data = item.imageData {
            
            let encrypted = item.encrypted
            DispatchQueue.global(qos: .background).async {[weak itemImageView] in
                
                var data: Data? = _data as Data
                if encrypted, let decryptedData = Encryption.shared.decrypt(Data: _data) {
                    data = decryptedData
                }
                
                if let _data = data {
                    
                    let image = UIImage(data: _data as Data)
                
                    DispatchQueue.main.async {
                        itemImageView?.image = image
                    }
                }
            }
        }
    }
    
    override func prepareForReuse() {
        
        super.prepareForReuse()
        
        itemImageView.image = nil
        idLabel.text = nil
        confidenceLabel.text = nil
        itemTextLabel.text = nil
    }

}
