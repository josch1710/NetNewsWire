//
//  MasterTableViewCell.swift
//  NetNewsWire
//
//  Created by Brent Simmons on 8/1/15.
//  Copyright © 2015 Ranchero Software, LLC. All rights reserved.
//

import UIKit
import RSCore
import Account
import RSTree

protocol MasterTableViewCellDelegate: class {
	func disclosureSelected(_ sender: MasterTableViewCell, expanding: Bool)
}

class MasterTableViewCell : UITableViewCell {

	weak var delegate: MasterTableViewCellDelegate?
	var allowDisclosureSelection = false

	override var accessibilityLabel: String? {
		set {}
		get {
			if unreadCount > 0 {
				let unreadLabel = NSLocalizedString("unread", comment: "Unread label for accessiblity")
				return "\(name) \(unreadCount) \(unreadLabel)"
			} else {
				return name
			}
		}
	}

	var indent = false {
		didSet {
			if indent != oldValue {
				setNeedsLayout()
			}
		}
	}
	
	var disclosureExpanded = false {
		didSet {
			updateDisclosureImage()
		}
	}
	
	var faviconImage: UIImage? {
		didSet {
			if let image = faviconImage {
				faviconImageView.image = shouldShowImage ? image : nil
			}
			else {
				faviconImageView.image = nil
			}
		}
	}

	var shouldShowImage = false {
		didSet {
			if shouldShowImage != oldValue {
				setNeedsLayout()
			}
			faviconImageView.image = shouldShowImage ? faviconImage : nil
		}
	}

	var unreadCount: Int {
		get {
			return unreadCountView.unreadCount
		}
		set {
			if unreadCountView.unreadCount != newValue {
				unreadCountView.unreadCount = newValue
				unreadCountView.isHidden = (newValue < 1)
				setNeedsLayout()
			}
		}
	}

	var name: String {
		get {
			return titleView.text ?? ""
		}
		set {
			if titleView.text != newValue {
				titleView.text = newValue
				setNeedsDisplay()
				setNeedsLayout()
			}
		}
	}

	private let titleView: UILabel = {
		let label = UILabel()
		label.numberOfLines = 1
		label.lineBreakMode = .byTruncatingTail
		label.allowsDefaultTighteningForTruncation = false
		return label
	}()

	private let faviconImageView: UIImageView = {
		return UIImageView(image: AppAssets.feedImage)
	}()

	private let unreadCountView = MasterUnreadCountView(frame: CGRect.zero)
	private var showingEditControl = false
	private var disclosureButton: UIButton?
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		commonInit()
	}

	override func willTransition(to state: UITableViewCell.StateMask) {
		super.willTransition(to: state)
		showingEditControl = state == .showingEditControl
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		let layout = MasterTableViewCellLayout(cellSize: bounds.size, shouldShowImage: shouldShowImage, label: titleView, unreadCountView: unreadCountView, showingEditingControl: showingEditControl, indent: indent, shouldShowDisclosure: true)
		layoutWith(layout)
	}
	
	@objc func buttonPressed(_ sender: UIButton) {
		if allowDisclosureSelection {
			disclosureExpanded = !disclosureExpanded
			delegate?.disclosureSelected(self, expanding: disclosureExpanded)
		}
	}
	
}

private extension MasterTableViewCell {

	func commonInit() {
		addSubviewAtInit(unreadCountView)
		addSubviewAtInit(faviconImageView)
		addSubviewAtInit(titleView)
		addDisclosureView()
	}
	
	func addDisclosureView() {
		
		disclosureButton = UIButton(type: .roundedRect)
		disclosureButton!.tintColor = AppAssets.chevronDisclosureColor
		disclosureButton!.addTarget(self, action: #selector(buttonPressed(_:)), for: UIControl.Event.touchUpInside)
		
		updateDisclosureImage()
		addSubviewAtInit(disclosureButton!)
		
	}
	
	func updateDisclosureImage() {
		if disclosureExpanded {
			disclosureButton?.setImage(AppAssets.chevronDownImage, for: .normal)
		} else {
			disclosureButton?.setImage(AppAssets.chevronRightImage, for: .normal)
		}
	}

	func addSubviewAtInit(_ view: UIView) {
		addSubview(view)
		view.translatesAutoresizingMaskIntoConstraints = false
	}

	func layoutWith(_ layout: MasterTableViewCellLayout) {
		faviconImageView.rs_setFrameIfNotEqual(layout.faviconRect)
		titleView.rs_setFrameIfNotEqual(layout.titleRect)
		unreadCountView.rs_setFrameIfNotEqual(layout.unreadCountRect)
		disclosureButton?.rs_setFrameIfNotEqual(layout.disclosureButtonRect)
	}
	
}

extension UIView {
	func rs_setFrameIfNotEqual(_ rect: CGRect) {
		if !self.frame.equalTo(rect) {
			self.frame = rect
		}
	}
}