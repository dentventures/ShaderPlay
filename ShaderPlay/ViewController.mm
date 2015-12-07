//
//  ViewController.m
//  ShaderPlay
//
//  Created by Brett Beers on 12/2/15.
//  Copyright © 2015 DentVentures. All rights reserved.
//

#import <OpenGL/gl.h>
#import "ViewController.h"
#include <glm/glm.hpp>
#import "OpenGLHelpers.h"

#include "BlenderModelLoader.hpp"

@implementation ViewController
{
    BlenderModel model;
    GLuint currentShaderId;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    
    self.glView.parent = self;
    
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (void)glViewReady {
    glm::vec3 cameraEye, cameraFocus;
    [self.glView getCameraEyePosition:&cameraEye.x y:&cameraEye.y z:&cameraEye.z];
    [self.glView getCameraFocusPosition:&cameraFocus.x y:&cameraFocus.y z:&cameraFocus.z];
    
    [self.txt_cameraEyeX setFloatValue:cameraEye.x];
    [self.txt_cameraEyeY setFloatValue:cameraEye.y];
    [self.txt_cameraEyeZ setFloatValue:cameraEye.z];
    
    [self.txt_cameraFocusX setFloatValue:cameraFocus.x];
    [self.txt_cameraFocusY setFloatValue:cameraFocus.y];
    [self.txt_cameraFocusZ setFloatValue:cameraFocus.z];
}

- (void)cameraEyeChanged:(GLfloat)x y:(GLfloat)y z:(GLfloat)z {
    [self.txt_cameraEyeX setFloatValue:x];
    [self.txt_cameraEyeY setFloatValue:y];
    [self.txt_cameraEyeZ setFloatValue:z];
}

- (void)cameraFocusChanged:(GLfloat)x y:(GLfloat)y z:(GLfloat)z {
    [self.txt_cameraFocusX setFloatValue:x];
    [self.txt_cameraFocusY setFloatValue:y];
    [self.txt_cameraFocusZ setFloatValue:z];
}

#pragma mark UI Actions

- (IBAction)touchInsideShader:(id)sender {
    [self setPathForInput: self.txt_shader];
    if(![[self.txt_shader stringValue] isEqualToString:@""])
        [self loadShaderFile: [self.txt_shader stringValue]];
}


- (IBAction)touchInsideBtnModelFile:(id)sender {
    [self setPathForInput: self.txt_modelFile];
    if(![[self.txt_modelFile stringValue] isEqualToString:@""])
        [self loadModelFile: [self.txt_modelFile stringValue]];
}

- (IBAction)inputHFOVChanged:(id)sender {
    NSTextField *input = sender;
    if(![self stringIsNumber:[input stringValue]]) {
        [input setStringValue:[NSString stringWithFormat:@"%.2lf", [self.hsldr_hfov floatValue]]];
    }
    else {
        [self.hsldr_hfov setFloatValue:[[input stringValue] floatValue]];
        [self.glView setProjectionHFOV:[[input stringValue] floatValue]];
    }
}

- (IBAction)inputRedChanged:(id)sender {
    NSTextField *input = sender;
    
    if(![self stringIsNumber:[input stringValue]]) {
        [input setStringValue:[NSString stringWithFormat:@"%.4lf", [self.hsldr_red floatValue]]];
    }
    else {
        [self.hsldr_red setFloatValue:[[input stringValue] floatValue]];
        [self sliderValueChanged:NULL];
    }
}

- (IBAction)inputGreenChanged:(id)sender {
    NSTextField *input = sender;
    if(![self stringIsNumber:[input stringValue]]) {
        [input setStringValue:[NSString stringWithFormat:@"%.4lf", [self.hsldr_green floatValue]]];
    }
    else {
        [self.hsldr_green setFloatValue:[[input stringValue] floatValue]];
        [self sliderValueChanged:NULL];
    }
}

- (IBAction)inputBlueChanged:(id)sender {
    NSTextField *input = sender;
    if(![self stringIsNumber:[input stringValue]]) {
        [input setStringValue:[NSString stringWithFormat:@"%.4lf", [self.hsldr_blue floatValue]]];
    }
    else {
        [self.hsldr_blue setFloatValue:[[input stringValue] floatValue]];
        [self sliderValueChanged:NULL];
    }
}

- (IBAction)sliderValueChanged:(id)sender {
    GLfloat r = [self.hsldr_red floatValue];
    GLfloat g = [self.hsldr_green floatValue];
    GLfloat b = [self.hsldr_blue floatValue];
    
    [self.txt_inputRed setStringValue:[NSString stringWithFormat:@"%.4lf", r]];
    [self.txt_inputGreen setStringValue:[NSString stringWithFormat:@"%.4lf", g]];
    [self.txt_inputBlue setStringValue:[NSString stringWithFormat:@"%.4lf", b]];
    
    [self.glView setGLClearColor:r g:g b:b];
}

- (IBAction)HFOVSliderValueChanged:(id)sender {
    NSSlider *slider = (NSSlider*)sender;
    GLfloat hfov = [slider floatValue];
    
    [self.txt_inputHFOV setStringValue:[NSString stringWithFormat:@"%.2lf", hfov]];
    [self.glView setProjectionHFOV: hfov];
}

- (IBAction)modelInputChanged:(id)sender {
    NSTextField *input = (NSTextField*)sender;
    [self loadModelFile: [input stringValue]];
}

- (IBAction)touchInsideRefreshButton:(id)sender {
    GLuint tempShaderId = currentShaderId;
    NSString *filename = [self.txt_shader stringValue];
    [self loadShaderFile: filename];
    
    NSLog(@"%d\n", currentShaderId);
    if(model.isValid)
       [self.glView updateModelShader: currentShaderId];
    
    glDeleteProgram(tempShaderId);
}

- (IBAction)lightDirectionChanged:(id)sender {
    
    GLfloat x = [self.txt_lightDirX floatValue];
    GLfloat y = [self.txt_lightDirY floatValue];
    GLfloat z = [self.txt_lightDirZ floatValue];
    
    [self.glView setLightDirection:x y:y z:z];
}

#pragma mark Helper Functions

- (void) loadModelFile:(NSString*)filepath {
    char *filename = (char*)[filepath UTF8String];
    loadBlenderModel(&model, filename);
    [self.glView setModel:&model];
}

- (void) loadShaderFile:(NSString*)filepath {
    filepath = [filepath stringByReplacingOccurrencesOfString:@".fs.glsl" withString:@""];
    filepath = [filepath stringByReplacingOccurrencesOfString:@".vs.glsl" withString:@""];
    
    currentShaderId = [OpenGLHelpers compileShader: filepath];
    if(currentShaderId < 0) return;
    if(model.isValid)
        [self.glView updateModelShader: currentShaderId];
}

- (void) setPathForInput:(NSTextField*)input {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:YES];
    [panel setCanChooseDirectories:NO];
    [panel setAllowsMultipleSelection:NO];
    
    NSInteger clicked = [panel runModal];
    
    if (clicked == NSFileHandlingPanelOKButton) {
        for (NSURL *url in [panel URLs]) {
            [input setStringValue:[url path]];
        }
    }
}

- (BOOL) stringIsNumber:(NSString*)value {
    NSScanner *scanner = [NSScanner scannerWithString:value];
    return ([scanner scanFloat:NULL]) && [scanner isAtEnd];
}

@end
