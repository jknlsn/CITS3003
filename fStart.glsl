// varying vec4 color;
// varying vec2 texCoord;  // The third coordinate is always 0.0 and is discarded
//
// uniform sampler2D texture;
//
// void main()
// {
//     gl_FragColor = color * texture2D( texture, texCoord * 2.0 );
// }


// removed
// varying vec4 color;

// added
varying vec3 N;
varying vec3 L;
varying vec3 E;
varying vec3 H;
vec4 color;
// kept
varying vec2 texCoord;  // The third coordinate is always 0.0 and is discarded

// Added
uniform vec3 AmbientProduct, DiffuseProduct, SpecularProduct;
uniform mat4 ModelView;
uniform vec4 LightPosition;
uniform float Shininess;

uniform sampler2D texture;

void main()
{
    // Compute terms in the illumination equation
    vec4 ambient = vec4(AmbientProduct,1.0);

    float Kd = max( dot(L, N), 0.0 );
    vec4  diffuse = Kd * vec4(DiffuseProduct,1.0);

    float Ks = pow( max(dot(N, H), 0.0), Shininess );
    vec4  specular = Ks * vec4(SpecularProduct,1.0);

    if (dot(L, N) < 0.0 ) {
      specular = vec4(0.0, 0.0, 0.0, 1.0);
    }

    // globalAmbient is independent of distance from the light source
    vec4 globalAmbient = vec4(0.1, 0.1, 0.1, 1.0);
    color = globalAmbient + ambient + diffuse + specular;
    color.a = 1.0;
    gl_FragColor = color * texture2D( texture, texCoord * 2.0 );
}
