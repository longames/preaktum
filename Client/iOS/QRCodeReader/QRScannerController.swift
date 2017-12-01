//
//  QRScannerController.swift
//  QRCodeReader
//
//  Created by Nikita Aplin on 23/11/2017.
//  Copyright © 2017 Aplin. All rights reserved.
//

import UIKit
import AVFoundation

class QRScannerController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    @IBOutlet var messageLabel:UILabel!
    @IBOutlet var topbar: UIView!
    @IBOutlet weak var switchOutlet: UISwitch!
    @IBOutlet weak var barcodeLabel: UILabel!
    @IBOutlet weak var imageRecOutlet: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var shotButton: UIButton!
    struct global {
        static var products = ["text"]
    }
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    
    let supportedCodeTypes = [AVMetadataObject.ObjectType.upce,
                        AVMetadataObject.ObjectType.code39,
                        AVMetadataObject.ObjectType.code39Mod43,
                        AVMetadataObject.ObjectType.code93,
                        AVMetadataObject.ObjectType.code128,
                        AVMetadataObject.ObjectType.ean8,
                        AVMetadataObject.ObjectType.ean13,
                        AVMetadataObject.ObjectType.aztec,
                        AVMetadataObject.ObjectType.pdf417,
                        AVMetadataObject.ObjectType.qr]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //global.products.removeFirst()
        //print(global.products[0])
        tableView.isHidden = true
        // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video as the media type parameter.
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            
            // Initialize the captureSession object.
            captureSession = AVCaptureSession()
            
            // Set the input device on the capture session.
            captureSession?.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
            
            // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            // Start video capture.
            captureSession?.startRunning()
            
            // Move the message label and top bar to the front
            view.bringSubview(toFront: messageLabel)
            view.bringSubview(toFront: topbar)
            view.bringSubview(toFront: switchOutlet)
            view.bringSubview(toFront: barcodeLabel)
            view.bringSubview(toFront: imageRecOutlet)
            view.bringSubview(toFront: tableView)
            view.bringSubview(toFront: shotButton)

            // Initialize QR Code Frame to highlight the QR code
            qrCodeFrameView = UIView()
            
            if let qrCodeFrameView = qrCodeFrameView {
                /*qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
                qrCodeFrameView.layer.borderWidth = 2
                view.addSubview(qrCodeFrameView)
                view.bringSubview(toFront: qrCodeFrameView)*/
            }
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            //print(error)
            return
        }
        tableView.delegate = self as? UITableViewDelegate
        tableView.dataSource = self as? UITableViewDataSource
    }

    @IBAction func shot(_ sender: Any) {
        captureSession?.stopRunning()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func showTableView(_ sender: Any) {
        /*if(tableView.isHidden){
            self.captureSession?.stopRunning()
            tableView.isHidden = false
        }else{
            self.captureSession?.startRunning()
            tableView.isHidden = true
        }*/
    }
    // MARK: - AVCaptureMetadataOutputObjectsDelegate Methods
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            messageLabel.text = "No QR/barcode is detected"
            return
        }
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if supportedCodeTypes.contains(metadataObj.type) {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                messageLabel.text = metadataObj.stringValue
                // Create the alert controller
                let alertController = UIAlertController(title: "Title", message: "Price: $100", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Add", style: UIAlertActionStyle.default) {
                    UIAlertAction in
                    if(global.products[0] == "text"){
                        global.products.removeFirst()
                    }
                    global.products.append(metadataObj.stringValue!)
                    let json: [String: Any] = ["type": "add", "barcode": metadataObj.stringValue!]
                    self.getRequest(json: json)
                    print(metadataObj.stringValue!)
                    //productsStruct.countP += 1å
                    self.captureSession?.startRunning()
                    self.messageLabel.text = "No QR/barcode is detected"
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
                    UIAlertAction in
                    for x in global.products{
                        print(x)
                    }
                    self.captureSession?.startRunning()
                    self.messageLabel.text = "No QR/barcode is detected"
                }
                alertController.addAction(okAction)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
                captureSession?.stopRunning()
            }
        }
    }
    func getRequest(json: [String: Any]) -> String{
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        // create post request
        let url = URL(string: "http://13.95.174.54/server/request.php")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // insert json data to the request
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                print(responseJSON)
            }
        }
        
        task.resume()
        return "123"
    }
}
