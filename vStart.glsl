attribute vec3 vPosition;
attribute vec3 vNormal;
attribute vec2 vTexCoord;

varying vec3 N;
varying vec3 pos;
varying vec3 Lvec;
varying vec2 texCoord;

uniform mat4 ModelView;
uniform vec4 LightPosition;
uniform mat4 Projection;

void main()
{

    vec4 vpos = vec4(vPosition, 1.0);

    // Transform vertex position into eye coordinates
    pos = (ModelView * vpos).xyz;


    // The vector to the light from the vertex
    Lvec = LightPosition.xyz - pos;

    // L = normalize( Lvec );   // Direction to the light source
    // E = normalize( -pos );   // Direction to the eye/camera
    // H = normalize( L + E );  // Halfway vector
    //
    // // Transform vertex normal into eye coordinates (assumes scaling
    // // is uniform across dimensions)
    // // vec3 N = normalize( (ModelView*vec4(vNormal, 0.0)).xyz );
    N = normalize( (ModelView*vec4(vNormal, 0.0)).xyz );

    gl_Position = Projection * ModelView * vpos;
    texCoord = vTexCoord;
}
