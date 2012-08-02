
// class that holds a collection of beams in layers, and understands how they are mixed.
class Mixer implements Serializable {
  
  private int nLayers;
  private Beam[] theLayers;
  private int[] levels;
  private boolean[] bump;
  int currentLayer;
  
  // generic constructor
  Mixer() {
    
    nLayers = 1;
    theLayers = new Beam[] {new Beam()};
    levels = new int[] {0};
    bump = new boolean[] {false};
    
  }
  
  // simple constructor for all defaults
  Mixer(int nLayers) {
  
    this.nLayers = nLayers;
    theLayers = new Beam[nLayers];
    levels = new int[nLayers];
    bump = new boolean[nLayers];
    
    for (int i = 0; i < nLayers; i++) {
      theLayers[i] = new Beam();
      levels[i] = 0;
      bump[i] = false;
    }
   
  }
  
  // method to put a beam in a layer
  void putBeamInLayer(int layer, Beam theBeam) {
    theLayers[layer] = theBeam;
  }
  
  // method to get a beam from a layer
  Beam getBeamFromLayer(int layer) {
    return theLayers[layer];
  }
  
  // method to get the current beam
  Beam getCurrentBeam() {
    return theLayers[currentLayer]; 
  }
  
  // method to set the current beam
  void setCurrentBeam(Beam theBeam) {
    putBeamInLayer(currentLayer, theBeam);
  }
  
  void setLevel(int layer, int level) {
    levels[layer] = level; 
  }
  
  void bumpOn(int layer) {
    bump[layer] = true;
  }
  
  void bumpOff(int layer) {
    bump[layer] = false;
  }
  
  // returns the number of layers
  int nLayers() {
    return nLayers;
  }
  
  // method to draw all the layers
  void drawLayers() {
    Beam drawMe;
  
    // loop over the beams and draw them.
    for(int i=0; i<nLayers; i++) {
      
      // don't draw beams that are all the way off
      if (levels[i] > 0 || bump[i]) {
        drawMe = getBeamFromLayer(i);
        if (bump[i]) {
          drawMe.display(255);
        }
        else {
          drawMe.display(levels[i]);
        }
      }
      
    }
  }
  
  // method to copy the entire current look
  BeamVault getCopyOfCurrentLook() {
    return new BeamVault( theLayers ); 
  }
  
  // method to copy a look into the mixer
  void setLook(BeamVault newLook) {
    
    int numElemNew = newLook.size();
    
    for (int i=0; i<nLayers; i++) {
      
      if (i < numElemNew) {
        theLayers[i] = newLook.retrieveCopy(i);
      }
      
      else {
        theLayers[i] = new Beam();
      }
    }
    
  }
  
  
} // end of Mixer class
