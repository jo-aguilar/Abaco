#!/usr/bin/env perl6

use v6;
use Terminal::ANSIColor;

proto sub inicia-abaco   ( --> Int:D ) {*};
proto sub redireciona-op (Int:D $entrada) {*};
proto sub requer-redsult (Str:D $entrada, Bool:D $conds, Str:D $aviso --> Str:D ) {*};
proto sub retorna-cond1  (Str:D $entrada) {*};
proto sub retorna-cond2  (Str:D $entrada) {*};
proto sub retorna-cond3  (Str:D $entrada) {*};
proto sub computa-erro   (Int:D $numero1, Int:D $numero2 --> Bool) {*};
proto sub computa-tempo  (Int:D $delta-tempo --> Str) {*};
proto sub operacao-op    ($func)  {*};
proto sub adicao         (Int:D $rodadas, Int:D $casas) {*};
proto sub subtracao      (Int:D $rodadas, Int:D $casas) {*};
proto sub multiplicacao  (Int:D $rodadas, Int:D $casas) {*};
proto sub divisao        (Int:D $rodadas, Int:D $casas) {*};

#=========================================================================#
#                               MAIN                                      #
#=========================================================================#
sub MAIN {
	shell 'clear';
	redireciona-op (inicia-abaco);
}

#========================= OPERAÇÕES BÁSICAS =============================#

multi sub computa-erro ($numero1, $numero2) {
#Avalia se os resultados dados pelo programa e pelo usuário são iguais, então envia
#uma mensagem para o terminal avisando sobre o resultado e retorna True ou False de 
#acordo com a avaliação
	{ put "[" ~ color("bold green"), "CORRETO", color('reset') ~ "]"; return True  } if ($numero1 == $numero2);
	{ put "[" ~ color("bold red"), "ERRADO" , color('reset') ~ "]" ;  return False } if ($numero1 != $numero2);
}

multi sub computa-tempo ($delta-tempo) {

	my $minutos = ($delta-tempo/60).Int;
	my $segundos = ($delta-tempo - $minutos*60).Int;
	return "$minutos:$segundos".Str;
}

multi sub divisao {
	my $letreiro = 
"+++++++++++++++++++++++++++++++++++++
+              DIVISÃO              +
+++++++++++++++++++++++++++++++++++++\n";
	say color("bold red"), $letreiro, color('reset');
}

multi sub multiplicacao { 
	my $letreiro = 
"+++++++++++++++++++++++++++++++++++++
+           MULTIPLICAÇÃO           +
+++++++++++++++++++++++++++++++++++++\n";
	say color("bold blue"), $letreiro, color('reset');
}

multi sub subtracao ($rodadas, $casas) { 
#A partir da quantidade de rodadas e casas especificadas pelo usuário, roda o programa
#requerendo os resultados de acordo com as especificações nos argumentos da função,
#executando a operação equivalente à subtração
	my $inicio = now;
	my $acertos = 0;
	my $erros   = 0;
	my $letreiro = 
"+++++++++++++++++++++++++++++++++++++
+             SUBTRAÇÃO             +
+++++++++++++++++++++++++++++++++++++\n"; 
	for (1 .. $rodadas) {
		shell 'clear';
		say color("bold yellow"), $letreiro, color('reset');
		my $numero1   = (10..10**$casas).rand.Int;
		my $numero2   = $numero1;
		$numero2 = do { $numero2 = (10..10**$casas).rand.Int } while $numero2 == $numero1;
		
		my $valor = max($numero2, $numero1) - min($numero2, $numero1);
		my $tentativa = prompt ("{max($numero2, $numero1)} - {min($numero2, $numero1)} = ");
		my $resultado = computa-erro(+$tentativa, $valor);
		if ($resultado == True) { $acertos++; }
		else                    { $erros++;   }
		sleep 1;
	}
	my $termino = now;
	put q:c:b [\nAcertos: {100*$acertos/$rodadas}%\nErros:   {100*$erros/$rodadas}%\n];
	put q:c:b [Tempo necessário {computa-tempo(($termino - $inicio).Int)}\n];
}

multi sub retorna-cond2 ( Str:D $entrada ) { 
#retorna a condição de número 2 para avaliação em &requer-result
  	return any(!(+$entrada ~~ Int), +$entrada < 2, $entrada > 50).Bool;
}

multi sub retorna-cond3 ( Str:D $entrada ) { 
#retorna a condição de número 3 para avaliação em &requer-result
	return any(!(+$entrada ~~ Int), +$entrada < 2, $entrada > 10).Bool;
}

multi sub adicao ($rodadas, $casas) {
#A partir da quantidade de rodadas e casas especificadas pelo usuário, roda o programa
#requerendo os resultados de acordo com as especificações nos argumentos da função,
#executando a operação equivalente à adição
	my $inicio = now;
	my $acertos = 0;
	my $erros   = 0;
	my $letreiro = 
"+++++++++++++++++++++++++++++++++++++
+              ADIÇÃO               +
+++++++++++++++++++++++++++++++++++++\n"; 
	for (1 .. $rodadas) {
		shell 'clear';
		say color("bold green"), $letreiro, color('reset');
		my $numero1   = (10..10**$casas).rand.Int;
		my $numero2   = (10..10**$casas).rand.Int;
		my $tentativa = prompt ("$numero1 + $numero2 = ");
		my $resultado = computa-erro(+$tentativa, $numero1 + $numero2);
		if ($resultado == True) { $acertos++; }
		else                    { $erros++;   }
		sleep 1;
	}
	my $termino = now;
	put q:c:b [\nAcertos: {100*$acertos/$rodadas}%\nErros:   {100*$erros/$rodadas}%\n];
	put q:c:b [Tempo necessário {computa-tempo(($termino - $inicio).Int)}\n];
}


multi sub operacao-op ($func) {
#Requer sistematicamente que o usuário informe a quantidade de rodadas a serem jogadas 
#entre 2 e 50, e a quantidade de casas que ambos os números devem ter, de 2 a 10, pedindo
#seguidamente que o usuário entre com quantidades válidas caso ele não se mantenha nos
#domínios, ou saindo caso ele digite 'p'. Caso contrário, chama &adicao para continuar
#com o jogo
	my $entrada1 = prompt 'Quantidade de rodadas [2-50]: ';
	my $rodadas  = requer-result($entrada1, &retorna-cond2,
				    "\nQuantidade inválida.\nTente novamente [2-50]: ");

	my $entrada2 = prompt 'Quantidade de casas [2-10]: ';
	my $casas    = requer-result($entrada2, &retorna-cond3,
				       "\nQuantidade inválida.\nTente novamente [2-10]: ");
	&$func(+$rodadas, +$casas);
}


#===================== FIM DAS OPERAÇÕES BÁSICAS =========================#

#===================== INTERFACE INICIAL DO PROGRAMA =====================#
multi sub redireciona-op ($entrada) {
#Redireciona para a função requerida pelo usuário de acordo com 
#o índice que foi fornecido como entrada
	operacao-op(&adicao)        if $entrada == 1;
	operacao-op(&subtracao)     if $entrada == 2;
	operacao-op(&multiplicacao) if $entrada == 3;
	operacao-op(&divisao)       if $entrada == 4;
}

multi sub retorna-cond1 ( Str:D $entrada ) { 
#retorna a condição de número 1 para avaliação em &requer-result
	return any(!(+$entrada ~~ Int), +$entrada < 1, $entrada > 4).Bool;
}

multi sub requer-result ($entrada is rw, $conds, $aviso --> Str:D ) {
#Verifica a validade da condição de entrada como válida, primeiramente.
#Caso não se enquadre na especificação, termina o programa. Caso se enquadre
#verifica sua validade numérica, e continua requerindo por números ou pelo
#término do programa até que se obtenha um resultado utilizável
	if ($entrada eq 'q') { "Terminando...\n".put; exit };
	while ( &$conds($entrada) ) {
		put $aviso;
		$entrada = prompt '>';
		if ($entrada eq 'q') { "Terminando...\n".put; exit }
	}
	return $entrada;
}

multi sub inicia-abaco (--> Int:D ) {
#Faz a chamada da função primária de forma ao usuário saber quais
#são as opções disponíveis e dar entrada em um número válido. Caso
#o número não seja válido, continua demandando um válido ao usuário
	
	put color('bold red'), "Qual operação deve ser executada?", color('reset');
	put '(' ~ color('bold green'),  "1", color('reset') ~ ') Adição';
	put '(' ~ color('bold yellow'), "2", color('reset') ~ ') Subtração';
	put '(' ~ color('bold blue'),   "3", color('reset') ~ ') Multiplicação';
	put '(' ~ color('bold red'),    "4", color('reset') ~ ') Subtração';
	
	my $entrada = prompt '>';
	my $resultado = requer-result($entrada,
				      &retorna-cond1,
				      "Entrada inválida.\nTente novamente [1-4]");
	return +$resultado;
}
#======================= FIM DA INTERFACE INICIAL ========================#
