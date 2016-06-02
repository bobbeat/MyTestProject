//
//  Shader.vsh
//  openglcircle
//
//  Created by gaozhimin on 12-9-14.
//  Copyright (c) 2012年 autonavi. All rights reserved.
//

attribute vec4 position;

//
attribute vec2 TexCoordIn; // New
varying vec2 TexCoordOut; // New

void main()
{
    gl_Position = position;
    
    TexCoordOut = TexCoordIn; // New
}
