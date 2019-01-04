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
import UserNotifications

class NearestViewController: UITableViewController {
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
    
    //internal let refreshControl = UIRefreshControl()
    
    let locationManager = CLLocationManager()
    
    let center = UNUserNotificationCenter.current()
    let options: UNAuthorizationOptions = [.alert, .sound];
    
    var initialLoad: Bool = false
    
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
    var colors = [flatRed, flatBlue, flatGreen, flatYellow, flatPurple, flatDarkGreen,flatRed, flatBlue, flatGreen, flatYellow, flatPurple, flatDarkGreen,flatRed, flatBlue, flatGreen]
    var titles = ["LOADING"]
    
    var descriptions: NSArray = ["LOADING"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        self.lat = (self.locationManager.location?.coordinate.latitude)!
        self.long = (self.locationManager.location?.coordinate.longitude)!
        print(lat.description + "\n" + long.description)
        downloadCurrentStopData()
        
    }
    
    @IBAction func unwindToPasses(segue:UIStoryboardSegue) {
        
    }
    
    private func setup() {
        cellHeights = Array(repeating: kCloseCellHeight, count: count)
        tableView.estimatedRowHeight = kCloseCellHeight
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .black
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        print("test")
        
        self.lat = (self.locationManager.location?.coordinate.latitude)!
        self.long = (self.locationManager.location?.coordinate.longitude)!
        
    }
    
    /// This function updates the current Lat and Long values. It also downloads the stop data from the API based on the current lat+long values.
    func downloadCurrentStopData (){
        
        //had to add this because adding it directly to the url made swift throw an error.
        let countStopsAPI = "&count=" + self.numberOfStops.description
        
        guard let apiURL = URL(string: "https://developer.cumtd.com/api/v2.2/JSON/getstopsbylatlon?key=" + mainApiKey.description + "&lat="+self.lat.description + "&lon=" + self.long.description + countStopsAPI) else { return }
        
        let group = DispatchGroup()
        group.enter()
        DispatchQueue.main.async {
            URLSession.shared.dataTask(with: apiURL) { (data, response
                , error) in
                print(data! as NSData)
                guard let data = data else { return }
                do {
                    let decoder = JSONDecoder()
                    //Decodes the JSON recieved from the url.
                    let mtdData = try decoder.decode(mtd_stop_loc.self, from: data)
                    self.currentStopData = mtdData
                    
                    //Iterates through all of the stops in the decoded data (stops) in mtdData.
                    for i in 0..<mtdData.stops.count {
                        //Adds the stop name and stop id to respective arrays.
                        self.stopNameArr = self.stopNameArr.adding(mtdData.stops[i].stop_name) as NSArray
                        self.stopIDArr = self.stopIDArr.adding(mtdData.stops[i].stop_id) as NSArray
                        
                        //Gets the distance, in feet, and converts it to miles and adds it to the array.
                        let currentDistacne = ((mtdData.stops[i].distance)*self.feetToMileConv)
                        let roundedDownDistance = String(format: "%.2f", currentDistacne) + "\n mi"
                        self.stopDistance = self.stopDistance.adding(roundedDownDistance) as NSArray
                    }
                    self.descriptions = self.stopNameArr
                    self.titles = self.stopDistance as! [String]
                    self.count = 15
                    self.cellHeights = Array(repeating: self.kCloseCellHeight, count: self.count)
                    if(!self.isStopArrEmpty()){
                        
                        self.tableView.reloadData()
                        //print(self.view.subviews.count)
                    }
                } catch let err {
                    print("Error Downloading data", err)
                }
                }.resume()
            group.leave()
        }
    }
    
    var count = 1
    
    func isStopArrEmpty() -> Bool{
        return stopNameArr.count == 0
    }
    
}


extension NearestViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return count
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
        cell.descLabel.text = descriptions[indexPath.row] as? String
        
        
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
        
        let cell = tableView.cellForRow(at: indexPath) as! FoldingCell
        
        if cell.isAnimating() {
            return
        }
        
        var duration = 0.0
        let cellIsCollapsed = cellHeights[indexPath.row] == kCloseCellHeight
        if cellIsCollapsed {
            cellHeights[indexPath.row] = kOpenCellHeight
            cell.unfold(true, animated: true, completion: nil)
            duration = 0.5
        } else {
            cellHeights[indexPath.row] = kCloseCellHeight
            cell.unfold(false, animated: true, completion: nil)
            duration = 0.8
        }
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: { () -> Void in
            tableView.beginUpdates()
            tableView.endUpdates()
        }, completion: nil)
        
    }
    
}

