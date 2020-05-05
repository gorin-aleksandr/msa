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

let chatStoryboard = UIStoryboard(name: "Chat", bundle: nil)

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
