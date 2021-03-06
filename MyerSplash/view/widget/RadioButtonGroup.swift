import Foundation
import UIKit
import SnapKit
import MaterialComponents
import MyerSplashShared

class RadioButtonGroup: UIStackView {
    var onItemClicked: ((Int) -> Void)? = nil

    convenience init(options: [String], selected: Int) {
        self.init(frame: CGRect.zero)
        initUi(options, selected)
    }

    private func initUi(_ options: [String], _ selected: Int) {
        self.axis = NSLayoutConstraint.Axis.vertical

        for i in 0..<options.count {
            let button = RadioButton(options[i])
            if (i == selected) {
                button.checked = true
            }
            button.isUserInteractionEnabled = true
            button.addGestureRecognizer(UITapGestureRecognizer(target: self,
                    action: #selector(self.onClickItem)))
            addArrangedSubview(button)
            button.snp.makeConstraints { maker in
                maker.left.right.equalTo(self)
            }
        }
    }

    @objc
    private func onClickItem(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view,
              let index = self.subviews.firstIndex(of: view) else {
            return
        }
        for i in 0..<subviews.count {
            (subviews[i] as! RadioButton).checked = index == i
        }
        onItemClicked?(index)
    }
}

class RadioButton: UIView {
    private var tickIcon: UIImageView!
    private var contentView: UILabel!

    var checked: Bool = false {
        didSet {
            tickIcon.isHidden = !checked
        }
    }

    private var content: String? = nil
    private var rippleController: MDCRippleTouchController!

    convenience init(_ text: String) {
        self.init(frame: CGRect.zero)
        content = text
        initUi()
    }

    private func initUi() {
        tickIcon = UIImageView()
        tickIcon.image = UIImage(named: R.icons.ic_done)?.withRenderingMode(.alwaysTemplate)
        tickIcon.isHidden = true
        tickIcon.tintColor = UIColor.getDefaultLabelUIColor()

        contentView = UILabel()
        contentView.text = content
        contentView.textColor = UIColor.getDefaultLabelUIColor()
        contentView.font = contentView.font.withSize(FontSizes.Normal)

        addSubview(tickIcon)
        addSubview(contentView)

        tickIcon.snp.makeConstraints { maker in
            maker.centerY.equalTo(self)
            maker.width.height.equalTo(Dimensions.SingleChoiceItemHeight / 2)
            maker.left.equalTo(self).offset(12)
        }

        contentView.snp.makeConstraints { maker in
            maker.left.equalTo(tickIcon.snp.right).offset(12)
            maker.right.equalTo(self)
            maker.centerY.equalTo(self)
        }

        self.snp.makeConstraints { maker in
            maker.height.equalTo(Dimensions.SingleChoiceItemHeight)
        }
        
        rippleController = MDCRippleTouchController()
        rippleController.addRipple(to: self)
        rippleController.rippleView.rippleColor = R.colors.rippleColor
    }
}
