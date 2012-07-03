import processing.opengl.*;

// graphics options
boolean useOpenGL = false;

// midi stuff
import promidi.*;

MidiIO midiIO;
int nMidiOut = 9;
MidiOut[] midiOuts = new MidiOut[nMidiOut];

int lastChannel; // for hacking around the knob limitations
int APCDeviceNum = 0;

boolean useMidi = false;
boolean midiDebug = false;


// the beam mixer
int nBeams = 2;
Mixer mixer = new Mixer(nBeams);


int frameNumber;

// screem geometry
//int x_size = 1920;
//int y_size = 1080;
//int x_size = 1280;
//int y_size = 720;

int x_size = 1280;
int y_size = 768;

int x_center, y_center;



// various constraints and multipliers
int maxRadius; // largest radius given screen constraints
float maxRadiusMultiplier = 2; // optional multiplier to enable larger shapes than screen size;
float screenAspect;
float maxEllipseAspect = 2;
int blackingScale = 10;

int maxSegs = 127;

//color stuff
int colPalleteSize = 128;


color[] colPallete = new color[colPalleteSize];


void setup() {
  
  // processing-specific setup
  if (useOpenGL) {
    size(x_size, y_size, OPENGL);
    //hint(DISABLE_OPENGL_2X_SMOOTH);
  }
  else {
    size(x_size,y_size);
  }

  background(0); //black
  //smooth(); // anti-aliasing is SLOW
  
  ellipseMode(RADIUS);
  
  strokeCap(SQUARE);
  
  frameRate(30);
  frameNumber = 0;
  
  colorMode(HSB);
  
  // geometry
  screenAspect = float(width)/float(height);
  
  maxRadius = min(width, height)/2;
  
  x_center = width/2;
  y_center = height/2;
  
  

  //get an instance of MidiIO
  midiIO = MidiIO.getInstance(this);
  println("printPorts of midiIO");

  //print a list of all available devices
  midiIO.printDevices();
  
  // open midi outputs
  if (useMidi) {
    for (int i=0; i<nMidiOut; i++) {
      midiOuts[i] = midiIO.getMidiOut(i,APCDeviceNum); // so stupid that the syntax is backwards for opening inputs and outputs...
    } 
  }

  // open midi channels for each beam and fill the array of beams; for now all tunnels.
  for(int i = 0; i < nBeams; i++) {
    
    // open midi input for this beam
    if (useMidi) {
      midiIO.openInput(APCDeviceNum,i);
    
    }
    
    mixer.putBeamInLayer(i, new Tunnel());
    
    // can change defaults as the list is propagated here:
    if ( !useMidi) {
      mixer.setLevel(i,255);
      
      Tunnel thisTunnel = (Tunnel) mixer.getBeamFromLayer(i);
      
      
      //thisTunnel.rotSpeedI = 72;
      thisTunnel.ellipseAspectI = 64;
      thisTunnel.colWidthI = 32;
      thisTunnel.colSpreadI = 127;
      thisTunnel.colSatI = 32;
      
      thisTunnel.thicknessI = 40;
      thisTunnel.radiusI = 64-i*4;
      //thisTunnel.radiusI = 50;
      thisTunnel.rotSpeedI = (i-4)*2+64;
      thisTunnel.ellipseAspectI = 64;
      
      thisTunnel.blackingI = 20;
      
      // radius
      Animation anim0 = thisTunnel.getAnimation(0);
      anim0.speedI = 66;
      anim0.weightI = 40;
      anim0.typeI = 108;
      anim0.targetI = 0;
      anim0.updateParams();
      
      // x offset
      Animation anim1 = thisTunnel.getAnimation(1);
      anim1.speedI = 70;
      anim1.weightI = 64;
      anim1.typeI = 0;
      anim1.targetI = 64;
      anim1.updateParams();
      
      // thickness
      Animation anim2 = thisTunnel.getAnimation(2);
      anim2.speedI = 30;
      anim2.weightI = 64;
      anim2.typeI = 24;
      anim2.targetI = 32;
      anim2.updateParams();
      
      Animation anim3 = thisTunnel.getAnimation(3);
      anim3.speedI = 68;
      anim3.weightI = 32;
      anim3.typeI = 0;
      anim3.targetI = 96;
      anim3.updateParams();
      
      
      thisTunnel.updateParams();
    }
  }
  
  
}



// method called whenever processing draws a frame, basically the event loop
void draw() {
  
  // black out everything to remove leftover pixels
  background(0);
  
  mixer.drawLayers();
  
  /*
  // deep copy testing
  if (frameNumber % 1 == 0) {
    Tunnel toCopy = (Tunnel) theBeams.get(0);
    Tunnel theCopy = toCopy.copy();
    theBeams.set(0, theCopy);
  }
  */
  
  println(frameRate);
}



void controllerIn(Controller controller, int device, int channel) {
  
  int num = controller.getNumber();
  int val = controller.getValue();
  
  boolean channelChange = false;
  boolean isCh0Only = isControlCh0Only(num);
  
  // if the control didn't come from an APC channel 0 only control and we seem to have switched channels
  if ( !isCh0Only  && (channel != lastChannel) ) {
    lastChannel = channel;
    channelChange = true;
  }
  
  // if the control came from a top knob, interpret correctly
  if ( isCh0Only ) {
    channel = lastChannel;
  }
  
  midiInputHandler(channel, channelChange, false, num, val);
  
  if (midiDebug) {
    println("controller in");
    print("channel  = ");
    println(channel);
    print("number   = ");
    println(num);
    print("value    = ");
    println(val);
  }
}

// list of controls that only come from midi channel 0
boolean isControlCh0Only(int num) {
  if ( (num > 46 && num < 56) || (14 == num) || (15 == num) )
    return true;
  else return false;
}



void noteOn(Note note, int device, int channel) {

  int num = note.getPitch();
  
  boolean channelChange = false;
  boolean isCh0Only = isNoteCh0Only(num);
  
  // if the note didn't come from a ch0 only button and we seem to have switched channels
  if ( !isCh0Only && (channel != lastChannel) ) {
    lastChannel = channel;
    channelChange = true;
  }
  
  // if the note came from a ch0 only button, interpret correctly
  if ( isCh0Only ) {
    channel = lastChannel;
  }
  
  if (7 == num || (num >= 0x30 && num <= 0x37) ) {
    midiInputHandler(channel, channelChange, false, num, 0);
  }
  else {
    midiInputHandler(channel, channelChange, true, num, 0);
  }
  

  if (midiDebug) {
    println("note on");
    print("channel  = ");
    println(channel);
    print("pitch    = ");
    println(num);
  }
}



boolean isNoteCh0Only(int num) {
  if ( (num >= 0x50 && num <= 0x65) || (num >= 0x30 && num <= 0x37) ) // thanks APC40 programmers for this simple range!  hacked in range of top knobs.
    return true;
  else return false;
}

// method called once the CC and noteOn methods have parsed and formatted data.
void midiInputHandler(int layerNum, boolean chanChange, boolean isNote, int num, int val) {
    // ensure we don't retrieve null beams
  if (layerNum < nBeams) {
    
    // get the appropriate beam
    Beam thisBeam = mixer.getBeamFromLayer(layerNum);

    thisBeam.setMIDIParam(isNote, num, val);
  
    // update knob state if we've changed channel
    if (chanChange) {
      updateTopKnobState(thisBeam);
      setBottomLEDRings(lastChannel, thisBeam);
      setTopLEDRings(thisBeam);
    }

    // call the update method
    thisBeam.updateParams();
    
  }
}

// method to update the state of the top control knobs when we change channels
void updateTopKnobState(Beam theBeam) {
  
  String beamType = theBeam.type;
  
  // for tunnel type
  if(beamType.equals("tunnel")) {
    Tunnel theTunnel = (Tunnel) theBeam;
    
    // update the top knobs
    sendCC(0, 52, theTunnel.segsI);
    sendCC(0, 53, theTunnel.blackingI);
    
    Animation thisAnim = theTunnel.getCurrentAnimation();
    
    sendCC(0, 48, thisAnim.typeI);
    sendCC(0, 49, thisAnim.weightI);
    sendCC(0, 50, thisAnim.speedI);
    sendCC(0, 51, thisAnim.targetI);
    
  }
  
}

// method to set the bottom LED ring values
void setBottomLEDRings(int channel, Beam thisBeam) {
  String beamType = thisBeam.type;
  if (beamType.equals("tunnel")) {
    sendCC(channel, 0x18, 1);
    sendCC(channel, 0x19, 1);
    sendCC(channel, 0x1A, 2);
    sendCC(channel, 0x1B, 2);
  
    sendCC(channel, 0x1C, 3);
    sendCC(channel, 0x1D, 2);
    sendCC(channel, 0x1E, 2);
    sendCC(channel, 0x1F, 1);
  }
}

// set the top LED ring values
void setTopLEDRings(Beam thisBeam) {
  
  String beamType = thisBeam.type;
  if (beamType.equals("tunnel")) {
  
    sendCC(0, 0x38, 1);
    sendCC(0, 0x39, 2);
    sendCC(0, 0x3A, 3);
    sendCC(0, 0x3B, 1);
    
    sendCC(0, 0x3C, 2);
    sendCC(0, 0x3D, 1);
  }
}

// method to unwrap angles
float unwrap(float theAngle) {
  while (PI < theAngle) {
    theAngle = theAngle - TWO_PI;
  }
  while (PI < -1*theAngle) {
    theAngle = theAngle + TWO_PI;
  }
  
  return theAngle;
}


// wrapper method for sending midi control changes
void sendCC(int channel, int number, int val) {
  if (channel < nMidiOut) {
    midiOuts[channel].sendController(new Controller(number, val)); 
  }
}

// wrapper method for sending midi notes, because we don't care about most parameters
void sendNote(int channel, int number) {
  if (channel < nMidiOut) {
    midiOuts[channel].sendNote(new Note(number, 127, 20));
  } 
}


// ----------------------------------------------
// as of yet unused midi methods

void noteOff(Note note, int device, int channel) {
  int pit = note.getPitch();

  // println("note off");
  // print("pitch    = ");
  // println(pit);
}

void programChange(ProgramChange programChange, int device, int channel) {
  int num = programChange.getNumber();

  println("program change");
  print("number   = ");
  println(num);
}

