{
	let tab = 3;
	let indent = 0;
	let formatted = '';

	function incr() { indent += tab; }
	function decr() { indent -= tab; }
	function crlf() { formatted += '\r\n' + ' '.repeat(indent); }
}

start 
	= mdx:MdxExpression ows ";"? ows { 
		mdx.emit(); 
		formatted += ';';
		return formatted; 
	}

MdxExpression 
	= ows w:WithExpression? SelectKeyWord ows axis0:AxisExpression komma axis1:AxisExpression ws from:FromExpression where:(ws WhereExpression)? {
	return {emit() { 
			if (w) { w.emit(); }
			formatted += 'SELECT';
			incr();
			crlf();
			axis0.emit();
			formatted += ',';
			crlf();
			axis1.emit();
			indent -= tab;
			crlf();
			from.emit();
			if (where) {
				crlf();
				where[1].emit();
			}
        }};	
	}
	/ ows w:WithExpression? SelectKeyWord ows axis:AxisExpression ws from:FromExpression where:(ws WhereExpression)? {
	return {emit() { 
			if (w) { w.emit(); }
			formatted += 'SELECT';
			incr();
			crlf();
	        axis.emit();
			decr();
			crlf();
			from.emit();
			if (where) {
				crlf();
				where[1].emit();
			}
        }};	
	}

WithExpression
	= WithKeyWord ws definitions:(WithDefinitionExpression ows)+ {
		return {emit() {
			formatted += "WITH";
			incr();
			definitions.forEach((d, i, a) => {
				crlf();
				d[0].emit();
			});
			decr();
			crlf();
		}};
	}

WithDefinitionExpression
	= MemberDefinition / SetDefinition

MemberDefinition
	= MemberKeyWord ws element:ElementExpression ws AsKeyWord ws set:SetExpression solveOrder:(komma SolveOrderKeyWord ows "=" ows NumberConst)? {
		return {emit() {
			formatted += "MEMBER ";
			element.emit();
			formatted += " AS";
			incr();
			crlf();
			set.emit();
			if (solveOrder) {
				formatted += ',';
				crlf();
				formatted += 'SOLVE_ORDER = ';
				formatted += solveOrder[5];
			}
			decr();
		}};
	}

SetDefinition
	= SetKeyWord ws element:ElementExpression ws AsKeyWord ws set:SetExpression {
		return {emit() {
			formatted += "SET ";
			element.emit();
			formatted += " AS";
			incr();
			crlf();
			set.emit();
			decr();
		}};
	}

AxisExpression 
	= nonEmpty:NonEmptyExpression? tuple:TupleExpression ows dimProps:DimensionPropertiesExpression? axisLocation:AxisLocationExpression {
		return { emit() { 
			if (nonEmpty) formatted += nonEmpty;
			tuple.emit();
			if (dimProps) {
				dimProps.emit();
			}
			formatted += axisLocation;
			}};
	}
	
NonEmptyExpression = NonKeyWord ws EmptyKeyWord ws { return 'NON EMPTY '; }

AxisLocationExpression 
	= OnKeyWord ws ColumnsKeyWord { return ' ON COLUMNS'; }
	/ OnKeyWord ws "0"            { return ' ON 0'; }
	/ OnKeyWord ws RowsKeyWord    { return ' ON ROWS'; }
	/ OnKeyWord ws "1"            { return ' ON 1'; }
	
DimensionPropertiesExpression
	= DimensionKeyWord ws PropertiesKeyWord ws prop:PropertyName props:(komma PropertyName)* ows {
		return {emit() {
			crlf();
			formatted += "DIMENSION PROPERTIES ";
			formatted += prop;
			if (props) {
				props.forEach((p, i, a) => {
					formatted += ', ' + p[1];
				});
			}
		}};
	}

FromExpression
	= FromKeyWord ws cube:CubeName { 
		return { emit() { formatted += 'FROM ' + cube; }};
    }
	/ FromKeyWord ows "(" ows mdx:MdxExpression ows ")" {
		return { emit() {
			formatted += 'FROM (';
			incr(); incr();
			mdx.emit();
			decr(); decr();
			formatted += ')';
	    }};
	}

TupleExpression
	= set:SetExpression ows op:$[\*-] ows tuple:TupleExpression { 
		return {emit() { 
				set.emit() 
				crlf();
				formatted += op;
				crlf();
				tuple.emit();
			}}; 
	}
	/ SetExpression

SetExpression
	= setPart:SetPartExpression komma set:SetExpression {
		return {emit() {
				setPart.emit();
				formatted += ',';
				crlf();
				set.emit();
		}};
	}
	/ SetPartExpression

SetPartExpression
	= element1:ElementExpression ows ":" ows element2:ElementExpression {
		return {emit() {
				element1.emit();
				crlf();
				formatted += ':';
				crlf();
				element2.emit();
		}};
	}
	/ element:ElementExpression
	
ElementPartExpression = $("["[^\]]+"]")
ElementFunction = FunctionExpression / FunctionName
ElementExpression 
	= element:$((ElementPartExpression ("." ElementPartExpression)*) (ampersandElement:("." ("&" ElementPartExpression)+) / "." elementFunction:ElementFunction)?) {
		return {emit() { formatted += element; }};
	}
	/ func:FunctionExpression
	/ open:[{(] ows tuple:TupleExpression ows close:[)}] {
		return {emit() {
			formatted += open;
			incr();
			crlf();
			tuple.emit();
			decr();
			crlf();
			formatted += close;
		}};
	}
	/ "{" ows "}" {
		return {emit() {
			formatted += '{}';
		}};
	}

FunctionExpression
	= func:FunctionName ows parameters:ParameterListExpression {
		return {emit() {
			formatted += func;
			parameters.emit();
		}};
	}

OperationExpression
	= operand:OperandExpression ows operator:OperatorExpression ows operation:OperationExpression {
		return {emit() {
			operand.emit();
			formatted += ' ' + operator + ' ';
			operation.emit();
		}};
	}
	/ OperandExpression

OperandExpression
	= set:SetExpression {
		return {emit() {
			set.emit();
		}};
	}
	/ i:NumberConst { return {emit() { formatted += i; }};}
	/ "(" ows operation:OperationExpression ows ")" {
		return {emit() {
			formatted += '(';
			incr();
			operation.emit();
			decr();
			formatted += ')';
		}};
	}

ParameterListExpression
	= "(" ows parameter:ParameterExpression parameters:(komma ParameterExpression)* ows ")" {
		return {emit() {
			formatted += '(';
			incr();
			crlf();
			parameter.emit();
			parameters.forEach((p, i, a) => {
				formatted += ',';
				crlf();
				p[1].emit();
			});
			decr();
			crlf();
			formatted += ')';
		}};
	}

ParameterExpression
	= OperationExpression
	/ flag:FlagParameter { return {emit() { formatted += flag.toUpperCase(); }}; }

WhereExpression
	= WhereKeyWord ows tuple:TupleExpression {
		return {emit() {
			formatted += 'WHERE ';
			incr();
			tuple.emit();
			decr();
		}};
	}

PropertyName = $("["[^\]]+"]")
CubeName = $("["[^\]]+"]")
FunctionName = $([A-Za-z][A-Za-z0-9]*)
FlagParameter = $([A-Za-z][A-Za-z0-9_]*)
NumberConst = $([\-]?[0-9]+("."[0-9]+)?)

WithKeyWord = "WITH"i
SetKeyWord = "SET"i
MemberKeyWord = "MEMBER"i
AsKeyWord = "AS"i
SolveOrderKeyWord = "SOLVE_ORDER"i
SelectKeyWord = "SELECT"i
NonKeyWord = "NON"i
EmptyKeyWord = "EMPTY"i
DimensionKeyWord = "DIMENSION"i
PropertiesKeyWord = "PROPERTIES"i
OnKeyWord = "ON"i
ColumnsKeyWord = "COLUMNS"i
RowsKeyWord = "ROWS"i
FromKeyWord = "FROM"i
WhereKeyWord = "WHERE"i

OperatorExpression
	= $"+"
	/ $"-"
	/ $"*"
	/ $"IS"i
	/ $"="
	/ $"<>"
	/ $">"
	/ $">="
	/ $"<"
	/ $"<="

ws = [ \t\r\n]+
ows = [ \t\r\n]*
komma = ows "," ows
