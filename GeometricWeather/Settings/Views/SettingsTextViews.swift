//
//  SettingsTextViews.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/9/15.
//

import SwiftUI

struct SettingsTitleView: View {
    
    let key: String
    
    var body: some View {
        Text(
            NSLocalizedString(key, comment: "")
        ).font(
            Font(titleFont)
        ).foregroundColor(
            Color(UIColor.label)
        )
    }
}

struct SettingsBodyView: View {
    
    let key: String
    
    var body: some View {
        Text(
            NSLocalizedString(key, comment: "")
        ).font(
            Font(bodyFont)
        ).foregroundColor(
            Color(UIColor.secondaryLabel)
        )
    }
}

struct SettingsCaptionView: View {
    
    let key: String
    
    var body: some View {
        Text(
            NSLocalizedString(key, comment: "")
        ).font(
            Font(captionFont)
        ).foregroundColor(
            Color(UIColor.tertiaryLabel)
        )
    }
}

struct SettingsTextViews_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            SettingsTitleView(key: "settings_title_background_free")
            SettingsBodyView(key: "settings_title_background_free")
            SettingsCaptionView(key: "settings_title_background_free")
        }
    }
}
