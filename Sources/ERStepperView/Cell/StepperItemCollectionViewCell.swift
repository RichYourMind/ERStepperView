//
//  StepperItemCollectionViewCell.swift
//  Restaurant App
//
//  Created by ArshMini on 7/3/21.
//

import UIKit

class StepperItemCollectionViewCell: UICollectionViewCell {

    
    
    //MARK: - IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    
    
    
    
    
    
    
    //MARK: - Init
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    
    
    
    
    //MARK: - Configure
    func configure(title: String , color: UIColor , font: UIFont) {
        titleLabel.text = title
        titleLabel.textColor = color
        titleLabel.font = font
    }
    
    
    
    
    
    

}
