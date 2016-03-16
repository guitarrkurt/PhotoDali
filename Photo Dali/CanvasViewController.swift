//
//  CanvasViewController.swift
//  Photo Dali
//
//  Created by guitarrkurt on 07/03/16.
//  Copyright © 2016 guitarrkurt. All rights reserved.
//

import UIKit

class CanvasViewController: UIViewController, UIPopoverPresentationControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, popoverDelegate {
    
    //Mark: - Propertys
    
    /*Protocolo CAMERA*/
    var imagePicker: UIImagePickerController!
    
    /*Canvas*/
    @IBOutlet weak var firstImageView: UIImageView!
    @IBOutlet weak var secondImageView: UIImageView!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    /*Contents View*/
    @IBOutlet weak var contentViewPencils: UIView!
    @IBOutlet weak var contentViewTabBar: UIView!
    
    /*Persistencia Datos*/
    let banderaTapGesture = NSUserDefaults.standardUserDefaults()
    var persistenciaGrosor = NSUserDefaults.standardUserDefaults()
    var persistenciaTransparencia = NSUserDefaults.standardUserDefaults()
    var respaldoImage: UIImage!
    
    /*Colors*/
    var lastPoint = CGPoint.zero
    var red: CGFloat = 0.0
    var green: CGFloat = 0.0
    var blue: CGFloat = 0.0
    var brushWidth: CGFloat = 10.0
    var opacity: CGFloat = 1.0
    var swiped = false
    
    let colors: [(CGFloat, CGFloat, CGFloat)] = [
        (0, 0, 0),
        (105.0 / 255.0, 105.0 / 255.0, 105.0 / 255.0),
        (1.0, 0, 0),
        (0, 0, 1.0),
        (51.0 / 255.0, 204.0 / 255.0, 1.0),
        (102.0 / 255.0, 204.0 / 255.0, 0),
        (102.0 / 255.0, 1.0, 0),
        (160.0 / 255.0, 82.0 / 255.0, 45.0 / 255.0),
        (1.0, 102.0 / 255.0, 0),
        (1.0, 1.0, 0),
        (1.0, 1.0, 1.0),
    ]
    
    //Mark: - Constructor
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hiddenPencils()
        
        //Diseno content view pencils
        contentViewPencils.layer.cornerRadius = 8.0
        
        //Add Tap Gesture Content View Pencils
        let tap = UITapGestureRecognizer(target: self, action: "handleTap:")
        contentViewPencils.addGestureRecognizer(tap)
        
        //Inicializar la BANDERA
        banderaTapGesture.setBool(true, forKey: "estado")
        
        //Inicializar GROSOR y TRANSPARENCIA
        persistenciaGrosor.setFloat(1.0, forKey: "grosor")
        persistenciaTransparencia.setFloat(1.0, forKey: "transparencia")
    }
    
    //Funcion que maneja el gesto del TAP en la CAJA_DE_COLORES, es decir, View que contiene los colores
    func handleTap(sender: UITapGestureRecognizer) {
        //Obtenemos el tamano de la pantalla para medir cuanto se muestra/oculta nuestra paleta de colores
        let screenHeight = UIScreen.mainScreen().bounds.height
        //Desplazamiento de la paleta de colores
        var offsetYAbajo: CGFloat!
        var offsetYArriba: CGFloat!
        
        //Si es modelo mas chico que el iphone 6
        if(screenHeight < 667.0){
            offsetYAbajo = contentViewPencils.center.y + (UIScreen.mainScreen().bounds.height/4.5)
            offsetYArriba = contentViewPencils.center.y - (UIScreen.mainScreen().bounds.height/4.5)
        }
            //Si es el iphone 6 o 6 plus pero menor que el Ipad en portrair. PS: Ipad en landscape si entra aqui
        else if(screenHeight >= 667.0 && screenHeight < 1024.0){
            offsetYAbajo = contentViewPencils.center.y + (UIScreen.mainScreen().bounds.height/6.0)
            offsetYArriba = contentViewPencils.center.y - (UIScreen.mainScreen().bounds.height/6.0)
        }
            //Si es el ipad en portrair
        else{
            offsetYAbajo = contentViewPencils.center.y + (UIScreen.mainScreen().bounds.height/9.0)
            offsetYArriba = contentViewPencils.center.y - (UIScreen.mainScreen().bounds.height/9.0)
        }
        
        //Checamos la bandera para Subir/Bajar la paleta de colores
        if(banderaTapGesture.boolForKey("estado") == true){
            //Abajo
            print("Abajo")
            banderaTapGesture.setBool(false, forKey: "estado")
            contentViewPencils.center = CGPoint(x: UIScreen.mainScreen().bounds.width/2, y: offsetYAbajo)
        } else {
            //Arriba
            print("Arriba")
            banderaTapGesture.setBool(true, forKey: "estado")
            contentViewPencils.center = CGPoint(x: UIScreen.mainScreen().bounds.width/2, y: offsetYArriba)
        }
    }
    
    //Mientras esta haciendo el cambio de orientacion, solo aplica para iPad
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.currentDevice().orientation.isLandscape.boolValue {
            print("Landscape")
            banderaTapGesture.setBool(true, forKey: "estado")
        } else {
            print("Portrait")
            banderaTapGesture.setBool(true, forKey: "estado")
        }
    }
    
    //Mark: - Camera
    @IBAction func buttonCamera(sender: UIButton) {
        useCamera()
    }
    
    func useCamera(){
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .Camera
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    //Mark: - Gallery
    func loadImageButtonTapped(){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .PhotoLibrary
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    //Este metodo lo comparte tanto CAMERA como GALLERY
    internal func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]){
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            //SCALE_ASPECT_FIT conserva su tamaño y lo escala al MARGEN/MARCO que se le presente
            //SCALE_TO_FILL rellena todo el MARGEN/MARCO
            //            secondImageView.contentMode = .ScaleAspectFit
            secondImageView.contentMode  = .ScaleToFill
            respaldoImage = pickedImage
            secondImageView.image = pickedImage
            
            banderaTapGesture.setBool(true, forKey: "estado")
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //Baja la vista despues de tomar la foto
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func galleryButtonAction(sender: UIButton) {
        loadImageButtonTapped()
    }
    // MARK: - Done Button Action
    @IBAction func doneButtonAction(sender: UIBarButtonItem) { //Terminamos de editar y queremos guardar o compartir
        
        //Ocultamos los lapices
        hiddenPencils()
        
        //Propertys
        let hightScreen = UIScreen.mainScreen().bounds.height
        let widthScreen = UIScreen.mainScreen().bounds.width
        
        //Guardamos en un Auxiliar nuestra obra de arte
        UIGraphicsBeginImageContext(secondImageView.bounds.size)
        secondImageView.image?.drawInRect(CGRect(x: 0, y: 0,
            width: secondImageView.frame.size.width, height: secondImageView.frame.size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //Preguntamos si es iPad o iPhon ya que por el tamano de la pantalla en el primero hace un
        //ALERT_ACCION_SHEET y ocupa toda la pantalla a diferencia del iPad que usa un POPOVER
        if((hightScreen >= 1024 && widthScreen >= 768) || (hightScreen >= 768 && widthScreen >= 1024)){
            print("iPad")
        
            let activity = UIActivityViewController(activityItems: [image], applicationActivities: nil)

            let popup: UIPopoverController = UIPopoverController(contentViewController: activity)
            popup.presentPopoverFromRect(CGRectMake(self.view.frame.size.width / 2, self.view.frame.size.height / 4, 0, 0), inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Unknown, animated: true)
            
        }else{
            print("iPhone")
            
            let activity = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            presentViewController(activity, animated: true, completion: nil)
        }

        //Nos muestra nuestro CONTENEDOR de opciones: elegir foto, tomar foto, editar
        showTabBar()
    }
    
    // MARK: - Draw
    @IBAction func drawPencilButtonAction(sender: UIButton) {//Al pintar oculatamos el CONTENEDOR de opciones y mostramos solo los colores
        hiddenTabBar()
        showPencils()
    }
    
    // MARK: - Popover
    @IBAction func settingsButtonAction(sender: UIBarButtonItem) { //POPOVER SETTINGS: ancho y transparencia
            
            let screenHeight = UIScreen.mainScreen().bounds.height
            let VC = storyboard?.instantiateViewControllerWithIdentifier("popoverController") as! PopoverViewController
            
            //Si es modelo mas chico que el iphone 6
            if(screenHeight < 667.0){
                VC.preferredContentSize = CGSize(width: UIScreen.mainScreen().bounds.width/1.5, height: UIScreen.mainScreen().bounds.height/1.5)
            }
                //Si es el iphone 6 o 6 plus pero menor que el Ipad en portrair. PS: Ipad en landscape si entra aqui
            else if(screenHeight >= 667.0 && screenHeight < 1024.0)
            {
                VC.preferredContentSize = CGSize(width: UIScreen.mainScreen().bounds.width/2, height: UIScreen.mainScreen().bounds.height/2)
            }
                //Si es el ipad en portrair
            else{
                VC.preferredContentSize = CGSize(width: UIScreen.mainScreen().bounds.width/2, height: UIScreen.mainScreen().bounds.height/2)
            }
            
            let navController = UINavigationController(rootViewController: VC)
            navController.modalPresentationStyle = UIModalPresentationStyle.Popover
            
            let popover = navController.popoverPresentationController
            popover?.delegate = self
            
            popover?.barButtonItem = sender
            self.presentViewController(navController, animated: true, completion: nil )

    }
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    internal func popoverPresentationControllerDidDismissPopover(popoverPresentationController: UIPopoverPresentationController){
        
        print("hizo dismiss")
    }
    
    // MARK: - Another Functions
    func hiddenPencils(){
        contentViewPencils.hidden = true
    }
    func showPencils(){
        contentViewPencils.hidden = false
    }
    func hiddenTabBar(){
        contentViewTabBar.hidden = true
    }
    func showTabBar(){
        contentViewTabBar.hidden = false
    }

    // MARK: - Draw
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        swiped = false
        
        let touch = touches.first! as UITouch
        lastPoint = touch.locationInView(self.view)
        
        //LA LINEA DE ABAJO GENERA UN PUNTO, PERO CUANDO BAJAMOS NUESTRA CAJA DE COLORES HAY UN BUG⚠️
        //drawLineFrom(lastPoint, toPoint: lastPoint)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // 6
        swiped = true
        
        let touch = touches.first! as UITouch
        
        let currentPoint = touch.locationInView(view)
        drawLineFrom(lastPoint, toPoint: currentPoint)
        
        // 7
        lastPoint = currentPoint
    }
    func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint) {
        // 1
        UIGraphicsBeginImageContext(view.frame.size)
        
        let context = UIGraphicsGetCurrentContext()
        secondImageView.image?.drawInRect(CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        
        // 2
        CGContextMoveToPoint(context, fromPoint.x, fromPoint.y)
        CGContextAddLineToPoint(context, toPoint.x, toPoint.y)
        
        // 3
        CGContextSetLineCap(context, CGLineCap.Round)
        CGContextSetLineWidth(context, CGFloat(persistenciaGrosor.floatForKey("grosor")))
        CGContextSetRGBStrokeColor(context, red, green, blue, CGFloat(persistenciaTransparencia.floatForKey("transparencia")))

        CGContextSetBlendMode(context, CGBlendMode.Normal)
        
        // 4
        CGContextStrokePath(context)
        
        // 5
        secondImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        secondImageView.alpha = opacity
        
        UIGraphicsEndImageContext()
    }
    
    @IBAction func pencilPressed(sender: AnyObject) {
        //Los botones de los lapices usaron TAGS del 0 al 11, modificadas desde la parte grafica
        var index = sender.tag ?? 0
        if index < 0 || index >= colors.count {
            index = 0
        }
        //Tupla
        (red, green, blue) = colors[index]
        //Si el INDEX es 10, es color BLANCO y nuestra CAJA_DE_COLORES la ponemos en NEGRO para que no se distorcione
        if(index == 10){
            contentViewPencils.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.8)
        }
        //Sino ponemos la CAJA_DE_COLORES del color seleccionado
        else{
            contentViewPencils.backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: 0.8)
        }
        //Cuando seleecionamos un nuevo color se quita la TRANSPARENCIA
        if index == colors.count - 1 {
            opacity = 1.0
        }
    }

    // MARK: - Agitar y Borrar
    override func motionBegan(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == .MotionShake {
            banderaTapGesture.setBool(true, forKey: "estado")
            secondImageView.image = respaldoImage
        }
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    // MARK: - Protocolo de POPOVER_VIEW_CONTROLLER
    func settingsPencil(grosor: CGFloat, transparencia: CGFloat){
        print("grosor: \(grosor), transparencia: \(transparencia)")
        self.brushWidth = grosor
        print("brushWidth: \(brushWidth)")
        self.opacity = transparencia
        print("opacity: \(opacity)")
        
        
        persistenciaGrosor.setFloat(Float(grosor), forKey: "grosor")
        self.opacity = CGFloat(persistenciaTransparencia.setFloat(Float(transparencia), forKey: "transparencia"))
    
        
    }
    
}



