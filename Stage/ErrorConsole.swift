//
//  ErrorConsole.swift
//  Stage
//
//  Copyright © 2016 David Parton
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
//  associated documentation files (the "Software"), to deal in the Software without restriction,
//  including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies
//  or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
//  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE
//  AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
//  DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import Foundation
import UIKit

final class ErrorConsoleWindow: UIWindow {
    private weak var restoreWindow: UIWindow?
    override var hidden: Bool {
        didSet {
            if hidden {
                if let restoreWindow = restoreWindow { restoreWindow.makeKeyAndVisible() }
                rootViewController = nil
                restoreWindow = nil
            }
            else {
                rootViewController = ErrorConsoleRootViewController()
                restoreWindow = UIApplication.sharedApplication().keyWindow
                if let window = restoreWindow {
                    if window == self { restoreWindow = nil }
                    restoreWindow?.hidden = true
                }
            }
        }
    }

    override func becomeKeyWindow() {
        rootViewController = ErrorConsoleRootViewController()
        super.becomeKeyWindow()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        windowLevel = UIWindowLevelStatusBar
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        windowLevel = UIWindowLevelStatusBar
    }
}

public class ErrorConsole : StageDefinitionErrorListener {
    let window = ErrorConsoleWindow(frame: UIScreen.mainScreen().bounds)

    public init() { }
    public func error(exception: StageException) {
        window.makeKeyAndVisible()
        (window.rootViewController as? ErrorConsoleRootViewController)?.error(exception)
    }
}

public class ErrorConsoleRootViewController: UIViewController, StageDefinitionErrorListener {
    var messages: [String] = []
    var messagesView: StackingView?
    var definition: StageDefinition?

    init() {
        super.init(nibName: nil, bundle: nil)
        let factory = DefaultDefinitionFactory()
        definition = try! factory.build(data: errorConsoleDefinition.dataUsingEncoding(NSUTF8StringEncoding)!)
    }
    public required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented: \(#function)")
    }

    public override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if isViewLoaded() && motion == .MotionShake {
            view.window?.hidden = true
            view.window?.rootViewController = nil
        }
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        struct Mapping: StageViewMapping {
            let messages: StackingView
            init(map: Mapper) throws {
                messages = try map.view(named: "MessageStack")
            }
        }
        let ctxt = try! definition!.load(viewHierarchy: "ErrorConsole") { (mapping: Mapping) in
            messagesView = mapping.messages
        }
        try! ctxt.addAsSubview(of: view)
    }

    public func error(exception: StageException) {
        let backtrace: [String], consoleMessage: String
        switch exception {
        case .InvalidViewType(let message, let bt):
            consoleMessage = "Invalid view type\n\(message)"
            backtrace = bt
        case .ResourceNotAvailable(let name, let message, let bt):
            consoleMessage = "Resource not available: \(name)\n\(message)"
            backtrace = bt
        case .UnhandledProperty(let message, let line, let bt):
            consoleMessage = "Unhandled property on line \(line)\n\(message)"
            backtrace = bt
        case .UnknownView(let message, let bt):
            consoleMessage = "Unknown view\n\(message)"
            backtrace = bt
        case .UnknownViewHierarchy(let message, let bt):
            consoleMessage = "Unknown view hierarchy\n\(message)"
            backtrace = bt
        case .UnrecognizedContent(let message, let line, let bt):
            consoleMessage = "Unrecognized content on line \(line)\n\(message)"
            backtrace = bt
        case .InvalidDataEncoding(let bt):
            consoleMessage = "\(exception)"
            backtrace = bt
        }
        messages.append("\(consoleMessage)\n\(backtrace.map { "  ...\($0)" }.joinWithSeparator("\n"))")
        messagesView?.removeAllSubviews()
        messages.forEach { msg in
            struct Mapping: StageViewMapping {
                let label: UILabel
                init(map: Mapper) throws {
                    label = try map.view(named: "Message")
                }
            }
            try! definition!.load(viewHierarchy: "MessageViewHierarchy") { (mapping: Mapping) in
                mapping.label.text = msg
            }.addAsSubview(of: messagesView!)
        }
    }
}

let errorConsoleDefinition: String = { [
    "ErrorConsole:",
    "  ScrollView",
    "    ContentStack",
    "      MessageStack",
    "      ShakeToReload",
    "",
    "ErrorConsole:",
    "  .backgroundColor = red",
    "",
    "ScrollView:",
    "  .class = UIScrollView",
    "  .constrainToSuperviewEdges = YES",
    "",
    "ContentStack:",
    "  .class = Stage.StackingView",
    "  .constrainToSuperviewEdges = YES",
    "  .layoutAttributes =",
    "    width == ErrorConsole.width",
    "",
    "MessageStack:",
    "  .class = Stage.StackingView",
    "  .spacing = 13",
    "  .contentInset = { 40, 13, 13, 13 }",
    "  .layoutAttributes =",
    "    width == ErrorConsole.width",
    "",
    "ShakeToReload:",
    "  .class = UILabel",
    "  .font = 14 Menlo",
    "  .numberOfLines = 2",
    "  .text = Shake (^⌘Z) to hide console",
    "      Shake again to reload",
    "  .textAlignment = center",
    "  .textColor = #660000",
    "  .layoutAttributes =",
    "",
    "MessageViewHierarchy:",
    "  Message",
    "",
    "Message:",
    "  .class = UILabel",
    "  .font = 10 Menlo-Bold",
    "  .textColor = white",
    "  .shadowColor = black",
    "  .shadowOpacity = 0.4",
    "  .shadowOffset = { 1, 1 }",
    "  .shadowRadius = 0.5",
    "  .numberOfLines = 0",
    "  .layoutAttributes =",
    "",
].joinWithSeparator("\n") }()
