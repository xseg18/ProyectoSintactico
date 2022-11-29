

1. ¿Que tipo de analizador es generado por CUP y por ANTLR?
ANTLR4 genera bottom-up LL* y Cup genera top-down LALR
2. En ANTLR existen dos formas para generar acciones a partir del arbol de parsing, ¿Cuál utilizó y porqué?
Se hizo uso de los visitors dada su facil aplicación, generación de código y asimilación de walkers por el AST. También porque se podía comparar y apoyar con la implementación de cup (tipos resultantes y como o qué visitar).
3. ¿Cúales requisitos debió cumplir su gramática para ser compatible con CUP?
- plugin y dependencia correspondiente con misma versión.
- cambio de "class" a "class_" en no terminales.
- declaración de precedencias.
4. ¿Cuáles requisitos debió cumplir su gramática para ser compatible con ANTLR?
- plugin y dependencia correspondiente con misma versión.
- creación del directorio gt.edu.url dentro de la carpeta antlr4
- creación de lexer correspondiente para la gramatica
- creación de producciones para gramatica basada en manual de cool 
- cambios en archivo makefile (eliminación de ejecución de jflex)
- eliminación clase TokenConstantsCool.java 
- Cambios en clase Utilities (compatibilidad con CommonToken en vez de Symbol)
