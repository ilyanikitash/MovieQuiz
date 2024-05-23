//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Ilya Nikitash on 16.05.2024.
//

import XCTest

final class MovieQuizUITests: XCTestCase {
    
    var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        app = XCUIApplication()
        app.launch()
        
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        app.terminate()
        app = nil

    }
    func testYesButton() {
        sleep(3)
        let indexLabel = app.staticTexts["Index"]
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["Yes"].tap()
        
        sleep(3)
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        XCTAssertEqual(indexLabel.label, "2/10")
        XCTAssertNotEqual(firstPosterData, secondPosterData)
    }
    func testNoButton() {
        sleep(3)
        let indexLabel = app.staticTexts["Index"]
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["No"].tap()
        
        sleep(3)
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        XCTAssertEqual(indexLabel.label, "2/10")
        XCTAssertNotEqual(firstPosterData, secondPosterData)
    }
    
    func testResultsAlert() {
        for _ in 1...10 {
            sleep(2)
            app.buttons["No"].tap()
        }
        
        sleep(1)
        
        let alert = app.alerts["Result Alert"]
        
        XCTAssertTrue(alert.exists)
        XCTAssertEqual(alert.buttons.firstMatch.label, "Сыграть еще раз")
        XCTAssertEqual(alert.label, "Этот раунд окончен!")
    }
    
    func testAlertExist() {
        for _ in 1...10 {
            sleep(2)
            app.buttons["No"].tap()
        }
        
        sleep(1)
        
        let alert = app.alerts["Result Alert"]
        alert.buttons.firstMatch.tap()
        
        sleep(2)
        let indexLabel = app.staticTexts["Index"]
        
        XCTAssertFalse(alert.exists)
        XCTAssertEqual(indexLabel.label, "1/10")
    }
}
