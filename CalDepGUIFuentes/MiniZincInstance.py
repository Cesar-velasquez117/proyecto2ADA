import minizinc
from datetime import timedelta

# def format_matrix(matrix):
#     formatted_matrix = "["
#     for row in matrix:
#         formatted_row = ", ".join(str(e) for e in row)
#         formatted_matrix += f"| {formatted_row} "
#     formatted_matrix += "|]"
#     return formatted_matrix

def MiniZincInstance(solver_name,n,min,max,D):
    with open('CalDep.mzn', 'r') as f:
        minizinc_code = f.read()

    string_params = f"n = {n};\n"
    string_params += f"Min = {min};\n"
    string_params += f"Max = {max};\n"
    string_params += "D = " + D + ";\n"

    minizinc_code = string_params + minizinc_code

    model = minizinc.Model()
    model.add_string(minizinc_code)

    solver = minizinc.Solver.lookup(solver_name)

    instance = minizinc.Instance(solver, model)

    result = instance.solve(
                    timeout=timedelta(minutes=2)
    )
    
    return result


#print(MiniZincInstance("4","1","2","[| 0, 553, 204, 248 | 553, 0, 443, 305 | 204, 443, 0, 138 | 248, 305, 138, 0 |]"))