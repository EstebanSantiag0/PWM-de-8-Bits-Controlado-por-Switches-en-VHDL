# PWM de 8 Bits Controlado por Switches en VHDL (Práctica 6)

Proyecto en **VHDL** para la tarjeta **Digilent Nexys 2 (FPGA Spartan-3E)** que genera una señal **PWM (modulación por ancho de pulso)** de 8 bits para controlar el **brillo de un LED**. El ciclo de trabajo se elige con los **8 switches** de la tarjeta.

## Tabla de contenido

- [Descripción general](#descripción-general)
- [Hardware objetivo](#hardware-objetivo)
- [Funcionamiento](#funcionamiento)
- [Relación switches → brillo](#relación-switches--brillo)
- [Asignación de pines](#asignación-de-pines)
- [Estructura del repositorio](#estructura-del-repositorio)
- [Cómo compilar y programar](#cómo-compilar-y-programar)
- [Notas y consideraciones](#notas-y-consideraciones)

## Descripción general

Un LED no tiene un "medio encendido": solo prende o apaga. Para que **parezca** que brilla menos, se enciende y apaga muy rápido. La fracción del tiempo que pasa encendido (el **ciclo de trabajo**) determina el brillo que percibe el ojo. Este circuito compara un contador de 8 bits con el valor de los switches para decidir en qué momento encender el LED dentro de cada periodo.

## Hardware objetivo

- **Tarjeta:** Digilent **Nexys 2**
- **FPGA:** Xilinx **Spartan-3E** `xc3s500e-5fg320`
- **Reloj:** 50 MHz (pin B8)
- **Salida:** pin **L15** = conector **Pmod JA, pin 1** (LED externo con su resistencia)
- **Herramienta:** Xilinx ISE Design Suite 14.7
- **Recursos usados:** 29 slices de 4,656 (menos del 1 %)

## Funcionamiento

```
 clk 50 MHz ──► divisor (0…2000) ──► tick ≈ 25 kHz ──► contador triangular 0→255→0 ──┐
                                                                                     ├─► comparador ──► led
 switches(7:0) ──────────────────────────────────────────────────────────────────────┘
```

1. **Divisor:** la variable `rf` cuenta de 0 a 2000. Cada vez que llega al límite se produce un *tick* (≈ 24.99 kHz).
2. **Contador triangular:** en cada tick, `cnt` sube de 0 a 255 (`flag = 0`) y luego baja de 255 a 0 (`flag = 1`). Un periodo completo dura 510 ticks, así que la frecuencia del PWM es de **≈ 49 Hz**.
3. **Comparación:**
   - Al inicio de cada mitad (cuando el contador llega a un extremo) el LED se **apaga**.
   - En la subida, el LED se **enciende** cuando `cnt = switches`.
   - En la bajada, el LED se **enciende** cuando `255 − cnt = switches`.

El resultado es un **PWM centrado (simétrico)**: el pulso encendido queda centrado alrededor del punto máximo del contador.

## Relación switches → brillo

El LED pasa **apagado** los primeros `switches` ticks de cada mitad y **encendido** el resto, por lo que el ciclo de trabajo es aproximadamente:

```
duty ≈ (255 − switches) / 255
```

| `switches` (decimal) | Ciclo de trabajo | Brillo |
|---|---|---|
| 0   | 100 % | Máximo |
| 64  | ≈ 75 % | Alto |
| 128 | ≈ 50 % | Medio |
| 192 | ≈ 25 % | Bajo |
| 255 | 0 % | Apagado |

Es decir, **a mayor valor en los switches, menor brillo**. Los valores se obtuvieron simulando ciclo a ciclo la lógica de `EightBitPWM.vhd`.

## Asignación de pines

Basado en `pines.ucf`:

| Señal | Pin | Ubicación en la Nexys 2 |
|---|---|---|
| `clk` | B8 | Oscilador de 50 MHz |
| `switches<0>` (LSB) | R17 | SW7 (izquierda) |
| `switches<1>` | N17 | SW6 |
| `switches<2>` | L13 | SW5 |
| `switches<3>` | L14 | SW4 |
| `switches<4>` | K17 | SW3 |
| `switches<5>` | K18 | SW2 |
| `switches<6>` | H18 | SW1 |
| `switches<7>` (MSB) | G18 | SW0 (derecha) |
| `led` | L15 | Pmod JA1 (`IOSTANDARD = LVTTL`) |

> Ojo: el bit **menos** significativo está en el switch de la **izquierda** (SW7), al revés de la numeración de la tarjeta.

## Estructura del repositorio

```
Practica6/
├── bin/
│   └── EightBitPWM.bit   # Bitstream listo para programar la Nexys 2
├── EightBitPWM.vhd       # Generador PWM (top)
├── pines.ucf             # Restricciones de pines
└── Practica6.xise        # Proyecto de Xilinx ISE
```

## Cómo compilar y programar

**Solo programar:** carga `bin/EightBitPWM.bit` con **Digilent Adept** o **iMPACT**:

```bash
djtgcfg prog -d Nexys2 -i 0 -f bin/EightBitPWM.bit
```

**Compilar desde el código:**
1. Abre `Practica6.xise` en Xilinx ISE 14.7.
2. Ejecuta **Generate Programming File** (el top es `EightBitPWM`).

Verificado: el proyecto compila desde un clon limpio con ISE 14.7 y cumple todas las restricciones de tiempo.

## Notas y consideraciones

- A ≈ 49 Hz el ojo puede notar un ligero parpadeo con brillos bajos. Para eliminarlo basta con reducir el límite del divisor `rf`: por ejemplo, con 500 el PWM sube a ≈ 196 Hz.
- Si se prefiere que más valor en los switches signifique **más** brillo, basta con invertir la salida (sacar `not led` al pin): el ciclo de trabajo pasa a ser ≈ `switches / 255`.
- La salida usa un pin del conector Pmod, así que se necesita un LED externo con una resistencia en serie (≈ 220–330 Ω) hacia GND.
