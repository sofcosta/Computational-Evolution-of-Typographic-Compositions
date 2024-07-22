class Population {

  Individual[] individuals;
  int generations;
  PApplet parent;

  Population(PApplet parent) {
    this.parent = parent;
    individuals = new Individual[population_size];
    initialize();
  }

  void initialize() {
    individuals = null;
    individuals = new Individual[population_size];
    for (int i = 0; i < individuals.length; i++) {
      individuals[i] = new Individual(operations, minOperations, maxOperations);
    }

    for (int i = 0; i < individuals.length; i++) {
        individuals[i].randomise(parent);
        individuals[i].setFitness(0);
    }

    generations = 0;
  }

  //void changePopulationSize(int newPopulationSize) {
  //  if (newPopulationSize < individuals.length) {
  //    int nAux = individuals.length - newPopulationSize;
  //    for (int i=0; i<nAux; i++) {
  //      individuals = (Individual[])shorten(individuals);
  //      fitnessSlider[newPopulationSize+i] = null;
  //    }
  //  } else if (newPopulationSize > individuals.length) {
  //    int nAux = newPopulationSize - individuals.length;
  //    int oldPopulationSize = individuals.length;
  //    println(nAux);
  //    for (int i=0; i<nAux; i++) {
  //      individuals = (Individual[])append(individuals, new Individual(operations, minOperations, maxOperations));
  //    }
  //    for (int i=0; i<nAux; i++) {
  //      individuals[oldPopulationSize+i].randomise(parent);
  //      individuals[oldPopulationSize+i].setFitness(0);
  //    }
  //    println("added individuals");
  //  }
  //}

  void evolve() {
    //Individual[] new_generation = new Individual[individuals.length];
    Individual[] new_generation = new Individual[population_size];
    sortIndividualsByFitness();
    // Copies best individuals to next generation
    for (int i = 0; i < elite_size; i++) {
      new_generation[i] = individuals[i].getCopy();
    }
    // Crossover without changing elite
    for (int i = elite_size; i < new_generation.length; i++) {
      if (random(1) <= crossover_rate) {
        Individual parent1 = tournamentSelection();
        Individual parent2 = tournamentSelection();
        new_generation[i] = parent1.crossover(parent, parent2);
      } else {
        new_generation[i] = tournamentSelection().getCopy();
      }
    }
    // Mutates without changing elite
    for (int i = elite_size; i < new_generation.length; i++) {
      new_generation[i].mutate(parent);
    }
    // Alters the size of individuals array
    if (population_size < individuals.length) {
      int nAux = individuals.length - population_size;
      for (int i=0; i<nAux; i++) {
        individuals = (Individual[])shorten(individuals);
      }
    } else if (population_size > individuals.length) {
      for (int i=individuals.length; i<population_size; i++) {
        individuals = (Individual[])append(individuals, null);
      }
    }
    // Copies the new_generation to individuals and sets fitness to zero
    for (int i = 0; i < individuals.length; i++) {
      individuals[i] = new_generation[i];
    }
    for (int i = 0; i < individuals.length; i++) {
      individuals[i].setFitness(0);
    }
    // Adds 1 to generations
    generations++;
  }

  Individual tournamentSelection() {
    Individual[] tournament = new Individual[tournament_size];
    for (int i = 0; i < tournament.length; i++) {
      int random_index = int(random(0, individuals.length));
      tournament[i] = individuals[random_index];
    }
    Individual fittest = tournament[0];
    for (int i = 1; i < tournament.length; i++) {
      if (tournament[i].getFitness() > fittest.getFitness()) {
        fittest = tournament[i];
      }
    }
    return fittest;
  }

  void sortIndividualsByFitness() {
    Arrays.sort(individuals, new Comparator<Individual>() {
      public int compare(Individual indiv1, Individual indiv2) {
        return Float.compare(indiv2.getFitness(), indiv1.getFitness());
      }
    }
    );
  }

  Individual getIndiv(int index) {
    return individuals[index];
  }

  int getSize() {
    return individuals.length;
  }

  int getGenerations() {
    return generations;
  }
}
