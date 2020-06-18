//
//  ViewController.swift
//  WeatherApp_ET
//
//  Created by Student on 17/06/2020.
//  Copyright © 2020 agh. All rights reserved.
//

import UIKit
import Foundation


class ViewController: UIViewController {
    

    @IBOutlet var tempLabel: UILabel!
    @IBOutlet var typeLabel: UILabel!
    @IBOutlet var tempMinLabeel: UILabel!
    @IBOutlet var tempMaxLabel: UILabel!
    
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var typeValue: UILabel!
    
    @IBOutlet var tempValue: UILabel!
    @IBOutlet var tempMinValue: UILabel!
    @IBOutlet var tempMaxValue: UILabel!
    @IBOutlet var windSpeedValue: UILabel!
    @IBOutlet var windDirectionValue: UILabel!
    @IBOutlet var rainfallValue: UILabel!
    @IBOutlet var pressureValue: UILabel!
    @IBOutlet var dateValue: UILabel!
    
    @IBOutlet var backButton: UIButton!
    @IBOutlet var nextButton: UIButton!

    @IBAction func nextButtonAction(_sender : Any) {
        if (self.count != self.index + 1 && self.count != 0){
            print("go next")
            self.backButton.isEnabled = true
            self.index = self.index + 1
            self.updateView(index: self.index)
            if (self.count == self.index + 1){
                self.nextButton.isEnabled = false
            }
            else {
                self.nextButton.isEnabled = true
            }
        }
    }

    @IBAction func backButtonAction(_sender: Any) {
        if (self.index > 0 ){
            self.nextButton.isEnabled = true
            self.index = self.index - 1
            self.updateView(index: self.index)
            if (self.index == 0){
                self.backButton.isEnabled = false
            }
            else {
                self.backButton.isEnabled = true
            }
        }
    }
    
    
    
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
    
    var index : Int = 0
    var weatherData: Weather?
    var count : Int = 0
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.backButton.isEnabled = false
        print("view loaded.")
        self.loadWeatherData()
        self.initializeView(weatherData: self.weatherData)
    }
    
    func setLabelsValue (text: String){
        self.typeValue.text = text
        self.tempMinValue.text=text
        self.tempMaxValue.text=text
        self.windSpeedValue.text=text
        self.windDirectionValue.text=text
        self.rainfallValue.text=text
        self.pressureValue.text=text
    }
    
    func loadWeatherData(){
        if let url = URL(string: "https://www.metaweather.com/api/location/523920/") {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if error  != nil {
                    self.setLabelsValue(text: "client error")
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse,
                    (200...299).contains(httpResponse.statusCode) else {
                        self.setLabelsValue(text: "server error")
                        return
                }
                if let data = data {
                    let jsonDecoder = JSONDecoder()
                    do{
                        let response = try jsonDecoder.decode(Weather.self, from: data)
                        self.weatherData = response
                                            }
                    catch {
                        print(error)
                    }
                    DispatchQueue.main.async {
                        self.initializeView(weatherData: self.weatherData)
                    }
                }
                
                }.resume()
        }
        
    }
    
    func initializeView(weatherData: Weather?){
        self.weatherData = weatherData
        if let tempCount = self.weatherData?.consolidatedWeather.count {
            self.count = tempCount
            if (self.count > 1) {
                self.nextButton.isEnabled = true
            }
        }
        else {
            self.nextButton.isEnabled = false
        }
        self.updateView(index: self.index)
    }
    
    func updateView(index: Int){
        if let chosenDayWeatherData = self.weatherData?.consolidatedWeather[index] {
            self.imageView.image = UIImage(named: chosenDayWeatherData.weatherStateName)
            self.imageView.setNeedsDisplay()
            self.typeValue.text = String(chosenDayWeatherData.weatherStateName)
            self.tempMinValue.text = String(chosenDayWeatherData.minTemp)
            self.tempMaxValue.text = String(chosenDayWeatherData.maxTemp)
            self.windDirectionValue.text = String(chosenDayWeatherData.windDirection)
            self.windSpeedValue.text = String(chosenDayWeatherData.windSpeed)
            self.rainfallValue.text = String(chosenDayWeatherData.humidity)
            self.pressureValue.text = String(chosenDayWeatherData.airPressure)
            self.tempValue.text = String(chosenDayWeatherData.theTemp)
            self.dateValue.text = String(chosenDayWeatherData.applicableDate)
        }
        else {
        }
        
    }
    
    
}

