//
//  Helpers.swift
//  MSA
//
//  Created by Nik on 28.03.2020.
//  Copyright © 2020 Pavlo Kharambura. All rights reserved.
//

import UIKit
import CryptoKit
import CommonCrypto
import Charts
import EmptyStateKit
import Firebase
import Amplitude

let chatStoryboard = UIStoryboard(name: "Chat", bundle: nil)
let signInStoryboard = UIStoryboard(name: "SignIn", bundle:nil)
let profileStoryboard = UIStoryboard(name: "Profile", bundle:nil)
let newProfileStoryboard = UIStoryboard(name: "New Profile", bundle:nil)
let measurementsStoryboard = UIStoryboard(name: "Measurements", bundle:nil)
let trainingStoryboard = UIStoryboard(name: "Trannings", bundle:nil)
let communityStoryboard = UIStoryboard(name: "Community", bundle:nil)

let iPhoneXHeight: CGFloat = 812.0
let iPhoneXWidth: CGFloat = 375.0
let screenSize: CGRect = UIScreen.main.bounds


func randomString(length: Int) -> String {
  let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
  return String((0..<length).map{ _ in letters.randomElement()! })
}

func nowDateString() -> String {
  let formatter = DateFormatter()
  formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
  let myString = formatter.string(from: Date())
  return myString
}

func nowDateStringForCalendar(date: Date) -> String {
  let formatter = DateFormatter()
  formatter.dateFormat = "dd.MM.yyyy"
  let myString = formatter.string(from: date)
  return myString
}

func convertDateToString(date: Date) -> String{
  
  let formatter = DateFormatter()
  formatter.dateFormat = "dd/MM/yy HH:mm"
  let myString = formatter.string(from: date) // string purpose I add here
  return myString
}

extension String
{
  func toDateTime() -> Date?
  {
    //Create Date Formatter
    let dateFormatter = DateFormatter()
    
    //Specify Format of String to Parse
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    
    //Parse into NSDate
    if let dateFromString = dateFormatter.date(from: self) {
      //Return Parsed Date
      return dateFromString
    } else {
      return nil
    }
    
  }
  
}

extension UIView {
  func roundCorners(corners:UIRectCorner, radius: CGFloat) {
    let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
    let mask = CAShapeLayer()
    let rect = self.bounds
    mask.frame = rect
    mask.path = path.cgPath
    self.layer.mask = mask
  }
}

class DataDetector {
  
  private class func _find(all type: NSTextCheckingResult.CheckingType,
                           in string: String, iterationClosure: (String) -> Bool) {
    guard let detector = try? NSDataDetector(types: type.rawValue) else { return }
    let range = NSRange(string.startIndex ..< string.endIndex, in: string)
    let matches = detector.matches(in: string, options: [], range: range)
    loop: for match in matches {
      for i in 0 ..< match.numberOfRanges {
        let nsrange = match.range(at: i)
        let startIndex = string.index(string.startIndex, offsetBy: nsrange.lowerBound)
        let endIndex = string.index(string.startIndex, offsetBy: nsrange.upperBound)
        let range = startIndex..<endIndex
        guard iterationClosure(String(string[range])) else { break loop }
      }
    }
  }
  
  class func find(all type: NSTextCheckingResult.CheckingType, in string: String) -> [String] {
    var results = [String]()
    _find(all: type, in: string) {
      results.append($0)
      return true
    }
    return results
  }
  
  class func first(type: NSTextCheckingResult.CheckingType, in string: String) -> String? {
    var result: String?
    _find(all: type, in: string) {
      result = $0
      return false
    }
    return result
  }
}

// MARK: String extension

extension String {
  var detectedLinks: [String] { DataDetector.find(all: .link, in: self) }
  var detectedFirstLink: String? { DataDetector.first(type: .link, in: self) }
  var detectedURLs: [URL] { detectedLinks.compactMap { URL(string: $0) } }
  var detectedFirstURL: URL? {
    guard let urlString = detectedFirstLink else { return nil }
    return URL(string: urlString)
  }
  var youtubeID: String? {
    let pattern = "((?<=(v|V)/)|(?<=be/)|(?<=(\\?|\\&)v=)|(?<=embed/))([\\w-]++)"
    
    let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
    let range = NSRange(location: 0, length: count)
    
    guard let result = regex?.firstMatch(in: self, range: range) else {
      return nil
    }
    
    return (self as NSString).substring(with: result.range)
  }
  
  func take(_ n: Int) -> String {
    guard n >= 0 else {
      fatalError("n should never negative")
    }
    let index = self.index(self.startIndex, offsetBy: min(n, self.count))
    return String(self[..<index])
  }
  
}

func randomNonceString(length: Int = 32) -> String {
  precondition(length > 0)
  let charset: Array<Character> =
    Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
  var result = ""
  var remainingLength = length
  
  while remainingLength > 0 {
    let randoms: [UInt8] = (0 ..< 16).map { _ in
      var random: UInt8 = 0
      let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
      if errorCode != errSecSuccess {
        fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
      }
      return random
    }
    
    randoms.forEach { random in
      if remainingLength == 0 {
        return
      }
      
      if random < charset.count {
        result.append(charset[Int(random)])
        remainingLength -= 1
      }
    }
  }
  
  return result
}


extension String {
  
  func sha256() -> String{
    if let stringData = self.data(using: String.Encoding.utf8) {
      return hexStringFromData(input: digest(input: stringData as NSData))
    }
    return ""
  }
  
  private func digest(input : NSData) -> NSData {
    let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
    var hash = [UInt8](repeating: 0, count: digestLength)
    CC_SHA256(input.bytes, UInt32(input.length), &hash)
    return NSData(bytes: hash, length: digestLength)
  }
  
  private  func hexStringFromData(input: NSData) -> String {
    var bytes = [UInt8](repeating: 0, count: input.length)
    input.getBytes(&bytes, length: input.length)
    var hexString = ""
    for byte in bytes {
      hexString += String(format:"%02x", UInt8(byte))
    }
    return hexString
  }
}

struct ResponseData: Decodable {
  var city: [City]
}
struct City : Decodable {
  var name: String
}

func loadJson(filename fileName: String) -> [City]? {
  if let url = Bundle.main.url(forResource:fileName, withExtension: "json") {
    do {
      let data = try Data(contentsOf: url)
      let decoder = JSONDecoder()
      let jsonData = try decoder.decode(ResponseData.self, from: data)
      return jsonData.city
    } catch {
      print("error:\(error)")
    }
  }
  return nil
}

extension UITextField {
  func setBottomBorder() {
    self.borderStyle = .none
    self.layer.backgroundColor = UIColor.clear.cgColor
    self.layer.masksToBounds = false
    self.layer.shadowColor = UIColor.red.cgColor
    self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
    self.layer.shadowOpacity = 1.0
    self.layer.shadowRadius = 0.0
  }
}

extension UITextField
{
  func setBottomBorder(withColor color: UIColor, widthLine: CGFloat)
  {
    self.borderStyle = UITextField.BorderStyle.none
    self.backgroundColor = UIColor.clear
    let width: CGFloat = 1.0
    
    let borderLine = UIView(frame: CGRect(x: 0, y: self.frame.height - width, width: widthLine, height: width))
    borderLine.backgroundColor = color
    self.addSubview(borderLine)
  }
}

class CustomTitleView: UIView
{
  
  var title_label = UILabel()
  var left_imageView = UIImageView()
  
  override init(frame: CGRect){
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder){
    super.init(coder: aDecoder)
    setup()
  }
  
  func setup(){
    self.addSubview(title_label)
    self.addSubview(left_imageView)
    
  }
  
  func loadWith(title: String, leftImage: UIImage?)
  {
    
    //self.backgroundColor = .yellow
    
    // =================== title_label ==================
    //title_label.backgroundColor = .blue
    title_label.text = title
    title_label.font = UIFont.systemFont(ofSize: 14)
    
    
    // =================== imageView ===================
    left_imageView.image = leftImage
    
    setupFrames()
  }
  
  func setupFrames()
  {
    
    let height: CGFloat = 44
    let image_size: CGFloat = height * 0.8
    
    left_imageView.frame = CGRect(x: 0,
                                  y: (height - image_size) / 2,
                                  width: (left_imageView.image == nil) ? 0 : image_size,
                                  height: image_size)
    
    let titleWidth: CGFloat = title_label.intrinsicContentSize.width + 10
    title_label.frame = CGRect(x: left_imageView.frame.maxX + 5,
                               y: 0,
                               width: titleWidth,
                               height: height)
    
    
    
    contentWidth = Int(left_imageView.frame.width)
    self.frame = CGRect(x: 0, y: 0, width: CGFloat(contentWidth), height: height)
  }
  
  
  var contentWidth: Int = 0 //if its CGFloat, it infinitely calls layoutSubviews(), changing franction of a width
  override func layoutSubviews() {
    super.layoutSubviews()
    self.frame.size.width = CGFloat(contentWidth)
  }
  
}

extension UITextField {
  
  enum Direction {
    case Left
    case Right
  }
  
  // add image to textfield
  func withImage(direction: Direction, image: UIImage, colorSeparator: UIColor, colorBorder: UIColor){
    let mainView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 45))
    mainView.layer.cornerRadius = 5
    
    let view = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 45))
    view.backgroundColor = .clear
    view.clipsToBounds = true
    view.layer.cornerRadius = 5
    view.layer.borderWidth = CGFloat(0.5)
    view.layer.borderColor = colorBorder.cgColor
    mainView.addSubview(view)
    
    let imageView = UIImageView(image: image)
    imageView.contentMode = .scaleAspectFit
    imageView.frame = CGRect(x: 12.0, y: 10.0, width: 24.0, height: 24.0)
    view.addSubview(imageView)
    
    let seperatorView = UIView()
    seperatorView.backgroundColor = colorSeparator
    //mainView.addSubview(seperatorView)
    
    if(Direction.Left == direction){ // image left
      // seperatorView.frame = CGRect(x: 45, y: 0, width: 5, height: 45)
      self.leftViewMode = .always
      self.leftView = mainView
    } else { // image right
      //seperatorView.frame = CGRect(x: 0, y: 0, width: 5, height: 45)
      self.rightViewMode = .always
      self.rightView = mainView
    }
    
    self.layer.borderColor = colorBorder.cgColor
    self.layer.borderWidth = CGFloat(0.5)
    self.layer.cornerRadius = 5
  }
}

@objc(BarChartFormatter)
public class BarChartFormatter: NSObject, IAxisValueFormatter{
  var currentWeek: [Date]
  public init(datesRange: [Date]) {
    currentWeek = datesRange
  }
  
  public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
    if currentWeek.count == 7 {
      return "\(currentWeek[Int(value)].day) \(dayOfWeek(index: Int(value)))"
    } else {
      return "\(currentWeek[Int(value)].day)/\(currentWeek[Int(value)].month)"
    }
  }
}

func dayOfWeek(index: Int) -> String {
  switch index {
    case 0:
      return "Пн"
    case 1:
      return "Вт"
    case 2:
      return "Ср"
    case 3:
      return "Чт"
    case 4:
      return "Пт"
    case 5:
      return "Сб"
    case 6:
      return "Вс"
    default:
      return "Пн"
  }
}

extension Double {
  func roundTo(places: Int) -> Double {
    let divisor = pow(10.0, Double(places))
    return (self * divisor).rounded() / divisor
  }
}

struct Env {
  
  private static let production : Bool = {
    #if DEBUG
    print("DEBUG")
    let dic = ProcessInfo.processInfo.environment
    if let forceProduction = dic["forceProduction"] , forceProduction == "true" {
      return true
    }
    return false
    #elseif ADHOC
    print("ADHOC")
    return false
    #else
    print("PRODUCTION")
    return true
    #endif
  }()
  
  static func isProduction () -> Bool {
    return self.production
  }
  
}

enum MainState: CustomState {
  case emptyGalleryForUser
  case emptyGalleryForMe
  case noInfoForCoachUser
  case noSporstmansForCoach
  case noSporstmansForMe
  case noChats
  case noMessages
  case noCars
  
  var image: UIImage? {
    switch self {
      case .emptyGalleryForUser: return UIImage(named: "emptyGallery")
      case .emptyGalleryForMe: return UIImage(named: "emptyGallery")
      case .noInfoForCoachUser: return UIImage(named: "noUserInfo")
      case .noSporstmansForCoach: return UIImage(named: "emptySpotsmans")
      case .noSporstmansForMe: return UIImage(named: "emptySpotsmans")
      case .noChats: return UIImage(named: "noChatsForUser")
      case .noMessages: return UIImage(named: "noMesages")
      case .noCars: return UIImage(named: "noCars")
    }
  }
  
  var title: String? {
    switch self {
      case .emptyGalleryForUser: return ""
      case .emptyGalleryForMe: return ""
      case .noInfoForCoachUser: return ""
      case .noSporstmansForCoach: return ""
      case .noSporstmansForMe: return ""
      case .noChats: return ""
      case .noMessages: return ""
      case .noCars: return "Автомобилей еще нет"
    }
  }
  
  var description: String? {
    switch self {
      case .emptyGalleryForUser: return "У этого пользователя пока нет фото."
      case .emptyGalleryForMe: return "У этого пользователя пока нет фото."
      case .noInfoForCoachUser: return "Пользователь еще не заполнил информацию о себе "
      case .noSporstmansForCoach: return "У этого тренера пока нет спортсменов."
      case .noSporstmansForMe: return "У тебя пока нет спортсменов. Найди спортсменов в сообществе, или пригласи их в приложение."
      case .noChats: return "У тебя еще нет активных переписок.\nПерейди в сообщество,\nчтобы найти новые знакомства."
      case .noMessages: return "Нет сообщений"
      case .noCars: return "Добавьте свой автомобиль для того, чтобы создать заявку"
    }
  }
  
  var titleButton: String? {
    switch self {
      case .emptyGalleryForUser: return nil
      case .emptyGalleryForMe: return nil
      case .noInfoForCoachUser: return nil
      case .noSporstmansForCoach: return nil
      case .noSporstmansForMe: return nil
      case .noChats: return nil
      case .noMessages: return nil
      case .noCars: return "Добавить авто"
    }
  }
}

struct AnalyticsSender {
    static let shared = AnalyticsSender()
    private init() { }
   
  func logEvent(eventName: String, params: [String: Any]? = nil) {
    Analytics.logEvent(eventName, parameters: params)
    Amplitude.instance()?.logEvent(eventName)
    }
}
