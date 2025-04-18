# Evolving Typographic Compositions

We developed an Interactive Evolutionary System to generate typographic compositions. The system evolves sequences of operations that are then applied to text to create the compositions. Besides the main program, we also created a complementary tool to edit the resulting compositions from the main system. The exported compositions can be found in the `outputs` folder of the program files.

![System's Interface](Interface.png)

*Interface of the Evolutionary System*

## Installation

To run our program in your machine you must follow these steps:

1. Download and Install Processing through the official website: [processing.org](https://processing.org/)
2. Install Library dependencies
3. Clone the repository or download ZIP
4. Locate the program folder you want to open (EvolutionaryTypeComp or Editor)
5. Open the main `.pde` file of the program you want to use (`EvolutionaryTypeComp.pde` or `Editor.pde`)
6. Run the Sketch

## Using the system

To use the system more easily, read this section.

### Interacting with the system

You can do the following things through the interface of the system:

1. Change the minimum and maximum number of operations in a composition
2. Turn on or off each operation
3. Change the number of compositions in each population
4. Change the recombination and mutation probabilities
5. Evaluate each composition
6. Evolve or reset the population
7. Change the text in the compositions using the keyboard

### Change Font

To change the font used in the compositions you should follow these steps:

1. Download the `.ttf` file of the desired font from [Google Fonts](https://fonts.google.com/)
2. Add the file to the Sketch data folder
3. Add the file name to the fonts Array inside the code

```java
String[] fonts = {
"RobotoMono-Regular.ttf",
"IBMPlexSerif-Regular.ttf",
"RobotoMono-Thin.ttf",
"IBMPlexSerif-Thin.ttf",
"RobotoMono-Bold.ttf",
"IBMPlexSerif-Bold.ttf"
};
```

1. Open `config.json` file (which is inside the Sketch data folder) and change the `fontNo` variable to the corresponding position of the font you added to the Array

### Change Composition’s Resolution

To change the resolution of the compositions being evolved you can open `config.json` file (which is inside the Sketch data folder) and change the `proportions`. `w` for the composition’s width and `h` for the height. 

### Import Evolved Composition to Editor

To import an evolved composition to the Editor you should follow these steps:

1. Locate the exported composition in the `outputs` folder of the Evolutionary system
2. Locate the `.txt` file that contains the genotype
3. Copy the first genotype, the one of the type `[flip 0,566 0,368][repeat 0,223 0,844 0,014 0,358 0,354 0,318][rotate 0,627]`
4. Open the Editor and paste the genotype inside the first element of the Array `file` 
5. Run the program

## Dependencies

The system uses the library [Geomerative](https://github.com/rikrd/geomerative) to retrieve the outlines of the text. To install this library through the Processing Library Manager:

1. Open Processing
2. Go to `Sketch` → `Import Library` → `Add Library`
3. Search for `Geomerative` and click `Install`
