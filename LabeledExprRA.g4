grammar LabeledExpr;
import CommonLexerRules;

prog: stat+;

stat:
	expr NEWLINE			# printExpr
	| ID '=' expr NEWLINE	# assign
	| NEWLINE				# blank;
expr
   : expr ('+'|'-') expr      # AddSub
   | expr ('*'|'/') expr      # MulDiv
   | INT                      # Int
   | '(' expr ')'             # Parens
   ;
