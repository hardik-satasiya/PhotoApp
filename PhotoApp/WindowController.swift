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
	let ciContext = CIContext()
	
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
	let distortionFilterToolbarItemID = "Distortion"
	let stylizeToolbarItemID = "Stylize"
	
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
	@IBAction func applyChangesToolbar(_ sender: NSSegmentedControl) {
		applyChanges(index: sender.selectedSegment)
	}
	@IBOutlet weak var applyChangesButtons: NSSegmentedControl!
	
	@IBOutlet weak var applyChangesButton: NSSegmentedCell!
	
	@IBAction func applyChangesMenu(_ sender: NSMenuItem) {
		applyChanges(index: sender.tag)
	}
	
	func applyChanges(index: Int) {
		if let view = window?.contentViewController as? ViewController,
			let _ = originalCIImage {
			switch index {
			case 0:
				originalCIImage = view.image
			case 1:
				view.image = originalCIImage
			default:
				assertionFailure("Failed to apply changes")
			}
			setApplyState(state: false)
		}
	}
	
	func setApplyState(state: Bool) {
		if state {
			applyChangesButton.setImage(NSImage(named: NSImage.Name(rawValue: "CheckMarkColored")), forSegment: 0)
			applyChangesButton.setImage(NSImage(named: NSImage.Name(rawValue: "CrossMarkColored")), forSegment: 1)
		}
		if !state {
			applyChangesButton.setImage(NSImage(named: NSImage.Name(rawValue: "CheckMark")), forSegment: 0)
			applyChangesButton.setImage(NSImage(named: NSImage.Name(rawValue: "CrossMark")), forSegment: 1)
		}
		applyChangesButton.setEnabled(state, forSegment: 0)
		applyChangesButton.setEnabled(state, forSegment: 1)
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
			var filteredImage = image.applyingFilter("CIBoxBlur", parameters: ["inputRadius": boxRadius])
			filteredImage = filteredImage.cropped(to: image.extent)
			view.image = filteredImage
			setApplyState(state: true)
		}
	}
	
	func updateDiscBlur(with discRadius: Double) {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			//Crashes with values 0...1 radar 33770007
			var filteredImage = image.applyingFilter("CIDiscBlur", parameters: ["inputRadius": discRadius])
			filteredImage = filteredImage.cropped(to: image.extent)
			view.image = filteredImage
			setApplyState(state: true)
		}
	}
	
	func updateGaussianBlur(with sigma: Double) {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			var filteredImage = image.applyingFilter("CIGaussianBlur", parameters: ["inputRadius": sigma])
			filteredImage = filteredImage.cropped(to: image.extent)
			view.image = filteredImage
			setApplyState(state: true)
		}
	}
	
	func updateMaskedVariableBlur(with radius: Double) {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			var filteredImage = image.applyingFilter("CIMaskedVariableBlur", parameters: ["inputRadius": radius])
			filteredImage = filteredImage.cropped(to: image.extent)
			view.image = filteredImage
			setApplyState(state: true)
		}
	}
	
	func updateMedianFilter() {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			var filteredImage = image.applyingFilter("CIMedianFilter", parameters: [:])
			filteredImage = filteredImage.cropped(to: image.extent)
			view.image = filteredImage
			setApplyState(state: true)
		}
	}
	
	func updateMotionBlur(with motionRadius: Double, motionAngle: Double) {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			var filteredImage = image.applyingFilter("CIMotionBlur", parameters: ["inputRadius": motionRadius, "inputAngle": motionAngle])
			filteredImage = filteredImage.cropped(to: image.extent)
			view.image = filteredImage
			setApplyState(state: true)
		}
	}
	
	func updateNoiseReduction(with noiseLevel: Double, sharpness: Double) {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			var filteredImage = image.applyingFilter("CINoiseReduction", parameters: ["inputNoiseLevel": noiseLevel, "inputSharpness": sharpness])
			filteredImage = filteredImage.cropped(to: image.extent)
			view.image = filteredImage
			setApplyState(state: true)
		}
	}
	
	func updateZoomBlur(with amount: Double, center: CIVector) {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			var filteredImage = image.applyingFilter("CIZoomBlur", parameters: ["inputAmount": amount, "inputCenter": center])
			filteredImage = filteredImage.cropped(to: image.extent)
			view.image = filteredImage
			setApplyState(state: true)
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
			blurPopovers[id] = nil
			blurPopoverControllers[id] = nil
			blurPopoverControllers[id] = self.storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: blurPopoverControllerNames[id] )) as? NSViewController
			self.createBlurPopover(popoverViewController: self.blurPopoverControllers[id]!, x: id)
			let prefEdge: NSRectEdge = NSRectEdge.minY
			let targetButton = window!.standardWindowButton(.closeButton)!.superview!
			self.blurPopovers[id]?.show(relativeTo: targetButton.bounds , of: targetButton, preferredEdge: prefEdge)
			callBlurUpdate(id: id)
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
	
	func callBlurUpdate(id: Int) {
			switch id {
			case 1:
				updateBoxBlur(with: 10.0)
			case 2:
				updateDiscBlur(with: 10.0)
			case 3:
				updateGaussianBlur(with: 10.0)
			case 4:
				updateMotionBlur(with: 10.0, motionAngle: 0.0)
			case 5:
				updateNoiseReduction(with: 0.2, sharpness: 1.0)
			default:
				self.doNothing()
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
			var filteredImage = image.applyingFilter("CIColorControls", parameters: ["inputSaturation": saturation, "inputBrightness": brightness, "inputContrast": contrast])
			filteredImage = filteredImage.cropped(to: image.extent)
			view.image = filteredImage
			setApplyState(state: true)
		}
	}
	
	func updateExposureAdjust(with ev: Double) {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			var filteredImage = image.applyingFilter("CIExposureAdjust", parameters: ["inputEV": ev])
			filteredImage = filteredImage.cropped(to: image.extent)
			view.image = filteredImage
			setApplyState(state: true)
		}
	}
	
	func updateGammaAdjust(with power: Double) {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			var filteredImage = image.applyingFilter("CIGammaAdjust", parameters: ["inputPower": power])
			filteredImage = filteredImage.cropped(to: image.extent)
			view.image = filteredImage
			setApplyState(state: true)
		}
	}
	
	func updateHueAdjust(with angle: Double) {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			var filteredImage = image.applyingFilter("CIHueAdjust", parameters: ["inputAngle": angle])
			filteredImage = filteredImage.cropped(to: image.extent)
			view.image = filteredImage
			setApplyState(state: true)
		}
	}
	
	func updateLinearToSRGBFilter() {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			var filteredImage = image.applyingFilter("CILinearToSRGBToneCurve", parameters: [:])
			filteredImage = filteredImage.cropped(to: image.extent)
			view.image = filteredImage
			setApplyState(state: true)
		}
	}
	
	func updateSRGBToLinearFilter() {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			var filteredImage = image.applyingFilter("CISRGBToneCurveToLinear", parameters: [:])
			filteredImage = filteredImage.cropped(to: image.extent)
			view.image = filteredImage
			setApplyState(state: true)
		}
	}
	
	func updateTemperatureAndTint(with temperature: CGFloat, tint: CGFloat) {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			var filteredImage = image.applyingFilter("CITemperatureAndTint", parameters: ["inputNeutral": CIVector(x: 13000.0 - temperature, y: tint), "inputTargetNeutral": CIVector(x: 6500.0, y: 0.0)])
			filteredImage = filteredImage.cropped(to: image.extent)
			view.image = filteredImage
			setApplyState(state: true)
		}
	}
	
	func updateVibranceAdjust(with vibrance: Double) {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			var filteredImage = image.applyingFilter("CIVibrance", parameters: ["inputAmount": vibrance])
			filteredImage = filteredImage.cropped(to: image.extent)
			view.image = filteredImage
			setApplyState(state: true)
		}
	}
	
	func updateWhitePointAdjust(with whitePoint: CIColor) {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			var filteredImage = image.applyingFilter("CIWhitePointAdjust", parameters: ["inputColor": whitePoint])
			filteredImage = filteredImage.cropped(to: image.extent)
			view.image = filteredImage
			setApplyState(state: true)
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
				colorAdjustmentPopovers[id] = nil
				colorAdjustmentPopoverControllers[id] = nil
				colorAdjustmentPopoverControllers[id] = self.storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: colorAdjustmentPopoverControllerNames[id] )) as? NSViewController
				self.createColorAdjustmentPopover(popoverViewController: self.colorAdjustmentPopoverControllers[id]!, x: id)
				let targetButton = window!.standardWindowButton(.closeButton)!.superview!
				let prefEdge: NSRectEdge = NSRectEdge.minY
				self.colorAdjustmentPopovers[id]?.show(relativeTo: targetButton.bounds, of: targetButton, preferredEdge: prefEdge)
				callColorAdjustmentUpdate(id: id)
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
	
	func callColorAdjustmentUpdate(id: Int) {
		switch id {
		case 1:
			updateColorControls(with: 2.0, brightness: 0.25, contrast: 1.5)
		case 2:
			updateExposureAdjust(with: 1.0)
		case 3:
			updateGammaAdjust(with: 0.5)
		case 4:
			updateHueAdjust(with: 1.57079633)
		case 7:
			updateTemperatureAndTint(with: 3500.0, tint: 0.0)
		case 8:
			updateVibranceAdjust(with: 0.5)
		case 9:
			updateWhitePointAdjust(with: CIColor(red: 255 / 256, green: 255 / 256, blue: 200/256))
		default:
			self.doNothing()
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
			var filteredImage = image.applyingFilter("CISharpenLuminance", parameters: ["inputSharpness": sharpness])
			filteredImage = filteredImage.cropped(to: image.extent)
			view.image = filteredImage
			setApplyState(state: true)
		}
	}
	
	func updateUnsharpMask(with radius: Double, intensity: Double) {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			var filteredImage = image.applyingFilter("CIUnsharpMask", parameters: ["inputRadius": radius, "inputIntensity": intensity])
			filteredImage = filteredImage.cropped(to: image.extent)
			view.image = filteredImage
			setApplyState(state: true)
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
			sharpenPopovers[id] = nil
			sharpenPopoverControllers[id] = nil
			sharpenPopoverControllers[id] = self.storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: sharpenPopoverNames[id] )) as? NSViewController
			self.createSharpenPopover(popoverViewController: self.sharpenPopoverControllers[id]!, x: id)
			let prefEdge: NSRectEdge = NSRectEdge.minY
			let targetButton = window!.standardWindowButton(.closeButton)!.superview!
			self.sharpenPopovers[id]?.show(relativeTo: targetButton.bounds , of: targetButton, preferredEdge: prefEdge)
			callSharpenUpdate(id: id)
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
	
	func callSharpenUpdate(id: Int) {
		switch id {
		case 1:
			self.updateSharpenLuminance(with: 0.5)
		case 2:
			self.updateUnsharpMask(with: 0.5, intensity: 0.5)
		default:
			self.doNothing()
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
				self.updateMirror(orientation: CGImagePropertyOrientation.upMirrored)
			case 1:
				self.updateMirror(orientation: CGImagePropertyOrientation.downMirrored)
            default:
                self.doNothing()
            }
        }
    }
    
	
	func updateCrop(with rectangle: CGRect) {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			var offsetRect = rectangle
			offsetRect.origin.x += image.extent.origin.x
			offsetRect.origin.y += image.extent.origin.y
			let filteredImage = image.applyingFilter("CICrop", parameters: ["inputRectangle": CIVector(cgRect: offsetRect)])
			view.image = filteredImage
			setApplyState(state: true)
		}
	}
	
	func updateRotation(with angle: CGFloat) {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			let filteredImage = image.applyingFilter("CIStraightenFilter", parameters: ["inputAngle": angle])
			view.image = filteredImage
			setApplyState(state: true)
		}
	}
	
	func updateMirror(orientation: CGImagePropertyOrientation) {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			let filteredImage = image.oriented(orientation)
			view.image = filteredImage
			setApplyState(state: true)
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
			var filteredImage = image.applyingFilter("CIColorInvert", parameters: [:])
			filteredImage = filteredImage.cropped(to: image.extent)
			view.image = filteredImage
			setApplyState(state: true)
		}
	}
	
	func updateMonochromeAdjust(with color: CIColor, intensity: Double) {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			var filteredImage = image.applyingFilter("CIColorMonochrome", parameters: ["inputColor": color, "inputIntensity": intensity])
			filteredImage = filteredImage.cropped(to: image.extent)
			view.image = filteredImage
			setApplyState(state: true)
		}
	}
	
	func updatePosterize(with levels: Double) {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			var filteredImage = image.applyingFilter("CIColorPosterize", parameters: ["inputLevels": levels])
			filteredImage = filteredImage.cropped(to: image.extent)
			view.image = filteredImage
			setApplyState(state: true)
		}
	}
	
	func updateFalseColor(with color0: CIColor, color1: CIColor) {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			var filteredImage = image.applyingFilter("CIFalseColor", parameters: ["inputColor0": color0, "inputColor1": color1])
			filteredImage = filteredImage.cropped(to: image.extent)
			view.image = filteredImage
			setApplyState(state: true)
		}
	}
	
	func updateMaskToAlpha() {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			var filteredImage = image.applyingFilter("CIMaskToAlpha", parameters: [:])
			filteredImage = filteredImage.cropped(to: image.extent)
			view.image = filteredImage
			setApplyState(state: true)
		}
	}
	
	func updateMaximumComponent() {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			var filteredImage = image.applyingFilter("CIMaximumComponent", parameters: [:])
			filteredImage = filteredImage.cropped(to: image.extent)
			view.image = filteredImage
			setApplyState(state: true)
		}
	}
	
	func updateMinimumComponent() {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			var filteredImage = image.applyingFilter("CIMinimumComponent", parameters: [:])
			filteredImage = filteredImage.cropped(to: image.extent)
			view.image = filteredImage
			setApplyState(state: true)
		}
	}
	
	func updatePhotoEffectChrome() {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			var filteredImage = image.applyingFilter("CIPhotoEffectChrome", parameters: [:])
			filteredImage = filteredImage.cropped(to: image.extent)
			view.image = filteredImage
			setApplyState(state: true)
		}
	}
	
	func updatePhotoEffectFade() {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			var filteredImage = image.applyingFilter("CIPhotoEffectFade", parameters: [:])
			filteredImage = filteredImage.cropped(to: image.extent)
			view.image = filteredImage
			setApplyState(state: true)
		}
	}
	
	func updatePhotoEffectInstant() {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			var filteredImage = image.applyingFilter("CIPhotoEffectInstant", parameters: [:])
			filteredImage = filteredImage.cropped(to: image.extent)
			view.image = filteredImage
			setApplyState(state: true)
		}
	}
	
	func updatePhotoEffectMono() {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			var filteredImage = image.applyingFilter("CIPhotoEffectMono", parameters: [:])
			filteredImage = filteredImage.cropped(to: image.extent)
			view.image = filteredImage
			setApplyState(state: true)
		}
	}
	
	func updatePhotoEffectNoir() {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			var filteredImage = image.applyingFilter("CIPhotoEffectNoir", parameters: [:])
			filteredImage = filteredImage.cropped(to: image.extent)
			view.image = filteredImage
			setApplyState(state: true)
		}
	}
	
	func updatePhotoEffectProcess() {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			var filteredImage = image.applyingFilter("CIPhotoEffectProcess", parameters: [:])
			filteredImage = filteredImage.cropped(to: image.extent)
			view.image = filteredImage
			setApplyState(state: true)
		}
	}
	
	func updatePhotoEffectTonal() {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			var filteredImage = image.applyingFilter("CIPhotoEffectTonal", parameters: [:])
			filteredImage = filteredImage.cropped(to: image.extent)
			view.image = filteredImage
			setApplyState(state: true)
		}
	}
	
	func updatePhotoEffectTransfer() {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			var filteredImage = image.applyingFilter("CIPhotoEffectTransfer", parameters: [:])
			filteredImage = filteredImage.cropped(to: image.extent)
			view.image = filteredImage
			setApplyState(state: true)
		}
	}
	
	func updateSepiaTone(with intensity: Double) {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			var filteredImage = image.applyingFilter("CISepiaTone", parameters: ["inputIntensity": intensity])
			filteredImage = filteredImage.cropped(to: image.extent)
			view.image = filteredImage
			setApplyState(state: true)
		}
	}
	
	func updateVignette(with radius: Double, intensity: Double) {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			var filteredImage = image.applyingFilter("CIVignette", parameters: ["inputIntensity": intensity, "inputRadius": radius])
			filteredImage = filteredImage.cropped(to: image.extent)
			view.image = filteredImage
			setApplyState(state: true)
		}
	}
	
	func updateVignetteEffect(with radius: Double, intensity: Double, center: CIVector) {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			var filteredImage = image.applyingFilter("CIVignetteEffect", parameters: ["inputIntensity": intensity, "inputRadius": radius, "inputCenter": center])
			filteredImage = filteredImage.cropped(to: image.extent)
			view.image = filteredImage
			setApplyState(state: true)
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
				colorEffectPopovers[id] = nil
				colorEffectPopoverControllers[id] = nil
				colorEffectPopoverControllers[id] = self.storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: colorEffectPopoverControllerNames[id] )) as? NSViewController
				self.createColorEffectPopover(popoverViewController: self.colorEffectPopoverControllers[id]!, x: id)
				let targetButton = window!.standardWindowButton(.closeButton)!.superview!
				let prefEdge: NSRectEdge = NSRectEdge.minY
				self.colorEffectPopovers[id]?.show(relativeTo: targetButton.bounds, of: targetButton, preferredEdge: prefEdge)
				self.callColorEffectUpdate(id: id)
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
	
	func callColorEffectUpdate(id: Int) {
			switch id {
			case 2:
				updateMonochromeAdjust(with: CIColor(red: 200 / 256, green: 255 / 256, blue: 255 / 256), intensity: 1.0)
			case 3:
				updatePosterize(with: 20.0)
			case 4:
				updateFalseColor(with: CIColor(red: 0.0, green: 0.0, blue: 100 / 256), color1: CIColor(red: 255 / 256, green: 200 / 256, blue: 255 / 256))
			case 16:
				updateSepiaTone(with: 0.5)
			default:
				self.doNothing()
			}
//		}
	}
	
	
	//-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
	//  distortion effect filter and toolbar item
	//-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
	
	@IBOutlet var distortionEffectFilterView: NSView!
	@IBOutlet weak var distortionEffectFilterPopUpButton: NSPopUpButton!
	var distortionEffectPopovers: [NSPopover?] = [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]
	var distortionEffectPopoverControllerNames: [String] = ["", "BumpDistortionPopoverViewController", "BumpDistortionLinearPopoverViewController", "CircleSplashDistortionPopoverViewController", "CircularWrapPopoverVIewController", "GlassDistortionPopoverViewController", "HoleDistortionPopoverViewController", "LightTunnelPopoverViewController", "PinchDistortionPopoverViewController", "StretchCropPopoverViewController", "TorusLensDistortionPopoverViewController", "TwirlDistortionPopoverViewController", "VortexDistortionPopoverViewController"]
	var distortionEffectArray: [Int] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
	var distortionEffectPopoverControllers: [NSViewController?] = [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]
	
	// labai daug funkciju
	
	func updateBumpDistortion(with x: CGFloat, y: CGFloat, radius: Double, scale: Double) {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			var filteredImage = image.applyingFilter("CIBumpDistortion", parameters: ["inputCenter": CIVector(x: x, y: y), "inputRadius": radius, "inputScale": scale])
			filteredImage = filteredImage.cropped(to: image.extent)
			view.image = filteredImage
			setApplyState(state: true)
		}
	}
	
	func updateBumpDistortionLinear(with x: CGFloat, y: CGFloat, radius: Double, angle: Double, scale: Double) {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			var filteredImage = image.applyingFilter("CIBumpDistortionLinear", parameters: ["inputCenter": CIVector(x: x, y: y), "inputRadius": radius, "inputAngle": angle, "inputScale": scale])
			filteredImage = filteredImage.cropped(to: image.extent)
			view.image = filteredImage
			setApplyState(state: true)
		}
	}
	
	func updateCircleSplashDistortion(with x: CGFloat, y: CGFloat, radius: Double) {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			var filteredImage = image.applyingFilter("CICircleSplashDistortion", parameters: ["inputCenter": CIVector(x: x, y: y), "inputRadius": radius])
			filteredImage = filteredImage.cropped(to: image.extent)
			view.image = filteredImage
			setApplyState(state: true)
		}
	}
	
	func updateCircularWrap(with x: CGFloat, y: CGFloat, radius: Double, angle: Double) {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			var filteredImage = image.applyingFilter("CICircularWrap", parameters: ["inputCenter": CIVector(x: x, y: y), "inputRadius": radius, "inputAngle": angle])
			filteredImage = filteredImage.cropped(to: image.extent)
			view.image = filteredImage
			setApplyState(state: true)
		}
	}
	
	func updateGlassDistortion(with x: CGFloat, y: CGFloat, scale: Double) {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			let nsImage = NSImage(named: NSImage.Name(rawValue: "glassTexture"))
			let imageData = nsImage!.tiffRepresentation!
			let ciImage = CIImage(data: imageData)
			
			var filteredImage = image.applyingFilter("CIGlassDistortion", parameters: ["inputCenter": CIVector(x: x, y: y), "inputScale": scale, "inputTexture": ciImage!])
			filteredImage = filteredImage.cropped(to: image.extent)
			view.image = filteredImage
			setApplyState(state: true)
		}
	}
	
	func updateHoleDistortion(with x: CGFloat, y: CGFloat, radius: Double) {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			var filteredImage = image.applyingFilter("CIHoleDistortion", parameters: ["inputCenter": CIVector(x: x, y: y), "inputRadius": radius])
			filteredImage = filteredImage.cropped(to: image.extent)
			view.image = filteredImage
			setApplyState(state: true)
		}
	}
	
	func updateLightTunnel(with x: CGFloat, y: CGFloat, radius: Double, rotation: Double) {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			var filteredImage = image.applyingFilter("CILightTunnel", parameters: ["inputCenter": CIVector(x: x, y: y), "inputRadius": radius, "inputRotation": rotation])
			filteredImage = filteredImage.cropped(to: image.extent)
			view.image = filteredImage
			setApplyState(state: true)
		}
	}
	
	func updatePinchDistortion(with x: CGFloat, y: CGFloat, radius: Double, scale: Double) {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			var filteredImage = image.applyingFilter("CIPinchDistortion", parameters: ["inputCenter": CIVector(x: x, y: y), "inputRadius": radius, "inputScale": scale])
			filteredImage = filteredImage.cropped(to: image.extent)
			view.image = filteredImage
			setApplyState(state: true)
		}
	}
	
	func updateStretchCrop(with width: CGFloat, height: CGFloat, cropAmount: Double, centerStretchAmount: Double) {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			let filteredImage = image.applyingFilter("CIStretchCrop", parameters: ["inputSize": CIVector(x: width, y: height), "inputCropAmount": cropAmount, "inputCenterStretchAmount": centerStretchAmount])
			view.image = filteredImage
			setApplyState(state: true)
		}
	}
	
	func updateTorusLensDistortion(with x: CGFloat, y: CGFloat, radius: Double, width: Double, refraction: Double) {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			var filteredImage = image.applyingFilter("CITorusLensDistortion", parameters: ["inputCenter": CIVector(x: x, y: y), "inputRadius": radius, "inputWidth": width, "inputRefraction": refraction])
			filteredImage = filteredImage.cropped(to: image.extent)
			view.image = filteredImage
			setApplyState(state: true)
		}
	}
	
	func updateTwirlDistortion(with x: CGFloat, y: CGFloat, radius: Double, angle: Double) {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			var filteredImage = image.applyingFilter("CITwirlDistortion", parameters: ["inputCenter": CIVector(x: x, y: y), "inputRadius": radius, "inputAngle": angle])
			filteredImage = filteredImage.cropped(to: image.extent)
			view.image = filteredImage
			setApplyState(state: true)
		}
	}
	
	func updateVortexDistortion(with x: CGFloat, y: CGFloat, radius: Double, angle: Double) {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			var filteredImage = image.applyingFilter("CIVortexDistortion", parameters: ["inputCenter": CIVector(x: x, y: y), "inputRadius": radius, "inputAngle": angle])
			filteredImage = filteredImage.cropped(to: image.extent)
			view.image = filteredImage
			setApplyState(state: true)
		}
	}
	
	
	@IBAction func showDistortionEffectPopoverAction(_ sender: NSButton) {
		showDistortionEffectPopover(id: distortionEffectFilterPopUpButton.indexOfSelectedItem)
	}
	
	@IBAction func showDistortionEffectPopoverActionMenu(_ sender: NSMenuItem) {
		showDistortionEffectPopover(id: sender.tag)
	}
	
	func showDistortionEffectPopover(id: Int) {
		if id != 0
		{
			distortionEffectPopovers[id] = nil
			distortionEffectPopoverControllers[id] = nil
			distortionEffectPopoverControllers[id] = self.storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: distortionEffectPopoverControllerNames[id] )) as? NSViewController
			self.createDistortionEffectPopover(popoverViewController: self.distortionEffectPopoverControllers[id]!, x: id)
			let targetButton = window!.standardWindowButton(.closeButton)!.superview!
			let prefEdge: NSRectEdge = NSRectEdge.minY
			self.distortionEffectPopovers[id]?.show(relativeTo: targetButton.bounds, of: targetButton, preferredEdge: prefEdge)
			callDistortionUpdate(id: id)
		}
	}
	
	func createDistortionEffectPopover(popoverViewController: NSViewController, x: Int) {
		if (self.distortionEffectPopovers[x] == nil)
		{
			self.distortionEffectPopovers[x] = NSPopover.init()
			self.distortionEffectPopovers[x]?.contentViewController = popoverViewController;
			self.distortionEffectPopovers[x]?.animates = true
			self.distortionEffectPopovers[x]?.appearance = NSAppearance.init(named: NSAppearance.Name.vibrantLight)
			self.distortionEffectPopovers[x]?.behavior = NSPopover.Behavior.transient
			self.distortionEffectPopovers[x]?.delegate = self
			(self.distortionEffectPopovers[x]?.contentViewController as? PopoverViewController)?.windowController = self
		}
	}
	
	func callDistortionUpdate(id: Int) {
			switch id {
			case 5:
				updateGlassDistortion(with: 0.0, y: 0.0, scale: 75.0)
			default:
				self.doNothing()
		}
	}
	
	//-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
	//  stylize filter and toolbar item
	//-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
	
	@IBOutlet var stylizeFilterView: NSView!
	@IBOutlet weak var stylizeFilterPopUpButton: NSPopUpButton!
	var stylizePopovers: [NSPopover?] = [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]
	var stylizePopoverControllerNames: [String] = ["", "BloomPopoverViewController", "", "CrystallizePopoverViewController", "EdgesPopoverViewController", "EdgeWorkPopoverViewController", "GloomPopoverViewController", "HeightFieldFromMaskPopoverViewController", "HexagonalPixellatePopoverViewController", "HighlightShadowAdjustPopoverViewController", "LineOverlayPopoverViewController", "PixellatePopoverViewController", "PointillizePopoverViewController"]
	var stylizeArray: [Int] = [1, 3, 4, 5, 6, 7 ,8 ,9 , 10, 11, 12]
	var stylizePopoverControllers: [NSViewController?] = [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]
	
	// daug funkciju
	
	
	func updateBloom(with radius: Double, intensity: Double) {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			var filteredImage = image.applyingFilter("CIBloom", parameters: ["inputRadius": radius, "inputIntensity": intensity])
			filteredImage = filteredImage.cropped(to: image.extent)
			view.image = filteredImage
			setApplyState(state: true)
		}
	}
	
	func updateComicEffect() {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			var filteredImage = image.applyingFilter("CIComicEffect", parameters: [:])
			filteredImage = filteredImage.cropped(to: image.extent)
			view.image = filteredImage
			setApplyState(state: true)
		}
	}
	
	func updateCrystallize(with x: CGFloat, y: CGFloat, radius: Double) {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			var filteredImage = image.applyingFilter("CICrystallize", parameters: ["inputCenter": CIVector(x: x, y: y), "inputRadius": radius])
			filteredImage = filteredImage.cropped(to: image.extent)
			view.image = filteredImage
			setApplyState(state: true)
		}
	}
	
	func updateEdges(with intensity: Double) {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			var filteredImage = image.applyingFilter("CIEdges", parameters: ["inputIntensity": intensity])
			filteredImage = filteredImage.cropped(to: image.extent)
			view.image = filteredImage
			setApplyState(state: true)
		}
	}
	
	func updateEdgeWork(with radius: Double) {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			var filteredImage = image.applyingFilter("CIEdgeWork", parameters: ["inputRadius": radius])
			filteredImage = filteredImage.cropped(to: image.extent)
			view.image = filteredImage
			setApplyState(state: true)
		}
	}
	
	func updateGloom(with radius: Double, intensity: Double) {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			var filteredImage = image.applyingFilter("CIGloom", parameters: ["inputRadius": radius, "inputIntensity": intensity])
			filteredImage = filteredImage.cropped(to: image.extent)
			view.image = filteredImage
			setApplyState(state: true)
		}
	}
	
	func updateHeightFieldFromMask(with radius: Double) {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			var filteredImage = image.applyingFilter("CIHeightFieldFromMask", parameters: ["inputRadius": radius])
			filteredImage = filteredImage.cropped(to: image.extent)
			view.image = filteredImage
			setApplyState(state: true)
		}
	}
	
	func updateHexagonalPixellate(with x: CGFloat, y: CGFloat, scale: Double) {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			var filteredImage = image.applyingFilter("CIHexagonalPixellate", parameters: ["inputCenter": CIVector(x: x, y: y), "inputScale": scale])
			filteredImage = filteredImage.cropped(to: image.extent)
			view.image = filteredImage
			setApplyState(state: true)
		}
	}
	
	func updateHighlightShadow(with highlight: Double, shadow: Double) {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			var filteredImage = image.applyingFilter("CIHighlightShadowAdjust", parameters: ["inputHighlightAmount": highlight, "inputShadowAmount": shadow])
			filteredImage = filteredImage.cropped(to: image.extent)
			view.image = filteredImage
			setApplyState(state: true)
		}
	}
	
	func updateLineOverlay(with NRNoiseLevel: Double, NRSharpness: Double, edgeIntensity: Double, threshold: Double, contrast: Double) {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			var filteredImage = image.applyingFilter("CILineOverlay", parameters: ["inputNRNoiseLevel": NRNoiseLevel, "inputNRSharpness": NRSharpness, "inputEdgeIntensity": edgeIntensity, "inputThreshold": threshold, "inputContrast": contrast])
			filteredImage = filteredImage.cropped(to: image.extent)
			view.image = filteredImage
			setApplyState(state: true)
		}
	}
	
	func updatePixellate(with x: CGFloat, y: CGFloat, scale: Double) {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			var filteredImage = image.applyingFilter("CIPixellate", parameters: ["inputCenter": CIVector(x: x, y: y), "inputScale": scale])
			filteredImage = filteredImage.cropped(to: image.extent)
			view.image = filteredImage
			setApplyState(state: true)
		}
	}
	
	func updatePointillize(with x: CGFloat, y: CGFloat, radius: Double) {
		if let view = window?.contentViewController as? ViewController,
			let image = originalCIImage {
			var filteredImage = image.applyingFilter("CIPointillize", parameters: ["inputCenter": CIVector(x: x, y: y), "inputRadius": radius])
			filteredImage = filteredImage.cropped(to: image.extent)
			view.image = filteredImage
			setApplyState(state: true)
		}
	}
	
	@IBAction func showStylizePopoverAction(_ sender: NSButton) {
		showStylizePopover(id: stylizeFilterPopUpButton.indexOfSelectedItem)
	}
	
	@IBAction func showStylizePopoverActionMenu(_ sender: NSMenuItem) {
		showStylizePopover(id: sender.tag)
	}
	
	func showStylizePopover(id: Int) {
		switch id {
		case 2:
			self.updateComicEffect()
		default:
			if id != 0
			{
				stylizePopovers[id] = nil
				stylizePopoverControllers[id] = nil
				stylizePopoverControllers[id] = self.storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: stylizePopoverControllerNames[id])) as? NSViewController
				self.createStylizePopover(popoverViewController: self.stylizePopoverControllers[id]!, x: id)
				let targetButton = window!.standardWindowButton(.closeButton)!.superview!
				let prefEdge: NSRectEdge = NSRectEdge.minY
				self.stylizePopovers[id]?.show(relativeTo: targetButton.bounds, of: targetButton, preferredEdge: prefEdge)
				callStylizeUpdate(id: id)
			}
		}
	}
	
	func createStylizePopover(popoverViewController: NSViewController, x: Int) {
		if (self.stylizePopovers[x] == nil)
		{
			self.stylizePopovers[x] = NSPopover.init()
			self.stylizePopovers[x]?.contentViewController = popoverViewController;
			self.stylizePopovers[x]?.animates = true
			self.stylizePopovers[x]?.appearance = NSAppearance.init(named: NSAppearance.Name.vibrantLight)
			self.stylizePopovers[x]?.behavior = NSPopover.Behavior.transient
			self.stylizePopovers[x]?.delegate = self
			(self.stylizePopovers[x]?.contentViewController as? PopoverViewController)?.windowController = self
		}
	}
	
	func callStylizeUpdate(id: Int) {
			switch id {
			case 1:
				updateBloom(with: 20.0, intensity: 0.5)
			case 4:
				updateEdges(with: 10.0)
			case 5:
				updateEdgeWork(with: 2.0)
			case 6:
				updateGloom(with: 25.0, intensity: 0.5)
			case 7:
				updateHeightFieldFromMask(with: 25.0)
			case 9:
				updateHighlightShadow(with: 0.5, shadow: -0.3)
			case 10:
				updateLineOverlay(with: 0.01, NRSharpness: 3, edgeIntensity: 2, threshold: 1.5, contrast: 0.25)
			default:
				self.doNothing()
			}
	}
	
	func doNothing() {}
	
	override func windowDidLoad() {
		super.windowDidLoad()
		
		// toolbar
		
		setApplyState(state: false)
		self.toolbar.allowsUserCustomization = true
		self.toolbar.autosavesConfiguration = true
		self.toolbar.displayMode = .iconOnly
		
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
		} else if (itemIdentifier == ((distortionFilterToolbarItemID as NSString) as NSToolbarItem.Identifier)) {
			// 8) Distortion toolbar item.
			toolbarItem = customToolbarItem(itemForItemIdentifier: distortionFilterToolbarItemID, label: "Distortion", paletteLabel:"Distortion", toolTip: "Distort the image", target: self, itemContent: self.distortionEffectFilterView, action: nil, menu: nil)!
		} else if (itemIdentifier == ((stylizeToolbarItemID as NSString) as NSToolbarItem.Identifier)) {
			// 9) Stylize toolbar item.
			toolbarItem = customToolbarItem(itemForItemIdentifier: stylizeToolbarItemID, label: "Stylize", paletteLabel:"Stylize", toolTip: "Stylize the image", target: self, itemContent: self.stylizeFilterView, action: nil, menu: nil)!
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
		        NSToolbarItem.Identifier(rawValue: colorEffectFilterToolbarItemID),
		        NSToolbarItem.Identifier(rawValue: distortionFilterToolbarItemID),
		        NSToolbarItem.Identifier(rawValue: stylizeToolbarItemID)]
	}
	
	func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
		return [NSToolbarItem.Identifier(rawValue: ZoomToolbarItemID),
		        NSToolbarItem.Identifier(rawValue: applyChangesToolbarItemID),
		        NSToolbarItem.Identifier(rawValue: geometryAdjustToolbarItemID),
		        NSToolbarItem.Identifier(rawValue: blurFilterToolbarItemID),
		        NSToolbarItem.Identifier(rawValue: sharpenFilterToolbarItemID),
		        NSToolbarItem.Identifier(rawValue: colorAdjustmentFilterToolbarItemID),
		        NSToolbarItem.Identifier(rawValue: colorEffectFilterToolbarItemID),
		        NSToolbarItem.Identifier(rawValue: distortionFilterToolbarItemID),
		        NSToolbarItem.Identifier(rawValue: stylizeToolbarItemID),
		        NSToolbarItem.Identifier.space,
		        NSToolbarItem.Identifier.flexibleSpace]
	}
	
	func popoverShouldDetach(_ popover: NSPopover) -> Bool {
		return true
	}
	
}
