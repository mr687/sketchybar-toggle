import AppKit
import XCTest
@testable import SketchyBarToggleCore

final class EventTapTests: XCTestCase {
    func testHiddenBarStaysHiddenAtStackedSeamAndRestoresPastTolerance() {
        let lower = NSRect(x: 0, y: 0, width: 1000, height: 900)
        let upper = NSRect(x: 500, y: 900, width: 1000, height: 800)
        let screens = [lower, upper]
        let controller = MockBarController()
        let stateMachine = BarStateMachine(controller: controller)
        stateMachine.handleMousePosition(distanceFromTop: 0)

        let seamDistance = EventTapMonitor.distanceFromTop(
            NSPoint(x: 700, y: 902), currentScreen: upper,
            screens: screens, isHidden: true, triggerZone: stateMachine.triggerZone
        )
        stateMachine.handleMouseClick(distanceFromTop: seamDistance)
        stateMachine.handleMousePosition(distanceFromTop: seamDistance)
        XCTAssertEqual(stateMachine.state, .hidden)
        XCTAssertFalse(stateMachine.hasPendingDebounce)
        XCTAssertEqual(controller.showCallCount, 0)

        let awayDistance = EventTapMonitor.distanceFromTop(
            NSPoint(x: 700, y: 912), currentScreen: upper,
            screens: screens, isHidden: true, triggerZone: stateMachine.triggerZone
        )
        stateMachine.handleMousePosition(distanceFromTop: awayDistance)
        XCTAssertTrue(stateMachine.hasPendingDebounce)
    }

    func testSeamGuardDoesNotChangeVisibleOrSingleScreenBehavior() {
        let lower = NSRect(x: 0, y: 0, width: 1000, height: 900)
        let upper = NSRect(x: 500, y: 900, width: 1000, height: 800)
        XCTAssertEqual(EventTapMonitor.distanceFromTop(
            NSPoint(x: 700, y: 902), currentScreen: upper,
            screens: [lower, upper], isHidden: false, triggerZone: 10
        ), 798)
        XCTAssertEqual(EventTapMonitor.distanceFromTop(
            NSPoint(x: 1200, y: 902), currentScreen: upper,
            screens: [lower, upper], isHidden: true, triggerZone: 10
        ), 798)
        XCTAssertEqual(EventTapMonitor.distanceFromTop(
            NSPoint(x: 700, y: 850), currentScreen: lower,
            screens: [lower], isHidden: true, triggerZone: 10
        ), 50)
    }
}
