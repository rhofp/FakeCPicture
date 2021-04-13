//
//  HomeViewController.swift
//  FakePicture
//
//  Created by maxwell on 12/04/21.
//

import UIKit
import Firebase
import CoreServices
import FirebaseUI               // For image downloading
import FirebaseAuth

class HomeViewController: UIViewController {
    
    // Singleton variable to access Firebase storage
    let storage = Storage.storage()
    let userIdentifier = Auth.auth().currentUser?.uid
    
    let placeholderImage = UIImage(named: "placeholder")
    
    var imagesReferences : [StorageReference] = []
    var images: [UIImage] = []
    
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var uploadButton: UIButton!
    
    @IBOutlet var collection: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Only login user can acces this View
        // Hence we can call userInfo
        setUserInfo()
        setupElements()
        
        let nib = UINib
            .init(nibName: "ImageCollectionViewCell", bundle: nil)
        // Register nib cell in the collection instance
        collection.register(nib, forCellWithReuseIdentifier: "imageCellXIB")
        
        refreshImageCarrousel()
        
    }
        
    func setUserInfo(){
        let db = Firestore.firestore()
        
        let userRef = db.collection("users")
            .whereField("uid",isEqualTo: ("\(userIdentifier!)"))
        userRef.getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let firstname = document.data()["firstname"]!
                    let lastname = document.data()["lastname"]!
                    self.welcomeLabel.text = "Welcome \(firstname) \(lastname)"
                }
            }
        }

    }

    func setupElements(){
        Utilities.styleFilledButton(uploadButton)
    }
    
    @IBAction func uploadImage(_ sender: Any) {
        let userImagePicker = UIImagePickerController()
        userImagePicker.delegate = self
        
        userImagePicker.sourceType = .photoLibrary
        userImagePicker.mediaTypes = ["public.image"]
        
        present(userImagePicker, animated: true, completion: nil)
    }
    
    @IBAction func logout(_ sender: Any) {
        print("Jumping into logout")
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
            print("Got into try catch")
            let vc = storyboard?
                .instantiateViewController(identifier: "main")
                as! ViewController
            vc.modalPresentationStyle = .fullScreen

            self.present(vc, animated: true, completion: nil)
            
        } catch let signOutError as NSError {
          print ("Error signing out: %@", signOutError)
        }
    }
   
    
    func uploadImageToCloud(imageData:Data,filename:String){
        // Activity indicator instance
        let activityIndicator = UIActivityIndicatorView.init(style: .large)
        activityIndicator.startAnimating()
        activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator)
        
        // Firebase storage reference
        let storageRef = storage.reference()
        // Creating the cloud path
        let imageRef = storageRef
            .child("\(String(userIdentifier!))")
            .child("gallery").child(filename)
        
        let uploadMetaData = StorageMetadata()
        uploadMetaData.contentType = "image/jpeg"
        
        imageRef.putData(imageData,metadata: uploadMetaData){
            (metadata,error) in
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
            if let error = error{
                print(error.localizedDescription)
            } else {
                print("Upload successfull")
                self.imagesReferences.append(imageRef)
                self.collection.reloadData()
            }
        }

    }
    
    func refreshImageCarrousel(){
 
        let storageReference = storage.reference()
            .child("\(String(userIdentifier!))/gallery")
        
        storageReference.listAll{ (result,error) in
          if let error = error {
            print(error)
          }
          for item in result.items {
            self.imagesReferences.append(item)
            self.collection.reloadData()
          }
        }
        
    }

}

// Extension to delegate the image picker controller to the class itself
extension HomeViewController: UIImagePickerControllerDelegate{
    // When the user finish selecting the image
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info:
            [UIImagePickerController.InfoKey : Any]) {
        // image selected info is store as an array
        if let userImage = info[
            UIImagePickerController.InfoKey.originalImage] as? UIImage,
           let optimizedImageData = userImage.jpegData(compressionQuality: 0.6){
            
            // We send the image as JPEG compressed at 60 percent
            uploadImageToCloud(
                imageData: optimizedImageData,
                filename:"\(abs(optimizedImageData.hashValue)).jpg")
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
}

extension HomeViewController: UICollectionViewDataSource{
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int) -> Int {
        
        return imagesReferences.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "imageCellXIB",
            for: indexPath) as! ImageCollectionViewCell
        if imagesReferences.count > 0 {
            let ref = imagesReferences[indexPath.item]
            cell.imageViewCell
                .sd_setImage(with: ref, placeholderImage: placeholderImage)
            self.images.append(cell.imageViewCell.image!)
        }
        
        return cell
    }
        
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath) {

        let vc = storyboard?
            .instantiateViewController(identifier: "detailView")
            as! DetailViewController
    
        vc.image = imagesReferences[indexPath.item]

        self.present(vc, animated: true, completion: nil)
    }
    
}

extension HomeViewController: UICollectionViewDelegate {
    
}


// Extension to delegate the image picker controller to the class itself
extension HomeViewController: UINavigationControllerDelegate{
    
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 100, height: 100)
    }
}
