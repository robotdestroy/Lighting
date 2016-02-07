/*******************************************************************************
 Copyright (c) 2013 Koninklijke Philips N.V.
 All Rights Reserved.
 ********************************************************************************/

#import "PHControlLightsViewController.h"
#import <HueSDK_OSX/HueSDK.h>
#import "AppDelegate.h"

#define MAX_HUE 65535

@interface PHControlLightsViewController ()
    @property (nonatomic,weak) IBOutlet NSTextField *bridgeLastHeartbeatLabel;
    @property (nonatomic,weak) IBOutlet NSButton *turnOffConnectLights;
    @property (nonatomic,weak) IBOutlet NSButton *turnOnConnectLights;
    @property (weak) IBOutlet NSSlider *sliderOneOutput;
    @property (weak) IBOutlet NSSlider *sliderTwoOutput;
    @property (weak) IBOutlet NSSlider *sliderThreeOutput;
    @property (weak) IBOutlet NSButton *oneToggle;
    @property (weak) IBOutlet NSButton *twoToggle;
    @property (weak) IBOutlet NSButton *threeToggle;
@end

@implementation PHControlLightsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)loadView{
    [super loadView];
    
    PHNotificationManager *notificationManager = [PHNotificationManager defaultManager];
    // Register for the local heartbeat notifications
    [notificationManager registerObject:self withSelector:@selector(localConnection) forNotification:LOCAL_CONNECTION_NOTIFICATION];
    [notificationManager registerObject:self withSelector:@selector(noLocalConnection) forNotification:NO_LOCAL_CONNECTION_NOTIFICATION];
    
    [self noLocalConnection];
}

- (void)localConnection{
    [self loadConnectedBridgeValues];
    [self updateSliders];
}

- (void)noLocalConnection{
    self.bridgeLastHeartbeatLabel.stringValue = NSLocalizedString(@"Not connected", @"");
    [self.bridgeLastHeartbeatLabel setEnabled:NO];
}

- (IBAction)sliderOne: (NSNumber *)currentBrightness {
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    PHLight *lightOne = [cache.lights objectForKey:@"1"];
    PHLightState *lightStateOneSlider = lightOne.lightState;
    if (lightStateOneSlider.on) {
        NSNumber *newBrightnessOne = [NSNumber numberWithInt:_sliderOneOutput.intValue];
        [lightStateOneSlider setBrightness:newBrightnessOne];
        NSLog(@"%@", newBrightnessOne);
        PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
        [bridgeSendAPI updateLightStateForId:lightOne.identifier withLightState:lightStateOneSlider completionHandler:^(NSArray *errors) {
            if (!errors){
                // Update successful
            } else {
                // Error occurred
            }
        }];
    }
}

- (IBAction)sliderTwo:(id)sender {
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    PHLight *lightTwo = [cache.lights objectForKey:@"2"];
    PHLightState *lightStateTwoSlider = lightTwo.lightState;
    if (lightStateTwoSlider.on) {
        NSNumber *newBrightnessTwo = [NSNumber numberWithInt:_sliderTwoOutput.intValue];
        [lightStateTwoSlider setBrightness:newBrightnessTwo];
        NSLog(@"%@", newBrightnessTwo);
        PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
        [bridgeSendAPI updateLightStateForId:lightTwo.identifier withLightState:lightStateTwoSlider completionHandler:^(NSArray *errors) {
            if (!errors){
                // Update successful
            } else {
                // Error occurred
            }
        }];
    }
}

- (IBAction)sliderThree:(id)sender {
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    PHLight *lightThree = [cache.lights objectForKey:@"3"];
    PHLightState *lightStateThreeSlider = lightThree.lightState;
    if (lightStateThreeSlider.on) {
        NSNumber *newBrightnessThree = [NSNumber numberWithInt:_sliderThreeOutput.intValue];
        [lightStateThreeSlider setBrightness:newBrightnessThree];
        NSLog(@"%@", newBrightnessThree);
        PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
        [bridgeSendAPI updateLightStateForId:lightThree.identifier withLightState:lightStateThreeSlider completionHandler:^(NSArray *errors) {
            if (!errors){
                // Update successful
            } else {
                // Error occurred
            }
        }];
    }
}

- (IBAction)turnOnConnectLights:(id)sender{
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
    for (PHLight *light in cache.lights.allValues) {
        PHLightState *lightState = [[PHLightState alloc] init];
        lightState.on = @YES;
        [bridgeSendAPI updateLightStateForId:light.identifier withLightState:lightState completionHandler:^(NSArray *errors) {
            if (errors != nil) {
                NSString *message = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Errors", @""), errors != nil ? errors : NSLocalizedString(@"none", @"")];
                NSLog(@"Response: %@",message);
            }
            [self.turnOnConnectLights setEnabled:YES];
        }];
    }
}

- (IBAction)turnOffConnectLights:(id)sender{
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
    for (PHLight *light in cache.lights.allValues) {
        PHLightState *lightState = [[PHLightState alloc] init];
        lightState.on = @NO;
        [bridgeSendAPI updateLightStateForId:light.identifier withLightState:lightState completionHandler:^(NSArray *errors) {
            if (errors != nil) {
                NSString *message = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Errors", @""), errors != nil ? errors : NSLocalizedString(@"none", @"")];
                NSLog(@"Response: %@",message);
            }
            [self.turnOffConnectLights setEnabled:YES];
        }];
    }
    _sliderOneOutput.intValue = 0;
    _oneToggle.alphaValue = 0.5;
    _sliderTwoOutput.intValue = 0;
    _twoToggle.alphaValue = 0.5;
    _sliderThreeOutput.intValue = 0;
    _threeToggle.alphaValue = 0.5;
}

- (IBAction)updateOne:(id)sender {
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    PHLight *lightOneLevel = [cache.lights objectForKey:@"1"];
    PHLightState *lightStateOne = lightOneLevel.lightState;
    if ([lightStateOne.on isEqual: @1]) {
        PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
        PHLightState *lightState = [[PHLightState alloc] init];
        lightState.on = @NO;
        [bridgeSendAPI updateLightStateForId:@"1" withLightState:lightState completionHandler:^(NSArray *errors) {
            if (errors != nil) {
                NSString *message = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Errors", @""), errors != nil ? errors : NSLocalizedString(@"none", @"")];
                NSLog(@"Response: %@",message);
            }
            [self.turnOnConnectLights setEnabled:YES];
        }];
        _sliderOneOutput.intValue = 0;
        _oneToggle.alphaValue = 0.5;
    } else {
        PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
        PHLightState *lightState = [[PHLightState alloc] init];
        lightState.on = @YES;
        [bridgeSendAPI updateLightStateForId:@"1" withLightState:lightState completionHandler:^(NSArray *errors) {
            if (errors != nil) {
                NSString *message = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Errors", @""), errors != nil ? errors : NSLocalizedString(@"none", @"")];
                
                NSLog(@"Response: %@",message);
            }
            [self.turnOnConnectLights setEnabled:YES];
        }];
        _sliderOneOutput.intValue = 0;
        _oneToggle.alphaValue = 1;
        PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
        PHLight *lightOneLevel = [cache.lights objectForKey:@"1"];
        _sliderOneOutput.intValue = lightOneLevel.lightState.brightness.intValue;
    }
}

- (IBAction)updateTwo:(id)sender {
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    PHLight *lightTwoLevel = [cache.lights objectForKey:@"2"];
    PHLightState *lightStateTwo = lightTwoLevel.lightState;
    if ([lightStateTwo.on isEqual: @1]) {
        PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
        PHLightState *lightState = [[PHLightState alloc] init];
        lightState.on = @NO;
        [bridgeSendAPI updateLightStateForId:@"2" withLightState:lightState completionHandler:^(NSArray *errors) {
            if (errors != nil) {
                NSString *message = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Errors", @""), errors != nil ? errors : NSLocalizedString(@"none", @"")];
                
                NSLog(@"Response: %@",message);
            }
            [self.turnOnConnectLights setEnabled:YES];
        }];
        _sliderTwoOutput.intValue = 0;
        _twoToggle.alphaValue = 0.5;
    } else {
        PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
        PHLightState *lightState = [[PHLightState alloc] init];
        lightState.on = @YES;
        [bridgeSendAPI updateLightStateForId:@"2" withLightState:lightState completionHandler:^(NSArray *errors) {
            if (errors != nil) {
                NSString *message = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Errors", @""), errors != nil ? errors : NSLocalizedString(@"none", @"")];
                
                NSLog(@"Response: %@",message);
            }
            [self.turnOnConnectLights setEnabled:YES];
        }];
        _sliderTwoOutput.intValue = 0;
        _twoToggle.alphaValue = 1;
        PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
        PHLight *lightTwoLevel = [cache.lights objectForKey:@"2"];
        _sliderTwoOutput.intValue = lightTwoLevel.lightState.brightness.intValue;
    }
}

- (IBAction)updateThree:(id)sender {
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    PHLight *lightThreeLevel = [cache.lights objectForKey:@"3"];
    PHLightState *lightStateThree = lightThreeLevel.lightState;
    if ([lightStateThree.on isEqual: @1]) {
        PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
        PHLightState *lightState = [[PHLightState alloc] init];
        lightState.on = @NO;
        [bridgeSendAPI updateLightStateForId:@"3" withLightState:lightState completionHandler:^(NSArray *errors) {
            if (errors != nil) {
                NSString *message = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Errors", @""), errors != nil ? errors : NSLocalizedString(@"none", @"")];
                NSLog(@"Response: %@",message);
            }
            [self.turnOnConnectLights setEnabled:YES];
        }];
        _sliderThreeOutput.intValue = 0;
        _threeToggle.alphaValue = 0.5;
    } else {
        PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
        PHLightState *lightState = [[PHLightState alloc] init];
        lightState.on = @YES;
        [bridgeSendAPI updateLightStateForId:@"3" withLightState:lightState completionHandler:^(NSArray *errors) {
            if (errors != nil) {
                NSString *message = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Errors", @""), errors != nil ? errors : NSLocalizedString(@"none", @"")];
                NSLog(@"Response: %@",message);
            }
            [self.turnOnConnectLights setEnabled:YES];
        }];
        _sliderThreeOutput.intValue = 0;
        _threeToggle.alphaValue = 1;
        PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
        PHLight *lightThreeLevel = [cache.lights objectForKey:@"3"];
        _sliderThreeOutput.intValue = lightThreeLevel.lightState.brightness.intValue;
    }
}

- (void)loadConnectedBridgeValues{
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    if (cache != nil && cache.bridgeConfiguration != nil && cache.bridgeConfiguration.ipaddress != nil){
        if (NSAppDelegate.phHueSDK.localConnected) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateStyle:NSDateFormatterNoStyle];
            [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
            self.bridgeLastHeartbeatLabel.stringValue = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:[NSDate date]]];
        } else {
            self.bridgeLastHeartbeatLabel.stringValue = NSLocalizedString(@"Waiting...", @"");
            [self updateSliders];
        }
    }
}

- (IBAction)selectOtherBridge:(id)sender{
    [NSAppDelegate searchForBridgeLocal];
}

- (void)updateSliders{
    NSLog(@"sliders updating");
    
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    
    PHLight *lightOneLevel = [cache.lights objectForKey:@"1"];
    PHLightState *lightStateOne = lightOneLevel.lightState;
//    NSLog(@"%@", lightOneLevel.lightState);
    if ([lightStateOne.on isEqual: @1]) {
        _sliderOneOutput.intValue = lightOneLevel.lightState.brightness.intValue;
        _oneToggle.alphaValue = 1;
    } else {
        _sliderOneOutput.intValue = 0;
        _oneToggle.alphaValue = 0.5;
    }
    
    PHLight *lightTwoLevel = [cache.lights objectForKey:@"2"];
    PHLightState *lightStateTwo = lightTwoLevel.lightState;
//    NSLog(@"%@", lightTwoLevel.lightState);
    if ([lightStateTwo.on isEqual: @1]) {
        _sliderTwoOutput.intValue = lightTwoLevel.lightState.brightness.intValue;
        _twoToggle.alphaValue = 1;
    } else {
        _sliderTwoOutput.intValue = 0;
        _twoToggle.alphaValue = 0.5;
    }
    
    PHLight *lightThreeLevel = [cache.lights objectForKey:@"3"];
    PHLightState *lightStateThree = lightThreeLevel.lightState;
//    NSLog(@"%@", lightThreeLevel.lightState);
    if ([lightStateThree.on isEqual: @1]) {
        _sliderThreeOutput.intValue = lightThreeLevel.lightState.brightness.intValue;
        _threeToggle.alphaValue = 1;
    } else {
        _sliderThreeOutput.intValue = 0;
        _threeToggle.alphaValue = 0.5;
    }
}

@end
