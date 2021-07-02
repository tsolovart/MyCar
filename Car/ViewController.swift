//
//  ViewController.swift
//  Car
//
//  Created by Zaoksky on 24.06.2021.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    var context: NSManagedObjectContext!
    var selectedCar: Car!
    // lazy var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var markLabel: UILabel!
    @IBOutlet weak var modelLabel: UILabel!
    @IBOutlet weak var carImageView: UIImageView!
    @IBOutlet weak var lastTimeStartedLabel: UILabel!
    @IBOutlet weak var numberOfTripsLabel: UILabel!
    @IBOutlet weak var ratingLable: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getDataFromFile()
        
        // загрузка данных из Core Data, если они там есть. Если нет, то метод getDataFromFile()
        let fetchRequest: NSFetchRequest<Car> = Car.fetchRequest()
        // марка авто заголовок segmentedControl
        let mark = segmentedControl.titleForSegment(at: 0)
        // информация о моделе
        fetchRequest.predicate = NSPredicate(format: "mark == %@", mark!)
        
        do {
            let results = try context.fetch(fetchRequest)
            selectedCar = results[0]
            insertDataFrom(selectedCar: selectedCar)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // получение инфо. об авто.
    func insertDataFrom(selectedCar: Car) {
        carImageView.image = UIImage(data: selectedCar.imageData! as Data)
        markLabel.text = selectedCar.mark
        modelLabel.text = selectedCar.model
        ratingLable.text = "Rating: \(selectedCar.rating!.doubleValue) / 10.0"
        numberOfTripsLabel.text = "Number of trips: \(selectedCar.timeDriven!.intValue)"
        
        // дата в текстовом формате
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .none
        lastTimeStartedLabel.text = "Last time started: \(df.string(from: selectedCar.lastStarted! as Date))"
        
        segmentedControl.tintColor = selectedCar.tintColor as? UIColor
    }
    
    // загрузка с data.plist. Если есть запись в Core Data, то чтение с .plist не будет
    func getDataFromFile() {
        
        // проверка. Если записи в Core Data?
        let fetchRequest: NSFetchRequest<Car> = Car.fetchRequest()
        
        // .predicate - установка критерий для получения записи. Установка критерия прохода всех автомобилей.
        fetchRequest.predicate = NSPredicate(format: "mark != nil")
        
        // для проверки кол-ва записей в Core Data
        var records = 0
        
        // извлечение записей
        do {
            let count = try context.count(for: fetchRequest)
            records = count
            print("Data is there already?")
        } catch {
            print(error.localizedDescription)
        }
        
        // Если получили кол-во записей != 0, значит есть запись в Core Data
        // Проверка кол-ва записей
        guard records == 0 else { return }
        
        // Путь до файла для считывания. Bundle - это наш проект
        let pathToFile = Bundle.main.path(forResource: "data", ofType: "plist")
        // [Словарей] Получение содержимого файла data.plist
        let dataArray = NSArray(contentsOfFile: pathToFile!)!
        
        for dictionary in dataArray {
            // каждая сущность соответствует словарю
            let entity = NSEntityDescription.entity(forEntityName: "Car", in: context)
            // объект с данными из словаря
            let car = NSManagedObject(entity: entity!, insertInto: context) as! Car
            
            // присваиваем объекту car значения из словаря
            let carDictionary = dictionary as! NSDictionary
            car.mark = carDictionary["mark"] as? String
            car.model = carDictionary["model"] as? String
            car.lastStarted = carDictionary["lastStarted"] as? NSDate
            car.timeDriven = carDictionary["timeDriven"] as? NSNumber
            car.rating = carDictionary["rating"] as? NSNumber
            
            let imageName = carDictionary["imageName"] as? String
            let image = UIImage(named: imageName!)
            // представление в формате Data
            let imageData = image!.pngData()
            car.imageData = imageData as NSData?
            
            // словарь цветов
            let colorDictionary = carDictionary["tintColor"] as? NSDictionary
            car.tintColor = getColor(colorDictionary: colorDictionary!)
        }
    }
    
    func getColor(colorDictionary: NSDictionary) -> UIColor {
        let red = colorDictionary["red"] as! NSNumber
        let green = colorDictionary["green"] as! NSNumber
        let blue = colorDictionary["blue"] as! NSNumber
        
        // / 255 - т.к. значение должно быть от 0 до 1
        return UIColor(red: CGFloat(red.floatValue) / 255,
                       green: CGFloat(green.floatValue) / 255,
                       blue: CGFloat(blue.floatValue) / 255,
                       alpha: 1.0)
    }
    
    @IBAction func segmentedCtrlPressed(_ sender: UISegmentedControl) {
        
        // sender = egmentedCtrl, но уже с заголовком
        let mark = sender.titleForSegment(at: sender.selectedSegmentIndex)
        // создание запроса
        let fetchRequest: NSFetchRequest<Car> = Car.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "marl == %@", mark!)
        
        // выполнение запроса
        do {
            let results = try context.fetch(fetchRequest)
            // сохранение результата
            selectedCar = results[0]
            // отображение данных
            insertDataFrom(selectedCar: selectedCar)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @IBAction func startEnginePressed(_ sender: UIButton) {
        // let для сохранения текущего кол-ва поездок. .intValue - приобразуем в Int
        let timesDriven = selectedCar.timeDriven?.intValue
        selectedCar.timeDriven = NSNumber(value: timesDriven! + 1)
        // обновление св-ва .lastStarted (поездка была совершена)
        selectedCar.lastStarted = NSDate()
        
        // сохранение
        do {
            try context.save()
            // обновление экрана
            insertDataFrom(selectedCar: selectedCar)
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    @IBAction func rateItPressed(_ sender: UIButton) {
        let ac = UIAlertController(title: "Rate it", message: "Rate this car please", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) {
            action in
            // текстовое поле. Будет всего 1
            let textField = ac.textFields?[0]
            // значение, вписанное в textField = рейтинг
            self.update(rating: textField!.text!)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        // добавление textField в AC
        ac.addTextField {
            textField in
            // тип клавиатуры для TextField
            textField.keyboardType = .numberPad
        }
        
        ac.addAction(ok)
        ac.addAction(cancel)
        present(ac, animated: true, completion: nil)
    }
    
    func update(rating: String) {
        // обновление рейтинга
        selectedCar.rating = NSNumber(value: Double(rating)!)
        
        // сохранение
        do {
            try context.save()
            // обновление экрана
            insertDataFrom(selectedCar: selectedCar)
        } catch {
            
            // если неправильно поставили рейтинг
            let ac = UIAlertController(title: "Wrong value", message: "Wrong input", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            ac.addAction(ok)
            present(ac, animated: true, completion: nil)
            print(error.localizedDescription)
        }
    }    
}

