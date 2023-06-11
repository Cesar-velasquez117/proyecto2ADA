import streamlit as st
import minizinc
from datetime import timedelta

# def format_matrix(matrix):
#     formatted_matrix = "["
#     for row in matrix:
#         formatted_row = ", ".join(str(e) for e in row)
#         formatted_matrix += f"| {formatted_row} "
#     formatted_matrix += "|]"
#     return formatted_matrix

def MiniZincInstance(n,min,max,D):
    with open('CalDep.mzn', 'r') as f:
        minizinc_code = f.read()

    string_params = f"n = {n};\n"
    string_params += f"Min = {min};\n"
    string_params += f"Max = {max};\n"
    string_params += "D = " + D + ";\n"

    minizinc_code = string_params + minizinc_code

    model = minizinc.Model()
    model.add_string(minizinc_code)

    solver = minizinc.Solver.lookup("chuffed")

    instance = minizinc.Instance(solver, model)

    result = instance.solve(
                    timeout=timedelta(minutes=2)
    )
    
    return result

# def generate_dzn_file(n, Min, Max, D):
#     dzn_code = f"n = {n};\n"
#     dzn_code += f"Min = {Min};\n"
#     dzn_code += f"Max = {Max};\n"
#     dzn_code += f"D = array2d(1..{n}, 1..{n}, {D});\n"

#     with open('DatosCalDep.dzn', 'w') as f:
#         f.write(dzn_code)

def main():
    st.title("Calendario de Torneos Deportivos")

    # Widget para seleccionar el archivo de entrada
    input_file = st.file_uploader("Seleccionar archivo de entrada")
    
    if input_file is not None:
        lines = input_file.readlines()

        n = int(lines[0].strip())
        Min = int(lines[1].strip())
        Max = int(lines[2].strip())
        # D = []
        # for line in lines[3:]:
        #     # Dividir la línea en elementos individuales
        #     elements = line.strip().split()
        #     # Convertir los elementos en enteros si es necesario
        #     row = [int(e) for e in elements]
        #     # Agregar la lista interna a la lista principal
        #     D.append(row)
        D = ""

        for i, line in enumerate(lines[3:]):
            # Dividir la línea en elementos individuales
            elements = line.strip().split()
            # Convertir los elementos en enteros si es necesario
            row = [int(e) for e in elements]
            # Agregar la lista interna a la lista principal
            formatted_row = ", ".join(str(e) for e in row)
            
            if i == 0:
                D += f"[| {formatted_row} "
            elif i == len(lines) - 4:
                D += f"| {formatted_row} |]"
            else:
                D += f"| {formatted_row} "

        # generate_dzn_file(n, Min, Max, D)
        st.text_area("Información obtenida del archivo:",value= f"n = {n} \n" + f"Min = {Min} \n" + f"Max = {Max} \n" + f"D = {D}", height=30,disabled=True )
        selected_option = st.selectbox("Selecciona un solver",["gecode","chuffed","or-tools","cbc","glpk"])
        st.write("Has seleccionado:", selected_option)
        
        # result = MiniZincInstance()
        # st.write("El resultado es:", result)
        print("n:",n)
        print("Min:",Min)
        print("Max:",Max)
        print("D:",D)
        print("f",MiniZincInstance("4","1","2","[| 0, 553, 204, 248 | 553, 0, 443, 305 | 204, 443, 0, 138 | 248, 305, 138, 0 |]"))
        st.text_area("Resultado: ", height=15,value= MiniZincInstance(n,Min,Max,D),disabled=True)
        # st.text(f"n = {n}")
        # st.text(f"Min = {Min}")
        # st.text(f"Max = {Max}")
        # st.text("D = ")
        # for row in D:
        #     st.text(row)
        

if __name__ == "__main__":
    main()