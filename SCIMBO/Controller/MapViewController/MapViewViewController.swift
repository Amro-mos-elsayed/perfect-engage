//
//  MapViewViewController.swift
//  mapkitDemo
//
//  Created by Casperon Technologies Pvt Ltd on 10/06/17.
//  Copyright © 2017 Casperon Technologies Pvt Ltd. All rights reserved.
//

import UIKit
import MapKit

protocol MapViewViewControllerDelegate : class {
    func isLocation(location:Bool)
    func coordinate(latitude:CLLocationDegrees,longitude:CLLocationDegrees,title:String,display:String,subTitle:String)
}

class MapViewViewController: UIViewController,MKMapViewDelegate,CLLocationManagerDelegate,coordinate,UITableViewDelegate,UITableViewDataSource,MKLocalSearchCompleterDelegate{
    
    @IBOutlet weak var send_Activity: UIActivityIndicatorView!
    @IBOutlet weak var sendLocation: UIButton!
    weak var delegate:MapViewViewControllerDelegate?
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var table: UITableView!
    
    @IBOutlet weak var info: UIView!
    
    @IBOutlet weak var place: UILabel!
    
    @IBOutlet weak var load: UIActivityIndicatorView!
    
    @IBOutlet weak var pin: UIButton!
    
    @IBOutlet weak var currentLocation_Btn: UIButton!
    
    @IBOutlet weak var searchBar_Btn: UIButton!
    
    @IBOutlet weak var selectMapSegmt_Contlr: UISegmentedControl!
    
    @IBOutlet weak var selectMapType_View: UIView!
    
    @IBOutlet weak var show_button: UIImageView!
    @IBOutlet weak var mapKit_View: MKMapView!
    
    var mapLatitude:CLLocationDegrees!
    var mapLongitude:CLLocationDegrees!
    var CurrentLatitude:CLLocationDegrees!
    var CurrentLongitude:CLLocationDegrees!
    
    var dis_Text = ""
    var sub_Title = ""
    var cdis_Text = ""
    var csub_Title = ""
    var current_title = ""
    var location_Title = ""
    var hide:Bool = false
    var d_view:Bool = false
    var value:CGFloat!
    var l:CLLocationCoordinate2D!
    var searchResult = [MKLocalSearchCompletion]()
    var count:Int = 0
    
    @IBOutlet weak var d_button: UIButton!
    
    @IBOutlet weak var hide_button: UIButton!
    var map_pin:MKAnnotationView!
    var lab:UILabel!
    var pin_image:UIImageView!
    var button:UIButton!
    var info_Image:UIImageView!
    var center = ""
    var centerAnnotation = MKPointAnnotation()
    let locationManager = CLLocationManager()
    var title_Head = NSArray()
    
    @IBOutlet weak var loader: UIView!
    
    @IBOutlet weak var activity_loader: UIActivityIndicatorView!
    //let selectedLabel:UILabel = UILabel.init(frame:CGRect(x:0, y: 0, width: 140, height: 38))
    //var annotationView = MKAnnotationView()
    var custmCall = CustomCalloutView()
    override func viewDidLoad() {
        super.viewDidLoad()
        if UIDevice.isIphoneX {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight_iPhoneX
        } else {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight
        }
        setUI_Properties()
        dis_Text = ""
        sub_Title = ""
        cdis_Text = ""
        csub_Title = ""
        current_title = ""
        location_Title = ""
        mapLatitude = CLLocationDegrees()
        mapLongitude = CLLocationDegrees()
        CurrentLatitude = CLLocationDegrees()
        CurrentLongitude = CLLocationDegrees()
        title_Head = ["Send Your Location","Show Places"]
        let nib = UINib(nibName: "HeaderCell", bundle: nil)
        table.register(nib, forCellReuseIdentifier: "HeaderCell")
        //table.register(UINib(nibName: "HeaderCell", bundle: nil), forCellReuseIdentifier: "HeaderCellID")
        
        //        let btn = UIButton(type: .detailDisclosure)
        //        custmCall.rightCalloutAccessoryView = btn
        
        
        
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            
        }
        
        
        //3
        //  let annotation = MKPointAnnotation()
        print(".....\(String(describing:l))")
        //let sikkim=CustomAnnotation(title: "Sikkim",subtitle:"fg", coordinate:l)
        //        let delhi = CustomAnnotation(title: "Delhi",subtitle:"fg", coordinate: CLLocationCoordinate2D(latitude: 28.619570, longitude: 77.088104))
        //        let kashmir = CustomAnnotation(title: "Kahmir",subtitle:"fg", coordinate: CLLocationCoordinate2D(latitude: 34.1490875, longitude: 74.0789389))
        //        let gujrat = CustomAnnotation(title: "Gujrat",subtitle:"fg", coordinate: CLLocationCoordinate2D(latitude: 22.258652, longitude: 71.1923805))
        //        let kerala = CustomAnnotation(title: "Kerala",subtitle:"fg", coordinate: CLLocationCoordinate2D(latitude: 9.931233, longitude:76.267303))
        
        self.map_pin = MKAnnotationView()
        self.lab = UILabel()
        self.pin_image = UIImageView()
        self.button = UIButton()
        self.info_Image = UIImageView()
        
        info.layer.cornerRadius = 10
        info.layer.masksToBounds = true
        
        self.button.setTitle("send this location", for:.normal)
        self.button.setTitleColor(UIColor.blue, for: .normal)
        
        self.pin_image.frame=CGRect(x:mapKit_View.frame.size.width/2 + 5.68, y:mapKit_View.frame.size.height/2 + 10.5, width:24 ,height: 24)
        
        print(pin_image.frame)
        
        //self.pin.frame=CGRect(x:mapKit_View.frame.size.width/2 + 5.68, y:mapKit_View.frame.size.height/2 + 10.5, width:24 ,height: 24)
        
        self.lab.frame = CGRect(x:mapKit_View.frame.size.width/2 - pin_image.frame.size.height-45, y:mapKit_View.frame.size.height/2 - pin_image.frame.size.height - 25, width:200, height:20)
        
        self.map_pin.frame = CGRect(x:mapKit_View.frame.size.width/2 - pin_image.frame.size.height - 35,y:mapKit_View.frame.size.height/2 - pin_image.frame.size.height - 10, width:225, height: 40)
        
        self.button.frame = CGRect(x:mapKit_View.frame.size.width/2 - pin_image.frame.size.height - 65, y:mapKit_View.frame.size.height/2 - lab.frame.size.height - pin_image.frame.size.height - 20, width:200, height:20)
        
        self.info_Image.frame = CGRect(x:mapKit_View.frame.size.width/2 - button.frame.size.width/2 + 25, y:mapKit_View.frame.size.height/2 - map_pin.frame.size.height - pin_image.frame.size.height, width:200 ,height:70)
        
        self.pin_image.image = UIImage(named: "1498732961_Map-Marker-Ball-Chartreuse")
        self.info_Image.image = UIImage(named: "speech-25909_640")
        
        self.map_pin.backgroundColor = UIColor.white
        
        map_pin.layer.cornerRadius = 20
        map_pin.layer.masksToBounds = true
        
        self.mapKit_View.isPitchEnabled = true
        mapKit_View.showsUserLocation = true
        
        d_button.layer.cornerRadius = 5
        hide_button.layer.cornerRadius = 5
        //add anotation adds pins
        //lab.sizeToFit()
        //        selectMapSegmt_Contlr.layer.borderWidth = 1
        //        selectMapSegmt_Contlr.layer.borderColor = UIColor.blue.cgColor
        
        //mapKit_View.addAnnotation(sikkim)
        //        mapKit_View.addAnnotation(delhi)
        //        mapKit_View.addAnnotation(kashmir)
        //        mapKit_View.addAnnotation(gujrat)
        //        mapKit_View.addAnnotation(kerala)
        
        //        mapKit_View.addSubview(map_pin)
        //        mapKit_View.addSubview(pin)
        //        mapKit_View.addSubview(pin_image)
        //        mapKit_View.addSubview(info_Image)
        //        mapKit_View.addSubview(lab)
        //        mapKit_View.addSubview(button)
        
        
        //      mapKit_View.addSubview(selectedLabel)
        //      map_pin.backgroundColor=UIColor.red
        //      view.addSubview(map_pin)
        //      Do any additional setup after loading the view.
        table.isScrollEnabled = false
        
        self.height_tab.constant = self.view.frame.size.height/9
        //        self.height_tab.constant = self.view.frame.size.height/1.5
        //
        //        hideS.setTitle("Hide Places", for: .normal)
        //        show_image.image = UIImage(named: "angle-arrow-down")
        //        info.isHidden = true
        //        pin.isHidden = true
        //        d_button.isHidden = true
        //        hide_button.isHidden = true
        //        value = mapKit_View.camera.pitch
        //        table.reloadData()
        hideS.isHidden = true
        show_image.isHidden = true
        
        
        sendLocation.isUserInteractionEnabled = false
        locate.isUserInteractionEnabled = false
        loader.isHidden = true
        mapKit_View.isRotateEnabled = false
        //mapKit_View.isScrollEnabled = false
        //sendLocation.isEnabled = false
        send_Activity.startAnimating()
        self.configureView()
    }
    
    var originalRegion: MKCoordinateRegion!
    
    
    func configureView() {
        self.mapKit_View.isZoomEnabled = false
        self.registerZoomGesture()
    }
    
    ///Register zoom gesture
    func registerZoomGesture() {
        let recognizer = UIPinchGestureRecognizer(target: self, action:#selector(MapViewViewController.handleMapPinch(recognizer:)))
        let tapRecognizer = UITapGestureRecognizer(target: self, action:#selector(MapViewViewController.handleMapTap(recognizer:)))
        self.mapKit_View.addGestureRecognizer(recognizer)
        self.mapKit_View.addGestureRecognizer(tapRecognizer)
        
    }
    
    @objc func handleMapTap(recognizer: UITapGestureRecognizer) {
        
        let currentRegion = self.mapKit_View.region;
        let currentSpan = self.mapKit_View.region.span;
        
        var region:MKCoordinateRegion = currentRegion;
        var span:MKCoordinateSpan = currentSpan;
        
        span.latitudeDelta = currentSpan.latitudeDelta / 2.3;
        span.longitudeDelta = currentSpan.longitudeDelta / 2.3;
        region.span = span;
        
        self.mapKit_View.setRegion(region, animated: false)
        
    }
    
    ///Zoom in/out map
    @objc func handleMapPinch(recognizer: UIPinchGestureRecognizer) {
        
        if (recognizer.state == .began) {
            self.originalRegion = self.mapKit_View.region
        }
        
        var latdelta: Double = originalRegion.span.latitudeDelta / Double(recognizer.scale)
        var londelta: Double = originalRegion.span.longitudeDelta / Double(recognizer.scale)
        
        //set these constants to appropriate values to set max/min zoomscale
        latdelta = max(min(latdelta, 80), 0.002)
        londelta = max(min(londelta, 80), 0.002)
        
        let span = MKCoordinateSpan(latitudeDelta: latdelta, longitudeDelta: londelta)
        
        self.mapKit_View.setRegion(MKCoordinateRegion(center: originalRegion.center, span: span), animated: false)
        
    }
    @IBOutlet weak var result: UILabel!
    @IBAction func clear(_ sender: UIButton) {
        
        UIView.animate(withDuration: 0.5, animations:{
            
            self.height_tab.constant = self.view.frame.size.height/9
            
        }, completion:nil)
        hideS.isHidden = true
        show_image.isHidden = true
        info.isHidden = false
        pin.isHidden = false
        d_button.isHidden = false
        hide_button.isHidden = false
        searchBar_Btn.setTitle("", for:.normal)
        count = 0
        table.reloadData()
        
    }
    
    @IBAction func sendCurrent(_ sender: UIButton) {
        
        
        self.delegate?.isLocation(location:true)
        
        self.delegate?.coordinate(latitude:self.CurrentLatitude,longitude:self.CurrentLongitude,title:self.current_title,display:self.cdis_Text,subTitle:self.csub_Title)
        
        self.pop(animated: true)
        
    }
    
    @IBAction func goBack(_ sender: UIButton) {
        
        self.pop(animated: true)
        
    }
    
    @IBOutlet weak var locate: UIButton!
    @IBOutlet weak var show_image: UIImageView!
    
    
    @IBOutlet weak var navigate: UIButton!
    
    @IBOutlet weak var tab_bottom: NSLayoutConstraint!
    @IBOutlet weak var top_table: NSLayoutConstraint!
    var show:Bool = true
    
    @IBOutlet weak var hideS: UIButton!
    @IBOutlet weak var height_tab: NSLayoutConstraint!
    
    @IBAction func passLocation(_ sender: UIButton) {
        
        if(self.location_Title != ""){
            self.delegate?.isLocation(location:true)
            
            self.delegate?.coordinate(latitude:self.mapLatitude,longitude:self.mapLongitude,title:self.location_Title,display:self.dis_Text,subTitle:self.sub_Title)
            self.pop(animated: true)
            
        }
        
        
    }
    
    @IBAction func hide_button(_ sender: UIButton) {
        
        if show{
            //vertical_space.constant = 300
            UIView.animate(withDuration: 0.5, animations:{
                
                self.height_tab.constant = self.view.frame.size.height/1.5
                
                self.table.frame = CGRect(x: self.mapKit_View.frame.origin.x, y:self.view.frame.size.height/1.5 , width: self.mapKit_View.frame.size.width, height: self.view.frame.size.height/1.5)
                
                //                self.mapKit_View.frame = CGRect(x: self.mapKit_View.frame.origin.x, y:self.view.frame.size.height/3 , width: self.mapKit_View.frame.size.width, height:150)
                
            }, completion:nil)
            
            //table_height.constant = 425
            
            count = searchResult.count
            sender.setTitle("Hide Places", for: .normal)
            show_image.image = UIImage(named: "angle-arrow-down")
            info.isHidden = true
            pin.isHidden = true
            d_button.isHidden = true
            hide_button.isHidden = true
            
            //tab_top.constant = 350
            show = false
            //table.isScrollEnabled = false
            table.reloadData()
            
            //table.isHidden = false
            
        }else{
            
            //tab_top.constant = 3
            //vertical_space.constant = 17
            UIView.animate(withDuration: 0.5, animations:{
                self.height_tab.constant = 124
                self.table.frame = CGRect(x: self.mapKit_View.frame.origin.x, y:self.view.frame.size.height/3 , width: self.mapKit_View.frame.size.width, height:124)
                
                //                self.mapKit_View.frame = CGRect(x: self.mapKit_View.frame.origin.x, y:self.view.frame.size.height/4.5 - 5, width: self.mapKit_View.frame.size.width, height:self.view.frame.size.height/1.8 + 5)
            }, completion:nil)
            
            
            show_image.image = UIImage(named: "up-arrow")
            count = 0
            //table_height.constant = 200
            
            sender.setTitle("Show Places", for:.normal)
            info.isHidden = false
            pin.isHidden = false
            d_button.isHidden = false
            hide_button.isHidden = false
            show = true
            //table.isScrollEnabled = true
            table.reloadData()
            //table.isHidden = true
            
        }
        
    }
    
    var searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    
    func search(text: String) {
        searchBar_Btn.setTitle(text, for: .normal)
        result.text = "searching..."
        loader.isHidden = false
        activity_loader.isHidden = false
        activity_loader.startAnimating()
        searchCompleter.delegate = self
        searchCompleter.queryFragment = text
        
        print(searchResults)
        
        hideS.isHidden =  false
        show =  false
        show_image.isHidden = false
        self.height_tab.constant = self.view.frame.size.height/1.5
        
        hideS.setTitle("Hide Places", for: .normal)
        show_image.image = UIImage(named: "angle-arrow-down")
        info.isHidden = true
        pin.isHidden = true
        d_button.isHidden = true
        hide_button.isHidden = true
        count = searchResults.count
        
        //        if(searchResults.count <= 0){
        //            loader.isHidden = false
        //            result.text = "No results found"
        //            activity_loader.isHidden = true
        //            //activity_loader.stopAnimating()
        //        }else{
        
        //}
        
        table.reloadData()
    }
    
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        if self.viewIfLoaded?.window != nil {
            print("called")
            searchResults = completer.results
            count = searchResults.count
            
            loader.isHidden = false
            result.text = "searching..."
            activity_loader.isHidden = false
            
            table.reloadData()
            
            if(count <= 0){
                loader.isHidden = false
                result.text = "No results found"
                activity_loader.isHidden = true
            }
        }
        
    }
    
    func hide(_ sender: UIButton) {
        
        print("ghghgh")
        if show{
            
            count = searchResult.count
            sender.setTitle("Hide Places", for: .normal)
            sender.setImage(UIImage(named:"angle-arrow-down"), for: .normal)
            info.isHidden = true
            pin.isHidden = true
            d_button.isHidden = true
            hide_button.isHidden = true
            show = false
            
        }else{
            
            UIView.animate(withDuration: 2, animations:{
                self.mapKit_View.frame.size.height = 425
                self.table.frame.origin.y = 563
            }, completion:nil)
            
            count = 0
            sender.setTitle("Show Places", for:.normal)
            info.isHidden = false
            pin.isHidden = false
            d_button.isHidden = false
            hide_button.isHidden = false
            show = true
            
        }
        
        
    }
    
    func selected(place: CLLocationCoordinate2D) {
        l=place
        print(String(describing:place))
    }
    
    func info(array: [MKLocalSearchCompletion]) {
        
        searchResult = array
        show =  false
        show_image.isHidden = false
        show = false
        hideS.isHidden = false
        self.height_tab.constant = self.view.frame.size.height/1.5
        hideS.setTitle("Hide Places", for: .normal)
        show_image.image = UIImage(named: "angle-arrow-down")
        info.isHidden = true
        pin.isHidden = true
        d_button.isHidden = true
        hide_button.isHidden = true
        //count = searchResult.count
        table.isScrollEnabled = true
        count = searchResult.count
        print(searchResult)
        table.reloadData()
        
    }
    
    
    
    //    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    //        let head_title = title_Head[section] as! String
    //
    //        return head_title
    //    }
    //
    //    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    ////        if(section == 0){
    ////            return 70
    ////        }else if(section == 1){
    ////            return 70
    ////        }
    //        return 1000
    //    }
    //
    //    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    //
    //        let headerCell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell") as! HeaderCell
    //        //headerCell.backgroundColor = UIColor.cyan
    //        switch(section){
    //        case 0:
    //            headerCell.title.setTitle("Send Your Location", for:.normal)
    //
    //            return headerCell
    //
    //        case 1:
    //            headerCell.title.setTitle("Show Places", for:.normal)
    //            headerCell.title.addTarget(self, action:#selector(MapViewViewController.hide(_:)), for:.touchUpInside)
    //            return headerCell
    //
    //        default:
    //            break
    //        }
    //        return headerCell
    //
    //    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 2
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(section == 0){
            return 0
        }else if(section == 1){
            return count
        }
        
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "place", for: indexPath )
        
        guard searchResults.count > indexPath.row else{return cell}
        
        let c = searchResults[indexPath.row]
        if(c.subtitle == ""){
            cell.textLabel?.font = UIFont.systemFont(ofSize: 17.0)
        }else{
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15.0)
        }
        cell.detailTextLabel?.textColor = UIColor.gray
        cell.textLabel?.text = c.title
        cell.detailTextLabel?.text = c.subtitle
        print("......\(searchResults.count)")
        loader.isHidden = true
        activity_loader.stopAnimating()
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let completion = searchResults[indexPath.row]
        
        let searchRequest = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: searchRequest)
        search.start { (response, error) in
            let coordinates = response?.mapItems[0].placemark.coordinate
            
            self.delegate?.isLocation(location:true)
            self.delegate?.coordinate(latitude:(response?.mapItems[0].placemark.coordinate.latitude)!,longitude:(response?.mapItems[0].placemark.coordinate.longitude)!,title:completion.title,display:completion.title,subTitle:"")
            self.pop(animated: true)
            print(String(describing: coordinates))
            
        }
        
        
    }
    
    @IBAction func d_view(_ sender: UIButton) {
        
        if d_view{
            
            let camera = MKMapCamera()
            
            sender.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
            //sender.setTitle(,for:.)
            //vertical_space.constant = 17
            UIView.animate(withDuration: 2, animations:{
                camera.centerCoordinate = self.mapKit_View.centerCoordinate
                camera.pitch = 0.0
                camera.altitude = 1000.0
                camera.heading = 0.0
                self.mapKit_View.setCamera(camera, animated: false)
            }, completion:nil)
            
            d_view = false
            
        }else{
            
            UIView.animate(withDuration: 2, animations:{
                
                let camera = MKMapCamera(lookingAtCenter: self.mapKit_View.centerCoordinate, fromDistance:900, pitch: 45.0, heading: 0.0)
                self.mapKit_View.setCamera(camera, animated: false)
            }, completion:nil)
            sender.titleLabel?.font = UIFont.boldSystemFont(ofSize:15.0)
            d_view = true
            
        }
        
    }
    
    @IBAction func hidePin(_ sender: UIButton) {
        if hide {
            
            sender.setImage(UIImage(named:"pin (11)"), for:.normal)
            info.isHidden = false
            pin.isHidden = false
            hide = false
            
        }else{
            
            sender.setImage(UIImage(named:"pin (10)"), for:.normal)
            info.isHidden = true
            pin.isHidden = true
            hide = true
            
        }
        
    }
    
    func setUI_Properties(){
        
        currentLocation_Btn.layer.cornerRadius = 5
        currentLocation_Btn.layer.shadowColor = UIColor.black.cgColor
        currentLocation_Btn.layer.shadowOpacity = 1
        currentLocation_Btn.layer.shadowOffset = CGSize.zero
        currentLocation_Btn.layer.shadowRadius = 10
        currentLocation_Btn.clipsToBounds = true
        
        searchBar_Btn.layer.cornerRadius = 5
        selectMapSegmt_Contlr.layer.cornerRadius = 10
        selectMapType_View.layer.shadowColor = UIColor.black.cgColor
        selectMapType_View.layer.shadowOpacity = 1
        selectMapType_View.layer.shadowOffset = CGSize.zero
        selectMapType_View.layer.shadowRadius = 10
        selectMapType_View.clipsToBounds = true
        searchBar_Btn.layer.cornerRadius = 10
        selectMapSegmt_Contlr.layer.cornerRadius = 10
        
    }
    
    @IBAction func cancelBtn_Action(_ sender: UIButton) {
        
        
    }
    
    @IBAction func segmentContr_Action(_ sender: UISegmentedControl) {
        switch selectMapSegmt_Contlr.selectedSegmentIndex
        {
        case 0:
            
            mapKit_View.mapType = .standard
            d_button.isHidden = false
            hide_button.isHidden = false
            print("dsgg")
            
        //textLabel.text = "First selected";
        case 1:
            
            mapKit_View.mapType = .hybrid
            d_button.isHidden = true
            hide_button.isHidden = true
            print("dfa")
            
        // textLabel.text = "Second Segment selected";
        case 2:
            
            mapKit_View.mapType = .satellite
            d_button.isHidden = true
            hide_button.isHidden = true
            print("rwg")
            
        default:
            break;
        }
    }
    
    
    @IBAction func searchBarBtn_Action(_ sender: UIButton) {
        
        let s = storyboard?.instantiateViewController(withIdentifier:"SearchPlacesViewController") as! SearchPlacesViewController
        self.pushView(s, animated: true)
        s.delegate = self
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        
        
        
        CurrentLatitude = locValue.latitude
        CurrentLongitude = locValue.longitude
        
        locationManager.stopUpdatingLocation()
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude:CurrentLatitude, longitude: CurrentLongitude)
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            if(error == nil)
            {
                var location_Name:String = String()
                var city_Name:String = String()
                //                var street_Name:String = String()
                var country_Name:String = String()
                //                var address:String = String()
                // Place details
                // Address dictionary
                if(placemarks != nil)
                {
                    var placeMark: CLPlacemark!
                    placeMark = placemarks?[0]
                    
                    
                        // Location name
                        if let locationName = placeMark.name {
                            print(locationName)
                            location_Name = locationName
                            
                        }
                        
                        if let subLocalityName = placeMark.subLocality {
                            print(subLocalityName)
                            //                            address = subLocalityName as String
                            
                        }
                        // Street address
                        if let street = placeMark.thoroughfare {
                            print(street)
                        }
                        // City
                        if let city = placeMark.subAdministrativeArea{
                            city_Name = city
                            print(city)
                        }
                        // Zip code
                        if let zip = placeMark.postalCode {
                            print(zip)
                        }
                        // Country
                        if let country = placeMark.country {
                            country_Name = country
                            print(country)
                        }
                        
                        var first_String = String()
                        var second_String = String()
                        first_String = location_Name
                        if city_Name == "" {
                            second_String = country_Name
                        }
                        else{
                            second_String = city_Name
                        }
                        
                        let form_Address = "\(first_String),\(second_String)"
                        
                        self.cdis_Text = first_String
                        self.csub_Title = second_String
                        self.current_title = form_Address
                        self.sendLocation.isUserInteractionEnabled = true
                        self.send_Activity.stopAnimating()
                        self.send_Activity.isHidden = true
                }
            }else{
                print(error!)
            }
        })
        
        
        
        
        let locations = CLLocationCoordinate2D(latitude: locValue.latitude,
                                               longitude: locValue.longitude)
        
        
        
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: locations, span: span)
        
        mapKit_View.setRegion(region, animated: true)
    }
    
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        
        //        centerAnnotation.subtitle = "getting address...."
        place.text = "getting address...."
        self.load.startAnimating()
        self.load.isHidden = false
        
        self.mapLatitude = mapView.centerCoordinate.latitude
        self.mapLongitude = mapView.centerCoordinate.longitude
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: mapLatitude, longitude: mapLongitude)
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            if(error == nil)
            {
                var location_Name:String = String()
                var city_Name:String = String()
                var country_Name:String = String()
                
                if(placemarks != nil)
                {
                    var placeMark: CLPlacemark!
                    placeMark = placemarks?[0]
                    
                        if let locationName = placeMark.name {
                            print(locationName)
                            location_Name = locationName as String
                        }
                        
                        if let subLocalityName = placeMark.subLocality {
                            print(subLocalityName)
                        }
                        
                        // Street address
                        if let street = placeMark.thoroughfare {
                            print(street)
                        }
                        
                        // City
                        if let city = placeMark.subAdministrativeArea {
                            city_Name = city as String
                            print(city)
                        }
                        
                        // Zip code
                        if let zip = placeMark.postalCode {
                            print(zip)
                        }
                        
                        // Country
                        if let country = placeMark.country {
                            country_Name = country as String
                            print(country)
                        }
                        
                        var first_String = String()
                        var second_String = String()
                        first_String = location_Name
                        if city_Name == "" {
                            second_String = country_Name
                        }
                        else{
                            second_String = city_Name
                        }
                        
                        let form_Address = "\(first_String),\(second_String)"
                        
                        //            self.centerAnnotation.coordinate = mapView.centerCoordinate
                        //            self.centerAnnotation.title = "Send this location"
                        //            self.centerAnnotation.subtitle = form_Address
                        self.dis_Text = first_String
                        self.sub_Title = second_String
                        self.place.text = form_Address
                        
                        self.load.stopAnimating()
                        self.load.isHidden = true
                        
                        self.location_Title = form_Address
                        
                        self.locate.isUserInteractionEnabled = true
                        
                }
            }
        })
        
        print("hhhhhh")
        
        
    }
    var current:Bool = false
    @IBAction func getCurrent_Location(_ sender: UIButton) {
        if(current){
            sender.setImage(UIImage(named:"navigation (5)"), for:.normal)
            //            locationManager.delegate = self
            //            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            //            locationManager.requestWhenInUseAuthorization()
            if(CurrentLatitude != nil){
                
                mapKit_View.setCenter(CLLocationCoordinate2D(latitude:CurrentLatitude, longitude:CurrentLongitude), animated:true)
                current = false
                
            }
            
            //locationManager.startUpdatingLocation()
            
        }else{
            sender.setImage(UIImage(named:"navigation (4)"), for:.normal)
            current = true
        }
        
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        //        let identifier = "CustomCalloutView"
        
        if annotation is CustomAnnotation {
            let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "myPin")
            
            pinAnnotationView.pinTintColor = .purple
            pinAnnotationView.isDraggable = true
            
            //displaying bubble....
            pinAnnotationView.canShowCallout = true
            pinAnnotationView.animatesDrop = true
            let deleteButton = UIButton.init(type: .custom) as UIButton
            deleteButton.frame.size.width = 44
            deleteButton.frame.size.height = 44
            deleteButton.backgroundColor = UIColor.red
            deleteButton.setImage(UIImage(named: "trash"), for: .normal)
            
            pinAnnotationView.leftCalloutAccessoryView = deleteButton
            
            return pinAnnotationView
        }
        return nil
        //
        //    let customAnnotationViewIdentifier = "MyAnnotation"
        //
        //    var pin = mapView.dequeueReusableAnnotationView(withIdentifier: customAnnotationViewIdentifier)
        //    if pin == nil {
        //        pin = CustomAnnotationView(annotation: annotation, reuseIdentifier: customAnnotationViewIdentifier)
        //    } else {
        //        pin?.annotation = annotation
        //
        //    }
        //    return pin
        //    if annotation is MKUserLocation {
        //        return nil
        //    }
        //
        //    let reuseId = "pin"
        //    var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        //    if pinView == nil {
        //        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        //        pinView?.isDraggable = true
        //        pinView?.animatesDrop = true
        //        pinView?.canShowCallout = true
        //    }
        //    else {
        //        pinView?.annotation = annotation
        //    }
        //
        //    return pinView
        
        
    }
    
    
    //    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
    //        for var view in views {
    //            view.canShowCallout = false
    //        }
    //    }
    
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        //        let capital = view.annotation as! CustomAnnotation
        
        let mapLatitude = mapView.centerCoordinate.latitude
        let mapLongitude = mapView.centerCoordinate.longitude
        //        let placeName = capital.title
        //        let placeInfo = capital.title
        
        let ac = UIAlertController(title: "\(mapLatitude)", message: "\(mapLongitude)", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        self.presentView(ac, animated: true, completion: nil)
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
        switch newState {
        case .starting:
            view.dragState = .none
        case .ending, .canceling:
            view.dragState = .none
        default: break
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




