//
//  SpotPopoverViewController.swift
//  ParkingSpotApp
//
//  Created by Pierce on 2/7/17.
//  Copyright © 2017 Pierce. All rights reserved.
//

import UIKit

class SpotPopoverViewController: UIViewController {

    var height: CGFloat = 0
    var width: CGFloat = 0
    
    // To be passed from ViewController
    var parkingSpot: ParkingSpot!
    
    var activity: UIActivityIndicatorView!
    
    weak var delegate: SpotPopoverViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        showSpotDetails()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showSpotDetails() {
        
        // Instantiate a new UILabel for the spot number
        let numberLabel = UILabel()
        view.addSubview(numberLabel)
        numberLabel.text = "Spot #\(parkingSpot.id)"
        numberLabel.font = UIFont(name: "HelveticaNeue-Regular", size: 20)
        numberLabel.textColor = UIColor.white
        numberLabel.numberOfLines = 1
        numberLabel.adjustsFontSizeToFitWidth = false
        let numberSize = numberLabel.attributedText!.size()
        numberLabel.frame = CGRect(x: 5, y: 5, width: numberSize.width, height: numberSize.height)
        
        // Create a name label right below the number label
        let nameLabel = UILabel()
        view.addSubview(nameLabel)
        nameLabel.text = parkingSpot.name
        nameLabel.font = UIFont(name: "HelveticaNeue-Regular", size: 20)
        nameLabel.textColor = UIColor.white
        nameLabel.numberOfLines = 1
        nameLabel.adjustsFontSizeToFitWidth = false
        let nameLabelSize = nameLabel.attributedText!.size()
        nameLabel.frame = CGRect(x: (width - nameLabelSize.width)/2, y: numberLabel.frame.maxY + 5, width: nameLabelSize.width, height: nameLabelSize.height)
        
        // Instantiate per-minute charge label
        let chargeLabel = UILabel()
        view.addSubview(chargeLabel)
        chargeLabel.text = "\(parkingSpot.costPerMinute) per Minute"
        chargeLabel.font = UIFont(name: "HelveticaNeue-Regular", size: 20)
        chargeLabel.textColor = UIColor.white
        chargeLabel.numberOfLines = 1
        chargeLabel.adjustsFontSizeToFitWidth = false
        let chargeLabelSize = chargeLabel.attributedText!.size()
        chargeLabel.frame = CGRect(x: (width - chargeLabelSize.width)/2, y: nameLabel.frame.maxY + 5, width: chargeLabelSize.width, height: chargeLabelSize.height)
        
        let buttonHeight: CGFloat = 35.0
        let reserveButton = UIButton()
        view.addSubview(reserveButton)
        reserveButton.setTitle("Reserve Spot", for: .normal)
        reserveButton.setTitleColor(UIColor.white, for: .normal)
        reserveButton.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        //let reserveButtonSize = reserveButton.titleLabel!.attributedText!.size()
        reserveButton.layer.cornerRadius = buttonHeight/2
        reserveButton.frame = CGRect(x: (width - 150)/2, y: height - (buttonHeight+10), width: 150, height: buttonHeight)
        reserveButton.addTarget(self, action: #selector(reserveSpot(_:)), for: .touchUpInside)
        
        let activity = UIActivityIndicatorView()
        view.addSubview(activity)
        activity.activityIndicatorViewStyle = .white
        activity.startAnimating()
        activity.frame = CGRect(x: (width - activity.bounds.width)/2, y: chargeLabel.frame.maxY + 10, width: activity.bounds.width, height: activity.bounds.height)
        activity.startAnimating()
        activity.alpha = 0
        self.activity = activity
    }
    
    func reserveSpot(_ sender: UIButton) {
        
        // Due to time I'm just going to make this a simple dummy transaction
        UIView.animate(withDuration: 0.3, animations: {
            self.activity.alpha = 1.0
            self.view.layoutIfNeeded()
        }, completion: {action in
        
            // Perform dummy authorization for 1.5 seconds
            self.perform(#selector(self.paymentReceived), with: nil, afterDelay: 1.5)
        })
    }
    
    func paymentReceived() {
        delegate?.paymentAuthorized()
    }

}

protocol SpotPopoverViewControllerDelegate: class {
    func paymentAuthorized()
}
