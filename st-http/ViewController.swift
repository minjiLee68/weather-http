//
//  ViewController.swift
//  st-http
//
//  Created by 이민지 on 2022/04/20.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var cityNameTextField: UITextField!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var templebel: UILabel!
    @IBOutlet weak var maxTempLebel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var minTempLebel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func TabFetchWeather(_ sender: Any) {
        if let cityName = self.cityNameTextField.text {
            self.getCurrentWeather(cityName: cityName)
            self.view.endEditing(true)
        }
    }
    
    func configureView(weatherInformation: WeatherInformation) {
        self.cityNameLabel.text = weatherInformation.name
        if let weather = weatherInformation.weather.first {
            self.weatherLabel.text = weather.description
        }
        self.templebel.text = "\(Int(weatherInformation.temp.temp - 273.15))℃"
        self.minTempLebel.text = "최저:\(Int(weatherInformation.temp.minTemp - 273.15))℃"
        self.maxTempLebel.text = "최고:\(Int(weatherInformation.temp.maxTemp - 273.15))℃"
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "에러", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func getCurrentWeather(cityName: String) {
        guard let url = URL(string: "http://api.openweathermap.org/data/2.5/weather?q=\(cityName)&appid=7374416e0b2e0e1040bcfe3c7b30390b") else {
            return
        }
        let session = URLSession(configuration: .default)
        session.dataTask(with: url) { [weak self] data, reponse, error in
            let succssRange = (200..<300)
            guard let data = data, error == nil else { return }
            let decoder = JSONDecoder()
            if let reponse = reponse as? HTTPURLResponse, succssRange.contains(reponse.statusCode) {
                guard let weatherInformation = try? decoder.decode(WeatherInformation.self, from: data) else { return }
                DispatchQueue.main.async {
                    self?.stackView.isHidden = false
                    self?.configureView(weatherInformation: weatherInformation)
                }
            }else {
                guard let errorMessage = try? decoder.decode(ErrorMessage.self, from: data) else { return }
                debugPrint(errorMessage)
                DispatchQueue.main.async {
                    self?.showAlert(message: errorMessage.message)
                }
            }
        }.resume()
    }
}
//웹통신 - 인터넷 상에서의 통신
// 많은 정보들을 주고 받기에 인터넷에는 엄격한 규약이 존재한다. 이것을 protocol이라 부른다.
