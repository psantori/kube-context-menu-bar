import Foundation

class Util {
    
    // run action in the background
    static func BG(_ action: @escaping ()->Void) {
        DispatchQueue.global(qos: .default).async(execute: action)
    }
    
    // run action on the main thread
    static func UI(_ action: @escaping ()->Void) {
        DispatchQueue.main.async(execute: action)
    }
    
    // fire action every second (infinitely)
    static func fireEverySecond(_ action: @escaping ()->Void) {
        while (true) {
            action();
            sleep(1);
        }
    }
}
