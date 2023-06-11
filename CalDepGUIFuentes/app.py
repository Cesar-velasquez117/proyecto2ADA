import streamlit as st
from MiniZincInstance import MiniZincInstance

def main():
    st.title("Calendario de Torneos Deportivos")

    # Widget para seleccionar el archivo de entrada
    input_file = st.file_uploader("Seleccionar archivo de entrada")
    
    if input_file is not None:
        lines = input_file.readlines()

        n = int(lines[0].strip())
        Min = int(lines[1].strip())
        Max = int(lines[2].strip())
        D = []

        for line in lines[3:]:
            row = line.decode().strip().split()
            formatted_row = ", ".join(row)
            D.append(f"[{formatted_row}]")

        st.text_area("Información obtenida del archivo:")
        st.text(f"n = {n}")
        st.text(f"Min = {Min}")
        st.text(f"Max = {Max}")
        st.text("D = ")
        for row in D:
            st.text(row)
        

if __name__ == "__main__":
    main()