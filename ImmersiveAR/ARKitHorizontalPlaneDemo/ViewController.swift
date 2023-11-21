
import UIKit
import ARKit

class ViewController: UIViewController {
    
    @IBOutlet weak var sceneView: ARSCNView!
    var player: AVPlayer!
    var touched = false
    var timer: Timer?
      var currentIndex = 0
      let typingInterval = 0.1
    let messageText = "Wear headphones for a better experience"
    var videoPlayer: AVPlayer!
    var videoNode: SKVideoNode?
    var audioPlayer: AVAudioPlayer?
    let playButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let blurEffect = UIBlurEffect(style: .light)
              let blurView = UIVisualEffectView(effect: blurEffect)
              blurView.frame = view.bounds
              view.addSubview(blurView)
              
              let headphoneImageView = UIImageView(image: UIImage(systemName: "headphones"))
              headphoneImageView.tintColor = .black
              headphoneImageView.contentMode = .scaleAspectFit
        headphoneImageView.layer.cornerRadius = 10
        headphoneImageView.layer.shadowColor = UIColor.black.cgColor
        headphoneImageView.layer.shadowOpacity = 0.5
        headphoneImageView.layer.shadowOffset = CGSize(width: 0, height: 2)
        headphoneImageView.layer.shadowRadius = 2
              headphoneImageView.translatesAutoresizingMaskIntoConstraints = false
              blurView.contentView.addSubview(headphoneImageView)
              
              // Create a label with the message
              let messageLabel = UILabel()
              messageLabel.text = ""
              messageLabel.textColor = .black
              messageLabel.textAlignment = .center
              messageLabel.numberOfLines = 0
        messageLabel.layer.cornerRadius = 10
        messageLabel.layer.shadowColor = UIColor.black.cgColor
        messageLabel.layer.shadowOpacity = 0.5
        messageLabel.layer.shadowOffset = CGSize(width: 0, height: 2)
        messageLabel.layer.shadowRadius = 2
              messageLabel.translatesAutoresizingMaskIntoConstraints = false
              blurView.contentView.addSubview(messageLabel)
        startTypingEffect(label: messageLabel)
              
              // Center the image view
              NSLayoutConstraint.activate([
                  headphoneImageView.centerXAnchor.constraint(equalTo: blurView.contentView.centerXAnchor),
                  headphoneImageView.centerYAnchor.constraint(equalTo: blurView.contentView.centerYAnchor, constant: -30),
                  headphoneImageView.widthAnchor.constraint(equalToConstant: 50),
                  headphoneImageView.heightAnchor.constraint(equalToConstant: 50)
              ])
              
              // Center the label
              NSLayoutConstraint.activate([
                  messageLabel.centerXAnchor.constraint(equalTo: blurView.contentView.centerXAnchor),
                  messageLabel.centerYAnchor.constraint(equalTo: blurView.contentView.centerYAnchor, constant: 30),
                  messageLabel.leadingAnchor.constraint(equalTo: blurView.contentView.leadingAnchor, constant: 20),
                  messageLabel.trailingAnchor.constraint(equalTo: blurView.contentView.trailingAnchor, constant: -20)
              ])
              playAudio()
              // Set up a timer to dismiss the blur after 4 seconds
        Timer.scheduledTimer(withTimeInterval: 4.0, repeats: false) { _ in
            UIView.animate(withDuration: 7, animations: {
                blurView.alpha = 0.0
            }) { _ in
                blurView.removeFromSuperview()
                self.addVideoNode()
                let temporaryLabel = UILabel()
                        temporaryLabel.text = "Tap on Screen For More Immersive Experience"
                        temporaryLabel.textColor = .black
                        temporaryLabel.textAlignment = .center
                        temporaryLabel.numberOfLines = 0
                        temporaryLabel.layer.cornerRadius = 10
                        temporaryLabel.layer.shadowColor = UIColor.black.cgColor
                        temporaryLabel.layer.shadowOpacity = 0.5
                        temporaryLabel.layer.shadowOffset = CGSize(width: 4, height: 4)
                        temporaryLabel.layer.shadowRadius = 2
                        temporaryLabel.translatesAutoresizingMaskIntoConstraints = false
                        self.view.addSubview(temporaryLabel)

                        NSLayoutConstraint.activate([
                            temporaryLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                            temporaryLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 30),
                            temporaryLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
                            temporaryLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20)
                        ])

                        // Schedule the removal of the label after 4 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                            temporaryLabel.removeFromSuperview()
                        }
            }
        }
        
        addTapGestureToSceneView()
        configureLighting()
        
        let pauseButton = UIButton(type: .system)
        pauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        pauseButton.addTarget(self, action: #selector(pauseButtonTapped), for: .touchUpInside)
        pauseButton.tintColor = .white
        pauseButton.layer.cornerRadius = 10
        pauseButton.layer.shadowColor = UIColor.black.cgColor
        pauseButton.layer.shadowOpacity = 0.5
        pauseButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        pauseButton.layer.shadowRadius = 2
        
        pauseButton.frame = CGRect(x: view.bounds.width - 60, y: 20, width: 40, height: 40)
        view.addSubview(pauseButton)
        
        playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        playButton.tintColor = .white
        playButton.layer.cornerRadius = 10
        playButton.layer.shadowColor = UIColor.black.cgColor
        playButton.layer.shadowOpacity = 0.5
        playButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        playButton.layer.shadowRadius = 2
        
        playButton.frame = CGRect(x: view.bounds.width - 60, y: 70, width: 40, height: 40)
        playButton.isEnabled = false
        view.addSubview(playButton)
    }
    func startTypingEffect(label: UILabel) {
           timer = Timer.scheduledTimer(withTimeInterval: typingInterval, repeats: true) { timer in
               if self.currentIndex < self.messageText.count {
                   let index = self.messageText.index(self.messageText.startIndex, offsetBy: self.currentIndex)
                   let nextCharacter = String(self.messageText[index])
                   label.text?.append(nextCharacter)
                   self.currentIndex += 1
               } else {
                   // Typing effect completed, invalidate the timer
                   timer.invalidate()
               }
           }
       }
    
    func playAudio() {
           guard let audioURL = Bundle.main.url(forResource: "Trimmed", withExtension: "mp3") else {
               fatalError("Audio file not found")
           }

           do {
               audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
               audioPlayer?.prepareToPlay()
               audioPlayer?.play()
           } catch {
               print("Error playing audio: \(error.localizedDescription)")
           }
       }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpSceneView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    @available(iOS 11.3, *)
    func setUpSceneView() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        
        sceneView.session.run(configuration)
        
        sceneView.delegate = self
//        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    
    func configureLighting() {
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
    }
    
    @objc func pauseButtonTapped() {
        // Pause the video player
        videoPlayer.pause()
        playButton.isEnabled  = true
    }
    
    @objc func playButtonTapped() {
        // Pause the video player
        videoPlayer.play()
        playButton.isEnabled = false
    }
    
    @objc func addToSceneView(withGestureRecognizer recognizer: UIGestureRecognizer) {
       
        if !touched {
            touched = true
            let tapLocation = recognizer.location(in: sceneView)
            let hitTestResults = sceneView.hitTest(tapLocation, types: .featurePoint)
            
            guard let hitTestResult = hitTestResults.first else { return }
            let translation = hitTestResult.worldTransform.translation
            let x = translation.x
            let y = translation.y
            let z = translation.z
            
            
            
            let fileUrl = URL(fileURLWithPath: Bundle.main.path(forResource: "Spatial", ofType: "mp4")!)
            player = AVPlayer(url: fileUrl)
            let tvGeo = SCNSphere(radius: 80)
            tvGeo.firstMaterial?.diffuse.contents = player
            tvGeo.firstMaterial?.isDoubleSided = true
            
//            player.seek(to:CMTimeMakeWithSeconds(100,1000))
            
            let tvNode = SCNNode(geometry: tvGeo)
            
            tvNode.position = SCNVector3(x,y,z)
            tvGeo.firstMaterial?.diffuse.contentsTransform = SCNMatrix4Translate(SCNMatrix4MakeScale(-1, 1, 1), 1, 0, 0)
            sceneView.scene.rootNode.addChildNode(tvNode)
            videoPlayer.pause()
            player.play()
            
            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: videoPlayer.currentItem, queue: nil) { _ in
                self.player.seek(to: CMTimeMakeWithSeconds(0, 100))
                self.player.play()
            }
            
        }
        else {
            touched = true
            
        }
        
    }
    
    func addVideoNode() {
        guard let videoURL = Bundle.main.url(forResource: "NG", withExtension: "mp4") else {
            fatalError("Video file not found")
        }
        
        videoPlayer = AVPlayer(url: videoURL)
        let videoScene = SKScene(size: CGSize(width: 1280, height: 720)) // Adjust the size based on your video dimensions
        
        videoNode = SKVideoNode(avPlayer: videoPlayer)
        videoNode?.position = CGPoint(x: videoScene.size.width / 2, y: videoScene.size.height / 2)
        videoNode?.size = CGSize(width: 1920, height: 1080)
        videoNode?.yScale = -1.0 // Flip the video to match ARKit's coordinate system
        
        videoScene.addChild(videoNode!)
        
        let plane = SCNPlane(width: 2.0, height: 1.0) // Adjust the size based on your desired plane size
        plane.firstMaterial?.diffuse.contents = videoScene
        
        let planeNode = SCNNode(geometry: plane)
        planeNode.position = SCNVector3(0, 0, -2) // Adjust the position based on your scene
        
        sceneView.scene.rootNode.addChildNode(planeNode)
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: videoPlayer.currentItem, queue: nil) { _ in
            self.videoPlayer.seek(to: CMTime(seconds: 0, preferredTimescale: 1000))
            self.videoPlayer.play()
        }
        
        videoPlayer.play()
        
    }
    
    
    
    func addTapGestureToSceneView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.addToSceneView(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
        
        
    }
}

extension float4x4 {
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}

extension UIColor {
    public class var transparentLightBlue: UIColor {
        return UIColor(red: 90/255, green: 200/255, blue: 250/255, alpha: 0.50)
    }
}

extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // 1
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        // 2
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        let plane = SCNPlane(width: width, height: height)
        
        // 3
        plane.materials.first?.diffuse.contents = UIColor.transparentLightBlue
        
        // 4
        let planeNode = SCNNode(geometry: plane)
        
        // 5
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x,y,z)
        planeNode.eulerAngles.x = -.pi / 2
        
        // 6
        //        node.addChildNode(planeNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // 1
        guard let planeAnchor = anchor as?  ARPlaneAnchor,
              let planeNode = node.childNodes.first,
              let plane = planeNode.geometry as? SCNPlane
        else { return }
        
        // 2
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        plane.width = width
        plane.height = height
        
        // 3
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x, y, z)
    }
}
