/***********************************************************************
 ShapeConverter
 Copyright (c) 2018 LIA
 www.liaworks.com
 ------------------------------------------------------------------------
 -> converts simple shapes drawn in Adobe Illustrator 
 (and saved as Illustrator 8 files) into human readable processing code.
 ------------------------------------------------------------------------
 Donation:
 If you like ShapeConverter so much that you feel a strong need 
 to buy me a cup of coffee (or tea) in return for using it, 
 you can donate via PayPal using my email address lia@liaworks.com
 or you can click the donate button in the running application
 to get a fancy interface. :)
 ------------------------------------------------------------------------
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 
 ***********************************************************************/


import java.awt.*;
import java.awt.event.*;
import java.awt.datatransfer.*;
import javax.swing.*;
import java.io.*;

boolean SHOW_CODE = false; // set this to true if you want to see some code on your screen
boolean SHOW_POINTS = false; // set this to true if you want to see the points that make up the shapes

PFont font;

String pathInput;
String pathOutput;
String errorOnImportMessage = "Invalid Adobe Illustrator 8(!) file, please try again";

String[] allImportedLines;
StringList selectedLines = new StringList();
StringList convertedLines = new StringList();

int startLineNum;
int endLineNum;

Button openFileButton;
Button saveTextButton;
Button copyTextToClipboardButton;
Button donateButton;

// --------------------------------------------------
void setup() {
  size(800, 600);
  background(255);
  font = loadFont("Monaco-12.vlw");
  textFont(font);

  pathInput = "PLEASE CLICK THE BUTTON ABOVE TO SELECT AN AI8 FILE";
  openFileButton = new Button(20, 20, 120, 60, "OPEN ADOBE ILLUSTRATOR 8 FILE", false, "");
  copyTextToClipboardButton = new Button(660, 20, 120, 60, "COPY TEXT TO CLIPBOARD", false, "");
  saveTextButton = new Button(520, 20, 120, 60, "SAVE TEXT", false, "");
  donateButton = new Button(706, 559, 74, 21, "", true, "donateButton.gif");

  clearListsAndIni();
}

void clearListsAndIni() {
  selectedLines.clear();
  convertedLines.clear();
  startLineNum = 0;
  endLineNum = 0;
}

// --------------------------------------------------
void draw() {

  background(255);

  openFileButton.draw();
  copyTextToClipboardButton.draw();
  saveTextButton.draw();
  donateButton.draw();

  drawpathInput();
  
  drawIllustratorShapeToScreen();

  if (SHOW_CODE) {
    drawSelectedLines();
    drawConvertedLines();
  }
}

// --------------------------------------------------
void mousePressed() {
  if (openFileButton.mouseOverButton()) {
    selectInput("Select a file to process:", "selectFileInput");
  }

  if (copyTextToClipboardButton.mouseOverButton()) {
    copyTextToClipboard();
  }

  if (saveTextButton.mouseOverButton()) {
    selectOutput("Select a file to write to:", "selectFileOutput");
  }

  if (donateButton.mouseOverButton()) {
    link("https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=lia%40liaworks%2ecom&lc=GB&item_name=LIA%20%2d%20Software%20Art&currency_code=EUR&bn=PP%2dDonationsBF%3abtn_donate_SM%2egif%3aNonHosted");
  }
}

// --------------------------------------------------
void drawpathInput() {
  if (pathInput.equals(errorOnImportMessage)) {
    fill(255, 0, 0);
  } else {
    fill(0);
  }

  noStroke();
  textAlign(LEFT, CENTER);
  textSize(12);
  text(pathInput, 20, 100);
}


// --------------------------------------------------
void drawSelectedLines() {
  textSize(12);
  fill(0);
  noStroke();
  textAlign(LEFT, TOP);
  int x = 20;
  int y = 140; // startpos ?
  int yInc = 20;
  text("IMPORTED AI8 DATA: ", x, y);
  y += yInc * 2;
  for (int i=0; i<selectedLines.size(); i++) {
    text(selectedLines.get(i), x, y);
    y += yInc;
  }
}

// --------------------------------------------------
void drawConvertedLines() {
  textSize(12);
  fill(0);
  noStroke();
  textAlign(LEFT, TOP);
  int x = 420;
  int y = 140; // startpos ?
  int yInc = 20;
  text("CONVERTED TEXT: ", x, y);
  y += yInc * 2;
  for (int i=0; i<convertedLines.size(); i++) {
    text(convertedLines.get(i), x, y);
    y += yInc;
  }
}

// --------------------------------------------------
String[] getPiecesOfPrevLine(int index) {
  String[] lastUsedPoint = new String[2];
  String[] piecesOfPrevLine = split(selectedLines.get(index), ' ');
  lastUsedPoint[0] = piecesOfPrevLine[piecesOfPrevLine.length-3];
  lastUsedPoint[1] = piecesOfPrevLine[piecesOfPrevLine.length-2];
  return lastUsedPoint;
}

// --------------------------------------------------
String getFlippedY(String inputString) {
  float stringAsFloat = float(inputString);

  if (stringAsFloat != 0.0) {
    stringAsFloat *= -1;
    return str(stringAsFloat);
  } else {
    return str(0);
  }
}

// --------------------------------------------------
void convertSelectedLines() {

  for (int i=0; i<selectedLines.size()-1; i++) {
    String[] pieces = split(selectedLines.get(i), ' ');
    String lastPiece = pieces[pieces.length-1];

    if ( lastPiece.equals("m") ) {
      convertedLines.append("beginShape();");
    } 

    if ( lastPiece.equals("l") || lastPiece.equals("L") ) {
      String x0 = pieces[0];
      String y0 = getFlippedY(pieces[1]);
      convertedLines.append("vertex(" + x0 + ", " + y0 + ");");
    } 

    if ( lastPiece.equals("v") || lastPiece.equals("V") ||
      lastPiece.equals("y") || lastPiece.equals("Y") ) {
      String x0 = getPiecesOfPrevLine(i-1)[0];
      String y0 = getFlippedY(getPiecesOfPrevLine(i-1)[1]);

      String x1 = pieces[0];
      String y1 = getFlippedY(pieces[1]);
      String x2 = pieces[2];
      String y2 = getFlippedY(pieces[3]);

      convertedLines.append("vertex(" + x0 + ", " + y0 + ");");
      convertedLines.append(
        "bezierVertex(" 
        + x0 + ", " + y0 + ", " 
        + x1 + ", " + y1 + ", " 
        + x2 + ", " + y2 + 
        ");");
    } 

    if ( lastPiece.equals("c") || lastPiece.equals("C") ) {

      String x0 = getPiecesOfPrevLine(i-1)[0];
      String y0 = getFlippedY( getPiecesOfPrevLine(i-1)[1] );
      
      String x1 = pieces[0];
      String y1 = getFlippedY( pieces[1] );
      String x2 = pieces[2];
      String y2 = getFlippedY( pieces[3] );
      String x3 = pieces[4];
      String y3 = getFlippedY( pieces[5] );

      convertedLines.append("vertex(" + x0 + ", " + y0 + ");");
      convertedLines.append(
        "bezierVertex(" 
        + x1 + ", " + y1 + ", " 
        + x2 + ", " + y2 + ", " 
        + x3 + ", " + y3 +
        ");");
    } 

    if ( 
      lastPiece.equals("N") ||
      lastPiece.equals("B") ||
      lastPiece.equals("S") ||
      lastPiece.equals("F")
      ) {
      convertedLines.append("endShape();");
    }

    if ( 
      lastPiece.equals("n") ||
      lastPiece.equals("b") ||
      lastPiece.equals("s") ||
      lastPiece.equals("f")
      ) {
      convertedLines.append("endShape(CLOSE);");
    }
  }
}

// --------------------------------------------------
void drawIllustratorShapeToScreen() {
  if (convertedLines.size()>0) {

    stroke(0, 80);
    float percentage = 0.25;
    line(width*percentage, height/2., width*(1-percentage), height/2.);
    line(width/2., height*percentage, width/2., height*(1-percentage));

    pushMatrix();
    translate(width/2., height/2.);

    for (int i=0; i<selectedLines.size(); i++) {
      String[] pieces = split(selectedLines.get(i), ' ');
      String lastPiece = pieces[pieces.length-1];

      if ( lastPiece.equals("m") ) {
        stroke(0);
        noFill();
        beginShape();
      } 

      if ( lastPiece.equals("l") || lastPiece.equals("L") ) {
        float x0 = float(pieces[0]); 
        float y0 = float(pieces[1]) * -1;

        vertex(x0, y0);
        if (SHOW_POINTS) {
          stroke(0, 255, 230);
          noFill();
          ellipse(x0, y0, 13, 13);
          stroke(0);
        }
      } 

      if ( lastPiece.equals("v") || lastPiece.equals("V") ||
        lastPiece.equals("y") || lastPiece.equals("Y") ) {

        float x0 = float(getPiecesOfPrevLine(i-1)[0]);
        float y0 = float(getPiecesOfPrevLine(i-1)[1]) * -1;

        float x1 = float(pieces[0]);
        float y1 = float(pieces[1]) * -1;
        float x2 = float(pieces[2]);
        float y2 = float(pieces[3]) * -1;


        vertex(x0, y0);
        bezierVertex(x0, y0, x1, y1, x2, y2);
        if (SHOW_POINTS) {
          stroke(255, 0, 0);
          ellipse(x0, y0, 5, 5);

          stroke(0, 255, 0);
          ellipse(x1, y1, 7, 7);

          stroke(0, 0, 255);
          ellipse(x2, y2, 9, 9);

          stroke(0);
        }
      } 

      if ( lastPiece.equals("c") || lastPiece.equals("C") ) {
        float x0 = float(getPiecesOfPrevLine(i-1)[0]);
        float y0 = float(getPiecesOfPrevLine(i-1)[1]) * -1;

        float x1 = float(pieces[0]);
        float y1 = float(pieces[1]) * -1;
        float x2 = float(pieces[2]);
        float y2 = float(pieces[3]) * -1;
        float x3 = float(pieces[4]);
        float y3 = float(pieces[5]) * -1;

        vertex(x0, y0);
        bezierVertex(x1, y1, x2, y2, x3, y3);
        if (SHOW_POINTS) {
          stroke(255, 0, 0);
          ellipse(x0, y0, 5, 5);

          stroke(0, 255, 0);
          ellipse(x1, y1, 7, 7);

          stroke(0, 0, 255);
          ellipse(x2, y2, 9, 9);

          stroke(255, 80, 30);
          ellipse(x3, y3, 11, 11);

          stroke(0);
        }
      } 

      if ( 
        lastPiece.equals("N") ||
        lastPiece.equals("B") ||
        lastPiece.equals("S") ||
        lastPiece.equals("F")
        ) {

        endShape();
      }

      if ( 
        lastPiece.equals("n") ||
        lastPiece.equals("b") ||
        lastPiece.equals("s") ||
        lastPiece.equals("f")
        ) {

        endShape(CLOSE);
      }
    } 

    popMatrix();
  }
}

// --------------------------------------------------
void selectLinesAndMakeCopy() {
  for (int i=0; i< allImportedLines.length; i++) {
    if (allImportedLines[i].equals("%AI5_BeginLayer")) {
      startLineNum = i + 5;
    }

    if (allImportedLines[i].equals("%AI5_EndLayer--")) {
      endLineNum = i;
    }
  }

  int totalSelectedLineNum = endLineNum - startLineNum;

  for (int i=0; i<totalSelectedLineNum; i++) {
    selectedLines.append( allImportedLines[startLineNum+i] );
  }

  if (totalSelectedLineNum==0) {
    pathInput = errorOnImportMessage;
  } else {
    convertSelectedLines();
  }
}

// --------------------------------------------------
void selectFileInput(File selection) {
  if (selection == null) {
    pathInput = "Window was closed or the user hit cancel.";
  } else {
    clearListsAndIni();
    pathInput = selection.getAbsolutePath();
    allImportedLines = loadStrings(pathInput);
    selectLinesAndMakeCopy();
  }
}

// --------------------------------------------------
void selectFileOutput(File selection) {
  if (selection == null) {
  } else {
    pathOutput = selection.getAbsolutePath();
    saveText();
  }
}

// --------------------------------------------------
void copyTextToClipboard() {
  String copiedText = "";

  String[] linesToSave = new String[convertedLines.size()];
  for (int i = 0; i < linesToSave.length; i++) {
    linesToSave[i] = convertedLines.get(i);
    copiedText = copiedText + convertedLines.get(i) + "\n";
  }

  // String selection = copiedText;
  StringSelection sel = new StringSelection(copiedText);
  Clipboard clipboard = Toolkit.getDefaultToolkit().getSystemClipboard();
  clipboard.setContents(sel, sel);
}

// --------------------------------------------------
void saveText() {
  String[] linesToSave = new String[convertedLines.size()];
  for (int i = 0; i < linesToSave.length; i++) {
    linesToSave[i] = convertedLines.get(i);
  }
  saveStrings(pathOutput, linesToSave);
}
