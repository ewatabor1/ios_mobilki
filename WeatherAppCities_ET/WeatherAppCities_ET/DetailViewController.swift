//
//  DetailViewController.swift
//  WeatherAppCities_ET
//
//  Created by Student on 20/06/2020.
//  Copyright © 2020 Student. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!
    
    
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
    
    var index : Int = 0
    var cityWeatherData: Weather?
    var count : Int = 0
    var cityName: String?
    


    func configureView() {
       // Update the user interface for the detail item.
        if let detail = detailItem {
            if let label = detailDescriptionLabel {
                label.text = detail.description
           }
        }
        if let city = cityName {
            navigationItem.title = city
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.backButton.isEnabled = false        // Do any additional setup after loading the view, typically from a nib.
        self.initializeView()
        configureView()
    }

    var detailItem: NSDate? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    
    func initializeView(){
        if let tempCount = self.cityWeatherData?.consolidatedWeather.count {
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
        if let chosenDayWeatherData = self.cityWeatherData?.consolidatedWeather[index] {
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

