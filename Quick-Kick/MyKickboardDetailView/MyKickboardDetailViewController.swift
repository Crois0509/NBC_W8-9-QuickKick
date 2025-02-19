//
//  MyKickboardDetailViewController.swift
//  Quick-Kick
//
//  Created by 장상경 on 12/18/24.
//

import UIKit
import SnapKit
import CoreData

enum ViewMode {
    case normal
    case edit
}

final class MyKickboardDetailViewController: UIViewController, ModalViewDelegate {
    
    private let coreDataManager = CoreDataManager.shared
    
    private let kickboardDetailView = MyKickboardDetailView()
    
    private var mode: ViewMode = .normal
    
    private var selectedItmeCount: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewConfiguration()
        setupDetailView()
        setupEditButton()
        kickboardDetailView.delegate = self
    }
    
    private func setupViewConfiguration() {
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.backgroundColor = .white
        view.backgroundColor = .white
        
        let naviTitle = UILabel()
        naviTitle.text = self.mode == .normal ? "내 킥보드 관리" : "삭제할 킥보드 선택"
        naviTitle.textColor = .black
        naviTitle.font = UIFont.systemFont(ofSize: 25, weight: .bold)
        self.navigationItem.titleView = naviTitle
        self.navigationController?.navigationBar.tintColor = .PersonalNomal.nomal
    }
    
    private func setupEditButton() {
        let editTitle = self.selectedItmeCount > 0 ? "\(self.selectedItmeCount)개 지우기" : "취소"
        let buttonTitle = self.mode == .normal ? "편집" : editTitle
        let rightButton = UIBarButtonItem(title: buttonTitle, style: .plain, target: self, action: #selector(onEditMode))
        self.navigationItem.rightBarButtonItem = rightButton
    }
    
    private func confirmDeleteDataAlert(on viewController: UIViewController, completion: @escaping () -> Void) {
        let alert = UIAlertController(title: "경고", message: "정말 삭제 하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "삭제", style: .destructive) { _ in
            completion()
        })
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        viewController.present(alert, animated: true)
    }
    
    @objc private func onEditMode() {
        switch self.mode {
        case .normal:
            self.kickboardDetailView.mode = .edit
            self.mode = .edit
            setupEditButton()
            setupViewConfiguration()
            self.kickboardDetailView.reloadCellData()
        case .edit:
            if self.selectedItmeCount > 0 {
                confirmDeleteDataAlert(on: self) { [weak self] in
                    guard let self else { return }
                    self.kickboardDetailView.deledteCell()
                    self.kickboardDetailView.reloadCellData()
                    self.mode = .normal
                    self.setupEditButton()
                    self.setupViewConfiguration()
                }
            } else {
                self.mode = .normal
                setupEditButton()
                setupViewConfiguration()
            }
        }

    }
    
    private func setupDetailView() {
        self.kickboardDetailView.modalViewDelegate = self
        view.addSubview(self.kickboardDetailView)
        
        self.kickboardDetailView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func editKickboardModalView(_ isSaddled: Bool, _ nickName: String, _ id: NSManagedObjectID) {
        let modalVC = RegistrationModalViewController()
        modalVC.editKickboardData(isSaddled, nickName, id)
        
        modalVC.modalPresentationStyle = .formSheet
        modalVC.sheetPresentationController?.preferredCornerRadius = 50
        modalVC.sheetPresentationController?.detents = [.medium()]
        
        modalVC.disappear = { [weak self] in
            guard let self else { return }
            
            self.kickboardDetailView.reloadCellData()
            
        }
        
        self.present(modalVC, animated: true)
    }
    
}

extension MyKickboardDetailViewController: MyKickboardDetailViewDelegate {
    func getSelectItemCount(_ items: Int) {
        self.selectedItmeCount = items
        self.setupEditButton()
    }
    
    func deleteKickboard(_ items: [Kickboard]) {
        items.forEach {
            coreDataManager.delete($0)
        }
    }
    
    func getKickboardsCount() -> Int {
        coreDataManager.fetchMyKickboards().count
    }
    
    func getKickboards() -> [Kickboard] {
        coreDataManager.fetchMyKickboards()
    }
}
