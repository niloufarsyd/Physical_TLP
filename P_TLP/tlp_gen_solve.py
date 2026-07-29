##This is multiple times Gen and Solve using a PUF device connected via serial port.
import matplotlib.pyplot as plt

from tlp_gen import tlp_gen_rs_device 
from tlp_solve import tlp_solve_rs_device
from puf_bridge import PUFDevice
from GEN_SOL_RS import solution_equality
import numpy as np, math, time, sys

# # === 1) Connect to PUF Device ===
# dev = PUFDevice("COM4", baudrate=1_000_000)
# print("Connected to PUF device on COM4")

# === 2) Generate Puzzle Once ===
N       = 3000       # number of rounds
B       = 15000
lambda_ = 64
num_runs = 10
m       = 40

# D_p     = 0.001
D_p     = 0.0005
D_mode  = "geometric"
tau     = 0.2
q_bits  = max(math.ceil(math.log2(B)), math.ceil(math.log2(N + 2*m + 1)))
print(q_bits)
# Random secrets
# S = [''.join(str(b) for b in np.random.randint(0, 2, 128)) for _ in range(3)]


solve_times = []
info_histories = []
total_tries_runs = []
gen_times = []
FN_all=[]
FP_all=[]
print("\n--- Independent Puzzle Generation + Solving Runs ---")

for r in range(num_runs):
    print(f"\n=== Run {r+1}/{num_runs} ======================================")

    # --- Step 1: Generate fresh secrets and connect device ---
    dev_gen = PUFDevice("COM4", baudrate=1_000_000)
    S = [''.join(str(b) for b in np.random.randint(0, 2, 128)) for _ in range(3)]

    print("[Gen] Starting puzzle generation ...")
    t1 = time.perf_counter_ns()
    Z, H, k_vec = tlp_gen_rs_device(N, B, lambda_, q_bits, m, S,
                             eval_device=dev_gen, D_mode=D_mode, D_p=D_p)
    t2 = time.perf_counter_ns()
    t_gen = (t2 - t1) / 1e9
    gen_times.append(t_gen)
    # print(f"[Gen] Done in {t_gen:.3f}s | Parity symbols: {H['parity']}")
    print(f"[Gen] Done in {t_gen:.3f}s ")
    # Cleanly close generation port
    if hasattr(dev_gen, "flush"):
        dev_gen.flush()
    dev_gen.close()
    time.sleep(0.4)

    # --- Step 2: Solve puzzle ---
    dev_solve = PUFDevice("COM4", baudrate=1_000_000)
    print("[Solve] Starting puzzle solving ...")

    t3 = time.perf_counter_ns()
    S_recovered, info, FN, FP_byRS, k_hat, k_rec = tlp_solve_rs_device(
        Z, H, tau=tau,
        eval_device=dev_solve,
        baudrate=1_000_000,
        verbose=False,
        run_id=r+1
    )
    t4 = time.perf_counter_ns()
    t_sol = (t4 - t3) / 1e9

    diff_indices = np.where(k_hat != k_vec)[0]

    for i in diff_indices:
        print(f"Index {i}: k_hat = {k_hat[i]}, k_rec = {k_vec[i]}")
    FP= max(0, len(diff_indices) - FN)
    print(f"[Solve] FN={FN}, FP={FP} (byRS={FP_byRS})")

    # Cleanup solver UART
    if hasattr(dev_solve, "flush"):
        dev_solve.flush()
    try:
        dev_solve.serial.reset_input_buffer()
        dev_solve.serial.reset_output_buffer()
    except Exception:
        pass
    dev_solve.close()

    # --- Step 3: Store metrics ---
    total_tries = sum(info["tries_hist"])
    total_tries_runs.append(total_tries)
    solve_times.append(t_sol)
    FN_all.append(FN)
    FP_all.append(FP)

    print(f"[Solve] Duration: {t_sol:.3f}s | Total tries: {total_tries} | Mean tries/round: {total_tries / N:.2f}")

    if solution_equality(S, S_recovered):
        print("✅ Puzzle solved correctly.")
    else:
        print("❌ Puzzle not solved correctly!")
    
    np.savez(f"K_results_N{N}_B{B}_run{r}_of_{num_runs}runs.npz",
         N=N, B=B, D_p=D_p, D_mode=D_mode,
         k_vec=k_vec,
         k_hat=k_hat,
         k_rec=k_rec,
         FN=FN,
         FP=FP)

    sys.stdout.flush()
    time.sleep(0.4)
# dev.close()

## ==========Theoretical analysis:=====
print("\n--- Theoretical Analysis: ---")
p=D_p
x=1-D_p
norm = 1 - x**B
theo_mean = ((x - B*x**B + (B-1)*x**(B+1)) / (p * norm))
E2 = ((1-p)*(2-p) - x**B * (B*p*(1-p) + 2 - p)) / (p**2 * norm)
theo_var = E2 - theo_mean**2
print(f"Theoretical mean E[k]: {theo_mean:.1f}, E[T]: {N*(1+theo_mean):.1f}")
print(f"Theoretical std[K]: {np.sqrt(theo_var):.1f},std[T]:{np.sqrt(N*theo_var):.1f}")


# === 5) Summary ===
T_mean = np.mean(total_tries_runs)
T_std  = np.std(total_tries_runs)
print("\n--- Summary Across Runs ---")
# print("FN_all : ", FN_all)
# print("FP_all : ", FP_all)
print(f"Average gen time:  {np.mean(gen_times):.2f}s ± {np.std(gen_times):.2f}")
print(f"Average solving time: {np.mean(solve_times):.2f}s ± {np.std(solve_times):.2f}")
print(f"Average total PUF invocations: {T_mean:.1f} ± {T_std:.1f}")
print(f"Tries per round (avg over runs): {np.mean([np.mean(t) for t in total_tries_runs]):.2f}")
print(f"Average FN per run: {np.mean(FN_all):.3f}")
print(f"Average FP per run: {np.mean(FP_all):.3f}")
print(f"Relative variation (σ/μ): {T_std/T_mean:.4f}")



## === 6) Optional: Save Data for Plotting ===
np.savez(f"multi_independentRuns_results_N{N}_B{B}_runs{num_runs}.npz",
         N=N, B=B, D_p=D_p, D_mode=D_mode,
         solve_times=solve_times,
         total_tries_runs=total_tries_runs,
         info_histories=info_histories,
         FN_all=FN_all, FP_all=FP_all)

print("\n Experiment finished. Results saved successfully.")
print(f"Mean total PUF invocations: {np.sum(total_tries_runs)/num_runs:.1f}")
plt.figure(figsize=(7,4))
plt.hist(total_tries_runs, bins=10, color='tab:blue', edgecolor='black', alpha=0.7)
plt.axvline(T_mean, color='r', linestyle='--', label=f"Mean={T_mean:.0f}")
plt.axvline(T_mean+T_std, color='g', linestyle=':', label=f"+1σ={T_mean+T_std:.0f}")
plt.axvline(T_mean-T_std, color='g', linestyle=':')
plt.title("Distribution of Total Solving Time (PUF Invocations)")
plt.xlabel("Total PUF Invocations per Solve Run")
plt.ylabel("Frequency")
plt.legend()
plt.grid(True, alpha=0.5)
plt.show()

###This is "one" time Puzzle generation and multiple solving runs using a PUF device connected via serial port.
# import matplotlib.pyplot as plt

# from tlp_gen import tlp_gen_rs_device 
# from tlp_solve import tlp_solve_rs_device
# from puf_bridge import PUFDevice
# from GEN_SOL_RS import solution_equality
# import numpy as np, math, time, sys

# # === 1) Connect to PUF Device ===
# dev = PUFDevice("COM4", baudrate=1_000_000)
# print("Connected to PUF device on COM4")

# # === 2) Generate Puzzle Once ===
# N       = 100       # number of rounds
# B       = 1000
# lambda_ = 64
# num_runs = 1
# m       = 10
# D_p     = 0.001
# # D_p     = 0.0005
# D_mode  = "geometric"
# tau     = 0.2
# q_bits  = max(math.ceil(math.log2(B)), math.ceil(math.log2(N + 2*m + 1)))

# # Random secrets
# S = [''.join(str(b) for b in np.random.randint(0, 2, 128)) for _ in range(3)]

# print("--- Puzzle Generation ---")
# t1 = time.perf_counter_ns()
# Z, H = tlp_gen_rs_device(N, B, lambda_, q_bits, m, S,
#                          eval_device=dev, D_mode=D_mode, D_p=D_p)
# t2 = time.perf_counter_ns()
# t_gen = (t2 - t1) / 1e9
# print(f"Gen Time = {t_gen:.3f}s")

# print("Parity symbols:", H["parity"])
# dev.close()  # Close generation device
# time.sleep(0.5)
# # === 3) Solve Multiple Times ===

# solve_times = []
# tries_histories = []
# info_histories = []
# total_tries_runs = []

# FN_all=[]
# FP_all=[]
# print("\n--- Multiple Solve Runs -----------------------------------------")
# for r in range(num_runs):
#     print(f"\n=== Solve Run {r+1}/{num_runs} =========================")
#     dev_run = PUFDevice("COM4", baudrate=1_000_000)
#     time.sleep(0.2)  # let UART stabilize
#     t3 = time.perf_counter_ns()
#     S_recovered, info, FN, FP = tlp_solve_rs_device(Z, H, tau=tau,
#                                             eval_device=dev_run,
#                                             baudrate=1_000_000,
#                                             verbose=False,    # suppress per-round prints
#                                             run_id=r+1)
#     t4 = time.perf_counter_ns()
#     t_sol = (t4 - t3)/ 1e9
#     # Safely flush & close COM
#     if hasattr(dev_run, "flush"):
#         dev_run.flush()
#     try:
#         dev_run.serial.reset_input_buffer()
#         dev_run.serial.reset_output_buffer()
#     except Exception:
#         pass
#     dev_run.close()
#     time.sleep(0.3)

#     FN_all.append(FN)
#     FP_all.append(FP)

#     total_tries = sum(info["tries_hist"])
#     avg_tries   = total_tries / N
#     tries_mean  = np.mean(info["tries_hist"])
#     tries_std   = np.std(info["tries_hist"])

#     # Store results
#     solve_times.append(t_sol)
#     tries_histories.append(info["tries_hist"])
#     info_histories.append(info)
#     total_tries_runs.append(total_tries)

#     print(f"Solving duration: {t_sol:.6f}s")
#     # print("Stats:", info)
#     print(f"Total PUF invocations: {total_tries}, avg/round: {avg_tries:.2f}")
#     print(f"PUF invoc. mean={tries_mean:.2f}, std={tries_std:.2f}")

#     if solution_equality(S, S_recovered):
#         print("✅ Solved solution matches locked solution.")

#     else:
#         print("❌ Solved solution does NOT match locked solution!")

#     sys.stdout.flush()
#     time.sleep(0.5)
# # === 4) Close Device ===
# # dev.close()
# T_mean = np.mean(total_tries_runs)
# T_std  = np.std(total_tries_runs)
# # === 5) Summary ===
# print("\n--- Summary Across Runs ---")
# print("FN_all : ", FN_all)
# print("FP_all : ", FP_all)
# print(f"Average solving time: {np.mean(solve_times):.2f}s ± {np.std(solve_times):.2f}")
# print(f"Mean total PUF invocations: {T_mean:.1f} ± {T_std:.1f}")
# print(f"Tries per round (avg over runs): {np.mean([np.mean(t) for t in tries_histories]):.2f}")
# print(f"Theoretical std: {np.sqrt(N*(1-D_p)/(D_p**2)):.1f}")
# print(f"Relative variation (σ/μ): {T_std/T_mean:.4f}")

# print(f"Average FN per run: {np.mean(FN_all):.3f}")
# print(f"Average FP per run: {np.mean(FP_all):.3f}")

# ## === 6) Optional: Save Data for Plotting ===
# np.savez(f"multi_GenSolveRun_results_N{N}_B{B}_runs{num_runs}.npz",
#          N=N, B=B, D_p=D_p, D_mode=D_mode,
#          solve_times=solve_times,
#          total_tries_runs=total_tries_runs,
#          info_histories=info_histories,
#          FN_all=FN_all, FP_all=FP_all)

# print("\n Experiment finished. Results saved successfully.")
# print(f"Mean total PUF invocations: {np.sum(total_tries_runs)/num_runs:.1f}")
# plt.figure(figsize=(7,4))
# plt.hist(total_tries_runs, bins=10, color='tab:blue', edgecolor='black', alpha=0.7)
# plt.axvline(T_mean, color='r', linestyle='--', label=f"Mean={T_mean:.0f}")
# plt.axvline(T_mean+T_std, color='g', linestyle=':', label=f"+1σ={T_mean+T_std:.0f}")
# plt.axvline(T_mean-T_std, color='g', linestyle=':')
# plt.title("Distribution of Total Solving Time (PUF Invocations)")
# plt.xlabel("Total PUF Invocations per Solve Run")
# plt.ylabel("Frequency")
# plt.legend()
# plt.grid(True, alpha=0.5)
# plt.show()
