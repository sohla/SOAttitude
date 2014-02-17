//
//  SOViewController.m
//  SOAttitude
//
//  Created by Stephen OHara on 17/02/14.
//  Copyright (c) 2014 Stephen OHara. All rights reserved.
//

#import "SOViewController.h"

@interface SOViewController ()
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

@property (retain, nonatomic) CMMotionManager *motionManager;
@property (retain, nonatomic) CADisplayLink *motionDisplayLink;

@property double motionLastYaw;

@end

@implementation SOViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.


    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.deviceMotionUpdateInterval = 0.02;  // 50 Hz
    
    self.motionDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(motionRefresh:)];
    [self.motionDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    if ([self.motionManager isDeviceMotionAvailable]) {
        // to avoid using more CPU than necessary we use `CMAttitudeReferenceFrameXArbitraryZVertical`
        [self.motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryZVertical];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)motionRefresh:(id)sender {
    
    // found at : http://www.dulaccc.me/2013/03/computing-the-ios-device-tilt.html
    
    CMQuaternion quat = self.motionManager.deviceMotion.attitude.quaternion;
    double yaw = asin(2*(quat.x*quat.z - quat.w*quat.y));
    
    if (self.motionLastYaw == 0) {
        self.motionLastYaw = yaw;
    }
    
    // kalman filtering
    static float q = 0.1;   // process noise
    static float r = 0.1;   // sensor noise
    static float p = 0.1;   // estimated error
    static float k = 0.5;   // kalman filter gain
    
    float x = self.motionLastYaw;
    p = p + q;
    k = p / (p + r);
    x = x + k*(yaw - x);
    p = (1 - k)*p;
    self.motionLastYaw = x;
    
    // use the x value as the "updated and smooth" yaw
    self.detailLabel.text = [NSString stringWithFormat:@"%.2f",x];
    
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if(orientation == UIInterfaceOrientationLandscapeLeft){

        if(x <= -0.9){
            self.view.backgroundColor = [UIColor greenColor];
        }else{
            self.view.backgroundColor = [UIColor whiteColor];
        }

    }else if (orientation == UIInterfaceOrientationLandscapeRight){

        if(x >= 0.9){
            self.view.backgroundColor = [UIColor greenColor];
        }else{
            self.view.backgroundColor = [UIColor whiteColor];
        }

    }
    
    
}

@end
