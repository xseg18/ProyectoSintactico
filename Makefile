MAVEN := mvn
SRCLEXER:= lexer-chilero
SRCPARSERCUP:= parser-chilero-cup
SRCPARSERANTLR:= parser-chilero-antlr
JARFILELEXER := lexer-chilero/target/lexer-chilero-1.0-SNAPSHOT-jar-with-dependencies.jar
JARFILEPARSERCUP := parser-chilero-cup/target/parser-chilero-cup-1.0-SNAPSHOT-jar-with-dependencies.jar
JARFILEPARSERANTLR := parser-chilero-antlr/target/parser-chilero-antlr-1.0-SNAPSHOT-jar-with-dependencies.jar

compilelexer:
	${MAVEN} -f ${SRCLEXER}/pom.xml clean verify

compileparsercup:
	${MAVEN} -f ${SRCPARSERCUP}/pom.xml clean verify

compileparserantlr:
	${MAVEN} -f ${SRCPARSERANTLR}/pom.xml clean verify

lexer: compilelexer
	@rm -f lexer
	echo '#!/bin/bash' >> lexer
	echo 'java -jar ${JARFILELEXER} $$*' >> lexer
	chmod 755 lexer

parsercup: compileparsercup
	@rm -f parser
	echo '#!/bin/bash' >> parser
	echo 'java -jar ${JARFILELEXER} $$* | java -jar ${JARFILEPARSERCUP} $$*' >> parser
	chmod 755 parser

parserantlr: compileparserantlr
	@rm -f parser
	echo '#!/bin/bash' >> parser
	echo 'java -jar ${JARFILEPARSERANTLR} $$*' >> parser
	chmod 755 parser

dofactorialcup: clean lexer parsercup
	-./mycoolccup cooltests/factloop.cl cooltests/atoi.cl
	-./bin/spim cooltests/factloop.s < cooltests/factloop.test

dostackcup: clean lexer parsercup
	-./mycoolccup cooltests/stack.cl cooltests/atoi.cl
	-./bin/spim cooltests/stack.s < cooltests/stack.test

dofactorialantlr: clean parserantlr
	-./mycoolcantlr cooltests/factloop.cl cooltests/atoi.cl
	-./bin/spim cooltests/factloop.s < cooltests/factloop.test

dostackantlr: clean parserantlr
	-./mycoolcantlr cooltests/stack.cl cooltests/atoi.cl
	-./bin/spim cooltests/stack.s < cooltests/stack.test

clean:
	-${MAVEN} -f ${SRCLEXER}/pom.xml clean
	-${MAVEN} -f ${SRCPARSERCUP}/pom.xml clean
	-${MAVEN} -f ${SRCPARSERANTLR}/pom.xml clean
	-rm -f cooltests/*.s lexer
	-rm -f input.test
