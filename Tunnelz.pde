import processing.opengl.*;

// graphics options
boolean useOpenGL = false;

import themidibus.*;

MidiBus[] midiBusses;

boolean useMidi = true;
boolean midiDebug = true;

boolean useAPC = true;
int APCDeviceNumIn = 1;
int APCDeviceNumOut = 1;

boolean useiPad = false;
int iPadDeviceNumIn = 2;
int iPadDeviceNumOut = 2;

int nMidiDev = 2;




// the beam mixer
int nBeams = 8;
Mixer mixer = new Mixer(nBeams);


// beam state storage
BeamMatrixMinder beamMatrix;

// file loading and saving
boolean loadFile = false;
String fileToLoad = "";
String filePrefix = "/Users/Chris/Beam Effects Project/Program State/tunnelz_state_";

// Animation clipboard
AnimationClipboard animClipboard = new AnimationClipboard();


int frameNumber;

// screem geometry
//int x_size = 1920;
//int y_size = 1080;
//int x_size = 1280;
//int y_size = 720;

int x_size = 1280;
int y_size = 720;

int x_center, y_center;

// various constraints and multipliers
int maxRadius; // largest radius given screen constraints
float maxRadiusMultiplier = 2; // optional multiplier to enable larger shapes than screen size;
float screenAspect;
float maxEllipseAspect = 2;

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
  
  // turn that annoying extra beam off
  noCursor();
  
  // open midi outputs
  if (useMidi) {
    // print all available midi devices
    
    midiBusses = new MidiBus[nMidiDev];
    
    MidiBus.list();
    
    if (useAPC) {
      println("looking for an APC40 at input " + APCDeviceNumIn + ", output " + APCDeviceNumOut);
      midiBusses[0] = new MidiBus(this, APCDeviceNumIn, APCDeviceNumOut);
    }
    
    if (useiPad) {
      println("looking for an iPad at input " + iPadDeviceNumIn + ", output " + iPadDeviceNumOut);
      midiBusses[1] = new MidiBus(this, iPadDeviceNumIn, iPadDeviceNumOut);
    }
    
  }
  
  beamMatrix = new BeamMatrixMinder();

  // open midi channels for each mixer channel and fill the mixer; for now all tunnels.
  for(int i = 0; i < mixer.nLayers(); i++) {
    
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
      
      thisTunnel.updateParams();
    }
  }
  
  // pretend we just pushed track select 1
  if (useMidi) {
    midiInputHandler(0, true, true, 0x33, 127);
  }
  
  // save a copy of the default tunnel
  beamMatrix.putBeam(4, 7, new Tunnel() );
  
}



// method called whenever processing draws a frame, basically the event loop
void draw() {
  
  // black out everything to remove leftover pixels
  background(0);
  
  mixer.drawLayers();
  
  if (frameNumber % 240 == 0) {
    println(frameRate);
  }
  
  frameNumber++;
}



void controllerChange(int channel, int number, int value) {

  if ( !keepControlChannelData(number) ) {
    channel = mixer.currentLayer;
  }
  
  if (midiDebug) {
    println("controller in");
    print("channel  = ");
    println(channel);
    print("number   = ");
    println(number);
    print("value    = ");
    println(value);
  }
  
  midiInputHandler(channel, false, false, number, value);
}

boolean keepControlChannelData(int num) {
  if (7 == num) return true;
  else return false;
}

void noteOn(int channel, int pitch, int velocity) {
  
  boolean channelChange = false;
  
  // if this button is always channel 0
  if ( !keepNoteChannelData(pitch) ) {
    
    channel = mixer.currentLayer;
  }
  
  // if we pushed a track select button, not the master
  else if ( 0x33 == pitch && channel < 8 ) {
    mixer.currentLayer = channel;
    channelChange = true;
  }
  
  if (midiDebug) {
    println("note on");
    print("channel  = ");
    println(channel);
    print("pitch    = ");
    println(pitch);
    print("velocity = ");
    println(velocity);
  }
  
  midiInputHandler(channel, channelChange, true, pitch, 127);

}


void noteOff(int channel, int pitch, int velocity) {
  
  // for now we're only using note off for bump buttons
  if (0x32 == pitch) {
    midiInputHandler(channel, false, true, pitch, 0);
  }
  
  if (midiDebug) {
    println("note off");
    print("channel  = ");
    println(channel);
    print("pitch    = ");
    println(pitch);
    print("velocity = ");
    println(velocity);
  }
}

// does this note come from a button whose channel data we care about?
boolean keepNoteChannelData(int num) {
  if (num >= 0x30 && num <= 0x39) {
    return true;
  }
  else return false;
}


// method called once the CC and noteOn methods have parsed and formatted data.
void midiInputHandler(int channel, boolean chanChange, boolean isNote, int num, int val) {
    // ensure we don't retrieve null beams, make an exception for master channel
  if (channel < mixer.nLayers() ) {
    
    // if the control is an upfader
    if (0x07 == num && !isNote) {
      // special cases to allow scaling to 255
      if (0 == val) {
        mixer.setLevel(channel, 0);
      }
      else {
        mixer.setLevel(channel, 2*val + 1);
      }
    }
    
    // if a bump button
    else if (0x32 == num && isNote) {
      if (127 == val) {
        mixer.bumpOn(channel);
        setBumpButtonLED(channel, true);
      }
      else {
        mixer.bumpOff(channel);
        setBumpButtonLED(channel, false);
      }
    }
    
    // if a mask button
    else if (0x31 == num && isNote) {
      boolean newState = mixer.toggleMaskState(channel);
      setMaskButtonLED(channel, newState);
    }
    
    // if not a mixer parameter
    else {
    
      // get the appropriate beam
      Beam thisBeam = mixer.getBeamFromLayer(mixer.currentLayer);
      
      // if nudge+: animation paste
      if (isNote && 0x64 == num) {
        // ensure we don't paste null
        if (animClipboard.hasData) {
          thisBeam.replaceCurrentAnimation( animClipboard.paste() );
          thisBeam.updateParams();
          updateKnobState(mixer.currentLayer, thisBeam);
        }
      }
      
      // if nudge-: animation copy
      else if (isNote && 0x65 == num) {
        animClipboard.copy( thisBeam.getCurrentAnimation() );
      }
      
      // beam save mode toggle
      else if (isNote && 0x52 == num) {
        
        // turn off look save mode
        beamMatrix.waitingForLookSave = false;
        setLookSaveLED(0);
        
        // turn off delete mode
        beamMatrix.waitingForDelete = false;
        setDeleteLED(0);
        
        // if we were already waiting for a beam save
        if (beamMatrix.waitingForBeamSave) {
          
          beamMatrix.waitingForBeamSave = false;
          setBeamSaveLED(0);
          
          println("beam save off");
          
        }
        
        // we're activating beam save mode
        else {
          // turn on beam save mode
          beamMatrix.waitingForBeamSave = true;
          setBeamSaveLED(2);
          
          println("beam save on");
        }
        
      } // end beam save mode toggle
      
      // look save mode toggle
      else if (isNote && 0x53 == num) {
        
        // turn off beam save mode
        beamMatrix.waitingForBeamSave = false;
        setBeamSaveLED(0);
        
        // turn off delete mode
        beamMatrix.waitingForDelete = false;
        setDeleteLED(0);
        
        // if we were already waiting for a look save
        if (beamMatrix.waitingForLookSave) {
          
          beamMatrix.waitingForLookSave = false;
          setLookSaveLED(0);
          
          println("look save off");
          
        }
        
        // we're activating look save mode
        else {
          beamMatrix.waitingForLookSave = true;
          setLookSaveLED(2);
          
          println("look save on");
        }
      } // end look save mode toggle
      
      // delete saved element mode toggle
      else if (isNote && 0x54 == num) {
        
        // these buttons are radio
        beamMatrix.waitingForBeamSave = false;
        setBeamSaveLED(0);
        beamMatrix.waitingForLookSave = false;
        setLookSaveLED(0);
        
        if (beamMatrix.waitingForDelete) {
          beamMatrix.waitingForDelete = false;
          setDeleteLED(0);
        }

        // we're activating delete mode
        else {
          beamMatrix.waitingForDelete = true;
          setDeleteLED(2);
        }
      } // end delete element mode toggle
      
      // if we just pushed a beam save matrix button
      else if ( isNote && (num >= 0x35) && (num <= 0x39) && (channel < 8) ) {
        
        // if we're in save mode
        if (beamMatrix.waitingForBeamSave) {
          beamMatrix.putBeam(num - 0x35, channel, mixer.getCurrentBeam() );
          beamMatrix.waitingForBeamSave = false;
          setBeamSaveLED(0);
          println("saving a beam");
        }
        else if (beamMatrix.waitingForLookSave) {
          beamMatrix.putLook(num - 0x35, channel, mixer.getCopyOfCurrentLook() );
          beamMatrix.waitingForLookSave = false;
          setLookSaveLED(0);
          println("saving a look");
        }
        // if we're in delete mode
        else if (beamMatrix.waitingForDelete) {
          beamMatrix.clearElement(num - 0x35, channel);
          beamMatrix.waitingForDelete = false;
          setDeleteLED(0);
          println("deleted an element");
        }
        
        // otherwise we're getting a thing from the minder
        else {
          
          int row = num - 0x35;
          
          if ( beamMatrix.elementHasData(row, channel) ) {
          
            BeamVault theSavedThing = beamMatrix.getElement(row, channel);
          
            boolean isLook = beamMatrix.elementIsLook(row, channel);
            
            boolean lookEdit = false;
          
            if ( isLook &&  lookEdit ) {
              mixer.setLook(theSavedThing);
              println("setting a look.");
            }
            else {
              mixer.setCurrentBeam( theSavedThing.retrieveCopy(0) );
              println("setting a beam");
            }
            
            Beam currentBeam = mixer.getCurrentBeam();
            updateKnobState( mixer.currentLayer, currentBeam );
            setAnimSelectLED( currentBeam.currAnim );
            
            if (isLook && !lookEdit) {
              setIsLookLED(channel, true);
            }
            else {
              setIsLookLED(channel, false);
            }
          }
          
        }
        
      }
      
      // if beam-specific parameter:
      else {
      
        thisBeam.setMIDIParam(isNote, num, val);
      
        // update knob state if we've changed channel
        if (chanChange) {
          setTrackSelectLEDRadio(mixer.currentLayer);
          setBottomLEDRings(mixer.currentLayer, thisBeam);
          setTopLEDRings(thisBeam);
          setAnimSelectLED(thisBeam.currAnim);
        }
    
        // call the update method
        thisBeam.updateParams();
        updateKnobState(mixer.currentLayer, thisBeam);
      }
    } 
  }
}


// wrapper method for sending midi control changes
void sendCC(int channel, int number, int val) {
  if (useMidi) {
    if (useAPC) {
      midiBusses[0].sendControllerChange(channel, number, val);
    }
    if (useiPad) {
      midiBusses[1].sendControllerChange(channel, number, val);
    }
  }
}

// wrapper method for sending midi notes, because we don't care about most parameters
void sendNote(int channel, int number, int velocity) {
  if (useMidi) {
    if (useAPC) {
      midiBusses[0].sendNoteOn(channel, number, velocity);
    }
    if (useiPad) {
      midiBusses[1].sendNoteOn(channel, number, velocity);
    }
  }
}

