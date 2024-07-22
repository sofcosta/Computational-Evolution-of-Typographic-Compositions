class Individual {

  ArrayList<float[]> genes = new ArrayList<float[]>();
  PShape phenotype = null;
  float fitness = 0;
  PGraphics image = null;

  Op[] ops;
  int minOps;
  int maxOps;

  Individual(Op[] ops, int minOps, int maxOps) {
    this.ops = ops;
    this.minOps = minOps;
    this.maxOps = maxOps;
  }

  Individual() {
    this.ops = operations;
    this.minOps = minOperations;
    this.maxOps = maxOperations;
  }

  Individual getCopy() {
    Individual copy = new Individual(ops, minOps, maxOps);
    for (int o = 0; o < genes.size(); o++) {
      float[] groupOfGenes = new float[genes.get(o).length];
      System.arraycopy(genes.get(o), 0, groupOfGenes, 0, genes.get(o).length);
      copy.genes.add(groupOfGenes);
    }
    copy.fitness = fitness;
    return copy;
  }

  void randomise() {
    // Clear existing genes
    genes.clear();

    // Determine number of operations
    int numOps = int(random(minOps, maxOps + 1));

    // Create genes
    for (int o = 0; o < numOps; o++) {
      int indexRandomOp = int(random(ops.length));
      float[] groupOfGenes = new float[1 + ops[indexRandomOp].getNumParams()];
      groupOfGenes[0] = indexRandomOp;
      for (int g = 1; g < groupOfGenes.length; g++) {
        groupOfGenes[g] = random(0, 1);
      }
      genes.add(groupOfGenes);
    }
  }

  void setGenes(ArrayList<float[]> newGenes) {
    genes.clear();
    for (int i = 0; i < newGenes.size(); i++) {
      genes.add(newGenes.get(i));
    }
  }

  void setFitness(float fitness) {
    this.fitness = fitness;
  }

  float getFitness() {
    return fitness;
  }

  float getNumOp() {
    return genes.size();
  }

  String getOpName(int index) {
    return getOperationByIndex(operations, genes.get(index)[0]).name;
  }

  void removeOp(int index) {
    genes.remove(index);
  }

  float[] getOpParams(int index) {
    float[] params = new float[genes.get(index).length-1];
    for (int j=0; j<genes.get(index).length-1; j++) {
      params[j] = genes.get(index)[j+1];
    }
    return params;
  }

  void changeParam(int iOp, int iParam, float newValue) {
    genes.get(iOp)[iParam+1] = newValue;
  }

  void addOp(int opIndex) {
    if (genes.size() < maxOps) {
      float[] groupOfGenes = new float[1 + ops[opIndex].getNumParams()];
      groupOfGenes[0] = opIndex;
      for (int g = 1; g < groupOfGenes.length; g++) {
        groupOfGenes[g] = random(0, 1);
      }
      genes.add(groupOfGenes);
    } else {
      System.err.println("Max number of Operations!");
    }
  }

  String getString(boolean parseParams, int decimalDigits) {
    String text = "";
    for (int o = 0; o < genes.size(); o++) {
      Op currOp = getOperationByIndex(ops, genes.get(o)[0]);
      text += "[" + currOp.name + " ";
      for (int g = 1; g < genes.get(o).length; g++) {
        if (parseParams) {
          text += nf(currOp.parseParam(g - 1, genes.get(o)[g]), 0, decimalDigits);
        } else {
          text += nf(genes.get(o)[g], 0, decimalDigits);
        }
        if (g < genes.get(o).length - 1) {
          text += " ";
        }
      }
      text += "]";
      if (o < genes.size() - 1) {
        text += "";
      }
    }
    return text;
  }

  String getFormula(boolean parseParams, int decimalDigits) {
    String text = "\"";
    for (int i=0; i<lines.length; i++) {
      text += lines[i];
      if (lines.length>1 && i != lines.length-1) {
        text += " / ";
      }
    }
    text += "\"";
    for (int o = 0; o < genes.size(); o++) {
      Op currOp = getOperationByIndex(ops, genes.get(o)[0]);
      String auxOp = currOp.name + "(";
      for (int g = 1; g < genes.get(o).length; g++) {
        auxOp += currOp.paramNames[g-1] + "=";
        if (parseParams) {
          if (genes.get(o)[0] == 1 || genes.get(o)[0] == 4 || (genes.get(o)[0] == 5 && g == 6)) {  // Degrees
            auxOp += int(degrees(currOp.parseParam(g - 1, genes.get(o)[g]))) + ", ";
          } else if (genes.get(o)[0] == 5 && g == 1 || genes.get(o)[0] == 8 || genes.get(o)[0] == 9) {  // int
            auxOp += int(currOp.parseParam(g - 1, genes.get(o)[g])) + ", ";
          } else if (genes.get(o)[0] == 7 && g == 1) {
            auxOp += nf(currOp.parseParam(g - 1, genes.get(o)[g]), 0, decimalDigits+1).replace(',', '.') + ", ";
          } else {
            auxOp += nf(currOp.parseParam(g - 1, genes.get(o)[g]), 0, decimalDigits).replace(',', '.') + ", ";
          }
        } else {
          auxOp += nf(genes.get(o)[g], 0, decimalDigits).replace(',', '.') + ", ";
        }
      }
      text = auxOp + text + ")";
    }
    return text;
  }

  void calculatePhenotype(PApplet parent, PShape shape) {
    // call sequence of operations to generate final shape, and keep in memory
    phenotype = MyPShape.getCopy(parent, shape);
    // center shape (it is initialised aligned to the left and bottom)
    phenotype = applyOperation(operations, "translate", parent, phenotype, new float[]{-0.5, -0.5});
    for (int i=0; i<genes.size(); i++) {
      float opIndex = genes.get(i)[0];
      Op currOp = getOperationByIndex(ops, opIndex);
      float[] params = new float[getOpNumParamsByIndex(operations, opIndex)];
      for (int j=1; j<genes.get(i).length; j++) {
        params[j-1] = currOp.parseParam(j-1, genes.get(i)[j]);
      }
      //println("==============================");
      //println(currOp.name);
      phenotype = applyOperation(operations, currOp.name, parent, phenotype, params);
      //println("==============================");
    }
  }

  void drawPhenotype(PApplet parent, PGraphics pg, float x, float y, float maxW, float maxH, float margin, boolean geno) {
    if (phenotype == null) {
      println("Phenotype null");
      return;
    }
    margin = margin*2;
    pg.beginDraw();
    pg.background(bgColorPoster);
    // Calculate scaling to fit frame
    PVector shapeDimensions = getDimensions(phenotype);
    float auxDim = ((maxW-margin)*shapeDimensions.y)/shapeDimensions.x;
    float scaleFactor = 1;
    if (auxDim <= (maxH-margin)) {
      scaleFactor = auxDim / shapeDimensions.y;
    } else {
      auxDim = ((maxH-margin)*shapeDimensions.x)/shapeDimensions.y;
      scaleFactor = auxDim / shapeDimensions.x;
    }
    phenotype = applyOperation(operations, "scale", parent, phenotype, new float[]{scaleFactor, scaleFactor});
    for (int i=0; i<phenotype.getChildCount(); i++) {
      phenotype.getChild(i).setStrokeWeight(maxW * 0.005);
    }
    pg.shape(phenotype, x-getCenter(phenotype).x, y-getCenter(phenotype).y);
    if (geno) {
      String genotype = getFormula(true, 1);
      //textFont(roboto);
      textFont(workSans);
      textSize(pg.height*0.008);
      //textAlign(LEFT, TOP);
      //float genotypeTextW = textWidth(genotype);
      //int nRows = ceil(genotypeTextW/pg.height*0.98);
      //String genotypeDisplay = addLineBreaksToText(genotype, pg.height*0.98, nRows);
      //int nRows = ceil(genotypeTextW/(pg.height*0.7));

      //String genotypeDisplay = addLineBreaksToText(genotype, pg.height*0.7);
      //String genotypeDisplay = addLineBreaksToText(genotype, pg.width*0.96);
      //String genotypeDisplay = addLineBreaksToText(genotype, pg.width*0.6);
      String genotypeDisplay = addLineBreaksToText(genotype, pg.width*0.8);
      //pg.textFont(roboto);
      pg.textFont(workSans);
      pg.textSize(pg.height*0.008);
      //pg.textAlign(LEFT, TOP);
      pg.textAlign(LEFT, BOTTOM);
      pg.fill(0);
      //pg.pushMatrix();
      //pg.translate(pg.width*0.01, pg.height*0.99);
      //pg.rotate(-PI/2);
      //pg.text(genotypeDisplay, 0, 0);
      pg.text(genotypeDisplay, pg.width*0.02, pg.height);
      //pg.text(genotypeDisplay, pg.width*0.01, pg.height*1.005);
      //
      //float auxW = pg.width*0.1;
      //float auxH = (logo.height*auxW)/logo.width;
      //pg.shape(logo, pg.width*0.89, pg.height*0.006, auxW, auxH);
      //
      pg.textFont(workSansBold);
      pg.textSize(pg.height*0.02);
      pg.textAlign(RIGHT, TOP);
      //pg.text("tyfe", pg.width*0.99, pg.height*0.01);
      //
      for (int i=0; i<lines.length; i++) {
        pg.text(lines[i], pg.width*0.98, pg.height*0.02*i + pg.height*0.01);
      }
      //pg.popMatrix();
    }
    pg.endDraw();
  }

  PGraphics getPhenotypeImage(PApplet parent, int w, int h, int margin) {
    if (image == null || image.width != w || image.height != h) {
      image = null;
      image = createPGraphicsWithDefaultPixelDensity(w, h, JAVA2D); // modified my tiagofm
      image.beginDraw();
      image.background(bgColorPoster);
      drawPhenotype(parent, image, w / 2, h / 2, w, h, margin, false);
      image.endDraw();
    }
    return image;
  }

  void exportPhenotypePDF(PApplet parent, int w, int h, int margin) {
    String output_filename = year() + "-" + nf(month(), 2) + "-" + nf(day(), 2) + "/" +
      year() + "-" + nf(month(), 2) + "-" + nf(day(), 2) + "_" +
      nf(hour(), 2) + "-" + nf(minute(), 2) + "-" + nf(second(), 2);
    String output_path = sketchPath("outputs/" + output_filename);
    println("Exporting individual to: " + output_path);

    PGraphics png = createPGraphicsWithDefaultPixelDensity(w, h, JAVA2D);
    drawPhenotype(parent, png, w / 2, h / 2, w, h, margin, true);
    png.save(output_path + ".png");
    PGraphics png2 = createPGraphicsWithDefaultPixelDensity(w, h, JAVA2D);
    drawPhenotype(parent, png2, w / 2, h / 2, w, h, margin, false);
    png2.save(output_path + "_1.png");

    //PGraphics pdf = createGraphics(w, h, PDF, output_path + ".pdf");
    PGraphics pdf = createPGraphicsWithDefaultPixelDensity(w, h, PDF, output_path + ".pdf"); // modified my tiagofm
    pdf.beginDraw();
    drawPhenotype(parent, pdf, w / 2, h / 2, w, h, margin, true);
    pdf.dispose();
    pdf.endDraw();

    PGraphics pdf2 = createPGraphicsWithDefaultPixelDensity(w, h, PDF, output_path + "_1.pdf"); // modified my tiagofm
    pdf2.beginDraw();
    drawPhenotype(parent, pdf2, w / 2, h / 2, w, h, margin, false);
    pdf2.dispose();
    pdf2.endDraw();

    saveStrings(output_path + ".txt", new String[]{getString(false, 3), "\n", getFormula(true, 2)});
  }
}
