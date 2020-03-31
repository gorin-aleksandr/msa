//
//  Helpers.swift
//  MSA
//
//  Created by Nik on 28.03.2020.
//  Copyright © 2020 Pavlo Kharambura. All rights reserved.
//

import UIKit

let chatStoryboard = UIStoryboard(name: "Chat", bundle: nil)

func nowDateString() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let myString = formatter.string(from: Date())
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
