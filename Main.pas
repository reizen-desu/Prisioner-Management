Program RegistoCriminal;
Uses CRT, SysUtils, DateUtils, DOS, Graph;
	procedure menu; forward;
	procedure alterar; forward;

const ver = '3.0'; //Versao atual do programa.
	caminho = 'CriminalMinds\'; // Pasta base. Obs: Mude o directorio para alterar o destino dos arquivos.
		caminhoRelatorios = caminho+'Relatorios\';
		caminhoAtivos = caminho+'Activos\'; // Pasta onde serao gravados os arquivos que serao usados activamente.
				dbReclusos 	= caminhoAtivos+'Reclusos.db'; 
				dbVisitantes = caminhoAtivos+'Visitantes.db';
				dbLibertados = caminhoAtivos+'Libertados.db';

		caminhoArquivados = caminho+'Arquivados\'; // Pasta onde serao gravados os arquivos 'apagados'.
				dbReclusosArquivados = caminhoArquivados+'Reclusos.db';
				dbVisitantesArquivados = caminhoArquivados+'Visitantes.db';
				dbLibertadosArquivados = caminhoArquivados+'Libertados.db';

Type
	dadosRecluso = Record
		naoMostrar: Boolean; {Controlador que sera usado na listagem. Usado juntamente com apagado (Padrao: False)}
			apagado: Boolean; {Depois de apagado, o valor deve passar para True}
			libertado: Boolean; {Depois de libertado, o valor deve passar para True}
					nome,		{Nome completo do recluso em questao. }
					ala,		{Menores ou Adultos, dependendo da idade.}
					bi,			{Bilhete de Identidade do recluso em questao.}
		categoriaCrime,  		{Ha tres categorias: Leve, Grave e Macabro. }
		responsavel,			{Responsavel pelo menor de idade.}
		descricaoCrime,
		SerVoluntario,			{servicos voluntarios}
		corOlhos,
		corPele,
		corCabelo: String[150];
		genero: Char; 		{Jasse disse que nao gosta de sexo...}
		altura,	 idade,
					id,			{Numero UNICO atribuido a cada recluso.}
			comportamento,	{Conduta do recluso}
				peso,			{Peso do recluso}
			contacto,
			visitantes,		{Numero de visitantes recebidos}
		diaDetencao, mesDetencao, anoDetencao, horaDetencao, 	{Dados da data detencao.}
		diaSaida, mesSaida, anoSaida, horaSaida,
		diaNasc, mesNasc, anoNasc: Integer;		{Dados de nascimento do recluso.}
		dataDetencao, dataSaida, dataNasc: String[25];			{Concatenacao dos dados anteriores}
	end;

	dadosVisitante = Record
		naoMostrar: Boolean;		{Padrao: False}
			apagado: Boolean;
		visitando: Boolean;
		id: Integer;
		estaPresente: Boolean;	{Verificar se o visitante actualmente se encontra no centro.}
		nome, relacao, recluso: String[100];
		diaEntrada, mesEntrada, anoEntrada, horaEntrada,
		diaSaida, mesSaida, anoSaida, horaSaida,
				numeroDeVisitas:
					Integer;
		dataEntrada, dataSaida:	{Hora de entrada e saida da visita.} 
					String[25];
	end;

	dadosLibertado = record
		naoMostrar: Boolean;
		nome, ala, 		{O nr de BI foi omitido por enquanto...}
		categoriaCrime,
		descricaoCrime,
		motivo: String[150];
		genero: Char;
		altura, idade, id: Integer;

		dataNasc, diaNasc, mesNasc, anoNasc: Integer;
		dataDetencao, dataSaida,
		tempoPermanecido: 	{Tempo total permanecido no centro de detencao}
				String[35];
	end;

	dadosServicos = record
		nome, descricao: String;		{Nome e descrição do serviço}
				membros: 	Integer;	{Número de integrantes}
				estado: 	Boolean;	{Se está decorrendo ou não}
		inscritos: array[1..50] of Integer; {ID dos reclusos que estão a participar}

	end;

var //Variaveis usadas na gravacao de ficheiros.
	recluso: dadosRecluso;
	visitante: dadosVisitante;
	libertado: dadosLibertado;
	reclusoArquivo: file of dadosRecluso;
	visitanteArquivo: file of dadosVisitante;
	libertadoArquivo: file of dadosLibertado;
	f: text; // Variavel dos contadores (relatorio)

	//Outras variaveis
	opcao, i: Integer;		
	YYYY, MM, DD: Word;		{Referentes à Data.}
	HH, N, SS, MS: Word; {Referentes às Horas}
	// celas: text;


////////////////////////////////////////////////
////////	PROCEDIMENTOS AUXILIARES 		///////

///////// ECRA, ESTETICA DO PROGRAMA} ///////
	procedure mensagemTopo(texto: String; tipo: Byte);
	begin

	if tipo = 1 then
		begin
			Window(3, 1, 80, 3);
			TextBackground(white);
			ClrScr;
			texto := AnsiUpperCaseFileName(texto);
			GotoXY(6, 2);
			TextColor(black);
			Writeln(texto);
			TextBackground(black);
			TextColor(white);
			exit;
		end
	else if tipo = 2 then
		begin
			Window(3, 1, 80, 3);
			TextBackground(red);
			ClrScr;
			texto := AnsiUpperCaseFileName(texto);
			GotoXY(6, 2);
			TextColor(yellow);
			Writeln(texto);
			TextBackground(black);
			TextColor(white);
			exit;
		end
	else if tipo = 3 then
		begin
			Window(3, 1, 80, 3);
			TextBackground(green);
			ClrScr;
			texto := AnsiUpperCaseFileName(texto);
			GotoXY(6, 2);
			TextColor(white);
			Writeln(texto);
			TextBackground(black);
			TextColor(white);
			exit;
		end;
	end;
	
	procedure mensagemMenu(texto: String; x, y: Byte);
	begin	
		Window(3, 5, 80, 30);
		GotoXY(X, Y);
		write(texto);
	end;

	procedure mensagemMenuInt(texto: Integer; x, y: Byte);
	begin	
		Window(3, 5, 80, 30);
		GotoXY(X, Y);
		write(texto);
	end;

	procedure apagarMenu;
	begin
		Window(3, 5, 50, 30);
		TextBackground(black);
		ClrScr;
	end;

	procedure apagarTudo;
	begin
		Window(1,1,110,30);
		TextBackground(black);
		ClrScr;
	end;

	
	procedure dashboard(texto: String; x, y: Byte); {Tabela ao lado}
	begin
		Window(70, 1, 110, 30);
		TextBackground(8);
		ClrScr;
		GotoXY(x, y);
		TextColor(green);
		Write(texto);
		TextBackground(black);
		TextColor(white);
		exit;
	end;
	
	procedure mensagemRodape;
	begin
		Window(3, 31, 80, 32);
		TextBackground(white);
		ClrScr;
		TextColor(black);
		Writeln('Cryme - An Open Source Project');
		Write('Os justiceiros                                                       Ver.', ver);
		TextColor(white);
		TextBackground(black);
	end;

procedure desejaContinuar;
begin
	mensagemMenu('Deseja efectuar mais alguma operacao?', 1, 20);
	Writeln;
	Writeln('1. Voltar ao menu');
	Writeln('0. Sair');
	Readln(opcao);
	repeat
		case opcao of
			1: begin
				mensagemTopo('Reencaminhando ao menu...', 1);
				apagarMenu;
				apagarTudo;
				mensagemRodape;
				delay(500);
				menu;
			end;
			0: begin
				mensagemTopo('Encerrando o programa...', 2);
				apagarMenu;
				delay(1500);
				halt;
			end;
		end;
	until (opcao <> 1) or (opcao <> 0);
end;

//////////  CRIACAO DE ARQUIVOS PARA ARMAZENAMENTO /////////////
	procedure criarArquivos;
	begin
		//Criacao de um arquivo para armazenamento de Reclusos.
		Assign(reclusoArquivo, dbReclusos);
		{$I-}
		Reset(reclusoArquivo);
		{$I+}
		if IOResult <> 0 then ReWrite(reclusoArquivo);
		Close(reclusoArquivo);
		Assign(reclusoArquivo, dbReclusos);

		//Criacao de um arquivo para armazenamento de Visitantes.
		Assign(visitanteArquivo, dbVisitantes);
		{$I-}
		Reset(visitanteArquivo);
		{$I+}
		if IOResult <> 0 then ReWrite(visitanteArquivo);
		Close(visitanteArquivo);
		Assign(visitanteArquivo, dbVisitantes);

		// Criacao de um arquivo para armazenamento de Libertados.
		Assign(libertadoArquivo, dbLibertados);
		{$I-}
		Reset(libertadoArquivo);
		{$I+}
		if IOResult <> 0 then ReWrite(libertadoArquivo);
		Close(libertadoArquivo);

	end;
	
////////// CRIAÇÃO DE DIRECTORIOS   ///////////
	procedure criarDirectorios;
	begin		
		if DirectoryExists(caminho) then exit // Caso o directorio exista, ele saira.
		else begin // Casao nao, as pastas serao criadas.
				CreateDir(caminho);
					CreateDir(caminhoAtivos);
					CreateDir(caminhoArquivados);
					CreateDir(caminhoRelatorios);
				criarArquivos; //Inclusive, serao criadas tambem arquivos.
			 end;
	end;
////////// MANIPULACAO DE ARQUIVOS ///////////
	function reclusoExiste(nome: String): Boolean; 
	{Verifica se um determinado nome existe dentro do arquivo recluso.}
	begin
		// Assign(reclusoArquivo, dbReclusos);
		// {$I-}
		Reset(reclusoArquivo);
		// {$I+}
		reclusoExiste := false;
		if IOResult > 0 then exit;
		nome := AnsiUpperCaseFileName(nome);
		while not eof(reclusoArquivo) do
			begin
				Read(reclusoArquivo, recluso);
				if recluso.nome = nome then 
					begin
						reclusoExiste := true;
						Close(reclusoArquivo);
						exit;
					end;
			end;
		Close(reclusoArquivo);
	end;
	
	function visitanteExiste (nome: String): Boolean; 
	{Compara um nome introduzido com os nomes do arquivo visitante.}
	begin
		Reset(visitanteArquivo);
		visitanteExiste := false;
		nome := AnsiUpperCaseFileName(nome);
		while not eof(visitanteArquivo) do
			begin
				Read(visitanteArquivo, visitante);
				if visitante.nome = nome then 
					begin
						visitanteExiste :=  true;
						Close(visitanteArquivo);
						exit;
					end;
			end;
	end;
	
	procedure arquivarRecluso(nome: String);
	{Como funciona: Copia todos os dados no arquivo Recluso (ativo) e}
	{coloca-os no arquivo ReclusoArquivado, e muda o valor da variavel }
	{"naoMostar" para Verdadeira.}
	begin
		
	end;


	function lerID(quem: Integer; nome: String): Integer;
	{Retorna o ID para o individuo especificado no "quem";}
	{Opcoes para quem: 1 = Recluso, 2 = Visitante e 3 = Libertado}
	{No nome, é onde coloca-se o nome do "quem".}
	{Ex: lerID(2, visitante.nome)}
	begin
		
		nome := AnsiUpperCaseFileName(nome);

		case quem of
			1: 	begin {Para reclusos}
					Reset(reclusoArquivo);
					while not eof(reclusoArquivo) do					
						begin
							Read(reclusoArquivo, recluso);  
							if recluso.nome = nome then 
								begin
									lerID := recluso.id;
									Close(reclusoArquivo);
									exit;
								end;
						end;
					Close(reclusoArquivo);
					lerID := 0;
					exit;
				end;
			2: begin {Para visitantes}
					Reset(visitanteArquivo);
					while not eof(visitanteArquivo) do					
						begin
							Read(visitanteArquivo, visitante);  
							if visitante.nome = nome then 
								begin
									lerID := recluso.id;
									Close(visitanteArquivo);
									exit;
								end;
						end;
					Close(visitanteArquivo);
					lerID := 0;
					exit;
				end;
			3:	begin {Para Libertados}
					Reset(libertadoArquivo);
					while not eof(libertadoArquivo) do
						begin
							Read(libertadoArquivo, libertado);
							if libertado.nome = nome then 
								begin
									lerID := libertado.id;
									Close(libertadoArquivo);
									exit;
								end;
						end;
					Close(libertadoArquivo);
					lerID := 0;
					exit;
				end;
		end;
	end;
	
	function lerNome(quem, id: Integer): String;
	(*Esta funcao recebe um ID e retorna o nome que pertence ao ID.
		É o inverso do "lerID"
	1 = Recluso; 2 = Visitante; 3 = Libertado;
	*)
	var
		posicao: Integer;
	begin
		
		posicao := id;

		case quem of
			1: 	begin {Para reclusos}
					Reset(reclusoArquivo);
					Seek(reclusoArquivo, id);
					Read(reclusoArquivo, recluso);
					lerNome := recluso.nome;
					Close(reclusoArquivo);
					exit;
				end;
			2: 	begin {Para visitantes}
					Reset(visitanteArquivo);
					Seek(visitanteArquivo, posicao);
					Read(reclusoArquivo, recluso);
					lerNome := visitante.nome;
					Close(visitanteArquivo);			
					exit;
				end;
			3:	begin {Para Libertados}
					Reset(libertadoArquivo);
					Seek(libertadoArquivo, posicao);
					Read(reclusoArquivo, recluso);
					lerNome := libertado.nome;
					Close(libertadoArquivo);
					exit;
				end;
			else lerNome := '';
		end;
	end;

 function visitasActivas: Integer;
 {Descricao: Retorna quantas visitas estao no centro no momento.}
 var
 	temp: Integer;
 begin
 	 Reset(visitanteArquivo);
 	 temp := 0;
 	 while not eof(visitanteArquivo) do
 	 begin
 	 	Read(visitanteArquivo, visitante);
 	 	if visitante.visitando = true then temp := temp + 1;
 	 end;
 	 Close(visitanteArquivo);
 	 visitasActivas := temp;
 end;




 procedure adicionarRelatorio(nome: String; quantidade: Integer);
		(*Ex: relatorio('reclusos', 1) <-- Adiciona 1 ao relatorio dos reclusos.
		  Para mais opcoes veja a lista de variaveis abaixo.
		  Para remover um faca: relatorio('reclusos', -1) <-- Remove 1 ao relatorio do mesmo*)	
	var
		acessos, modificacoes, operacoes,
		reclusos, visitantes, libertados, maiores, menores,
		idrecluso, idvisitante, idlibertado, fuga, celas, 
		arquivados, familiar, advogado, amigo, crimeLeve, crimeGrave, crimeMacabro,
		loginfalha, visitanteActivo, penaLeve, penaGrave, penaMacabro:
					Integer;
	begin
		Assign(f, caminhoRelatorios+nome+'.txt');
		{$I-}
		Reset(f);
		{$I+}
		if IOResult <> 0 then //Cria um arquivo se nao existe
			begin
				ReWrite(f);
				write(f, quantidade);
				Close(f);
				exit;
			end;	

		case nome of
			'acessos', 'acesso':  begin
						read(f, acessos);
						acessos := quantidade + acessos;
						Close(f);
						ReWrite(f);
						write(f, acessos);
					end;
			'modificacoes','modificacao':  
							begin
						read(f, modificacoes);
						modificacoes := quantidade + modificacoes;
						Close(f);
						ReWrite(f);
						write(f, modificacoes);					
							end;
			'operacoes','operacao':  
						begin
						read(f, modificacoes);
						modificacoes := quantidade + modificacoes;
						Close(f);
						ReWrite(f);
						write(f, modificacoes);
						end;
			'reclusos', 'recluso':  
						begin
						read(f, reclusos);
						reclusos := quantidade + reclusos;
						Close(f);
						ReWrite(f);
						write(f, reclusos);
						end;
			'visitantes', 'visitante':  
						begin
						read(f, visitantes);
						visitantes := quantidade + visitantes;
						Close(f);
						ReWrite(f);
						write(f, visitantes);
						end;
			'libertados', 'libertado':  
						begin
						read(f, libertados);
						libertados := quantidade + libertados;
						Close(f);
						ReWrite(f);
						write(f, libertados);
						end;
			'maiores', 'maior':  
						begin
						read(f, maiores);
						maiores := quantidade + maiores;
						Close(f);
						ReWrite(f);
						write(f, maiores);
						end;
			'menores', 'menor':  
						begin
						read(f, menores);
						menores := quantidade + menores;
						Close(f);
						ReWrite(f);
						write(f, menores);
						end;
			'idRecluso':  begin
						read(f, idrecluso);
						idrecluso := quantidade + idrecluso;
						Close(f);
						ReWrite(f);
						write(f, idrecluso);
						end;
			'idVisitante':  begin
						read(f, idVisitante);
						idVisitante := quantidade + idVisitante;
						Close(f);
						ReWrite(f);
						write(f, idVisitante);
						end;
			'idLibertado':  begin
						read(f, idLibertado);
						acessos := quantidade + acessos;
						Close(f);
						ReWrite(f);
						write(f, acessos);
						end;
			'fuga':  begin
						read(f, fuga);
						fuga := quantidade + fuga;
						Close(f);
						ReWrite(f);
						write(f, fuga);
						end;
			'arquivados', 'arquivado': begin
							read(f, arquivados);
							arquivados := quantidade + arquivados;
							Close(f);
							ReWrite(f);
							write(f, arquivados);
						end;
			'familiar', 'familiares': begin
						read(f, familiar);
						familiar := quantidade + familiar;
						Close(f);
						ReWrite(f);
						write(f, familiar);
					end;		
			'advogado', 'advogados': begin
						Read(f, advogado);
						advogado := quantidade + advogado;
						Close(f);
						ReWrite(f);
						write(f, advogado);
					end;		
			'amigo', 'amigos': begin
						Read(f, amigo);
						amigo := quantidade + amigo;
						Close(f);
						ReWrite(f);
						write(f, amigo);
					end;		

			'loginfalha': begin
						Read(f, loginfalha);
						loginfalha := quantidade + loginfalha;
						Close(f);
						ReWrite(f);
						write(f, loginfalha);
					end;		
			'crimeLeve': begin
						Read(f, crimeLeve);
						crimeLeve := quantidade + crimeLeve;
						Close(f);
						ReWrite(f);
						write(f, crimeLeve);
					end;	

			'crimeGrave': begin
						Read(f, crimeGrave);
						crimeGrave := quantidade + crimeGrave;
						Close(f);
						ReWrite(f);
						write(f, crimeGrave);
					end;	

			'crimeMacabro': begin
						Read(f, crimeMacabro);
						crimeMacabro := quantidade + crimeMacabro;
						Close(f);
						ReWrite(f);
						write(f, crimeMacabro);
					end;	

			'visitanteActivo': begin
						Read(f, visitanteActivo);
						visitanteActivo := quantidade + visitanteActivo;
						Close(f);
						ReWrite(f);
						write(f, visitanteActivo);
					end;	

			'celas': begin
						Read(f, celas);
						celas := quantidade + celas;
						Close(f);
						ReWrite(f);
						write(f, celas);
					end;	
					
			'penaLeve': begin
						Read(f, penaLeve);
						penaLeve := quantidade + penaLeve;
						Close(f);
						ReWrite(f);
						write(f, penaLeve);
					end;	
					
			'penaGrave': begin
						Read(f, penaGrave);
						penaGrave := quantidade + penaGrave;
						Close(f);
						ReWrite(f);
						write(f, penaGrave);
					end;	
					
			'penaMacabro': begin
						Read(f, penaMacabro);
						penaMacabro := quantidade + penaMacabro;
						Close(f);
						ReWrite(f);
						write(f, penaMacabro);
					end;	
			



			else 
				Writeln('Erro na gravacao da contagem');
		end;
		Close(f);
	end;	
	

	function lerRelatorio(nome: String): Integer;
	var
		acessos, modificacoes, operacoes,
		reclusos, visitantes, libertados, maiores, menores,
		idrecluso, idvisitante, idlibertado, fuga, 
		arquivados, familiar, advogado, amigo, loginfalha,
		crimeLeve, crimeGrave, crimeMacabro, visitanteActivo,
		celas, penaLeve, penaGrave, penaMacabro:
					Integer;
	begin
		Assign(f, caminhoRelatorios+nome+'.txt');
		{$I-}
		Reset(f);
		{$I+}
		if IOResult <> 0 then //Sai prematuramente com o retorno 0.
			begin
				lerRelatorio := 0;
				exit;
			end;	

		case nome of
			'acessos', 'acesso':  begin
						read(f, acessos);
						lerRelatorio := acessos;
					end;
			'modificacoes','modificacao':  
							begin
						read(f, modificacoes);
						lerRelatorio := modificacoes;
					end;
			'operacoes','operacao':  
						begin
						read(f, modificacoes);
						lerRelatorio := modificacoes;
					end;
			'reclusos','recluso':  
						begin
						read(f, reclusos);
						lerRelatorio := reclusos;
					end;
			'visitantes', 'visitante':  
						begin
						read(f, visitantes);
						lerRelatorio := visitantes;
					end;
			'libertados', 'libertado':  
						begin
						read(f, libertados);
						lerRelatorio := libertados;
					end;
			'maiores', 'maior':  
						begin
						read(f, maiores);
						lerRelatorio := maiores;
					end;
			'menores', 'menor':  
						begin
						read(f, menores);
						lerRelatorio := menores;
					end;
			'idRecluso':  begin
						read(f, idrecluso);
						lerRelatorio := idrecluso;
					end;
			'idVisitante':  begin
						read(f, idVisitante);
						lerRelatorio := idVisitante;
					end;
			'idLibertado':  begin
						read(f, idLibertado);
						lerRelatorio := idLibertado;
					end;
			'fuga':  begin
						read(f, fuga);
						lerRelatorio := fuga;
					end;	
			'arquivados', 'arquivado':  begin
						read(f, arquivados);
						lerRelatorio := arquivados;
					end;	
			'familiar', 'familiares': begin
						read(f, familiar);
						lerRelatorio := familiar;
					end;		
			'advogado', 'advogados': begin
						read(f, advogado);
						lerRelatorio := advogado;
					end;		
			'amigo', 'amigos': begin
						read(f, amigo);
						lerRelatorio := amigo;
					end;		
			'loginfalha': begin
						read(f, loginfalha);
						lerRelatorio := loginfalha;
					end;	

			'crimeLeve': begin
						read(f, crimeLeve);
						lerRelatorio := crimeLeve;
					end;	

			'crimeGrave': begin
						read(f, crimeGrave);
						lerRelatorio := crimeGrave;
					end;	

			'crimeMacabro': begin
						read(f, crimeMacabro);
						lerRelatorio := crimeMacabro;
					end;

			'visitanteActivo': begin
						read(f, visitanteActivo);
						lerRelatorio := visitanteActivo;
					end;

			'celas': begin
						read(f, celas);
						lerRelatorio := celas;
					end;

			'penaLeve': begin
						read(f, penaLeve);
						lerRelatorio := penaLeve;
					end;

			'penaGrave': begin
						read(f, penaGrave);
						lerRelatorio := penaGrave;
					end;

			'penaMacabro': begin
						read(f, penaMacabro);
						lerRelatorio := penaMacabro;
					end;

			else 
				lerRelatorio := 0;
		end;
		Close(f);
	end;

////////	FIM ― PROCEDIMENTOS AUXILIARES	////
////////////////////////////////////////////////





// Comentario: Este procedimento precisa de melhorias... pois esta muito baguncado.
procedure login;
type
	dados = Record
		nome, usuario, senha: String[50];
	end;
var
	admin: dados;
	db: file of dados;
	usuario, senha: String[50]; //Variaveis usadas no login para comparacao.
	celas, penaLeve, penaGrave, penaMacabro: Integer;

begin
	Assign(db, caminho+'login.encrypted');
	{$I-}
	Reset(db);
	{$I+}
	if IOResult <> 0 then //Gravam-se os dados de administrador caso nao tenha um arquivo existente. 
		begin
			ReWrite(db); 

			mensagemRodape;
			mensagemTopo('Primeiro acesso ao programa', 1);
			mensagemMenu('Bem vindo. Preencha os dados abaixo.', 1,2);
			mensagemMenu('Nome: ',1,3);
			Readln(admin.nome);
			mensagemMenu('Utilizador: ', 1,6);
			Readln(admin.usuario);
			Write('Senha: ');
			TextColor(black);
			Readln(admin.senha);
			TextBackground(white);

			Seek(db, 0);
			Write(db, admin);
			Close(db);

			apagarTudo;
			mensagemTopo('Conta criada com sucesso!!', 3);
			delay(1000);
			
			//Bloco das Configuroes do programa
			apagarTudo;
			mensagemTopo('Configuracoes do sistema', 1);
			mensagemMenu('Configurando...',1,1);
			Writeln;
			Writeln;

			Write('Numero de celas: ');
			Readln(celas);
			// Writeln('Definicao de penas ');
			// Write('Leve: ');
			// Readln(penaLeve);
			// Write('Grave: ');
			// Readln(penaGrave);
			// Write('Macabro: ');
			// Readln(penaMacabro);


			adicionarRelatorio('celas', celas);
			adicionarRelatorio('penaLeve', penaLeve);
			adicionarRelatorio('penaGrave', penaGrave);
			adicionarRelatorio('penaMacabro', penaMacabro);


			apagarMenu;
			mensagemMenu('Pressione qualquer tecla', 3,10);
			mensagemMenu('Para retornar ao login.',3,11);

			readkey;
			login;
		end
	else 
		begin //Faz-se uso dos dados do arquivo para verificacao de dados de login.
			mensagemRodape;
			apagarMenu;
			for i := 1 to 3 do //Onde 3 é o número de tentativas restantes
				begin
					mensagemTopo('login', 1);
					mensagemMenu('', 1, 17);
					Writeln('Tentativas restantes: ', 4-i);
					mensagemMenu('Utilizador: ',1,5);
					Readln(usuario);
					Write('Senha: ');
					TextColor(black);
					Readln(senha);
					TextBackground(white);

					Seek(db, 0);
					Read(db, admin);

					if (usuario = admin.usuario) and (senha = admin.senha) then
						begin
							Close(db);
							apagarMenu;
							adicionarRelatorio('acessos', 1);
							mensagemTopo('Logado com sucesso!!',3);
							delay(1500);
							mensagemTopo('Reencaminhando ao menu...', 1);
							delay(2000);
							exit;
						end
					else begin
							mensagemTopo('Utilizador ou senha incorrecta!', 2);
							apagarMenu;
							delay(1000);
						 end;
				end;

			Close(db);
			mensagemTopo('Erro no login tres vezes seguidas!! Encerrando o programa...', 2);
			delay(3500);
			halt;
		end;
end;







//OPCAO #11
procedure ajuda;
begin
	Writeln('Opcoes: ');
	Writeln('1. FAQ (Em desenvolvimento)');
	Writeln('2. Abrir manual de instrucoes');
	Readln(opcao);
	ClrScr;
	case opcao of
		1: 	begin
				Writeln('1. Quantos usuarios podem usar o programa?');
				Writeln('R: Esta previsto que apenas um individuo responsavel, e que este se');
				Writeln('encontre na recepcao podera manejar o programa.');
				Writeln;
				Writeln('Obs: Se alguma duvida nao estiver esclarecida leia o guia ou');
				Writeln('contacte-nos.');
				Writeln;
				Writeln('(Ainda em construcao)');
				Writeln('Pressione qualquer tecla para sair');
				readkey;
				exit;
			end;
		2:  begin
				if FileExists('SumatraPDF\SumatraPDF.exe') and FileExists('manual.pdf') then
					Exec('C:\Program Files\SumatraPDF\SumatraPDF.exe', 'manual.pdf')
				else Exec('C:\Windows\System32\notepad.exe', 'manual.txt');
			end;
		else ajuda
	end;
end;

//OPCAO #10
procedure pesquisar;
var
	nome: String;
begin
	apagarTudo;
	mensagemTopo('Dados de Pesquisa', 1);

	mensagemMenu('Introduza o nome: ',1,1);
	Writeln;
	Readln(nome);
	nome := AnsiUpperCaseFileName(nome);

	if reclusoExiste(nome) then
		begin
			apagarTudo;
			mensagemTopo('Registo encontrado', 3);
			mensagemMenu('', 1,1);
			Writeln; 
			Writeln('ID:                  ', recluso.id);
			Writeln('Nome:                ', recluso.nome);
			Writeln('No de BI:            ', recluso.bi);
			Writeln('Altura:              ', recluso.altura ,' cm');
			Writeln('Categoria de crime:  ', recluso.categoriaCrime);
			Writeln('Descricao de crime:  ', recluso.descricaoCrime);
			Writeln('Data de Nascimento:  ', recluso.diaNasc,'-',recluso.mesNasc,'-',recluso.anoNasc);
			Writeln('Data de Detencao:    ', recluso.diaDetencao,'-',recluso.mesDetencao,'-',recluso.anoDetencao);
			Writeln('Idade:               ', recluso.idade);
			if recluso.idade < 18 then //Exibe o nome do responsavel se for menor de idade
				begin
					Writeln('Responsavel:               ', recluso.responsavel);
					Writeln('Contacto do Responsavel: ', recluso.contacto );
				end;	

			Writeln;
			Writeln;
			Writeln('Deseja voltar a tentar com outro nome?');
			Writeln('1. Sim');
			Writeln('2. Voltar ao menu');
			Writeln('3. Sair');

			Readln(opcao);

			case opcao of
				1: begin
					apagarTudo;
					pesquisar;
				end;

				2: begin
					apagarTudo;
					menu;
				end;

				3: begin
					apagarTudo;
					mensagemTopo('Encerrando o programa...', 2);
					delay(1000);
					halt;
				end;
			end;
		end
	else begin
		repeat
		apagarTudo;
		mensagemTopo('Nao encontrado', 2);
		mensagemMenu('Nao foi encontrado nenhum registo com o nome introduzido.',1,1);
		Writeln;
		Writeln('Deseja voltar a tentar com outro nome?');
		Writeln('1. Sim');
		Writeln('2. Voltar ao menu');
		Writeln('3. Sair');

		Readln(opcao);

			case opcao of
				1: begin
					apagarTudo;
					pesquisar;
				end;

				2: begin
					apagarTudo;
					menu;
				end;

				3: begin
					apagarTudo;
					mensagemTopo('Encerrando o programa...', 2);
					delay(1000);
					halt;
				end;
			end;
		until (opcao = 1) or (opcao = 2) or (opcao = 3);
	end;
end;

//OPCAO #9
procedure relatorios;
begin
	mensagemTopo('Relatorios', 1);
	apagarMenu;
	mensagemMenu('Visao geral do sistema',27,1);
	Writeln;
	Writeln('Numero de reclusos:  ', lerRelatorio('reclusos'));
	Writeln('Numero de visitantes:  ', lerRelatorio('visitantes'));
	Writeln('Numero de reclusos adultos: ', lerRelatorio('maiores'));
	Writeln('Numero de reclusos menores: ', lerRelatorio('menores'));
	Writeln('Numero de Reclusos libertados: ', lerRelatorio('libertados'));
	Writeln('Numero de fugitivos: ', lerRelatorio('fuga'));
	Writeln;
	Writeln;
	// Writeln('                                Miscelania:');
	Writeln();
	// Writeln('Numero de operacoes realizadas: ', lerRelatorio('operacoes'));
	Writeln('Numero de acessos: ', lerRelatorio('acessos')); 
	Writeln('Numero de modificacoes realizadas: ', lerRelatorio('operacoes'));
	Writeln;
	desejaContinuar;
end;



//OPCAO #8
procedure excluir;
var
	temp, posicao, idade: Integer;
	id, nome: String;
	erro: Integer;
	anoSaida, mesSaida, diaSaida: String;

begin
	apagarTudo;
	// dashboard('Tome cuidado', 1,4);
	mensagemTopo('Proceda com cautela', 1);
	mensagemMenu(' __', 50,20);
	mensagemMenu('|  /', 50, 21);
	mensagemMenu('|_/', 50, 22);
	mensagemMenu('.-.', 50, 23);
	mensagemMenu('`-''', 50, 24);

	Reset(reclusoArquivo);

		Reset(reclusoArquivo);

	mensagemMenu('ID', 1,1);
	mensagemMenu('Nome', 4,1);
	mensagemMenu('Categoria', 35,1);
	mensagemMenu('Entrada', 45,1);

	temp := 1;
	while not eof(reclusoArquivo) do
	begin
		temp := temp + 1;
		Read(reclusoArquivo, recluso);
		if recluso.apagado = true then continue;
		if recluso.naoMostrar = true then continue;
		if recluso.idade = 0 then continue;
		Str(recluso.id, id);
		mensagemMenu(id, 1,temp);
		mensagemMenu(recluso.nome, 4,temp);
		MensagemMenu(recluso.categoriaCrime,35,temp);
		mensagemMenu(recluso.dataDetencao, 45, temp);
	end;

	Writeln;
	Writeln;
	Writeln;
	Write('Escolha o ID que gostaria de libertar: ');
	
	repeat
		Readln(posicao);
	until (posicao > 0) and (posicao < FileSize(reclusoArquivo));

	idade := recluso.idade;
	Close(reclusoArquivo);

	nome := lerNome(1, posicao);
	// if nome = '' then readkey;
		if not reclusoExiste(nome) then
			begin
				mensagemTopo('404 | Not Found!', 2);
				apagarTudo;
				apagarMenu;
				Writeln('Nao foi encontrado nenhum registo com');
				writeln('o ID introduzido.');
				delay(500);
				Writeln;
				Writeln;
				Writeln('1. Tentar com outro ID');
				Writeln('2. Retornar ao menu principal');
				Writeln('0. Sair');
				Readln(opcao);

				case opcao of
					1: excluir;
					2: menu; 
					0: begin
							apagarMenu;
							mensagemTopo('Saindo...', 1);
							delay(1000);
							halt;
						end;
				end;
			end
		else begin
			apagarTudo;
			mensagemTopo('Confirmacao - Libertar', 3);
			mensagemMenu('Tem a certeza que pretende libertar '+lerNome(1, posicao)+'?',1,2);
			Writeln;
			Writeln('1. Sim');
			Writeln('2. Cancelar');
			Writeln('0. Cancelar e sair.');

			Readln(opcao);
			case opcao of
				1: begin
					Reset(reclusoArquivo);
					Seek(reclusoArquivo, posicao);
					recluso.naoMostrar := true;
					recluso.apagado := true;
					recluso.libertado := true;

					DecodeDate(Date, YYYY,MM,DD);
					DecodeTime(Time, HH,MM,SS,MS);

					anoSaida := FormatDateTime('YYYY', Now);
					Val(anoSaida, recluso.anoSaida, erro);

					mesSaida := FormatDateTime('MM', Now);
					Val(mesSaida, recluso.mesSaida, erro);

					diaSaida := FormatDateTime('DD', Now);
					Val(diaSaida, recluso.diaSaida, erro);

					recluso.dataSaida := anoSaida+'-'+mesSaida+'-'+diaSaida;


					Write(reclusoArquivo, recluso);
					Close(reclusoArquivo);

					adicionarRelatorio('libertados', 1);
					adicionarRelatorio('reclusos', -1);
					if idade < 18 then adicionarRelatorio('menores', -1)
					else adicionarRelatorio('maiores', -1);

					apagarTudo;
					mensagemTopo('Recluso liberto com sucesso!', 3);
					desejaContinuar;

				end;

				2: begin
					apagarTudo;
					mensagemTopo('Operacao cancelada!', 2);
					mensagemMenu('Pressione em qualquer tecla para retornar', 2,5);
					readkey;
					apagarTudo;
					menu;
				end;

				0: begin
					apagarTudo;
					mensagemTopo('Encerrando o programa...', 1);
					delay(1500);
					halt;
				end;
		end;
		adicionarRelatorio('operacoes', 1);
	end;
end;

//OPCAO #7
procedure libertar;
var
	temp, posicao, idade: Integer;
	id, nome: String;
begin
	apagarTudo;
	mensagemTopo('Libertar', 1);
	// dashboard('Tome cuidado', 1,4);

	Reset(reclusoArquivo);

	mensagemMenu('ID', 1,1);
	mensagemMenu('Nome', 4,1);
	mensagemMenu('Categoria', 35,1);
	mensagemMenu('Entrada', 45,1);

	temp := 1;
	while not eof(reclusoArquivo) do
	begin
		temp := temp + 1;
		Read(reclusoArquivo, recluso);
		if recluso.apagado = true then continue;
		if recluso.naoMostrar = true then continue;
		if recluso.idade = 0 then continue;
		Str(recluso.id, id);
		mensagemMenu(id, 1,temp);
		mensagemMenu(recluso.nome, 4,temp);
		MensagemMenu(recluso.categoriaCrime,35,temp);
		mensagemMenu(recluso.dataDetencao, 45, temp);
	end;

	Writeln;
	Writeln;
	Writeln;
	Write('Escolha o ID que gostaria de libertar: ');
	repeat
		Readln(posicao);
	until (posicao > 0) and (posicao < FileSize(reclusoArquivo));

	idade := recluso.idade;
	Close(reclusoArquivo);




	///////////
end;
//OPCAO #6
procedure servicosVoluntarios;
var
	nome, id: String;
	temp: Integer;
begin
	apagarMenu;
	mensagemTopo('Servicos Voluntarios', 1);
	mensagemMenu('',1,1);
	Writeln('1. Aceder a lista de servicos');
	Writeln('2. Registar novo servico');
	Writeln('3. Apagar servico');
	Writeln;
	Write('Opcao: '); Readln(opcao);

	case opcao of
		1: begin
				
		end;

		2: begin
			
		end;

		3: begin
			
		end;
		else 
			;
	end;
end;


//OPCAO #5
procedure visitas;
var
	ultimoID, erro, temp, {id, erro e temp são variáveis temporárias então não tem muita importância}
	posicao, idTemp: {Posicao refere-se à posição do ID. posição = 2 é igual a ID = 2.} 
		Integer;
	nome, id, reclusoTemp, nomeTemp: String;
	avanca: Boolean;
	
	anoDetencao, mesDetencao, diaDetencao, horaDetencao: String;
begin
	apagarMenu;
	apagarTudo;
	mensagemTopo('Menu - Visitas',1);
	mensagemMenu('Opcoes', 34, 1);
	Writeln;
	Writeln;
	Writeln('1. Registar visitante');
	Writeln('2. Fazer visita');
	Writeln('3. Encerrar visita');
	Readln(opcao);

	case opcao of
			1:  begin
				apagarTudo;
				mensagemTopo('Registar visitante', 1);

				// Bloco de leitura de ID. Faz a leitura do ultimo ID para registo de visitante.
				Reset(visitanteArquivo);
				if (FileSize(visitanteArquivo) = 0) then ultimoID := 1
				else ultimoID := FileSize(visitanteArquivo);
				Close(visitanteArquivo);
				apagarMenu;
				
				// Daqui em diante começa o registo.
				mensagemTopo('Novo Visitante ', 1);
				mensagemMenu('Registo no. ', 29,1);
				Writeln(ultimoID);
				Writeln;
				Writeln;
				Write('Nome do visitante: ');
				Readln(nome);
				nome := AnsiUpperCaseFileName(nome);

				//Bloco para verificacao da existencia de um visitante com o mesmo nome.
				if visitanteExiste(nome) then
				begin
					apagarTudo;
					mensagemTopo('O nome ja existe no sistema!', 2);
					apagarMenu;
					MensagemMenu('Ja tem um registo com o mesmo nome.', 1,5);
					delay(200);
					Writeln;
					Writeln;
					Writeln('1. Voltar ao Menu Visitas');
					Writeln('2. Retornar ao menu principal');
					Writeln('0. Sair');
					Readln(opcao);

					repeat
						case opcao of
							1: visitas;
							2: menu; 
							0: begin
									apagarMenu;
									mensagemTopo('Encerrando o programa...', 1);
									delay(1000);
									halt;
								end;
						end;
					until (opcao = 1) or (opcao = 2) or (opcao = 3);
				end;


				//--Criacao de um novo visitante--

				LowVideo; //Faz as letras ficarem meio cinzentas, que nem comentarios.

				//Bloco listagem de reclusos
				Reset(reclusoArquivo); //Lista todos os reclusos disponiveis para visita
				mensagemMenu('ID', 1,7);
				mensagemMenu('Nome', 4,7);
				temp := 7;
				while not eof(reclusoArquivo) do
				begin
					Read(reclusoArquivo, recluso);
					if recluso.apagado = true then continue; //Verifica se recluso foi arquivado 
					if recluso.idade = 0 then continue; //Verifica se recluso é inválido
							
					temp := temp + 1;
					Str(recluso.id, id);
					mensagemMenu(id, 1,temp);
					mensagemMenu(recluso.nome, 4,temp);
				end;
				Close(reclusoArquivo); //Fecha o arquivo para leitura de dados

				HighVideo; // Volta a normalidade (letras normais)
				Writeln;
				Writeln;
				Write('Escolha o ID do recluso que pretende visitar: ');
				repeat
					Readln(posicao);
				until (posicao > 0) and (posicao < (temp-6));
					GotoXY(wherex, wherey-1);
					delline;
				reclusoTemp := lerNome(1, posicao);
				// Close(reclusoArquivo); //Fecha o arquivo para leitura de dados

				Reset(visitanteArquivo); 	//Abre arquivo para inicio de gravacao
				Seek(visitanteArquivo, ultimoID); 	//Vai ate a ultima posicao do registo
				visitante.nome := nome; 	//Atribui o nome pedido no inicio para o visitante.
				visitante.naoMostrar := false;
				visitante.visitando := false;		//Status atual: Se está actualmente em visita ou não
				visitante.recluso := reclusoTemp;	//Grava o nome do recluso (a quem o visitante pretende visitar)
				visitante.id := ultimoID;

				//Bloco de colecção da data atual do registo
				DecodeDate(Date, YYYY,MM,DD);
				DecodeTime(Time, HH,MM,SS,MS);

				anoDetencao := FormatDateTime('YYYY', Now);
				Val(anoDetencao, visitante.anoEntrada, erro);

				mesDetencao := FormatDateTime('MM', Now);
				Val(mesDetencao, visitante.mesEntrada, erro);

				diaDetencao := FormatDateTime('DD', Now);
				Val(diaDetencao, visitante.diaEntrada, erro);
				visitante.dataEntrada := anoDetencao+'-'+mesDetencao+'-'+diaDetencao;

				horaDetencao := FormatDateTime('hh:mm', Now);
				Val(horaDetencao, visitante.horaEntrada, erro);


				Writeln('Relacao: ');
				Writeln('1. Familiar');
				Writeln('2. Amigo');
				Writeln('3. Advogado');
				repeat
					Readln(opcao);
					case opcao of
						1: begin
							visitante.relacao := 'Familiar';
							adicionarRelatorio('familiar', 1);
						end;
						2: begin
							visitante.relacao := 'Amigo';
							adicionarRelatorio('amigo', 1);
						end;
						3: begin
							visitante.relacao := 'Advogado';
							adicionarRelatorio('advogado', 1);
						end;
					end;
					Readln(opcao);
					GotoXY(1, wherey-1);
					delline;
				until (opcao = 1) or (opcao = 2) or (opcao = 3);

				visitante.numeroDeVisitas := 0;

				Write(visitanteArquivo, visitante);
				Close(visitanteArquivo); //--Fim de registo de visitante.

				apagarTudo;
				adicionarRelatorio('visitantes', 1);
				mensagemTopo('Registo completo!', 3);
				mensagemMenu('Pretende fazer a visita agora?',1,1);
				Writeln;
				Writeln('1. Sim');
				Writeln('2. Retornar ao menu');
				Writeln('0. Cancelar e sair.');
				Readln(opcao);
				case opcao of
					1: begin
						apagarTudo;
						visitas;
					end;

					2: begin
						apagarTudo;
						mensagemTopo('Retornando ao menu...', 1);
						delay(1000);
						menu;
					end;

					0: begin
						apagarTudo;
						mensagemTopo('Encerrando o programa...', 1);
						delay(1500);
						halt;
					end;
				end;
			end;

			2: begin //FAZER VISITA
					apagarTudo;
					mensagemTopo('Fazer visita', 1);

					mensagemMenu('',1,1);
					Reset(visitanteArquivo); //Lista todos os visitantes disponiveis para visita
					mensagemMenu('ID', 1,7);
					mensagemMenu('Nome', 4,7);
					temp := 7;
					while not eof(visitanteArquivo) do
						begin
							Read(visitanteArquivo, visitante);
							if visitante.apagado = true then continue; //Verifica se visitante foi arquivado 		
							if visitante.id = 0 then continue;
							temp := temp + 1;
							Str(visitante.id, id);
							mensagemMenu(id, 1,temp);
							LowVideo;
							mensagemMenu(visitante.nome, 4,temp);
							HighVideo;
						end;
					Close(visitanteArquivo); //Fecha o arquivo para leitura de dados

					HighVideo; // Volta a normalidade (letras normais)
					Writeln;
					Writeln;
					Write('Escolha o ID do visitante: ');
					repeat
						Readln(posicao);
					until (posicao > 0) and (posicao < (temp-6));

					apagarTudo;
					mensagemTopo('Visita em andamento...', 3);

					adicionarRelatorio('visitanteActivo', 1); //Adiciona 1 aos Visitantes activos ***

					Reset(visitanteArquivo);
					Seek(visitanteArquivo, posicao);
					Read(visitanteArquivo, visitante);
					mensagemMenu('O visitante com o nome '+visitante.nome+' tem permissao para entrar no centro', 1,1);
					temp := visitante.numeroDeVisitas;
					Writeln;
					Writeln('ate que o operador de por encerrada a visita.');
					Close(visitanteArquivo);

					Reset(visitanteArquivo); //Abre o ficheiro
					Seek(visitanteArquivo, posicao); //Posicao atual

					visitante.numeroDeVisitas := temp + 1;
					visitante.visitando := true;
					
					Write(visitanteArquivo, visitante); //Grava o ficheiro
					Close(visitanteArquivo); //Fecha o ficheiro

					Writeln;
					Writeln;
					Writeln;
					Writeln;
					Writeln('Clique em qualquer tecla para voltar ao menu principal.');
					readkey;
					apagarTudo;
					exit;
				
				end;

			3: begin //ENCERRAR VISITA	
					apagarTudo;
					mensagemTopo('Encerrar visita', 1);
					Reset(visitanteArquivo); //Lista todos os reclusos disponiveis para visita
					temp := 2;
					mensagemMenu('ID', 1,temp);
					mensagemMenu('Nome', 4,temp);
					while not eof(visitanteArquivo) do
					begin
						Read(visitanteArquivo, visitante);
						if visitante.apagado = true then continue; //Verifica se visitante foi arquivado 
						if visitante.visitando = false then continue; //Verifica se visitante é inválido
						temp := temp + 1;
						Str(visitante.id, id);
						mensagemMenu(id, 1,temp);
						mensagemMenu(visitante.nome, 4,temp);
					end;
					Close(visitanteArquivo); //Fecha o arquivo para leitura de dados

					HighVideo; // Volta a normalidade (letras normais)
					Writeln;
					Writeln;
					Write('Escolha o ID do visitante: ');
					repeat
						Readln(posicao);
					until (posicao > 0) and (posicao <= (temp+10));


					//Bloco para leitura e copia de dados no arquivo visitantes
					Reset(visitanteArquivo);
					Seek(visitanteArquivo, posicao);
					read(visitanteArquivo, visitante);
					idTemp := visitante.id;
					nomeTemp := visitante.nome;
					Close(visitanteArquivo);

					//Bloco para mudar de activo para inactivo.
					Reset(visitanteArquivo);
					Seek(visitanteArquivo, posicao);
					visitante.id := idTemp;
					visitante.nome := nomeTemp;
					visitante.visitando := false;
					Write(visitanteArquivo, visitante);
					Close(visitanteArquivo);

					adicionarRelatorio('visitanteActivo', -1); //Remove 1 aos visitantes activos. ***

					apagarTudo;
					mensagemTopo('Visita encerrada!!', 3);

					if lerRelatorio('visitanteActivo') = 0 then
					begin
						mensagemMenu('Nenhuma visita activa no momento.',1,2);
						Writeln;
						Writeln;
						Writeln('Clique em qualquer tecla para voltar ao menu.');
						readkey;
						apagarTudo;
						exit;
					end

					else begin
						mensagemMenu('Visitas activas restantes: ', 1,2);
						Writeln(lerRelatorio('visitanteActivo'));
						Writeln;
						Writeln;
						Writeln('Pressione qualquer tecla para voltar ao menu');
						readkey;
						apagarTudo;
						menu;
					end;

				end;
				


				else 
					apagarTudo;
					visitas;
	end;
end;

//OPCAO #4
procedure comportamento;
var
	temp, posicao, condutaTemp: Integer;
	id: String;
begin
	apagarTudo;
	mensagemTopo('Conduta', 1);
	mensagemMenu('',1,1);
	Writeln('1. Actualizar Conduta');
	Writeln('2. Verificar Conduta');
	Writeln('0. Voltar ao menu');
	Readln(opcao);

	apagarTudo;
	case opcao of
		1: begin
				mensagemTopo('Actualizar conduta',1);

				Reset(reclusoArquivo);

				mensagemMenu('ID', 1,1);
				mensagemMenu('Nome', 4,1);
				mensagemMenu('Categoria', 35,1);
				mensagemMenu('Entrada', 45,1);

				temp := 1;
				while not eof(reclusoArquivo) do
				begin
					temp := temp + 1;
					Read(reclusoArquivo, recluso);
					if recluso.apagado = true then continue;
					if recluso.naoMostrar = true then continue;
					if recluso.idade = 0 then continue;
					Str(recluso.id, id);
					mensagemMenu(id, 1,temp);
					mensagemMenu(recluso.nome, 4,temp);
					MensagemMenu(recluso.categoriaCrime,35,temp);
					mensagemMenu(recluso.dataDetencao, 45, temp);
				end;

				Writeln;
				Writeln;
				Writeln;
				Write('Escolha o ID que gostaria de alterar: ');
				repeat
					Readln(posicao);
				until (posicao > 0) and (posicao < FileSize(reclusoArquivo));
				Close(reclusoArquivo);

				//Bloco para ler o comportamento
				Reset(reclusoArquivo);
				Seek(reclusoArquivo, posicao);
				Read(reclusoArquivo, recluso);
				condutaTemp := recluso.comportamento; // !
				Close(reclusoArquivo);
							
				apagarTudo;
				mensagemTopo('Conduta',1);
				mensagemMenu('1. Boa conduta',1,1);
				mensagemMenu('2. Ma conduta',1,2);
				Readln(opcao);
				apagarTudo;
				case opcao of
					1: begin

							mensagemTopo('Boa conduta', 3);
							mensagemMenu('',1,2);
							Writeln('1. Proactividade');
							Writeln('2. Respeito');
							Writeln('3. Colaborativo');
							Readln(opcao);

							case opcao of
								1: begin
										Reset(reclusoArquivo);
										Seek(reclusoArquivo, posicao);
										recluso.comportamento := condutaTemp + 10;

										Write(reclusoArquivo, recluso);
										Close(reclusoArquivo);
								end;
								2: begin
										Reset(reclusoArquivo);
										Seek(reclusoArquivo, posicao);
										recluso.comportamento := condutaTemp + 15;

										Write(reclusoArquivo, recluso);
										Close(reclusoArquivo);
								end;
								3: begin
										Reset(reclusoArquivo);
										Seek(reclusoArquivo, posicao);
										recluso.comportamento := condutaTemp + 30;

										Write(reclusoArquivo, recluso);
										Close(reclusoArquivo);
								end;
							end;
					end;

					2: begin
							mensagemTopo('Ma conduta', 2);
							mensagemMenu('',1,2);
							Writeln('1. Desrespeito');
							Writeln('2. Briga');
							Writeln('3. Tentativa de Fuga');
							Readln(opcao);

							case opcao of
								1: begin
										Reset(reclusoArquivo);
										Seek(reclusoArquivo, posicao);
										recluso.comportamento := condutaTemp - 10;

										Write(reclusoArquivo, recluso);
										Close(reclusoArquivo);
								end;
								2: begin
										Reset(reclusoArquivo);
										Seek(reclusoArquivo, posicao);
										recluso.comportamento := condutaTemp - 15;

										Write(reclusoArquivo, recluso);
										Close(reclusoArquivo);
								end;
								3: begin
										Reset(reclusoArquivo);
										Seek(reclusoArquivo, posicao);
										recluso.comportamento := condutaTemp - 30;

										Write(reclusoArquivo, recluso);
										Close(reclusoArquivo);
								end;
							end;
					end;
						else 

				end;

		end;

		2: begin
				mensagemTopo('Verificar conduta',1);

				Reset(reclusoArquivo);

				mensagemMenu('ID', 1,1);
				mensagemMenu('Nome', 4,1);
				mensagemMenu('Categoria', 35,1);
				mensagemMenu('Entrada', 45,1);

				temp := 1;
				while not eof(reclusoArquivo) do
				begin
					temp := temp + 1;
					Read(reclusoArquivo, recluso);
					if recluso.apagado = true then continue;
					if recluso.naoMostrar = true then continue;
					if recluso.idade = 0 then continue;
					Str(recluso.id, id);
					mensagemMenu(id, 1,temp);
					mensagemMenu(recluso.nome, 4,temp);
					MensagemMenu(recluso.categoriaCrime,35,temp);
					mensagemMenu(recluso.dataDetencao, 45, temp);
				end;

				Writeln;
				Writeln;
				Writeln;
				Write('Escolha o ID que gostaria de libertar: ');
				repeat
					Readln(posicao);
				until (posicao > 0) and (posicao < FileSize(reclusoArquivo));
				Close(reclusoArquivo);		

				//Bloco para ler o comportamento
				Reset(reclusoArquivo);
				Seek(reclusoArquivo, posicao);
				Read(reclusoArquivo, recluso);

				apagarTudo;
				mensagemTopo('Conduta do Recluso', 1);
				mensagemMenu('Nome: ',1,1);
				Writeln(recluso.nome);
				Writeln('Pontos: ', recluso.comportamento);
				Writeln;

				if recluso.comportamento < 0 then Writeln('Descricao: Psicopata')
				else if recluso.comportamento < 50 then Writeln('Descricao: Mau')
				else if recluso.comportamento < 100 then Writeln('Descricao: Aceitavel')
				else if recluso.comportamento = 100 then Writeln('Descricao: Normal')
				else if recluso.comportamento < 130 then Writeln('Descricao: Bom')
				else if recluso.comportamento > 130 then Writeln('Descricao: Excelente');
				readkey;
				condutaTemp := recluso.comportamento; // !
				Close(reclusoArquivo);
		end;

		3: begin
			
		end;
	end;

end;
	
//OPCAO #3
procedure alterar;
var
	nome, id: String;
	temp: Integer;
begin
	apagarMenu;
	mensagemTopo('Alterar', 1);

	Reset(reclusoArquivo);

	temp := 1;
	mensagemMenu('ID', 1,1);
	mensagemMenu('Nome', 4,1);
	mensagemMenu('Idade', 35,1);
	mensagemMenu('Ala', 43,1);
	mensagemMenu('Detencao', 55,1);

	while not eof(reclusoArquivo) do
	begin
		temp := temp + 1;
		Read(reclusoArquivo, recluso);
		if recluso.idade = 0 then continue;
		Str(recluso.id, id);
		mensagemMenu(id, 1,temp);
		MensagemMenu(recluso.nome,4,temp);
		Str(recluso.idade, id);
		MensagemMenu(id,35,temp);
		mensagemMenu(recluso.ala,43,temp);
		mensagemMenu(recluso.dataDetencao,55,temp);
	end;
	Writeln;
	Writeln;
	Writeln;
	Write('Escolha o ID que gostaria de alterar: ');
	repeat
		Readln(opcao);
	until (opcao > 0) and (opcao < FileSize(reclusoArquivo));

	Close(reclusoArquivo);

	nome := lerNome(1, opcao);
	// if nome = '' then readkey;
		if not reclusoExiste(nome) then
			begin
				mensagemTopo('404 | Not Found!', 2);
				apagarMenu;
				Writeln('Nao foi encontrado nenhum registo com');
				writeln('o ID introduzido.');
				delay(500);
				Writeln;
				Writeln;
				Writeln('1. Tentar com outro nome');
				Writeln('2. Retornar ao menu principal');
				Writeln('0. Sair');
				Readln(opcao);

				case opcao of
					1: alterar;
					2: menu; 
					0: begin
							apagarMenu;
							mensagemTopo('Saindo...', 1);
							delay(1000);
							halt;
						end;
				end;
			end
		else begin
			apagarTudo;
			mensagemRodape;
			mensagemTopo('Mais detalhes - Alteracao', 3);
			mensagemMenu('',1,1);
			Writeln('ID:                   ', recluso.id);
			Writeln('Nome:                ', recluso.nome);
			Writeln('No de BI:            ', recluso.bi);
			Writeln('Altura:               ', recluso.altura ,' cm');
			Writeln('Categoria de crime:  ', recluso.categoriaCrime);
			Writeln('Descricao de crime: ', recluso.descricaoCrime);
			Writeln('Idade:                ', recluso.idade);
			Writeln;
			Writeln('O que gostaria de alterar?');
			Writeln('1. Nome');
			Writeln('2. No. de BI');
			Writeln('3. Altura');
			Writeln('4. Categoria do crime');
			Writeln('5. Descricao do crime');
			Writeln('0. Sair');
			Readln(opcao);

			case opcao of
				1: begin
					Reset(reclusoArquivo);
					Seek(reclusoArquivo, opcao);
					Write('Introduza o novo nome: ');
					Read(recluso.nome);
					recluso.nome := AnsiUpperCaseFileName(recluso.nome);
					write(reclusoArquivo, recluso);
					Close(reclusoArquivo);
					apagarTudo;
					mensagemTopo('Nome alterado com sucesso!', 3);
					adicionarRelatorio('modificacoes', 1);
					desejaContinuar;

				end;

				2: begin
					Reset(reclusoArquivo);
					Seek(reclusoArquivo, opcao);
					Write('Introduza os novos dados do BI: ');
					Read(recluso.bi);
					write(reclusoArquivo, recluso);
					Close(reclusoArquivo);
					apagarTudo;
					mensagemRodape;
					mensagemTopo('BI alterado com sucesso!', 3);
					adicionarRelatorio('modificacoes', 1);
					desejaContinuar;
				end;

				3: begin
					Reset(reclusoArquivo);
					Seek(reclusoArquivo, opcao);
					Write('Introduza a nova altura: ');
					Read(recluso.altura);
					write(reclusoArquivo, recluso);
					Close(reclusoArquivo);
					apagarTudo;
					mensagemRodape;
					mensagemTopo('Altura alterado com sucesso!', 3);
					adicionarRelatorio('modificacoes', 1);
					desejaContinuar;
				end;

				4: begin
					Reset(reclusoArquivo);
					Seek(reclusoArquivo, opcao);
					Writeln('Escolha uma nova categoria:');
					Writeln('1. Leve');
					Writeln('2. Grave');
					Writeln('3. Macabro');
					repeat
						Readln(opcao);
						delline;
						case opcao of
								1: recluso.categoriaCrime := 'Leve';
								2: recluso.categoriaCrime := 'Grave';
								3: recluso.categoriaCrime := 'Macabro';
							end;
					until (opcao <> 1) or (opcao <> 2) or (opcao <> 3);
					write(reclusoArquivo, recluso);
					Close(reclusoArquivo);
					apagarTudo;
					mensagemRodape;
					mensagemTopo('Categoria alterado com sucesso!', 3);
					adicionarRelatorio('modificacoes', 1);
					desejaContinuar;
				end;

				5: begin
					Reset(reclusoArquivo);
					Seek(reclusoArquivo, opcao);
					Write('Introduza a nova descricao: ');
					Read(recluso.descricaoCrime);
					write(reclusoArquivo, recluso);
					Close(reclusoArquivo);
					apagarTudo;
					mensagemRodape;
					mensagemTopo('Descricao alterada com sucesso!', 3);
					adicionarRelatorio('modificacoes', 1);
					desejaContinuar;
				end;

				0: begin
					mensagemTopo('Encerrando o programa...', 3);
					apagarMenu;
					delay(1000);
				end;

				else 
					;
			end;

			//Os  outros dados, por se tratrar de elementos sensiveis, tornam-se entao 
	 end;

end;

//OPCAO #2
procedure listar;
var
	//Variaveis temporaria para armazenamento de informacoes
	id: String; 
	temp: Integer;
	// inicioListagem: Integer; {Onde comeca a listgem dos visitantes}
begin
	apagarMenu;
	mensagemTopo('Listagem ',1);

	mensagemMenu('',1,1);
	Writeln('1. Reclusos');
	Writeln('2. Visitantes');
	Writeln('3. Libertos');
	Readln(opcao);

	//Bloco da listagem dos reclusos
	if opcao = 1 then
		begin
			apagarTudo;

			if lerRelatorio('reclusos') = 0 then 
				begin
					mensagemTopo('404 | Not Found', 2);
					mensagemMenu('Nao ha nenhum registo por mostrar.', 1,1);
				end
			else
			begin

				mensagemTopo('Reclusos', 1);
				Reset(reclusoArquivo);
				TextColor(yellow);
				temp := 1;
				mensagemMenu('ID', 1,1);
				mensagemMenu('NOME', 4,1);
				mensagemMenu('IDADE', 35,1);
				mensagemMenu('ALA', 43,1);
				mensagemMenu('DETENCAO', 55,1);


				TextColor(white);
				while not eof(reclusoArquivo) do
				begin
					Read(reclusoArquivo, recluso);
					if recluso.idade = 0 then continue;
					// if recluso.naoMostrar then continue;
					if recluso.apagado = true then continue;
					temp := temp + 1;
					Str(recluso.id, id);
					mensagemMenu(id, 1,temp);
					MensagemMenu(recluso.nome,4,temp);
					Str(recluso.idade, id);
					MensagemMenu(id,35,temp);
					mensagemMenu(recluso.ala,43,temp);
					mensagemMenu(recluso.dataDetencao,55,temp);
				end;
				Close(reclusoArquivo);
			end;
		end;

	//Bloco da listagem dos visitantes
	if opcao = 2 then 
		begin
			apagarTudo;

			if lerRelatorio('visitantes') = 0 then 
				begin
					mensagemTopo('404 | Not Found', 2);
					mensagemMenu('Nao ha nenhum registo por mostrar.', 1,1);
				end
			else
			begin
				mensagemTopo('Visitantes', 1);
				TextColor(cyan);
				Reset(visitanteArquivo); //Abre o arquivo visitantes
				temp := 1;
				mensagemMenu('ID', 1,temp);
				mensagemMenu('NOME', 6,temp);
				mensagemMenu('Estado', 25,temp);
				mensagemMenu('Visitando', 37, temp);
				mensagemMenu('No. Visitas', 55, temp);
				// mensagemMenu('FEITAS', 35,temp);
				// mensagemMenu('ULTIMA VISITA', 45,temp);
				TextColor(white);

				while not eof(visitanteArquivo) do
				begin
					Read(visitanteArquivo, visitante);
					// if visitante.id = 
					if visitante.naoMostrar = true then continue;
					if visitante.id = 0 then continue;
					if visitante.apagado = true then continue;
					temp := temp + 1;
					Str(visitante.id, id);
					mensagemMenu(id, 1,temp);
					MensagemMenu(visitante.nome,6,temp);
					mensagemMenu('', 25, temp); //Estado de visita (visitando ou nao);
					mensagemMenu(visitante.recluso, 37, temp);
					mensagemMenuInt(visitante.numeroDeVisitas, 55, temp); //Nr de visitas realizadas;
					// Str(visitante.idade, id);
					// MensagemMenu(id,35,temp);
					// mensagemMenu(visitante.dataDetencao,45,temp);
				end;
				Close(visitanteArquivo);
			end;
		end;

	//Bloco da listagem dos reclusos libertados
	if opcao = 3 then
		begin	
			apagarTudo;

			if lerRelatorio('libertados') = 0 then 
				begin
					mensagemTopo('404 | Not Found', 2);
					mensagemMenu('Nao ha nenhum registo por mostrar.', 1,1);
				end
			else
			begin
				mensagemTopo('Libertos', 1);
				Reset(reclusoArquivo);
				TextColor(green);
				temp := 1;
				mensagemMenu('ID', 1,temp);
				mensagemMenu('NOME', 4,temp);
				mensagemMenu('IDADE', 35,temp);
				mensagemMenu('ALA', 43,temp);
				mensagemMenu('DETENCAO', 55,temp);
				mensagemMenu('SAIDA', 68, temp);


				TextColor(white);
				while not eof(reclusoArquivo) do
				begin
					Read(reclusoArquivo, recluso);
					if recluso.idade = 0 then continue;
					// if recluso.naoMostrar then continue;
					// if recluso.apagado = true then continue;
					if recluso.libertado = true then 
						begin
							temp := temp + 1;
							Str(recluso.id, id);
							mensagemMenu(id, 1,temp);
							MensagemMenu(recluso.nome,4,temp);
							Str(recluso.idade, id);
							MensagemMenu(id,35,temp);
							mensagemMenu(recluso.ala,43,temp);
							mensagemMenu(recluso.dataDetencao,55,temp);
							mensagemMenu(recluso.dataSaida,68,temp);
						end else continue;
				end;
				Close(reclusoArquivo);
			end;
		end;


	if opcao > 3 then listar;


	

	Writeln;
	Writeln;
	Writeln;
	Writeln;
	Writeln;
	Writeln('Pressione qualquer tecla para voltar ao menu principal.');
	readkey;
	apagarMenu;
	menu;

	// 				mensagemMenu(id, 1,i+2);
	// 				mensagemMenu(visitante.nome, 5, i+2);
	// end
	// else begin
	// 	mensagemTopo('Nao ha nenhum registo', 2);
	// 	mensagemMenu('Pressione qualquer tecla para retornar ao menu.', 3,15);
	// end;
	// Close(reclusoArquivo);

	// Reset(visitanteArquivo);		{Lista os visitantes}
	// mensagemMenu('ID ', 1, 1);
	// mensagemMenu(' Nome',5, 1);
	// mensagemMenu('Entrada', 30, 1);
	// for i := 0 to FileSize(visitanteArquivo) do 
	// 	begin
	// 		Seek(visitanteArquivo, i);
	// 		Read(visitanteArquivo, visitante);
	// 		if visitante.naoMostrar then continue
	// 		else
	// 			begin
	// 				Str(visitante.id, id);
	// 			end;
	// 	end;
	// Close(visitanteArquivo);
	end;

//OPCAO #1
procedure registar;
var
	nome: String[100];
	id, erro: Integer;
	avanca: Boolean;
	anoDetencao, mesDetencao, diaDetencao, horaDetencao: String;
begin
	Reset(reclusoArquivo);
	if FileSize(reclusoArquivo) = 0 then id := 1
	else id := FileSize(reclusoArquivo);
	Close(reclusoArquivo);
	apagarMenu;
	
	mensagemTopo('Novo registo ', 1);
	mensagemMenu('Registo no. ', 29,1);
	Writeln(id);
	Write('Nome: ');
	Readln(nome);
	nome := AnsiUpperCaseFileName(nome);

	if reclusoExiste(nome) then
	begin
		mensagemTopo('O nome ja existe no sistema!', 2);
		apagarMenu;
		Writeln('Ja tem um registo com o mesmo nome.');
		delay(500);
		Writeln;
		Writeln;
		Writeln('1. Tentar com outro nome');
		Writeln('2. Retornar ao menu principal');
		Writeln('0. Sair');
		Readln(opcao);

		case opcao of
			1: registar;
			2: menu; 
			0: begin
					apagarMenu;
					mensagemTopo('Saindo...', 1);
					delay(1000);
					halt;
				end;
		end;
	end;
	Reset(reclusoArquivo);
	Seek(reclusoArquivo, id);
	recluso.nome := nome;
	Write('Genero (M/F): ');
	repeat
		Readln(recluso.genero);
		recluso.genero := Upcase(recluso.genero);
	until (recluso.genero = 'M') or (recluso.genero = 'F');
	Write('Altura (em cm): ');
	Readln(recluso.altura);
	Write('Numero de BI: ');
	Readln(recluso.bi);
	Write('Cor dos olhos: ');
	Readln(recluso.corolhos);
	Write('Cor da pele: ');
	Readln(recluso.corpele);
	Write('Cor do cabelo: ');
	Readln(recluso.corcabelo);
	Write('Peso: ');
	Readln(recluso.peso);
	repeat
		avanca := true;
		Write('Data de Nascimento (DD-MM-AAAA):');
		Readln(recluso.dataNasc);	

		Val(Copy(recluso.dataNasc, 1, 2), recluso.diaNasc, erro);
		Val(Copy(recluso.dataNasc, 4, 2), recluso.mesNasc, erro);
		Val(Copy(recluso.dataNasc, 7, 4), recluso.anoNasc, erro);
		if (erro <> 0) then 
		begin
			Writeln('Dados incorrectos. Introduza correctamente a data.');
			avanca := false;
		end;
	until avanca = true;

	mensagemTopo('Detalhes - Prisao', 1);
	apagarMenu;
	repeat 
		mensagemMenu('Categoria do crime:', 1,3);
		Writeln();
		Writeln('1. Leve');
		Writeln('2. Grave');
		Writeln('3. Macabro');
		//repeat
			Readln(opcao);
			delline;
		case opcao of
				1: 
				begin
					recluso.categoriaCrime := 'Leve';
					adicionarRelatorio('crimeLeve', 1);
				end;
				
				2: 
				begin
					recluso.categoriaCrime := 'Grave';
					adicionarRelatorio('crimeGrave', 1);
				end;
				3: 
				begin
					recluso.categoriaCrime := 'Macabro';
					adicionarRelatorio('crimeMacabro', 1);
				end

			else
				begin
					apagarTudo;
					mensagemTopo('OPCAO INVALIDA...', 2); 
					mensagemMenu('',1,1);
					Writeln('TENTE NOVAMENTE!!!');
					delay(1000);
					apagarTudo;
				end;
			end;

	until (opcao = 1) or (opcao = 2) or (opcao = 3);
	Write('Descricao do crime: ');
	Readln(recluso.descricaoCrime);
	Writeln;
	Writeln('Data de Detencao:');
	Writeln('1. Introduzir manualmente');
	Writeln('2. Usar data actual (',FormatDateTime('DD-MM-YYYY', Now),')');

	Readln(opcao);
	case opcao of
		1: 	begin
				Writeln('Preencha os campos abaixo: ');
				repeat
					Write('Ano: ');
					Readln(recluso.anoDetencao);
				until (recluso.anoDetencao > 2018) and (recluso.anoDetencao < 2040);	
				repeat
					Write('  Mes: ');
					Readln(recluso.mesDetencao);
				until (recluso.mesDetencao > 0) and (recluso.mesDetencao < 13);
				repeat
					Write('  Dia: ');
					Readln(recluso.diaDetencao);
				until (recluso.diaDetencao > 0) and (recluso.diaDetencao < 32);

				Str(recluso.anoDetencao, anoDetencao);
				Str(recluso.mesDetencao, mesDetencao);
				Str(recluso.diaDetencao, diaDetencao);
				recluso.dataDetencao := anoDetencao+'-'+mesDetencao+'-'+diaDetencao;
			end;
		2: begin
				DecodeDate(Date, YYYY,MM,DD);
				DecodeTime(Time, HH,MM,SS,MS);

				anoDetencao := FormatDateTime('YYYY', Now);
				Val(anoDetencao, recluso.anoDetencao, erro);

				mesDetencao := FormatDateTime('MM', Now);
				Val(mesDetencao, recluso.mesDetencao, erro);

				diaDetencao := FormatDateTime('DD', Now);
				Val(diaDetencao, recluso.diaDetencao, erro);
				recluso.dataDetencao := anoDetencao+'-'+mesDetencao+'-'+diaDetencao;

				horaDetencao := FormatDateTime('hh:mm', Now);
				Val(horaDetencao, recluso.horaDetencao, erro);
				
			end;
	end;	


	recluso.idade := (recluso.anoDetencao - recluso.anoNasc); // Estima a idade do recluso consoante as datas introduzidas.	
	recluso.apagado := false;
	recluso.naoMostrar := false;
	recluso.libertado := false;
	recluso.comportamento := 100; // Valor inicial de cada recluso

	if recluso.idade<14 then
	begin 
		apagarTudo;
		mensagemTopo(' O recluso nao pode ser encarcerrado...',2);
		delay(2000);

		desejaContinuar;
	end
	else if recluso.idade < 18 then
	begin
		recluso.ala := 'Menores';

		mensagemTopo('Menor de idade', 1);
		apagarMenu;
		mensagemMenu('Introduza o nome do responsavel: ', 1,2);
		Readln(recluso.responsavel);
		Write('Introduza o contacto do responsavel: ');
		Readln(recluso.contacto);
	end
	else begin
		mensagemTopo('Maior de idade', 1);
		recluso.ala := 'Adultos';	
		recluso.responsavel := '';
		recluso.contacto := 0;
	end;
	recluso.id := id; {Atribui o ID para o recluso}
	// recluso.naoMostrar := false;

	mensagemTopo('   Confirmacao  ', 1);
	apagarMenu;

	mensagemMenu('Confira se os dados abaixo estao correctos.',1,1);
	mensagemMenu('Caso nao, altere-o(s) pelo opcao indica abaixo.',1,2);
	Writeln;
	Writeln; 
	Writeln('ID:                  ', recluso.id);
	Writeln('Nome:                ', recluso.nome);
	Writeln('No de BI:            ', recluso.bi);
	Writeln('Altura:              ', recluso.altura ,' cm');
	Writeln('Categoria de crime:  ', recluso.categoriaCrime);
	Writeln('Descricao de crime:  ', recluso.descricaoCrime);
	Writeln('Data de Nascimento:  ', recluso.diaNasc,'-',recluso.mesNasc,'-',recluso.anoNasc);
	Writeln('Data de Detencao:    ', recluso.diaDetencao,'-',recluso.mesDetencao,'-',recluso.anoDetencao);
	Writeln('Idade:               ', recluso.idade);
	if recluso.idade < 18 then //Exibe o nome do responsavel se for menor de idade
	begin
	Writeln('Responsavel:               ', recluso.responsavel);
	Writeln('Contacto do Responsavel: ', recluso.contacto );
	end;
	Writeln('Ala:                 ', recluso.ala);	
	Writeln;
	Writeln('Confirmar registo?');
	Writeln('1. Sim');
	Writeln('2. Alterar dados');
	Writeln('3. Cancelar');
	Readln(opcao);

	if opcao = 1 then 

	begin
		// adicionarRelatorio('reclusos', 1);
		// if recluso.idade < 18 then adicionarRelatorio('menores', 1)
		// else adicionarRelatorio('maiores', 1);
		if recluso.idade < 18 then adicionarRelatorio('menores', 1)
		else adicionarRelatorio('maiores', 1);

		Write(reclusoArquivo, recluso);
		Close(reclusoArquivo);
		adicionarRelatorio('reclusos',1);
		delay(150);
		apagarTudo;
		mensagemRodape;
		mensagemTopo('Registo efectuado com sucesso!!', 3);

		desejaContinuar;
	end

	else if opcao = 2 then
	begin
		apagarTudo;
		mensagemTopo('ALTERANDO OS DADOS DO RECLUSO...',1);
		mensagemMenu('', 1,1);
		Writeln('Opcoes: ');
		Writeln;
		Writeln(' ID                 ', recluso.id); // Nao pode ser alterado pois e gerado automaticamente
		Writeln('1. Nome:                ', recluso.nome);
		Writeln('2. No de BI:            ', recluso.bi);
		Writeln('3. Altura:              ', recluso.altura ,' cm');
		Writeln('4. Categoria de crime:  ', recluso.categoriaCrime);
		Writeln('           ==> Descricao de crime:  ', recluso.descricaoCrime);
		Writeln('5. Data de Nascimento:  ', recluso.diaNasc,'-',recluso.mesNasc,'-',recluso.anoNasc);
		//Writeln('6. Data de Detencao:    ', recluso.diaDetencao,'-',recluso.mesDetencao,'-',recluso.anoDetencao);
		//Writeln('7. Idade:               ', recluso.idade);
		//Writeln('=====> para alterar a idade basta alterar a data de nascimento');
		Writeln;
		Write('OPCAO..:');
			readln(opcao);

			case opcao of 
				1: begin

						Write('Insira o Nome certo: ');
						Readln(nome);
						
						if recluso.idade < 18 then adicionarRelatorio('menores', 1)
						else adicionarRelatorio('maiores', 1);

						recluso.nome:= nome;
						Write(reclusoArquivo, recluso);
						Close(reclusoArquivo);
						adicionarRelatorio('reclusos',1);
						delay(150);
						apagarTudo;
						mensagemRodape;
						mensagemTopo('Registo efectuado com sucesso!!', 3);

						desejaContinuar;	
					end;
				2: begin

						Write('Insira o numero do Bilhete de Identidade: ');
						Readln(recluso.bi);
						
						if recluso.idade < 18 then adicionarRelatorio('menores', 1)
						else adicionarRelatorio('maiores', 1);
						Write(reclusoArquivo, recluso);
						Close(reclusoArquivo);
						adicionarRelatorio('reclusos',1);
						delay(150);
						apagarTudo;
						mensagemRodape;
						mensagemTopo('Registo efectuado com sucesso!!', 3);

						desejaContinuar;	
					end;
				3: begin

						Write('Insira a altura: ');
						Readln(Recluso.altura);
						
						if recluso.idade < 18 then adicionarRelatorio('menores', 1)
						else adicionarRelatorio('maiores', 1);

						Write(reclusoArquivo, recluso);
						Close(reclusoArquivo);
						adicionarRelatorio('reclusos',1);
						delay(150);
						apagarTudo;
						mensagemRodape;
						mensagemTopo('Registo efectuado com sucesso!!', 3);

						desejaContinuar;	
					end;
				4: begin

						Writeln('Insira a CATEGORIA e DESCRICAO DO CRIME: ');
						Writeln('1. Leve');
						Writeln('2. Grave');
						Writeln('3. Macabro ');
						Write('Opcao..:');
						readln(opcao);

						if opcao = 1 then
						begin
							recluso.categoriaCrime:='Leve';
						end 
						else if opcao = 2 then
						begin
							recluso.categoriaCrime:='Grave';
						end

						else if opcao = 3 then
						begin
							recluso.categoriaCrime:='Macabro';
						end else 
							begin
							mensagemTopo('Opcao Invalida',2);
							delay(1000);
							Writeln('Reencaminhando ao Menu.');
							delay(1000);
							Writeln('Reencaminhando ao Menu..');
							delay(1000);
							Writeln('Reencaminhando ao Menu...');
							delay(1000);
							
							menu;

						end;

						Write('Insira a Descricao do Crime : ');
						Readln(recluso.descricaoCrime);
						
						if recluso.idade < 18 then adicionarRelatorio('menores', 1)
						else adicionarRelatorio('maiores', 1);

						Write(reclusoArquivo, recluso);
						Close(reclusoArquivo);
						adicionarRelatorio('reclusos',1);
						delay(150);
						apagarTudo;
						mensagemRodape;
						mensagemTopo('Registo efectuado com sucesso!!', 3);

						desejaContinuar;	
					end;

					5: begin

							repeat
								avanca := true;
								Write('insira a Data de Nascimento (DD-MM-AAAA): ');
								Readln(recluso.dataNasc);	

								Val(Copy(recluso.dataNasc, 1, 2), recluso.diaNasc, erro);
								Val(Copy(recluso.dataNasc, 4, 2), recluso.mesNasc, erro);
								Val(Copy(recluso.dataNasc, 7, 4), recluso.anoNasc, erro);
								if (erro <> 0) then 
								begin
									Writeln('Dados incorrectos. Introduza correctamente a data.');
									avanca := false;
								end;
							until avanca = true;

							DecodeDate(Date, YYYY,MM,DD);
							DecodeTime(Time, HH,MM,SS,MS);

							anoDetencao := FormatDateTime('YYYY', Now);
							Val(anoDetencao, recluso.anoDetencao, erro);

							mesDetencao := FormatDateTime('MM', Now);
							Val(mesDetencao, recluso.mesDetencao, erro);

							diaDetencao := FormatDateTime('DD', Now);
							Val(diaDetencao, recluso.diaDetencao, erro);
							recluso.dataDetencao := anoDetencao+'-'+mesDetencao+'-'+diaDetencao;

							horaDetencao := FormatDateTime('hh:mm', Now);
							Val(horaDetencao, recluso.horaDetencao, erro);


							
											recluso.idade := (recluso.anoDetencao - recluso.anoNasc); // Estima a idade do recluso consoante as datas introduzidas.	
											recluso.apagado := false;
											recluso.naoMostrar := false;
											recluso.libertado := false;

											if recluso.idade<14 then
											begin 
												apagarTudo;
												mensagemTopo(' O recluso nao pode ser encarcerrado...',2);
												delay(2000);

												desejaContinuar;
											end
											else if recluso.idade < 18 then
											begin
												recluso.ala := 'Menores';

												mensagemTopo('Menor de idade', 1);
												apagarMenu;
												mensagemMenu('Introduza o nome do responsavel: ', 1,2);
												Readln(recluso.responsavel);
												Write('Introduza o contacto do responsavel: ');
												Readln(recluso.contacto);
											end
											else begin
												mensagemTopo('Maior de idade', 1);
												recluso.ala := 'Adultos';	
												recluso.responsavel := '';
												recluso.contacto := 0;
											end;
									

						if recluso.idade < 18 then adicionarRelatorio('menores', 1)
						else adicionarRelatorio('maiores', 1);
						Write(reclusoArquivo, recluso);
						Close(reclusoArquivo);
						adicionarRelatorio('reclusos',1);
						delay(150);
						apagarTudo;
						mensagemRodape;
						mensagemTopo('Registo efectuado com sucesso!!', 3);

						desejaContinuar;	
					end;
			end;

	end
	else
		begin
			Close(reclusoArquivo);
			mensagemTopo('Registo cancelado', 2);
			apagarMenu;
			desejaContinuar;
		end;

	/// Confirme os dados de registo

end;

procedure menu;
begin
		apagarTudo;
		apagarMenu;
	repeat
		mensagemRodape;

		if visitasActivas > 0 then
		begin
			dashboard('Visitas no centro: ', 2,16);
			Writeln(visitasactivas);
			apagarMenu;
		end;

		mensagemTopo('Menu Principal', 1);
		mensagemMenu('',1,1);
		Writeln('1. Registar');
		Writeln('2. Listar');
		Writeln('3. Alterar dados de registo');
		Writeln('4. Conduta');
		Writeln('5. Visitas');
		// Writeln('6. Servicos voluntarios');
		Writeln('8. Libertar');
		// Writeln('8. Excluir');
		Writeln('9. Relatorios');
		Writeln('10. Pesquisar');
		// Writeln('11. Ajuda');
		Write('0.'); 
		TextColor(red);
		Write(' Sair');
		Writeln;
		Writeln;
		TextColor(white);
		Write('Opcao desejada: ');
		Readln(opcao);


		case opcao of
			1: registar;
			2: listar;
			3: alterar;
			4: comportamento;
			5: visitas;
			6: servicosVoluntarios;
			7: libertar;
			8: excluir;
			9: relatorios;
			10: pesquisar;
			11: ajuda;
			0: begin
					mensagemTopo('Encerrando o programa...', 1);
					apagarMenu;
					delay(1000);
					halt;
				end;
			else 
				gotoxy(1, 12);
				delline;
				mensagemTopo('Opcao invalida!', 2);
				delay(1500);
		end;
	until opcao = 99;
end;


begin
	criarDirectorios; { <-- Obrigatorio}
	criarArquivos; { <-- Obrigatorio}
	mensagemRodape;
	login;
	// servicosVoluntarios;
	mensagemRodape;
	menu;

end.
