varying vec4 color;
varying vec2 texCoord;  // The third coordinate is always 0.0 and is discarded

uniform sampler2D texture;

void main()
{
    gl_FragColor = color * texture2D( texture, texCoord * 2.0 );
}
