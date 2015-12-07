//
//  ModelViewerParentProtocol.h
//  ShaderPlay
//
//  Created by Brett Beers on 12/4/15.
//  Copyright © 2015 DentVentures. All rights reserved.
//

#ifndef ModelViewerParentProtocol_h
#define ModelViewerParentProtocol_h

@protocol ModelViewerParent
- (void)glViewReady;
- (void)cameraEyeChanged:(GLfloat)x y:(GLfloat)y z:(GLfloat)z;
- (void)cameraFocusChanged:(GLfloat)x y:(GLfloat)y z:(GLfloat)z;

@end

#endif /* ModelViewerParentProtocol_h */
