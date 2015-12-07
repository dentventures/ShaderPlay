//
//  ViewController.h
//  ShaderPlay
//
//  Created by Brett Beers on 12/2/15.
//  Copyright © 2015 DentVentures. All rights reserved.
//

#import "ModelViewerView.h"
#import "ModelViewerParentProtocol.h"
#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController <ModelViewerParent>
@property (weak) IBOutlet NSButton *btn_shader;
@property (weak) IBOutlet NSButton *btn_modelFile;

@property (weak) IBOutlet NSTextField *txt_shader;
@property (weak) IBOutlet NSTextField *txt_modelFile;
@property (weak) IBOutlet NSTextField *txt_inputRed;
@property (weak) IBOutlet NSTextField *txt_inputGreen;
@property (weak) IBOutlet NSTextField *txt_inputBlue;
@property (weak) IBOutlet NSTextField *txt_inputHFOV;

@property (weak) IBOutlet NSTextField *txt_cameraEyeX;
@property (weak) IBOutlet NSTextField *txt_cameraEyeY;
@property (weak) IBOutlet NSTextField *txt_cameraEyeZ;

@property (weak) IBOutlet NSTextField *txt_cameraFocusX;
@property (weak) IBOutlet NSTextField *txt_cameraFocusY;
@property (weak) IBOutlet NSTextField *txt_cameraFocusZ;

@property (weak) IBOutlet NSTextField *txt_lightDirX;
@property (weak) IBOutlet NSTextField *txt_lightDirY;
@property (weak) IBOutlet NSTextField *txt_lightDirZ;

@property (weak) IBOutlet NSSlider *hsldr_red;
@property (weak) IBOutlet NSSlider *hsldr_green;
@property (weak) IBOutlet NSSlider *hsldr_blue;
@property (weak) IBOutlet NSSlider *hsldr_hfov;

@property (weak) IBOutlet ModelViewerView *glView;

//- (void) glViewReady;

@end

