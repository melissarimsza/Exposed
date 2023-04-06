//
//  CapturedImageView.swift
//  Exposed
//
//  Created by Melissa Rimsza on 10/4/22.
//

import UIKit
//CLEANED

class CapturedImageView : UIView {
    var image : UIImage? {
        didSet {
            guard let image = image else {return}
            imageView.image = image
        }
    }
    
    //MARK:- View Components
    let imageView : UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    //initializers
    override init(frame: CGRect) {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
