



// DATA

in vec2 v_coordinates;

layout(location = 0) out ivec4 output0;
layout(location = 1) out ivec4 output1;
layout(location = 2) out ivec4 output2;

uniform isampler2D u_inputTexture0;
uniform isampler2D u_inputTexture1;
uniform isampler2D u_inputTexture2;

uniform bool u_isPointerDown;
uniform int u_time;
uniform int u_inputKey;
uniform int u_maxSoakedCells;
uniform int u_soakPerAbsorb;
uniform float u_spawnerSize;
uniform vec2 u_pointerPosition;
