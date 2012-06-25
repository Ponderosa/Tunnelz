
// class that holds a collection of beams in layers, and understands how they are mixed.
class Mixer {
  
  int nBeams;
  ArrayList theBeams;
  int[] levels;
  
  // generic constructor
  Mixer() {
    
    nBeams = 1;
    theBeams = new ArrayList(nBeams);
    levels = new int[] {0};
    
  }
  
  // simple constructor for all defaults
  Mixer(int nBeams) {
  
    this.nBeams = nBeams;
    theBeams = new ArrayList(nBeams);
    
    for (int i = 0; i < nBeams; i++) {
      levels[i] = 0;
    }
   
  }
  
  // method to draw all the layers
  void drawLayers() {
    Beam drawMe;
  
    // loop over the beams and draw them.
    for(int i=0; i<nBeams; i++) {
    
      drawMe = (Beam) theBeams.get(i);
      drawMe.display();
      
    }
  }
  
  
} // end of Mixer class
