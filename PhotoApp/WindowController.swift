//  WindowController.swift
//  PhotoApp
//
//  Created by Pixelmator on 6/19/17.
//  Copyright © 2017 Pixelmator. All rights reserved.

import Cocoa
import CoreImage

class WindowController: NSWindowController, NSToolbarDelegate, NSPopoverDelegate {
	
	var originalImage: NSImage? = nil
	var originalCIImage: CIImage? = nil
//	let ciContext = CIContext.init(mtlDevice: MTLCreateSystemDefaultDevice()!)
	let ciContext = CIContext()
//	weak var appDelegate: AppDelegate? = nil
	
	//-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
	//  toolbar
	//-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
	
	let ZoomToolbarItemID = "Zoom"
	let applyChangesToolbarItemID = "Apply Changes"
	let blurFilterToolbarItemID = "Blur Filter"
	let colorEffectFilterToolbarItemID = "Color Effect Filter"
	let colorAdjustmentFilterToolbarItemID = "Color Adjustment Filter"
	let geometryAdjustToolbarItemID = "Geometry Adjustment"
	let sharpenFilterToolbarItemID = "Sharpen Filter"
	
	@IBOutlet var toolbar: NSToolbar!
	
	
	//-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
	//  zoom toolbar item
	//-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
	
	@IBOutlet var zoomControlView: NSView!
	@IBAction func changeZoom(_ sender: NSSegmentedControl) {
		let whichButton = sender.selectedSegment
		self.zoom(index: whichButton)
	}
	
	//-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
	//  apply changes toolbar item
	//-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
	
	@IBOutlet var applyChangesView: NSView!
	@IBAction func applyChanges(_ sender: NSSegmentedControl) {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			switch sender.selectedSegment {
			case 0:
				originalCIImage = view.image
			case 1:
				view.image = originalCIImage
			default:
				assertionFailure("Failed to apply changes")
			}
		}
	}
	
	//-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
	//  blur filter toolbar item and popovers
	//-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
	
	@IBOutlet var blurFilterView: NSView!
	@IBOutlet weak var blurFilterPopUpButton: NSPopUpButton!
	
	var blurPopovers: [NSPopover?] = [nil, nil, nil, nil, nil, nil, nil, nil, nil, ]
	var blurPopoverControllerNames: [String] = ["", "BoxBlurPopoverViewController", "DiscBlurPopoverViewController", "GaussianBlurPopoverViewController", "MotionBlurPopoverViewController", "NoiseBlurPopoverViewController", "ZoomBlurPopoverViewController"]
	var blurPopoverControllers: [NSViewController?] = [nil, nil, nil, nil, nil, nil, nil, nil, nil]
	
	func updateBoxBlur(with boxRadius: Double) {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			let filteredImage = image.applyingFilter("CIBoxBlur", withInputParameters: ["inputRadius": boxRadius])
			view.image = filteredImage
		}
	}
	
	func updateDiscBlur(with discRadius: Double) {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			//Crashes with values 0..1 radar 33770007
			let filteredImage = image.applyingFilter("CIDiscBlur", withInputParameters: ["inputRadius": discRadius])
			view.image = filteredImage
		}
	}
	
	func updateGaussianBlur(with sigma: Double) {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			let filteredImage = image.applyingFilter("CIGaussianBlur", withInputParameters: ["inputRadius": sigma])
			view.image = filteredImage
		}
	}
	
	func updateMaskedVariableBlur(with radius: Double) {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			let filteredImage = image.applyingFilter("CIMaskedVariableBlur", withInputParameters: ["inputRadius": radius])
			view.image = filteredImage
		}
	}
	
	func updateMedianFilter() {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			let filteredImage = image.applyingFilter("CIMedianFilter", withInputParameters: [:])
			view.image = filteredImage
		}
	}
	
	func updateMotionBlur(with motionRadius: Double, motionAngle: Double) {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			let filteredImage = image.applyingFilter("CIMotionBlur", withInputParameters: ["inputRadius": motionRadius, "inputAngle": motionAngle])
			view.image = filteredImage
		}
	}
	
	func updateNoiseReduction(with noiseLevel: Double, sharpness: Double) {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			let filteredImage = image.applyingFilter("CINoiseReduction", withInputParameters: ["inputNoiseLevel": noiseLevel, "inputSharpness": sharpness])
			view.image = filteredImage
		}
	}
	
	func updateZoomBlur(with amount: Double, center: CIVector) {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			let filteredImage = image.applyingFilter("CIZoomBlur", withInputParameters: ["inputAmount": amount, "inputCenter": center])
			view.image = filteredImage
		}
	}
	
	@IBAction func showBlurPopoverAction(_ sender: NSButton) {
		showBlurPopover(id: blurFilterPopUpButton.indexOfSelectedItem)
	}
	
	@IBAction func showBlurPopoverActionMenu(_ sender: NSMenuItem) {
		showBlurPopover(id: sender.tag)
	}
	
	func showBlurPopover(id: Int) {
		if id != 0 && id != 7 {
			self.createBlurPopover(popoverViewController: self.blurPopoverControllers[id]!, x: id)
			let prefEdge: NSRectEdge = NSRectEdge.minY
			let targetButton = window!.standardWindowButton(.closeButton)!.superview!
			self.blurPopovers[id]?.show(relativeTo: targetButton.bounds , of: targetButton, preferredEdge: prefEdge)
		} else if id == 7 {
			self.updateMedianFilter()
		}
	}
	
	func createBlurPopover(popoverViewController: NSViewController, x: Int) {
		if (self.blurPopovers[x] == nil) {
			self.blurPopovers[x] = NSPopover.init()
			self.blurPopovers[x]?.contentViewController = popoverViewController;
			self.blurPopovers[x]?.animates = true
			self.blurPopovers[x]?.appearance = NSAppearance.init(named: NSAppearance.Name.vibrantLight)
			self.blurPopovers[x]?.behavior = NSPopover.Behavior.transient
			self.blurPopovers[x]?.delegate = self
			(self.blurPopovers[x]?.contentViewController as? PopoverViewController)?.windowController = self
		}
	}
	
	//-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
	//  color adjustment filter toolbar item and popovers
	//-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
	
	@IBOutlet var colorAdjustmentFilterView: NSView!
	@IBOutlet weak var colorAdjustmentFilterPopUpButton: NSPopUpButton!
	
	var colorAdjustmentPopovers: [NSPopover?] = [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]
	var colorAdjustmentPopoverControllerNames: [String] = ["", "ColorControlsPopoverViewController", "ExposureAdjustPopoverViewController", "GammaAdjustPopoverViewController", "HueAdjustPopoverViewController", "", "", "TemperatureAndTintPopoverViewController", "VibrancePopoverViewController", "WhitePointAdjustPopoverViewController"]
	var colorAdjustmentPopoverControllers: [NSViewController?] = [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]
	let colorAdjustmentArray: [Int] = [1, 2, 3, 4, 7, 8, 9]
	
	func updateColorControls(with saturation: Double, brightness: Double, contrast: Double) {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			let filteredImage = image.applyingFilter("CIColorControls", withInputParameters: ["inputSaturation": saturation, "inputBrightness": brightness, "inputContrast": contrast])
			view.image = filteredImage
		}
	}
	
	func updateExposureAdjust(with ev: Double) {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			let filteredImage = image.applyingFilter("CIExposureAdjust", withInputParameters: ["inputEV": ev])
			view.image = filteredImage
		}
	}
	
	func updateGammaAdjust(with power: Double) {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			let filteredImage = image.applyingFilter("CIGammaAdjust", withInputParameters: ["inputPower": power])
			view.image = filteredImage
		}
	}
	
	func updateHueAdjust(with angle: Double) {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			let filteredImage = image.applyingFilter("CIHueAdjust", withInputParameters: ["inputAngle": angle])
			view.image = filteredImage
		}
	}
	
	func updateLinearToSRGBFilter() {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			let filteredImage = image.applyingFilter("CILinearToSRGBToneCurve", withInputParameters: [:])
			view.image = filteredImage
		}
	}
	
	func updateSRGBToLinearFilter() {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			let filteredImage = image.applyingFilter("CISRGBToneCurveToLinear", withInputParameters: [:])
			view.image = filteredImage
		}
	}
	
	func updateVibranceAdjust(with vibrance: Double) {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			let filteredImage = image.applyingFilter("CIVibrance", withInputParameters: ["inputAmount": vibrance])
			view.image = filteredImage
		}
	}
	
	func updateWhitePointAdjust(with whitePoint: CIColor) {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			let filteredImage = image.applyingFilter("CIWhitePointAdjust", withInputParameters: ["inputColor": whitePoint])
			view.image = filteredImage
		}
	}
	
	@IBAction func showColorAdjustmentPopover(_ sender: NSButton) {
		showColorAdjustmentPopover(id: colorAdjustmentFilterPopUpButton.indexOfSelectedItem)
	}
	
	@IBAction func showColorAdjustmentPopoverMenu(_ sender: NSMenuItem) {
		showColorAdjustmentPopover(id: sender.tag)
	}
	
	func showColorAdjustmentPopover(id: Int) {
		switch id {
		case 5:
			self.updateLinearToSRGBFilter()
		case 6:
			self.updateSRGBToLinearFilter()
		default:
			if id != 0 {
				self.createColorAdjustmentPopover(popoverViewController: self.colorAdjustmentPopoverControllers[id]!, x: id)
				let targetButton = window!.standardWindowButton(.closeButton)!.superview!
				let prefEdge: NSRectEdge = NSRectEdge.minY
				self.colorAdjustmentPopovers[id]?.show(relativeTo: targetButton.bounds, of: targetButton, preferredEdge: prefEdge)
			}
		}
	}
	
	func createColorAdjustmentPopover(popoverViewController: NSViewController, x: Int) {
		if (self.colorAdjustmentPopovers[x] == nil)
		{
			self.colorAdjustmentPopovers[x] = NSPopover.init()
			self.colorAdjustmentPopovers[x]?.contentViewController = popoverViewController;
			self.colorAdjustmentPopovers[x]?.animates = true
			self.colorAdjustmentPopovers[x]?.appearance = NSAppearance.init(named: NSAppearance.Name.vibrantLight)
			self.colorAdjustmentPopovers[x]?.behavior = NSPopover.Behavior.transient
			self.colorAdjustmentPopovers[x]?.delegate = self
			(self.colorAdjustmentPopovers[x]?.contentViewController as? PopoverViewController)?.windowController = self
		}
	}
	
	//-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
	//  sharpening
	//-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
	
	@IBOutlet var sharpenView: NSView!
	@IBOutlet var sharpenPopUpButton: NSPopUpButton!
	var sharpenPopovers: [NSPopover?] = [nil, nil, nil]
	var sharpenPopoverControllers: [NSViewController?] = [nil, nil, nil]
	var sharpenPopoverNames: [String] = ["", "SharpenLuminancePopoverViewController", "UnsharpMaskPopoverViewController"]
	
	// netgi dvi funkcijos
	
	func updateSharpenLuminance(with sharpness: Double) {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			let filteredImage = image.applyingFilter("CISharpenLuminance", withInputParameters: ["inputSharpness": sharpness])
			view.image = filteredImage
		}
	}
	
	func updateUnsharpMask(with radius: Double, intensity: Double) {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			let filteredImage = image.applyingFilter("CIUnsharpMask", withInputParameters: ["inputRadius": radius, "inputIntensity": intensity])
			view.image = filteredImage
		}
	}
	
	@IBAction func showSharpenPopoverAction(_ sender: NSButton) {
		showSharpenPopover(id: sharpenPopUpButton.indexOfSelectedItem)
	}
	
	@IBAction func showSharpenPopoverActionMenu(_ sender: NSMenuItem) {
		showSharpenPopover(id: sender.tag)
	}
	
	func showSharpenPopover(id: Int) {
		if id != 0 {
			self.createSharpenPopover(popoverViewController: self.sharpenPopoverControllers[id]!, x: id)
			let prefEdge: NSRectEdge = NSRectEdge.minY
			let targetButton = window!.standardWindowButton(.closeButton)!.superview!
			self.sharpenPopovers[id]?.show(relativeTo: targetButton.bounds , of: targetButton, preferredEdge: prefEdge)
		}
	}
	
	func createSharpenPopover(popoverViewController: NSViewController, x: Int) {
		if (self.sharpenPopovers[x] == nil)
		{
			self.sharpenPopovers[x] = NSPopover.init()
			self.sharpenPopovers[x]?.contentViewController = popoverViewController;
			self.sharpenPopovers[x]?.animates = true
			self.sharpenPopovers[x]?.appearance = NSAppearance.init(named: NSAppearance.Name.vibrantLight)
			self.sharpenPopovers[x]?.behavior = NSPopover.Behavior.transient
			self.sharpenPopovers[x]?.delegate = self
			(self.sharpenPopovers[x]?.contentViewController as? PopoverViewController)?.windowController = self
		}
	}
	
	//-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
	//  geometry adjustment
	//-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
	
	@IBOutlet var geometryAdjustmentView: NSView!
	@IBOutlet weak var geometryControls: NSSegmentedControl!
	@IBAction func initWindowControllerInstanceInCustomImageView(_ sender: Any) {
		if let view = window?.contentView?.subviews.first as? NSScrollView {
			(view.documentView?.subviews.first as? CustomImageView)?.windowController = self
		}
	}
    
    @IBOutlet weak var geometryControlsMomentary: NSSegmentedControl!
    @IBAction func geometryControlsMomentary(_ sender: Any) {
        if let sender = sender as? NSSegmentedControl {
            switch sender.selectedSegment {
            case 0:
                self.updateMirror()
            default:
                self.doNothing()
            }
        }
    }
    
	
	func updateCrop(with rectangle: CGRect) {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			let filteredImage = image.applyingFilter("CICrop", withInputParameters: ["inputRectangle": CIVector(cgRect: rectangle)])
			view.image = filteredImage
		}
	}
	
	func updateRotation(with angle: CGFloat) {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			let filteredImage = image.applyingFilter("CIStraightenFilter", withInputParameters: ["inputAngle": angle])
			view.image = filteredImage
		}
	}
	
	func updateMirror() {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			let filteredImage = image.applyingOrientation(2)
			view.image = filteredImage
		}
	}
	
	//-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
	//  color effect filter and toolbar item
	//-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
	
	@IBOutlet var colorEffectFilterView: NSView!
	@IBOutlet weak var colorEffectFilterPopUpButton: NSPopUpButton!
	var colorEffectPopovers: [NSPopover?] = [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]
	var colorEffectPopoverControllerNames: [String] = ["", "", "ColorMonochromePopoverViewController", "ColorPosterizePopoverViewController", "FalseColorPopoverViewController", "", "", "", "", "", "", "", "", "", "", "", "SepiaTonePopoverViewController", "VignettePopoverViewController", "VignetteEffectPopoverViewController"]
	var colorEffectArray: [Int] = [2, 3, 4, 16, 17, 18]
	var colorEffectPopoverControllers: [NSViewController?] = [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]
	
	// labai daug funkciju
	
	func updateInvertColors() {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			let filteredImage = image.applyingFilter("CIColorInvert", withInputParameters: [:])
			view.image = filteredImage
		}
	}
	
	func updateMonochromeAdjust(with color: CIColor, intensity: Double) {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			let filteredImage = image.applyingFilter("CIColorMonochrome", withInputParameters: ["inputColor": color, "inputIntensity": intensity])
			view.image = filteredImage
		}
	}
	
	func updatePosterize(with levels: Double) {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			let filteredImage = image.applyingFilter("CIColorPosterize", withInputParameters: ["inputLevels": levels])
			view.image = filteredImage
		}
	}
	
	func updateMaskToAlpha() {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			let filteredImage = image.applyingFilter("CIMaskToAlpha", withInputParameters: [:])
			view.image = filteredImage
		}
	}
	
	func updateMaximumComponent() {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			let filteredImage = image.applyingFilter("CIMaximumComponent", withInputParameters: [:])
			view.image = filteredImage
		}
	}
	
	func updateMinimumComponent() {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			let filteredImage = image.applyingFilter("CIMinimumComponent", withInputParameters: [:])
			view.image = filteredImage
		}
	}
	
	func updatePhotoEffectChrome() {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			let filteredImage = image.applyingFilter("CIPhotoEffectChrome", withInputParameters: [:])
			view.image = filteredImage
		}
	}
	
	func updatePhotoEffectFade() {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			let filteredImage = image.applyingFilter("CIPhotoEffectFade", withInputParameters: [:])
			view.image = filteredImage
		}
	}
	
	func updatePhotoEffectInstant() {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			let filteredImage = image.applyingFilter("CIPhotoEffectInstant", withInputParameters: [:])
			view.image = filteredImage
		}
	}
	
	func updatePhotoEffectMono() {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			let filteredImage = image.applyingFilter("CIPhotoEffectMono", withInputParameters: [:])
			view.image = filteredImage
		}
	}
	
	func updatePhotoEffectNoir() {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			let filteredImage = image.applyingFilter("CIPhotoEffectNoir", withInputParameters: [:])
			view.image = filteredImage
		}
	}
	
	func updatePhotoEffectProcess() {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			let filteredImage = image.applyingFilter("CIPhotoEffectProcess", withInputParameters: [:])
			view.image = filteredImage
		}
	}
	
	func updatePhotoEffectTonal() {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			let filteredImage = image.applyingFilter("CIPhotoEffectTonal", withInputParameters: [:])
			view.image = filteredImage
		}
	}
	
	func updatePhotoEffectTransfer() {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			let filteredImage = image.applyingFilter("CIPhotoEffectTransfer", withInputParameters: [:])
			view.image = filteredImage
		}
	}
	
	func updateSepiaTone(with intensity: Double) {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			let filteredImage = image.applyingFilter("CISepiaTone", withInputParameters: ["inputIntensity": intensity])
			view.image = filteredImage
		}
	}
	
	func updateVignette(with radius: Double, intensity: Double) {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			let filteredImage = image.applyingFilter("CIVignette", withInputParameters: ["inputIntensity": intensity, "inputRadius": radius])
			view.image = filteredImage
		}
	}
	
	func updateVignetteEffect(with radius: Double, intensity: Double, center: CIVector) {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			let filteredImage = image.applyingFilter("CIVignetteEffect", withInputParameters: ["inputIntensity": intensity, "inputRadius": radius, "inputCenter": center])
			view.image = filteredImage
		}
	}
	
	
	@IBAction func showColorEffectPopoverAction(_ sender: NSButton) {
		showColorEffectPopover(id: colorEffectFilterPopUpButton.indexOfSelectedItem)
	}
	
	@IBAction func showColorEffectPopoverActionMenu(_ sender: NSMenuItem) {
		showColorEffectPopover(id: sender.tag)
	}
	
	func showColorEffectPopover(id: Int) {
		switch id {
		case 1:
			self.updateInvertColors()
		case 5:
			self.updateMaskToAlpha()
		case 6:
			self.updateMaximumComponent()
		case 7:
			self.updateMinimumComponent()
		case 8:
			self.updatePhotoEffectChrome()
		case 9:
			self.updatePhotoEffectFade()
		case 10:
			self.updatePhotoEffectInstant()
		case 11:
			self.updatePhotoEffectMono()
		case 12:
			self.updatePhotoEffectNoir()
		case 13:
			self.updatePhotoEffectProcess()
		case 14:
			self.updatePhotoEffectTonal()
		case 15:
			self.updatePhotoEffectTransfer()
		default:
			if id != 0
			{
				self.createColorEffectPopover(popoverViewController: self.colorEffectPopoverControllers[id]!, x: id)
				let targetButton = window!.standardWindowButton(.closeButton)!.superview!
				let prefEdge: NSRectEdge = NSRectEdge.minY
				self.colorEffectPopovers[id]?.show(relativeTo: targetButton.bounds, of: targetButton, preferredEdge: prefEdge)
			}
		}
	}
	
	func createColorEffectPopover(popoverViewController: NSViewController, x: Int) {
		if (self.colorEffectPopovers[x] == nil)
		{
			self.colorEffectPopovers[x] = NSPopover.init()
			self.colorEffectPopovers[x]?.contentViewController = popoverViewController;
			self.colorEffectPopovers[x]?.animates = true
			self.colorEffectPopovers[x]?.appearance = NSAppearance.init(named: NSAppearance.Name.vibrantLight)
			self.colorEffectPopovers[x]?.behavior = NSPopover.Behavior.transient
			self.colorEffectPopovers[x]?.delegate = self
			(self.colorEffectPopovers[x]?.contentViewController as? PopoverViewController)?.windowController = self
		}
	}
	
	func doNothing() {}
	
	override func windowDidLoad() {
		super.windowDidLoad()
		
		// toolbar
		
		self.toolbar.allowsUserCustomization = true
		self.toolbar.autosavesConfiguration = true
		self.toolbar.displayMode = .iconOnly
		
		// popover
		
		for x in 1...6 {
			blurPopoverControllers[x] = self.storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: blurPopoverControllerNames[x] )) as? NSViewController
		}
		
		for x in colorAdjustmentArray {
			colorAdjustmentPopoverControllers[x] = self.storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: colorAdjustmentPopoverControllerNames[x] )) as? NSViewController
		}
		
		for x in colorEffectArray {
			colorEffectPopoverControllers[x] = self.storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: colorEffectPopoverControllerNames[x] )) as? NSViewController
		}
		
		for x in 1...2 {
			sharpenPopoverControllers[x] = self.storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: sharpenPopoverNames[x] )) as? NSViewController
		}
		
		if let viewController = window?.contentViewController as? ViewController {
			viewController.windowController = self
		}
	}
	
	
	func zoom(index: Int) {
		if let view = window?.contentView?.subviews.first as? NSScrollView {
			switch(index) {
			case 0: view.magnification = view.magnification / 1.5
			case 1: view.magnification = view.magnification * 1.5
			default: print("Invalid selection")
			}
		}
	}
	
	func customToolbarItem(itemForItemIdentifier itemIdentifier: String, label: String, paletteLabel: String, toolTip: String, target: AnyObject, itemContent: AnyObject, action: Selector?, menu: NSMenu?) -> NSToolbarItem? {
		
		let toolbarItem = NSToolbarItem(itemIdentifier: NSToolbarItem.Identifier(rawValue: itemIdentifier))
		
		toolbarItem.label = label
		toolbarItem.paletteLabel = paletteLabel
		toolbarItem.toolTip = toolTip
		toolbarItem.target = target
		toolbarItem.action = action
		
		// Set the right attribute, depending on if we were given an image or a view.
		if (itemContent is NSImage) {
			let image: NSImage = itemContent as! NSImage
			toolbarItem.image = image
		}
		else if (itemContent is NSView) {
			let view: NSView = itemContent as! NSView
			toolbarItem.view = view
		}
		else {
			assertionFailure("Invalid selection")
		}
		
		let menuItem: NSMenuItem = NSMenuItem()
		menuItem.submenu = menu
		menuItem.title = label
		toolbarItem.menuFormRepresentation = menuItem
		
		return toolbarItem
	}
	
	func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
		
		var toolbarItem: NSToolbarItem = NSToolbarItem()
		
		if (itemIdentifier == ((ZoomToolbarItemID as NSString) as NSToolbarItem.Identifier)) {
			// 1) Zoom toolbar item.
			toolbarItem = customToolbarItem(itemForItemIdentifier: ZoomToolbarItemID, label: "Zoom", paletteLabel:"Zoom", toolTip: "Change your zoom level", target: self, itemContent: self.zoomControlView, action: nil, menu: nil)!
		} else if (itemIdentifier == ((blurFilterToolbarItemID as NSString) as NSToolbarItem.Identifier)) {
			// 2) Blur filter toolbar item.
			toolbarItem = customToolbarItem(itemForItemIdentifier: blurFilterToolbarItemID, label: "Blur Filter", paletteLabel:"Blur Filter", toolTip: "Apply blur filter to the image", target: self, itemContent: self.blurFilterView, action: nil, menu: nil)!
		} else if (itemIdentifier == ((colorEffectFilterToolbarItemID as NSString) as NSToolbarItem.Identifier)) {
			// 3) Color effect filter toolbar item.
			toolbarItem = customToolbarItem(itemForItemIdentifier: colorEffectFilterToolbarItemID, label: "Color Effect Filter", paletteLabel:"Color Effect Filter", toolTip: "Apply color effect filter to the image", target: self, itemContent: self.colorEffectFilterView, action: nil, menu: nil)!
		} else if (itemIdentifier == ((colorAdjustmentFilterToolbarItemID as NSString) as NSToolbarItem.Identifier)) {
			// 4) Color effect filter toolbar item.
			toolbarItem = customToolbarItem(itemForItemIdentifier: colorAdjustmentFilterToolbarItemID, label: "Color Adjustment Filter", paletteLabel:"Color Adjustment Filter", toolTip: "Apply color adjustment filter to the image", target: self, itemContent: self.colorAdjustmentFilterView, action: nil, menu: nil)!
		} else if (itemIdentifier == ((geometryAdjustToolbarItemID as NSString) as NSToolbarItem.Identifier)) {
			// 5) Geometry adjustment toolbar item.
			toolbarItem = customToolbarItem(itemForItemIdentifier: geometryAdjustToolbarItemID, label: "Geometry Adjustment", paletteLabel:"Geometry Adjustment", toolTip: "Adjust the geometry of the image", target: self, itemContent: self.geometryAdjustmentView, action: nil, menu: nil)!
		} else if (itemIdentifier == ((applyChangesToolbarItemID as NSString) as NSToolbarItem.Identifier)) {
			// 6) Apply changes toolbar item.
			toolbarItem = customToolbarItem(itemForItemIdentifier: applyChangesToolbarItemID, label: "Apply Changes", paletteLabel:"Apply Changes", toolTip: "Apply or discard changes done to the image", target: self, itemContent: self.applyChangesView, action: nil, menu: nil)!
		} else if (itemIdentifier == ((sharpenFilterToolbarItemID as NSString) as NSToolbarItem.Identifier)) {
			// 7) Sharpen filter toolbar item.
			toolbarItem = customToolbarItem(itemForItemIdentifier: sharpenFilterToolbarItemID, label: "Sharpen", paletteLabel:"Sharpen", toolTip: "Sharpen the image", target: self, itemContent: self.sharpenView, action: nil, menu: nil)!
		}
		
		return toolbarItem
	}
	
	func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
		return [NSToolbarItem.Identifier(rawValue: ZoomToolbarItemID),
		        NSToolbarItem.Identifier(rawValue: applyChangesToolbarItemID),
		        NSToolbarItem.Identifier(rawValue: geometryAdjustToolbarItemID),
		        NSToolbarItem.Identifier(rawValue: blurFilterToolbarItemID),
		        NSToolbarItem.Identifier(rawValue: sharpenFilterToolbarItemID),
		        NSToolbarItem.Identifier(rawValue: colorAdjustmentFilterToolbarItemID),
		        NSToolbarItem.Identifier(rawValue: colorEffectFilterToolbarItemID)]
	}
	
	func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
		return [NSToolbarItem.Identifier(rawValue: ZoomToolbarItemID),
		        NSToolbarItem.Identifier(rawValue: applyChangesToolbarItemID),
		        NSToolbarItem.Identifier(rawValue: geometryAdjustToolbarItemID),
		        NSToolbarItem.Identifier(rawValue: blurFilterToolbarItemID),
		        NSToolbarItem.Identifier(rawValue: sharpenFilterToolbarItemID),
		        NSToolbarItem.Identifier(rawValue: colorAdjustmentFilterToolbarItemID),
		        NSToolbarItem.Identifier(rawValue: colorEffectFilterToolbarItemID),
		        NSToolbarItem.Identifier.space,
		        NSToolbarItem.Identifier.flexibleSpace,
		        NSToolbarItem.Identifier.showColors]
	}
	
	func popoverShouldDetach(_ popover: NSPopover) -> Bool {
		return true
	}
	
}
