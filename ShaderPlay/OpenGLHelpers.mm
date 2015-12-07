//
//  OpenGLHelpers.m
//  TouchRPGPOC
//
//  Created by Brett Beers on 11/21/15.
//  Copyright © 2015 DentVentures. All rights reserved.
//

#import "OpenGLHelpers.h"

@implementation OpenGLHelpers

+ (GLuint) compileShader:(NSString*)shaderName {
    
    NSString *vertexShaderName = [NSString stringWithFormat:@"%@.vs.glsl", shaderName];
    NSString *fragmentShaderName = [NSString stringWithFormat:@"%@.fs.glsl", shaderName];
    
    GLuint vertexShader = [self compileShader:vertexShaderName withType:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self compileShader:fragmentShaderName withType:GL_FRAGMENT_SHADER];
    
    GLuint shaderProgramHandle = glCreateProgram();
    glAttachShader(shaderProgramHandle, vertexShader);
    glAttachShader(shaderProgramHandle, fragmentShader);
    glLinkProgram(shaderProgramHandle);
    
    GLint linkResult;
    glGetProgramiv(shaderProgramHandle, GL_LINK_STATUS, &linkResult);
    if(linkResult == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(shaderProgramHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
//        exit(1);
        return -1;
    }
    
    return shaderProgramHandle;
}

+ (GLuint)compileShader:(NSString*)shaderName withType:(GLenum)shaderType {
    
    NSString* shaderPath = shaderName;
    NSError* error;
    NSString* shaderString = [NSString stringWithContentsOfFile:shaderPath encoding:NSUTF8StringEncoding error:&error];
    if (!shaderString) {
        NSLog(@"Error loading shader: %@", error.localizedDescription);
        exit(1);
    }
    
    GLuint shaderHandle = glCreateShader(shaderType);
    
    const char * shaderStringUTF8 = [shaderString UTF8String];
    int shaderStringLength = (int)[shaderString length];
    glShaderSource(shaderHandle, 1, &shaderStringUTF8, &shaderStringLength);
    
    glCompileShader(shaderHandle);
    
    GLint compileSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        NSLog(@"Error in file: %@\n", shaderName);
        GLchar messages[256];
        glGetShaderInfoLog(shaderHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
//        exit(1);
        return -1;
    }
    
    return shaderHandle;
    
}

@end
