//
//  Extenstions.swift
//  MeetingRooms
//
//  Created by Oliver Victor Wang Hansen on 15/05/2015.
//  Copyright (c) 2015 Nodes. All rights reserved.
//

import UIKit


// MARK: - UI
extension CGRect {
    var y: CGFloat {
        set {
            self = CGRect(origin: CGPointMake(origin.x, newValue), size: size)
        }
        get {
            return self.origin.y
        }
    }
    
    var x: CGFloat {
        set {
            self = CGRect(origin: CGPointMake(newValue, origin.y), size: size)
        }
        get {
            return self.origin.x
        }
    }
    
    var height: CGFloat {
        set {
            self = CGRect(origin: origin, size: CGSize(width: size.width, height: newValue))
        }
        get {
            return self.size.height
        }
    }
    
    var width: CGFloat {
        set {
            self = CGRect(origin: origin, size: CGSize(width: newValue, height: self.height))
        }
        get {
            return self.size.width
        }
    }
    
    func rectByReversingSize() -> CGRect {
        return CGRect(origin: self.origin, size: CGSizeMake(self.height, self.width))
    }
}

public func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

public func * (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x * right.x, y: left.y * right.y)
}

public func / (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x / right.x, y: left.y / right.y)
}

public func / (left: CGPoint, right: CGFloat) -> CGPoint {
    return CGPoint(x: left.x / right, y: left.y / right)
}

extension UIView {
    func setPosition(center: CGPoint, size: CGSize) {
        self.bounds = CGRect(x:0, y: 0, width: size.width, height: size.height)
        self.center = center
    }
    
    func roundCorners(corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.CGPath
        self.layer.mask = mask
    }
    
    class func loadFromNibNamed(nibNamed: String, bundle : NSBundle? = nil) -> UIView? {
        return UINib(
            nibName: nibNamed,
            bundle: bundle
            ).instantiateWithOwner(nil, options: nil)[0] as? UIView
    }
    
    
    func startGlow(colour:UIColor, radius:CGFloat) {
        
        self.layer.shadowColor = colour.CGColor
        self.layer.shadowRadius = radius
        self.layer.shadowOpacity = 1
        self.layer.shadowOffset = CGSizeZero
        
        
        UIView.animateWithDuration(0.7, delay: 0, options:
            [UIViewAnimationOptions.Autoreverse, UIViewAnimationOptions.CurveEaseInOut, UIViewAnimationOptions.Repeat],
            animations: { () -> Void in
            
            self.transform = CGAffineTransformMakeScale(1.2, 1.2)
            
            }) { (completed) -> Void in
                self.layer.shadowRadius = 0.0
                self.transform = CGAffineTransformMakeScale(1, 1)
        }
    }
    
//    -(void)makeViewShine:(UIView*) view
//    {
//    view.layer.shadowColor = [UIColor yellowColor].CGColor;
//    view.layer.shadowRadius = 10.0f;
//    view.layer.shadowOpacity = 1.0f;
//    view.layer.shadowOffset = CGSizeZero;
//    
//    
//    [UIView animateWithDuration:0.7f delay:0 options:UIViewAnimationOptionAutoreverse | UIViewAnimationCurveEaseInOut | UIViewAnimationOptionRepeat | UIViewAnimationOptionAllowUserInteraction  animations:^{
//    
//    [UIView setAnimationRepeatCount:15];
//    
//    view.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
//    
//    
//    } completion:^(BOOL finished) {
//    
//    view.layer.shadowRadius = 0.0f;
//    view.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
//    }];
//    
//    }
    
    func pulseOnce() {
        if self.layer.animationForKey("kPulseAnimation") == nil {
            let pulseAnimation:CABasicAnimation = CABasicAnimation(keyPath: "transform.scale");
            pulseAnimation.duration = 0.2;
            pulseAnimation.toValue = NSNumber(float: 1.1);
            
            
            pulseAnimation.autoreverses = true;
//            pulseAnimation.repeatCount = Float.infinity;
            self.layer.addAnimation(pulseAnimation, forKey: "kPulseAnimation")
        }
    }
    
    func startPulse() {
        if self.layer.animationForKey("kPulseAnimation") == nil {
            let pulseAnimation:CABasicAnimation = CABasicAnimation(keyPath: "transform.scale");
            pulseAnimation.duration = 0.5;
            pulseAnimation.toValue = NSNumber(float: 1.1);

            
            pulseAnimation.autoreverses = true;
            pulseAnimation.repeatCount = Float.infinity;
            self.layer.addAnimation(pulseAnimation, forKey: "kPulseAnimation")
        }
    }
    
    func stopPulse() {
        
        self.layer.removeAnimationForKey("kPulseAnimation")
    }
    
}

extension UIColor {
    
    //    convenience init(rgb: UInt) {
    //        self.init(
    //            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
    //            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
    //            blue: CGFloat(rgb & 0x0000FF) / 255.0,
    //            alpha: CGFloat(1.0)
    //        )
    //    }
    
    func imageFromColour() -> UIImage {
        
        let rect = CGRectMake(0, 0, 1, 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetFillColorWithColor(context, self.CGColor)
        
        CGContextFillRect(context, rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return image;
    }
}

extension UITableView {
    
    class ShiftedLabel: UILabel {
        
        var overrideInsets: UIEdgeInsets?
        
        override func drawTextInRect(rect: CGRect) {
            let insets = overrideInsets ?? UIEdgeInsetsMake(-50, 50, 0, 50)
            super.drawTextInRect(UIEdgeInsetsInsetRect(rect, insets))
        }
    }
    
    
    func hidePlaceholder() {
        
        UIView.animateWithDuration(0, animations: { () -> Void in
            self.viewWithTag(777)?.alpha = 0
        })
    }
    
    func showPlaceholder(placeholderText: String, overrideInsets:UIEdgeInsets? = nil, placeholderImage:UIImage? = nil) {
        
        var placeholder = self.viewWithTag(777)
        
        //        var yPos = 0
        
        if let placeholder = placeholder as? ShiftedLabel {
            placeholder.text = placeholderText
            
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                placeholder.alpha = 1
            })
        }
        else {
            let placeholderLabel = ShiftedLabel(frame: self.bounds)
            //placeholderLabel.overrideInsets = overrideInsets
            placeholderLabel.tag = 777
            placeholderLabel.text = placeholderText
            placeholderLabel.textAlignment = NSTextAlignment.Center
            placeholderLabel.font = UIFont.systemFontOfSize(16)
            placeholderLabel.textColor = UIColor.grayColor()
            
            placeholderLabel.alpha = 0
            placeholderLabel.numberOfLines = 0
            
            //            self.addSubview(placeholderLabel)
            self.backgroundView = placeholderLabel
            
            placeholder = placeholderLabel
            
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                placeholderLabel.alpha = 1
            })
        }
        
        if let placeholderImage = placeholderImage {
            
            let placeholderImageView = self.viewWithTag(779)
            
            if let placeholderImageView = placeholderImageView as? UIImageView {
                
                placeholderImageView.image = placeholderImage
                
                //let yOffset = CGFloat((overrideInsets != nil) ? overrideInsets!.top/2 : 0)
                //placeholderImageView.frame.y = placeholderImageView.frame.y - placeholderImageView.frame.height - 5 + yOffset
                
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    placeholderImageView.alpha = 1
                })
            }
            else {
                
                var frame = CGRectZero
                frame.size = placeholderImage.size
                let imageView = UIImageView(frame: frame)
                
                imageView.center = CGPointMake(self.center.x, (self.bounds.height / 2) - 70)
                imageView.image = placeholderImage
                imageView.alpha = 0
                imageView.tag = 779
                
                self.backgroundView?.addSubview(imageView)
                
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    imageView.alpha = 1
                })
            }
        }
        else {
            // Remove placeholder image
            let placeholderImageView = self.viewWithTag(779)
            
            if let placeholderImageView = placeholderImageView as? UIImageView {
                placeholderImageView.removeFromSuperview()
            }
        }
    }
}

extension UICollectionView {
    
    class ShiftedLabel: UILabel {
        
        var overrideInsets: UIEdgeInsets?
        
        override func drawTextInRect(rect: CGRect) {
            let insets = overrideInsets ?? UIEdgeInsetsMake(-50, 50, 0, 50)
            super.drawTextInRect(UIEdgeInsetsInsetRect(rect, insets))
        }
    }
    
    
    func hidePlaceholder() {
        
        UIView.animateWithDuration(0, animations: { () -> Void in
            self.viewWithTag(777)?.alpha = 0
        })
    }
    
    func showPlaceholder(placeholderText: String, overrideInsets:UIEdgeInsets? = nil, placeholderImage:UIImage? = nil) {
        
        var placeholder = self.viewWithTag(777)
        
        //        var yPos = 0
        
        if let placeholder = placeholder as? ShiftedLabel {
            placeholder.text = placeholderText
            
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                placeholder.alpha = 1
            })
        }
        else {
            let placeholderLabel = ShiftedLabel(frame: self.bounds)
            //placeholderLabel.overrideInsets = overrideInsets
            placeholderLabel.tag = 777
            placeholderLabel.text = placeholderText
            placeholderLabel.textAlignment = NSTextAlignment.Center
            placeholderLabel.font = UIFont.systemFontOfSize(16)
            placeholderLabel.textColor = UIColor.grayColor()
            
            placeholderLabel.alpha = 0
            placeholderLabel.numberOfLines = 0
            
            //            self.addSubview(placeholderLabel)
            self.backgroundView = placeholderLabel
            
            placeholder = placeholderLabel
            
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                placeholderLabel.alpha = 1
            })
        }
        
        if let placeholderImage = placeholderImage {
            
            let placeholderImageView = self.viewWithTag(779)
            
            if let placeholderImageView = placeholderImageView as? UIImageView {
                
                placeholderImageView.image = placeholderImage
                
                //let yOffset = CGFloat((overrideInsets != nil) ? overrideInsets!.top/2 : 0)
                //placeholderImageView.frame.y = placeholderImageView.frame.y - placeholderImageView.frame.height - 5 + yOffset
                
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    placeholderImageView.alpha = 1
                })
            }
            else {
                
                var frame = CGRectZero
                frame.size = placeholderImage.size
                let imageView = UIImageView(frame: frame)
                
                imageView.center = CGPointMake(self.center.x, (self.bounds.height / 2) - 70)
                imageView.image = placeholderImage
                imageView.alpha = 0
                imageView.tag = 779
                
                self.backgroundView?.addSubview(imageView)
                
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    imageView.alpha = 1
                })
            }
        }
        else {
            // Remove placeholder image
            let placeholderImageView = self.viewWithTag(779)
            
            if let placeholderImageView = placeholderImageView as? UIImageView {
                placeholderImageView.removeFromSuperview()
            }
        }
    }
}

extension UISwitch {
    
    struct Loading {
        static let background = UIView()
        static let spinner = UIActivityIndicatorView()
    }
        
    func showSpinner(show:Bool) {
        
        if UISwitch.Loading.spinner.superview == nil {
            UISwitch.Loading.background.frame = self.bounds
            UISwitch.Loading.background.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.7)
            UISwitch.Loading.background.layer.cornerRadius = UISwitch.Loading.background.bounds.height/2
            UISwitch.Loading.background.clipsToBounds = true
           UISwitch.Loading.spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
           UISwitch.Loading.spinner.center = CGPointMake(UISwitch.Loading.background.bounds.width/2, UISwitch.Loading.background.bounds.height/2)
            UISwitch.Loading.background.addSubview(UISwitch.Loading.spinner)
            self.addSubview(UISwitch.Loading.background)
//            self.clipsToBounds = true
            
            UISwitch.Loading.background.alpha = 0 // Default hidden
        }
        
        if show {
            UISwitch.Loading.spinner.startAnimating()
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                
                UISwitch.Loading.background.alpha = 1
            })
        }
        else {
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                UISwitch.Loading.background.alpha = 0
                }, completion: { (completed) -> Void in
                    UISwitch.Loading.spinner.stopAnimating()
            })
        }
    }
}


   // MARK: - Misc

extension String {
    
//    func isValidEmail() -> Bool {
//                    
//            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
//            
//            let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
//            let result = emailTest.evaluateWithObject(self)
//            
//            return result
//    }
    
//    func isValidPassword() -> Bool {
//        
//        return self.characters.count > 5
//    }
    
//    func isValidUsername() -> Bool {
//        
//        let passRegEx = "^([a-zA-Z0-9._-]+)$"
//        
//        let passTest = NSPredicate(format:"SELF MATCHES %@", passRegEx)
//        let result = passTest.evaluateWithObject(self)
//        
//        return result //&& (self.characters.count > 5)
//    }
    
//    func URLEncodedString() -> String {
//        
//        let encodedString = ((self as NSString).URLEncodedString() as String)
//        return encodedString
//        
//    }
}

extension NSTimeInterval {
    
    static let dayInSeconds:NSTimeInterval = 60 * 60 * 24
    
    static func days(numberOfDays:Int) -> NSTimeInterval {
        
        return dayInSeconds * NSTimeInterval(numberOfDays)
    }
    
    static func hours(numberOfHours:Int) -> NSTimeInterval {
        
        return 60 * 60 * NSTimeInterval(numberOfHours)
    }
    
    func intervalToHoursMinutesSeconds() -> (Int, Int, Int) {
        return (Int(self) / 3600, (Int(self) % 3600) / 60, (Int(self) % 3600) % 60)
    }

}

extension NSTimeZone {
    
    func offsetString() -> String {
        
        var negative = false
        var hours = 0
        var mins = 0
        
        var seconds:Int = self.secondsFromGMT
        if seconds < 0 {
            
            negative = true
            seconds = seconds * -1
        }
        
        hours = Int(seconds/3600)
        mins = Int(seconds%3600) / 60
        
        let sign = negative ? "-" : "+"
        let hourString = String(format: "%02d", hours)
        let minString = String(format: "%02d", mins)
        let string = sign + "\(hourString):\(minString)"
        
        return string
    }
    
}

extension NSDateFormatter {
    
    private static let sharedSystemTimezoneFormatter = NSDateFormatter()
    private static let sharedTimeZoneFormatter = NSDateFormatter()
    
    static func sharedFormatter() -> NSDateFormatter {
        return sharedTimeZoneFormatter
    }
    
    static func yyyymmdd() -> NSDateFormatter {
        
        sharedSystemTimezoneFormatter.dateFormat = "yyyy-MM-dd"
        return sharedSystemTimezoneFormatter
    }
    
    static func yyyyMMddHHmmss() -> NSDateFormatter {
        
        sharedSystemTimezoneFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return sharedSystemTimezoneFormatter
    }
    
    static func ddMMM() -> NSDateFormatter {
        
        sharedSystemTimezoneFormatter.dateFormat = "dd. MMM"
        return sharedSystemTimezoneFormatter
    }
    
    static func iso8601() -> NSDateFormatter {
        
        sharedSystemTimezoneFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        return sharedSystemTimezoneFormatter
    }
    
    static func passportExpiry() -> NSDateFormatter {
        
        sharedSystemTimezoneFormatter.dateFormat = "dd MMMM yyyy"
        return sharedSystemTimezoneFormatter
    }

    static func passportExpiryShort() -> NSDateFormatter {
        
        sharedSystemTimezoneFormatter.dateFormat = "dd MMM yyyy"
        return sharedSystemTimezoneFormatter
    }
    
    static func insightddmmyy() -> NSDateFormatter {
        
        sharedSystemTimezoneFormatter.dateFormat = "dd/MM/yy"
        return sharedSystemTimezoneFormatter
    }
    
}






extension NSDate {
    
    
    func applyTimezoneToUTCDate(timezoneToApply:NSTimeZone) -> NSDate {
        
        let style = timezoneToApply.isDaylightSavingTimeForDate(NSDate()) ? NSTimeZoneNameStyle.ShortDaylightSaving : NSTimeZoneNameStyle.ShortStandard
        
        let tzExtension = timezoneToApply.localizedName(style, locale: nil)!
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd MM yyyy"
        
        var dateString = formatter.stringFromDate(self)
        
        dateString = dateString + " " + tzExtension
        
        formatter.dateFormat = "dd MM yyyy z"
        
        let dateInTimezone = formatter.dateFromString(dateString)
        
        return dateInTimezone!
        
    }
}

//extension GAI {
//    
//    static func trackScreen(name:String) {
//        
//        let tracker = GAI.sharedInstance().defaultTracker
//        tracker.set(kGAIScreenName, value: name)
//        tracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject : AnyObject])
//    }
//}

/**
 Dispatches the given closure on the main queue after specified delay
 
 - parameter delay:   The number of seconds you want to wait before dispatching the closure
 - parameter closure: The closure you wish to execute on the main queue after the delay
 */
internal func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}
