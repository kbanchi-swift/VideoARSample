//
//  ViewController.swift
//  VideoARSample
//
//  Created by 伴地慶介 on 2021/11/13.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    var recordingButton: RecordingButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.scene = SCNScene()
        sceneView.isPlaying = true
        
        self.recordingButton = RecordingButton(self)
        
        let videoUrl = Bundle.main.url(forResource: "satou", withExtension: "mp4")!
        let videoNode = createVideoNode(size: 3.0, videoUrl: videoUrl)
        videoNode.position = SCNVector3(0, 0, -5.0)
        sceneView.scene.rootNode.addChildNode(videoNode)
        
        //        // Show statistics such as fps and timing information
        //        sceneView.showsStatistics = true
        //
        //        // Create a new scene
        //        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        //
        //        // Set the scene to the view
        //        sceneView.scene = scene
    }
    
    func createVideoNode(size:CGFloat, videoUrl: URL) -> SCNNode {
        // AVPlayerを生成する
        let avPlayer = AVPlayer(url: videoUrl)
        
        //ループ再生
        avPlayer.actionAtItemEnd = AVPlayer.ActionAtItemEnd.none;
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(ViewController.didPlayToEnd),
                                               name: NSNotification.Name("AVPlayerItemDidPlayToEndTimeNotification"),
                                               object: avPlayer.currentItem)
        // SKSceneを生成する
        let skScene = SKScene(size: CGSize(width: 1000, height: 1000)) // あまりサイズが小さいと、ビデオの解像度が落ちる
        
        // AVPlayerからSKVideoNodeの生成する（サイズは、skSceneと同じ大きさにする）
        let skNode = SKVideoNode(avPlayer: avPlayer)
        skNode.position = CGPoint(x: skScene.size.width / 2.0, y: skScene.size.height / 2.0)
        skNode.size = skScene.size
        skNode.yScale = -1.0 // 座標系を上下逆にする
        skNode.play() // 再生開始
        
        // SKSceneに、SKVideoNodeを追加する
        skScene.addChild(skNode)
        
        // Boxノードを生成して、マテリアルのSKSeceを適用する
        let node = SCNNode()
        node.geometry = SCNBox(width: size, height: size, length: size, chamferRadius: 0)
        let material = SCNMaterial()
        material.diffuse.contents = skScene
        node.geometry?.materials = [material]
        node.scale = SCNVector3(1.7, 1, 1) // サイズは横長
        return node
    }
    
    // ループ再生
    @objc func didPlayToEnd(notification: NSNotification) {
        let item: AVPlayerItem = notification.object as! AVPlayerItem
        item.seek(to: CMTime.zero, completionHandler: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK: - ARSCNViewDelegate
    
    /*
     // Override to create and configure nodes for anchors added to the view's session.
     func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
     let node = SCNNode()
     
     return node
     }
     */
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
