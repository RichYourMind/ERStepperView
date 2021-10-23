//
//  StepperView.swift
//  Restaurant App
//
//  Created by ArshMini on 7/3/21.
//

import UIKit

public protocol StepperDelegate: AnyObject {
    func stepperViewIsShowing(index: Int)
    func stepperViewIsGoingZero()
}

open class StepperView: UIView {

    
    
    
    enum AnimationDirection {
        case up
        case down
    }
    enum AnimationState {
        case undergo
        case reachedEnd
        case stopped
    }
    
    
    
    
    
    //MARK: - Public Properties
    public weak var delegate: StepperDelegate?
    @IBInspectable public var primaryColor: UIColor = #colorLiteral(red: 0.5568627451, green: 0.3450980392, blue: 0.9803921569, alpha: 1) {
        didSet {
            collectionViewBoxView.backgroundColor = primaryColor
            collectionViewBoxView.layer.shadowColor = primaryColor.cgColor
            collectionViewBoxView.layer.borderWidth = 1.5
            collectionViewBoxView.layer.borderColor = primaryColor.cgColor
//            collectionViewBoxView.layer.cornerRadius = self.frame.width/2
            upButton.setTitleColor(primaryColor, for: .normal)
            downButton.setTitleColor(primaryColor, for: .normal)
        }
    }
    @IBInspectable public var totalNumber: Int = 10 {
        didSet {
            self.collectionView.reloadData()
        }
    }
    public var font: UIFont = .systemFont(ofSize: 25, weight: .bold)
    
    
    
    
    
    //MARK: - Public Methods
    public func setView(to index: Int) {
        currentSelectedIndex = index
        DispatchQueue.main.async {[unowned self] in
            collectionView.setContentOffset(getCollectionOffsetPoint(for: index), animated: false)
        }
    }
    
    
    
    
    //MARK: - Private Properties
    private var finalOffset: CGFloat {
        return (self.frame.height - collectionViewBoxView.frame.height)/2
    }
    private var animationDirection: AnimationDirection!
    private var animationState: AnimationState! = .stopped
    private let animationDuration: TimeInterval = 0.4
    private var buttonFontSize: CGFloat {
        return self.frame.width / 3
    }
    
    //Speed
    private var currentSpeed: CGFloat = 3.0
    private let speedsStep: [CGFloat] = [3.0 , 4.0 , 5.0 , 7.0 , 8.5 , 10 , 12 , 15]
    private let speedChangerInterval: TimeInterval = 0.4
    private var speedChangerTimer: Timer!
    private var currentSpeedIndex: Int = 0
    private let initialIndex: Int = 0
    private var finalIndex: Int {
        let lastItemContentOffset: CGFloat = collectionView.contentSize.height - collectionView.frame.height
        return Int(round(lastItemContentOffset / collectionView.frame.height))
    }
    private var currentIndex: Int {
        return Int(round(collectionView.contentOffset.y/collectionView.frame.height))
    }
    private var currentSelectedIndex: Int = 0

    
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    
    
    
    
    
    
    //MARK: - Views
    lazy var collectionViewBoxView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 13
        view.layer.shadowRadius = 15
        view.layer.shadowOpacity = 0.6
        return view
    }()
    lazy var layout: UICollectionViewFlowLayout = {
       let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = .zero
        return layout
    }()
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isScrollEnabled = false
        collectionView.register(.init(nibName: "StepperItemCollectionViewCell", bundle: Bundle.module), forCellWithReuseIdentifier: "myStepperItemCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    lazy var upButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(primaryColor, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: buttonFontSize)
        button.setTitle("∧", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(upButtonPressed), for: .touchUpInside)
        return button
    }()
    
    lazy var downButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(primaryColor, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: buttonFontSize)
        button.setTitle("∨", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(downButtonPressed), for: .touchUpInside)
        return button
    }()
    
    
    
    
    
    //MARK: - Setup
    private func setup() {
        
        addSubview(upButton)
        addSubview(downButton)
        addSubview(collectionViewBoxView)
        collectionViewBoxView.addSubview(collectionView)
        
        //Add Constraint
        NSLayoutConstraint.activate([
            upButton.widthAnchor.constraint(equalToConstant: self.frame.width/2),
            upButton.heightAnchor.constraint(equalToConstant: self.frame.width/2),
            upButton.topAnchor.constraint(equalTo: self.topAnchor , constant: 2),
            upButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            downButton.widthAnchor.constraint(equalToConstant: self.frame.width/2),
            downButton.heightAnchor.constraint(equalToConstant: self.frame.width/2),
            downButton.bottomAnchor.constraint(equalTo: self.bottomAnchor , constant: -2),
            downButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            collectionViewBoxView.widthAnchor.constraint(equalToConstant: self.frame.width),
            collectionViewBoxView.heightAnchor.constraint(equalToConstant: self.frame.width),
            collectionViewBoxView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            collectionViewBoxView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            collectionView.topAnchor.constraint(equalTo: self.collectionViewBoxView.topAnchor, constant: 0),
            collectionView.bottomAnchor.constraint(equalTo: self.collectionViewBoxView.bottomAnchor, constant: 0),
            collectionView.leadingAnchor.constraint(equalTo: self.collectionViewBoxView.leadingAnchor, constant: 0),
            collectionView.trailingAnchor.constraint(equalTo: self.collectionViewBoxView.trailingAnchor, constant: 0),

        ])
        
        
        //Properties
        primaryColor = #colorLiteral(red: 0.5568627451, green: 0.3450980392, blue: 0.9803921569, alpha: 1)
        
        //Pan Gesture
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        collectionViewBoxView.addGestureRecognizer(panGesture)
        
        //Reload Collection Data
        collectionView.reloadData()
        
        //Configure Timer
        configureDisplayLink()

    }
    
    
    
    
    
    
    
    
    ////////////////////////////
    //////////////
    //
    //       MARK: Display Link
    //
    //////////////
    ////////////////////////////
    var displayShowdLink: CADisplayLink!
    private func configureDisplayLink() {
        
        //Display Link
        displayShowdLink = CADisplayLink(target: self, selector: #selector(linkTriggered))
        displayShowdLink.isPaused = true
        displayShowdLink.add(to: .main, forMode: .default)
        
    }
    
    @objc func linkTriggered(displayLink: CADisplayLink) {
                
        //Check For Continue
        if self.collectionView.contentOffset.y < 0 {
            displayShowdLink.isPaused = true
            self.collectionView.setContentOffset(.zero, animated: true)
            self.animationState = .reachedEnd
            return
        }
        
        let finalOffset: CGFloat = collectionView.contentSize.height - collectionView.frame.height
        if self.collectionView.contentOffset.y > finalOffset {
            displayShowdLink.isPaused = true
            self.collectionView.setContentOffset(.init(x: 0.0, y: finalOffset), animated: true)
            self.animationState = .reachedEnd
            return
        }
        
        
        //Set Collection Offset
        let point: CGPoint = .init(x: 0, y: self.collectionView.contentOffset.y + currentSpeed)
        self.collectionView.setContentOffset(point, animated: false)
        
    }
    
    private func startSpeedTimer() {
        speedChangerTimer = Timer.scheduledTimer(withTimeInterval: speedChangerInterval , repeats: true) {[unowned self] timer in
            currentSpeedIndex += 1
            guard currentSpeedIndex < speedsStep.count else {
                timer.invalidate()
                return
            }
            currentSpeed = animationDirection == .down ? -speedsStep[currentSpeedIndex] : speedsStep[currentSpeedIndex]
            
        }
    }
    
    
    
    
    
    
    
    
    
    
    //MARK: - Handle Pan Gesture
    @objc func handlePan(_ pan: UIPanGestureRecognizer) {
        var yTransition = pan.translation(in: collectionViewBoxView).y
        yTransition = yTransition > 0 ? min(yTransition , finalOffset) : max(yTransition , -finalOffset)
        
        //State
        switch pan.state {
        case .began:
            currentSpeedIndex = 0
            animationState = .stopped
        case .changed: collectionViewBoxView.transform = CGAffineTransform(translationX: 0.0 , y: yTransition)
            if yTransition > 0 , currentIndex == initialIndex {return}
            if yTransition < 0 , currentIndex == finalIndex {return}
            
            switch animationState {
            case .stopped:
                if abs(yTransition) == abs(finalOffset) {
                    animationState = .undergo
                    animationDirection = yTransition > 0 ? AnimationDirection.down : AnimationDirection.up
                    currentSpeed = animationDirection == .down ? -speedsStep[currentSpeedIndex] : speedsStep[currentSpeedIndex]
                    startSpeedTimer()
                    displayShowdLink.isPaused = false
                }
                
                break
                
            case .undergo , .reachedEnd:
                let currentDirection = yTransition > 0 ? AnimationDirection.down : AnimationDirection.up
                if currentDirection != animationDirection {
                    //User Is Switching Direction In Middle Of Animation
                    //We Have To Reset Aniamtion
                    if abs(yTransition) == abs(finalOffset) {
                        speedChangerTimer.invalidate()
                        currentSpeedIndex = 0
                        animationDirection = yTransition > 0 ? AnimationDirection.down : AnimationDirection.up
                        currentSpeed = animationDirection == .down ? -speedsStep[currentSpeedIndex] : speedsStep[currentSpeedIndex]
                        startSpeedTimer()
                        displayShowdLink.isPaused = false
                    }
                    
                }
                
            default:
                break
            }
            
        case .ended:
            self.setBoxViewBackToNormalPosition(duration: animationDuration, delay: 0.0)
            currentSelectedIndex = currentIndex
            delegate?.stepperViewIsShowing(index: currentSelectedIndex)
            guard !displayShowdLink.isPaused else {return}
            displayShowdLink.isPaused = true
            
            if animationDirection == .up {
                animateCollectionViewTo(point: getCollectionOffsetPoint(for: currentIndex + 1),
                                        duration: animationDuration * 0.8, delay: 0.0) {
                    [unowned self] in
                    self.currentSelectedIndex = currentIndex + 1
                    delegate?.stepperViewIsShowing(index: currentSelectedIndex)
                }
            }else {
                animateCollectionViewTo(point: getCollectionOffsetPoint(for: currentIndex - 1),
                                        duration: animationDuration * 0.8, delay: 0.0) {
                    [unowned self] in
                    self.currentSelectedIndex = currentIndex - 1
                    delegate?.stepperViewIsShowing(index: currentSelectedIndex)
                }
            }

            
        default: break
        }
    }
    
    
    
    
    
    
    
    
    //MARK: - Helper Methods
    private func getCollectionOffsetPoint(for index: Int) -> CGPoint {
        return CGPoint(x: 0, y: CGFloat(index) * CGFloat(collectionView.frame.height))
    }
    
    
    
    
    
    
    
    //MARK: - Actions
    @objc func upButtonPressed() {
        animateBoxViewUp(duration: animationDuration, delay: 0.0) {[unowned self] in
            self.setBoxViewBackToNormalPosition(duration: animationDuration, delay: 0.0)
        }
        
        guard currentSelectedIndex < finalIndex else {return}
        animateCollectionViewTo(point: getCollectionOffsetPoint(for: currentSelectedIndex + 1),
                                duration: animationDuration, delay: animationDuration/3) {
            [unowned self] in
            self.currentSelectedIndex += 1
            delegate?.stepperViewIsShowing(index: currentSelectedIndex)
        }
    }
    
    @objc func downButtonPressed() {
        animateBoxViewDown(duration: animationDuration, delay: 0.0) {[unowned self] in
            self.setBoxViewBackToNormalPosition(duration: animationDuration, delay: 0.0)
        }
        
        guard currentSelectedIndex > initialIndex else {
            delegate?.stepperViewIsGoingZero()
            return
        }
        animateCollectionViewTo(point: getCollectionOffsetPoint(for: currentSelectedIndex - 1),
                                duration: animationDuration, delay: animationDuration/3) {
            [unowned self] in
            self.currentSelectedIndex -= 1
            delegate?.stepperViewIsShowing(index: currentSelectedIndex)

        }
    }
    
    
    
    
    
    //MARK: - Animation
    private func setBoxViewBackToNormalPosition(duration: TimeInterval , delay: TimeInterval, completion: (() -> ())? = nil) {
        UIView.animate(withDuration: duration,
                       delay: delay,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.5,
                       options: []) {[unowned self] in
            self.collectionViewBoxView.transform = .identity
        } completion: { _ in
            completion?()
        }
    }
    
    private func animateBoxViewUp(duration: TimeInterval , delay: TimeInterval , completion: (() -> ())? = nil) {
        UIView.animate(withDuration: duration,
                       delay: delay,
                       usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 1.0,
                       options: [.curveEaseOut]) {[unowned self] in
            self.collectionViewBoxView.transform = CGAffineTransform(translationX: 0.0, y: -finalOffset)
        } completion: { _ in
            completion?()
        }

    }
    
    private func animateBoxViewDown(duration: TimeInterval , delay: TimeInterval , completion: (() -> ())? = nil) {
        UIView.animate(withDuration: duration,
                       delay: delay,
                       usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 1.0,
                       options: [.curveEaseOut]) {[unowned self] in
            self.collectionViewBoxView.transform = CGAffineTransform(translationX: 0.0, y: finalOffset)
        } completion: { _ in
            completion?()
        }

    }
    
    private func animateCollectionViewTo(point: CGPoint , duration: TimeInterval , delay: TimeInterval  , completion: (() -> ())? = nil) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {[unowned self] in
            UIView.animate(withDuration: duration,
                           delay: 0.0,
                           usingSpringWithDamping: 1.0,
                           initialSpringVelocity: 1.0,
                           options: [.curveEaseOut]) {[unowned self] in
                self.collectionView.setContentOffset(point, animated: true)
            } completion: { _ in
                completion?()
            }
        }
    }
    
    
    

}






//MARK: - UICollection View Delegate / Datasource
extension StepperView: UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return totalNumber
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myStepperItemCell", for: indexPath) as! StepperItemCollectionViewCell
        
        //Confiugre
        cell.configure(title: "\(indexPath.item + 1)" , color: .white, font: self.font)
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
}
