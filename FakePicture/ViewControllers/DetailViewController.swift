//
//  DetailViewController.swift
//  FakePicture
//
//  Created by maxwell on 15/04/21.
//

import UIKit
import FirebaseStorage
import FirebaseUI               // For image downloading

class DetailViewController: UIViewController {
   
    var image: StorageReference!
    @IBOutlet weak var detailImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async {
            self.setImage()
        }
    }
    
    func setImage() {
        detailImageView.sd_setImage(with: image!,
                                    placeholderImage: UIImage(named: "placeholder"))
    }

    
}
