//
//  TransferMasterView.swift
//  TUIRoomKit
//
//  Created by janejntang on 2023/2/20.
//

import Foundation

class TransferMasterView: UIView {
    let viewModel: TransferMasterViewModel
    var attendeeList: [UserEntity]
    var searchArray: [UserEntity] = []
    private var isSearching: Bool = false
    
    let topLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(0xD5E0F2)
        label.font = UIFont(name: "PingFangSC-Regular", size: 16)
        label.text = .transferMasterText
        return label
    }()
    
    let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = .searchMemberText
        searchBar.setBackgroundImage(UIColor(0x1B1E26).trans2Image(), for: .top, barMetrics: .default)
        if #available(iOS 13, *) {
            searchBar.searchTextField.textColor = UIColor(0xB2BBD1)
            searchBar.searchTextField.tintColor = UIColor(0xB2BBD1).withAlphaComponent(0.3)
            searchBar.searchTextField.layer.cornerRadius = 6
            searchBar.searchTextField.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        } else {
            if let textField = searchBar.value(forKey: "searchField") as? UITextField {
                textField.textColor = UIColor(0xB2BBD1)
                textField.tintColor = UIColor(0xB2BBD1).withAlphaComponent(0.3)
                textField.layer.cornerRadius = 6
                textField.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            }
        }
        return searchBar
    }()
    
    let searchControl: UIControl = {
        let view = UIControl()
        view.backgroundColor = .clear
        view.isHidden = true
        return view
    }()
    
    let appointMasterButton: UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitle(.appointAndLeaveRoomText, for: .normal)
        button.setTitleColor(UIColor(0xFFFFFF), for: .normal)
        button.setBackgroundImage(UIColor(0x006EFF).withAlphaComponent(0.2).trans2Image(), for: .disabled)
        button.setBackgroundImage(UIColor(0x006EFF).trans2Image(), for: .normal)
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.adjustsImageWhenHighlighted = false
        return button
    }()
    
    lazy var transferMasterTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor(0x1B1E26)
        tableView.register(TransferMasterTableCell.self, forCellReuseIdentifier: "RaiseHandCell")
        return tableView
    }()
    
    init(viewModel: TransferMasterViewModel) {
        self.viewModel = viewModel
        self.attendeeList = viewModel.attendeeList
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var isViewReady: Bool = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        backgroundColor = UIColor(0x1B1E26)
        guard !isViewReady else { return }
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
        isViewReady = true
    }
    
    func constructViewHierarchy() {
        addSubview(topLabel)
        addSubview(searchBar)
        addSubview(transferMasterTableView)
        addSubview(appointMasterButton)
        addSubview(searchControl)
    }
    
    func activateConstraints() {
        topLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10.scale375Height())
            make.leading.equalToSuperview().offset(16.scale375())
            make.trailing.equalToSuperview().offset(-16.scale375())
            make.height.equalTo(24.scale375Height())
        }
        searchBar.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16.scale375())
            make.trailing.equalToSuperview().offset(-16.scale375())
            make.height.equalTo(34.scale375Height())
            make.top.equalTo(topLabel.snp.bottom).offset(23.scale375Height())
        }
        transferMasterTableView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16.scale375())
            make.trailing.equalToSuperview().offset(-16.scale375())
            make.top.equalTo(searchBar.snp.bottom).offset(10.scale375Height())
            make.bottom.equalToSuperview()
        }
        appointMasterButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-40 - kDeviceSafeBottomHeight)
            make.height.equalTo(50)
            make.leading.equalToSuperview().offset(20)
        }
        searchControl.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func bindInteraction() {
        searchBar.delegate = self
        viewModel.viewResponder = self
        appointMasterButton.addTarget(self, action: #selector(appointMasterAction(sender:)), for: .touchUpInside)
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideSearchControl(sender:)))
        searchControl.addGestureRecognizer(tap)
        appointMasterButton.isEnabled = viewModel.userId.count > 0
    }
    
    @objc func appointMasterAction(sender: UIButton) {
        viewModel.appointMasterAction(sender: sender)
    }
    
    @objc func hideSearchControl(sender: UIView) {
        if #available(iOS 13, *) {
            searchBar.searchTextField.resignFirstResponder()
        } else {
            searchBar.resignFirstResponder()
        }
        searchControl.isHidden = true
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}

extension TransferMasterView: UISearchBarDelegate {
    func searchBar(_ searchBar:UISearchBar,textDidChange searchText:String){
        let searchContentText = searchText.trimmingCharacters(in: .whitespaces)
        if searchContentText.count == 0 {
            attendeeList = viewModel.attendeeList
            transferMasterTableView.reloadData()
            isSearching = false
        } else {
            searchArray = viewModel.attendeeList.filter({ model -> Bool in
                return model.userName.contains(searchContentText)
            })
            attendeeList = searchArray
            transferMasterTableView.reloadData()
            isSearching = true
        }
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchControl.isHidden = false
        return true
    }
}

extension TransferMasterView: UITableViewDataSource {
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return attendeeList.count
    }
}

extension TransferMasterView: UITableViewDelegate {
    internal func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let attendeeModel = attendeeList[indexPath.row]
        let cell = TransferMasterTableCell(attendeeModel: attendeeModel, viewModel: viewModel)
        cell.selectionStyle = .none
        return cell
    }
    
    internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchBar.endEditing(true)
        if #available(iOS 13, *) {
            searchBar.searchTextField.resignFirstResponder()
        } else {
            searchBar.resignFirstResponder()
        }
        viewModel.userId = attendeeList[indexPath.row].userId
        appointMasterButton.isEnabled = true
        transferMasterTableView.reloadData()
    }
    internal func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.scale375Height()
    }
}

extension TransferMasterView: TransferMasterViewResponder {
    func makeToast(message: String) {
        makeToast(message)
    }
    
    func reloadTransferMasterTableView() {
        guard !isSearching else { return }
        attendeeList = viewModel.attendeeList
        transferMasterTableView.reloadData()
    }
    
    func searchControllerChangeActive(isActive: Bool) {
        searchBar.endEditing(!isActive)
        if #available(iOS 13, *) {
            searchBar.searchTextField.resignFirstResponder()
        } else {
            searchBar.resignFirstResponder()
        }
    }
}

class TransferMasterTableCell: UITableViewCell {
    let attendeeModel: UserEntity
    let viewModel: TransferMasterViewModel
    
    let avatarImageView: UIImageView = {
        let img = UIImageView()
        img.layer.cornerRadius = 20
        img.layer.masksToBounds = true
        return img
    }()
    
    let userLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(0xD5E0F2)
        label.backgroundColor = UIColor.clear
        label.textAlignment = isRTL ? .right : .left
        label.textAlignment = .left
        label.font = UIFont(name: "PingFangSC-Regular", size: 16)
        label.numberOfLines = 1
        return label
    }()
    
    let checkMarkButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "room_check_mark", in: tuiRoomKitBundle(), compatibleWith: nil), for: .normal)
        button.isHidden = true
        return button
    }()
    
    let downLineView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(0x2A2D38)
        return view
    }()
    
    init(attendeeModel: UserEntity ,viewModel: TransferMasterViewModel) {
        self.attendeeModel = attendeeModel
        self.viewModel = viewModel
        super.init(style: .default, reuseIdentifier: "TransferMasterTableCell")
    }
    
    private var isViewReady: Bool = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else { return }
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
        isViewReady = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func constructViewHierarchy() {
        contentView.addSubview(avatarImageView)
        contentView.addSubview(userLabel)
        contentView.addSubview(checkMarkButton)
        contentView.addSubview(downLineView)
    }
    
    func activateConstraints() {
        avatarImageView.snp.makeConstraints { make in
            make.width.height.equalTo(40.scale375Height())
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        checkMarkButton.snp.makeConstraints { make in
            make.width.height.equalTo(22.scale375())
            make.trailing.equalToSuperview()
            make.centerY.equalTo(self.avatarImageView)
        }
        userLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(avatarImageView.snp.trailing).offset(10.scale375())
            make.width.equalTo(150.scale375())
            make.height.equalTo(22.scale375Height())
        }
        downLineView.snp.makeConstraints { make in
            make.leading.equalTo(userLabel)
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(1.scale375Height())
        }
    }
    
    func bindInteraction() {
        backgroundColor = UIColor(0x1B1E26)
        setupViewState(item: attendeeModel)
    }
    
    func setupViewState(item: UserEntity) {
        let placeholder = UIImage(named: "room_default_user", in: tuiRoomKitBundle(), compatibleWith: nil)
        if let url = URL(string: item.avatarUrl) {
            avatarImageView.sd_setImage(with: url, placeholderImage: placeholder)
        } else {
            avatarImageView.image = placeholder
        }
        userLabel.text = item.userName
        if viewModel.userId == attendeeModel.userId {
            checkMarkButton.isHidden = false
        }
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}

private extension String {
    static var transferMasterText: String {
        localized("Appoint a new master")
    }
    static var searchMemberText: String {
        localized("Search for participants")
    }
    static var appointAndLeaveRoomText: String {
        localized("Appoint and leave")
    }
}
