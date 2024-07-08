void InterfaceIndivSelected() {
  //============== Background ==============//
  fill(0, 200);
  rect(0, 0, width, height);

  //============== Exit button ==============//
  noFill();
  if (overRect(width*0.955, height*0.04, width*0.02, width*0.02)) {
    stroke(200);
  } else {
    stroke(255);
  }
  strokeWeight(5);
  line(width*0.955, height*0.04, width*0.955+width*0.02, height*0.04+width*0.02);
  line(width*0.955, height*0.04+width*0.02, width*0.955+width*0.02, height*0.04);
  strokeWeight(1);

  //============== Individual ==============//
  float auxW = (height*0.78 * w) / h;
  //image(selectedIndiv.getPhenotypeImage(this, w*2, h*2, int(w*2 * marginPerc)), width/2-auxW/2, height*0.115, auxW, height*0.78);
  image(fullImage, width/2-auxW/2, height*0.115, auxW, height*0.78);

  //============== Export Button ==============//
  if (overRect(width/2-width*0.038, height*0.955-height*0.017, width*0.076, height*0.034)) {
    fill(200);
  } else {
    fill(255);
  }
  stroke(0);
  strokeWeight(2);
  rectMode(CENTER);
  rect(width/2, height*0.955, width*0.076, height*0.034);
  strokeWeight(1);

  fill(0);
  textSize(width*0.019);
  textAlign(CENTER, BASELINE);
  text("Export", width/2, height*0.965);

  if (exported) {
    fill(255);
    textSize(width*0.0093);
    textAlign(LEFT, BASELINE);
    text("Your export has been\nsuccessful!", width/2 + width*0.045, height*0.951);
  }

  //============== Genotype ==============//
  textSize(width*0.0093);
  textAlign(CENTER, CENTER);
  String genotype = selectedIndiv.getFormula(true, 1);
  float genotypeTextW = textWidth(genotype);
  int nRows = ceil(genotypeTextW/(width*0.85));
  String genotypeDisplay = addLineBreaksToText(genotype, width*0.85);
  fill(255);
  noStroke();
  float auxWidth;
  if (genotypeTextW > width*0.85) {
    auxWidth = width*0.864;
  } else {
    auxWidth = genotypeTextW + width*0.014;
  }
  rect(width/2, height*0.058, auxWidth, height*0.03 + height*0.015*(nRows-1));
  fill(0);
  text(genotypeDisplay, width/2, height*0.065);
  rectMode(CORNER);
}

void Interface() {
  float posXTextLeft = width*0.02;
  float posXOp = posXTextLeft + width*0.01;
  float posYOpInc = height*0.033;

  //============== Section Backgrounds ==============//
  fill(221, 247, 255);  // Blue -> Posters
  rect(width*0.18, 0, width*0.82, height);

  fill(255, 251, 220);  // Yellow -> Operations
  rect(0, 0, width*0.18, height*0.60);

  fill(255, 237, 237);  // Red -> Evolution
  rect(0, height*0.60, width*0.18, height*0.40);

  //============== Section Titles ==============//
  fill(0);
  textFont(roboto_italic);
  textSize(width*0.023);
  textAlign(LEFT, BASELINE);

  text("Operations", posXTextLeft, height*0.06);
  text("Evolution", posXTextLeft, height*0.66);
  text("Compositions", width*0.2, height*0.06);

  //============== Operations Section ==============//
  textFont(roboto);
  textSize(width*0.0093);
  text("Number of operations", posXTextLeft, height*0.1);

  operationRange.display();

  textSize(width*0.012);
  textAlign(LEFT, BASELINE);

  for (int i=0; i<operations.length; i++) {
    if (i < 8) {
      toggleOp(operations[i].name, posXOp, height*0.2 + posYOpInc * i, opActive[i]);
    } else {
      toggleOp(operations[i].name, posXOp, height*0.2 + posYOpInc * (i+1), opActive[i]);
    }
  }

  textSize(width*0.007);
  textAlign(RIGHT, BASELINE);
  fill(0);
  text("Geometric", posXTextLeft + width*0.138, height*0.28 + height*0.165);
  text("Style", posXTextLeft + width*0.138, height*0.076 + height*0.465);

  noFill();
  stroke(0);
  rect(posXTextLeft, height*0.17, width*0.14, height*0.28);
  rect(posXTextLeft, height*0.47, width*0.14, height*0.076);

  //============== Evolution Section ==============//
  textSize(width*0.0093);
  textAlign(LEFT, BASELINE);
  text("Generation: #" + (pop.getGenerations()+1), posXTextLeft, height*0.7);
  text("Number of compositions", posXTextLeft, height*0.738);
  text("Recombination probability", posXTextLeft, height*0.802);
  text("Mutation probability", posXTextLeft, height*0.866);

  nPostersSlider.display();
  crossoverSlider.display();
  mutationSlider.display();

  stroke(0);
  strokeWeight(2);
  if (overRect(width*0.011, height*0.934, width*0.069, height*0.042) && !indivSelected) {
    fill(216, 192, 192);
  } else {
    fill(255, 237, 237);
  }
  rect(width*0.011, height*0.934, width*0.069, height*0.042);

  if (overRect(width*0.089, height*0.934, width*0.080, height*0.042) && !indivSelected) {
    fill(216, 192, 192);
  } else {
    fill(255, 237, 237);
  }
  rect(width*0.089, height*0.934, width*0.080, height*0.042);
  strokeWeight(1);

  fill(0);
  textSize(width*0.019);
  textAlign(LEFT, BASELINE);

  text("Reset", posXTextLeft - width*0.003, height*0.965);
  text("Evolve", width*0.095, height*0.965);
  
  //============== Compositions Section ==============//
  if (overRect(width*0.95, height*0.03, width*0.03, width*0.03)) {
    fill(100);
  } else {
    fill(0);
  }
  noStroke();
  shape(settingsIcon, width*0.95, height*0.03, width*0.025, width*0.025);
  
  fill(0);
  noStroke();
  textSize(width*0.0093);
  textAlign(LEFT, TOP);
  text(textValue, width*0.65, height*0.04);
}

void toggleOp(String opName, float posX, float posY, boolean active) {
  fill(0);
  text(opName, posX + width*0.02, posY);
  if (overRect(posX, posY - height*0.015, width*0.01, width*0.01) && !indivSelected) {
    fill(206, 203, 181);
  } else if (active) {
    fill(0);
  } else {
    fill(255, 251, 220);
  }
  stroke(0);
  rect(posX, posY - height*0.014, width*0.01, width*0.01);
}

class Slider {
  PVector sliderPos;
  float sliderW;
  float sliderMin, sliderMax;
  float sliderValue;
  float step;
  float handlePos;
  boolean overHandle = false;
  boolean locked = false;
  int handleColor = 50;
  int colorStatic, colorHover;
  boolean percentage;

  Slider() {
  }

  Slider(PVector sliderPos, float sliderW, float sliderMin, float sliderMax, float sliderValue, float step, boolean percentage) { //, int colorStatic, int colorHover
    this.sliderPos = sliderPos;
    this.sliderW = sliderW;
    this.sliderMin = sliderMin;
    this.sliderMax = sliderMax;
    this.sliderValue = sliderValue;
    handlePos = map(sliderValue, sliderMin, sliderMax, 0, sliderW);
    this.step = step;
    this.percentage = percentage;
  }

  void display() {
    if ((dist(sliderPos.x + handlePos, sliderPos.y, mouseX, mouseY) < width*0.006 ||
      overRect(sliderPos.x, sliderPos.y-width*0.003, sliderW, width*0.007))
      && !indivSelected) {
      overHandle = true;
      handleColor = 100;
    } else {
      overHandle = false;
      if (!locked) {
        handleColor = 0;
      }
    }

    stroke(handleColor);
    strokeWeight(1.5);
    line(sliderPos.x, sliderPos.y, sliderPos.x + sliderW, sliderPos.y);

    noStroke();
    fill(handleColor);
    ellipse(sliderPos.x + handlePos, sliderPos.y, width*0.0058, width*0.0058);

    fill(0);
    textAlign(CENTER);
    if (step == 1) {
      sliderValue = ceil(map(handlePos, 0, sliderW, sliderMin, sliderMax));
    } else {
      sliderValue = ceil(map(handlePos, 0, sliderW, sliderMin/step, sliderMax/step)) * step;
    }
    if (percentage) {
      text((int)sliderValue + "%", sliderPos.x + handlePos, sliderPos.y + height*0.02);
    } else {
      text((int)sliderValue, sliderPos.x + handlePos, sliderPos.y + height*0.02);
    }
  }

  void changeDimensions(PVector sliderPos, float sliderW) {
    this.sliderPos = sliderPos;
    this.sliderW = sliderW;
  }

  void resetValue() {
    handlePos = 0;
  }

  float getValue() {
    return sliderValue;
  }

  void mousePressed() {
    if (overHandle) {
      locked = true;
      handlePos = constrain(mouseX - sliderPos.x, 0, sliderW);
    }
  }

  void mouseDragged() {
    if (locked) {
      handlePos = constrain(mouseX - sliderPos.x, 0, sliderW);
      handleColor = colorHover;
    }
  }

  void mouseReleased() {
    locked = false;
  }
}

class Range {
  PVector rangePos;
  float rangeW;
  float rangeMin, rangeMax;
  int rangeMinValue, rangeMaxValue;
  float handleMinPos, handleMaxPos;
  boolean overMinHandle = false, overMaxHandle = false;
  boolean lockedMin = false, lockedMax = false;
  int handleMinColor = 50, handleMaxColor = 50;
  float stepSize;


  Range(PVector rangePos, float rangeW, float rangeMin, float rangeMax, int rangeMinValue, int rangeMaxValue) {
    this.rangePos = rangePos;
    this.rangeW = rangeW;
    this.rangeMin = rangeMin;
    this.rangeMax = rangeMax;
    this.rangeMinValue = rangeMinValue;
    this.rangeMaxValue = rangeMaxValue;
    handleMinPos = map(rangeMinValue, rangeMin, rangeMax, 0, rangeW);
    handleMaxPos = map(rangeMaxValue, rangeMin, rangeMax, 0, rangeW);
    stepSize = rangeW/(rangeMax-rangeMin);
  }

  void display() {
    if ((dist(rangePos.x + handleMinPos, rangePos.y, mouseX, mouseY) < width*0.006 ||
      overRect(rangePos.x, rangePos.y-width*0.003, handleMinPos+(handleMaxPos-handleMinPos)/2, width*0.006))
      && !indivSelected) {
      overMinHandle = true;
      handleMinColor = 100;
    } else {
      overMinHandle = false;
      if (!lockedMin) {
        handleMinColor = 0;
      }
    }
    if ((dist(rangePos.x + handleMaxPos, rangePos.y, mouseX, mouseY) < width*0.006 ||
      (mouseX>rangePos.x+handleMaxPos-(handleMaxPos-handleMinPos)/2 && mouseY>rangePos.y-10 && mouseX<rangePos.x+rangeW && mouseY<rangePos.y+10))
      && !indivSelected) {
      overMaxHandle = true;
      handleMaxColor = 100;
    } else {
      overMaxHandle = false;
      if (!lockedMax) {
        handleMaxColor = 0;
      }
    }

    stroke(150);
    strokeWeight(1.5);
    line(rangePos.x, rangePos.y, rangePos.x+handleMinPos, rangePos.y);
    line(rangePos.x+handleMaxPos, rangePos.y, rangePos.x + rangeW, rangePos.y);
    stroke(0);
    line(rangePos.x+handleMinPos, rangePos.y, rangePos.x+handleMaxPos, rangePos.y);

    noStroke();
    fill(handleMinColor);
    ellipse(rangePos.x + handleMinPos, rangePos.y, width*0.0058, width*0.0058);
    fill(handleMaxColor);
    ellipse(rangePos.x + handleMaxPos, rangePos.y, width*0.0058, width*0.0058);

    fill(0);
    textAlign(CENTER);
    textSize(width*0.0093);
    rangeMinValue = (int)map(handleMinPos, 0, rangeW, rangeMin, rangeMax);
    text((int)rangeMinValue, rangePos.x + handleMinPos, rangePos.y + height*0.02);
    rangeMaxValue = (int)map(handleMaxPos, 0, rangeW, rangeMin, rangeMax);
    text((int)rangeMaxValue, rangePos.x + handleMaxPos, rangePos.y + height*0.02);
  }

  int[] getValue() {
    return new int[] {rangeMinValue, rangeMaxValue};
  }

  void mousePressed() {
    if (overMinHandle) {
      lockedMin = true;
      handleMinPos = constrain(mouseX - rangePos.x, 0, handleMaxPos - stepSize);
    } else if (overMaxHandle) {
      lockedMax = true;
      handleMaxPos = constrain(mouseX - rangePos.x, handleMinPos + stepSize, rangeW);
    }
  }

  void mouseDragged() {
    if (lockedMin) {
      handleMinPos = constrain(mouseX - rangePos.x, 0, handleMaxPos - stepSize);
      handleMinColor = 0;
    } else if (lockedMax) {
      handleMaxPos = constrain(mouseX - rangePos.x, handleMinPos + stepSize, rangeW);
      handleMaxColor = 0;
    }
  }

  void mouseReleased() {
    lockedMin = false;
    lockedMax = false;
  }
}
