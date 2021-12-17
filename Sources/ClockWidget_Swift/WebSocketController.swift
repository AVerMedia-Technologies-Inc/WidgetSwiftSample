//
//  WebSocketController.swift
//  ClockWidget_Swift
//
//  Created by ShihPing on 2021/10/13.
//

import Foundation

protocol WebSocketControllerDelegate: NSObjectProtocol {
    func receive(string: String)
    func receive(data: Data)
    func connectSuccess()
    func disconnect()
    func parseJsonError(string: String)
}

class WebSocketController: NSObject {
    var urlSession: URLSession?
    var webSocketTask: URLSessionWebSocketTask?
    
    weak var delegate: WebSocketControllerDelegate?
    
    override init() {
        super.init()
        urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
    }
    
    func connect(urlString: String) {
        guard let url = URL(string: urlString) else {
            print("Error: can not create URL")
            return
        }
        
        webSocketTask = (urlSession?.webSocketTask(with: url))!
        webSocketTask?.resume()
        
        receive()
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
    }
    
    func send(data: Data) {
        //Creator Central receive String type. If send Data type will not working.
        let str = String(decoding: data, as: UTF8.self)
        let message = URLSessionWebSocketTask.Message.string(str)
        webSocketTask?.send(message) { error in
            if let error = error {
                print(error)
            } else {
                print("done")
            }
        }
    }
    
    func receive() {
        webSocketTask?.receive { result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    self.delegate?.receive(string: text)
                case .data(let data):
                    self.delegate?.receive(data: data)
                @unknown default:
                    fatalError()
                }

            case .failure(let error):
                print("receive [failure]")
                print(error)
            }

            self.receive()
        }
    }
}

extension WebSocketController: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("URLSessionWebSocketTask is connected")
        delegate?.connectSuccess()
    }

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        let reasonString: String
        if let reason = reason, let string = String(data: reason, encoding: .utf8) {
            reasonString = string
        } else {
            reasonString = ""
        }

        print("URLSessionWebSocketTask is closed: code=\(closeCode), reason=\(reasonString)")
        delegate?.disconnect()
    }
}
