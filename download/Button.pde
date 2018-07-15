class Button {
  float x, y, w, h;
  String buttonText;
  color fillLow, fillHigh;
  boolean useImage;
  PImage buttonImg;


  Button(float _x, float _y, float _w, float _h, String _buttonText, boolean _useImage, String _imgPath) {
    x = _x;
    y = _y;
    w = _w;
    h = _h;
    buttonText = _buttonText;
    fillHigh = color(124, 124, 124);
    fillLow  = color(200, 200, 200);
    useImage = _useImage;
    if(useImage){
      buttonImg = loadImage(_imgPath);
    }
  }

  void draw() {
    
    if(useImage){
     drawImageButton();
    }else{
    drawTextButton();
    }
    
    
  }
  
  void drawTextButton(){
    stroke(0);
    if (mouseOverButton()) {
      fill(fillHigh);
    } else {
      fill(fillLow);
    }

    rect(x, y, w, h);

    fill(0);
    noStroke();
    textSize(12);
    textAlign(CENTER, CENTER);
    text(buttonText, x, y, w, h);
  }
  
  void drawImageButton(){
    image(buttonImg, x, y);
  }

  boolean mouseOverButton() {
    if (
      mouseX > x && 
      mouseX < x+w &&
      mouseY > y &&
      mouseY < y+h
      ) {
      return true;
    } else {
      return false;
    }
  }
}
