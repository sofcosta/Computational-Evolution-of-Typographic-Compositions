import geomerative.*; //<>//
import java.util.*;
import processing.pdf.*; // Needed to export PDFs
//import controlP5.*;

//ControlP5 cp5;

Op[] operations = new Op[]{
  new OpTranslate(),
  new OpRotate(),
  new OpScale(),
  new OpFlip(),
  new OpSkew(),
  new OpRepeat(),
  new OpMisalign(),
  new OpDistort(),
  new OpFill(),
  new OpStroke()};

int canvasW = 1080, canvasH = 1700;
int w = 540, h = 850;
int margin = 50;
color bgColorPoster = 255;

Individual indiv;
int minOperations = 2, maxOperations = 10;

PShape pShape;
PGraphics canvas;

//String[] lines = {"This is not text"};
String[] lines = {"This is text"};
//String[] lines = {"15yD+M"};

//String[] lines = {
//  "We\'ve been whispering for hours",
//  "If there\'s a god, she knows",
//  "When something\'s more than words",
//  "Souls do the talking,",
//  "And that\'s how it goes."};

//String[] lines = {"ΨΩ"};
// Δ Θ Λ Ξ Π Σ Φ Ψ Ω β ҉

float[][] buttons = new float[maxOperations][2];
float buttonW = 30, buttonH = 50;

String[] file = {"[flip 0,019 0,045][flip 0,566 0,368][repeat 0,223 0,844 0,014 0,358 0,354 0,318][repeat 0,985 0,058 0,866 0,732 0,770 0,615][rotate 0,627][rotate 0,477]"};

//String[] file;
ArrayList<float[]> genes = new ArrayList<float[]>();

PFont roboto, workSans, workSansBold, inputFont;

String textValue = "";

PShape logo;

void setup() {
  //fullScreen();
  size(1600, 900);
  smooth(8);
  pixelDensity(displayDensity());

  roboto = createFont("RobotoMono-Regular.ttf", 128);
  workSans = createFont("WorkSans-Regular.ttf", 128);
  workSansBold = createFont("WorkSans-Bold.ttf", 128);
  //inputFont = createFont("RobotoMono-Regular.ttf", 12);
  textFont(workSans);

  logo = loadShape("logo.svg");

  genes = stringToGenes(file[0]);

  //genes = formulaToGenes(file[0]);

  // Create RShape and convert it to PShape
  RG.init(this);
  RFont rFont = new RFont("RobotoMono-Regular.ttf", 500, RG.LEFT);
  //RFont rFont = new RFont("IBMPlexSerif-Regular.ttf", 500, RG.LEFT);
  RShape rShape = new RShape();
  RShape[] aux = new RShape[lines.length];
  for (int i=0; i<lines.length; i++) {
    aux[i] = rFont.toShape(lines[i]);
    aux[i].translate(0, aux[0].getHeight()*1.3*i);
    for (int j=0; j<aux[i].countChildren(); j++) {
      rShape.addChild(aux[i].children[j]);
    }
  }
  pShape = RShapeToPShape(rShape);
  changeShapeStyle(pShape, true, color(0), false, color(0));

  canvas = createGraphics(canvasW, canvasH);
  indiv = new Individual(operations, minOperations, maxOperations);
  indiv.randomise();
  if (genes != null) {
    indiv.setGenes(genes);
  }
  indiv.calculatePhenotype(this, pShape);
  indiv.drawPhenotype(this, canvas, canvas.width/2, canvas.height/2, canvasW, canvasH, margin, true);

  for (int i=0; i<buttons.length; i++) {
    buttons[i][0] = w + 50;
    buttons[i][1] = 40 + buttonH*1.5*i;
    if (i >= 10) {
      buttons[i][0] = w + 600;
      buttons[i][1] = 40 + buttonH*1.5*(i-10);
    }
  }

  textSize(20);
  textAlign(LEFT, TOP);
  noStroke();

  for (int i=0; i<lines.length; i++) {
    textValue += lines[i];
    if (i < lines.length-1) {
      textValue += '\n';
    }
  }
}

void draw() {
  background(220);
  image(canvas, 25, 25, w, h);

  // =================== Parameters Adjustments =================== //
  for (int i=0; i<indiv.getNumOp(); i++) {
    if (overRect(buttons[i][0] + 470, buttons[i][1] + 20, 20, 20)) {
      stroke(200);
    } else {
      stroke(255);
    }
    strokeWeight(5);
    line(buttons[i][0] + 470, buttons[i][1] + 20, buttons[i][0] + 470 + 20, buttons[i][1] + 40);
    line(buttons[i][0] + 470, buttons[i][1] + 40, buttons[i][0] + 470 + 20, buttons[i][1] + 20);
    noStroke();
    fill(0);
    textSize(18);
    text(indiv.getOpName(i), buttons[i][0], buttons[i][1]);
    Op currOp = getOperationByIndex(operations, indiv.genes.get(i)[0]);
    float[] params = indiv.getOpParams(i);
    textSize(12);
    for (int j=0; j<params.length; j++) {
      fill(0);
      float auxParam = currOp.parseParam(j, params[j]);
      if (indiv.genes.get(i)[0] == 1 || indiv.genes.get(i)[0] == 4 || (indiv.genes.get(i)[0] == 5 && j == 5)) {  // Degrees
        text(int(degrees(auxParam)), buttons[i][0] + 70*j, buttons[i][1] + 36);
        //auxParam = int(degrees(auxParam));
      } else if ((indiv.genes.get(i)[0] == 5 && j == 0) || indiv.genes.get(i)[0] == 8 || indiv.genes.get(i)[0] == 9) {  // n Repeat
        text(round(auxParam), buttons[i][0] + 70*j, buttons[i][1] + 36);
      } else if (indiv.genes.get(i)[0] == 7 && j == 0) {
        text(nf(auxParam, 0, 2), buttons[i][0] + 70*j, buttons[i][1] + 36);
      } else {
        text(nf(auxParam, 0, 1), buttons[i][0] + 70*j, buttons[i][1] + 36);
      }
      if (overRect(buttons[i][0] + 70*j+35, buttons[i][1] + 35, 10, 5)) {
        fill(200);
      } else {
        fill(255);
      }
      triangle(buttons[i][0] + 70*j+35, buttons[i][1] + 40, buttons[i][0] + 70*j+40, buttons[i][1] + 35, buttons[i][0] + 70*j+45, buttons[i][1] + 40);
      if (overRect(buttons[i][0] + 70*j+35, buttons[i][1] + 45, 10, 5)) {
        fill(200);
      } else {
        fill(255);
      }
      triangle(buttons[i][0] + 70*j+35, buttons[i][1] + 45, buttons[i][0] + 70*j+40, buttons[i][1] + 50, buttons[i][0] + 70*j+45, buttons[i][1] + 45);
    }
  }
  // =================== New Operation Buttons =================== //
  fill(255);
  textSize(14);
  text("Add new operation:", buttons[0][0], height - 80);
  for (int i=0; i<operations.length; i++) {
    if (overRect(buttons[0][0] + 90*i, height - 60, 80, 30)) {
      fill(200);
    } else {
      fill(255);
    }
    rect(buttons[0][0] + 90*i, height - 60, 80, 30);
    fill(0);
    text(operations[i].name, buttons[0][0] + 90*i + 3, height - 50);
  }
  // =================== Reset Button =================== //
  if (overRect(width-100, height - 60, 70, 30)) {
    fill(200);
  } else {
    fill(255);
  }
  rect(width-80, height - 60, 55, 30);
  fill(0);
  text("reset", width-75, height - 50);

  // =================== Text Input =================== //
  //if (!cp5.get(Textfield.class, "text").getText().equals(textValue)) {
  //  textValue = cp5.get(Textfield.class, "text").getText();
  //  if (textValue.equals("")) {
  //    textValue = "|";
  //  }
  //  textChanged(textValue);
  //}
  fill(0);
  noStroke();
  textAlign(LEFT, TOP);
  text(textValue, width*0.75, height*0.1);
}

void keyPressed() {
  if (!overRect(25, 25, w, h)) {
    if ((keyCode > 44 && keyCode < 111) || key == ENTER || key == RETURN || key == ' ') {
      if (textValue.equals("|")) {
        textValue = ""+key;
      } else {
        textValue += key;
      }
    } else if (key == BACKSPACE) {
      if (textValue.length() > 0) {
        textValue = textValue.substring(0, textValue.length()-1);
      }
      if (textValue.equals("")) {
        textValue = "|";
      }
    }
    textChanged(textValue);
  }
}

void keyReleased() {
  if (key == 'e' && overRect(25, 25, w, h)) {
    indiv.exportPhenotypePDF(this, canvasW, canvasH, margin);
  }
}

void mouseReleased() {
  // =================== Parameters Adjustments =================== //
  for (int i=0; i<indiv.getNumOp(); i++) {
    if (overRect(buttons[i][0] + 470, buttons[i][1] + 20, 20, 20)) {
      indiv.removeOp(i);
      break;
    }
    float[] params = indiv.getOpParams(i);
    for (int j=0; j<params.length; j++) {
      if (overRect(buttons[i][0] + 70*j+35, buttons[i][1] + 35, 10, 5)) {
        indiv.changeParam(i, j, constrain(params[j] + 0.1, 0, 1));
        println(params[j]);
      } else if (overRect(buttons[i][0] + 70*j+35, buttons[i][1] + 45, 10, 5)) {
        indiv.changeParam(i, j, constrain(params[j] - 0.1, 0, 1));
        println(params[j]);
      }
    }
    indiv.calculatePhenotype(this, pShape);
    indiv.drawPhenotype(this, canvas, canvas.width/2, canvas.height/2, canvasW, canvasH, margin, true);
  }
  // =================== New Operation Buttons =================== //
  for (int i=0; i<operations.length; i++) {
    if (overRect(buttons[0][0] + 90*i, height - 60, 80, 30)) {
      indiv.addOp(i);
    }
    indiv.calculatePhenotype(this, pShape);
    indiv.drawPhenotype(this, canvas, canvas.width/2, canvas.height/2, canvasW, canvasH, margin, true);
  }
  // =================== Reset Button =================== //
  if (overRect(width-100, height - 60, 70, 30)) {
    genes = stringToGenes(file[0]);
    indiv.setGenes(genes);
    indiv.calculatePhenotype(this, pShape);
    indiv.drawPhenotype(this, canvas, canvas.width/2, canvas.height/2, canvasW, canvasH, margin, true);
  }
}

// added by tiagofm
PGraphics createPGraphicsWithDefaultPixelDensity(int w, int h, String renderer, String outputPath) {
  int currPixelDensity = pixelDensity;
  pixelDensity = 1;
  PGraphics pg;
  if (outputPath == null) {
    pg = createGraphics(w, h, renderer);
  } else {
    pg = createGraphics(w, h, renderer, outputPath);
  }
  pixelDensity = currPixelDensity;
  return pg;
}

// added by tiagofm
PGraphics createPGraphicsWithDefaultPixelDensity(int w, int h, String renderer) {
  return createPGraphicsWithDefaultPixelDensity(w, h, renderer, null);
}

// =================== Check if mouse is inside rect =================== //
boolean overRect(float x, float y, float w, float h) {
  if (mouseX >= x && mouseX <= x+w &&
    mouseY >= y && mouseY <= y+h) {
    return true;
  } else {
    return false;
  }
}

// =================== Add line breaks to string depending on available space width =================== //
String addLineBreaksToText(String text, float w) {
  float genotypeTextW = textWidth(text);
  int nRows = ceil(genotypeTextW/w);
  String output = "";
  int maxIndexOfBreak = floor(w/textWidth("a"));
  int indexOfBreak = maxIndexOfBreak;
  int indexOfBreakAux = 0;
  for (int i=0; i < nRows; i++) {
    //println(i);
    if (indexOfBreak < text.length()) {
      while (text.charAt(indexOfBreak) != ' ') {
        indexOfBreak--;
      }
      indexOfBreak++;
      output += text.substring(indexOfBreakAux, indexOfBreak);
      nRows = i+ceil(textWidth(text.substring(indexOfBreak, text.length()))/w) + 1;
      indexOfBreakAux = indexOfBreak;
      indexOfBreak += maxIndexOfBreak;
    } else {
      output += text.substring(indexOfBreakAux, text.length());
    }
    output += "\n";
  }
  return output;
}

// =================== String of genes to Arraylist =================== //
ArrayList<float[]> stringToGenes(String file) {
  String[] opNames = getOperationsNames(operations);
  String[] list = splitTokens(file, "[]");
  ArrayList<float[]> genes = new ArrayList<float[]>();
  for (int i=0; i<list.length; i++) {
    String[] auxS = split(list[i], " ");
    float[] auxf = new float[auxS.length];
    for (int j=0; j<opNames.length; j++) {
      if (auxS[0].equals(opNames[j])) {
        auxf[0] = j;
      }
    }
    for (int j=1; j<auxS.length; j++) {
      auxf[j] = float(auxS[j].replace(",", "."));
    }
    genes.add(auxf);
  }
  return genes;
}

ArrayList<float[]> formulaToGenes(String file) {
  String[] opNames = getOperationsNames(operations);
  ArrayList<float[]> genes = new ArrayList<float[]>();
  String auxString = file;
  while (auxString.indexOf("(") != -1) {
    String auxOp = auxString.substring(0, auxString.indexOf("("));
    auxString = auxString.substring(auxString.indexOf("(")+1, auxString.length()-1);
    String auxParams;
    if (auxString.lastIndexOf(")") != -1) {
      auxParams = auxString.substring(auxString.lastIndexOf(")")+2, auxString.length());
      auxString = auxString.substring(0, auxString.lastIndexOf(")")+1);
    } else {
      auxParams = auxString.substring(auxString.lastIndexOf("\"")+2, auxString.length());
      auxString = auxString.substring(auxString.indexOf("\"")+1, auxString.lastIndexOf("\""));
      lines[0] = auxString;
    }
    float[] auxf = new float[getOpNumParamsByName(operations, auxOp)+1];
    for (int j=0; j<opNames.length; j++) {
      if (auxOp.equals(opNames[j])) {
        auxf[0] = j;
      }
    }
    int paramIndex = 1;
    while (auxParams.indexOf("=") != -1) {
      float param;
      if (auxParams.indexOf(",") != -1) {
        param = float(auxParams.substring(auxParams.indexOf("=")+1, auxParams.indexOf(",")));
        auxParams = auxParams.substring(auxParams.indexOf(",")+1, auxParams.length());
      } else {
        param = float(auxParams.substring(auxParams.indexOf("=")+1, auxParams.length()));
        auxParams = "";
      }
      auxf[paramIndex] = param;
      paramIndex++;
    }
    genes.add(auxf);
  }
  return genes;
}


void textChanged(String newText) {
  lines = split(newText, '\n');

  //lines[0] = newText;
  //============== Geomerative ==============//
  // Create RShape and convert it to PShape
  RG.init(this);
  RFont rFont = new RFont("RobotoMono-Regular.ttf", 500, RG.LEFT);

  RShape rShape = new RShape();
  RShape[] aux = new RShape[lines.length];
  for (int i=0; i<lines.length; i++) {
    aux[i] = rFont.toShape(lines[i]);
    aux[i].translate(0, aux[0].getHeight()*1.3*i);
    for (int j=0; j<aux[i].countChildren(); j++) {
      rShape.addChild(aux[i].children[j]);
    }
  }
  pShape = RShapeToPShape(rShape);
  changeShapeStyle(pShape, true, color(0), false, color(0));
  indiv.calculatePhenotype(this, pShape);
  indiv.drawPhenotype(this, canvas, canvas.width/2, canvas.height/2, canvasW, canvasH, margin, true);
}
