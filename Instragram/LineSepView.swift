//
//  LineSepView.swift
//  Instragram
//
//  Created by ZJH on 2018/10/20.
//  Copyright © 2018年 Akhmed Idigov. All rights reserved.
//

import UIKit

class LineSepView: UIView,UIGestureRecognizerDelegate{
    var cameraClickCallback:(() -> ())?
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clear
        
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        
        guard let context = UIGraphicsGetCurrentContext() else {return}
        
        let width = rect.size.width
        let height = rect.size.height
        
        let path = CGMutablePath()
        path.move(to:CGPoint(x:width/3.0, y:0))
        path.addLine(to:CGPoint(x:width/3.0, y:height))
        
        path.move(to:CGPoint(x:width/3.0*2, y:0))
        path.addLine(to:CGPoint(x:width/3.0*2, y:height))
        
        path.move(to:CGPoint(x:0, y:height/3.0))
        path.addLine(to:CGPoint(x:width, y:height/3.0))
        
        path.move(to:CGPoint(x:0, y:height/3.0*2))
        path.addLine(to:CGPoint(x:width, y:height/3.0*2))
        
        context.addPath(path)
        
        context.setStrokeColor(UIColor.white.cgColor)
        
        context.setLineWidth(1)
        
        context.strokePath()
    }
    
    required init?(coder aDecoder:NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        let subview = self.viewWithTag(100)
        if (subview != nil) {
            let convertpoint = subview?.convert(point, from: self)
            if (subview?.point(inside: convertpoint!, with: event))!{
                if self.cameraClickCallback != nil {
                    self.cameraClickCallback!()
                }
                print("hitTest111")
            }
        }
        
        let result = super.hitTest(point, with: event)
        return result;
    }
}
