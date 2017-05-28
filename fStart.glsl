// added
varying vec3 pos;
varying vec3 Lvec1;
varying vec3 Lvec2;
varying vec3 N;

vec4 color;
// kept
varying vec2 texCoord;  // The third coordinate is always 0.0 and is discarded

// Added
uniform vec3 AmbientProduct, DiffuseProduct, SpecularProduct;
uniform mat4 ModelView;
uniform vec4 LightPosition1;
uniform vec4 LightPosition2;
uniform vec3 LightColor1;
uniform vec3 LightColor2;
uniform float LightBrightness1;
uniform float LightBrightness2;
uniform float Shininess;

uniform sampler2D texture;

void main()
{

    // The vector to the light from the vertex
    vec3 Lvec1 = LightPosition1.xyz - pos;
    vec3 Lvec2 = LightPosition2.xyz - pos;

    vec3 L1 = normalize( Lvec1 );   // Direction to the light source
    vec3 L2 = normalize( Lvec2 );   // Direction to the light source
    vec3 E = normalize( -pos );   // Direction to the eye/camera
    vec3 H1 = normalize( L1 + E );  // Halfway vector
    vec3 H2 = normalize( L2 + E );  // Halfway vector

    // Transform vertex normal into eye coordinates (assumes scaling
    // is uniform across dimensions)
    // vec3 N = normalize( (ModelView*vec4(vNormal, 0.0)).xyz );

    // Compute terms in the illumination equation
    vec4 ambient1 = vec4((LightColor1 * LightBrightness1),1.0) * vec4(AmbientProduct,1.0);
    vec4 ambient2 = vec4((LightColor2 * LightBrightness2),1.0) * vec4(AmbientProduct,1.0);

    float Kd1 = max( dot(L1, N), 0.0 );
    vec4  diffuse1 = Kd1 * vec4(DiffuseProduct,1.0);
    float Kd2 = max( dot(L2, N), 0.0 );
    vec4  diffuse2 = Kd2 * vec4(DiffuseProduct,1.0);

    float Ks1 = pow( max(dot(N, H1), 0.0), Shininess );
    vec4  specular1 = Ks1 * LightBrightness1 * vec4(SpecularProduct,1.0);
    float Ks2 = pow( max(dot(N, H2), 0.0), Shininess );
    vec4  specular2 = Ks2 * LightBrightness1 * vec4(SpecularProduct,1.0);

    if (dot(L1, N) < 0.0 ) {
      specular1 = vec4(0.0, 0.0, 0.0, 1.0);
    }
    if (dot(L2, N) < 0.0 ) {
      specular2 = vec4(0.0, 0.0, 0.0, 1.0);
    }

    // globalAmbient is independent of distance from the light source
    vec4 globalAmbient = vec4(0.1, 0.1, 0.1, 1.0);
    color = globalAmbient + ambient1 + ambient2 + diffuse1 + specular1 + diffuse2 + specular2;
    color.a = 1.0;
    gl_FragColor = color * texture2D( texture, texCoord * 2.0 );
}
