import processing.opengl.*;

// graphics options
boolean useOpenGL = false;

// midi stuff
import promidi.*;

MidiIO midiIO;
int nMidiOut = 9;
MidiOut[] midiOuts = new MidiOut[nMidiOut];

int APCDeviceNum = 0;

boolean useMidi = false;
boolean midiDebug = true;


// the beam mixer
int nBeams = 8;
Mixer mixer = new Mixer(nBeams);


// beam state storage
BeamVault buttonsVault = new BeamVault(40);

// Animation clipboard
AnimationClipboard animClipboard = new AnimationClipboard();


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

  // open midi channels for each mixer channel and fill the mixer; for now all tunnels.
  for(int i = 0; i < mixer.nLayers(); i++) {
    
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
  
  // println(frameRate);
}



void controllerIn(Controller controller, int device, int channel) {
  
  int num = controller.getNumber();
  int val = controller.getValue();
  
  boolean channelChange = false;
  boolean isCh0Only = isControlCh0Only(num);
  
  // if the control didn't come from an APC channel 0 only control and we seem to have switched channels
  if ( !isCh0Only  && (channel != mixer.currentLayer) ) {
    mixer.currentLayer = channel;
    channelChange = true;
  }
  
  // if the control came from a top knob, interpret correctly
  if ( isCh0Only ) {
    channel = mixer.currentLayer;
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

  // cases: note came from a button: has velocity = 127
  // note came from a stupid CC as note bug, has velocity = 0
  
  int num = note.getPitch();
  int vel = note.getVelocity();
  
  boolean channelChange = false;
  
  boolean isCh0Only;
  
  // if the note came from a button
  if ( vel > 0 ) {
    
    isCh0Only = isNoteCh0Only(num);
    
    // if the note didn't come from a ch0 only button and we seem to have switched channels
    if ( !isCh0Only && (channel != mixer.currentLayer) ) {
      mixer.currentLayer = channel;
      channelChange = true;
    }
  
    // if the note came from a ch0 only button, interpret correctly
    if ( isCh0Only ) {
      channel = mixer.currentLayer;
    }
    
    midiInputHandler(channel, channelChange, true, num, 0);
  }
  
  // if velocity is 0, ie, CC as note bug
  else {
    isCh0Only = ( num >= 0x30 && num <= 0x37 );
    
    // if the note didn't come from a ch0 only button and we seem to have switched channels
    if ( !isCh0Only && (channel != mixer.currentLayer) ) {
      mixer.currentLayer = channel;
      channelChange = true;
    }
  
    // if the note came from a ch0 only button, interpret correctly
    if ( isCh0Only ) {
      channel = mixer.currentLayer;
    }
    
    midiInputHandler(channel, channelChange, false, num, 0);
  }
  

  if (midiDebug) {
    println("note on");
    print("channel  = ");
    println(channel);
    print("pitch    = ");
    println(num);
    print("velocity = ");
    println(vel);
  }
}



boolean isNoteCh0Only(int num) {
  if ( num >= 0x50 && num <= 0x65 ) // thanks APC40 programmers for this simple range!
    return true;
  else return false;
}

// method called once the CC and noteOn methods have parsed and formatted data.
void midiInputHandler(int layerNum, boolean chanChange, boolean isNote, int num, int val) {
    // ensure we don't retrieve null beams
  if (layerNum < mixer.nLayers() ) {
    
    // if the control is an upfader
    if (0x07 == num) {
      // special cases to allow scaling to 255
      if (0 == val) {
        mixer.setLevel(layerNum, 0);
      }
      else {
        mixer.setLevel(layerNum, 2*val + 1);
      }
    }
    
    // if not an upfader
    else {
    
      // get the appropriate beam
      Beam thisBeam = mixer.getBeamFromLayer(layerNum);
      
      // if nudge+: animation paste
      if (0x64 == num) {
        // ensure we don't paste null
        if (animClipboard.hasData) {
          thisBeam.replaceCurrentAnimation( animClipboard.paste() );
          thisBeam.updateParams();
          updateKnobState(thisBeam);
        }
      }
      
      // if nudge-: animation copy
      if (0x65 == num) {
        animClipboard.copy( thisBeam.getCurrentAnimation() );
      }
      
      // if beam-specific parameter:
      else {
      
        thisBeam.setMIDIParam(isNote, num, val);
      
        // update knob state if we've changed channel
        if (chanChange) {
          updateKnobState(thisBeam);
          setBottomLEDRings(mixer.currentLayer, thisBeam);
          setTopLEDRings(thisBeam);
          setAnimSelectLED(thisBeam.currAnim);
        }
    
        // call the update method
        thisBeam.updateParams();
      }
    } 
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
void sendNote(int channel, int number, int velocity) {
  if (channel < nMidiOut) {
    midiOuts[channel].sendNote(new Note(number, velocity, 100));
  } 
}


// ----------------------------------------------
// as of yet unused midi methods

void noteOff(Note note, int device, int channel) {
  int num = note.getPitch();
  int vel = note.getVelocity();

  
  if (midiDebug) {
    println("note off");
    print("channel  = ");
    println(channel);
    print("pitch    = ");
    println(num);
    print("velocity = ");
    println(vel);
  }
}


void programChange(ProgramChange programChange, int device, int channel) {
  int num = programChange.getNumber();

  println("program change");
  print("number   = ");
  println(num);
}

