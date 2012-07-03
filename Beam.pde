// generic Beam class
class Beam {
  
  String type;
  
  Beam() {
    type = "generic";
  }
  
  // constructor used for copying
  protected Beam(Beam original) {
    type = original.type;
  }
  
  // copy method
  Beam copy() {
    return new Beam(this);
  }
  
  void updateParams() {
  }
  
  void display(int level) {
  }
  
  Animation getAnimation(int theAnim) {
    return null; 
  }
  
  void setMIDIParam(boolean isNote, int num, int val) {
    
  }
} // end of Beam class
