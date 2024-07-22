static class MyPShape extends PShape {
  // https://github.com/processing/processing/blob/459853d0dcdf1e1648b1049d3fdbb4bf233fded8/core/src/processing/core/PShape.java#L1446
  static PShape getCopy(PApplet parent, PShape src) {
    //println(src.getFamily());
    return PShape.createShape(parent, src);
  }
}

PShape RShapeToPShape(RShape textImage) {
  PShape textGroup =  createShape(GROUP);
  for (int i=0; i<textImage.children.length; i++) { // Number of letters
    PShape letter = createShape(PShape.PATH);
    letter.beginShape();
    //letter.fill(141, 255, 0);
    for (int j=0; j<textImage.children[i].countPaths(); j++) { // Number of paths for each letter

      RPoint[] points = textImage.children[i].paths[j].getPoints();
      if (j>0) letter.beginContour();
      for (int k=0; k<points.length; k++) {
        letter.vertex(points[k].x, points[k].y);
      }
      if (j>0) letter.endContour();
    }
    letter.endShape(CLOSE);
    //letter.disableStyle();
    textGroup.addChild(letter);
  }
  return textGroup;
}

//PShape RShapeToPShape(RShape textImage) {
//  PShape textGroup =  createShape(GROUP);
//  for (int i=0; i<textImage.children.length; i++) { // Number of letters
//    PShape letter = createShape(PShape.PATH);
//    letter.beginShape();
//    //letter.fill(141, 255, 0);
//    for (int j=0; j<textImage.children[i].countPaths(); j++) { // Number of paths for each letter

//      RPath paths = textImage.children[i].paths[j];
//      if (j>0) letter.beginContour();
//      letter.vertex(paths.commands[0].startPoint.x, paths.commands[0].startPoint.y);

//      for (int k=0; k<paths.commands.length; k++) {
//        RCommand command = paths.commands[k];

//        //RPoint start = command.startPoint;
//        RPoint end = command.endPoint;

//        // check if this line has controlpoints (bezier)
//        if (command.controlPoints != null) {
//          letter.bezierVertex(command.controlPoints[0].x, command.controlPoints[0].y, end.x, end.y, end.x, end.y);
//        } else {
//          letter.vertex(end.x, end.y);
//        }
//      }
//      if (j>0) letter.endContour();
//    }
//    letter.endShape(CLOSE);
//    //letter.disableStyle();
//    textGroup.addChild(letter);
//  }
//  return textGroup;
//}


PVector[] boundingBox(PShape s) {
  PVector topLeft = s.getChild(0).getVertex(0);
  PVector bottomRight = s.getChild(0).getVertex(0);

  for (int i=0; i<s.getChildCount(); i++) {
    for (int j=0; j<s.getChild(i).getVertexCount(); j++) {
      PVector aux = s.getChild(i).getVertex(j);
      if (aux.x < topLeft.x) topLeft.x = aux.x;
      else if (aux.x > bottomRight.x) bottomRight.x = aux.x;
      if (aux.y < topLeft.y) topLeft.y = aux.y;
      else if (aux.y > bottomRight.y) bottomRight.y = aux.y;
    }
  }
  return new PVector[] {topLeft, bottomRight};
}

PVector getDimensions(PShape s) {
  PVector dimensions = new PVector();
  PVector[] bb = boundingBox(s);
  dimensions.x = bb[1].x-bb[0].x;
  dimensions.y = bb[1].y-bb[0].y;
  return dimensions;
}

PVector getCenter(PShape s) {
  PVector center = new PVector();
  PVector[] bb = boundingBox(s);
  center.x = bb[0].x + getDimensions(s).x/2;
  center.y = bb[0].y + getDimensions(s).y/2;
  return center;
}

void changeShapeStyle(PShape s, boolean fillTrue, color fill, boolean strokeTrue, color stroke) {
  for (int i=0; i<s.getChildCount(); i++) {
    if (fillTrue) {
      s.getChild(i).setFill(fill);
    } else {
      s.getChild(i).setFill(false);
    }
    if (strokeTrue) {
      s.getChild(i).setStroke(stroke);
    } else {
      s.getChild(i).setStroke(false);
    }
  }
}
