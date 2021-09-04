#!/usr/bin/env python

step_fs = int(input("Ingrese el step en fs:\n"))  # Paso en fs

step_ns = step_fs * 10 ** -6  # Paso en nanosegundos

ns = int(input("Ingrese el tiempo a simular en ns:\n"))  # Tiempo de simulación en nanosegundos)

steps = ns / step_ns

print(f"Deben utilizarse {steps:.0f} steps.")
