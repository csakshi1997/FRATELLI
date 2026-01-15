import Foundation
#if canImport(AppKit)
import AppKit
#endif
#if canImport(UIKit)
import UIKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(DeveloperToolsSupport)
import DeveloperToolsSupport
#endif

#if SWIFT_PACKAGE
private let resourceBundle = Foundation.Bundle.module
#else
private class ResourceBundleClass {}
private let resourceBundle = Foundation.Bundle(for: ResourceBundleClass.self)
#endif

// MARK: - Color Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ColorResource {

}

// MARK: - Image Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ImageResource {

    /// The "Controls" asset catalog image resource.
    static let controls = DeveloperToolsSupport.ImageResource(name: "Controls", bundle: resourceBundle)

    /// The "EllipseImg" asset catalog image resource.
    static let ellipseImg = DeveloperToolsSupport.ImageResource(name: "EllipseImg", bundle: resourceBundle)

    /// The "Ellipse_scheme" asset catalog image resource.
    static let ellipseScheme = DeveloperToolsSupport.ImageResource(name: "Ellipse_scheme", bundle: resourceBundle)

    /// The "POSMTabbar" asset catalog image resource.
    static let posmTabbar = DeveloperToolsSupport.ImageResource(name: "POSMTabbar", bundle: resourceBundle)

    /// The "PolygonBtn" asset catalog image resource.
    static let polygonBtn = DeveloperToolsSupport.ImageResource(name: "PolygonBtn", bundle: resourceBundle)

    /// The "addActionItem" asset catalog image resource.
    static let addActionItem = DeveloperToolsSupport.ImageResource(name: "addActionItem", bundle: resourceBundle)

    /// The "addItems" asset catalog image resource.
    static let addItems = DeveloperToolsSupport.ImageResource(name: "addItems", bundle: resourceBundle)

    /// The "addNewContactt" asset catalog image resource.
    static let addNewContactt = DeveloperToolsSupport.ImageResource(name: "addNewContactt", bundle: resourceBundle)

    /// The "addPOSM" asset catalog image resource.
    static let addPOSM = DeveloperToolsSupport.ImageResource(name: "addPOSM", bundle: resourceBundle)

    /// The "addQuantity" asset catalog image resource.
    static let addQuantity = DeveloperToolsSupport.ImageResource(name: "addQuantity", bundle: resourceBundle)

    /// The "arrow" asset catalog image resource.
    static let arrow = DeveloperToolsSupport.ImageResource(name: "arrow", bundle: resourceBundle)

    /// The "back" asset catalog image resource.
    static let back = DeveloperToolsSupport.ImageResource(name: "back", bundle: resourceBundle)

    /// The "backG" asset catalog image resource.
    static let backG = DeveloperToolsSupport.ImageResource(name: "backG", bundle: resourceBundle)

    /// The "backgroundImage" asset catalog image resource.
    static let background = DeveloperToolsSupport.ImageResource(name: "backgroundImage", bundle: resourceBundle)

    /// The "bg" asset catalog image resource.
    static let bg = DeveloperToolsSupport.ImageResource(name: "bg", bundle: resourceBundle)

    /// The "btnIImge" asset catalog image resource.
    static let btnIImge = DeveloperToolsSupport.ImageResource(name: "btnIImge", bundle: resourceBundle)

    /// The "buttonsImage" asset catalog image resource.
    static let buttons = DeveloperToolsSupport.ImageResource(name: "buttonsImage", bundle: resourceBundle)

    /// The "calander-interface-icon-svgrepo-com 1" asset catalog image resource.
    static let calanderInterfaceIconSvgrepoCom1 = DeveloperToolsSupport.ImageResource(name: "calander-interface-icon-svgrepo-com 1", bundle: resourceBundle)

    /// The "cameraPlaceholder" asset catalog image resource.
    static let cameraPlaceholder = DeveloperToolsSupport.ImageResource(name: "cameraPlaceholder", bundle: resourceBundle)

    /// The "cameraVisibility" asset catalog image resource.
    static let cameraVisibility = DeveloperToolsSupport.ImageResource(name: "cameraVisibility", bundle: resourceBundle)

    /// The "check" asset catalog image resource.
    static let check = DeveloperToolsSupport.ImageResource(name: "check", bundle: resourceBundle)

    /// The "checkBox" asset catalog image resource.
    static let checkBox = DeveloperToolsSupport.ImageResource(name: "checkBox", bundle: resourceBundle)

    /// The "contactsTabbar" asset catalog image resource.
    static let contactsTabbar = DeveloperToolsSupport.ImageResource(name: "contactsTabbar", bundle: resourceBundle)

    /// The "customerPromotion" asset catalog image resource.
    static let customerPromotion = DeveloperToolsSupport.ImageResource(name: "customerPromotion", bundle: resourceBundle)

    /// The "date" asset catalog image resource.
    static let date = DeveloperToolsSupport.ImageResource(name: "date", bundle: resourceBundle)

    /// The "decreaseQuantity" asset catalog image resource.
    static let decreaseQuantity = DeveloperToolsSupport.ImageResource(name: "decreaseQuantity", bundle: resourceBundle)

    /// The "direction" asset catalog image resource.
    static let direction = DeveloperToolsSupport.ImageResource(name: "direction", bundle: resourceBundle)

    /// The "done" asset catalog image resource.
    static let done = DeveloperToolsSupport.ImageResource(name: "done", bundle: resourceBundle)

    /// The "dot" asset catalog image resource.
    static let dot = DeveloperToolsSupport.ImageResource(name: "dot", bundle: resourceBundle)

    /// The "dotImg" asset catalog image resource.
    static let dotImg = DeveloperToolsSupport.ImageResource(name: "dotImg", bundle: resourceBundle)

    /// The "editPen" asset catalog image resource.
    static let editPen = DeveloperToolsSupport.ImageResource(name: "editPen", bundle: resourceBundle)

    /// The "generatePIBtn" asset catalog image resource.
    static let generatePIBtn = DeveloperToolsSupport.ImageResource(name: "generatePIBtn", bundle: resourceBundle)

    /// The "homeTabbar" asset catalog image resource.
    static let homeTabbar = DeveloperToolsSupport.ImageResource(name: "homeTabbar", bundle: resourceBundle)

    /// The "imagePicker" asset catalog image resource.
    static let imagePicker = DeveloperToolsSupport.ImageResource(name: "imagePicker", bundle: resourceBundle)

    /// The "launchImage" asset catalog image resource.
    static let launch = DeveloperToolsSupport.ImageResource(name: "launchImage", bundle: resourceBundle)

    /// The "menu_BAr" asset catalog image resource.
    static let menuBAr = DeveloperToolsSupport.ImageResource(name: "menu_BAr", bundle: resourceBundle)

    /// The "nextBtnBox" asset catalog image resource.
    static let nextBtnBox = DeveloperToolsSupport.ImageResource(name: "nextBtnBox", bundle: resourceBundle)

    /// The "noDataFoundImage" asset catalog image resource.
    static let noDataFound = DeveloperToolsSupport.ImageResource(name: "noDataFoundImage", bundle: resourceBundle)

    /// The "ordersTabbar" asset catalog image resource.
    static let ordersTabbar = DeveloperToolsSupport.ImageResource(name: "ordersTabbar", bundle: resourceBundle)

    /// The "outletDivider" asset catalog image resource.
    static let outletDivider = DeveloperToolsSupport.ImageResource(name: "outletDivider", bundle: resourceBundle)

    /// The "outletDividerWhite" asset catalog image resource.
    static let outletDividerWhite = DeveloperToolsSupport.ImageResource(name: "outletDividerWhite", bundle: resourceBundle)

    /// The "previewGrid" asset catalog image resource.
    static let previewGrid = DeveloperToolsSupport.ImageResource(name: "previewGrid", bundle: resourceBundle)

    /// The "previous" asset catalog image resource.
    static let previous = DeveloperToolsSupport.ImageResource(name: "previous", bundle: resourceBundle)

    /// The "progress0" asset catalog image resource.
    static let progress0 = DeveloperToolsSupport.ImageResource(name: "progress0", bundle: resourceBundle)

    /// The "progress1" asset catalog image resource.
    static let progress1 = DeveloperToolsSupport.ImageResource(name: "progress1", bundle: resourceBundle)

    /// The "readMore" asset catalog image resource.
    static let readMore = DeveloperToolsSupport.ImageResource(name: "readMore", bundle: resourceBundle)

    /// The "reload" asset catalog image resource.
    static let reload = DeveloperToolsSupport.ImageResource(name: "reload", bundle: resourceBundle)

    /// The "riskStockSeparation" asset catalog image resource.
    static let riskStockSeparation = DeveloperToolsSupport.ImageResource(name: "riskStockSeparation", bundle: resourceBundle)

    /// The "schemeDropDown" asset catalog image resource.
    static let schemeDropDown = DeveloperToolsSupport.ImageResource(name: "schemeDropDown", bundle: resourceBundle)

    /// The "search" asset catalog image resource.
    static let search = DeveloperToolsSupport.ImageResource(name: "search", bundle: resourceBundle)

    /// The "searchIcon" asset catalog image resource.
    static let searchIcon = DeveloperToolsSupport.ImageResource(name: "searchIcon", bundle: resourceBundle)

    /// The "selected" asset catalog image resource.
    static let selected = DeveloperToolsSupport.ImageResource(name: "selected", bundle: resourceBundle)

    /// The "selectedRadio" asset catalog image resource.
    static let selectedRadio = DeveloperToolsSupport.ImageResource(name: "selectedRadio", bundle: resourceBundle)

    /// The "separation" asset catalog image resource.
    static let separation = DeveloperToolsSupport.ImageResource(name: "separation", bundle: resourceBundle)

    /// The "seprationTbleVw" asset catalog image resource.
    static let seprationTbleVw = DeveloperToolsSupport.ImageResource(name: "seprationTbleVw", bundle: resourceBundle)

    /// The "signInBackgroingImg" asset catalog image resource.
    static let signInBackgroingImg = DeveloperToolsSupport.ImageResource(name: "signInBackgroingImg", bundle: resourceBundle)

    /// The "trash" asset catalog image resource.
    static let trash = DeveloperToolsSupport.ImageResource(name: "trash", bundle: resourceBundle)

    /// The "uncheck" asset catalog image resource.
    static let uncheck = DeveloperToolsSupport.ImageResource(name: "uncheck", bundle: resourceBundle)

    /// The "unselectedRadio" asset catalog image resource.
    static let unselectedRadio = DeveloperToolsSupport.ImageResource(name: "unselectedRadio", bundle: resourceBundle)

    /// The "visitIcon" asset catalog image resource.
    static let visitIcon = DeveloperToolsSupport.ImageResource(name: "visitIcon", bundle: resourceBundle)

    /// The "visitsTabbar" asset catalog image resource.
    static let visitsTabbar = DeveloperToolsSupport.ImageResource(name: "visitsTabbar", bundle: resourceBundle)

    /// The "workingWithOutlet" asset catalog image resource.
    static let workingWithOutlet = DeveloperToolsSupport.ImageResource(name: "workingWithOutlet", bundle: resourceBundle)

}

// MARK: - Color Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

}
#endif

// MARK: - Image Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    /// The "Controls" asset catalog image.
    static var controls: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .controls)
#else
        .init()
#endif
    }

    /// The "EllipseImg" asset catalog image.
    static var ellipseImg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .ellipseImg)
#else
        .init()
#endif
    }

    /// The "Ellipse_scheme" asset catalog image.
    static var ellipseScheme: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .ellipseScheme)
#else
        .init()
#endif
    }

    /// The "POSMTabbar" asset catalog image.
    static var posmTabbar: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .posmTabbar)
#else
        .init()
#endif
    }

    /// The "PolygonBtn" asset catalog image.
    static var polygonBtn: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .polygonBtn)
#else
        .init()
#endif
    }

    /// The "addActionItem" asset catalog image.
    static var addActionItem: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .addActionItem)
#else
        .init()
#endif
    }

    /// The "addItems" asset catalog image.
    static var addItems: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .addItems)
#else
        .init()
#endif
    }

    /// The "addNewContactt" asset catalog image.
    static var addNewContactt: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .addNewContactt)
#else
        .init()
#endif
    }

    /// The "addPOSM" asset catalog image.
    static var addPOSM: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .addPOSM)
#else
        .init()
#endif
    }

    /// The "addQuantity" asset catalog image.
    static var addQuantity: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .addQuantity)
#else
        .init()
#endif
    }

    /// The "arrow" asset catalog image.
    static var arrow: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .arrow)
#else
        .init()
#endif
    }

    /// The "back" asset catalog image.
    static var back: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .back)
#else
        .init()
#endif
    }

    /// The "backG" asset catalog image.
    static var backG: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .backG)
#else
        .init()
#endif
    }

    /// The "backgroundImage" asset catalog image.
    static var background: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .background)
#else
        .init()
#endif
    }

    /// The "bg" asset catalog image.
    static var bg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .bg)
#else
        .init()
#endif
    }

    /// The "btnIImge" asset catalog image.
    static var btnIImge: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .btnIImge)
#else
        .init()
#endif
    }

    /// The "buttonsImage" asset catalog image.
    static var buttons: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .buttons)
#else
        .init()
#endif
    }

    /// The "calander-interface-icon-svgrepo-com 1" asset catalog image.
    static var calanderInterfaceIconSvgrepoCom1: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .calanderInterfaceIconSvgrepoCom1)
#else
        .init()
#endif
    }

    /// The "cameraPlaceholder" asset catalog image.
    static var cameraPlaceholder: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .cameraPlaceholder)
#else
        .init()
#endif
    }

    /// The "cameraVisibility" asset catalog image.
    static var cameraVisibility: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .cameraVisibility)
#else
        .init()
#endif
    }

    /// The "check" asset catalog image.
    static var check: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .check)
#else
        .init()
#endif
    }

    /// The "checkBox" asset catalog image.
    static var checkBox: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .checkBox)
#else
        .init()
#endif
    }

    /// The "contactsTabbar" asset catalog image.
    static var contactsTabbar: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .contactsTabbar)
#else
        .init()
#endif
    }

    /// The "customerPromotion" asset catalog image.
    static var customerPromotion: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .customerPromotion)
#else
        .init()
#endif
    }

    /// The "date" asset catalog image.
    static var date: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .date)
#else
        .init()
#endif
    }

    /// The "decreaseQuantity" asset catalog image.
    static var decreaseQuantity: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .decreaseQuantity)
#else
        .init()
#endif
    }

    /// The "direction" asset catalog image.
    static var direction: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .direction)
#else
        .init()
#endif
    }

    /// The "done" asset catalog image.
    static var done: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .done)
#else
        .init()
#endif
    }

    /// The "dot" asset catalog image.
    static var dot: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .dot)
#else
        .init()
#endif
    }

    /// The "dotImg" asset catalog image.
    static var dotImg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .dotImg)
#else
        .init()
#endif
    }

    /// The "editPen" asset catalog image.
    static var editPen: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .editPen)
#else
        .init()
#endif
    }

    /// The "generatePIBtn" asset catalog image.
    static var generatePIBtn: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .generatePIBtn)
#else
        .init()
#endif
    }

    /// The "homeTabbar" asset catalog image.
    static var homeTabbar: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .homeTabbar)
#else
        .init()
#endif
    }

    /// The "imagePicker" asset catalog image.
    static var imagePicker: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .imagePicker)
#else
        .init()
#endif
    }

    /// The "launchImage" asset catalog image.
    static var launch: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .launch)
#else
        .init()
#endif
    }

    /// The "menu_BAr" asset catalog image.
    static var menuBAr: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .menuBAr)
#else
        .init()
#endif
    }

    /// The "nextBtnBox" asset catalog image.
    static var nextBtnBox: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .nextBtnBox)
#else
        .init()
#endif
    }

    /// The "noDataFoundImage" asset catalog image.
    static var noDataFound: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .noDataFound)
#else
        .init()
#endif
    }

    /// The "ordersTabbar" asset catalog image.
    static var ordersTabbar: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .ordersTabbar)
#else
        .init()
#endif
    }

    /// The "outletDivider" asset catalog image.
    static var outletDivider: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .outletDivider)
#else
        .init()
#endif
    }

    /// The "outletDividerWhite" asset catalog image.
    static var outletDividerWhite: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .outletDividerWhite)
#else
        .init()
#endif
    }

    /// The "previewGrid" asset catalog image.
    static var previewGrid: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .previewGrid)
#else
        .init()
#endif
    }

    /// The "previous" asset catalog image.
    static var previous: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .previous)
#else
        .init()
#endif
    }

    /// The "progress0" asset catalog image.
    static var progress0: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .progress0)
#else
        .init()
#endif
    }

    /// The "progress1" asset catalog image.
    static var progress1: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .progress1)
#else
        .init()
#endif
    }

    /// The "readMore" asset catalog image.
    static var readMore: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .readMore)
#else
        .init()
#endif
    }

    /// The "reload" asset catalog image.
    static var reload: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .reload)
#else
        .init()
#endif
    }

    /// The "riskStockSeparation" asset catalog image.
    static var riskStockSeparation: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .riskStockSeparation)
#else
        .init()
#endif
    }

    /// The "schemeDropDown" asset catalog image.
    static var schemeDropDown: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .schemeDropDown)
#else
        .init()
#endif
    }

    /// The "search" asset catalog image.
    static var search: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .search)
#else
        .init()
#endif
    }

    /// The "searchIcon" asset catalog image.
    static var searchIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .searchIcon)
#else
        .init()
#endif
    }

    /// The "selected" asset catalog image.
    static var selected: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .selected)
#else
        .init()
#endif
    }

    /// The "selectedRadio" asset catalog image.
    static var selectedRadio: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .selectedRadio)
#else
        .init()
#endif
    }

    /// The "separation" asset catalog image.
    static var separation: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .separation)
#else
        .init()
#endif
    }

    /// The "seprationTbleVw" asset catalog image.
    static var seprationTbleVw: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .seprationTbleVw)
#else
        .init()
#endif
    }

    /// The "signInBackgroingImg" asset catalog image.
    static var signInBackgroingImg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .signInBackgroingImg)
#else
        .init()
#endif
    }

    /// The "trash" asset catalog image.
    static var trash: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .trash)
#else
        .init()
#endif
    }

    /// The "uncheck" asset catalog image.
    static var uncheck: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .uncheck)
#else
        .init()
#endif
    }

    /// The "unselectedRadio" asset catalog image.
    static var unselectedRadio: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .unselectedRadio)
#else
        .init()
#endif
    }

    /// The "visitIcon" asset catalog image.
    static var visitIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .visitIcon)
#else
        .init()
#endif
    }

    /// The "visitsTabbar" asset catalog image.
    static var visitsTabbar: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .visitsTabbar)
#else
        .init()
#endif
    }

    /// The "workingWithOutlet" asset catalog image.
    static var workingWithOutlet: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .workingWithOutlet)
#else
        .init()
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    /// The "Controls" asset catalog image.
    static var controls: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .controls)
#else
        .init()
#endif
    }

    /// The "EllipseImg" asset catalog image.
    static var ellipseImg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .ellipseImg)
#else
        .init()
#endif
    }

    /// The "Ellipse_scheme" asset catalog image.
    static var ellipseScheme: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .ellipseScheme)
#else
        .init()
#endif
    }

    /// The "POSMTabbar" asset catalog image.
    static var posmTabbar: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .posmTabbar)
#else
        .init()
#endif
    }

    /// The "PolygonBtn" asset catalog image.
    static var polygonBtn: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .polygonBtn)
#else
        .init()
#endif
    }

    /// The "addActionItem" asset catalog image.
    static var addActionItem: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .addActionItem)
#else
        .init()
#endif
    }

    /// The "addItems" asset catalog image.
    static var addItems: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .addItems)
#else
        .init()
#endif
    }

    /// The "addNewContactt" asset catalog image.
    static var addNewContactt: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .addNewContactt)
#else
        .init()
#endif
    }

    /// The "addPOSM" asset catalog image.
    static var addPOSM: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .addPOSM)
#else
        .init()
#endif
    }

    /// The "addQuantity" asset catalog image.
    static var addQuantity: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .addQuantity)
#else
        .init()
#endif
    }

    /// The "arrow" asset catalog image.
    static var arrow: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .arrow)
#else
        .init()
#endif
    }

    /// The "back" asset catalog image.
    static var back: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .back)
#else
        .init()
#endif
    }

    /// The "backG" asset catalog image.
    static var backG: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .backG)
#else
        .init()
#endif
    }

    /// The "backgroundImage" asset catalog image.
    static var background: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .background)
#else
        .init()
#endif
    }

    /// The "bg" asset catalog image.
    static var bg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .bg)
#else
        .init()
#endif
    }

    /// The "btnIImge" asset catalog image.
    static var btnIImge: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .btnIImge)
#else
        .init()
#endif
    }

    /// The "buttonsImage" asset catalog image.
    static var buttons: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .buttons)
#else
        .init()
#endif
    }

    /// The "calander-interface-icon-svgrepo-com 1" asset catalog image.
    static var calanderInterfaceIconSvgrepoCom1: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .calanderInterfaceIconSvgrepoCom1)
#else
        .init()
#endif
    }

    /// The "cameraPlaceholder" asset catalog image.
    static var cameraPlaceholder: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .cameraPlaceholder)
#else
        .init()
#endif
    }

    /// The "cameraVisibility" asset catalog image.
    static var cameraVisibility: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .cameraVisibility)
#else
        .init()
#endif
    }

    /// The "check" asset catalog image.
    static var check: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .check)
#else
        .init()
#endif
    }

    /// The "checkBox" asset catalog image.
    static var checkBox: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .checkBox)
#else
        .init()
#endif
    }

    /// The "contactsTabbar" asset catalog image.
    static var contactsTabbar: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .contactsTabbar)
#else
        .init()
#endif
    }

    /// The "customerPromotion" asset catalog image.
    static var customerPromotion: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .customerPromotion)
#else
        .init()
#endif
    }

    /// The "date" asset catalog image.
    static var date: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .date)
#else
        .init()
#endif
    }

    /// The "decreaseQuantity" asset catalog image.
    static var decreaseQuantity: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .decreaseQuantity)
#else
        .init()
#endif
    }

    /// The "direction" asset catalog image.
    static var direction: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .direction)
#else
        .init()
#endif
    }

    /// The "done" asset catalog image.
    static var done: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .done)
#else
        .init()
#endif
    }

    /// The "dot" asset catalog image.
    static var dot: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .dot)
#else
        .init()
#endif
    }

    /// The "dotImg" asset catalog image.
    static var dotImg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .dotImg)
#else
        .init()
#endif
    }

    /// The "editPen" asset catalog image.
    static var editPen: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .editPen)
#else
        .init()
#endif
    }

    /// The "generatePIBtn" asset catalog image.
    static var generatePIBtn: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .generatePIBtn)
#else
        .init()
#endif
    }

    /// The "homeTabbar" asset catalog image.
    static var homeTabbar: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .homeTabbar)
#else
        .init()
#endif
    }

    /// The "imagePicker" asset catalog image.
    static var imagePicker: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .imagePicker)
#else
        .init()
#endif
    }

    /// The "launchImage" asset catalog image.
    static var launch: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .launch)
#else
        .init()
#endif
    }

    /// The "menu_BAr" asset catalog image.
    static var menuBAr: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .menuBAr)
#else
        .init()
#endif
    }

    /// The "nextBtnBox" asset catalog image.
    static var nextBtnBox: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .nextBtnBox)
#else
        .init()
#endif
    }

    /// The "noDataFoundImage" asset catalog image.
    static var noDataFound: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .noDataFound)
#else
        .init()
#endif
    }

    /// The "ordersTabbar" asset catalog image.
    static var ordersTabbar: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .ordersTabbar)
#else
        .init()
#endif
    }

    /// The "outletDivider" asset catalog image.
    static var outletDivider: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .outletDivider)
#else
        .init()
#endif
    }

    /// The "outletDividerWhite" asset catalog image.
    static var outletDividerWhite: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .outletDividerWhite)
#else
        .init()
#endif
    }

    /// The "previewGrid" asset catalog image.
    static var previewGrid: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .previewGrid)
#else
        .init()
#endif
    }

    /// The "previous" asset catalog image.
    static var previous: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .previous)
#else
        .init()
#endif
    }

    /// The "progress0" asset catalog image.
    static var progress0: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .progress0)
#else
        .init()
#endif
    }

    /// The "progress1" asset catalog image.
    static var progress1: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .progress1)
#else
        .init()
#endif
    }

    /// The "readMore" asset catalog image.
    static var readMore: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .readMore)
#else
        .init()
#endif
    }

    /// The "reload" asset catalog image.
    static var reload: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .reload)
#else
        .init()
#endif
    }

    /// The "riskStockSeparation" asset catalog image.
    static var riskStockSeparation: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .riskStockSeparation)
#else
        .init()
#endif
    }

    /// The "schemeDropDown" asset catalog image.
    static var schemeDropDown: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .schemeDropDown)
#else
        .init()
#endif
    }

    /// The "search" asset catalog image.
    static var search: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .search)
#else
        .init()
#endif
    }

    /// The "searchIcon" asset catalog image.
    static var searchIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .searchIcon)
#else
        .init()
#endif
    }

    /// The "selected" asset catalog image.
    static var selected: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .selected)
#else
        .init()
#endif
    }

    /// The "selectedRadio" asset catalog image.
    static var selectedRadio: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .selectedRadio)
#else
        .init()
#endif
    }

    /// The "separation" asset catalog image.
    static var separation: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .separation)
#else
        .init()
#endif
    }

    /// The "seprationTbleVw" asset catalog image.
    static var seprationTbleVw: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .seprationTbleVw)
#else
        .init()
#endif
    }

    /// The "signInBackgroingImg" asset catalog image.
    static var signInBackgroingImg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .signInBackgroingImg)
#else
        .init()
#endif
    }

    /// The "trash" asset catalog image.
    static var trash: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .trash)
#else
        .init()
#endif
    }

    /// The "uncheck" asset catalog image.
    static var uncheck: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .uncheck)
#else
        .init()
#endif
    }

    /// The "unselectedRadio" asset catalog image.
    static var unselectedRadio: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .unselectedRadio)
#else
        .init()
#endif
    }

    /// The "visitIcon" asset catalog image.
    static var visitIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .visitIcon)
#else
        .init()
#endif
    }

    /// The "visitsTabbar" asset catalog image.
    static var visitsTabbar: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .visitsTabbar)
#else
        .init()
#endif
    }

    /// The "workingWithOutlet" asset catalog image.
    static var workingWithOutlet: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .workingWithOutlet)
#else
        .init()
#endif
    }

}
#endif

// MARK: - Thinnable Asset Support -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ColorResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if AppKit.NSColor(named: NSColor.Name(thinnableName), bundle: bundle) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIColor(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}
#endif

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ImageResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if bundle.image(forResource: NSImage.Name(thinnableName)) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIImage(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ImageResource?) {
#if !targetEnvironment(macCatalyst)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ImageResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

