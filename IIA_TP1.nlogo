breed[leoes leao]
breed[hienas hiena]
Globals[nAlimentoPequeno]
turtles-own [energia nAlimento_PequenoPorte nAlimento_GrandePorte ]
hienas-own[agrupamento]
leoes-own[descanso Trap Avoid]

to Setup
  Setup-Patches
  Setup-Turtles
  reset-ticks
end


to Setup-Patches
  clear-all
  set-patch-size 15
  ask patches
  [

    ifelse random 101 < Alimento_PequenoPorte
    [
      set pcolor brown
    ]
    [
      ifelse random 101 < Alimento_GrandePorte
      [
        set pcolor red
      ]
      [
        if Armadilhas = true
        [
        if random 101 <= 1
        [
          set pcolor 52  ;Trap
        ]
        ]
      ]

    ]
  ]
  set nAlimentoPequeno 0
  set nAlimentoPequeno nAlimentoPequeno + count patches with [pcolor = brown]
  let aux 0
  set aux aux + Celulas_Azuis
  while [aux > 0]
    [
      ask one-of patches with [pcolor = black]
      [
        set pcolor blue
        set aux aux - 1
       ]
    ]
end

to Setup-Turtles
  clear-turtles
  let x 0
  create-leoes nLeoes
  [
    set energia 0
    set energia energia + EnergiaInicial
    set Trap 0
    set Avoid 0
    set shape "cat"
    set heading 90
    set color yellow
    set descanso 0
    setxy random-xcor random-ycor
    set x x + count turtles-on patch-here
    while[x > 1 or pcolor != black][
      setxy random-xcor random-ycor
      set x 0
      set x x + count turtles-on patch-here
    ]
  ]
  set x 0
  create-hienas nHienas
  [
    set energia 0
    set agrupamento 0
    set agrupamento agrupamento + 1
    set energia energia + EnergiaInicial
    set shape "wolf"
    set heading 90
    set color white
    setxy random-xcor random-ycor
    set x x + count turtles-on patch-here
    while[x > 1 or pcolor != black][
      setxy random-xcor random-ycor
      set x 0
      set x x + count turtles-on patch-here
    ]
  ]
end

to Go
  Check-Alimentos
  if Reprodução = true
  [
    Reproduzir
  ]
  Move-Leao
  Move-Hiena
  Check-Death
  tick
  if (ticks >= 500 or count turtles = 0)[stop]
end


to Reproduzir
  ask hienas[
    if energia > EnergiaInicial
    [
      if random 101 < 90
      [
        set energia round(energia / 3)
        hatch 2
        [
          jump 1
        ]
      ]
    ]
  ]
  ask leoes [
    if energia > EnergiaInicial * 2
    [
      if random 101 < 75
      [
        set energia round (energia / 2)
        hatch 2
        [
          jump 1
        ]
      ]
    ]
  ]
end


to Check-Death
  ask turtles[if energia < 1 [die]]
end

to Check-Alimentos
  let x 0
  set x x + count patches with [pcolor = brown]
  if(x < nAlimentoPequeno)[
    set x nAlimentoPequeno - x
    ask n-of x patches with [pcolor = black] [
      set pcolor brown
    ]
  ]
end

to Move-Leao
  let x 0
  ask leoes[
    if Armadilhas = true and Trap > 0 [
      set energia energia - Trap
    ]
    ifelse descanso > 0[
      set descanso descanso - 1
    ]
    [
      set x VerificaComida
      if(x > 0)[stop]
      ifelse energia < PriorizarAlimento
      [
        set x ProcuraAlimentoLeao
        ifelse (x > 0)[
          set energia energia - 1
        ]
        [
          set x Look-Kill-OR-descanso
          ifelse ( x < 1 )[
            Leao-Descanso-Movimento
          ]
          [
            ifelse random 101 < 33[
              rt 90
            ]
            [
              ifelse random 101 < 66[
                fd 1
              ]
              [
                rt -90
              ]
            ]
          ]
        ]
      ]
      [
        set x movimentoEspecial
        ifelse(x < 1)[

          set x ProcuraAlimentoLeao
          ifelse (x > 0)[
            set energia energia - 1
          ]
          [
            Leao-Descanso-Movimento
          ]
        ]
        [

        ]
      ]
    ]
  ]

end
;FUNCOES LEAO
to-report movimentoEspecial
  let nHienasC 0
  let aux 0
  let energiaCombate 0
  ifelse any? hienas-on patch-left-and-ahead 90 1 or any? hienas-on patch-right-and-ahead 90 1 or any? hienas-on patch-ahead 1[
    ifelse any? hienas-on patch-left-and-ahead 90 1 and any? hienas-on patch-ahead 1[
      ifelse any? hienas-on patch-right-and-ahead 90 1[
        jump -2
        set energia energia - 4
        report 1
      ]
      [
        jump -1
        rt 90
        jump 1
        set energia energia - 5
        report 1

      ]
    ]
    [
      ifelse any? hienas-on patch-left-and-ahead 90 1 and any? hienas-on patch-right-and-ahead 90 1 [
        jump -1
        set energia energia - 3
        report 1
      ]
      [
        ifelse any? hienas-on patch-right-and-ahead 90 1 and any? hienas-on patch-ahead 1[
          jump -1
          rt -90
          jump 1
          set energia energia - 5
          report 1
        ]
        [
          ifelse any? hienas-on patch-ahead 1[
            set nHienasC nHienasC + count hienas-on patch-ahead 1
            if nHienasC > 1 [
              jump -1
              set energia energia - 3
              report 1
            ]
            ask hienas-on patch-ahead 1[
              set energiaCombate energiaCombate + (energia * PerdaEnergiaCombate) / 100
              die
              ask patch-ahead 1 [set pcolor brown]
            ]
            set energia energia - energiaCombate
            report 1
          ]
          [
            ifelse any? hienas-on patch-left-and-ahead 90 1[
              set nHienasC nhIenasC + count hienas-on patch-left-and-ahead 90 1
              if nHienasC > 1[
                rt 90
                jump 1
                set energia energia - 2
                report 1
              ]
              ask hienas-on patch-left-and-ahead 90 1[
                set energiaCombate energiaCombate + (energia * PerdaEnergiaCombate) / 100
                die
                ask patch-left-and-ahead 90 1 [set pcolor brown]
              ]
              set energia energia - energiaCombate
              report 1
            ]
            [
              set nHienasC nhIenasC + count hienas-on patch-right-and-ahead 90 1
              if nHienasC > 1[
                rt 90
                jump 1
                set energia energia - 2
                report 1
              ]
              ask hienas-on patch-right-and-ahead 90 1[
                set energiaCombate energiaCombate + (energia * PerdaEnergiaCombate) / 100
                die
                ask patch-right-and-ahead 90 1 [set pcolor brown]
              ]
              set energia energia - energiaCombate
              report 1
            ]
          ]
        ]
      ]
    ]
  ]
  [
    report 0
  ]
end
to-report VerificaComida
  ifelse [pcolor] of patch-here = brown or [pcolor] of patch-here = red[
    set pcolor black
    set energia energia + (Energia_Por_Alimento - 1)
    report 1
  ]
  [
    ifelse Avoid = 0 and Armadilhas [
      ifelse [pcolor] of patch-here = 52[
        set Avoid 1
        set Trap Trap + 0.1 * energia
        set energia energia - Trap
        ifelse any? leoes-on patch-ahead 1[
          ask leoes-on patch-ahead 1[
            set Avoid 1
          ]
          report 1
        ]
        [
          ifelse any? leoes-on patch-left-and-ahead 90 1 [
            ask leoes-on patch-left-and-ahead 90 1 [
              set Avoid 1
            ]
            report 1
          ]
          [
            if any? leoes-on patch-right-and-ahead 90 1[
              ask leoes-on patch-right-and-ahead 90 1 [
                set Avoid 1
              ]
              report 1
            ]
          ]
        ]
      ]
      [
        report 0
      ]
    ]
    [
    ]
  ]

  report 0
end

to Leao-Descanso-Movimento
  ifelse [pcolor] of patch-ahead 1 = blue[
    fd 1
    set energia energia - 1
    set descanso descanso + TempoDescanso
  ]
  [
    ifelse [pcolor] of patch-right-and-ahead 90 1 = blue [
      rt 90
      set energia energia - 1
    ]
    [
      ifelse [pcolor] of patch-left-and-ahead 90 1 = blue [
        rt -90
        set energia energia - 1
      ]
      [
        ifelse any? hienas-on patch-ahead 1 [
          ifelse any? hienas-on patch-left-and-ahead 90 1[
            rt 90
            set energia energia - 1
          ][
            rt -90
            set energia energia - 1
          ]
        ]
        [
          ifelse any? hienas-on patch-right-and-ahead 90 1 [
            ifelse any? hienas-on patch-ahead 1[
              rt -90
              set energia energia - 1
            ][
              fd 1
              set energia energia - 1
            ]
          ]
          [
            ifelse any? hienas-on patch-left-and-ahead 90 1[
              ifelse any? hienas-on patch-ahead 1 [
                rt 90
                set energia energia - 1
              ]
              [
                fd 1
                set energia energia - 1
              ]
            ]
            [
              ifelse random 101 < 33[
                rt 90
              ]
              [
                ifelse random 101 < 66[
                  rt -90
                ]
                [
                  fd 1
                ]
              ]
              set energia energia - 1
            ]
          ]
        ]
      ]
    ]
  ]
end

to-report ProcuraAlimentoLeao
  let x 0
  ifelse [pcolor] of patch-ahead 1 = red or  [pcolor] of patch-ahead 1 = brown[
    fd 1
    report 1
  ]
  [
    ifelse [pcolor] of patch-left-and-ahead 90 1 = red or [pcolor] of patch-left-and-ahead 90 1 = brown[
      rt -90
      report 1
    ]
    [
      ifelse [pcolor] of patch-right-and-ahead 90 1 = red or [pcolor] of patch-right-and-ahead 90 1 = brown
      [
        rt 90
        report 1
      ]
      [
        report 0
      ]
    ]
  ]
end

to-report Look-Kill-OR-descanso
  let mortes 0
  let x 0
  let y 0
  let z 0
  let energiaCombate 0
  let a 0
  let l 0
  let r 0

  if any? hienas-on patch-ahead 1 [
    set x x + count hienas-on patch-ahead 1
    set mortes mortes + 1
    set a a + 1
  ]
  if any? hienas-on patch-left-and-ahead 90 1 [
    set y y + count hienas-on patch-left-and-ahead 90 1
    set mortes mortes + 1
    set l l + 1
  ]
  if any? hienas-on patch-right-and-ahead 90 1 [
    set z z + count hienas-on patch-right-and-ahead 90 1
    set mortes mortes + 1
    set r r + 1
  ]

  ifelse mortes < 2 and z < 2 and x < 2 and y < 2[
    ifelse a > 0 [
      ask hienas-on patch-ahead 1[
        set energiaCombate energiaCombate + (energia * PerdaEnergiaCombate) / 100
        die
        if patch-ahead 1 = pink[
          ask patch-ahead 2 [set pcolor brown]
        ]
        ask patch-ahead 1 [set pcolor brown]
      ]
      set energia energia - energiaCombate
      report 1
    ]
    [
      ifelse l > 0
      [
        ask hienas-on patch-left-and-ahead 90 1[
          set energiaCombate energiaCombate + (energia * PerdaEnergiaCombate) / 100
          die


        ]
        set energia energia - energiaCombate
        report 1
      ]
      [
        ask hienas-on patch-right-and-ahead 90 1[
          set energiaCombate energiaCombate + (energia * PerdaEnergiaCombate) / 100
          die

        ]
        set energia energia - energiaCombate
        report 1
      ]
    ]
  ]
  [
    report 0
  ]
end

;FUNCOES HIENA
to Move-Hiena
  ask hienas[
    let x 0
    MudaCor
    set x ProcuraComidaHiena
    ifelse x = 1 [
      stop
    ]
    [
      ifelse x > 1 [
        set energia energia - 1
        VerificaOrientacao
      ]
      [
        set x ComportamentoHienas
        VerificaOrientacao
      ]
    ]
  ]
end

to VerificaOrientacao
  let thisTurtle heading
  if agrupamento > 1 [
    ifelse Armadilhas[
      if any? hienas-on neighbors4 [
        ask hienas-on neighbors4 [set heading thisTurtle]
      ]
      stop
    ]
    [
      ifelse any? hienas-on patch-ahead 1[
        ask hienas-on patch-ahead 1[set heading thisTurtle]
      ]
      [
        ifelse any? hienas-on patch-left-and-ahead 90 1[
          ask hienas-on patch-left-and-ahead 90 1[set heading thisTurtle]
        ]
        [
          ask hienas-on patch-right-and-ahead 90 1[set heading thisTurtle]
        ]
      ]
    ]
  ]
end


to-report ComportamentoHienas
  let energyAux 0
  let x 0
  set x x + count leoes-on patch-ahead 1 + count leoes-on patch-left-and-ahead 90 1 + count leoes-on patch-right-and-ahead 90 1
  ifelse Armadilhas[
    set x 0
    set x x + count leoes-on neighbors4
    ifelse agrupamento > 1 and x = 1[
      ifelse any? leoes-on patch-ahead 1 [
        ask leoes-on patch-ahead 1[
          set energyAux energyAux + energia
          die
        ]
        set energyAux energyAux / agrupamento
        set energia energia - energyAux
        ifelse [pcolor] of patch-ahead 1 = blue[
          ask patch-ahead 2 [set pcolor red]
          jump 2
          set energia energia - 2
        ][
          ask patch-ahead 1 [set pcolor red]
          jump 1
          set energia energia - 1
        ]
        report 5
      ]
      [
        ifelse any? leoes-on patch-left-and-ahead 90 1[
          ask leoes-on patch-left-and-ahead 90 1[
            set energyAux energyAux + energia
            die
          ]
          set energyAux energyAux / agrupamento
          set energia energia - energyAux
          ifelse [pcolor]of patch-left-and-ahead 90 1 = blue[
            ask patch-left-and-ahead 90 2 [set pcolor red]
            rt -90
            set energia energia - 1
          ]
          [
            ask patch-left-and-ahead 90 1 [set pcolor red]
            rt -90
            set energia energia - 1
          ]
          report 5
        ]
        [
          ifelse [pcolor] of patch-right-and-ahead 90 1 = blue [
            ask leoes-on patch-right-and-ahead 90 1[
              set energyAux energyAux + energia
              die
            ]
            set energyAux energyAux / agrupamento
            set energia energia - energyAux
            ifelse [pcolor]of patch-right-and-ahead 90 1 = blue[
              ask patch-right-and-ahead 90 2 [set pcolor red]
              rt 90
              set energia energia - 1
            ]
            [
              ask patch-right-and-ahead 90 1 [set pcolor red]
              rt 90
              set energia energia - 1
            ]
            report 5
          ]
          [
            ask leoes-on patch-right-and-ahead 180 1[
              set energyAux energyAux + energia
              die
            ]
            set energyAux energyAux / agrupamento
            set energia energia - energyAux
            ifelse [pcolor]of patch-right-and-ahead 180 1 = blue[
              ask patch-right-and-ahead 180 2 [set pcolor red]
              rt 180
              set energia energia - 1
            ]
            [
              ask patch-right-and-ahead 180 1 [set pcolor red]
              rt 180
              set energia energia - 1
            ]
            report 5
          ]
        ]
      ]
    ]
    [
      ifelse not any? leoes-on patch-ahead 1[
        fd 1
        set energia energia - 1
        report 1
      ]
      [
        ifelse not any? leoes-on patch-right-and-ahead 90 1 [
          rt 90
          fd 1
          set energia energia - 2
          report 1
        ]
        [
          ifelse not any? leoes-on patch-left-and-ahead 90 1[
            rt -90
            fd 1
            set energia energia - 2
            report 1
          ]
          [
            ifelse not any? leoes-on patch-left-and-ahead 180 1[
              rt 180
              fd 1
              set energia energia - 2
              report 1
            ]
            [

              set energia energia - energia / 2
              report 1
            ]
          ]
        ]
      ]
    ]
  ]
  [
    ifelse agrupamento > 1 and x = 1[
      ifelse any? leoes-on patch-ahead 1 [
        ask leoes-on patch-ahead 1[
          set energyAux energyAux + energia
          die
        ]
        set energyAux energyAux / agrupamento
        set energia energia - energyAux
        ifelse [pcolor] of patch-ahead 1 = blue[
          ask patch-ahead 2 [set pcolor red]
        ][
          ask patch-ahead 1 [set pcolor red]
        ]
        report 5
      ]
      [
        ifelse any? leoes-on patch-left-and-ahead 90 1[
          ask leoes-on patch-left-and-ahead 90 1[
            set energyAux energyAux + energia
            die
          ]
          set energyAux energyAux / agrupamento
          set energia energia - energyAux
          ifelse [pcolor]of patch-left-and-ahead 90 1 = blue[
            ask patch-left-and-ahead 90 2 [set pcolor red]
          ]
          [
            ask patch-left-and-ahead 90 1 [set pcolor red]
          ]
          report 5
        ]
        [
          ask leoes-on patch-right-and-ahead 90 1[
            set energyAux energyAux + energia
            die
          ]
          set energyAux energyAux / agrupamento
          set energia energia - energyAux
          ifelse [pcolor]of patch-right-and-ahead 90 1 = blue[
            ask patch-right-and-ahead 90 2 [set pcolor red]
          ]
          [
            ask patch-right-and-ahead 90 1 [set pcolor red]
          ]
          report 5
        ]
      ]

    ]
    [
      ifelse not any? leoes-on patch-ahead 1 [
        fd 1
        set energia energia - 1
        report 2
      ]
      [
        ifelse not any? leoes-on patch-right-and-ahead 90 1[
          rt 90
          set energia energia - 1
          report 4
        ]
        [
          ifelse not any? leoes-on patch-left-and-ahead 90 1[
            rt -90
            set energia energia - 1
            report 3
          ]
          [
            ifelse random 101 < 33[
              rt 90
              set energia energia - 1
              report 4
            ]
            [
              ifelse random 101 < 66[
                fd 1
                set energia energia - 1
                report 2
              ]
              [
                rt -90
                set energia energia - 1
                report 3
              ]
            ]
          ]
        ]
      ]
    ]
  ]
end

to-report ProcuraComidaHiena
  if [pcolor] of patch-here = red [
    set pcolor brown
    set energia energia + (Energia_Por_Alimento - 1)
    report 1
  ]
  ifelse [pcolor] of patch-here = brown [
    set pcolor black
    set energia energia + (Energia_Por_Alimento - 1)
    report 1
  ]
  [
    ifelse Armadilhas [
      ifelse one-of [pcolor] of neighbors4 = red or one-of [pcolor] of neighbors4 = brown[
        ifelse [pcolor] of patch-ahead 1 = red or [pcolor] of patch-ahead 1 = brown[
          fd 1
          set pcolor black
          set energia energia + (Energia_Por_Alimento - 1 )
          report 2
        ]
        [
          ifelse [pcolor] of patch-left-and-ahead 90 1 = red or [pcolor] of patch-left-and-ahead 90 1 = brown[
            rt -90
            fd 1
            set energia energia - 2
            report 3
          ]
          [
            ifelse [pcolor] of patch-right-and-ahead 90 1 = red or [pcolor] of patch-right-and-ahead 90 1 = brown
            [
              rt 90
              fd 1
              set energia energia - 2
              report 4
            ]
            [
              ifelse [pcolor] of patch-right-and-ahead 180 1 = red or [pcolor] of patch-right-and-ahead 180 1 = brown[
                rt 180
                fd 1
                set energia energia - 2
                report 7
              ]
              [
                report 0
              ]
            ]
          ]
        ]
      ]
      [
        report 0
      ]
    ]
    [
      ifelse [pcolor] of patch-ahead 1 = red or [pcolor] of patch-ahead 1 = brown[
        fd 1
        report 2
      ]
      [
        ifelse [pcolor] of patch-left-and-ahead 90 1 = red or [pcolor] of patch-left-and-ahead 90 1 = brown[
          rt -90
          report 3
        ]
        [
          ifelse [pcolor] of patch-right-and-ahead 90 1 = red or [pcolor] of patch-right-and-ahead 90 1 = brown
          [
            rt 90
            report 4
          ]
          [
            report 0
          ]
        ]
      ]
    ]
  ]
end

to MudaCor
  let x 0
  set x x + (count hienas-on patch-ahead 1) + (count hienas-on patch-left-and-ahead 90 1) + (count hienas-on patch-right-and-ahead 90 1)
  if Armadilhas [
    set x 0
    set x x + count hienas-on neighbors4
  ]
  ifelse (x > 0)[
    set color orange
    set agrupamento agrupamento + x
  ]
  [
    set agrupamento 1
    set color white
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
273
10
776
514
-1
-1
15.0
1
10
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
2
44
66
77
Setup
Setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
0
102
198
135
Alimento_PequenoPorte
Alimento_PequenoPorte
0
20
10.0
1
1
%
HORIZONTAL

SLIDER
0
146
198
179
Alimento_GrandePorte
Alimento_GrandePorte
0
10
5.0
1
1
%
HORIZONTAL

SLIDER
1
186
200
219
Energia_Por_Alimento
Energia_Por_Alimento
0
50
5.0
1
1
NIL
HORIZONTAL

SLIDER
0
228
201
261
Celulas_Azuis
Celulas_Azuis
0
5
2.5
0.5
1
NIL
HORIZONTAL

SLIDER
0
271
203
304
EnergiaInicial
EnergiaInicial
0
100
100.0
1
1
NIL
HORIZONTAL

SLIDER
0
315
205
348
nLeoes
nLeoes
0
100
15.0
1
1
NIL
HORIZONTAL

SLIDER
0
352
206
385
nHienas
nHienas
0
100
50.0
1
1
NIL
HORIZONTAL

SLIDER
2
400
208
433
PriorizarAlimento
PriorizarAlimento
0
20
10.0
1
1
NIL
HORIZONTAL

SLIDER
2
443
207
476
PerdaEnergiaCombate
PerdaEnergiaCombate
0
20
10.0
1
1
%
HORIZONTAL

SLIDER
2
485
207
518
TempoDescanso
TempoDescanso
0
10
5.0
1
1
ticks
HORIZONTAL

BUTTON
125
46
185
79
Go
Go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
879
59
1363
299
Agentes
Ticks
Nº de Agentes Vivos
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Leões" 1.0 0 -7171555 true "" "plot count leoes"
"Hienas" 1.0 0 -16645628 true "" "plot count hienas"

MONITOR
1076
307
1178
352
Hienas Vivas
count hienas
17
1
11

MONITOR
883
306
996
351
Leoes Vivos
count leoes
17
1
11

SWITCH
0
531
152
564
Armadilhas
Armadilhas
0
1
-1000

MONITOR
1243
306
1362
351
Armadilhas
count patches with [pcolor = white]
17
1
11

MONITOR
1071
380
1187
425
Leoes a descansar
count leoes-on patches with [pcolor = blue]
17
1
11

SWITCH
0
570
123
603
Reprodução
Reprodução
1
1
-1000

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

cat
false
0
Line -7500403 true 285 240 210 240
Line -7500403 true 195 300 165 255
Line -7500403 true 15 240 90 240
Line -7500403 true 285 285 195 240
Line -7500403 true 105 300 135 255
Line -16777216 false 150 270 150 285
Line -16777216 false 15 75 15 120
Polygon -7500403 true true 300 15 285 30 255 30 225 75 195 60 255 15
Polygon -7500403 true true 285 135 210 135 180 150 180 45 285 90
Polygon -7500403 true true 120 45 120 210 180 210 180 45
Polygon -7500403 true true 180 195 165 300 240 285 255 225 285 195
Polygon -7500403 true true 180 225 195 285 165 300 150 300 150 255 165 225
Polygon -7500403 true true 195 195 195 165 225 150 255 135 285 135 285 195
Polygon -7500403 true true 15 135 90 135 120 150 120 45 15 90
Polygon -7500403 true true 120 195 135 300 60 285 45 225 15 195
Polygon -7500403 true true 120 225 105 285 135 300 150 300 150 255 135 225
Polygon -7500403 true true 105 195 105 165 75 150 45 135 15 135 15 195
Polygon -7500403 true true 285 120 270 90 285 15 300 15
Line -7500403 true 15 285 105 240
Polygon -7500403 true true 15 120 30 90 15 15 0 15
Polygon -7500403 true true 0 15 15 30 45 30 75 75 105 60 45 15
Line -16777216 false 164 262 209 262
Line -16777216 false 223 231 208 261
Line -16777216 false 136 262 91 262
Line -16777216 false 77 231 92 261

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

footprint
true
0
Polygon -7500403 true true 75 195 90 240 135 270 165 270 195 255 225 195 225 180 195 165 177 154 167 139 150 135 132 138 124 151 105 165 76 172
Polygon -7500403 true true 250 136 225 165 210 135 210 120 227 100 241 99
Polygon -7500403 true true 75 135 90 135 105 120 105 75 90 75 60 105
Polygon -7500403 true true 120 122 155 121 161 62 148 40 136 40 118 70
Polygon -7500403 true true 176 126 200 121 206 89 198 61 186 57 166 106
Polygon -7500403 true true 93 69 103 68 102 50
Polygon -7500403 true true 146 34 136 33 137 15
Polygon -7500403 true true 198 55 188 52 189 34
Polygon -7500403 true true 238 92 228 94 229 76

horse_
false
0
Polygon -7500403 true true 75 225 97 249 112 252 122 252 114 242 102 241 89 224 94 181 64 113 46 119 31 150 32 164 61 204 57 242 85 266 91 271 101 271 96 257 89 257 70 242
Polygon -7500403 true true 216 73 219 56 229 42 237 66 226 71
Polygon -7500403 true true 181 106 213 69 226 62 257 70 260 89 285 110 272 124 234 116 218 134 209 150 204 163 192 178 169 185 154 189 129 189 89 180 69 166 63 113 124 110 160 111 170 104
Polygon -6459832 true true 252 143 242 141
Polygon -6459832 true true 254 136 232 137
Line -16777216 false 75 224 89 179
Line -16777216 false 80 159 89 179
Polygon -6459832 true true 262 138 234 149
Polygon -7500403 true true 50 121 36 119 24 123 14 128 6 143 8 165 8 181 7 197 4 233 23 201 28 184 30 169 28 153 48 145
Polygon -7500403 true true 171 181 178 263 187 277 197 273 202 267 187 260 186 236 194 167
Polygon -7500403 true true 187 163 195 240 214 260 222 256 222 248 212 245 205 230 205 155
Polygon -7500403 true true 223 75 226 58 245 44 244 68 233 73
Line -16777216 false 89 181 112 185
Line -16777216 false 31 150 47 118
Polygon -16777216 true false 235 90 250 91 255 99 248 98 244 92
Line -16777216 false 236 112 246 119
Polygon -16777216 true false 278 119 282 116 274 113
Line -16777216 false 189 201 203 161
Line -16777216 false 90 262 94 272
Line -16777216 false 110 246 119 252
Line -16777216 false 190 266 194 274
Line -16777216 false 218 251 219 257
Polygon -16777216 true false 230 67 228 54 222 62 224 72
Line -16777216 false 246 67 234 64
Line -16777216 false 229 45 235 68
Line -16777216 false 30 150 30 165

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -7500403 true true 75 225 97 249 112 252 122 252 114 242 102 241 89 224 94 181 64 113 46 119 31 150 32 164 61 204 57 242 85 266 91 271 101 271 96 257 89 257 70 242
Polygon -7500403 true true 216 73 219 56 229 42 237 66 226 71
Polygon -7500403 true true 181 106 213 69 226 62 257 70 260 89 285 110 272 124 234 116 218 134 209 150 204 163 192 178 169 185 154 189 129 189 89 180 69 166 63 113 124 110 160 111 170 104
Polygon -6459832 true true 252 143 242 141
Polygon -6459832 true true 254 136 232 137
Line -16777216 false 75 224 89 179
Line -16777216 false 80 159 89 179
Polygon -6459832 true true 262 138 234 149
Polygon -7500403 true true 50 121 36 119 24 123 14 128 6 143 8 165 8 181 7 197 4 233 23 201 28 184 30 169 28 153 48 145
Polygon -7500403 true true 171 181 178 263 187 277 197 273 202 267 187 260 186 236 194 167
Polygon -7500403 true true 187 163 195 240 214 260 222 256 222 248 212 245 205 230 205 155
Polygon -7500403 true true 223 75 226 58 245 44 244 68 233 73
Line -16777216 false 89 181 112 185
Line -16777216 false 31 150 47 118
Polygon -16777216 true false 235 90 250 91 255 99 248 98 244 92
Line -16777216 false 236 112 246 119
Polygon -16777216 true false 278 119 282 116 274 113
Line -16777216 false 189 201 203 161
Line -16777216 false 90 262 94 272
Line -16777216 false 110 246 119 252
Line -16777216 false 190 266 194 274
Line -16777216 false 218 251 219 257
Polygon -16777216 true false 230 67 228 54 222 62 224 72
Line -16777216 false 246 67 234 64
Line -16777216 false 229 45 235 68
Line -16777216 false 30 150 30 165

wolf 4
false
0
Polygon -7500403 true true 105 75 105 45 45 0 30 45 45 60 60 90
Polygon -7500403 true true 45 165 30 135 45 120 15 105 60 75 105 60 180 60 240 75 285 105 255 120 270 135 255 165 270 180 255 195 255 210 240 195 195 225 210 255 180 300 120 300 90 255 105 225 60 195 45 210 45 195 30 180
Polygon -16777216 true false 120 300 135 285 120 270 120 255 180 255 180 270 165 285 180 300
Polygon -16777216 true false 240 135 180 165 180 135
Polygon -16777216 true false 60 135 120 165 120 135
Polygon -7500403 true true 195 75 195 45 255 0 270 45 255 60 240 90
Polygon -16777216 true false 225 75 210 60 210 45 255 15 255 45 225 60
Polygon -16777216 true false 75 75 90 60 90 45 45 15 45 45 75 60

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.3.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count leoes</metric>
    <metric>count hienas</metric>
    <metric>ticks</metric>
    <enumeratedValueSet variable="PerdaEnergiaCombate">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nLeoes">
      <value value="5"/>
      <value value="10"/>
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Energia_Por_Alimento">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="PriorizarAlimento">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="TempoDescanso">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Armadilhas">
      <value value="false"/>
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Alimento_PequenoPorte">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="EnergiaInicial">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Celulas_Azuis">
      <value value="2.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nHienas">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Alimento_GrandePorte">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Reprodução">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
