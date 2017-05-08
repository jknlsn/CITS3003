// UWA CITS3003 
// Graphics 'n Animation Tool Interface & Data Reader (gnatidread.h)

// You shouldn't need to modify the code in this file, but feel free to.
// If you do, it would be good to mark your changes with comments.

#include "bitmap.h"

char dataDir[256];  // Stores the path to the models-textures folder.
const int numTextures = 31; 
const int numMeshes = 56;


// ------Functions to fail with an error mesage then a string or int------ 

void fail(const char *msg1, char *msg2) {
    fprintf(stderr, "%s %s\n", msg1, msg2);
    exit(1);
}

void failInt(const char *msg1, int i) {
    fprintf(stderr, "%s %d\n", msg1, i);
    exit(1);
}


// -----Texture data reading--------------------------------------------

// A type for a 2D texture, with height and width in pixels
typedef struct {
    int height;
    int width;
    GLubyte *rgbData;   // Array of bytes with the colour data for the texture
} texture;

// Load a texture via Michael Sweet's bitmap.c
texture* loadTexture(char *fileName) {
    texture* t = (texture*) malloc(sizeof (texture)); 
    BITMAPINFO *info;

    t->rgbData = LoadDIBitmap(fileName, &info);
    if (t->rgbData == NULL) fail("Error loading image: ", fileName);
       
    t->height=info->bmiHeader.biHeight;
    t->width=info->bmiHeader.biWidth;

    printf("\nLoaded a %d by %d texture\n\n", t->height, t->width);

    return t;
}

// Load the texture with number num from the models-textures directory
texture* loadTextureNum(int num) {
    if (num<0 || num>=numTextures) 
        failInt("Error in loading texture - wrong texture number:", num);

    char fileName[220];    
    sprintf(fileName, "%s/texture%d.bmp", dataDir, num);
    return loadTexture(fileName);
}

//----------------------------------------------------------------------------

// Initialise the Open Asset Importer toolkit
void aiInit()
{
    struct aiLogStream stream;

    // get a handle to the predefined STDOUT log stream and attach
    // it to the logging system. It remains active for all further
    // calls to aiImportFile(Ex) and aiApplyPostProcessing.
    stream = aiGetPredefinedLogStream(aiDefaultLogStream_STDOUT,NULL);
    aiAttachLogStream(&stream);

    // ... same procedure, but this stream now writes the
    // log messages to assimp_log.txt
    stream = aiGetPredefinedLogStream(aiDefaultLogStream_FILE,"assimp_log.txt");
    aiAttachLogStream(&stream);
}

// Load a mesh by number from the models-textures directory via the Open Asset Importer
aiMesh* loadMesh(int meshNumber) {
    char filename[256];
    sprintf(filename, "%s/model%d.x", dataDir, meshNumber);
    const aiScene* scene = aiImportFile(filename, aiProcessPreset_TargetRealtime_Quality 
                                        | aiProcess_ConvertToLeftHanded);
    return scene->mMeshes[0];
}


// -------------- Strings for the texture and mesh menus ---------------------------------

char textureMenuEntries[numTextures][128] = {
    "1 Plain", "2 Rust", "3 Concrete", "4 Carpet", "5 Beach Sand", 
    "6 Rocky", "7 Brick", "8 Water", "9 Paper", "10 Marble", 
    "11 Wood", "12 Scales", "13 Fur", "14 Denim", "15 Hessian",
    "16 Orange Peel", "17 Ice Crystals", "18 Grass", "19 Corrugated Iron", "20 Styrofoam",
    "21 Bubble Wrap", "22 Leather", "23 Camouflage", "24 Asphalt", "25 Scratched Ice",
    "26 Rattan", "27 Snow", "28 Dry Mud", "29 Old Concrete", "30 Leopard Skin"
};

char objectMenuEntries[numMeshes][128] = {
    "1 Thin Dinosaur","2 Big Dog","3 Saddle Dinosaur", "4 Dragon", "5 Cleopatra", 
    "6 Bone I", "7 Bone II", "8 Rabbit", "9 Long Dragon", "10 Buddha", 
    "11 Sitting Rabbit", "12 Frog", "13 Cow", "14 Monster", "15 Sea Horse", 
    "16 Head", "17 Pelican", "18 Horse", "19 Kneeling Angel", "20 Porsche I", 
    "21 Truck", "22 Statue of Liberty", "23 Sitting Angel", "24 Metal Part", "25 Car", 
    "26 Apatosaurus", "27 Airliner", "28 Motorbike", "29 Dolphin", "30 Spaceman", 
    "31 Winnie the Pooh", "32 Shark", "33 Crocodile", "34 Toddler", "35 Fat Dinosaur", 
    "36 Chihuahua", "37 Sabre-toothed Tiger", "38 Lioness", "39 Fish", "40 Horse (head down)", 
    "41 Horse (head up)", "42 Skull", "43 Fighter Jet I", "44 Toad", "45 Convertible", 
    "46 Porsche II", "47 Hare", "48 Vintage Car", "49 Fighter Jet II", "50 Gargoyle", 
    "51 Chef", "52 Parasaurolophus", "53 Rooster", "54 T-rex", "55 Sphere"
};


//-----Code for using the mouse to adjust floats - you shouldn't need to modify this code.
// Calling setTool(vX, vY, vMat, wX, wY, wMat) below makes the left button adjust *vX and *vY
// as the mouse moves in the X and Y directions, via the transformation vMat which can be used
// for scaling and rotation. Similarly the middle button adjusts *wX and *wY via wMat.
// Any of vX, vY, wX, wY may be NULL in which case nothing is adjusted for that component.

static vec2 prevPos;
static mat2 leftTrans, middTrans;
static int currButton = -1; 

static void doNothingCallback(vec2 xy) { return; }

static void(*leftCallback)(vec2) = &doNothingCallback;
static void(*middCallback)(vec2) = &doNothingCallback;

static int mouseX=0, mouseY=0;         // Updated in the mouse-passive-motion function.

static vec2 currMouseXYscreen(float x, float y) { 
    return vec2( x/windowWidth, (windowHeight-y)/windowHeight ); 
} 

static void doToolUpdateXY(int x, int y) { 
    if (currButton == GLUT_LEFT_BUTTON || currButton == GLUT_MIDDLE_BUTTON) {
        vec2 currPos = vec2(currMouseXYscreen(x,y));
        if (currButton==GLUT_LEFT_BUTTON)        
            leftCallback(leftTrans * (currPos - prevPos));
        else
            middCallback(middTrans * (currPos - prevPos));
            
        prevPos = currPos;
        glutPostRedisplay();
    }
}
        
static mat2 rotZ(float rotSidewaysDeg) {
    mat4 rot4 = RotateZ(rotSidewaysDeg);    
    return mat2(rot4[0][0], rot4[0][1], rot4[1][0], rot4[1][1]);
}

//static vec2 currXY(float rotSidewaysDeg) { return rotZ(rotSidewaysDeg) * vec2(currRawX(), currRawY()); }
static vec2 currMouseXYworld(float rotSidewaysDeg) { return rotZ(rotSidewaysDeg) * currMouseXYscreen(mouseX, mouseY); }

// See the comment about 40 lines above
static void setToolCallbacks( void(*newLeftCallback)(vec2 transformedMovement), mat2 leftT, 
                              void(*newMiddCallback)(vec2 transformedMovement), mat2 middT) {

    leftCallback = newLeftCallback;
    leftTrans = leftT; 
    middCallback = newMiddCallback;
    middTrans = middT;

    currButton=-1;  // No current button to start with

    // std::cout << leftXYold << " " << middXYold << std::endl; // For debugging
}

vec2 clickPrev;

static void activateTool(int button) {
    currButton = button;
    clickPrev = currMouseXYscreen(mouseX, mouseY);

    // std::cout << clickOrigin << std::endl;  // For debugging
}

static void deactivateTool() {
    currButton=-1; 
}

//-------------------------------------------------------------
