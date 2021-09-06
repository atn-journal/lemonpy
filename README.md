# lemonpy

[addionsrand](addionsrand.py)  
Calcula cuántos iones agregar a un sistema solvatado en función del número de moléculas de agua presentes y la molaridad deseada.  

[MDsteps](MDsteps.py)  
Calcula cuántos steps deben solicitarse para realizar una dinámica de X ns, dado un step de Y fs.

[minimize](minimize.sh)  
Realiza la minimización energética en tres pasos de un sistema solvatado. Muestra los resultados en VMD.

[template.slurm](template.slurm)  
Plantilla para correr MD con script de SLURM.

[strip-traj](strip-traj.sh)  
Procesa una trayectoria .nc eliminando una de cada diez frames. Centra la proteína en la caja y remueve aguas e iones.

[strip-prmtop](strip-prmtop.sh)  
Procesa el archivo de topología para eliminar agua e iones.

[join-traj](join-traj.sh)  
Une trayectorias.

[fas2pir](fas2pir.sh)
Convierte una secuencia FASTA a formato PIR.

[MutSeq](MutSeq.py)  
Solicita ingreso de una secuencia aminoacídica, posición a mutar y aa nuevo. Se pueden ingresar varias posiciones individuales. Da como salida las secuencias mutadas en formato FASTA.  
