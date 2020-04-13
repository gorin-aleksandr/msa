
class CopyTrainingsManager {

    static var shared: CopyTrainingsManager = {
        let instance = CopyTrainingsManager()
        return instance
    }()

  var copiedWeek: TrainingWeek?
  var copiedDay: TrainingDay?
  
  private init() {}
  
  func printObjects() {
    print("Week is: \(copiedWeek)")
  }
}
