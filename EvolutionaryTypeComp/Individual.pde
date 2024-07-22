class Individual { //<>//

  ArrayList<float[]> genes = new ArrayList<float[]>();
  PShape phenotype = null;
  float fitness = 0;
  PGraphics image = null;
  PGraphics validationCanvas = null;

  Op[] ops;
  int minOps;
  int maxOps;

  Individual(Op[] ops, int minOps, int maxOps) {
    this.ops = ops;
    this.minOps = minOps;
    this.maxOps = maxOps;
  }

  Individual() {
    this(operations, minOperations, maxOperations);
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

  void randomise(PApplet parent) {
    int numOps = int(random(minOps, maxOps + 1));  // Determine number of operations

    for (int attempt = 0; attempt < nAttempts; attempt++) {
      genes.clear();  // Clear existing genes
      // Create genes
      for (int o = 0; o < numOps; o++) {
        int indexRandomOp = int(random(ops.length));
        while (opActive[indexRandomOp] == false) {
          indexRandomOp = int(random(ops.length));
        }
        float[] groupOfGenes = new float[1 + ops[indexRandomOp].getNumParams()];
        groupOfGenes[0] = indexRandomOp;
        for (int g = 1; g < groupOfGenes.length; g++) {
          groupOfGenes[g] = random(0, 1);
        }
        genes.add(groupOfGenes);
      }
      //println("attempt: "+ attempt);
      if (validIndiv(parent)) {
        break;
      }
    }
  }

  Individual crossover(PApplet parent, Individual partner) {
    Individual child = new Individual();
    Individual parent1 = getCopy();
    Individual parent2 = partner.getCopy();
    for (int attempt = 0; attempt < nAttempts; attempt++) {
      int crossover_point1 = int(random(1, parent1.genes.size()));
      int crossover_point2 = int(random(1, parent2.genes.size()));
      for (int i = 0; i < crossover_point1; i++) {
        child.genes.add(parent1.genes.get(i));
      }
      for (int i = crossover_point2; i < parent2.genes.size(); i++) {
        child.genes.add(parent2.genes.get(i));
      }
      //println("attempt crossover: "+ attempt);
      //println("parent 1: " + parent1.getString(false,1));
      //println("parent 2: " + parent2.getString(false,1));
      //println();
      if (child.validIndiv(parent)) {
        //println("----------------------------------------");
        return child;
      } else {
        child = new Individual();
      }
    }
    child.image = null;
    return parent1.getCopy();
  }

  void mutate(PApplet parent) {
    Individual aux = getCopy();
    for (int attempt = 0; attempt < nAttempts; attempt++) {
      for (int i = 0; i < genes.size(); i++) {
        for (int j = 0; j < genes.get(i).length; j++) {
          if (random(1) <= mutation_rate) {
            if (j == 0) {
              // Check if randomised op is active
              int newOperation = int(random(ops.length));
              while (opActive[newOperation] == false) {
                newOperation = int(random(ops.length));
              }
              genes.get(i)[j] = newOperation;
              //println(getOperationByIndex(ops, newOperation).name);
              int numParams = getOpNumParamsByIndex(operations, newOperation);
              if (genes.get(i).length-1 != numParams) {
                float[] currValues = new float[genes.get(i).length];
                for (int k = 0; k < currValues.length; k++) {
                  currValues[k] = genes.get(i)[k];
                }
                genes.set(i, new float[numParams + 1]);
                for (int k = 0; k < numParams + 1; k++) {
                  if (k < currValues.length) {
                    genes.get(i)[k] = currValues[k];
                  } else {
                    genes.get(i)[k] = random(0, 1);
                  }
                }
              }
              assert genes.get(i).length == numParams + 1;
            } else {
              genes.get(i)[j] = constrain(genes.get(i)[j] + random(-0.1, 0.1), 0, 1);
            }
          }
        }
      }
      //println("attempt mutation: "+ attempt);
      //println(genes.size());
      if (!validIndiv(parent)) {
        genes = aux.genes;
        continue;
      } else {
        break;
      }
    }
    image = null;
  }

  boolean validIndiv(PApplet parent) {
    //println(genes.size() + " > " + maxOperations + " = " + (genes.size() > maxOperations));
    //println(getString(false, 1));
    if (genes.size() < minOperations || genes.size() > maxOperations) {
      return false;
    } else {
      calculatePhenotype(parent, pShape);
      if (validationCanvas == null) {
        validationCanvas = createGraphics(validationSize, validationSize);
      }
      validationCanvas.beginDraw();
      validationCanvas.clear();
      validationCanvas.background(bgColorPoster);
      drawPhenotype(parent, validationCanvas, validationSize*0.5, validationSize*0.5, validationSize, validationSize, 0, false);
      validationCanvas.endDraw();
      float perc = getPercentageOfNonBackgroundPixels(validationCanvas, bgColorPoster);
      //println("percentage: " + perc);
      if (perc > 0.05) {
        //println("valid");
        return true;
      } else {
        //println("invalid");
        return false;
      }

      //image.loadPixels();
      //int nBgPix = 0, nColorPix = 0;
      //// Tem de depender do número de operações médio, menor número de operações normalmente indica menos pixels
      ////float minColorPix = constrain(1000 * (float(maxOperations + minOperations)/2), 2000, 7000);
      //float minColorPix = image.pixels.length*0.001;
      //for (int i=0; i<image.pixels.length; i++) {
      //  if (image.pixels[i] == bgColorPoster) {
      //    nBgPix++;
      //  } else {
      //    //if (saturation(image.pixels[i]) < 25.5 || brightness(image.pixels[i]) > 229.5) {
      //    //  nBgPix++;
      //    //} else {
      //    nColorPix++;
      //    //}
      //  }
      //  if (nColorPix > minColorPix) break;  // Para acelerar um pouco o processo
      //}
      //println(image.pixels.length, nBgPix, nColorPix);
      //if (nColorPix > minColorPix) {
      //return true;
      //} else {
      //  return false;
      //}
    }
  }

  void setFitness(float fitness) {
    this.fitness = fitness;
  }

  float getFitness() {
    return fitness;
  }

  // Gets genotype as array of arrays
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

  // Gets human readable formula
  String getFormulaOld(boolean parseParams, int decimalDigits) {
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
      text = currOp.name + "(" + text;
      for (int g = 1; g < genes.get(o).length; g++) {
        text += ", " + currOp.paramNames[g-1] + "=";
        if (parseParams) {
          text += nf(currOp.parseParam(g - 1, genes.get(o)[g]), 0, decimalDigits).replace(',', '.');
        } else {
          text += nf(genes.get(o)[g], 0, decimalDigits).replace(',', '.');
        }
      }
      text += ")";
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
          if (genes.get(o)[0] == 4 || genes.get(o)[0] == 6 || (genes.get(o)[0] == 3 && g == 6)) {  // Degrees
            auxOp += int(degrees(currOp.parseParam(g - 1, genes.get(o)[g]))) + ", ";
          } else if (genes.get(o)[0] == 3 && g == 1 || genes.get(o)[0] == 8 || genes.get(o)[0] == 9) {  // int
            auxOp += int(currOp.parseParam(g - 1, genes.get(o)[g])) + ", ";
          } else if (genes.get(o)[0] == 0 && g == 1) {
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
    //println(getFormula(true, 0));
    // Call sequence of operations to generate final shape, and keep in memory
    phenotype = MyPShape.getCopy(parent, shape);
    // Center shape (it is initialised aligned to the left and bottom)
    phenotype = applyOperation(operations, "translate", parent, phenotype, new float[]{-0.5, -0.5});
    //println(genes.size());
    for (int i=0; i<genes.size(); i++) {
      float opIndex = genes.get(i)[0];
      Op currOp = getOperationByIndex(ops, opIndex);
      float[] params = new float[getOpNumParamsByIndex(operations, opIndex)];
      for (int j=1; j<genes.get(i).length; j++) {
        params[j-1] = currOp.parseParam(j-1, genes.get(i)[j]);
      }
      phenotype = applyOperation(operations, currOp.name, parent, phenotype, params);
    }
    //println("No. operations: " + genes.size());
    //println(getString(false, 2));
  }

  void drawPhenotype(PApplet parent, PGraphics pg, float x, float y, float maxW, float maxH, float margin, boolean geno) {
    if (phenotype == null) {
      println("Phenotype null");
      return;
    }
    margin = margin*2;
    //pg.beginDraw();
    //pg.background(bgColorPoster);
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
      textFont(work_sans);
      if (pg.height > pg.width) {
        textSize(pg.height*0.008);
      } else {
        textSize(pg.width*0.008);
      }
      //float genotypeTextW = textWidth(genotype);
      //int nRows = ceil(genotypeTextW/pg.height*0.98);
      //String genotypeDisplay = addLineBreaksToText(genotype, pg.height*0.98, nRows);
      //int nRows = ceil(genotypeTextW/(pg.height*0.7));
      //String genotypeDisplay = addLineBreaksToText(genotype, pg.height*0.7, nRows);
      String genotypeDisplay = addLineBreaksToText(genotype, pg.width*0.8);
      pg.textFont(work_sans);
      if (pg.height > pg.width) {
        pg.textSize(pg.height*0.008);
      } else {
        pg.textSize(pg.width*0.008);
      }
      pg.textAlign(LEFT, BOTTOM);
      pg.fill(0);
      pg.text(genotypeDisplay, pg.height*0.015, pg.height);
      pg.textFont(work_sans_bold);
      pg.textAlign(RIGHT, TOP);
      if (pg.height > pg.width) {
        pg.textSize(pg.height*0.02);
        for (int i=0; i<lines.length; i++) {
          pg.text(lines[i], pg.width-pg.height*0.01, pg.height*0.02*i + pg.height*0.01);
        }
      } else {
        pg.textSize(pg.width*0.02);
        for (int i=0; i<lines.length; i++) {
          pg.text(lines[i], pg.width-pg.height*0.01, pg.width*0.02*i + pg.width*0.01);
        }
      }
      //pg.pushMatrix();
      //pg.translate(pg.width*0.01, pg.height*0.99);
      //pg.rotate(-PI/2);
      //pg.text(genotypeDisplay, 0, 0);
      //pg.popMatrix();
    }
    //pg.endDraw();
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
    png.beginDraw();
    png.background(bgColorPoster);
    drawPhenotype(parent, png, w / 2, h / 2, w, h, margin, true);
    png.endDraw();
    png.save(output_path + ".png");

    PGraphics png2 = createPGraphicsWithDefaultPixelDensity(w, h, JAVA2D);
    png2.beginDraw();
    png2.background(bgColorPoster);
    drawPhenotype(parent, png2, w / 2, h / 2, w, h, margin, false);
    png2.endDraw();
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
