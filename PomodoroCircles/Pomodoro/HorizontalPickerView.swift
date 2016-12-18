import UIKit

enum PomodoroActivityStates: Int {
    case work = 0
    case shortBreak
    case longBreak
    
    var color: UIColor {
        get {
            switch self {
            case .work:
                return UIColor.red
            case .shortBreak:
                return UIColor.yellow
            case .longBreak:
                return UIColor.orange
            }
        }
    }
    
    var seconds: Int {
        get {
            switch self {
            case .work:
                return SettingsValues.pomodoroWork * 60
            case .shortBreak:
                return SettingsValues.pomodoroShortBreak * 60
            case .longBreak:
                return SettingsValues.pomodoroLongBreak * 60
            }
        }
    }
    
    var name: String {
        get {
            switch self {
            case .work:
                return SettingsValues.pomodoroWorkName
            case .shortBreak:
                return SettingsValues.pomodoroShortBreakName
            case .longBreak:
                return SettingsValues.pomodoroLongBreakName
            }
        }
    }
    
    var sound: String {
        get {
            switch self {
            case .work:
                return SettingsValues.notificationsWorkSound
            case .shortBreak:
                return SettingsValues.notificationsShortBreakSound
            case .longBreak:
                return SettingsValues.notificationsLongBreakSound
            }
        }
    }
}

protocol HorizontalPickerViewUpdateDelegate: class {
    func activityStateUpdate(_ selectedActivity: PomodoroActivityStates)
}

class HorizontalPickerViewCell: UICollectionViewCell {
    
    var label: UILabel!
    
    override var isSelected: Bool {
        didSet {
            label.font = isSelected ? Utils.horizontalPickerViewCellBoldFont : Utils.horizontalPickerViewCellFont
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        label = UILabel()
        label.textAlignment = .center
        label.font = Utils.horizontalPickerViewCellFont
        label.textColor = Utils.horizontalPickerViewCellFontColor
        contentView.addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class HorizontalPickerView: UIView {
    
    fileprivate let cellReuseIdentifier = "HorizontalPickerViewCell"
    fileprivate var collectionView : UICollectionView!
    fileprivate var data : [PomodoroActivityStates] = [.work, .shortBreak, .longBreak]
    fileprivate var selectedItem: Int = 0
    fileprivate var previousBounds = CGRect.zero
    
    weak var delegate: HorizontalPickerViewUpdateDelegate?
    
    var activated = true {
        didSet {
            isUserInteractionEnabled = activated
            for index in 0..<data.count {
                if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) {
                    cell.isHidden = index != selectedItem && !activated
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if bounds != previousBounds {
            previousBounds = bounds
            
            layer.mask?.frame = bounds
            scrollToItem(IndexPath(item: selectedItem, section: 0), callDelegate: false)
        }
    }
    
    func initView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.decelerationRate = UIScrollViewDecelerationRateFast
        collectionView.backgroundColor = UIColor.clear
        collectionView.register(HorizontalPickerViewCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 200, bottom: 0, right: 200)
        collectionView.showsHorizontalScrollIndicator = false
        
        addSubview(collectionView)
        collectionView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        collectionView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        collectionView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.selectItem(at: IndexPath(item: selectedItem, section: 0), animated: false, scrollPosition: UICollectionViewScrollPosition())
        
        let maskLayer = CAGradientLayer()
        maskLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.black.cgColor,
            UIColor.black.cgColor,
            UIColor.clear.cgColor]
        maskLayer.locations = [0.0, 0.22, 0.88, 1.0]
        maskLayer.startPoint = CGPoint(x: 0, y: 0)
        maskLayer.endPoint = CGPoint(x: 1, y: 0)
        layer.mask = maskLayer
        backgroundColor = UIColor.clear
    }
    
    func changeState(_ state: PomodoroActivityStates) {
        collectionView.cellForItem(at: IndexPath(item: selectedItem, section: 0))?.isHidden = !activated
        
        let item = data.index(of: state)!
        let path = IndexPath(item: item, section: 0)
        selectedItem = item
        scrollToItem(path, callDelegate: false)
        collectionView.selectItem(at: path, animated: false, scrollPosition: UICollectionViewScrollPosition())
        collectionView.cellForItem(at: IndexPath(item: selectedItem, section: 0))?.isHidden = false
    }
    
    func findCentralItem() {
        let visiblePaths = collectionView.indexPathsForVisibleItems
        var centerPath = visiblePaths[0]
        var centerOffset = CGFloat.greatestFiniteMagnitude
        
        for path in visiblePaths {
            let itemAttributes = collectionView.layoutAttributesForItem(at: path)!
            let difference = abs(itemAttributes.center.x - collectionView.contentOffset.x - collectionView.center.x)
            if difference < centerOffset {
                centerOffset = difference
                centerPath = path
            }
        }
        
        selectedItem = centerPath.item
        collectionView.selectItem(at: centerPath, animated: true, scrollPosition: UICollectionViewScrollPosition())
        scrollToItem(centerPath)
    }
    
    func scrollToItem(_ path: IndexPath, callDelegate: Bool = true) {
        if callDelegate {
            delegate?.activityStateUpdate(data[path.item])
        }
        
        let itemAttributes = collectionView.layoutAttributesForItem(at: path)!
        let offset = CGPoint(x: itemAttributes.center.x - collectionView.center.x, y: collectionView.contentOffset.y)
        collectionView.setContentOffset(offset, animated: true)
    }
}

extension HorizontalPickerView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.isHidden = indexPath.item != selectedItem && !activated
        cell.isSelected = indexPath.item == selectedItem
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedItem = indexPath.item
        scrollToItem(indexPath)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        findCentralItem()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            findCentralItem()
        }
    }
}

extension HorizontalPickerView: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as! HorizontalPickerViewCell
        cell.label.frame = cell.bounds
        cell.label.text = data[indexPath.item].name
        cell.tag = indexPath.item
        cell.isHidden = indexPath.item != selectedItem && !activated
        return cell
    }
}

extension HorizontalPickerView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return data[indexPath.item].name.size(attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 20, weight: 2)])
    }
}
