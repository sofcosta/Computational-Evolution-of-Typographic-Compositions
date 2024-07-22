// ============================================= Useful functions to use operations

static Op getOperationByName(Op[] ops, String name) {
  for (Op op : ops) {
    if (op.name.equals(name)) {
      return op;
    }
  }
  System.err.println("Invalid operation name: " + name);
  return null;
}

static Op getOperationByIndex(Op[] ops, float index) {
  return ops[(int) index];
}

static PShape applyOperation(Op[] ops, String name, PApplet parent, PShape input, float[] params) {
  return getOperationByName(ops, name).apply(parent, input, params);
}

static String[] getOperationsNames(Op[] ops) {
  String[] names = new String[ops.length];
  for (int i = 0; i < ops.length; i++) {
    names[i] = ops[i].name;
  }
  return names;
}

static int getOpNumParamsByName(Op[] ops, String name) {
  return getOperationByName(ops, name).getNumParams();
}

static int getOpNumParamsByIndex(Op[] ops, float index) {
  return getOperationByIndex(ops, index).getNumParams();
}

// ============================================= Operations implementation

abstract class Op {
  String name;
  String[] paramNames;
  float[] min;
  float[] max;

  Op(String name, String[] paramNames, float[] min, float[] max) {
    this.name = name;
    assert paramNames.length == min.length;
    assert min.length == max.length;
    this.paramNames = new String[paramNames.length];
    this.min = new float[min.length];
    this.max = new float[max.length];
    System.arraycopy(paramNames, 0, this.paramNames, 0, paramNames.length);
    System.arraycopy(min, 0, this.min, 0, min.length);
    System.arraycopy(max, 0, this.max, 0, max.length);
  }

  String getOpName() {
    return name;
  }

  int getNumParams() {
    return min.length;
  }

  float getMin(int indexParam) {
    return min[indexParam];
  }

  float getMax(int indexParam) {
    return max[indexParam];
  }

  float parseParam(int paramIndex, float normalisedValue) {
    return map(normalisedValue, 0, 1, min[paramIndex], max[paramIndex]);
  }

  float[] parseParams(float[] normalisedValues) {
    float[] realValues = new float[normalisedValues.length];
    for (int i=0; i<normalisedValues.length; i++) {
      realValues[i] = map(normalisedValues[i], 0, 1, min[i], max[i]);
    }
    return realValues;
  }

  void loadLimitsFromJSON(JSONObject json) {
    JSONObject jsonOps = json.getJSONObject("operations_params");
    if (jsonOps.hasKey(name)) {
      JSONObject jsonOp = jsonOps.getJSONObject(name);
      for (int indexParam = 0; indexParam < paramNames.length; indexParam++) {
        JSONObject jsonParam = jsonOp.getJSONObject(paramNames[indexParam]);
        min[indexParam] = jsonParam.getFloat("min");
        max[indexParam] = jsonParam.getFloat("max");
      }
    } else {
      println("Operation '" + name + "' not found in JSON.");
    }
  }

  abstract PShape apply(PApplet parent, PShape shape, float[] params);
}


class OpTranslate extends Op {
  OpTranslate() {
    super("translate", new String[]{"x", "y"}, new float[]{-5, -5}, new float[]{5, 5});
  }
  PShape apply(PApplet parent, PShape input, float[] params) {
    PShape output = MyPShape.getCopy(parent, input);
    PVector shapeSize = getDimensions(output);
    float moveX = params[0] * shapeSize.x;
    float moveY = params[1] * shapeSize.y;
    PVector aux = new PVector(0, 0);
    for (int i=0; i<output.getChildCount(); i++) {
      for (int j=0; j<output.getChild(i).getVertexCount(); j++) {
        aux = output.getChild(i).getVertex(j);
        output.getChild(i).setVertex(j, aux.x + moveX, aux.y + moveY);
      }
    }
    return output;
  }
}

class OpRotate extends Op {
  OpRotate() {
    super("rotate", new String[]{"ang"}, new float[]{0}, new float[]{TWO_PI});
  }
  PShape apply(PApplet parent, PShape input, float[] params) {
    PShape output = MyPShape.getCopy(parent, input);
    float angle = params[0];
    for (int i=0; i<output.getChildCount(); i++) {
      for (int j=0; j<output.getChild(i).getVertexCount(); j++) {
        PVector aux = output.getChild(i).getVertex(j);
        output.getChild(i).setVertex(j, (aux.x * cos(angle))+(aux.y * sin(angle)), (aux.x * -sin(angle))+(aux.y * cos(angle)));
      }
    }
    return output;
  }
}

class OpScale extends Op {
  OpScale() {
    super("scale", new String[]{"x", "y"}, new float[]{0.1, 0.1}, new float[]{3, 3});
  }
  PShape apply(PApplet parent, PShape input, float[] params) {
    PShape output = MyPShape.getCopy(parent, input);
    float scaleX = params[0];
    float scaleY = params[1];
    for (int i=0; i<output.getChildCount(); i++) {
      for (int j=0; j<output.getChild(i).getVertexCount(); j++) {
        PVector aux = output.getChild(i).getVertex(j);
        output.getChild(i).setVertex(j, aux.x * scaleX, aux.y * scaleY);
      }
    }
    return output;
  }
}

class OpFlip extends Op {
  OpFlip() {
    super("flip", new String[]{"x", "y"}, new float[]{-1, -1}, new float[]{1, 1});
  }
  PShape apply(PApplet parent, PShape input, float[] params) {
    PShape output = MyPShape.getCopy(parent, input);
    float flipX = params[0];
    float flipY = params[1];
    for (int i=0; i<output.getChildCount(); i++) {
      for (int j=0; j<output.getChild(i).getVertexCount(); j++) {
        PVector aux = output.getChild(i).getVertex(j);
        if (flipX<0 && flipY>=0) {
          output.getChild(i).setVertex(j, aux.x * -1, aux.y * 1);
        } else if (flipX>=0 && flipY<0) {
          output.getChild(i).setVertex(j, aux.x * 1, aux.y * -1);
        } else {
          output.getChild(i).setVertex(j, aux.x * -1, aux.y * -1);
        }
      }
    }
    return output;
  }
}

class OpSkew extends Op {
  OpSkew() {
    super("skew", new String[]{"x", "y"}, new float[]{-PI/2, -PI/2}, new float[]{PI/2, PI/2});
  }
  PShape apply(PApplet parent, PShape input, float[] params) {
    PShape output = MyPShape.getCopy(parent, input);
    float angleX = params[0];
    float angleY = params[1];
    for (int i=0; i<output.getChildCount(); i++) {
      for (int j=0; j<output.getChild(i).getVertexCount(); j++) {
        PVector aux = output.getChild(i).getVertex(j);
        output.getChild(i).setVertex(j, aux.x + (aux.y * sin(angleX)), (aux.x * sin(angleY)) + aux.y);
      }
    }
    return output;
  }
}

class OpRepeat extends Op {
  OpRepeat() {
    super("repeat", new String[]{"n", "tx", "ty", "sx", "sy", "ang"},
      new float[]{1, -1, -1, 0.1, 0.1, 0}, new float[]{11, 1, 1, 3, 3, TWO_PI});
  }

  //PShape apply(PApplet parent, PShape input, float[] params) {
  //  PShape output = MyPShape.getCopy(parent, input);
  //  float times = params[0];
  //  float stepX = params[1];
  //  float stepY = params[2];
  //  PShape shapeAux = MyPShape.getCopy(parent, input);
  //  for (int i=0; i<times; i++) {
  //    shapeAux = applyOperation(operations, "translate", parent, shapeAux, new float[]{stepX, stepY});
  //    for (int j=0; j<shapeAux.getChildCount(); j++) {
  //      output.addChild(shapeAux.getChild(j));
  //    }
  //  }
  //  return output;
  //}

  //PShape apply(PApplet parent, PShape input, float[] params) {
  //  PShape output = MyPShape.getCopy(parent, input);
  //  float times = params[0];
  //  float stepX = params[1];
  //  float stepY = params[2];
  //  float auxOp = params[3];
  //  float auxParam1 = params[4];
  //  float auxParam2 = params[5];
  //  PShape shapeAux = MyPShape.getCopy(parent, input);
  //  for (int i=0; i<times; i++) {
  //    if (auxOp < 1) {
  //      auxParam1 = map(auxParam1, 0, 1, 0.1, 3);
  //      auxParam2 = map(auxParam2, 0, 1, 0.1, 3);
  //      shapeAux = applyOperation(operations, "scale", parent, shapeAux, new float[]{auxParam1, auxParam2});
  //    } else if (auxOp >= 1 && auxOp < 2) {
  //      auxParam1 = map(auxParam1, 0, 1, 0, TWO_PI);
  //      shapeAux = applyOperation(operations, "rotate", parent, shapeAux, new float[]{PI/10});
  //    }
  //    shapeAux = applyOperation(operations, "translate", parent, shapeAux, new float[]{stepX, stepY});
  //    for (int j=0; j<shapeAux.getChildCount(); j++) {
  //      output.addChild(shapeAux.getChild(j));
  //    }
  //  }
  //  return output;
  //}

  PShape apply(PApplet parent, PShape input, float[] params) {
    PShape output = MyPShape.getCopy(parent, input);
    float times = round(params[0]);
    float stepX = params[1];
    float stepY = params[2];
    float scaleX = params[3];
    float scaleY = params[4];
    float rotateAng = params[5];
    PShape shapeAux = MyPShape.getCopy(parent, input);
    for (int i=0; i<times; i++) {
      shapeAux = applyOperation(operations, "scale", parent, shapeAux, new float[]{scaleX, scaleY});
      shapeAux = applyOperation(operations, "rotate", parent, shapeAux, new float[]{rotateAng});
      shapeAux = applyOperation(operations, "translate", parent, shapeAux, new float[]{stepX, stepY});
      for (int j=0; j<shapeAux.getChildCount(); j++) {
        output.addChild(shapeAux.getChild(j));
      }
    }
    return output;
  }
}

class OpMisalign extends Op {
  OpMisalign() {
    super("misalign", new String[]{"amp"}, new float[]{0}, new float[]{1});
  }
  PShape apply(PApplet parent, PShape input, float[] params) {
    PShape output = MyPShape.getCopy(parent, input);
    PVector shapeSize = getDimensions(output);
    float amplitude = params[0] * shapeSize.y;
    float[] auxMa = {0, -0.25, 0.25, 0, -0.5, -0.25, 0.5, 0.25, -0.25, 0};
    for (int i=0; i<output.getChildCount(); i++) {
      for (int j=0; j<output.getChild(i).getVertexCount(); j++) {
        PVector aux = output.getChild(i).getVertex(j);
        output.getChild(i).setVertex(j, aux.x, aux.y + auxMa[i%auxMa.length] * amplitude);
      }
    }

    return output;
  }
}

class OpDistort extends Op {
  OpDistort() {
    super("distort", new String[]{"p", "amp"}, new float[]{0.01, 1}, new float[]{0.1, 50});
  }
  PShape apply(PApplet parent, PShape input, float[] params) {
    PShape output = MyPShape.getCopy(parent, input);
    float period = params[0];
    float amplitude = params[1];
    for (int i=0; i<output.getChildCount(); i++) {
      for (int j=0; j<output.getChild(i).getVertexCount(); j++) {
        PVector aux = output.getChild(i).getVertex(j);
        output.getChild(i).setVertex(j, aux.x + amplitude * sin(aux.y * period), aux.y);
      }
    }
    return output;
  }
}

class OpFill extends Op {
  OpFill() {
    super("fill", new String[]{"r", "g", "b", "a"}, new float[]{0, 0, 0, 100}, new float[]{255, 255, 255, 255});
  }
  PShape apply(PApplet parent, PShape input, float[] params) {
    PShape output = MyPShape.getCopy(parent, input);
    for (int i=0; i<output.getChildCount(); i++) {
      output.getChild(i).setFill(color(params[0], params[1], params[2], params[3]));
    }
    return output;
  }
}

class OpStroke extends Op {
  OpStroke() {
    super("stroke", new String[]{"r", "g", "b", "a"}, new float[]{0, 0, 0, 100}, new float[]{255, 255, 255, 255});
  }
  PShape apply(PApplet parent, PShape input, float[] params) {
    PShape output = MyPShape.getCopy(parent, input);
    for (int i=0; i<output.getChildCount(); i++) {
      output.getChild(i).setStroke(true);
      output.getChild(i).setStroke(color(params[0], params[1], params[2], params[3]));
    }
    return output;
  }
}

// NOT WORKING -> can't remove points from PShape
class OpCrop extends Op {
  OpCrop() {
    super("crop", new String[]{"",""}, new float[]{0, 0}, new float[]{1, 1});
  }

  PShape apply(PApplet parent, PShape input, float[] params) {
    PShape output = MyPShape.getCopy(parent, input);
    PVector shapeSize = getDimensions(output);
    PVector shapeCenter = getCenter(output);
    float posX = params[0] * shapeSize.x;
    float posY = params[1] * shapeSize.y;
    PVector aux = new PVector(shapeCenter.x - shapeSize.x/2, shapeCenter.y - shapeSize.y/2);
    PShape auxShape1 = createShape(PShape.PATH);
    auxShape1.beginShape();
    auxShape1.fill(255);
    auxShape1.noStroke();
    auxShape1.vertex(aux.x + posX, aux.y - 10);
    auxShape1.vertex(aux.x + shapeSize.x, aux.y - 10);
    auxShape1.vertex(aux.x + shapeSize.x, aux.y + shapeSize.y + 10);
    auxShape1.vertex(aux.x + posX, aux.y + shapeSize.y + 10);
    auxShape1.endShape(CLOSE);
    //RECT, posX, shapeCenter.y - shapeSize.y/2, shapeCenter.x + shapeSize.x/2, shapeCenter.y + shapeSize.y/2);
    output.addChild(auxShape1);
    return output;
  }
}
