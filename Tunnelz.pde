import processing.opengl.*;

// graphics options
boolean useOpenGL = false;

// midi stuff
/*
import promidi.*;

MidiIO midiIO;
int nMidiOut = 9;
MidiOut[] midiOuts = new MidiOut[nMidiOut];
*/

import themidibus.*;

MidiBus midiBus;

int APCDeviceNumIn = 1;
int APCDeviceNumOut = 1;

boolean useMidi = true;
boolean midiDebug = false;


// the beam mixer
int nBeams = 8;
Mixer mixer = new Mixer(nBeams);


// beam state storage
BeamMatrixMinder beamMatrix;

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
  
  

  
  // open midi outputs
  if (useMidi) {
    // print all available midi devices
    MidiBus.list();
    midiBus = new MidiBus(this, APCDeviceNumIn, APCDeviceNumOut);
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
  
  // pretend we just pushed track select 1
  midiInputHandler(0, true, true, 0x33, 127);
  
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
  
  midiInputHandler(channel, channelChange, true, pitch, 0);

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
    // ensure we don't retrieve null beams
  if (channel < mixer.nLayers() ) {
    
    // if the control is an upfader
    if (0x07 == num) {
      // special cases to allow scaling to 255
      if (0 == val) {
        mixer.setLevel(channel, 0);
      }
      else {
        mixer.setLevel(channel, 2*val + 1);
      }
    }
    
    // if not an upfader
    else {
    
      // get the appropriate beam
      Beam thisBeam = mixer.getBeamFromLayer(mixer.currentLayer);
      
      // if nudge+: animation paste
      if (0x64 == num) {
        // ensure we don't paste null
        if (animClipboard.hasData) {
          thisBeam.replaceCurrentAnimation( animClipboard.paste() );
          thisBeam.updateParams();
          updateKnobState(mixer.currentLayer, thisBeam);
        }
      }
      
      // if nudge-: animation copy
      else if (0x65 == num) {
        animClipboard.copy( thisBeam.getCurrentAnimation() );
      }
      
      // beam save mode toggle
      else if (0x52 == num) {
        
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
      else if (0x53 == num) {
        
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
      else if (0x54 == num) {
        
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
          BeamVault theSavedThing = beamMatrix.getElement(num - 0x35, channel);
          
          // we're using null for empty elements
          if (theSavedThing != null) {
          
            if ( beamMatrix.elementIsLook(num - 0x35, channel) ) {
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
    midiBus.sendControllerChange(channel, number, val);
}

// wrapper method for sending midi notes, because we don't care about most parameters
void sendNote(int channel, int number, int velocity) {
    midiBus.sendNoteOn(channel, number, velocity);
}


// ----------------------------------------------
// as of yet unused midi methods

void noteOff(int channel, int pitch, int velocity) {
  
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
