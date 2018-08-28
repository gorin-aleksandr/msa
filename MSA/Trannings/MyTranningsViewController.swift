//
//  MyTranningsViewController.swift
//  MSA
//
//  Created by Pavlo Kharambura on 6/10/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import UIKit

class MyTranningsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initialViewConfiguration()
    }

    func initialViewConfiguration() {
        segmentControl.layer.masksToBounds = true
        segmentControl.layer.cornerRadius = 13
        segmentControl.layer.borderColor = lightBlue.cgColor
        segmentControl.layer.borderWidth = 1
        navigationController?.navigationBar.layer.backgroundColor = UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1).cgColor
        navigationController?.setNavigationBarHidden(false, animated: true)
        let attrs = [NSAttributedStringKey.foregroundColor: UIColor.black,
                     NSAttributedStringKey.font: UIFont(name: "Rubik-Medium", size: 17)!]
        self.navigationController?.navigationBar.titleTextAttributes = attrs
        segmentControl.setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "Rubik-Medium", size: 13)!],
                                                for: .normal)
        configureTableView()
        
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
    }
    
    @IBAction func back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func calendarButtonAction(_ sender: Any) {
    }
    @IBAction func addButtonAction(_ sender: Any) {
    }
    @IBAction func optionsButton(_ sender: Any) {
        showOptionsAlert()
    }
    
    func showOptionsAlert() {
        let alert = UIAlertController(title: "Редактирование тренировки", message: "", preferredStyle: UIAlertControllerStyle.alert)
        
        let myString  = "Редактирование тренировки"
        var myMutableString = NSMutableAttributedString()
        myMutableString = NSMutableAttributedString(string: myString as String, attributes: [NSAttributedStringKey.font: UIFont(name: "Rubik-Medium", size: 17)!])
        myMutableString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.black, range: NSRange(location:0,length:myString.count))
        alert.setValue(myMutableString, forKey: "attributedTitle")
        
        let save = UIAlertAction(title: "Сохранить как шаблон", style: .default, handler: { action in
            self.segmentControl.layer.borderColor = lightBlue.cgColor
        })
        let delete = UIAlertAction(title: "Удалить тренировку", style: .default, handler: { action in
            self.segmentControl.layer.borderColor = lightBlue.cgColor
        })
        let cancel = UIAlertAction(title: "Отмена", style: .default, handler: { action in
            self.segmentControl.layer.borderColor = lightBlue.cgColor
        })
        
        alert.addAction(save)
        alert.addAction(delete)
        alert.addAction(cancel)
        segmentControl.layer.borderColor = UIColor.lightGray.cgColor
        self.present(alert, animated: true, completion: nil)
        setFont(action: save, text: "Сохранить как шаблон", regular: true)
        setFont(action: delete, text: "Удалить тренировку", regular: true)
        setFont(action: cancel, text: "Отмена", regular: false)

    }

    private func setFont(action: UIAlertAction,text: String, regular: Bool) {
        var fontName = "Rubik"
        if !regular {
            fontName = "Rubik-Medium"
        }
        let attributedText = NSMutableAttributedString(string: text)
        let range = NSRange(location: 0, length: attributedText.length)
        attributedText.addAttribute(kCTFontAttributeName as NSAttributedStringKey, value: UIFont(name: fontName, size: 17.0)!, range: range)
        guard let label = (action.value(forKey: "__representer") as AnyObject).value(forKey: "label") as? UILabel else { return }
        label.attributedText = attributedText
    }
    
}

extension MyTranningsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
}
