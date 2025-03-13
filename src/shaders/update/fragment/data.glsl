// DATA

in vec2 v_coordinates;

layout(location = 0) out uvec4 output0;
layout(location = 1) out uvec4 output1;
layout(location = 2) out uvec4 output2;

uniform usampler2D u_inputTexture0;
uniform usampler2D u_inputTexture1;
uniform usampler2D u_inputTexture2;

uniform bool u_isPointerDown;
uniform uint u_time;
uniform uint u_inputKey;
uniform uint u_maxSoakedCells;
uniform uint u_soakPerAbsorb;
uniform float u_spawnerSize;
uniform vec2 u_pointerPosition;
