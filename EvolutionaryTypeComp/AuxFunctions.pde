void configChanged() {
  int oldW = w;
  int oldH = h;
  float oldMarginPerc = marginPerc;
  color oldBgColorPoster = bgColorPoster;
  int oldFontNo = fontNo;

  int oldMinPopulation = minPopulation;
  int oldMaxPopulation = maxPopulation;
  int oldElite_size = elite_size;
  int oldTournament_size = tournament_size;

  loadConfig();

  if (oldW != w || oldH != h || oldMarginPerc != marginPerc ||
    oldBgColorPoster != bgColorPoster || oldFontNo != fontNo) {
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
    for (int i=0; i<maxPopulation; i++) {
      fitnessSlider[i] = new Slider(new PVector(0, 0), 0, 0, 10, 0, 1, false);
    }
  } else if (oldMinPopulation != minPopulation || oldMaxPopulation != maxPopulation ||
    oldElite_size != elite_size|| oldTournament_size != tournament_size) {
    operationRange = new Range(new PVector(width*0.02, height*0.12), 160, 1, 15, minOperations, maxOperations);
    nPostersSlider = new Slider(new PVector(width*0.02, height*0.738 + height*0.016), 160, minPopulation, maxPopulation, population_size, 2, false);
  }
}

void textChanged(String newText) {
  lines = split(newText, '\n');

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
  //============== Evolution ==============//
    //pop = new Population(this);
    for (int i = 0; i < pop.getSize(); i++) {
      pop.getIndiv(i).calculatePhenotype(this, pShape);
      pop.getIndiv(i).image = null;
    }
  //indiv.calculatePhenotype(this, pShape);
  //indiv.drawPhenotype(this, canvas, canvas.width/2, canvas.height/2, canvasW, canvasH, margin, true);
}

//void initialiseProgram() {
//  //============== Geomerative ==============//
//  // Create RShape and convert it to PShape
//  RG.init(this);
//  RFont rFont = new RFont(fonts[fontNo], 500, RG.LEFT);

//  RShape rShape = new RShape();
//  RShape[] aux = new RShape[lines.length];
//  for (int i=0; i<lines.length; i++) {
//    aux[i] = rFont.toShape(lines[i]);
//    aux[i].translate(0, aux[0].getHeight()*1.3*i);
//    for (int j=0; j<aux[i].countChildren(); j++) {
//      rShape.addChild(aux[i].children[j]);
//    }
//  }
//  pShape = RShapeToPShape(rShape);
//  grid = calculateGrid(population_size, width*0.2, height*0.1, w, h, width*0.78, height*0.83, 0, width*0.01, height*0.05, false);

//  changeShapeStyle(pShape, true, color(0), false, color(0));

//  //============== Evolution ==============//
//  pop = new Population(this);
//  for (int i = 0; i < pop.getSize(); i++) {
//    pop.getIndiv(i).calculatePhenotype(this, pShape);
//  }
//}

//============== JSON Configurations ==============//
void loadConfig() {
  println("Loading configurations");
  JSONObject config = loadJSONObject("config.json");

  //============== Canvas ==============//
  w = config.getJSONObject("canvas").getJSONObject("proportions").getInt("w");
  h = config.getJSONObject("canvas").getJSONObject("proportions").getInt("h");
  marginPerc = config.getJSONObject("canvas").getFloat("marginPerc");
  JSONObject bgColor = config.getJSONObject("canvas").getJSONObject("bg_color");
  bgColorPoster = color(bgColor.getInt("r"), bgColor.getInt("g"), bgColor.getInt("b"));
  fontNo = config.getJSONObject("canvas").getInt("fontNo");

  //============== Evolution ==============//
  minPopulation = config.getJSONObject("evolution").getInt("minPopulation");
  maxPopulation = config.getJSONObject("evolution").getInt("maxPopulation");
  elite_size = config.getJSONObject("evolution").getInt("elite_size");
  tournament_size = config.getJSONObject("evolution").getInt("tournament_size");

  //============== Operation Parameters ==============//
  for (Op o : operations) {
    o.loadLimitsFromJSON(config);
  }
}

//============== Calculate grid of rectangular cells ==============//
PVector[][] calculateGrid(int nItems, float x, float y, float itemRealW, float itemRealH, float frameW, float frameH, float margin_min, float gutter_c, float gutter_r, boolean align_top) {
  int rows = 0, cols = 0;
  float aspRatio = ((float)(frameW - margin_min * 2)/(height - margin_min * 2)) / (itemRealW/itemRealH);
  float auxRows = sqrt(nItems / aspRatio);
  float auxCols = sqrt(nItems * aspRatio);
  int [][] auxGrid = {{ceil(auxRows), ceil(auxCols)}, {floor(auxRows), ceil(auxCols)}, {ceil(auxRows), floor(auxCols)}};
  float min = auxGrid[0][0] * auxGrid[0][1];

  //============== Get number of rows and columns ==============//
  rows = (int)auxRows;
  cols = (int)auxCols;
  if (auxRows % 1.5 != 0.0 || auxCols % 1.5 != 0.0) {
    for (int i=0; i<3; i++) {
      float aux = auxGrid[i][0] * auxGrid[i][1];
      if (aux >= nItems && aux <= min) {
        min = aux;
        rows = (int)auxGrid[i][0];
        cols = (int)auxGrid[i][1];
      }
    }
  }
  //============== Get dimensions of each item ==============//
  float itemW, itemH;
  itemW = ((frameW - margin_min * 2) - ((cols - 1) * gutter_c)) / cols;
  itemH = (itemW * itemRealH) / itemRealW;
  if ((itemH * rows + (rows - 1) * gutter_r) + (margin_min * 2) > frameH ) {
    itemH = ((frameH - margin_min * 2) - (rows - 1) * gutter_r) / rows;
    itemW = (itemH * itemRealW) / itemRealH;
  }
  //============== Adjust vertical and horizontal margins ==============//
  float margin_hor_adjusted = ((frameW - cols * itemW) - (cols - 1) * gutter_c) / 2;
  if (rows == 1 && cols > nItems) {
    margin_hor_adjusted = ((frameW - nItems * itemW) - (nItems - 1) * gutter_c) / 2;
  }
  float margin_ver_adjusted = ((frameH - rows * itemH) - (rows - 1) * gutter_r) / 2;
  if (align_top) {
    margin_ver_adjusted = min(margin_hor_adjusted, margin_ver_adjusted);
  }
  //============== Calculate positions ==============//
  PVector[][] positions = new PVector[rows][cols];
  for (int row = 0; row < rows; row++) {
    float row_y = y + margin_ver_adjusted + row * (itemH + gutter_r);
    for (int col = 0; col < cols; col++) {
      float col_x = x + margin_hor_adjusted + col * (itemW + gutter_c);
      positions[row][col] = new PVector(col_x, row_y, itemW);
    }
  }
  return positions;
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

float getPercentageOfNonBackgroundPixels(PImage img, color backgroundColor) {
  // Load the pixels of the image
  img.loadPixels();
  // Loop through all pixels to count background ones
  float numBackgroundPixels = 0;
  for (int i = 0; i < img.pixels.length; i++) {
    if (img.pixels[i] == backgroundColor) {
      numBackgroundPixels++;
    }
  }
  // Calculate percentage of backgroud pixels
  float percentageOfBackgroundPixels = numBackgroundPixels / img.pixels.length;
  
  // Return percentage of non-backgroud pixels
  return 1 - percentageOfBackgroundPixels;
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
