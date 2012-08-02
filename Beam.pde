// generic Beam class
class Beam implements java.io.Serializable {
  
  String type;
  int currAnim = 0;
  
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
  
  void display(int level, boolean drawAsMask) {
  }
  
  Animation getAnimation(int theAnim) {
    return null; 
  }
  
  Animation getCurrentAnimation() {
    return null;
  }
  
  void replaceCurrentAnimation(Animation newAnim) {
  }
  
  void setMIDIParam(boolean isNote, int num, int val) {
    
  }
  
  int getMIDIParam(boolean isNote, int num) {
    return 0;
  }
  
  String toString() {
    return type;
  }
} // end of Beam class
