import random
from scipy.stats import norm
import math
import cma
import numpy as np

def evaluate_loss(N, B):
    return abs(N - round(N)) + abs(B - round(B))

def generate_parameters():
    p = 0.999
    h = -norm.ppf((1 - p) / 2)
    t = random.uniform(1, 100)
    tau = random.uniform(10**(-17), 10**(-16))
    e = random.uniform(t/100, t/50)

    N = 4 * h**2 * t**2 / (3 * e**2)
    B = 3 * e**2 / (2 * h**2 * t * tau)
    return N, B

def objective_function(params):
    N, B = params
    return evaluate_loss(N, B)

def run_cma_es(N, B, max_iterations):
    initial_params = [N, B]  # Example initial guesses for N and B
    options = {'maxiter': max_iterations, 'bounds': [1, 10000000000000000000], 'seed': 1234}
    es = cma.CMAEvolutionStrategy(initial_params, 0.5, options)
    es.optimize(objective_function)
    # Access the best solution after the optimization
    best_solution = es.result.xbest  # Best solution found
    best_value = es.result.fbest  # Objective value of the best solution
    return best_solution, best_value

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


[N, B]=generate_parameters()

def test_algorithm(algorithm, config):
    objective_values = []
    parameter_values = []
    for _ in range(config['runs']):
        if algorithm == 'GA':
            loss, N, B = genetic_algorithm(config['population_size'], config['generations'])
        elif algorithm == 'CMA-ES':
            n, b =generate_parameters()
            best_solution, best_value = run_cma_es(n, b, config['max_iterations'])
            loss = best_value
            N, B = best_solution

        objective_values.append(loss)
        parameter_values.append((N, B))

    return np.array(objective_values), np.array(parameter_values)

# Configuration for fair comparison
config = {
    'runs': 30,
    'population_size': 100,
    'generations': 50,
    'max_iterations': 50  # Set to match GA generations for comparison
}

# Run tests
ga_objective_values, ga_parameters = test_algorithm('GA', config)
cmaes_objective_values, cmaes_parameters = test_algorithm('CMA-ES', config)

# Analyze results
print("GA Objective Values:", ga_objective_values)
print("GA Parameter Values:", ga_parameters)
print("CMA-ES Objective Values:", cmaes_objective_values)
print("CMA-ES Parameter Values:", cmaes_parameters)

print("GA Average Loss:", np.mean(ga_objective_values))
print("CMA-ES Average Loss:", np.mean(cmaes_objective_values))