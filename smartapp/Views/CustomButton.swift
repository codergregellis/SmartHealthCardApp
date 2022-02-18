//
//  CustomButton.swift
//  smartapp
//
//  Created by Greg Ellis on 2022-02-11.
//

import UIKit

@IBDesignable class CustomButton: UIButton {
    
    func setup(){
        self.layer.cornerRadius = 10
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
    }
}
