
// class that holds a collection of beams in layers, and understands how they are mixed.
class Mixer {
  
  private int nLayers;
  private ArrayList theLayers;
  private int[] levels;
  
  // generic constructor
  Mixer() {
    
    nLayers = 1;
    theLayers = new ArrayList(nLayers);
    levels = new int[] {0};
    
  }
  
  // simple constructor for all defaults
  Mixer(int nLayers) {
  
    this.nLayers = nLayers;
    theLayers = new ArrayList(nLayers);
    levels = new int[nLayers];
    
    for (int i = 0; i < nLayers; i++) {
      theLayers.add(null);
      levels[i] = 0;
    }
   
  }
  
  // method to put a beam in a layer
  void putBeamInLayer(int layer, Beam theBeam) {
    theLayers.set(layer, theBeam);
  }
  
  // method to get a beam from a layer
  Beam getBeamFromLayer(int layer) {
    return (Beam) theLayers.get(layer);
  }
  
  void setLevel(int layer, int level) {
    levels[layer] = level; 
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
    
      drawMe = getBeamFromLayer(i);
      drawMe.display(levels[i]);
      
    }
  }
  
  
} // end of Mixer class
