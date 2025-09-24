# Procedencia_asociatividad

````markdown
# Prueba de precedencia y asociatividad con ANTLR4

Este proyecto implementa un **intérprete de expresiones matemáticas** en ANTLR4.  
El objetivo es observar cómo la **precedencia** y la **asociatividad** de los operadores aritméticos dependen del diseño de la gramática.

## Objetivos de la actividad

1. Crear un programa en ANTLR que procese operaciones matemáticas.
2. Probar la **precedencia y asociatividad** de los operadores en la gramática original.
3. Rediseñar la gramática para **cambiar precedencia o asociatividad**.
4. Ejecutar varias cadenas de prueba y **comparar resultados**.
5. Documentar las diferencias.

##  Archivos del proyecto

- `LabeledExpr.g4` → Gramática **original** (precedencia tradicional).  
- `LabeledExprRA.g4` → Gramática **modificada** (cambio en precedencia/asociatividad).  
- `Calc.java` → Clase principal que carga el archivo de prueba y evalúa las expresiones.  
- `EvalVisitor.java` → Visitor para recorrer el árbol y calcular los resultados.  
- `t.expr` → Archivo de entrada con expresiones de prueba.  

## Requisitos

- **Java 11 o superior**  
- **ANTLR4 (v4.13.2 en este proyecto)**  

Descargar el JAR de ANTLR:

```bash
wget https://www.antlr.org/download/antlr-4.13.2-complete.jar -O antlr-4.13.2-complete.jar
````

## Instrucciones de uso

### 1. Generar el parser/lexer

Con la gramática original:

```bash
java -jar antlr-4.13.2-complete.jar -no-listener -visitor LabeledExpr.g4
```

Con la gramática modificada:

```bash
java -jar antlr-4.13.2-complete.jar -no-listener -visitor LabeledExprRA.g4
```

### 2. Compilar

```bash
javac -cp ".:antlr-4.13.2-complete.jar" *.java
```

### 3. Ejecutar

```bash
java -cp ".:antlr-4.13.2-complete.jar" Calc t.expr
```

Ejemplo de archivo `t.expr`:

```
2+3*4
2-3-4
(1+2)*3
8/4/2
```

## Cambios en la gramática

### Gramática original (precedencia tradicional)

En `LabeledExpr.g4` la precedencia se maneja con varias reglas:

```antlr
expr
   : expr ('*'|'/') expr      # MulDiv
   | expr ('+'|'-') expr      # AddSub
   | INT                      # Int
   | '(' expr ')'             # Parens
   ;
```

* Multiplicación/División tienen **más precedencia** que Suma/Resta.
* Todos los operadores son **asociativos a la izquierda** (por la recursión izquierda).

### Gramática modificada (cambio de precedencia/asociatividad)

#### Opción 1: Cambiar **precedencia**

Si quieres que `+` y `-` tengan más precedencia que `*` y `/`, inviertes el orden:

```antlr
expr
   : expr ('+'|'-') expr      # AddSub
   | expr ('*'|'/') expr      # MulDiv
   | INT                      # Int
   | '(' expr ')'             # Parens
   ;
```

Ahora `2+3*4` se interpreta como `(2+3)*4 = 20`.

#### Opción 2: Cambiar **asociatividad**

Si quieres que la resta sea **asociativa a la derecha**, debes evitar la recursión izquierda. Ejemplo:

```antlr
expr
   : INT
   | '(' expr ')'
   | expr ('*'|'/') expr
   | expr '+' expr
   | expr '-' expr -> ^(SUB expr expr) // pseudocódigo, ajustar en práctica
   ;
```

En la práctica, puedes lograr asociatividad derecha con **recursión derecha** en lugar de izquierda:

```antlr
expr
   : INT
   | '(' expr ')'
   | expr ('*'|'/') expr
   | expr '+' expr
   | expr '-' expr
   ;
```

Pero si redefines la regla como:

```antlr
expr
   : INT
   | '(' expr ')'
   | expr ('*'|'/') expr
   | expr '+' expr
   | expr '-' expr
   ;
```

y fuerzas el parser a tomar la rama derecha, obtendrás:
`2-3-4 = 2-(3-4) = 3`.

## Resultados de prueba

### Con `LabeledExpr.g4` (original):

* `2+3*4 = 14` 
* `2-3-4 = -5`  (izquierda: `(2-3)-4`)
* `(1+2)*3 = 9` 
* `8/4/2 = 1` 

### Con `LabeledExprRA.g4` (modificada):

* `2+3*4 = 20`  (suma antes que multiplicación).
* `2-3-4 = 3`  (asociatividad derecha: `2-(3-4)`).
* `(1+2)*3 = 9` (paréntesis mantiene precedencia).
* `8/4/2 = 4` (si se cambia asociatividad de división a derecha).

## Comparación

| Expresión | Gramática original | Gramática modificada |
| --------- | ------------------ | -------------------- |
| `2+3*4`   | 14                 | 20                   |
| `2-3-4`   | -5                 | 3                    |
| `(1+2)*3` | 9                  | 9                    |
| `8/4/2`   | 1                  | 4                    |
