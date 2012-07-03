// class for storing a deep copy of an animation to allow copy/paste
class AnimationClipboard {
  
  Animation theAnim;
  boolean hasData;
  
  AnimationClipboard() {
    theAnim = null;
    hasData = false;
  }
  
  void copy(Animation toCopy) {
    theAnim = toCopy.copy();
    hasData = true;
  }
  
  Animation paste() {
    return theAnim.copy();
  }
  
}
