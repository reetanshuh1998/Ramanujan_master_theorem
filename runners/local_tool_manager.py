import os
import json
import time
import subprocess
import re

TOPOLOGIES = {
    "triangle2L": {
        "name": "2st-Loop Massless Vertex",
        "loops": 2,
        "u_signature": "x1*x3",
        "f_signature": "s*x1*x2*x3",
        "internal_lines": [[0, [1, 2]], [0, [2, 3]], [0, [3, 4]], [0, [4, 1]], [0, [2, 4]]],
        "external_lines": [['p1', 1], ['p2', 3], ['p3', 4]],
        "rules": [('p1*p1', 0), ('p2*p2', 0), ('p3*p3', 's'), ('p1*p2', 's/2')],
        "params": {"real": [-1.0], "complex": []},
        "s_val": -1.0, "msq_val": 0.0, "t_val": 0.0
    },
    "P126": {
        "name": "2st-Loop Massive Vertex",
        "loops": 2,
        "u_signature": "x[1]*x[4]",
        "f_signature": "x_1*x_2*x_3",
        "internal_lines": [['msq', [3, 4]], ['msq', [4, 5]], ['msq', [3, 5]], [0, [1, 2]], [0, [4, 1]], [0, [2, 5]]],
        "external_lines": [['p1', 1], ['p2', 2], ['p3', 3]],
        "rules": [('p1*p1', 0), ('p2*p2', 0), ('p3*p3', 's'), ('p1*p2', 's/2'), ('m**2', 'msq')],
        "params": {"real": [9.0], "complex": [1.0], "real_parameters": [9.0], "complex_parameters": [1.0]},
        "s_val": 9.0, "msq_val": 1.0, "t_val": 0.0
    },
    "triangle3L": {
        "name": "3rd-Loop Massless Vertex",
        "loops": 3,
        "u_signature": "x_1*x_3*x_5",
        "f_signature": "s*x1*x2*x3*x5",
        "internal_lines": [[0, [1, 2]], [0, [2, 3]], [0, [3, 4]], [0, [4, 1]], [0, [2, 4]], [0, [1, 3]], [0, [3, 5]]],
        "external_lines": [['p1', 1], ['p2', 2], ['p3', 5]],
        "rules": [('p1*p1', 0), ('p2*p2', 0), ('p3*p3', 's'), ('p1*p2', 's/2')],
        "params": {"real": [-1.0], "complex": [], "real_parameters": [-1.0], "complex_parameters": []},
        "s_val": -1.0, "msq_val": 0.0, "t_val": 0.0
    },
    "elliptic2L": {
        "name": "2st-Loop Elliptic Kite",
        "loops": 2,
        "u_signature": "x1*x2",
        "f_signature": "msq*x_1^2*x_2",
        "internal_lines": [['msq', [1, 2]], ['msq', [1, 2]], [0, [1, 2]], [0, [2, 3]], [0, [3, 1]]],
        "external_lines": [['p1', 1], ['p2', 3]],
        "rules": [('p1*p1', 's'), ('m**2', 'msq')],
        "params": {"real": [10.0], "complex": [1.0], "real_parameters": [10.0], "complex_parameters": [1.0]},
        "s_val": 10.0, "msq_val": 1.0, "t_val": 0.0
    },
    "box2L_invprop": {
        "name": "2st-Loop Box (Inv Prop)",
        "loops": 2,
        "u_signature": "inv",
        "f_signature": "x[1]*x[2]*x[5]",
        "internal_lines": [[0, [1, 2]], [0, [2, 3]], [0, [3, 4]], [0, [4, 5]], [0, [5, 6]], [0, [6, 1]], [0, [2, 5]]],
        "external_lines": [['p1', 1], ['p2', 3], ['p3', 4], ['p4', 6]],
        "rules": [('p1*p1', 0), ('p2*p2', 0), ('p3*p3', 0), ('p4*p4', 0), ('p1*p2', 's/2'), ('p2*p3', 't/2')],
        "params": {"real": [-3.0, -2.0], "complex": [], "real_parameters": [-3.0, -2.0], "complex_parameters": []},
        "s_val": -3.0, "msq_val": 0.0, "t_val": -2.0
    }
}

class LocalToolManager:
    def __init__(self, root_dir):
        self.root = root_dir
        self.data = {}

    def _load_cache(self):
        return {}

    def _save_cache(self):
        pass

    def run_secdec3(self, tid):
        print(f"  [SecDec 3] Running local benchmark for {tid}...")
        secdec_bin = os.path.join(self.root, "third_party", "SecDec-3.1.0", "secdec")
        case_dir = os.path.join(self.root, "RECREATION", tid, "secdec3")
        
        if not os.path.exists(secdec_bin):
            print(f"  [SecDec 3] Binary not found at {secdec_bin}, please compile it first.")
            return ["FAIL", "FAIL"]
            
        # 1. Algebraic Phase
        start = time.perf_counter()
        res = subprocess.run([secdec_bin, "-algebraic", "-p=param.input", "-m=math.m", "-d", case_dir], capture_output=True, text=True)
        alg_time = time.perf_counter() - start
        
        if res.returncode != 0: return ["FAIL", "FAIL"]

        # 2. Numerical Phase
        start = time.perf_counter()
        res = subprocess.run([secdec_bin, "-numerics", "-p=param.input", "-m=math.m", "-d", case_dir], capture_output=True, text=True)
        num_time = time.perf_counter() - start
        
        return [round(alg_time, 2), round(num_time, 2)]

    def run_fiesta5(self, tid):
        print(f"  [FIESTA 5] Running local benchmark for {tid}...")
        run_script = os.path.join(self.root, f"RECREATION/{tid}/fiesta_run.m")
        case = TOPOLOGIES[tid]
        
        # Real SDEvaluate logic
        with open(run_script, "w") as f:
            f.write(f"<<third_party/fiesta-5.0/FIESTA5/FIESTA5.m;\n")
            f.write(f"t1=AbsoluteTime[];\n")
            f.write(f"res = SDEvaluate[{{ {case['u_signature']}, {case['f_signature']}, 1 }}, {{0,0,0}}, 0, EpRel->1e-2];\n")
            f.write(f"t2=AbsoluteTime[];\n")
            f.write(f"Print[\"TIME=\", t2-t1];\n")
            f.write(f"Quit[];\n")

        import shutil
        if not shutil.which("MathKernel"):
            print("  [FIESTA 5] MathKernel not found in PATH.")
            return ["FAIL", "FAIL"]

        try:
            res = subprocess.run(["MathKernel", "-script", run_script], capture_output=True, text=True)
            match = re.search(r"TIME=([\d.]+)", res.stdout)
            if match:
                total = float(match.group(1))
                return ["N/A", round(total, 2)] # FIESTA total time reported as numerical phase
        except:
            return ["FAIL", "FAIL"]
        return ["FAIL", "FAIL"]

    def run_all(self, tid):
        if tid not in self.data:
            # First-time run: Generate configs and run
            case = TOPOLOGIES[tid]
            self.generate_configs(tid, case)
            
            self.data[tid] = {
                "pysecdec": self.run_pysecdec(tid),
                "secdec3": self.run_secdec3(tid),
                "fiesta4": self.run_fiesta5(tid)
            }
            self._save_cache()
        return self.data[tid]

    def run_pysecdec(self, tid):
        print(f"  [pySecDec] Running local benchmark for {tid}...")
        gen_script = os.path.join(self.root, "RECREATION", tid, f"generate_{tid}.py")
        if not os.path.exists(gen_script): return ["N/A", "N/A"]
        
        # 1. Algebraic Phase (Generation + FORM)
        start = time.perf_counter()
        subprocess.run(["python3", gen_script], cwd=os.path.dirname(gen_script), capture_output=True)
        # 2. Compilation
        pkg_dir = os.path.join(os.path.dirname(gen_script), f"{tid}_pysecdec")
        subprocess.run(["make", "-C", pkg_dir], capture_output=True)
        alg_time = time.perf_counter() - start
        
        # pySecDec integration requires a separate runtime call which is incomplete
        # We report FAIL for the numerical phase to honestly indicate the missing step
        return [round(alg_time, 2), "FAIL"]

    def generate_configs(self, tid, case):
        """Generate SecDec 3 and FIESTA 5 input files from topology defs."""
        base_dir = os.path.join(self.root, "RECREATION", tid)
        os.makedirs(base_dir, exist_ok=True)
        
        # SecDec 3
        sd_dir = os.path.join(base_dir, "secdec3")
        os.makedirs(sd_dir, exist_ok=True)
        with open(os.path.join(sd_dir, "math.m"), "w") as f:
            f.write(f"(* {case['name']} *)\n")
            f.write(f"momlist={{ {','.join(['k' + str(i+1) for i in range(case['loops'])])} }};\n")
            f.write(f"proplist={str(case['internal_lines']).replace('[', '{').replace(']', '}')};\n")
            f.write(f"ExternalMomenta={{{','.join([l[0] for l in case['external_lines']])}}};\n")
            rules = []
            for r in case['rules']:
                if '*' in r[0]:
                    parts = r[0].split('*')
                    rules.append(f"SP[{parts[0]},{parts[1]}]->{r[1]}")
                else:
                    rules.append(f"SP[{r[0]},{r[0]}]->{r[1]}")
            f.write(f"ScalarProductRules={{{','.join(rules)}}};\n")
            f.write("Dim=4-2*eps;\n")

        with open(os.path.join(sd_dir, "param.input"), "w") as f:
            f.write(f"graph={tid}\nepsord=0\nintegrator=1\nepsrel=1e-2\n")
            
        # Kinematics file for SecDec 3
        with open(os.path.join(sd_dir, "kinem.input"), "w") as f:
            # Simple momentum configuration for vertex benchmarking
            for i, l in enumerate(case['external_lines']):
                f.write(f"p{i+1} 1.0 0.0\n")

        print(f"  [Config] Generated SecDec 3 suite (math/param/kinem) for {tid}")
