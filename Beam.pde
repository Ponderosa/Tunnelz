// generic Beam class
class Beam {
  
  String type;
  int levelI, level;
  
  Beam() {
    type = "generic";
    levelI = 0;
    level = 0;
  }
  
  /*
  Beam clone() throws CloneNotSupportedException {
    Beam theCopy;
    try {
    theCopy =  (Beam) super.clone();
    }
    catch (CloneNotSupportedException e) {
      theCopy = null; // never executes.
    }
    
    return theCopy;
  }
  */
  
  void updateBeam() {
  }
  
  void display() {
  }
  
  Animation getAnimation(int theAnim) {
    return null; 
  }
  
  void setMIDIParam(boolean isNote, int num, int val) {
    
  }
} // end of Beam class
