//
// This is a generated file, do not edit!
// Generated by R.swift, see https://github.com/mac-cain13/R.swift
//

import Foundation
import Rswift
import UIKit

/// This `R` struct is generated and contains references to static resources.
struct R: Rswift.Validatable {
  fileprivate static let applicationLocale = hostingBundle.preferredLocalizations.first.flatMap { Locale(identifier: $0) } ?? Locale.current
  fileprivate static let hostingBundle = Bundle(for: R.Class.self)

  /// Find first language and bundle for which the table exists
  fileprivate static func localeBundle(tableName: String, preferredLanguages: [String]) -> (Foundation.Locale, Foundation.Bundle)? {
    // Filter preferredLanguages to localizations, use first locale
    var languages = preferredLanguages
      .map { Locale(identifier: $0) }
      .prefix(1)
      .flatMap { locale -> [String] in
        if hostingBundle.localizations.contains(locale.identifier) {
          if let language = locale.languageCode, hostingBundle.localizations.contains(language) {
            return [locale.identifier, language]
          } else {
            return [locale.identifier]
          }
        } else if let language = locale.languageCode, hostingBundle.localizations.contains(language) {
          return [language]
        } else {
          return []
        }
      }

    // If there's no languages, use development language as backstop
    if languages.isEmpty {
      if let developmentLocalization = hostingBundle.developmentLocalization {
        languages = [developmentLocalization]
      }
    } else {
      // Insert Base as second item (between locale identifier and languageCode)
      languages.insert("Base", at: 1)

      // Add development language as backstop
      if let developmentLocalization = hostingBundle.developmentLocalization {
        languages.append(developmentLocalization)
      }
    }

    // Find first language for which table exists
    // Note: key might not exist in chosen language (in that case, key will be shown)
    for language in languages {
      if let lproj = hostingBundle.url(forResource: language, withExtension: "lproj"),
         let lbundle = Bundle(url: lproj)
      {
        let strings = lbundle.url(forResource: tableName, withExtension: "strings")
        let stringsdict = lbundle.url(forResource: tableName, withExtension: "stringsdict")

        if strings != nil || stringsdict != nil {
          return (Locale(identifier: language), lbundle)
        }
      }
    }

    // If table is available in main bundle, don't look for localized resources
    let strings = hostingBundle.url(forResource: tableName, withExtension: "strings", subdirectory: nil, localization: nil)
    let stringsdict = hostingBundle.url(forResource: tableName, withExtension: "stringsdict", subdirectory: nil, localization: nil)

    if strings != nil || stringsdict != nil {
      return (applicationLocale, hostingBundle)
    }

    // If table is not found for requested languages, key will be shown
    return nil
  }

  /// Load string from Info.plist file
  fileprivate static func infoPlistString(path: [String], key: String) -> String? {
    var dict = hostingBundle.infoDictionary
    for step in path {
      guard let obj = dict?[step] as? [String: Any] else { return nil }
      dict = obj
    }
    return dict?[key] as? String
  }

  static func validate() throws {
    try intern.validate()
  }

  /// This `R.color` struct is generated, and contains static references to 12 colors.
  struct color {
    /// Color `AccentColor`.
    static let accentColor = Rswift.ColorResource(bundle: R.hostingBundle, name: "AccentColor")
    /// Color `ConflictText`.
    static let conflictText = Rswift.ColorResource(bundle: R.hostingBundle, name: "ConflictText")
    /// Color `GreatBorder`.
    static let greatBorder = Rswift.ColorResource(bundle: R.hostingBundle, name: "GreatBorder")
    /// Color `LevelSquareText`.
    static let levelSquareText = Rswift.ColorResource(bundle: R.hostingBundle, name: "LevelSquareText")
    /// Color `NoneSquareBackground`.
    static let noneSquareBackground = Rswift.ColorResource(bundle: R.hostingBundle, name: "NoneSquareBackground")
    /// Color `NumberPickerButtonBackground`.
    static let numberPickerButtonBackground = Rswift.ColorResource(bundle: R.hostingBundle, name: "NumberPickerButtonBackground")
    /// Color `PrimarySquareBackground`.
    static let primarySquareBackground = Rswift.ColorResource(bundle: R.hostingBundle, name: "PrimarySquareBackground")
    /// Color `SecondarySquareBackground`.
    static let secondarySquareBackground = Rswift.ColorResource(bundle: R.hostingBundle, name: "SecondarySquareBackground")
    /// Color `SelectableNumberText`.
    static let selectableNumberText = Rswift.ColorResource(bundle: R.hostingBundle, name: "SelectableNumberText")
    /// Color `SelectedSquareBackground`.
    static let selectedSquareBackground = Rswift.ColorResource(bundle: R.hostingBundle, name: "SelectedSquareBackground")
    /// Color `SubBorder`.
    static let subBorder = Rswift.ColorResource(bundle: R.hostingBundle, name: "SubBorder")
    /// Color `UserSquareText`.
    static let userSquareText = Rswift.ColorResource(bundle: R.hostingBundle, name: "UserSquareText")

    #if os(iOS) || os(tvOS)
    /// `UIColor(named: "AccentColor", bundle: ..., traitCollection: ...)`
    @available(tvOS 11.0, *)
    @available(iOS 11.0, *)
    static func accentColor(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIColor? {
      return UIKit.UIColor(resource: R.color.accentColor, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIColor(named: "ConflictText", bundle: ..., traitCollection: ...)`
    @available(tvOS 11.0, *)
    @available(iOS 11.0, *)
    static func conflictText(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIColor? {
      return UIKit.UIColor(resource: R.color.conflictText, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIColor(named: "GreatBorder", bundle: ..., traitCollection: ...)`
    @available(tvOS 11.0, *)
    @available(iOS 11.0, *)
    static func greatBorder(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIColor? {
      return UIKit.UIColor(resource: R.color.greatBorder, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIColor(named: "LevelSquareText", bundle: ..., traitCollection: ...)`
    @available(tvOS 11.0, *)
    @available(iOS 11.0, *)
    static func levelSquareText(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIColor? {
      return UIKit.UIColor(resource: R.color.levelSquareText, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIColor(named: "NoneSquareBackground", bundle: ..., traitCollection: ...)`
    @available(tvOS 11.0, *)
    @available(iOS 11.0, *)
    static func noneSquareBackground(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIColor? {
      return UIKit.UIColor(resource: R.color.noneSquareBackground, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIColor(named: "NumberPickerButtonBackground", bundle: ..., traitCollection: ...)`
    @available(tvOS 11.0, *)
    @available(iOS 11.0, *)
    static func numberPickerButtonBackground(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIColor? {
      return UIKit.UIColor(resource: R.color.numberPickerButtonBackground, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIColor(named: "PrimarySquareBackground", bundle: ..., traitCollection: ...)`
    @available(tvOS 11.0, *)
    @available(iOS 11.0, *)
    static func primarySquareBackground(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIColor? {
      return UIKit.UIColor(resource: R.color.primarySquareBackground, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIColor(named: "SecondarySquareBackground", bundle: ..., traitCollection: ...)`
    @available(tvOS 11.0, *)
    @available(iOS 11.0, *)
    static func secondarySquareBackground(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIColor? {
      return UIKit.UIColor(resource: R.color.secondarySquareBackground, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIColor(named: "SelectableNumberText", bundle: ..., traitCollection: ...)`
    @available(tvOS 11.0, *)
    @available(iOS 11.0, *)
    static func selectableNumberText(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIColor? {
      return UIKit.UIColor(resource: R.color.selectableNumberText, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIColor(named: "SelectedSquareBackground", bundle: ..., traitCollection: ...)`
    @available(tvOS 11.0, *)
    @available(iOS 11.0, *)
    static func selectedSquareBackground(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIColor? {
      return UIKit.UIColor(resource: R.color.selectedSquareBackground, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIColor(named: "SubBorder", bundle: ..., traitCollection: ...)`
    @available(tvOS 11.0, *)
    @available(iOS 11.0, *)
    static func subBorder(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIColor? {
      return UIKit.UIColor(resource: R.color.subBorder, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIColor(named: "UserSquareText", bundle: ..., traitCollection: ...)`
    @available(tvOS 11.0, *)
    @available(iOS 11.0, *)
    static func userSquareText(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIColor? {
      return UIKit.UIColor(resource: R.color.userSquareText, compatibleWith: traitCollection)
    }
    #endif

    #if os(watchOS)
    /// `UIColor(named: "AccentColor", bundle: ..., traitCollection: ...)`
    @available(watchOSApplicationExtension 4.0, *)
    static func accentColor(_: Void = ()) -> UIKit.UIColor? {
      return UIKit.UIColor(named: R.color.accentColor.name)
    }
    #endif

    #if os(watchOS)
    /// `UIColor(named: "ConflictText", bundle: ..., traitCollection: ...)`
    @available(watchOSApplicationExtension 4.0, *)
    static func conflictText(_: Void = ()) -> UIKit.UIColor? {
      return UIKit.UIColor(named: R.color.conflictText.name)
    }
    #endif

    #if os(watchOS)
    /// `UIColor(named: "GreatBorder", bundle: ..., traitCollection: ...)`
    @available(watchOSApplicationExtension 4.0, *)
    static func greatBorder(_: Void = ()) -> UIKit.UIColor? {
      return UIKit.UIColor(named: R.color.greatBorder.name)
    }
    #endif

    #if os(watchOS)
    /// `UIColor(named: "LevelSquareText", bundle: ..., traitCollection: ...)`
    @available(watchOSApplicationExtension 4.0, *)
    static func levelSquareText(_: Void = ()) -> UIKit.UIColor? {
      return UIKit.UIColor(named: R.color.levelSquareText.name)
    }
    #endif

    #if os(watchOS)
    /// `UIColor(named: "NoneSquareBackground", bundle: ..., traitCollection: ...)`
    @available(watchOSApplicationExtension 4.0, *)
    static func noneSquareBackground(_: Void = ()) -> UIKit.UIColor? {
      return UIKit.UIColor(named: R.color.noneSquareBackground.name)
    }
    #endif

    #if os(watchOS)
    /// `UIColor(named: "NumberPickerButtonBackground", bundle: ..., traitCollection: ...)`
    @available(watchOSApplicationExtension 4.0, *)
    static func numberPickerButtonBackground(_: Void = ()) -> UIKit.UIColor? {
      return UIKit.UIColor(named: R.color.numberPickerButtonBackground.name)
    }
    #endif

    #if os(watchOS)
    /// `UIColor(named: "PrimarySquareBackground", bundle: ..., traitCollection: ...)`
    @available(watchOSApplicationExtension 4.0, *)
    static func primarySquareBackground(_: Void = ()) -> UIKit.UIColor? {
      return UIKit.UIColor(named: R.color.primarySquareBackground.name)
    }
    #endif

    #if os(watchOS)
    /// `UIColor(named: "SecondarySquareBackground", bundle: ..., traitCollection: ...)`
    @available(watchOSApplicationExtension 4.0, *)
    static func secondarySquareBackground(_: Void = ()) -> UIKit.UIColor? {
      return UIKit.UIColor(named: R.color.secondarySquareBackground.name)
    }
    #endif

    #if os(watchOS)
    /// `UIColor(named: "SelectableNumberText", bundle: ..., traitCollection: ...)`
    @available(watchOSApplicationExtension 4.0, *)
    static func selectableNumberText(_: Void = ()) -> UIKit.UIColor? {
      return UIKit.UIColor(named: R.color.selectableNumberText.name)
    }
    #endif

    #if os(watchOS)
    /// `UIColor(named: "SelectedSquareBackground", bundle: ..., traitCollection: ...)`
    @available(watchOSApplicationExtension 4.0, *)
    static func selectedSquareBackground(_: Void = ()) -> UIKit.UIColor? {
      return UIKit.UIColor(named: R.color.selectedSquareBackground.name)
    }
    #endif

    #if os(watchOS)
    /// `UIColor(named: "SubBorder", bundle: ..., traitCollection: ...)`
    @available(watchOSApplicationExtension 4.0, *)
    static func subBorder(_: Void = ()) -> UIKit.UIColor? {
      return UIKit.UIColor(named: R.color.subBorder.name)
    }
    #endif

    #if os(watchOS)
    /// `UIColor(named: "UserSquareText", bundle: ..., traitCollection: ...)`
    @available(watchOSApplicationExtension 4.0, *)
    static func userSquareText(_: Void = ()) -> UIKit.UIColor? {
      return UIKit.UIColor(named: R.color.userSquareText.name)
    }
    #endif

    fileprivate init() {}
  }

  /// This `R.file` struct is generated, and contains static references to 5 files.
  struct file {
    /// Resource file `easy.data`.
    static let easyData = Rswift.FileResource(bundle: R.hostingBundle, name: "easy", pathExtension: "data")
    /// Resource file `extreme.data`.
    static let extremeData = Rswift.FileResource(bundle: R.hostingBundle, name: "extreme", pathExtension: "data")
    /// Resource file `hard.data`.
    static let hardData = Rswift.FileResource(bundle: R.hostingBundle, name: "hard", pathExtension: "data")
    /// Resource file `medium.data`.
    static let mediumData = Rswift.FileResource(bundle: R.hostingBundle, name: "medium", pathExtension: "data")
    /// Resource file `veryEasy.data`.
    static let veryEasyData = Rswift.FileResource(bundle: R.hostingBundle, name: "veryEasy", pathExtension: "data")

    /// `bundle.url(forResource: "easy", withExtension: "data")`
    static func easyData(_: Void = ()) -> Foundation.URL? {
      let fileResource = R.file.easyData
      return fileResource.bundle.url(forResource: fileResource)
    }

    /// `bundle.url(forResource: "extreme", withExtension: "data")`
    static func extremeData(_: Void = ()) -> Foundation.URL? {
      let fileResource = R.file.extremeData
      return fileResource.bundle.url(forResource: fileResource)
    }

    /// `bundle.url(forResource: "hard", withExtension: "data")`
    static func hardData(_: Void = ()) -> Foundation.URL? {
      let fileResource = R.file.hardData
      return fileResource.bundle.url(forResource: fileResource)
    }

    /// `bundle.url(forResource: "medium", withExtension: "data")`
    static func mediumData(_: Void = ()) -> Foundation.URL? {
      let fileResource = R.file.mediumData
      return fileResource.bundle.url(forResource: fileResource)
    }

    /// `bundle.url(forResource: "veryEasy", withExtension: "data")`
    static func veryEasyData(_: Void = ()) -> Foundation.URL? {
      let fileResource = R.file.veryEasyData
      return fileResource.bundle.url(forResource: fileResource)
    }

    fileprivate init() {}
  }

  fileprivate struct intern: Rswift.Validatable {
    fileprivate static func validate() throws {
      // There are no resources to validate
    }

    fileprivate init() {}
  }

  fileprivate class Class {}

  fileprivate init() {}
}

struct _R {
  fileprivate init() {}
}
