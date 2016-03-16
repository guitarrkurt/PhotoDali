//
//  PopoverViewController.swift
//  Photo Dali
//
//  Created by guitarrkurt on 08/03/16.
//  Copyright © 2016 guitarrkurt. All rights reserved.
//

import UIKit
protocol popoverDelegate{
    func settingsPencil(grosor: CGFloat, transparencia: CGFloat)
}
class PopoverViewController: UIViewController {
    var delegate: popoverDelegate? = nil
    @IBOutlet weak var porcentajeGrosor: UILabel!
    @IBOutlet weak var porcentajeTransparencia: UILabel!
    @IBOutlet weak var sliderGrosor: UISlider!
    @IBOutlet weak var sliderTransparencia: UISlider!
    @IBOutlet weak var imageView: UIImageView!
    
    
    var grosor: CGFloat = 10.0
    var transparencia: CGFloat = 1.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func sliderChanged(sender: UISlider) {
        if sender == sliderGrosor {
            grosor = CGFloat(sender.value)
            porcentajeGrosor.text = "\(NSString(format: "%.0f", grosor.native) as String)%"
        } else {
            transparencia = CGFloat(sender.value)
            porcentajeTransparencia.text = "\(NSString(format: "%.0f", transparencia.native*100) as String)%"
        }
        drawPreview()
    }
    
    func drawPreview() {
        UIGraphicsBeginImageContext(imageView.frame.size)
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetLineCap(context, CGLineCap.Round)
        CGContextSetLineWidth(context, grosor)
        
        //        CGContextSetRGBStrokeColor(context, red, green, blue, transparencia)
        CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, transparencia)
        
        CGContextStrokePath(context)
        
        CGContextMoveToPoint(context, 45.0, 45.0)
        CGContextAddLineToPoint(context, 45.0, 45.0)
        
        //CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, transparencia)
        
        CGContextStrokePath(context)
        imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        
        let esclavo = storyboard?.instantiateViewControllerWithIdentifier("canvasVC") as! CanvasViewController
        
        
        esclavo.settingsPencil(grosor, transparencia: transparencia)
        
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
    
}
