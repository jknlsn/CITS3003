attribute vec3 vPosition;
attribute vec3 vNormal;
attribute vec2 vTexCoord;

varying vec3 N;
varying vec3 pos;
varying vec3 Lvec1;
varying vec3 Lvec2;
varying vec2 texCoord;

uniform mat4 ModelView;
uniform vec4 LightPosition1;
uniform vec4 LightPosition2;
uniform mat4 Projection;

void main()
{

    vec4 vpos = vec4(vPosition, 1.0);

    // Transform vertex position into eye coordinates
    pos = (ModelView * vpos).xyz;


    // The vector to the light from the vertex
    Lvec1 = LightPosition1.xyz - pos;
    Lvec2 = LightPosition2.xyz;

    // // Transform vertex normal into eye coordinates (assumes scaling
    // // is uniform across dimensions)
    // // vec3 N = normalize( (ModelView*vec4(vNormal, 0.0)).xyz );
    N = normalize( (ModelView*vec4(vNormal, 0.0)).xyz );

    gl_Position = Projection * ModelView * vpos;
    texCoord = vTexCoord;
}
