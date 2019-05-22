//
//  ConversationScreen.swift
//  Roma Chat
//
//  Created by Drasko Vucenovic on 2019-04-04.
//  Copyright © 2019 Barrett Breshears. All rights reserved.
//

import UIKit

class ConversationScreen: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var conversationCollectionView: UICollectionView!
    @IBOutlet weak var fakeKeyboardHeightCnst: NSLayoutConstraint!
    
    @IBOutlet weak var messagingContainerView: UIView!
    
    @IBOutlet weak var messagingTextView: UITextField!
    
    private let reuseIdentifier = "ConversationCell"
    
    /// An empty view used as a 'UIResponder.inputAccessoryView'. When the scrollview
    /// 'keyboardDismissMode' is '.interactive', the keyboard doesn't post frame change
    /// notifications to allow us to move the text view as the keyboard interactively is dimsssed.
    /// This view has a zero height and sits above the keyboard as it apepars. We can then use
    /// this view to adjust the collectionView's constraints to move it alongside the keyboard.
    let accessoryView = UIView(frame: .zero)
    
    override var inputAccessoryView: UIView? {
        return messagingContainerView
    }

    var avatar : UIImage?
    
    // Our custom view from the XIB file
    var view: UIView!
    
    var conversation: RomaConversation?
    
    var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        let width = UIScreen.main.bounds.size.width
        layout.estimatedItemSize = CGSize(width: width, height: 10)
        layout.sectionFootersPinToVisibleBounds = true
        return layout
    }()
    
    override init(frame: CGRect) {
        // 1. setup any properties here
        
        // 2. call super.init(frame:)
        super.init(frame: frame)
        
        // 3. Setup view from .xib file
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        // 1. setup any properties here
        
        // 2. call super.init(coder:)
        super.init(coder: aDecoder)
        
        // 3. Setup view from .xib file
        xibSetup()
    }
    
    func xibSetup() {
        view = loadViewFromNib()
        
        // use bounds not frame or it'll be offset
        view.frame = bounds
        
        // Make the view stretch with containing view
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        
        let nib = UINib.init(nibName: String(describing: ConversationScreen.self), bundle: nil)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        
        return view
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        instances = InstanceData.getAllInstances()
//        accounts = Account.getAccounts()
//        //TODO: use current instance to determine corresponding account
//        let account = accounts[0]
//        lblAccountName.text = account.username

        conversationCollectionView.dataSource = self
        conversationCollectionView.delegate = self
        conversationCollectionView.collectionViewLayout = layout
        conversationCollectionView.alwaysBounceVertical = true
        conversationCollectionView.contentInsetAdjustmentBehavior = .always
        conversationCollectionView.register(UINib(nibName: "ConversationCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        conversationCollectionView.keyboardDismissMode = .interactive
        
        messagingContainerView.translatesAutoresizingMaskIntoConstraints = false
        messagingTextView.translatesAutoresizingMaskIntoConstraints = false
        messagingContainerView.autoresizingMask = .flexibleHeight
        inputAccessoryView?.autoresizingMask = .flexibleHeight
        

        conversationCollectionView.register(UINib(nibName: "ConversationScreenFooter", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "ConversationScreenFooter")
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillChangeFrame(notification: NSNotification) {
        print("keyboard heightc changed)")

        if let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardFrame.size.height
            print("keyboard height: \(keyboardHeight)")
//            self.fakeKeyboardHeightCnst.constant = keyboardHeight
//            self.view.layoutIfNeeded()
            //do the chnages according ot this height
        }
    }
//    @objc func keyboardWillHide(notification: NSNotification) {
//        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
//            if self.view.frame.origin.y != 0 {
//                self.view.frame.origin.y += keyboardSize.height
//            }
//        }
//    }
    
    func refreshData() {
        guard let conversation = conversation else { return }
        
        for message in conversation.messages {
            if let status = message {
                print("Meessage: \(String(describing: status.content))")
            }
        }
        
        conversationCollectionView.reloadData()
        let lastMessageIndex = conversation.messages.count - 1
        conversationCollectionView.scrollToItem(at: IndexPath(row: lastMessageIndex, section: 0), at: UICollectionView.ScrollPosition.bottom, animated: true)
    }
    
    
    //MARK: - UITableViewDelegate & UITableViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
//
//    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//
//        if kind == UICollectionView.elementKindSectionFooter {
//            if let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter,
//                                                                                withReuseIdentifier:"ConversationScreenFooter", for: indexPath) as? ConversationScreenFooter {
//                return headerView
//            }
//        }
//
//        return UICollectionReusableView()
//    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let conversation = conversation {
            return conversation.messages.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? ConversationCell {
            if let conversation = conversation {
                if let status = conversation.messages[indexPath.row] {
                    let username = status.account.username
                    let message = status.content.stripHTML()
                    cell.lblUsername?.text = username
                    cell.lblMessage?.text = message
                }
            }
            return cell
        }
        return UICollectionViewCell()
    }
    
    //MARK: - Collection View Layout
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let availableWidth = view.frame.width
//
//        return CGSize(width: availableWidth, height: 200)
//    }
//
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        layout.estimatedItemSize = CGSize(width: view.bounds.size.width, height: 10)
        super.traitCollectionDidChange(previousTraitCollection)
    }
    
//    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        layout.estimatedItemSize = CGSize(width: view.bounds.size.width, height: 10)
//        layout.invalidateLayout()
//        super.viewWillTransition(to: size, with: coordinator)
//    }
    
    
    
    
    
    
}
