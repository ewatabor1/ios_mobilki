//
//  AddViewController.swift
//  WeatherAppCities_ET
//
//  Created by Student on 20/06/2020.
//  Copyright © 2020 Student. All rights reserved.
//

import Foundation

import UIKit


struct City: Codable {
    let title: String
    let locationType: LocationType
    let woeid: Int
    let lattLong: String
    
    enum CodingKeys: String, CodingKey {
        case title
        case locationType = "location_type"
        case woeid
        case lattLong = "latt_long"
    }
}

enum LocationType: String, Codable {
    case city = "City"
}

typealias Cities = [City]

class AddViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet var tableView: UITableView!
    weak var delegateAction: AddCity?
    var citiesData: Cities?
    @IBOutlet var searchCityName: UITextField!
    

    @IBAction func searchButtonAction(_ sender: Any) {
        self.loadCitiesData()
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
    func configureView() {
        // Update the user interface for the detail item.
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()       // Do any additional setup after loading the view, typically from a nib.
        self.tableView.dataSource = self
        self.tableView.delegate = self
        configureView()
    }
    
    var detailItem: NSDate? {
        didSet {
            // Update the view.
            configureView()
        }
    }

    
    func loadCitiesData(){
        if searchCityName.text=="" || searchCityName==nil{
            return
        }
        var url1 = "https://www.metaweather.com/api/location/search/?query=" + self.searchCityName.text!
        if let url = URL(string: url1) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if error  != nil {
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse,
                    (200...299).contains(httpResponse.statusCode) else {
                        return
                }
                if let data = data {
                    let jsonDecoder = JSONDecoder()
                    do{
                            let response = try jsonDecoder.decode(Cities.self, from: data)
                            self.citiesData = response
                    }
                    catch {
                        print(error)
                    }
                    DispatchQueue.main.async {
                            self.tableView.reloadData()
                    }
                }
                
                
                }.resume()
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.citiesData?.count ?? 0
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cityName = citiesData?[indexPath.row].title
        let cityUrl = "https://www.metaweather.com/api/location/" + String(citiesData![indexPath.row].woeid)
        delegateAction?.addCity(cityName: cityName!, cityUrl: cityUrl)
        _ = navigationController?.popViewController(animated: true)
        }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cityCell")
        cell.textLabel?.text = citiesData?[indexPath.row].title
        return cell
    }
    
    func addCityMain(cityName: String, cityUrl:String){
        delegateAction?.addCity(cityName: cityName, cityUrl: cityUrl)
    }
    
}

