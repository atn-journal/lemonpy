#!/usr/bin/env python3

print("Cálculo de iones a agregar a un sistema antes de su minimización.\n")

M = float(input("Ingrese la molaridad deseada:\n"))  # En M (mol/litro)

N = 6.02214076 * 10 ** 23  # Número de avogadro
dH2O = 997                 # Densidad del H2O en g/L
mH2O = 18.02               # PM del H2O en g/mol

ion_L = M * N              # Moles de ion a agregar a un litro de solución de concentración M
H2O_L = dH2O / mH2O * N    # Moles de agua en un litro

H2O_s = int(input("Ingrese la cantidad de moléculas de agua en la simulación:\n"))  # Indicado por tLEaP al solvatar

ion_s = ion_L * H2O_s / H2O_L  # Simple regla de tres

print(f"Deben agregarse {ion_s:.0f} unidades de cada ion.")
