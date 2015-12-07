//
//  BlenderModelLoader.hpp
//  ShaderPlay
//
//  Created by Brett Beers on 12/6/15.
//  Copyright © 2015 DentVentures. All rights reserved.
//

#ifndef BlenderModelLoader_hpp
#define BlenderModelLoader_hpp

#include <iostream>
#include <sstream>
#include <fstream>
#include <string>
#include <vector>
#include <glm/glm.hpp>
#include <assert.h>

#include <OpenGL/gl3.h>


#define MAX_TOKEN_LENGTH 1024

typedef struct _BlenderModel {    
    std::vector<glm::vec3> vertices;
    std::vector<glm::vec2> uvs;
    std::vector<glm::vec3> normals;
    
    GLuint VAO;
    GLuint VBO, VNBO, UVBO;
    
    GLuint shaderId;
    bool isValid;
    
} BlenderModel;

void loadBlenderModel(BlenderModel *model, char *filename);

void prepareModel(BlenderModel *model, GLuint shaderId);

void updateModelShader(BlenderModel *model, GLuint shaderId);

#endif /* BlenderModelLoader_hpp */
