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
//  Constants.swift
//  Verifier
//
//  Created by Emilio Apuzzo on 29/10/21.
//

import Foundation

struct Constants {
    
    // TestValidityCheck
    static let rapidStartHoursKey = "rapid_test_start_hours"
    static let rapidEndHoursKey = "rapid_test_end_hours"
    static let molecularStartHoursKey = "molecular_test_start_hours"
    static let molecularEndHoursKey = "molecular_test_end_hours"
    
    // VaccineValidityCheck
    static let vaccineIncompleteStartDays = "vaccine_start_day_not_complete"
    static let vaccineIncompleteEndDays = "vaccine_end_day_not_complete"
    static let vaccineCompleteStartDays = "vaccine_start_day_complete"
    static let vaccineCompleteEndDays = "vaccine_end_day_complete"
    static let JeJVacineCode = "EU/1/20/1525"
    static let SputnikVacineCode = "Sputnik-V"
    static let sanMarinoCode = "SM"
    
    // Settings
    static let drlMaxRetries = "MAX_RETRY"
    
}
