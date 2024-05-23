>[!WARNING]\
>El plagio o intento de copia de este material en el proyecto de la asignatura de Arquitectura de Computadores impartida por la ETSIINF de la UPM supondrá un suspenso inmediato. Este contenido es únicamente informativo y de uso didáctico, los autores de este proyecto no nos hacemos responsables del mal uso que se le pueda dar al contenido de este repositorio. ([LICENSE](/LICENSE))

# E/S mediante interrupciones
Modulo Entrada/Salida con código ensamblador DUART MC68681

## Autores
[Diego Vigneron Olmos](https://github.com/diegovoos)

[Alejandro Náger Fernández-Calvo](https://github.com/aleexnager)

## Herramientas
El microprocesador MC68000 fue introducido en 1979 y es el primer microprocesador de la familia M68000 de Motorola. Es un procesador CISC, aunque posee un juego de instrucciones muy ortogonal, tiene un bus de datos de 16 bits y un bus de direcciones de 24 bits.  

El MC68000 fue uno de los primeros microprocesadores en introducir un modo de ejecuci´onprivilegiado. Así, las instrucciones se ejecutan en uno de los dos modos posibles:  

**Modo usuario:** este modo proporciona el entorno de ejecuci´on para los programas de aplicación.  
**Modo supervisor:** en este modo se proporcionan algunas instrucciones privilegiadas que no están disponibles en el modo usuario. El software de sistema y el sistema operativo ejecuta en este modo privilegiado.  

## Compilar y ejecutar un programa principal
Para compilar se deben haber seguido las instrucciones del manual para instalar las dependencias.  

Una vez tenemos las dependencias instaladas, podemos ejecutar el programa usando el siguiente comando en la terminal:
```
68kasm -l practica.s
```
Esto va a generar los ficheros: _, _ y por tanto son nuestros ficheros compilados.  

## Manual
[Manual 88110](/doc/Manual88110.pdf)

## Enunciado del proyecto
[Enunciado](/doc/enunciado.pdf)

## Presentación del proyecto
[Presentación](/doc/presentacion.pdf)
