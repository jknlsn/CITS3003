attribute vec3 vPosition;
attribute vec3 vNormal;
attribute vec2 vTexCoord;

attribute vec4 boneIDs;
attribute vec4 boneWeights;
uniform mat4 boneTransforms[64];

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

    mat4 boneTransform = boneWeights[0] * boneTransforms[int(boneIDs[0])] +
                         boneWeights[1] * boneTransforms[int(boneIDs[1])] +
                         boneWeights[2] * boneTransforms[int(boneIDs[2])] +
                         boneWeights[3] * boneTransforms[int(boneIDs[3])] ;

    vec4 vpos = boneTransform * vec4(vPosition,1.0);
    vec4 vnorm = boneTransform * vec4(vNormal,0.0);

    // vec4 vpos = vec4(vPosition, 1.0);

    // Transform vertex position into eye coordinates
    pos = (ModelView * vpos).xyz;


    // The vector to the light from the vertex
    Lvec1 = LightPosition1.xyz - pos;
    Lvec2 = LightPosition2.xyz;

    // // Transform vertex normal into eye coordinates (assumes scaling
    // // is uniform across dimensions)
    // // vec3 N = normalize( (ModelView*vec4(vNormal, 0.0)).xyz );
    N = normalize( (ModelView * vnorm).xyz );

    gl_Position = Projection * ModelView * vpos;
    texCoord = vTexCoord;
}
