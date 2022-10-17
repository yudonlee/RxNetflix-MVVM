//
//  String+Extension.swift
//  Netflix
//
//  Created by yudonlee on 2022/07/09.
//

import Foundation

extension String {
    func capitalizeFirstLetter() -> String { 
        return self.prefix(1).uppercased() + self.lowercased().dropFirst()
    }
}
