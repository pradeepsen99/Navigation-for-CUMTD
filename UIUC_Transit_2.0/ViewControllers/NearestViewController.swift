//
//  NearestStopViewController.swift
//  UIUC_Transit_2.0
//
//  Created by Pradeep Kumar on 1/2/19.
//  Copyright © 2019 Pradeep Kumar. All rights reserved.
//

import UIKit
import FoldingCell
import CoreLocation

class NearestViewController: UITableViewController {
    
    static var flatGreen = UIColor(red: 93/255, green: 172/255, blue: 94/255, alpha: 1.0)
    
    static var flatBlue = UIColor(red: 86/255, green: 149/255, blue: 219/255, alpha: 1)
    
    static var flatRed = UIColor(red: 210/255, green: 88/255, blue: 64/255, alpha: 1)
    
    static var flatPurple = UIColor(red: 87/255, green: 53/255, blue: 94/255, alpha: 1)
    
    static var flatYellow = UIColor(red: 246/255, green: 208/255, blue: 69/255, alpha: 1)
    
    static var flatDarkGreen = UIColor(red: 65/255, green: 97/255, blue: 114/255, alpha: 1)
    
    let kCloseCellHeight: CGFloat = 179
    let kOpenCellHeight: CGFloat = 488
    let kRowsCount = 10
    var cellHeights: [CGFloat] = []
    var colors = [flatRed, flatBlue, flatGreen, flatYellow, flatPurple, flatDarkGreen]
    var titles = ["Tiger Inn", "Ivy Club", "Tower Club", "Chi Phi Rager", "Dave's BDay", "Pub Night"]
    
    var descriptions = ["Tiger Inn is one of eleven active eating clubs at Princeton.",
                        "Ivy Club is one of eleven active eating clubs at Princeton.",
                        "Tower Club is one of eleven active eating clubs at Princeton.",
                        "Chi Phi is having a rager today. Don't miss out #fraternity",
                        "You already know who it is. Your boy dave is throwing down.",
                        "Alpha Dog Brewery is hosting a pub crawl for fine food and drink."]
    
    
    let numberOfStops: Int = 15
    let feetToMileConv: Double = 0.000189393939
    
    var currentStop: String = ""
    var currentStopCode: String = ""
    
    fileprivate var lat: Double = 0
    fileprivate var long: Double = 0
    
    fileprivate var stopNameArr: NSArray = []
    fileprivate var stopIDArr: NSArray = []
    fileprivate var stopDistance: NSArray = []
    fileprivate var stopTableView: UITableView!
    
    fileprivate var currentStopData: mtd_stop_loc? = nil
    
    //private let refreshControl = UIRefreshControl()
    
     var initialLoad: Bool = false
    
    let locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkLocationEnabled()
        
        setup()
    }
    
    func isStopArrEmpty() -> Bool{
        return stopNameArr.count == 0
    }
    
    private func checkLocationEnabled(){
        // If location services is enabled get the users location and run functions, otherwise, provide a prompt that forces them to add location.
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined,.restricted, .denied:
                showLocationDisabledPopUp()
                print("denied")
            case .authorizedAlways, .authorizedWhenInUse:
                locationManager.delegate = self as? CLLocationManagerDelegate
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.startUpdatingLocation()
                print("enabled")
                downloadCurrentStopData()
                if(!isStopArrEmpty()){
                    //Set up for 3D Touch in the cells of stopTableView
                    registerForPreviewing(with: self as! UIViewControllerPreviewingDelegate, sourceView: stopTableView)
                }
                print("works!")
            }
        } else {
            print("Location services are not enabled")
            showLocationDisabledPopUp()
        }
    }
    
    /// Show the popup to the user if we have been deined access
    func showLocationDisabledPopUp() {
//        let alertController = UIAlertController(title: "Background Location Access Disabled",
//                                                message: "In order to get information about your closest stops we need your location",
//                                                preferredStyle: .alert)
//
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//        alertController.addAction(cancelAction)
//
//        let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
//            if let url = URL(string: UIApplication.openSettingsURLString) {
//                UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
//            }
//        }
//        alertController.addAction(openAction)
//
//        self.present(alertController, animated: true, completion: nil)
    }
    
    private func setup() {
        cellHeights = Array(repeating: kCloseCellHeight, count: kRowsCount)
        tableView.estimatedRowHeight = kCloseCellHeight
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .black
    }
    
    @IBAction func unwindToPasses(segue:UIStoryboardSegue) {
        
    }
    
    /// This function updates the current Lat and Long values. It also downloads the stop data from the API based on the current lat+long values.
    func downloadCurrentStopData (){
        
        self.lat = (self.locationManager.location?.coordinate.latitude)!
        self.long = (self.locationManager.location?.coordinate.longitude)!
        
        
        //had to add this because adding it directly to the url made swift throw an error.
        let countStopsAPI = "&count=" + self.numberOfStops.description
        
        guard let apiURL = URL(string: "https://developer.cumtd.com/api/v2.2/JSON/getstopsbylatlon?key=" + mainApiKey.description + "&lat="+self.lat.description + "&lon=" + self.long.description + countStopsAPI) else { return }
        
        URLSession.shared.dataTask(with: apiURL) { (data, response
            , error) in
            
            guard let data = data else { return }
            do {
                let decoder = JSONDecoder()
                //Decodes the JSON recieved from the url.
                let mtdData = try decoder.decode(mtd_stop_loc.self, from: data)
                self.currentStopData = mtdData
                DispatchQueue.main.async {
                    //Iterates through all of the stops in the decoded data (stops) in mtdData.
                    for i in 0..<mtdData.stops.count {
                        //Adds the stop name and stop id to respective arrays.
                        self.stopNameArr = self.stopNameArr.adding(mtdData.stops[i].stop_name) as NSArray
                        self.stopIDArr = self.stopIDArr.adding(mtdData.stops[i].stop_id) as NSArray
                        
                        //Gets the distance, in feet, and converts it to miles and adds it to the array.
                        let currentDistacne = ((mtdData.stops[i].distance)*self.feetToMileConv)
                        let roundedDownDistance = String(format: "%.2f", currentDistacne) + " mi"
                        self.stopDistance = self.stopDistance.adding(roundedDownDistance) as NSArray
                    }
                    
                    if(!self.initialLoad){
                        self.initialLoad = true
                        //self.displayTable()
                        
                    }
                    if(!self.isStopArrEmpty()){
                        self.stopTableView.reloadData()
                        //print(self.view.subviews.count)
                    }
                    
                }
            } catch let err {
                print("Error Downloading data", err)
            }
            }.resume()
    }
    
}



// MARK: - TableView
extension NearestViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard case let cell as DemoCell = cell else {
            return
        }
        
        cell.backgroundColor = .clear
        cell.titleText = titles[indexPath.row]
        cell.openBarColo.backgroundColor = colors[indexPath.row]
        cell.bigBGColor.backgroundColor = colors[indexPath.row]
        cell.closedBGColor.backgroundColor = colors[indexPath.row]
        cell.descLabel.text = descriptions[indexPath.row]
        
        
        if cellHeights[indexPath.row] == kCloseCellHeight {
            cell.unfold(false, animated: false, completion:nil)
        } else {
            cell.unfold(true, animated: false, completion: nil)
        }
        
        cell.number = indexPath.row
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FoldingCell", for: indexPath) as! FoldingCell
        let durations: [TimeInterval] = [0.26, 0.2, 0.2]
        cell.durationsForExpandedState = durations
        cell.durationsForCollapsedState = durations
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeights[indexPath.row]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //        let cell = tableView.cellForRow(at: indexPath) as! FoldingCell
        //
        //        if cell.isAnimating() {
        //            return
        //        }
        //
        //        var duration = 0.0
        //        let cellIsCollapsed = cellHeights[indexPath.row] == kCloseCellHeight
        //        if cellIsCollapsed {
        //            cellHeights[indexPath.row] = kOpenCellHeight
        //            cell.unfold(true, animated: true, completion: nil)
        //            duration = 0.5
        //        } else {
        //            cellHeights[indexPath.row] = kCloseCellHeight
        //            cell.unfold(false, animated: true, completion: nil)
        //            duration = 0.8
        //        }
        //
        //        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: { () -> Void in
        //            tableView.beginUpdates()
        //            tableView.endUpdates()
        //        }, completion: nil)
        //
    }
    
}
