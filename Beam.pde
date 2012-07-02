// generic Beam class
class Beam {
  
  String type;
  int levelI, level;
  
  Beam() {
    type = "generic";
    levelI = 0;
    level = 0;
  }
  
  // constructor used for copying
  protected Beam(Beam original) {
    type = original.type;
    levelI = original.levelI;
    level = original.level;
  }
  
  // copy method
  Beam copy() {
    return new Beam(this);
  }
  
  void updateParams() {
  }
  
  void display() {
  }
  
  Animation getAnimation(int theAnim) {
    return null; 
  }
  
  void setMIDIParam(boolean isNote, int num, int val) {
    
  }
} // end of Beam class
