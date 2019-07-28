//
//  ViewController.swift
//  Dish It Out
//
//  Created by Anish Roy on 6/16/18.
//  Copyright © 2018 Dish It Out. All rights reserved.
//

import UIKit
import CoreLocation
import Foundation
import Kanna
import Alamofire

struct Question {
    var questionString: String?
    var answers: [String]?
    var selectedAnswerIndex: Int?
}

var restWithMenus = [String]()
var city : String = "Austin"
var answerIndex = [Int]()
var lat : CLLocationDegrees = 30.310502
var long : CLLocationDegrees = -97.903097
var lats = [CLLocationDegrees]()
var lons = [CLLocationDegrees]()
var dishes = [String]()
var prices = [String]()

var foods = [Dish]()
var latsWMenu = [Double]()
var longsWMenu = [Double]()

var dishLats = [String]()
var dishLons = [String]()
var dishRests = [String]()

var questionsList: [Question] =
    [Question(questionString: "Question", answers: ["A1", "A2", "A3", "A4", "A5"], selectedAnswerIndex: nil),
    Question(questionString: "What cuisine would you like?", answers: ["Indian", "Chinese", "Mexican", "Italian", "Thai", "Vietnamese", "Korean", "Japanese", "American"], selectedAnswerIndex: nil),
     Question(questionString: "Which do you prefer?", answers: ["Sweet", "Sour", "Tart", "Salty", "Neither"], selectedAnswerIndex: nil),
     Question(questionString: "Which level of spicy would you prefer?", answers: ["Very", "Mild", "Barely", "None"], selectedAnswerIndex: nil), Question(questionString: "How many calories do you want?", answers: ["No Idea","0-300 Calories", "300-600 Calories", "600-1000 Calories", "1000+ Calories"],  selectedAnswerIndex: nil)]
var catAnswers = ["Indian", "Chinese", "Mexican", "Italian", "Thai", "Vietnamese", "Korean", "Japanese", "American"]
var names = [String]()
class HomeController: UIViewController, CLLocationManagerDelegate{
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        let button = UIButton(frame: CGRect(x: screenWidth/2 - 50, y: screenHeight/2 - 25 , width:100, height: 50))

        button.setTitle("Start Survey",  for: .normal)
        button.addTarget(self, action: #selector(beginSurvey), for: .touchUpInside)
        self.view.addSubview(button)
        view.backgroundColor = UIColor(red: 91/255, green: 144/255, blue: 234/255, alpha: 1.00)
        let imagePath = "DishItOutLogo.png"
        let image = UIImage(named: imagePath)
        let imageView = UIImageView(image: image)
        imageView.frame = CGRect(x: screenWidth/2 - 100, y: screenHeight/2 - 250, width: 200, height: 200)
        view.addSubview(imageView)
        let geoCoder = CLGeocoder()
        let loc = CLLocation(latitude: lat, longitude: long)
        geoCoder.reverseGeocodeLocation(loc, completionHandler: { (placemarks, error) -> Void in
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            if let city2 = placeMark.locality {
                print(city2)
                city = city2
            }
        })
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first{
            lat = location.coordinate.latitude
            long = location.coordinate.longitude
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if(status == CLAuthorizationStatus.denied){
            
        }
    }
    func showLocationDisabledPopup(){
        let alertController = UIAlertController(title: "Background Location Access Disabled.", message: "In order to find you dishes, we need your location.", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        let openAction = UIAlertAction(title: "Open Settings", style: .default){ (action) in
            if let url = URL(string: UIApplicationOpenSettingsURLString){
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        alertController.addAction(openAction)
        self.present(alertController, animated: true, completion:nil)
    }
    
    @objc func beginSurvey(sender_: UIButton!){
        print("Start Survey")
        let questionController = QuestionController()
        navigationController?.pushViewController(questionController, animated: true)
    }
}
class QuestionController: UITableViewController {

    let cellId = "cellId"
    let headerId = "headerId"
    var nextButtonPressed : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationItem.title = "Question"
        tableView.register(AnswerCell.self, forCellReuseIdentifier: cellId)
        tableView.register(QuestionHeader.self, forHeaderFooterViewReuseIdentifier: headerId)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        let nextButton = UIButton()
        nextButton.addTarget(self, action: #selector(QuestionController.nextAction), for: .touchUpInside)
        nextButton.setTitle("Next", for: .normal)
        let butitem = UIBarButtonItem(customView: nextButton)
        navigationItem.rightBarButtonItem = butitem
        tableView.sectionHeaderHeight = 50
        tableView.tableFooterView = UIView()
        self.tableView.allowsMultipleSelection = true

    }
     @objc func nextAction(){
        nextButtonPressed = true
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let index = navigationController?.viewControllers.index(of: self){
            let question = questionsList[index]
            if let count = question.answers?.count{
                return count
            }
        }
        return 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
         as! AnswerCell
        if let index = navigationController?.viewControllers.index(of: self){
            let question = questionsList[index]
            cell.nameLabel.text = question.answers?[indexPath.row]
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerId)
          as! QuestionHeader
        
        if let index = navigationController?.viewControllers.index(of: self){
            let question = questionsList[index]
            header.nameLabel.text = question.questionString
        }
        return header
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let index = navigationController?.viewControllers.index(of: self){
    /*        if(nextButtonPressed && index == questionsList.count - 2 ){
                print("njfasdjk")
                questionsList[index].selectedAnswerIndex = indexPath.item + 1
                print(questionsList[index].selectedAnswerIndex as Any)
                let questionController = QuestionController()
                navigationController?.pushViewController(questionController, animated: true)
                nextButtonPressed = false
            } */
            questionsList[index].selectedAnswerIndex = indexPath.item
             if(index < questionsList.count - 1){
                let questionController = QuestionController()
                navigationController?.pushViewController(questionController, animated: true)
            } else {
                let controller = ResultsController()
                navigationController?.pushViewController(controller, animated: true)
            }
        }
    }

}
class ResultsController: UIViewController {
    var dishView = UIImageView()
    
    let resultsLabel: UILabel = {
        let label = UILabel ();
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        view.addSubview(resultsLabel)
        dishView.frame = CGRect(x: 0, y: 50, width: 100, height: 100)
        view.addSubview(dishView)
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": resultsLabel]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": resultsLabel]))
        for question in questionsList{
            if question.selectedAnswerIndex != nil{
                answerIndex.append(question.selectedAnswerIndex!)}
        }
        if answerIndex.count >= questionsList.count{
            for _ in 1...(questionsList.count - 1){
            answerIndex.remove(at: 0)

            }
        }
        resultsLabel.numberOfLines = 100
        getBusinesses()
      //  resultsLabel.text = "Your answers were \(answerIndex)!\n You live in \(lat) , \(long)."
        usleep(2000000)
        //resultsLabel.text = "\(names)"
        for index in 0...(names.count - 1){
            searchForBusiness(lat: "\(lats[index])", lon: "\(lons[index])", name: "\(names[index])")
        }
  /*      for i in 0...(dishes.count - 1){
            foods.append(Dish(name: dishes[i], price: prices[i], restaurant: dishRests[i], lat: dishLats[i], long: dishLons[i]))
        } */
        getImage(search: "Paneer biryani")
    }
    
    func searchForBusiness(lat: String, lon: String, name: String) -> Void {
        let url : String = "https://www.allmenus.com/custom-results/\(name)/\(city)/"
        let newUrl : String = url.replacingOccurrences(of: " ", with: "%20")
       //Alamofire.request("https://www.allmenus.com/custom-results/\(name)/\(lat)%2C%20\(lon)/?sort=rating").responseString { response in
        Alamofire.request(newUrl).responseString { response in
            print("\(response.result.isSuccess)")
            if let html = response.result.value {
                self.parseBusinessURL(html: html, name : name, lat: lat, lon: lon)
            }
            if response.result.isSuccess {
                restWithMenus.append(name)
            }
        }
            print(newUrl)
    }
    
    func parseBusinessURL(html: String, name : String, lat: String, lon: String) -> Void {
        if let doc = try? HTML(html: html, encoding: .utf8) {
            // Search for nodes by CSS
            for link in doc.css("a[data-masterlist-id]") {
                print(link.text!)
                guard let url = link["href"] else {
                    print("No Matching Restaurants")
                    return
                }
                getMenuHTML(url: url, name: name, lat: lat, lon: lon)
            }
        }
    }
    
    func getMenuHTML(url: String, name : String, lat: String, lon: String){
        Alamofire.request("https://www.allmenus.com/\(url)").responseString { response in
            print("\(response.result.isSuccess)")
            if let html = response.result.value {
                self.getMenuText(html: html, name : name, lat: lat, lon: lon)
            }
        }
    }
    
    func getMenuText(html: String, name : String, lat: String, lon: String){
        if let doc = try? HTML(html: html, encoding: .utf8) {
            // Search for nodes by CSS
            for item in doc.css("span[class='item-title']") {
             //   print(item.text!)
                dishes.append(item.text!)
                dishLats.append(lat)
                dishLons.append(lon)
                dishRests.append(name)
            }
            for price in doc.css("span[class='item-price']") {
                guard let priceString = price.text else {
                    print("Price Cannot Be String")
                    return
                }
             //   print(priceString.replacingOccurrences(of: "\n", with: "", options: .regularExpression))
                prices.append(priceString.replacingOccurrences(of: "\n", with: "", options: .regularExpression))
            }
        }
        for index in (foods.count)...(dishes.count){
            if index != dishes.count {
              foods.append(Dish(name: dishes[index], price: prices[index], restaurant: dishRests[index], lat: dishLats[index], long: dishLons[index]))
            }
        }
        setResultsLabel()
    }
    func setResultsLabel(){
        var s : String = ""
        for _ in 0...4 {
            let x  = Int(arc4random_uniform(UInt32(foods.count)))
            print((foods[x].name)!)

            s.append("Dish: " + (foods[x].name)! + "\n Price: " + ((foods[x].price)!).trimmingCharacters(in: .whitespacesAndNewlines) + "\n Restaurant: " + (foods[x].restaurant)! + "\n")
            
        }
        resultsLabel.text = s
    }
    func getImage(search: String){
      /*  Alamofire.request("https://www.googleapis.com/customsearch/v1?q=\(search.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)&cx=015380519131246305033:rllmwwh0w3q&num=1&key=AIzaSyC-Ukv8dvU98AXvCPQ_5hakjTONPeyG9YA").responseString{ response in
            print("\(response.result.isSuccess)")
            guard let resp = response.result.value else {
                print("Bad Response")
                return
            }
                print(resp.capturedGroups(withRegex: "\"imageobject\": \\[[\\n ]+{[\\n ]+\"url\": \"(.+)\""))
            }
        
 */
        let strURL1 : String = "https://t5dw12a2mxz42vnqk1utxqwi-wpengine.netdna-ssl.com/wp-content/uploads/sites/2/2017/12/IMG_1339.jpg"
        Alamofire.request(strURL1).responseData(completionHandler: { response in
            if let dishPic = response.result.value {
                let image = UIImage(data: dishPic)
                self.dishView.image = image
            }
        })
    }
    
    func getBusinesses() {
        lat = 30.310502
        long = -97.903097
        
        let radius: Int = 16100
        let search: String = catAnswers[answerIndex[0]]
        let categories: String = catAnswers[answerIndex[0]]
        let site: String = "https://api.yelp.com/v3/businesses/search?term=\(search)&categories=\(categories)&latitude=\(lat)&longitude=\(long)&radius=\(radius)"
        
        guard let url = URL(string: site) else{
            print("error")
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("Bearer igeAKYMC9JXIWmFEy7UU8YqVrSDDAKP48_5iDUstet3yiddKVqMrvV-wfVADWNBqglVl80KPlz_99Y86xiT7VW96woq25wrKl3Amm6IK1_0wIy09GAk5iSzMT9EmW3Yx", forHTTPHeaderField: "Authorization")
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            // check for any errors
            guard error == nil else {
                print("error calling GET")
                print(error!)
                return
            }
            
            // parse the result as JSON, since that's what the API provides
            do {
                if let data = data,
                    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                    let businesses = json["businesses"] as? [[String: Any]] {
                    for business in businesses {
                        if let name = business["name"] as? String {
                            names.append(name)
                        }
                        if let coords = business["coordinates"] as? [String: Any]{
                            if let lon = coords["longitude"] as? Double, let lat = coords["latitude"] as? Double{
                                lons.append(lon)
                                lats.append(lat)
                            }
                        }
                    }
                    for index in 0...(names.count - 1){
                        print("\(names[index]) : \(lats[index]) , \(lons[index])")
                    }
                }
            } catch  {
                print("error trying to convert data to JSON")
                return
            }
        }
        task.resume()
    }
}

class QuestionHeader: UITableViewHeaderFooterView{
    override init(reuseIdentifier: String?){
        super.init(reuseIdentifier: reuseIdentifier)
        setUpViews()
    }
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Sample Question"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    func setUpViews(){
        addSubview(nameLabel)
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[v0]", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":nameLabel]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-16-[v0]", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":nameLabel]))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class AnswerCell: UITableViewCell{
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpViews()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Sample Answer"
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    func setUpViews(){
        addSubview(nameLabel)
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[v0]", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":nameLabel]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[v0]", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":nameLabel]))
    }
class CheckableTableViewCell: UITableViewCell {
        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            self.selectionStyle = .none
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        override func setSelected(_ selected: Bool, animated: Bool) {
            super.setSelected(selected, animated: animated)
            self.accessoryType = selected ? .checkmark : .none
        }
    }
}
extension String {
    func capturedGroups(withRegex pattern: String) -> [String] {
        var results = [String]()
        
        var regex: NSRegularExpression
        do {
            regex = try NSRegularExpression(pattern: pattern, options: [])
        } catch {
            return results
        }
        
        let matches = regex.matches(in: self, options: [], range: NSRange(location:0, length: self.characters.count))
        
        guard let match = matches.first else { return results }
        
        let lastRangeIndex = match.numberOfRanges - 1
        guard lastRangeIndex >= 1 else { return results }
        
        for i in 1...lastRangeIndex {
            let capturedGroupIndex = match.range(at: i)
            let matchedString = (self as NSString).substring(with: capturedGroupIndex)
            results.append(matchedString)
        }
        
        return results
    }
}

class Dish {
    var name: String?
    var price: String?
    var restaurant: String?
    var lat : String?
    var long : String?
    
    init(name: String, price: String, restaurant: String, lat : String, long: String) {
        self.name = name
        self.price = price
        self.restaurant = restaurant
        self.lat = lat
        self.long = long
    }
}


