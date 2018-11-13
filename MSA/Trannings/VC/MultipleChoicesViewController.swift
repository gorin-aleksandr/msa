//
//  File.swift
//  MSA
//
//  Created by Pavlo Kharambura on 11/13/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import UIKit

//MARK: - Multiple Choices View Controller Data Source protocol
protocol MultipleChoicesViewControllerDataSource: AnyObject {
    func elementsForMultipleChoiceController() -> [ExerciseInTraining]?
    func allowsMultipleSelection() -> Bool
    func elementsCanBeAdded() -> Bool
    func selectedElements() -> ([ExerciseInTraining], [Int])
}

//MARK: - Multiple Choices View Controller Delegate protocol
@objc protocol MultipleChoicesViewControllerDelegate: AnyObject {
    func selectionWasDone(with result: [String])
}

extension MultipleChoicesViewControllerDelegate {
    func popMultipleChoiseViewController() {
        guard let selfClass = self as? UIViewController else {
            return
        }
        guard let nc = selfClass.navigationController else {
            return
        }
        let _ = nc.popViewController(animated: true)
    }
}

//MARK: - Multiple Choices View Controller
class MultipleChoicesViewController: UIViewController {
    //MARK:  Names constants
    private let radioTableViewCellID = "ReusableMultipleSelectionTableViewCell"
    
    //MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var okButton: UIBarButtonItem!
    @IBOutlet weak var selectAllImage: UIImageView!
    
    //MARK: Properties
    var manager = TrainingManager(type: .my)

    weak var delegate: MultipleChoicesViewControllerDelegate?
    weak var dataSource: MultipleChoicesViewControllerDataSource?
    
    var elementsForChoosing: [ExerciseInTraining] = []
    var selectedDataArray: [ExerciseInTraining] = []
    var selectedIndexes: [Int] = [] {
        didSet {
            selectedIndexes.sort { $0 < $1 }
        }
    }
    var allSelected: Bool = false
    
    //MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialConfigureViewController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideableNavigationBar(false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        hideableNavigationBar(true)
    }
    
    private func hideableNavigationBar(_ hide: Bool) {
        if #available(iOS 11.0, *) {
            navigationItem.hidesSearchBarWhenScrolling = hide
        }
    }
    
    private func initialConfigureViewController() {
        configureControllerTitle()
        getPreviousSelectedElements()
        getElementsForChoosing()
        configureTableView()
        configureNavController()
        changeImage()
    }
    
    private func getPreviousSelectedElements() {
        guard let elements = dataSource?.selectedElements()  else {return}
        self.selectedDataArray.append(contentsOf: elements.0)
        self.selectedIndexes.append(contentsOf: elements.1)
    }
    
    private func configureControllerTitle() {
        self.navigationItem.setTitle(title: "Круговая тренировка", subtitle: "выберите упражнения")
    }
    
    private func getElementsForChoosing() {
        self.elementsForChoosing = dataSource?.elementsForMultipleChoiceController() ?? []
    }
    
    private func configureTableView() {
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.tableFooterView = UIView()
        self.tableView.estimatedRowHeight = 54.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.allowsMultipleSelection = dataSource?.allowsMultipleSelection() ?? false
        self.tableView.register(UINib(nibName: radioTableViewCellID, bundle: nil), forCellReuseIdentifier: radioTableViewCellID)
    }

    private func configureNavController() {
        self.navigationController?.view.backgroundColor = .white
    }
    
    @objc private func toggleEditing() {
        self.tableView.setEditing(!self.tableView.isEditing, animated: true)
        self.tableView.reloadData()
        navigationItem.rightBarButtonItem?.title = self.tableView.isEditing ? "Save" : "Edit"
    }
    
    @IBAction func back(_ sender: Any) {
        delegate?.popMultipleChoiseViewController()

    }
    
    @IBAction func okAction(_ sender: Any) {
        if selectedIndexes.count != 1 {
            if isExercisesPaired() {
                saveAction()
            } else {
                AlertDialog.showAlert("Неверный порядок упражнений!", message: "Упражнения для круговой тренировки должны состоять из груп по минимум 2 упражнения.", viewController: self)
            }
        } else {
            AlertDialog.showAlert("Неверное число упражнений!", message: "Должно быть выбрано или 0 или больше 2-х упражнений.", viewController: self)
        }
    }
    
    private func isExercisesPaired() -> Bool{
        if selectedIndexes.count == 0 {
            return true
        } else {
            for (index, number) in selectedIndexes.enumerated() {
                switch index {
                case 0:
                    if number+1 == selectedIndexes[index+1] {
                        continue
                    } else {
                        return false
                    }
                case selectedIndexes.count - 1:
                    if number-1 == selectedIndexes[index-1] {
                        continue
                    } else {
                        return false
                    }
                default:
                    if number+1 == selectedIndexes[index+1] {
                        continue
                    } else if number-1 == selectedIndexes[index-1] {
                        continue
                    } else {
                        return false
                    }
                }
            }
            return true
        }
    }

    @objc private func saveAction() {
        if allSelected {
            delegate?.selectionWasDone(with: elementsForChoosing.map{$0.exerciseId})
        } else {
            delegate?.selectionWasDone(with: selectedDataArray.map{$0.exerciseId})
        }
        delegate?.popMultipleChoiseViewController()
    }
    
    @IBAction func chooseAllExerc(_ sender: Any) {
        allSelected = !allSelected
        changeImage()
    }
    
    func changeImage() {
        if allSelected {
            selectAllImage.image = UIImage(named: "checkbox-filled")
        } else {
            selectAllImage.image = UIImage(named: "checkbox-empty")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "startRoundTraining":
            guard let vc = segue.destination as? CircleTrainingDayViewController else {return}
            vc.manager = self.manager
        default:
            return
        }
    }
    
}

//MARK: - Table View Data Source
extension MultipleChoicesViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.elementsForChoosing.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let source = dataSource else { return UITableViewCell() }
        let cell: UITableViewCell
        
        guard let selectionCell = tableView.dequeueReusableCell(withIdentifier: radioTableViewCellID, for: indexPath) as? ReusableMultipleSelectionTableViewCell else {
            return UITableViewCell()
        }
        configureSelectionCell(selectionCell, for: tableView, at: indexPath, with: source)
        cell = selectionCell

        return cell
    }
    
    private func configureSelectionCell(_ cell: ReusableMultipleSelectionTableViewCell,for tableView: UITableView, at indexPath: IndexPath, with source: MultipleChoicesViewControllerDataSource) {
        
        cell.selectionClass = source.allowsMultipleSelection() ? .multipleSelection : .singleSelection
        var elementForCell = ExerciseInTraining()
        
        elementForCell = elementsForChoosing[indexPath.row]

        cell.nameLabel.text = elementForCell.name
        if let ex = manager.getExercise(with: elementForCell.exerciseId) {
            cell.exerciseImage.sd_setImage(with: URL(string: ex.pictures.first?.url ?? ""), placeholderImage: nil, options: .allowInvalidSSLCertificates, completed: nil)
        }
        cell.cellState = selectedDataArray.contains(elementForCell) ? .selected : .unselected
    }
    
}

//MARK: - Table View Delegate
extension MultipleChoicesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let selectedCell = tableView.cellForRow(at: indexPath) ?? UITableViewCell()
        configureSelectedCell(selectedCell, in: tableView, at: indexPath)
    }
    
    private func configureSelectedCell(_ cell: UITableViewCell, in tableView: UITableView, at indexPath: IndexPath) {
        guard let selectedCell = cell as? ReusableMultipleSelectionTableViewCell else { return }
        var selectedItem = ExerciseInTraining()
        
        selectedItem = elementsForChoosing[indexPath.row]
        
        switch selectedCell.cellState {
        case .unselected:
            selectedDataArray.append(selectedItem)
            selectedIndexes.append(indexPath.row)
        case .selected:
            selectedDataArray.remove(selectedItem)
            selectedIndexes.remove(indexPath.row)
        }
        selectedCell.cellState.toggle()
    }
    
}
