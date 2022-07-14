//
//  TapCountRecognizer.swift
//  SwiftUISolutions
//  区别单击，双击，三击等多种点击同时出现的解决方案
//
//  Created by Yi Li on 2022/7/13.
//

import Foundation
import SwiftUI


// MARK: 区别单击，双击以及三击
struct TapCountRecognizerModifier: ViewModifier {
    let tapSensitivity: Int
    let singleTapAction: (() -> Void)?
    let doubleTapAction: (() -> Void)?
    let tripleTapAction: (() -> Void)?
    
    init(tapSensitivity: Int = 250, singleTapAction: (() -> Void)? = nil, doubleTapAction: (() -> Void)? = nil, tripleTapAction: (() -> Void)? = nil) {
        self.tapSensitivity  = ((tapSensitivity >= 0) ? tapSensitivity : 250)
        self.singleTapAction = singleTapAction
        self.doubleTapAction = doubleTapAction
        self.tripleTapAction = tripleTapAction
    }
    
    @State private var tapCount: Int = Int()
    @State private var currentDispatchTimeID: DispatchTime = DispatchTime.now()
    
    func body(content: Content) -> some View {
        return content
            .gesture(fundamentalGesture)
    }
    
    var fundamentalGesture: some Gesture {
        DragGesture(minimumDistance: 0.0, coordinateSpace: .local)
            .onEnded() { _ in tapCount += 1; tapAnalyzerFunction() }
    }
    
    func tapAnalyzerFunction() {
        currentDispatchTimeID = dispatchTimeIdGenerator(deadline: tapSensitivity)
        if tapCount == 1 {
            let singleTapGestureDispatchTimeID: DispatchTime = currentDispatchTimeID
            DispatchQueue.main.asyncAfter(deadline: singleTapGestureDispatchTimeID) {
                if (singleTapGestureDispatchTimeID == currentDispatchTimeID) {
                    if let unwrappedSingleTapAction: () -> Void = singleTapAction { unwrappedSingleTapAction() }
                    tapCount = 0
                }
            }
        }
        else if tapCount == 2 {
            let doubleTapGestureDispatchTimeID: DispatchTime = currentDispatchTimeID
            DispatchQueue.main.asyncAfter(deadline: doubleTapGestureDispatchTimeID) {
                if (doubleTapGestureDispatchTimeID == currentDispatchTimeID) {
                    if let unwrappedDoubleTapAction: () -> Void = doubleTapAction { unwrappedDoubleTapAction() }
                        tapCount = 0
                }
            }
        }
        else  {
            if let unwrappedTripleTapAction: () -> Void = tripleTapAction { unwrappedTripleTapAction() }
            tapCount = 0
        }
    }
    
    func dispatchTimeIdGenerator(deadline: Int) -> DispatchTime { return DispatchTime.now() + DispatchTimeInterval.milliseconds(deadline) }
    
}

extension View {
    func tapCountRecognizer(tapSensitivity: Int = 250, singleTapAction: (() -> Void)? = nil, doubleTapAction: (() -> Void)? = nil, tripleTapAction: (() -> Void)? = nil) -> some View {
        return self.modifier(TapCountRecognizerModifier(tapSensitivity: tapSensitivity, singleTapAction: singleTapAction, doubleTapAction: doubleTapAction, tripleTapAction: tripleTapAction))
    }
}


// MARK: 使用方式
struct testView: View {
    var body: some View {
        Rectangle()
            .tapCountRecognizer(tapSensitivity: 250, singleTapAction: singleTapAction, doubleTapAction: doubleTapAction, tripleTapAction: tripleTapAction)
    }

    func singleTapAction() {}
    
    func doubleTapAction() {}
    
    func tripleTapAction() {}
}