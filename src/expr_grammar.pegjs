program = p:(statement sep* (";" sep* statement sep*)* ";"?) {
    var stmts = flattenTokens(p, function(item) {
        return (isWhitespace(item) || item == ";");
    });
    return new AstProgram(stmts);
}

statement
		= id:identifier sep* "=" sep* e:expr { return new AstAssignment(id, e); }
		/ expr

unary_ops = "+" / "-"
additive_ops = "+" / "-"
multiplicative_ops = "*" / "/" / "%"
boolean_ops = "&" / "|"

expr = boolean_expr

boolean_expr
		= lo:additive_expr sep* op:boolean_ops sep* ro:boolean_expr { return new AstBinaryExpr(op, lo, ro); }
		/ additive_expr

additive_expr
		 = lo:multiplicative_expr sep* op:additive_ops sep* ro:additive_expr { return new AstBinaryExpr(op, lo, ro); }
		 / multiplicative_expr

multiplicative_expr
		= lo:unary sep* op:multiplicative_ops sep* ro:multiplicative_expr { return new AstBinaryExpr(op, lo, ro); }
		/ unary

unary
		= op:unary_ops sep* oper:func_call { return new AstUnaryExpr(op, oper); }
		/ func_call

func_call
		= funcName:identifier sep* "(" sep* args:((expr sep* ",")* sep* expr)? sep* ")" {
		        var argsList = flattenTokens(args, function(item) {
                    return (isWhitespace(item) || item == ",");
		        });
		       return new AstFuncCall(funcName, argsList);
		}
		/ primary_expr

primary_expr
		= val:value      {return new AstPrimaryExpr(val);}
		/ id:identifier  {return new AstPrimaryExpr(id);}
		/ "(" e:expr ")" { return e; }

identifier
		= val:([a-zA-Z_] [a-zA-Z_0-9]*) {
		    return flattenTokens(val).join("");
		}

value
		= val:([0-9]* "." [0-9]+ ([Ee] [0-9]+)?) {
		    return parseFloat(flattenTokens(val).join(""));
		}
		/ val:([a-fA-F0-9]+) [hH] {
		    return parseInt(flattenTokens(val).join(""), 16);
		}
        / val:([0-9]+) [dD]? {
            return parseInt(flattenTokens(val).join(""), 10);
        }


sep
	= [' '\t\r\n]