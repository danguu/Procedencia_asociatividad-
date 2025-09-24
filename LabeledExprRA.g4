grammar LabeledExpr;
import CommonLexerRules;

prog: stat+;

stat:
	expr NEWLINE			# printExpr
	| ID '=' expr NEWLINE	# assign
	| NEWLINE				# blank;
