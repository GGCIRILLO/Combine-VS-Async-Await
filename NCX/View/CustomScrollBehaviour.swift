//
//  CustomScrollBehaviour.swift
//  NCX
//
//  Created by Luigi Cirillo on 25/03/24.
//

import Foundation
import SwiftUI

struct CustomScrollBehaviour: ScrollTargetBehavior {
    func updateTarget(_ target: inout ScrollTarget, context: TargetContext) {
        if target.rect.minY < 75 {
            target.rect = .zero
        }
    }
}
