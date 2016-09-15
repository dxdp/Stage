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
    fileprivate weak var restoreWindow: UIWindow?
    override var isHidden: Bool {
        didSet {
            if isHidden {
                if let restoreWindow = restoreWindow { restoreWindow.makeKeyAndVisible() }
                rootViewController = nil
                restoreWindow = nil
            }
            else {
                rootViewController = ErrorConsoleRootViewController()
                restoreWindow = UIApplication.shared.keyWindow
                if let window = restoreWindow {
                    if window == self { restoreWindow = nil }
                    restoreWindow?.isHidden = true
                }
            }
        }
    }

    override func becomeKey() {
        rootViewController = ErrorConsoleRootViewController()
        super.becomeKey()
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

open class ErrorConsole : StageDefinitionErrorListener {
    let window = ErrorConsoleWindow(frame: UIScreen.main.bounds)

    public init() { }
    open func error(_ exception: StageException) {
        window.makeKeyAndVisible()
        (window.rootViewController as? ErrorConsoleRootViewController)?.error(exception)
    }
    open func trap<T>(_ code: (Void) throws -> T) -> T? {
        do {
            return try code()
        } catch let ex as StageException {
            error(ex)
        } catch {
        }
        return nil
    }
}

open class ErrorConsoleRootViewController: UIViewController, StageDefinitionErrorListener {
    var messages: [String] = []
    var messagesView: StackingView?
    var definition: StageDefinition?

    init() {
        super.init(nibName: nil, bundle: nil)
        let factory = DefaultDefinitionFactory()
        definition = try! factory.build(data: errorConsoleDefinition.data(using: String.Encoding.utf8)!)
    }
    public required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented: \(#function)")
    }

    open override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if isViewLoaded && motion == .motionShake {
            view.window?.isHidden = true
            view.window?.rootViewController = nil
        }
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        struct Mapping: StageViewMapping {
            let messages: StackingView
            init(map: Mapper) throws {
                messages = try map.view(named: "MessageStack")
            }
        }
        _ = try? definition!.load(viewHierarchy: "ErrorConsole") { (mapping: Mapping) in
            messagesView = mapping.messages
        }.addAsSubview(of: view)
    }

    open func error(_ exception: StageException) {
        let backtrace: [String], consoleMessage: String
        switch exception {
        case .invalidViewType(let message, let bt):
            consoleMessage = "Invalid view type\n\(message)"
            backtrace = bt
        case .resourceNotAvailable(let name, let message, let bt):
            consoleMessage = "Resource not available: \(name)\n\(message)"
            backtrace = bt
        case .unhandledProperty(let message, let line, let bt):
            consoleMessage = "Unhandled property on line \(line)\n\(message)"
            backtrace = bt
        case .unknownView(let message, let bt):
            consoleMessage = "Unknown view\n\(message)"
            backtrace = bt
        case .unknownViewHierarchy(let message, let bt):
            consoleMessage = "Unknown view hierarchy\n\(message)"
            backtrace = bt
        case .unrecognizedContent(let message, let line, let bt):
            consoleMessage = "Unrecognized content on line \(line)\n\(message)"
            backtrace = bt
        case .invalidDataEncoding(let bt):
            consoleMessage = "\(exception)"
            backtrace = bt
        }
        let messageContainer = messagesView ?? UIView()
        messages.append("\(consoleMessage)\n\(backtrace.map { "  ...\($0)" }.joined(separator: "\n"))")
        messagesView?.removeAllSubviews()
        messages.forEach { msg in
            struct Mapping: StageViewMapping {
                let label: UILabel
                init(map: Mapper) throws {
                    label = try map.view(named: "Message")
                }
            }
            _ = try? definition!.load(viewHierarchy: "MessageViewHierarchy") { (mapping: Mapping) in
                mapping.label.text = msg
            }.addAsSubview(of: messageContainer)
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
].joined(separator: "\n") }()
