import geomerative.*;
import java.util.*;
import processing.pdf.*; // Needed to export PDFs

//============== Operations ==============//
Op[] operations = new Op[]{
  new OpDistort(),
  new OpFlip(),
  new OpMisalign(),
  new OpRepeat(),
  new OpRotate(),
  new OpScale(),
  new OpSkew(),
  new OpTranslate(),
  new OpFill(),
  new OpStroke()};

//============== Canvas ==============//
int w = 1080, h = 1700;
float marginPerc = 0.05;
color bgColorPoster = 255;
int fontNo = 0;
String[] fonts = {
  "RobotoMono-Regular.ttf",
  "IBMPlexSerif-Regular.ttf",
  "RobotoMono-Thin.ttf",
  "IBMPlexSerif-Thin.ttf",
  "RobotoMono-Bold.ttf",
  "IBMPlexSerif-Bold.ttf"
};

//============== Evolution ==============//
int population_size = 10;
int minPopulation = 4, maxPopulation = 18;
int elite_size = 1;
int tournament_size = 3;
float crossover_rate = 0.7;
float mutation_rate = 0.4;
int minOperations = 2, maxOperations = 10;

Population pop;
PVector[][] grid;
Individual hovered_indiv = null;

int nAttempts = 50;
int validationSize = 200;
int auxPopSize = population_size;

PShape pShape;

//============== Input text ==============//
//String[] lines = {
//  "We\'ve been whispering for hours",
//  "If there\'s a god, she knows",
//  "When something\'s more than words",
//  "Souls do the talking,",
//  "And that\'s how it goes."};

//String[] lines = {""};
//String[] lines = {"Conclusion"};

String[] lines = {"This is text"};
//String[] lines = {"Development Plan"};
//String[] lines = {"text"};
//String[] lines = {"Ω"};
// Δ Θ Λ Ξ Π Σ Φ Ψ Ω β ҉

//String[] lines = {"15yD+M"};
//String[] lines = {"(D+M)x15"};
//String[] lines = {"15 anos", "Design e Multimédia"};

//============== Interface ==============//
PFont roboto, roboto_italic, work_sans, work_sans_bold;
boolean[] opActive = new boolean[operations.length];
Slider nPostersSlider, mutationSlider, crossoverSlider;
Range operationRange;
Slider[] fitnessSlider = new Slider[maxPopulation];
boolean indivSelected = false;
Individual selectedIndiv;
PGraphics fullImage = null;
boolean exported = false;
boolean configChanged = false;
PShape settingsIcon;

String textValue = "";

void setup() {
  //size(1400, 900);
  fullScreen();
  smooth(8);
  pixelDensity(displayDensity()); // added by tiagofm

  loadConfig();

  //============== Interface ==============//
  roboto = createFont("RobotoMono-Regular.ttf", 128);
  roboto_italic = createFont("RobotoMono-Italic.ttf", 128);
  work_sans = createFont("WorkSans-Regular.ttf", 128);
  work_sans_bold = createFont("WorkSans-Bold.ttf", 128);
  textFont(roboto);
  for (int i=0; i<lines.length; i++) {
    textValue += lines[i];
    if (i < lines.length-1) {
      textValue += '\n';
    }
  }
  settingsIcon = loadShape("icon.svg");
  settingsIcon.disableStyle();
  for (int i=0; i < opActive.length; i++) {
    opActive[i] = true;
  }
  //============== Sliders ==============//
  operationRange = new Range(new PVector(width*0.02, height*0.12), 160, 1, 15, minOperations, maxOperations);
  nPostersSlider = new Slider(new PVector(width*0.02, height*0.738 + height*0.016), 160, minPopulation, maxPopulation, population_size, 2, false);
  crossoverSlider = new Slider(new PVector(width*0.02, height*0.802 + height*0.016), 160, 0, 100, crossover_rate*100, 1, true);
  mutationSlider = new Slider(new PVector(width*0.02, height*0.866 + height*0.016), 160, 0, 100, mutation_rate*100, 1, true);
  for (int i=0; i<maxPopulation; i++) {
    fitnessSlider[i] = new Slider(new PVector(0, 0), 0, 0, 10, 0, 1, false);
  }

  //initialiseProgram();

  //textArea = new GTextArea(this, width*0.6, height*0.03, width*0.2, height*0.05, G4P.SCROLLBARS_AUTOHIDE);
  //textArea.setLocalColorScheme(5);

  //============== Geomerative ==============//
  // Create RShape and convert it to PShape
  RG.init(this);
  RFont rFont = new RFont(fonts[fontNo], 500, RG.LEFT);

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
  grid = calculateGrid(population_size, width*0.2, height*0.1, w, h, width*0.78, height*0.83, 0, width*0.01, height*0.05, false);

  changeShapeStyle(pShape, true, color(0), false, color(0));

  //============== Evolution ==============//
  pop = new Population(this);
  for (int i = 0; i < pop.getSize(); i++) {
    pop.getIndiv(i).calculatePhenotype(this, pShape);
  }
}

void draw() {
  if (!focused) {
    configChanged = true;
  }
  if (configChanged) {
    delay(1000);
    if (focused) {
      configChanged = false;
      configChanged();
    }
  }

  noStroke();
  Interface();

  fill(200);

  hovered_indiv = null;
  int r = 0, c = 0;
  for (int i = 0; i < population_size; i++) {
    float x = grid[r][c].x;
    float y = grid[r][c].y;
    float wi = grid[r][c].z;
    float hi = (grid[r][c].z * h) / w;

    if (mouseX > x && mouseX < x + wi && mouseY > y && mouseY < y + hi && !indivSelected) {
      hovered_indiv = pop.getIndiv(i);
      stroke(0);
      strokeWeight(3);
      rect(x, y, wi, hi);
    }
    image(pop.getIndiv(i).getPhenotypeImage(this, round(wi) * 2, round(hi) * 2, int(round(wi) * 2 * marginPerc)), x, y, wi, hi);
    //image(pop.getIndiv(i).image, x, y, wi, hi);
    fill(0);
    textSize(grid[0][0].z * 0.07);
    fitnessSlider[i].changeDimensions(new PVector(x+wi*0.05, y + hi*1.04), wi*0.9);
    fitnessSlider[i].display();

    c += 1;  // Go to next grid cell
    if (c >= grid[r].length) {
      r += 1;
      c = 0;
    }
  }

  if (indivSelected) {
    InterfaceIndivSelected();
  }
}

void keyPressed() {
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

void mousePressed() {
  if (!indivSelected) {
    operationRange.mousePressed();
    nPostersSlider.mousePressed();
    crossoverSlider.mousePressed();
    mutationSlider.mousePressed();
    for (int i=0; i<population_size; i++) {
      fitnessSlider[i].mousePressed();
    }
  }
}

void mouseDragged() {
  if (!indivSelected) {
    operationRange.mouseDragged();
    nPostersSlider.mouseDragged();
    crossoverSlider.mouseDragged();
    mutationSlider.mouseDragged();
    for (int i=0; i<population_size; i++) {
      fitnessSlider[i].mouseDragged();
    }
  }
}

void mouseReleased() {
  if (indivSelected) {
    //============== Exit button ==============//
    float auxW = (height*0.78 * w) / h;
    if (overRect(width*0.955, height*0.04, width*0.02, width*0.02) || mouseX < width/2-auxW/2 || mouseX > width/2+auxW/2) {
      indivSelected = false;
      exported = false;
    }
    //============== Export Individual ==============//
    if (overRect(width/2-width*0.038, height*0.955-height*0.017, width*0.076, height*0.034)) {
      selectedIndiv.exportPhenotypePDF(this, w, h, int(w*marginPerc));
      exported = true;
    }
  } else {
    //============== Sliders ==============//
    operationRange.mouseReleased();
    minOperations = operationRange.getValue()[0];
    maxOperations = operationRange.getValue()[1];
    nPostersSlider.mouseReleased();

    //if (population_size != (int)nPostersSlider.getValue()) {
    auxPopSize = (int)nPostersSlider.getValue();
    //}

    crossoverSlider.mouseReleased();
    crossover_rate = crossoverSlider.getValue()*0.01;
    mutationSlider.mouseReleased();
    mutation_rate = mutationSlider.getValue()*0.01;

    //============== Update Fitness ==============//
    for (int i=0; i<population_size; i++) {
      fitnessSlider[i].mouseReleased();
      pop.getIndiv(i).setFitness(fitnessSlider[i].getValue()*0.1);
    }

    //============== Evolve population ==============//
    if (overRect(width*0.091, height*0.938, width*0.076, height*0.034)) {
      if (population_size != auxPopSize) {
        population_size = auxPopSize;
        grid = calculateGrid(population_size, width*0.2, height*0.1, w, h, width*0.78, height*0.83, 0, width*0.01, height*0.05, false);
      }
      pop.evolve();
      for (int i = 0; i < pop.getSize(); i++) {
        pop.getIndiv(i).calculatePhenotype(this, pShape);
        fitnessSlider[i].resetValue();
      }
    }

    //============== Initialize population ==============//
    if (overRect(width*0.016, height*0.938, width*0.065, height*0.034)) {
      if (population_size != auxPopSize) {
        population_size = auxPopSize;
        grid = calculateGrid(population_size, width*0.2, height*0.1, w, h, width*0.78, height*0.83, 0, width*0.01, height*0.05, false);
      }
      pop.initialize();
      for (int i = 0; i < pop.getSize(); i++) {
        pop.getIndiv(i).calculatePhenotype(this, pShape);
        fitnessSlider[i].resetValue();
      }
    }

    //============== Select Individual ==============//
    if (hovered_indiv != null) {
      indivSelected = true;
      selectedIndiv = hovered_indiv;
      fullImage = null;
      fullImage = createPGraphicsWithDefaultPixelDensity(w*2, h*2, JAVA2D);
      fullImage.beginDraw();
      fullImage.background(bgColorPoster);
      selectedIndiv.drawPhenotype(this, fullImage, w, h, w*2, h*2, int(w*2 * marginPerc), false);
      fullImage.endDraw();
    }

    //============== Interface Operation Buttons ==============//
    int activeCount = 0;
    int lastChanged = 7;
    for (int i=0; i<operations.length; i++) {
      float y;
      if (i < 8) {
        y = height*0.2 + height*0.033 * i;
      } else {
        y = height*0.2 + height*0.033 * (i+1);
      }
      if (overRect(width*0.03, y - height*0.015, width*0.01, width*0.01)) {
        opActive[i] = !opActive[i];
        lastChanged = i;
      }
      if (opActive[i]) {
        activeCount++;
      }
    }
    if (activeCount == 0) {
      opActive[lastChanged] = true;
    }

    if (overRect(width*0.95, height*0.03, width*0.03, width*0.03)) {
      launch(sketchPath()+"/data/config.json");
      configChanged = true;
    }
  }
}
