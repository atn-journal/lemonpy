# lemonpy

[addionsrand](addionsrand.py)  
Calcula cuántos iones agregar a un sistema solvatado en función de el número de moléculas de agua presentes y la molaridad deseada.  

[MDsteps](MDsteps.py)  
Calcula cuántos steps deben solicitarse para realizar una dinámica de X ns, dado un step de Y fs.

[minimize](minimize.sh)  
Realiza la minimización energética en tres pasos de un sistema solvatado.

[MutSeq](MutSeq.py)  
Solicita ingreso de una secuencia aminoacídica, posición a mutar y aa nuevo. Se pueden ingresar varias posiciones individuales. Da como salida las secuencias mutadas en formato FASTA.  

[process-cpptraj](process-cpptraj.sh)  
Procesa una trayectoria .nc eliminando una de cada diez frames. Centra la proteína en la caja y remueve aguas e iones. Procesa también el .prmtop y finalmente carga los datos en VMD.
