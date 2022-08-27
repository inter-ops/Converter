//
//  ColorfulProgressIndicator.swift
//  Converter
//
//  Created by Justin Bush on 8/27/22.
//
//  Reference: https://stackoverflow.com/questions/60069243/how-do-i-create-my-own-progressbar-in-swift/60083375#60083375
//

import Cocoa

@IBDesignable
open class ColorfulProgressIndicator: NSView {
  @IBInspectable open var doubleValue: Double = 0  { didSet { needsLayout = true } }
  @IBInspectable open var minValue: Double = 0     { didSet { needsLayout = true } }
  @IBInspectable open var maxValue: Double = 100   { didSet { needsLayout = true } }
  
  @IBInspectable open var backgroundColor: NSColor = .controlBackgroundColor  { didSet { layer?.backgroundColor = backgroundColor.cgColor } }
  @IBInspectable open var progressColor:   NSColor = .controlAccentColor      { didSet { progressShapeLayer.fillColor = progressColor.cgColor } }
  @IBInspectable open var borderColor:     NSColor = .placeholderTextColor    { didSet { layer?.borderColor = borderColor.cgColor } }
  @IBInspectable open var borderWidth:     CGFloat = 0.3        { didSet { layer?.borderWidth = borderWidth } }
  @IBInspectable open var cornerRadius:    CGFloat = 3          { didSet { layer?.cornerRadius = cornerRadius } }
  
  private lazy var progressShapeLayer: CAShapeLayer = {
    let shapeLayer = CAShapeLayer()
    shapeLayer.fillColor = progressColor.cgColor
    return shapeLayer
  }()
  
  public override init(frame: NSRect = .zero) {
    super.init(frame: frame)
    configure()
  }
  
  public required init?(coder: NSCoder) {
    super.init(coder: coder)
    configure()
  }
  
  // needed because IB doesn't don't honor `wantsLayer`
  open override func prepareForInterfaceBuilder() {
    super.prepareForInterfaceBuilder()
    layer = CALayer()
    configure()
  }
  
  open override func layout() {
    super.layout()
    updateProgress()
  }
  
  open func animate(to doubleValue: Double? = nil, minValue: Double? = nil, maxValue: Double? = nil, duration: TimeInterval = 0.5) {
    let currentPath = progressShapeLayer.presentation()?.path ?? progressShapeLayer.path
    
    // stop prior animation, if any
    progressShapeLayer.removeAnimation(forKey: "updatePath")
    
    // update progress properties
    if let doubleValue = doubleValue { self.doubleValue = doubleValue }
    if let minValue = minValue       { self.minValue = minValue }
    if let maxValue = maxValue       { self.maxValue = maxValue }
    
    // create new animation
    let animation = CABasicAnimation(keyPath: "path")
    animation.duration = duration
    animation.fromValue = currentPath
    animation.toValue = progressPath
    progressShapeLayer.add(animation, forKey: "updatePath")
  }
}

private extension ColorfulProgressIndicator {
  func configure() {
    wantsLayer = true
    
    layer?.cornerRadius = cornerRadius
    layer?.backgroundColor = backgroundColor.cgColor
    layer?.borderWidth = borderWidth
    layer?.borderColor = borderColor.cgColor
    
    layer?.addSublayer(progressShapeLayer)
  }
  
  func updateProgress() {
    progressShapeLayer.path = progressPath
  }
  
  var progressPath: CGPath? {
    guard minValue != maxValue else { return nil }
    let percent = max(0, min(1, CGFloat((doubleValue - minValue) / (maxValue - minValue))))
    let rect = NSRect(origin: bounds.origin, size: CGSize(width: bounds.width * percent, height: bounds.height))
    return CGPath(rect: rect, transform: nil)
  }
}
