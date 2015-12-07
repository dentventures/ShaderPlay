//
//  ModelViewerView.m
//  ShaderPlay
//
//  Created by Brett Beers on 12/4/15.
//  Copyright © 2015 DentVentures. All rights reserved.
//

#import <OpenGL/gl.h>
#import <OpenGL/gl3.h>
#import "ModelViewerView.h"

#import "OpenGLHelpers.h"

#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>

#include "BlenderModelLoader.hpp"

@implementation ModelViewerView
{
    BlenderModel *blenderModel;
    glm::vec3 lightDir;
    
    GLfloat bglClearColor[4];
    CVDisplayLinkRef displayLink;

    glm::mat4 projectionMatrix;
    GLfloat horizontalFov;
    GLfloat nearPlane;
    GLfloat farPlane;
    
    glm::mat4 viewMatrix;
    glm::vec3 cameraEye;
    glm::vec3 cameraFocus;
    
    glm::mat4 modelMatrix;
    
    GLuint gridVAO;
    GLuint gridVBO;
    
    float aspect;
    
    glm::vec3* gridVertexData;
    float gridLinesX, gridLinesZ;
    
    GLuint linesShaderId;
    
    glm::vec3 triangleData[6];
    
    struct {
        glm::vec2 pos;
        
        glm::vec2 lastPos;
        long int lastPosTimestamp;
        
        glm::vec2 mouseDownPos;
        long int mouseDownTimestamp;
        
        glm::vec2 mouseUpPos;
        long int mouseUpTimestamp;
        
        glm::vec2 lastClick;
        long int lastClickTimestamp;
        
    } mouseInputState;
 
    long int globalTime;
    
}

- (void)awakeFromNib {
    
    NSOpenGLPixelFormatAttribute attributes[] = {
        NSOpenGLPFAOpenGLProfile, NSOpenGLProfileVersion3_2Core,   // Core Profile !
        NSOpenGLPFADoubleBuffer,
        NSOpenGLPFADepthSize, 24,
        NSOpenGLPFAAccelerated,
        NSOpenGLPFAColorSize, 24,
        NSOpenGLPFAAlphaSize, 8,
        NSOpenGLPFAAllowOfflineRenderers,
        0
    };
    
    NSOpenGLPixelFormat *format = [[NSOpenGLPixelFormat alloc] initWithAttributes:attributes];
    NSOpenGLContext *context = [[NSOpenGLContext alloc] initWithFormat:format shareContext: nil];
    // [context setView: self];
    [self setPixelFormat: format];
    [self setOpenGLContext: context];
    
}

-(void)mouseDown:(NSEvent *)theEvent {
    NSPoint eventLocation = theEvent.locationInWindow;
    NSPoint localPoint = [self convertPoint:eventLocation fromView:nil];
    NSLog(@"%lf\n", localPoint.x);
    mouseInputState.lastPos = glm::vec2{localPoint.x, localPoint.y};
    mouseInputState.pos = glm::vec2{localPoint.x, localPoint.y};
}

-(void)mouseMoved:(NSEvent *)theEvent {
    NSPoint eventLocation = theEvent.locationInWindow;
    NSPoint localPoint = [self convertPoint:eventLocation fromView:nil];
    mouseInputState.lastPos = mouseInputState.pos;
    mouseInputState.pos = glm::vec2{localPoint.x, localPoint.y};
}

-(void)mouseDragged:(NSEvent *)theEvent {
    [[NSApp keyWindow] makeFirstResponder: self];
    NSPoint eventLocation = theEvent.locationInWindow;
    NSPoint localPoint = [self convertPoint:eventLocation fromView:nil];
    mouseInputState.lastPos = mouseInputState.pos;
    mouseInputState.pos = glm::vec2{localPoint.x, localPoint.y};
    
    glm::vec2 delta = mouseInputState.pos - mouseInputState.lastPos;
    glm::vec3 direction = cameraFocus - cameraEye;
    
    glm::vec3 horiz = glm::normalize(glm::cross(direction, glm::vec3{0.f, 1.f, 0.f}));

    cameraFocus.y += delta.y;
    cameraFocus.x += horiz.x*delta.x;
    cameraFocus.z += horiz.z*delta.x;
    viewMatrix = glm::lookAt(cameraEye, cameraFocus, glm::vec3{0.0f, 1.0f, 0.0f});
    [self.parent cameraFocusChanged:cameraFocus.x y:cameraFocus.y z:cameraFocus.z];
}

-(void)mouseUp:(NSEvent *)theEvent {
    NSPoint eventLocation = theEvent.locationInWindow;
    NSPoint localPoint = [self convertPoint:eventLocation fromView:nil];
    
}

- (void)scrollWheel:(NSEvent *)theEvent {
    glm::vec3 dir = glm::normalize(cameraFocus - cameraEye);
    GLfloat delta = theEvent.scrollingDeltaY;
    cameraEye -= glm::vec3{dir.x*delta, dir.y*delta, dir.z*delta};
    cameraFocus = cameraEye + dir*100.f;
    viewMatrix = glm::lookAt(cameraEye, cameraFocus, glm::vec3{0.0f, 1.0f, 0.0f});
    [self.parent cameraEyeChanged:cameraEye.x y:cameraEye.y z:cameraEye.z];
    [self.parent cameraFocusChanged:cameraFocus.x y:cameraFocus.y z:cameraFocus.z];
}



- (void)prepareOpenGL{
    NSLog(@"preparing opengl\n");
    GLint swapInt = 1;
    [[self openGLContext] setValues:&swapInt forParameter:NSOpenGLCPSwapInterval];
    
    NSOpenGLContext* context = [self openGLContext];
    [context makeCurrentContext];

    
    CVDisplayLinkCreateWithActiveCGDisplays(&displayLink);
    CVDisplayLinkSetOutputCallback(displayLink, &displayLinkCallback, (__bridge void *)self);
    CGLPixelFormatObj cglPixelFormat = [[self pixelFormat] CGLPixelFormatObj];
    CVDisplayLinkSetCurrentCGDisplayFromOpenGLContext(displayLink, [context CGLContextObj], cglPixelFormat);
    CVDisplayLinkStart(displayLink);

    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LEQUAL);
    
    
    NSString* defaultShaderPath = [[NSBundle mainBundle] pathForResource:@"default_lines.vs" ofType:@"glsl"];
    NSURL *url = [NSURL URLWithString:defaultShaderPath];
    defaultShaderPath = [[url absoluteString] stringByDeletingLastPathComponent];
    defaultShaderPath = [NSString stringWithFormat:@"%@/%@", defaultShaderPath, @"default_lines" ];
    
    linesShaderId = [OpenGLHelpers compileShader:defaultShaderPath];
    NSLog(@"Compiled line shader: %d", linesShaderId);
    assert(linesShaderId > 0);
    glUseProgram(linesShaderId);
    
    aspect = self.frame.size.width/self.frame.size.height;
    horizontalFov = 45.0f;
    nearPlane = 0.1f;
    farPlane = 1000.f;
    [self setupProjectionMatrix:horizontalFov aspect:aspect near:nearPlane far:farPlane];
    
    cameraEye = glm::vec3{0.0f, 25.0f, 25.0f};
    cameraFocus = glm::vec3{0.0f, -75.0f, -75.0f};
    viewMatrix = glm::lookAt(cameraEye, cameraFocus, glm::vec3{0.0f, 1.0f, 0.0f});
    
    modelMatrix = glm::mat4();
    
    gridLinesX = 50.f;
    gridLinesZ = 50.f;
    
    glGenVertexArrays(1, &gridVAO);
    glBindVertexArray(gridVAO);
    glGenBuffers(1, &gridVBO);
    
    GLint positionLocation = glGetAttribLocation(linesShaderId, "position");
    
    int gridVertexSize = sizeof(glm::vec3)*(gridLinesX+gridLinesZ)*4;
    gridVertexData = (glm::vec3*)malloc(gridVertexSize);
    
    for(float x = 0; x < gridLinesX; ++x) {
        int i = x*4;
        gridVertexData[i+0] = glm::vec3{-gridLinesX, 0.0f, -x};
        gridVertexData[i+1] = glm::vec3{ gridLinesX, 0.0f, -x};
        gridVertexData[i+2] = glm::vec3{-gridLinesX, 0.0f,  x};
        gridVertexData[i+3] = glm::vec3{ gridLinesX, 0.0f,  x};
    }
    
    for(float z = 0; z < gridLinesZ; ++z) {
        int i = (gridLinesX*4)+z*4;
        gridVertexData[i+0] = glm::vec3{-z, 0.0f, -gridLinesZ};
        gridVertexData[i+1] = glm::vec3{-z, 0.0f,  gridLinesZ};
        gridVertexData[i+2] = glm::vec3{ z, 0.0f, -gridLinesZ};
        gridVertexData[i+3] = glm::vec3{ z, 0.0f,  gridLinesZ};
    }
    
    triangleData[0] = glm::vec3{-0.5, -0.5, 0.0};
    triangleData[1] = glm::vec3{0.0, 0.4, 0.0};
    triangleData[2] = glm::vec3{0.0, 0.4, 0.0};
    triangleData[3] = glm::vec3{0.5, -0.5, 0.0};
    triangleData[4] = glm::vec3{0.5, -0.5, 0.0};
    triangleData[5] = glm::vec3{-0.5, -0.5, 0.0};
    
    lightDir = glm::vec3{1.f, -1.f, 1.f};
    
    glBindBuffer(GL_ARRAY_BUFFER, gridVBO);
    glEnableVertexAttribArray(positionLocation);
    glVertexAttribPointer(positionLocation, 3, GL_FLOAT, false, 0, 0);
    glBufferData(GL_ARRAY_BUFFER, gridVertexSize, gridVertexData, GL_STATIC_DRAW);
    
    [self.parent glViewReady];
}

- (void)reshape {
    aspect = self.frame.size.width/self.frame.size.height;
    [self setupProjectionMatrix:horizontalFov aspect:aspect near:nearPlane far:farPlane];
}

static CVReturn displayLinkCallback(CVDisplayLinkRef displayLink, const CVTimeStamp* now, const CVTimeStamp* outputTime,
                                    CVOptionFlags flagsIn, CVOptionFlags* flagsOut, void* displayLinkContext) {
    
    @autoreleasepool {
        [(__bridge ModelViewerView*)displayLinkContext render];
    }
    return kCVReturnSuccess;
    
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    [self render];
}


- (void)renderModel {
    if(!blenderModel) return;

    glBindVertexArray(blenderModel->VAO);
    glUseProgram(blenderModel->shaderId);
    GLint projectionLocation = glGetUniformLocation(blenderModel->shaderId, "projection");
    GLint viewLocation = glGetUniformLocation(blenderModel->shaderId, "view");
    GLint modelLocation = glGetUniformLocation(blenderModel->shaderId, "model");
    GLint lightLocation = glGetUniformLocation(blenderModel->shaderId, "lightDirection");
    
    glUniformMatrix4fv(projectionLocation, 1, false, (GLfloat*)&projectionMatrix[0]);
    glUniformMatrix4fv(viewLocation, 1, false, (GLfloat*)&viewMatrix[0]);
    glUniformMatrix4fv(modelLocation, 1, false, (GLfloat*)&modelMatrix[0]);
    glUniform3fv(lightLocation, 1, (GLfloat*)&lightDir[0]);
    
    glDrawArrays(GL_TRIANGLES, 0, static_cast<int>(blenderModel->vertices.size()));
    glBindVertexArray(0);
}

- (void)render {
    NSOpenGLContext* context = [self openGLContext];
    [context makeCurrentContext];
    CGLLockContext([context CGLContextObj]);
    
    glClearColor(bglClearColor[0], bglClearColor[1], bglClearColor[2], bglClearColor[3]);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glUseProgram(linesShaderId);
    glBindVertexArray(gridVAO);
    
    GLint projectionLocation = glGetUniformLocation(linesShaderId, "projection");
    GLint viewLocation = glGetUniformLocation(linesShaderId, "view");
    GLint modelLocation = glGetUniformLocation(linesShaderId, "model");
    
    glUniformMatrix4fv(projectionLocation, 1, false, (GLfloat*)&projectionMatrix[0]);
    glUniformMatrix4fv(viewLocation, 1, false, (GLfloat*)&viewMatrix[0]);
    glUniformMatrix4fv(modelLocation, 1, false, (GLfloat*)&modelMatrix[0]);
    
    glDrawArrays(GL_LINES, 0, 400);
    
    [self renderModel];
    
    CGLFlushDrawable([context CGLContextObj]);
    CGLUnlockContext([context CGLContextObj]);
}


- (void)setGLClearRedColor:(GLfloat)r {
    bglClearColor[0] = r;
}

- (void)setGLClearGreenColor:(GLfloat)g {
    bglClearColor[1] = g;
}

- (void)setGLClearBlueColor:(GLfloat)b {
    bglClearColor[2] = b;
}

- (void)setGLClearColor:(GLfloat)r g:(GLfloat)g b:(GLfloat)b {
    bglClearColor[0] = r;
    bglClearColor[1] = g;
    bglClearColor[2] = b;
}

- (void)setProjectionHFOV:(GLfloat)hfov {
    horizontalFov = hfov;
    [self setupProjectionMatrix:horizontalFov aspect:aspect near:nearPlane far:farPlane];
}

- (void) setupProjectionMatrix:(GLfloat)hfov aspect:(GLfloat)aspect near:(GLfloat)near far:(GLfloat)far {
    projectionMatrix = glm::perspective(hfov, aspect, near, far);
}

- (void)setCameraEyePosition:(GLfloat)x y:(GLfloat)y z:(GLfloat)z {
    cameraEye = glm::vec3{x, y, z};
    viewMatrix = glm::lookAt(cameraEye, cameraFocus, glm::vec3{0.0f, 1.0f, 0.0f});
}

- (void)setCameraFocusPosition:(GLfloat)x y:(GLfloat)y z:(GLfloat)z {
    cameraFocus = glm::vec3{x, y, z};
    viewMatrix = glm::lookAt(cameraEye, cameraFocus, glm::vec3{0.0f, 1.0f, 0.0f});
}

- (void)getCameraEyePosition:(GLfloat*)x y:(GLfloat*)y z:(GLfloat*)z {
    *x = cameraEye.x;
    *y = cameraEye.y;
    *z = cameraEye.z;
}

- (void)getCameraFocusPosition:(GLfloat*)x y:(GLfloat*)y z:(GLfloat*)z {
    *x = cameraFocus.x;
    *y = cameraFocus.y;
    *z = cameraFocus.z;
}

- (void)setLightDirection:(GLfloat)x y:(GLfloat)y z:(GLfloat)z {
    lightDir.x = x;
    lightDir.y = y;
    lightDir.z = z;
}


- (void)setModel:(BlenderModel*)model {
    // NOTE(Brett): this needs to be handled better. Should not have to query the model for the shader to set the shader
    blenderModel = model;
    GLuint shaderId = model->shaderId;
    if(!shaderId)
        shaderId = linesShaderId;
    prepareModel(blenderModel, shaderId);
}

- (void)updateModelShader:(GLuint)shaderId {
    updateModelShader(blenderModel, shaderId);
}

@end
