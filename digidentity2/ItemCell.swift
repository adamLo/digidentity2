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
        confidenceLabel.text = String(format: NSLocalizedString("Confidence: %f", comment: "Item confidence label format"), item.confidence)
        itemTextLabel.text = String(format: NSLocalizedString("Text: %@", comment: "Item text label format"), (item.text ?? "").trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
        
        if let _data = item.imageData {
            
            DispatchQueue.global(qos: .background).async {[weak itemImageView] in
                
                let image = UIImage(data: _data as Data)
                
                DispatchQueue.main.async {
                    itemImageView?.image = image
                }
            }
        }
        else {
            itemImageView.image = nil
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
