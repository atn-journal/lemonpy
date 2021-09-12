# pmemd

## Minimization

Minimizing the system with 25 kcal/mol restraints on PROTEIN, 500 steps of steepest descent and 2000 of conjugated gradient  # Título o comentarios, sin límite de líneas
  &cntrl  # Siempre requerido, inicia bloque de código. Todo el bloque debe tener al menos un espacio antes
    imin=1,  # Indica que se realice (1) o no (0, default) minimización
    ntx=1,  # Lectura de solo coordenadas (1, default) o también velocidades (5) desde el archivo de coordenadas
    irest=0,  # Reanudar (1) o no (0, default) una simulación anterior. Si es 0, se reestablece el tiempo y no se leen velocidades
    ntxo=2,  # Formato de .rst de salida, ASCII (1) o NetCDF (2, default)
    ntpr=50,  # Cada cuántos steps se guarda la información de energía en mdout y mdinfo (default 50)
    ntf=1, pág 364
    ntb=1,
    cut=9.0,
    nsnb=10,
    ntr=1,
    maxcyc=2500,
    ncyc=2000,
    ntmin=1,
    restraintmask=':1-644',
    restraint_wt=25.0,
  /
  &ewald
    ew_type = 0,
    skinnb = 1.0,
  /

## Heating

Heating the system with 5 kcal/mol restraints on PROTEIN, V=const
  &cntrl
    imin=0,
    ntx=1,
    ntpr=500,
    ntwr=500,
    ntwx=500,
    ntwe=500,
    nscm=5000,
    ntf=2,
    ntc=2,
    ntb=1,
    ntp=0,
    nstlim=50000,
    t=0.0,
    dt=0.002,
    cut=9.0,
    tempi=100.0,
    ntt=1,
    ntr=1,
    nmropt=1,  # NMR restraints and weight changes will be read. No tendría que ser 0?
    restraintmask=':1-644',
    restraint_wt=5.0,
  /
  &wt
    type='TEMP0',
    istep1=0,
    istep2=5000,
    value1=100.0,
    value2=300.0,
  /
  &wt
    type='TEMP0',
    istep1=5001,
    istep2=50000,
    value1=300.0,
    value2=300.0,
  /
  &wt type='END',
  /

## Equilibration

Equilibrating the system during 5000 ps at constant T=300 K, P=1 ATM and coupling=0.2
  &cntrl
    imin=0,
    ntx=5,
    ntpr=500,
    ntwr=500,
    ntwx=500,
    ntwe=500,
    nscm=5000,
    ntf=2,
    ntc=2,
    ntb=2,
    ntp=1,
    tautp=0.2,
    taup=0.2,
    nstlim=250000,
    t=0.0,
    dt=0.002,
    cut=9.0,
    ntt=1,
    ntr=0,
    irest=1,
  /

## Production

Molecular dynamics production of 50 ns
  &cntrl
    imin=0,
    ntx=5,
    ntpr=500,
    ntwr=500,
    ntwx=500,
    ntwe=500,
    nscm=5000,
    ntf=2,
    ntc=2,
    ntb=2,
    ntp=1,
    tautp=5.0,
    taup=5.0,
    nstlim=25000000,
    t=0.0,
    dt=0.002,
    cut=9.0,
    ntt=1,
    irest=1,
    iwrap=1,
    ioutfm=1,
  /
  &ewald
    ew_type=0,
    skinnb=1.0,
  /
  