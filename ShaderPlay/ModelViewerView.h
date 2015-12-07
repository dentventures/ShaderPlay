//
//  ModelViewerView.h
//  ShaderPlay
//
//  Created by Brett Beers on 12/4/15.
//  Copyright © 2015 DentVentures. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ModelViewerParentProtocol.h"
#include "BlenderModelLoader.hpp"

@interface ModelViewerView : NSOpenGLView

@property (nonatomic, strong) NSViewController<ModelViewerParent> *parent;

- (void)setGLClearRedColor:(GLfloat)r;
- (void)setGLClearGreenColor:(GLfloat)g;
- (void)setGLClearBlueColor:(GLfloat)b;
- (void)setGLClearColor:(GLfloat)r g:(GLfloat)g b:(GLfloat)b;

- (void)setProjectionHFOV:(GLfloat)hfov;
- (void)setCameraEyePosition:(GLfloat)x y:(GLfloat)y z:(GLfloat)z;
- (void)setCameraFocusPosition:(GLfloat)x y:(GLfloat)y z:(GLfloat)z;

- (void)getCameraEyePosition:(GLfloat*)x y:(GLfloat*)y z:(GLfloat*)z;
- (void)getCameraFocusPosition:(GLfloat*)x y:(GLfloat*)y z:(GLfloat*)z;

- (void)setLightDirection:(GLfloat)x y:(GLfloat)y z:(GLfloat)z;

- (void)setModel:(BlenderModel*)model;
- (void)updateModelShader:(GLuint)shaderId;


@end
