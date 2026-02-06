//
//  NotificationType.swift
//  DexLens
//
//  Created by Mert Avci on 2026-02-06.
//

import Foundation
import SwiftUI

enum NotificationType: CaseIterable, Identifiable {
    case success
    case info
    case failure

    var id: Self { self }

    var iconName: String {
        switch self {
        case .success:
            return "checkmark.circle.fill"
        case .info:
            return "info.circle.fill"
        case .failure:
            return "xmark.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .success:
            return .success
        case .info:
            return .primary
        case .failure:
            return .error
        }
    }

    var defaultTitle: String {
        switch self {
        case .success:
            return "Success"
        case .info:
            return "Information"
        case .failure:
            return "Error"
        }
    }
}

enum NotificationDuration {
    case short
    case normal
    case long
    case custom(TimeInterval)

    var timeInterval: TimeInterval {
        switch self {
        case .short:
            return 2
        case .normal:
            return 4
        case .long:
            return 6
        case .custom(let value):
            return value
        }
    }
}
