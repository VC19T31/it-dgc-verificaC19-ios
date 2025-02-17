/*
 *  license-start
 *  
 *  Copyright (C) 2021 Ministero della Salute and all other contributors
 *  
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *  
 *      http://www.apache.org/licenses/LICENSE-2.0
 *  
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
*/

//
//  BlackListValidator.swift
//  Verifier
//
//  Created by Ludovico Girolimini on 01/02/22.
//

import Foundation
import SwiftDGC

struct BlackListValidator: DGCValidator {
    
    private let blacklist = "black_list_uvci"

    func validate(hcert: HCert) -> Status {
        guard let blacklist = getBlacklist() else { return .valid }
        return blacklist.split(separator: ";").contains("\(hcert.getUVCI())") ? .notValid : .valid
    }
    
    private func getBlacklist() -> String? {
        return getValue(for: blacklist)
    }

    private func getValue(for name: String) -> String? {
        return LocalData.getSetting(from: name)
    }
    
}
