//
//  MasterViewController.swift
//  WeatherAppCities_ET
//
//  Created by Student on 20/06/2020.
//  Copyright © 2020 Student. All rights reserved.
//

import UIKit

struct ConsolidatedWeather: Codable {
    let id: Int
    let weatherStateName, weatherStateAbbr, windDirectionCompass, created: String
    let applicableDate: String
    let minTemp, maxTemp, theTemp, windSpeed: Double
    let windDirection, airPressure: Double
    let humidity: Int
    let visibility: Double
    let predictability: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case weatherStateName = "weather_state_name"
        case weatherStateAbbr = "weather_state_abbr"
        case windDirectionCompass = "wind_direction_compass"
        case created
        case applicableDate = "applicable_date"
        case minTemp = "min_temp"
        case maxTemp = "max_temp"
        case theTemp = "the_temp"
        case windSpeed = "wind_speed"
        case windDirection = "wind_direction"
        case airPressure = "air_pressure"
        case humidity, visibility, predictability
    }
}

struct Weather: Codable {
    let consolidatedWeather: [ConsolidatedWeather]
    let time, sunRise, sunSet, timezoneName: String
    let parent: Parent
    let sources: [Source]
    let title, locationType: String
    let woeid: Int
    let lattLong, timezone: String
    
    enum CodingKeys: String, CodingKey {
        case consolidatedWeather = "consolidated_weather"
        case time
        case sunRise = "sun_rise"
        case sunSet = "sun_set"
        case timezoneName = "timezone_name"
        case parent, sources, title
        case locationType = "location_type"
        case woeid
        case lattLong = "latt_long"
        case timezone
    }
    
}

struct Parent: Codable {
    let title, locationType: String
    let woeid: Int
    let lattLong: String
    
    enum CodingKeys: String, CodingKey {
        case title
        case locationType = "location_type"
        case woeid
        case lattLong = "latt_long"
    }
}

struct Source: Codable {
    let title, slug: String
    let url: String
    let crawlRate: Int
    
    enum CodingKeys: String, CodingKey {
        case title, slug, url
        case crawlRate = "crawl_rate"
    }
}

protocol AddCity: AnyObject {
    func addCity(cityName: String, cityUrl: String)
}

class MasterViewController: UITableViewController, AddCity {

    var detailViewController: DetailViewController? = nil
    var addCityViewController: AddViewController? = nil
    var objects = [Any]()
    var index : Int = 0
    var weatherData = [Weather?]()
    var citiesNames = [String]()
    var citiesUrl = [String]()
    var count : Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.citiesNames.append("Warszawa")
        self.citiesNames.append("Londyn")
        self.citiesNames.append("San Francisco")
        self.citiesUrl.append("https://www.metaweather.com/api/location/523920/")
        self.citiesUrl.append("https://www.metaweather.com/api/location/44418/")
        self.citiesUrl.append("https://www.metaweather.com/api/location/2487956/")
//        self.loadWeatherData()
        for cityUrl in citiesUrl {
            self.loadWeatherData(url: cityUrl)
        }
        
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        navigationItem.title = "Ewa Tabor"
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    @objc
    func insertNewObject(_ sender: Any) {
        objects.insert(NSDate(), at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let cityWeatherData = weatherData[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.cityName = citiesNames[indexPath.row]
                controller.cityWeatherData = cityWeatherData
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
        if segue.identifier == "addCityDetail" {
            let viewController = segue.destination as! AddViewController
            viewController.delegateAction = self
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return citiesNames.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if (indexPath.row < weatherData.count){
            let cityWeatherData = weatherData[indexPath.row]
            if let chosenDayWeatherData = cityWeatherData?.consolidatedWeather[0] {
                cell.detailTextLabel?.text = String(chosenDayWeatherData.theTemp)
                cell.imageView?.image = UIImage(named: chosenDayWeatherData.weatherStateName)
            }
            cell.textLabel!.text = citiesNames[indexPath.row]
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            objects.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    func loadWeatherData(url: String){
        //"https://www.metaweather.com/api/location/523920/"
        if let url = URL(string: url) {
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
                        let response = try jsonDecoder.decode(Weather.self, from: data)
                        self.weatherData.append(response)
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
    
    func addCity(cityName: String, cityUrl: String) {
        self.citiesNames.append(cityName)
        self.citiesUrl.append(cityUrl)
        self.loadWeatherData(url: cityUrl)
    }

}

