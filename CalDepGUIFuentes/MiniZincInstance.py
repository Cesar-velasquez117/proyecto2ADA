import minizinc
from datetime import timedelta


def MiniZincInstance():
    with open('CalDep.mzn', 'r') as f:
        minizinc_code = f.read()

    model = minizinc.Model()
    model.add_string(minizinc_code)

    solver = minizinc.Solver.lookup("gecode")

    instance = minizinc.Instance(solver, model)

    result = instance.solve(
                    timeout=timedelta(minutes=2)
    )
    
    return result