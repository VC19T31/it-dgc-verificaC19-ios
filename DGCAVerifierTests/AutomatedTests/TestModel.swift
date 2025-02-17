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
//  TestModel.swift
//  VerifierTests
//
//  Created by Emilio Apuzzo on 04/02/22.
//

import Foundation
import SwiftDGC
@testable import VerificaC19

struct TestCase: Codable, Equatable {
    static func == (lhs: TestCase, rhs: TestCase) -> Bool {
        guard lhs.expectedValidity.count == rhs.expectedValidity.count else { return false }
        return lhs.expectedValidity.enumerated()
            .map { rhs.expectedValidity[$0] == $1 }
            .filter {!$0}.isEmpty
    }
    
    let id: String
    let description: String
    let expectedValidity: [TestResult]
    var actualValidity: [TestResult]?
    let payload: String
    
    func report() -> TestReport {
        guard let actualValidity = actualValidity else { return TestReport(id: self.id, passed: false, error: "") }
        let result: [Bool] = expectedValidity.enumerated().map{ actualValidity[$0] == $1}
        
        guard !result.filter({!$0}).isEmpty else { return TestReport(id: self.id, passed: true, error: nil)}
    
        let error = expectedValidity
            .enumerated()
            .map {"\($1.mode): atteso = '\($1.result)' attuale = '\(actualValidity[$0].result)',"}
            .joined(separator: " ")
    
        return TestReport(id: self.id, passed: false, error: error)
    }
}

struct TestReport: Codable {
    let id: String
    let passed: Bool
    let error: String?
}

struct TestResult: Codable, Equatable {
    let mode: String
    let result: String
    
    func parseScanMode() -> ScanMode? {
        switch self.mode {
        case "base":
            return .base
        case "rafforzata":
            return .reinforced
        default:
            return nil
        }
    }
    
    init(mode: String, status: Status) {
        self.mode = mode
        switch status {
        case .notGreenPass:
            self.result = "notGreenPass"
        case .notValid:
            self.result = "notValid"
        case .valid:
            self.result = "valid"
        case .notValidYet:
            self.result = "notValidYet"
        case .verificationIsNeeded:
            self.result = "verificationIsNeeded"
        case .revokedGreenPass:
            self.result = "revokedGreenPass"
        }
    }
}
