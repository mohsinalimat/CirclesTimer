import UIKit
import CoreData

protocol ChartsDataProviderDelegate : class {
    func chartDataFullUpdate()
    func chartDataDayUpdate(_ yModelUpdate: Bool)
}

class PomodoroDataProvider {
    
    static let sharedInstance = PomodoroDataProvider()
    
    weak var chartsDelegate: ChartsDataProviderDelegate?
    var context = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    var coordinator = (UIApplication.shared.delegate as! AppDelegate).persistentStoreCoordinator
    
    fileprivate var currentHourValue: Double = 0
    var maximumHourValue: Double {
        get {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: PomodoroData.entityName)
            fetchRequest.fetchLimit = 1
            let sortDescriptor = NSSortDescriptor(key: "totalTime", ascending: false)
            fetchRequest.sortDescriptors = [sortDescriptor]
            
            let requestResult = executeFetchRequest(fetchRequest)
            if requestResult.count == 1 && requestResult[0].hours! > ChartConstants.minimumDisplayedHours {
                currentHourValue = round(requestResult[0].hours!) + 1
            } else {
                currentHourValue = 6.0
            }
            return currentHourValue
        }
    }
    
    fileprivate func executeFetchRequest(_ fetchRequest: NSFetchRequest<NSManagedObject>) -> [PomodoroDay] {
        do {
            let result = (try context.fetch(fetchRequest)) as! [PomodoroData]
            return result.map({ PomodoroDay(date: $0.date, seconds: $0.totalTime) })
            
        } catch let error as NSError {
            log(error)
        }
        
        return []
    }
    
    fileprivate func fetchInterval(_ startDate: Date, endDate: Date, today: Date, calendar: Calendar, fromNow: Int, daysCount: Int) -> [PomodoroDay] {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: PomodoroData.entityName)
        let predicate = NSPredicate(format: "%K >= %@ AND %K <= %@", "date", startDate as CVarArg, "date", endDate as CVarArg)
        fetchRequest.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        var requestResult = executeFetchRequest(fetchRequest)
        var result : [PomodoroDay] = []
        var index = 0
        for offset in 0...daysCount {
            let currentDate = calendar.date(byAdding: .day, value: offset, to: startDate)!
            if index < requestResult.count && (currentDate == requestResult[index].date) {
                result.append(requestResult[index])
                index += 1
            } else {
                let seconds : Double? = fromNow > 0 || (fromNow == 0 && currentDate.compare(today) == .orderedDescending) ? nil : 0.0
                result.append(PomodoroDay(date: currentDate, seconds: seconds))
            }
        }
        return result
    }

    
    fileprivate func getWeek(_ fromNow: Int) -> [PomodoroDay] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        let weekDayOffset = calendar.firstWeekday == 1 ? 0 : -1
        var weekDay = calendar.component(.weekday, from: today) + weekDayOffset
        if weekDay == 0 {
            weekDay = 7
        }
        
        let startDayOffset = -(weekDay - 1) + 7 * fromNow
        let startDate = calendar.date(byAdding: .day, value: startDayOffset, to: today)!
        let endDate = calendar.date(byAdding: .day, value: 7, to: startDate)!
        
        return fetchInterval(startDate, endDate: endDate, today: today, calendar: calendar, fromNow: fromNow, daysCount: 6)
    }
    
    fileprivate func getMonth(_ fromNow: Int) -> [PomodoroDay] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        var startComponents = calendar.dateComponents([.month, .year], from: today)
        startComponents.day = 1
        var startDate = calendar.date(from: startComponents)!
        if fromNow != 0 {
            startDate = calendar.date(byAdding: .month, value: fromNow, to: startDate)!
        }
        
        var endComponents = DateComponents()
        endComponents.day = -1
        endComponents.month = 1
        let endDate = calendar.date(byAdding: endComponents, to: startDate)!
        let daysCount = calendar.component(.day, from: endDate) - 1

        return fetchInterval(startDate, endDate: endDate, today: today, calendar: calendar, fromNow: fromNow, daysCount: daysCount)
    }
    
    fileprivate func getUnitStatistics(_ getterFunc: (Int) -> [PomodoroDay], fromNow: Int) -> [PomodoroDayStatistics] {
        let pomodoroDays = getterFunc(fromNow)
        
        var previousUnits = [[PomodoroDay]]()
        for i in 1...SettingsValues.chartLastUnitsCount {
            previousUnits.append(getterFunc(fromNow - i))
        }
        
        var previousSum = 0.0
        var previousNotZeroCount = 0.0
        var previousRealCount = 0.0
        for (_, day) in previousUnits[0].enumerated() {
            if let time = day.hours {
                previousRealCount += 1
                if time > 0 {
                    previousNotZeroCount += 1
                    previousSum += time
                }
            }
        }
        
        var temp = SettingsValues.chartIncludeZeroDays ? previousSum / previousRealCount : previousSum / previousNotZeroCount
        let averagePreviousUnit: Double? = temp.isNaN ? nil : temp
        for i in 1...SettingsValues.chartLastUnitsCount - 1 {
            for (_, day) in previousUnits[i].enumerated() {
                if let time = day.hours {
                    previousRealCount += 1
                    if time > 0 {
                        previousNotZeroCount += 1
                        previousSum += time
                    }
                }
            }
        }
        
        temp = SettingsValues.chartIncludeZeroDays ? previousSum / previousRealCount : previousSum / previousNotZeroCount
        let averagePreviousUnitInterval: Double? = temp.isNaN ? nil : temp
        var result = [PomodoroDayStatistics]()
        for (index, day) in pomodoroDays.enumerated() {
            let previousUnit : Double? = previousUnits[0].count > index ? previousUnits[0][index].hours : nil
            let pomodoroDayStatistics = PomodoroDayStatistics(day: day, previousUnit: previousUnit, averagePreviousUnit: averagePreviousUnit, averagePreviousInterval: averagePreviousUnitInterval)
            result.append(pomodoroDayStatistics)
        }
        return result

    }
    
    func getWeekStatistics(_ fromNow: Int) -> [PomodoroDayStatistics] {
        return getUnitStatistics(self.getWeek, fromNow: fromNow)
    }
    
    func getMonthStatistics(_ fromNow: Int) -> [PomodoroDayStatistics] {
        return getUnitStatistics(self.getMonth, fromNow: fromNow)
    }
    
    func addTime(seconds: Int, date: Date = Date()) {
        let calendar = Calendar.current
        let dateStart = calendar.startOfDay(for: date)

        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: PomodoroData.entityName)
        let predicate = NSPredicate(format: "%K == %@", "date", dateStart as CVarArg)
        fetchRequest.predicate = predicate
        
        do {
            var requestResult = (try context.fetch(fetchRequest)) as! [PomodoroData]
            var hours : Double
            
            if requestResult.count == 1 {
                requestResult[0].totalTime += Double(seconds)
                hours = requestResult[0].totalTime / 3600
            } else {
                let record = PomodoroData.insertNewObjectIntoContext(context)
                record.date = dateStart.timeIntervalSinceReferenceDate
                record.totalTime = Double(seconds)
                hours = record.totalTime / 3600
            }
            let yModelUpdate = hours >= currentHourValue
            
            try context.save()
            chartsDelegate?.chartDataDayUpdate(yModelUpdate)
        } catch let error as NSError {
            log(error)
        }
    }
    
    func removeAllRecords() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: PomodoroData.entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try coordinator.execute(deleteRequest, with: context)
            chartsDelegate?.chartDataFullUpdate()
        } catch let error as NSError {
            log(error)
        }
    }
    
    fileprivate func log(_ error: NSError) {}
}
