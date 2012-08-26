
// a look is a "beam" that is actually a composite of several beams.
class Look extends Beam {
  
  Beam[] theLayers;
  int[] levels;
  boolean[] mask;

  // default constructor
  Look() {
    theLayers = new Beam[] {new Beam()};
    levels = new int[] {0};
    mask = new boolean[] {false};
    type = "look";
  }
  
  // constructor from the contents of a mixer; note that this is a shallow copy of whatever you give it.  be careful!
  Look(Beam[] theLayers, int[] levels, boolean[] mask) {
    
    this.theLayers = theLayers;
    this.levels = levels;
    this.mask = mask;
    type = "look";
    
  }
  
  // deep copy constructor
  protected Look(Look original) {
    super(original);
    type = "look";
    
    int nBeams = original.theLayers.length;
    
    theLayers = new Beam[nBeams];
    
    Beam toCopy;
    for (int i=0; i < nBeams; i++) {
      toCopy = original.theLayers[i];
      theLayers[i] = toCopy.copy();
    }
    
    levels = Arrays.copyOf(original.levels, nBeams);
    mask = Arrays.copyOf(original.mask, nBeams);
    
  }
  
  // deep copy method
  Look copy() {
    return new Look(this);
  }
  
  // draw all the beams in a look
  void display(int level, boolean drawAsMask) {
    
    Beam drawMe;
    int scaledLevel;
    // loop over the list of beams
    for(int i = 0; i < theLayers.length; i++) {
      
      if (levels[i] != 0) {
      
        // scale the draw level based on the input to this method
        scaledLevel = (level * levels[i]) / 255;
        println("scaled level " +  scaledLevel);
        drawMe = theLayers[i];
        
        
        
        // draw as a mask if the beam is saved as a mask or this is called as a mask
        drawMe.display(scaledLevel, drawAsMask | mask[i]);
      }
    }
    
  }
}

