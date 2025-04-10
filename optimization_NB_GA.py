import random
from scipy.stats import norm
import math

def evaluate_loss(N, B):
    return abs(N - round(N)) + abs(B - round(B))

def generate_parameters():
    # Generate random values for lambda, h, t, tau
    #lambda_ = random.uniform(1, 100)
    #h = random.uniform(0.1, 10)
    t = random.uniform(10, 100)
    tau = random.uniform(10**(-17), 10**(-16))
    e=random.uniform(t/36500, t/18250)
    p=random.uniform(0.95, 1)
    #p=0.999
    h = -norm.ppf((1 - p) / 2)
    # t=100
    # tau=0.000000000000000317
    # e=1/365

    # Compute N and B based on some assumed functional relationship
    N = 4 * h**2 * t**2 / (3 * e**2)
    B = 3 * e**2 / (2 * h**2 * t * tau)
    return N, B

def genetic_algorithm(population_size, generations):
    population = [generate_parameters() for _ in range(population_size)]
    print("N & B  ", population)
    for generation in range(generations):
        # Evaluate the population
        scored_population = [(evaluate_loss(N, B), N, B) for N, B in population]
        scored_population.sort()  # Sort by loss
        # Select the best to reproduce (simple selection)
        top_performers = scored_population[:population_size//2]
        # Crossover and mutation
        new_population = []
        while len(new_population) < population_size:
            parent1, parent2 = random.sample(top_performers, 2)
            child1_N = (parent1[1] + parent2[1]) / 2
            child1_B = (parent1[2] + parent2[2]) / 2
            # Mutation: slightly alter N and B
            child1_N += random.uniform(-1, 1)
            child1_B += random.uniform(-1, 1)
            new_population.append((child1_N, child1_B))
        population = new_population
        
        print(f"Generation {generation}, Best Loss: {top_performers[0][0]}")
    return top_performers[0]

# Run the genetic algorithm
best_parameters = genetic_algorithm(population_size=100, generations=50)
print("Optimized loss:", best_parameters[0])
print("Best Fit N:", best_parameters[1], "=2^", math.log2(best_parameters[1]))
print("Best Fit B:", best_parameters[2], "=2^", math.log2(best_parameters[2]))
print(f"The log2(NB) = {math.log2(best_parameters[1]*best_parameters[2])}")