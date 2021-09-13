//
//  OnCellClickViewController.swift
//
//
//  Created by PremMac on 18/07/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit
import MapKit

class OnCellClickViewController: UIViewController,MKMapViewDelegate {
    
    var latitude:String!
    var longitude:String!
    var on_title: String!
    var subtitle:String!
    var place_name:String!
    
    
    @IBOutlet weak var On_subtitle: UILabel!
    
    @IBOutlet weak var On_CTitle: UILabel!
    @IBOutlet weak var mapKit: MKMapView!
    @IBOutlet weak var map_Segment: UISegmentedControl!
    
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    
    @IBAction func go_Back(_ sender: Any) {
        
        self.pop(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if UIDevice.isIphoneX {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight_iPhoneX
        } else {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight
        }
        
        print(latitude)
        print(longitude)
        
        let lat = (latitude as NSString).doubleValue
        let long = (longitude as NSString).doubleValue
        On_CTitle.text = place_name
        On_subtitle.text = subtitle
        
        let centre = CLLocationCoordinate2D(latitude: lat,longitude:long)
        let region = MKCoordinateRegion(center:centre, span:MKCoordinateSpan(latitudeDelta:0.001, longitudeDelta: 0.005))
        let place = CustomAnnotation(title: on_title,subtitle:subtitle, coordinate: CLLocationCoordinate2D(latitude: lat, longitude: long))
        
        mapKit.addAnnotation(place)
        mapKit.selectAnnotation(place, animated: true)
        mapKit.setRegion(region, animated:true)
        mapKit.isRotateEnabled = false
        
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func go_map(_ sender: Any) {
        
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let isGoogleMap:Bool = UIApplication.shared.canOpenURL(NSURL(string:"comgooglemaps://")! as URL)
        
        let CameraAction: UIAlertAction = UIAlertAction(title: "Open in maps", style: .default) { action -> Void in
            
            let lat = (self.latitude as NSString).doubleValue
            let long = (self.longitude as NSString).doubleValue
            let coordinate = CLLocationCoordinate2DMake(lat, long)
            let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.02))
            
            let options = [
                MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: region.center),
                MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: region.span)]
            
            let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
            
            mapItem.name = self.place_name
            mapItem.openInMaps(launchOptions: options)
            
            //            UIApplication.shared.openURL(NSURL(string:"http://maps.apple.com/?ll=\(lat),\(long)")! as URL)
            
        }
        let Google: UIAlertAction = UIAlertAction(title: "Open in Google Maps", style: .default) {
            action -> Void in
            let lat = (self.latitude as NSString).doubleValue
            let long = (self.longitude as NSString).doubleValue
            
            UIApplication.shared.open(NSURL(string:
                "comgooglemaps://?saddr=&daddr=\(lat),\(long)&directionsmode=driving")! as URL)
            
        }
        let Cancel: UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "comment"), style: .cancel) {
            action -> Void in
            
        }
        if(isGoogleMap){
            actionSheetController.addAction(CameraAction)
            actionSheetController.addAction(Google)
            actionSheetController.addAction(Cancel)
        }else{
            actionSheetController.addAction(CameraAction)
            actionSheetController.addAction(Cancel)
        }
        
        self.presentView(actionSheetController, animated: true, completion: nil)
    }
    
    @IBAction func segmentSelect(_ sender: Any) {
        switch map_Segment.selectedSegmentIndex
        {
        case 0:
            
            mapKit.mapType = .standard
            
            
        //textLabel.text = "First selected";
        case 1:
            
            mapKit.mapType = .hybrid
            
        case 2:
            
            mapKit.mapType = .satellite
            
        default:
            break;
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

