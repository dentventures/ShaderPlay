//
//  OpenGLHelpers.h
//  TouchRPGPOC
//
//  Created by Brett Beers on 11/21/15.
//  Copyright © 2015 DentVentures. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#include <OpenGL/gl3.h>
#include <OpenGL/gl3ext.h>

@interface OpenGLHelpers : NSObject

+ (GLuint) compileShader:(NSString*)shaderName;

@end
