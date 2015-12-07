//
//  BlenderModelLoader.cpp
//  ShaderPlay
//
//  Created by Brett Beers on 12/6/15.
//  Copyright © 2015 DentVentures. All rights reserved.
//

#include "BlenderModelLoader.hpp"

void loadBlenderModel(BlenderModel *model, char *filename) {
    
    assert(filename);
    assert(model);
    
    std::ifstream file = std::ifstream(filename, std::ios::in);
    
    if(!file.is_open()) {
        std::cout << "could not open the specified file: " << filename << std::endl;
        return;
    }
    
    std::vector<glm::vec3> vertices;
    std::vector<glm::vec2> uvs;
    std::vector<glm::vec3> normals;
    
    std::vector<unsigned int> vertexIndex;
    std::vector<unsigned int> uvIndex;
    std::vector<unsigned int> normalIndex;
    
    std::string token;
    bool reading = true;
    int result = -1, length = 0;
    while(reading) {
     
        file >> token;
        
        if(file.eof()) break;

        // NOTE(Brett): comment line, consume the line and move on;
        if(token[0] == '#') {
            std::getline(file, token, '\n');
            continue;
        }
        
        // NOTE(Brett): not using this yet. Only a single model should be used
        if(token[0] == 'o') {
            std::getline(file, token, '\n');
            continue;
        }
        
        if(token[0] == 's') {
            std::getline(file, token, '\n');
            continue;
        }
        
        if(token == "mtllib") {
            std::getline(file, token, '\n');
            continue;
        }

        if(token == "usemtl") {
            std::getline(file, token, '\n');
            continue;
        }
        
        // NOTE(Brett): Done with easy stuff, now read the file
        if(token[0] == 'f') {
            std::string line;
            std::getline(file, line, '\n');
//            std::cout << "LINE: " << line << std::endl;
            
            std::istringstream iss(line);
            std::string group;
            while(std::getline(iss, group, ' ')) {
                if(group == "") continue;
                
                std::istringstream isg(group);
                std::string t;
    
                std::getline(isg, t, '/');
                if(t != "")
                vertexIndex.push_back(std::stoi(t, nullptr, 10));
                
                std::getline(isg, t, '/');
                if(t != "")
                    uvIndex.push_back(std::stoi(t, nullptr, 10));
                
                std::getline(isg, t, '/');
                if(t != "")
                    normalIndex.push_back(std::stoi(t, nullptr, 10));
            };
            
//            std::cout << std::endl;
        }

        // NOTE(Brett): 'v '
        if(token == "v") {
            glm::vec3 v;
            file >> v.x >> v.y >> v.z;
//            std::cout << "V: " << v.x << ", " << v.y << ", " << v.z << std::endl;
            vertices.push_back(v);
            continue;
        }
        
        // NOTE(Brett): 'vt'
        if(token == "vt") {
            glm::vec2 vt;
            file >> vt.x >> vt.y;
//            std::cout << "VT: " << vt.x << ", " << vt.y << std::endl;
            uvs.push_back(vt);
            continue;
        }
        
        // NOTE(Brett): 'vn'
        if(token == "vn") {
            glm::vec3 vn;
            file >> vn.x >> vn.y >> vn.z;
//            std::cout << "VN: " << vn.x << ", " << vn.y << ", " << vn.z << std::endl;
            normals.push_back(vn);
            continue;
        }
    }
    
    for(int i = 0; i != vertexIndex.size(); ++i) {
        model->vertices.push_back(vertices[vertexIndex[i]-1]);
    }
    
    for(int i = 0; i != normalIndex.size(); ++i) {
        model->normals.push_back(normals[normalIndex[i]-1]);
    }
    
    for(int i = 0; i != uvIndex.size(); ++i) {
        model->uvs.push_back(uvs[uvIndex[i]-1]);
    }
    
    std::cout << "Finished parsing model" << std::endl;
    return;
}

void prepareModel(BlenderModel *model, GLuint shaderId) {
    
    assert(model);
    
    model->shaderId = shaderId;
    glUseProgram(model->shaderId);
    
    glGenVertexArrays(1, &model->VAO);
    glBindVertexArray(model->VAO);
    
    glGenBuffers(1, &model->VBO);
    glGenBuffers(1, &model->VNBO);
//    glGenBuffers(1, &model->UVBO);
    
    glBindBuffer(GL_ARRAY_BUFFER, model->VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(glm::vec3)*model->vertices.size(), (GLfloat*)&model->vertices[0], GL_STATIC_DRAW);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 3, GL_FLOAT, false, 0, 0);
    
    glBindBuffer(GL_ARRAY_BUFFER, model->VNBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(glm::vec3)*model->normals.size(), (GLfloat*)&model->normals[0], GL_STATIC_DRAW);
    glEnableVertexAttribArray(1);
    glVertexAttribPointer(1, 3, GL_FLOAT, false, 0, 0);
    
//    glBindBuffer(GL_ARRAY_BUFFER, model->UVBO);
//    glBufferData(GL_ARRAY_BUFFER, sizeof(glm::vec2)*model->uvs.size(), &model->uvs, GL_STATIC_DRAW);
//    glEnableVertexAttribArray(2);
//    glVertexAttribPointer(2, 2, GL_FLOAT, false, 0, 0);

//    glBufferData(GL_ELEMENT_ARRAY_BUFFER, model->uvIndex.size(), &model->uvIndex, GL_STATIC_DRAW);
    
    model->isValid = true;
    glBindVertexArray(0);
    
}

void updateModelShader(BlenderModel *model, GLuint shaderId) {
    assert(model);
    
    model->shaderId = shaderId;
    glUseProgram(model->shaderId);
    
    glBindVertexArray(model->VAO);
    
    glBindBuffer(GL_ARRAY_BUFFER, model->VBO);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 3, GL_FLOAT, false, 0, 0);
    
    glBindBuffer(GL_ARRAY_BUFFER, model->VNBO);
    glEnableVertexAttribArray(1);
    glVertexAttribPointer(1, 3, GL_FLOAT, false, 0, 0);
    
    //    glBindBuffer(GL_ARRAY_BUFFER, model->UVBO);
    //    glBufferData(GL_ARRAY_BUFFER, sizeof(glm::vec2)*model->uvs.size(), &model->uvs, GL_STATIC_DRAW);
    //    glEnableVertexAttribArray(2);
    //    glVertexAttribPointer(2, 2, GL_FLOAT, false, 0, 0);
    
    //    glBufferData(GL_ELEMENT_ARRAY_BUFFER, model->uvIndex.size(), &model->uvIndex, GL_STATIC_DRAW);
    
    glBindVertexArray(0);
    
}
