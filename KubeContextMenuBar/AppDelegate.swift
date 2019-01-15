import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    
    let statusItem = NSStatusBar.system.statusItem(withLength: 1)
    
    // last known modification date of the kube config
    var lastKubeConfigUpdate = Date.init(timeIntervalSince1970: 0)
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        Util.BG {
            let kubeConfigPath = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".kube/config")
            if (FileManager.default.fileExists(atPath: kubeConfigPath.path)) {
                Util.fireEverySecond {
                    self.checkOnKubeConfig(at: kubeConfigPath)
                }
            }
            
            // there is no kube config, nothing to do
            NSApplication.shared.terminate(self)
        }
    }
    
    // check whether kube config has been updated and read new data if yes
    func checkOnKubeConfig(at: URL) {
        do {
            let attr = try FileManager.default.attributesOfItem(atPath: at.path)
            if let kubeConfigUpdate = attr[FileAttributeKey.modificationDate] as? Date {
                if (kubeConfigUpdate > self.lastKubeConfigUpdate) {
                    readKubeConfig(at: at)
                }
                self.lastKubeConfigUpdate = kubeConfigUpdate
            }
        }
        catch {
            print(error)
        }
    }
    
    // read data from kube config, extract current context and display it in the UI
    func readKubeConfig(at: URL) {
        do {
            let kubeConfig = try String(contentsOf: at, encoding: .utf8)
            kubeConfig.enumerateLines { line, _ in
                if (line.hasPrefix("current-context: ")) {
                    let startOfContextInd = line.index(line.range(of: ":")!.lowerBound, offsetBy: 2)
                    let title = String(line[startOfContextInd...].replacingOccurrences(of: "_", with: "   "))
                    
                    // display the context in the UI
                    Util.UI {
                        if let button = self.statusItem.button {
                            button.title = title
                            self.statusItem.length = button.fittingSize.width
                        }
                    }
                }
            }
        } catch {
            print(error)
        }
    }
}
