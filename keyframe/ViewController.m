#import "ViewController.h"
#import "startRadiansForPath.h"

@implementation ViewController {
    UIBezierPath *_path0;
    UIBezierPath *_path1;
    CAShapeLayer *_shapeLayer0;
    CAShapeLayer *_shapeLayer1;
    CGFloat _currentScale;
    BOOL _isReset;
}

@synthesize imageView = _imageView;

- (void)initPaths {
    CGSize size = self.view.bounds.size;
    CGPoint p0 = CGPointMake(.2, .5);
    CGPoint p01a = CGPointMake(.2, .2);
    CGPoint p01b = CGPointMake(.5, .2);
    CGPoint p1 = CGPointMake(.5, .5);
    CGPoint p12a = CGPointMake(.5, .8);
    CGPoint p12b = CGPointMake(.8, .8);
    CGPoint p2 = CGPointMake(.8, .5);
    CGPoint p23a = CGPointMake(.8, .2);
    CGPoint p23b = CGPointMake(.5, .2);
    CGPoint p3 = CGPointMake(.5, .5);
    CGPoint p30a = CGPointMake(.5, .8);
    CGPoint p30b = CGPointMake(.2, .8);
    
    _path0 = [UIBezierPath bezierPath];
    [_path0 moveToPoint:p0];
    [_path0 addCurveToPoint:p1 controlPoint1:p01a controlPoint2:p01b];
    [_path0 addCurveToPoint:p2 controlPoint1:p12a controlPoint2:p12b];
    
    _path1 = [UIBezierPath bezierPath];
    [_path1 moveToPoint:p2];
    [_path1 addCurveToPoint:p3 controlPoint1:p23a controlPoint2:p23b];
    [_path1 addCurveToPoint:p0 controlPoint1:p30a controlPoint2:p30b];
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformScale(transform, size.width, size.height);
    transform = CGAffineTransformRotate(transform, M_PI / 12);
    [_path0 applyTransform:transform];
    [_path1 applyTransform:transform];
}

- (void)reset {
    self.imageView.center = _path1.currentPoint;
    self.imageView.transform = CGAffineTransformMakeRotation(startRadiansForPath(_path0));
    _currentScale = 1;
    _isReset = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initPaths];
    [self reset];
    
    _shapeLayer0 = [CAShapeLayer layer];
    _shapeLayer0.lineCap = kCALineCapRound;
    _shapeLayer0.lineJoin = kCALineJoinRound;
    _shapeLayer0.lineWidth = 2;
    _shapeLayer0.strokeColor = UIColor.blueColor.CGColor;
    _shapeLayer0.fillColor = NULL;
    _shapeLayer0.frame = self.view.layer.bounds;
    _shapeLayer0.path = _path0.CGPath;
    [self.view.layer addSublayer:_shapeLayer0];
    
    _shapeLayer1 = [CAShapeLayer layer];
    _shapeLayer1.lineCap = kCALineCapRound;
    _shapeLayer1.lineJoin = kCALineJoinRound;
    _shapeLayer1.lineWidth = 2;
    _shapeLayer1.strokeColor = UIColor.redColor.CGColor;
    _shapeLayer1.fillColor = NULL;
    _shapeLayer1.frame = self.view.layer.bounds;
    _shapeLayer1.path = _path1.CGPath;
    [self.view.layer addSublayer:_shapeLayer1];
    
    CGSize size = self.imageView.bounds.size;
    UIGraphicsBeginImageContextWithOptions(size, NO, UIScreen.mainScreen.scale); {
        CGContextRef gc = UIGraphicsGetCurrentContext();
        CGContextBeginPath(gc);
        CGContextMoveToPoint(gc, size.width / 2, size.height / 2);
        CGContextAddLineToPoint(gc, 0, 0);
        CGContextAddLineToPoint(gc, size.width, size.height / 2);
        CGContextAddLineToPoint(gc, 0, size.height);
        CGContextClosePath(gc);
        [UIColor.greenColor setFill];
        CGContextFillPath(gc);
        self.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    } UIGraphicsEndImageContext();
}

- (void)viewDidUnload
{
    [self setImageView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (IBAction)animate:(id)sender {
    UIImageView* theImage = self.imageView;
    
    UIBezierPath *path = _isReset ? _path0 : _path1;
    CGFloat newScale = 3 - _currentScale;
    
    CGPoint destination = [path currentPoint];
    
    // Strip off the rotation applied by `reset:`, because it interferes with `kCAAnimationRotateAuto`.
    theImage.transform = CGAffineTransformMakeScale(_currentScale, _currentScale);
    
    [UIView animateWithDuration:3 animations:^{
        // Prepare my own keypath animation for the layer position.
        // The layer position is the same as the view center.
        CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        positionAnimation.path = path.CGPath;
        positionAnimation.rotationMode = kCAAnimationRotateAuto;
        
        [CATransaction setCompletionBlock:^{
            CGAffineTransform finalTransform = [theImage.layer.presentationLayer affineTransform];
            [theImage.layer removeAnimationForKey:positionAnimation.keyPath];
            theImage.transform = finalTransform;
        }];
        
        // UIView will add animations for both of these changes.
        theImage.transform = CGAffineTransformMakeScale(newScale, newScale);
        theImage.center = destination;
        
        // Copy properties from UIView's animation.
        CAAnimation *autoAnimation = [theImage.layer animationForKey:@"position"];
        positionAnimation.duration = autoAnimation.duration;
        positionAnimation.fillMode = autoAnimation.fillMode;
        positionAnimation.removedOnCompletion = NO;
        
        // Replace UIView's animation with my animation.
        [theImage.layer addAnimation:positionAnimation forKey:positionAnimation.keyPath];
    }];
    
    _currentScale = newScale;
    _isReset = !_isReset;
}

@end
