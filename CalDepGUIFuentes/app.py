import streamlit as st
import minizinc
from datetime import timedelta
from MiniZincInstance import MiniZincInstance
# def format_matrix(matrix):
#     formatted_matrix = "["
#     for row in matrix:
#         formatted_row = ", ".join(str(e) for e in row)
#         formatted_matrix += f"| {formatted_row} "
#     formatted_matrix += "|]"
#     return formatted_matrix


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
        selected_option = st.selectbox("Selecciona un solver",['chuffed','gecode','api','cbc','coin-bc','coinbc','cp', 'cplex', 'experimental', 'findmus',
                                                                'float', 'gecode', 'gist', 'globalizer', 'gurobi', 'highs', 'int', 
                                                                'lcg', 'mip', 'org.chuffed.chuffed', 'org.gecode.gecode',
                                                                  'org.gecode.gist', 'org.minizinc.findmus', 'org.minizinc.globalizer',
                                                                    'org.minizinc.mip.coin-bc', 'org.minizinc.mip.cplex', 'org.minizinc.mip.gurobi',
                                                                      'org.minizinc.mip.highs', 'org.minizinc.mip.scip', 'org.minizinc.mip.xpress',
                                                                        'osicbc', 'restart', 'scip', 'set', 'tool', 'xpress'])
        st.write("Has seleccionado:", selected_option)
        
        # result = MiniZincInstance()
        # st.write("El resultado es:", result)

        st.text_area("Resultado: ", height=15,value= MiniZincInstance(selected_option,n,Min,Max,D),disabled=True)
        # st.text(f"n = {n}")
        # st.text(f"Min = {Min}")
        # st.text(f"Max = {Max}")
        # st.text("D = ")
        # for row in D:
        #     st.text(row)
        

if __name__ == "__main__":
    main()