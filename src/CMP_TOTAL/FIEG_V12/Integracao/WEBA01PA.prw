#Include "Protheus.ch"
#Include "TbiConn.ch"
#Include "TOPCONN.ch"
#Include "APWEBSRV.ch"
#Include "FWMVCDEF.ch"
#Include "FWCOMMAND.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} WEBA01PA
Web service que disponibiliza serviço de integração de operações como: cadastros, operações financeiras, consultas.

@type function
@author Thiago Rasmussen
@since 15/02/2019
@version P12.1.23

@obs Desenvolvimento FIEG

@history 14/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

//====================================================================
//WsIntegracao - Definição de Função de Usuário para controle interno
//====================================================================
User Function WEBA01PA() ; Return Nil 						// Dummy Function - For documentation purposes

//=====================================================================
//WsStruct - Definição das Estruturas de Variáveis Array ou Complexas
//=====================================================================

//=======================================
//Estrutura do Conjunto de Alias Protheus
//=======================================
WSSTRUCT StrCjAliasS
	WSDATA WsCjHAliasS	As Array Of StrAlias
ENDWSSTRUCT

//=======================================
//Estrutura de Alias Protheus
//=======================================
WSSTRUCT StrAlias
	WSDATA WsHAlias		As String
	WSDATA WsHDscAlias	As String
	WSDATA WsCjHeaders	As Array Of StrHeaders
ENDWSSTRUCT

//=======================================
//Estrutura de aHader Protheus
//=======================================
WSSTRUCT StrHeaders
	WSDATA Titulo			As String
	WSDATA Campo			As String
	WSDATA Mascara			As String
	WSDATA Tamanho			As Float
	WSDATA Decimal			As Float
	WSDATA Validacao		As String
	WSDATA Usado			As Boolean
	WSDATA Tipo				As String
	WSDATA ConsultF3		As String
	WSDATA Contexto			As String
	WSDATA ComboBox			As String
	WSDATA Inicializador	As String
	WSDATA EdicaoWhen		As String
ENDWSSTRUCT

//=======================================
//Estrutura do Conjunto de aCols Protheus
//=======================================
WSSTRUCT StrCjAColsS
	WSDATA WsCjACols	As Array Of StrACols
ENDWSSTRUCT

//=======================================
//Estrutura do aCols Protheus
//=======================================
WSSTRUCT StrACols
	WSDATA WsCAlias		As String
	WSDATA WsCjItens	As Array Of StrItsACols
ENDWSSTRUCT

//=======================================
//Estrutura do Conjunto de Itens do aCols Protheus
//=======================================
WSSTRUCT StrItsACols
	WSDATA WsCjRegistros	As Array Of StrRegACols
ENDWSSTRUCT

//=======================================
//Estrutura do Registro do aCols Protheus
//=======================================
WSSTRUCT StrRegACols
	WSDATA IdRegistro	AS Float
	WSDATA CampoAcols	As String
	WSDATA Conteudo		As String
ENDWSSTRUCT

//=======================================
//Estrutura de Retorno do Tikect.
//=======================================
WsStruct StrRetTicket
	WsData WsMensagens	As Array Of StrMsgRet
	WsData WsRetHeader	As Array Of StrCjAliasS OPTIONAL
	WsData WsRetACols	As Array Of StrCjAColsS OPTIONAL 
ENDWSSTRUCT

//=======================================
//Estrutura de Retorno da Mensagem.
//======================================= 
WsStruct StrMsgRet
	WsData WsCodMsg		As Float
	WsData WsDscMsg		As String
EndWsStruct

//=======================================
//Estrutura de Cliente.
//=======================================
WsStruct StrCliente
	WsData WsCodCli	AS String	OPTIONAL
	WsData WsLojCli	AS String	OPTIONAL
	WsData WsCgcCli	AS String	OPTIONAL
EndWsStruct

//=======================================
//Estrutura de Fornecedor.
//=======================================
WsStruct StrFornecedor
	WsData WsCodFor	AS String	OPTIONAL
	WsData WsLojFor	AS String	OPTIONAL
	WsData WsCgcFor	AS String	OPTIONAL
EndWsStruct

//=======================================
//Estrutura de Contabilidade Consolidada.
//=======================================
WsStruct StrContabilCab
	WsData WsDataLanc   AS String	OPTIONAL
	WsData WsLote   	AS String	OPTIONAL
	WsData WsSubLote	AS String	OPTIONAL
	WsData WsDocumento	AS String	OPTIONAL
EndWsStruct

WsStruct StrContabilDet
	WsData WsFilial   	AS String	OPTIONAL
	WsData WsLinha   	AS String	OPTIONAL
	WsData WsTpLanc	    AS String	OPTIONAL
	WsData WsContaD   	AS String	OPTIONAL
	WsData WsContaC   	AS String	OPTIONAL
	WsData WsCCC       	AS String	OPTIONAL
	WsData WsCCD       	AS String	OPTIONAL
	WsData WsItemC     	AS String	OPTIONAL
	WsData WsItemD    	AS String	OPTIONAL
	WsData WsValor     	AS String	OPTIONAL
	WsData WsFilOrig   	AS String	OPTIONAL
	WsData WsHist      	AS String	OPTIONAL
EndWsStruct        

WsStruct StrContabilDetArr
	WsData WsContabilDetArr AS Array Of StrContabilDet	OPTIONAL
EndWsStruct        


//=======================================
//Estrutura de Cliente para Inclusao
//=======================================
WsStruct StrClienteInc
	WsData WsTipoPessoa		AS String
	WsData WsCodCli   		AS String
	WsData WsLojCli   		AS String
	WsData WsCgcCli   		AS String
	WsData WsNome			AS String
	WsData WsEndereco 		AS String
	WsData WsBairro			AS String
	WsData WsCep			AS String
	WsData WsComplemento	AS String
	WsData WsCidade			AS String
	WsData WsUf				AS String
	WsData WsTelefone		AS String
EndWsStruct

//=======================================
//Estrutura de Contas a Receber
//=======================================
WsStruct StrTitulo
	WsData WsFilTit		AS String
	WsData WsPrefTit	AS String
	WsData WsNumTit		AS String
	WsData WsParcTit	AS String
	WsData WsTipoTit	AS String
EndWsStruct

//=======================================
//Estrutura de Contas a Receber
//Incluido por Iatan
//=======================================
WsStruct StrTituloErp
	WsData WsFilTit	   AS String  OPTIONAL
	WsData WsPrefTit   AS String  OPTIONAL 
	WsData WsNumTit	   AS String
	WsData WsOrigemTit AS String  OPTIONAL
	WsData WsParcTit   AS String  OPTIONAL 
	WsData WsTipoTit   AS String  OPTIONAL
	WsData WsContaC    As String  OPTIONAL
	WsData WsCc        As String  OPTIONAL
	WsData WsCentResp  As String  OPTIONAL
	WsData WsCodCli    As String  OPTIONAL
	WsData WsLojCli    As String  OPTIONAL
	WsData WsEmissao   As String  OPTIONAL
	WsData WsHist      As String  OPTIONAL
	WsData WsManual    As String  OPTIONAL
	WsData WsNatureza  As String  OPTIONAL
	WsData WsNomCli    As String  OPTIONAL
	WsData WsBanco     As String  OPTIONAL
	WsData WsAgencia   As String  OPTIONAL
	WsData WsConta     As String  OPTIONAL
	WsData WsValor     As String  OPTIONAL
	WsData WsVencto    As String  OPTIONAL
	WsData WsVencrea   As String  OPTIONAL
	WsData WsMotbx     As String  OPTIONAL
	WsData WsDtbx      As String  OPTIONAL
	WsData WsDtcred    As String  OPTIONAL
	WsData WsJuros     As String  OPTIONAL
	WsData WsDesconto  As String  OPTIONAL
	WsData WsValrec    As String  OPTIONAL
EndWsStruct

//=======================================
//Estrutura de Contas a Receber
//Incluido por Iatan
//=======================================
WsStruct StrTituloErpPag
	WsData WsFilTit	   AS String  OPTIONAL
	WsData WsPrefTit   AS String  OPTIONAL 
	WsData WsNumTit	   AS String
	WsData WsOrigemTit AS String  OPTIONAL
	WsData WsParcTit   AS String  OPTIONAL 
	WsData WsTipoTit   AS String  OPTIONAL
	WsData WsContaD    As String  OPTIONAL
	WsData WsCcD       As String  OPTIONAL
	WsData WsCentResp  As String  OPTIONAL
	WsData WsCodFor    As String  OPTIONAL
	WsData WsLojFor    As String  OPTIONAL
	WsData WsEmissao   As String  OPTIONAL
	WsData WsHist      As String  OPTIONAL
	WsData WsManual    As String  OPTIONAL
	WsData WsNatureza  As String  OPTIONAL
	WsData WsNomFor    As String  OPTIONAL
	WsData WsBanco     As String  OPTIONAL
	WsData WsAgencia   As String  OPTIONAL
	WsData WsConta     As String  OPTIONAL
	WsData WsValor     As String  OPTIONAL
	WsData WsVencto    As String  OPTIONAL
	WsData WsVencrea   As String  OPTIONAL
	WsData WsMotbx     As String  OPTIONAL
	WsData WsDtbx      As String  OPTIONAL
	WsData WsDtcred    As String  OPTIONAL
	WsData WsJuros     As String  OPTIONAL
	WsData WsDesconto  As String  OPTIONAL
	WsData WsValrec    As String  OPTIONAL
	WsData WsDataLib   As String  OPTIONAL
	WsData WsUsuaLib   As String  OPTIONAL
	WsData WsStatLib   As String  OPTIONAL
EndWsStruct

//=======================================
//Estrutura do parâmetro MV_DATAFIN
//Incluido por Iatan
//=======================================
WSSTRUCT StrMvdatafin
	WSDATA WsMvdatafin		As String
ENDWSSTRUCT

//=======================================
//Estrutura do retorno de rotinas customizadas
//Incluido por Iatan
//=======================================
WSSTRUCT StrRetornoS
	WSDATA WsRetornoS		As String
ENDWSSTRUCT

//=======================================
//Estrutura para Compensacao CR
//Incluido por Iatan
//=======================================
WSSTRUCT StrRecnoNF
	WSDATA WsRecnoNF		As String
ENDWSSTRUCT

WSSTRUCT StrRecnoPA
	WSDATA WsRecnoPA		As String
ENDWSSTRUCT


/*/================================================================================================================================/*/
/*/{Protheus.doc} WEBA01PA
Web service para Informar o Retorno do Ticket.

@type 	 class
@author  Thiago Rasmussen
@since 	 15/02/2019
@version P12.1.23
@obs 	 Desenvolvimento FIEG
@history 14/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 
/*/
/*/================================================================================================================================/*/

WsService WEBA01PA Description "Neste WebService contem todos os métodos para retorno da Rotina de Integração CR5 x PROTHEUS."

	WsData WsCEmp		As String
	WsData WsCFil		As String
	WsData WsLogin		As String
	WsData WsSenha		As String
	WsData WsTicket		As String
	WsData WsAHeader	As Boolean
	WsData WsRetorno	As StrRetTicket
	
	WsData WsCliente   	    As StrCliente
	WsData WsFornecedor 	As StrFornecedor
	WsData WsClienteInc 	As StrClienteInc
	WsData WsClienteOut	    As StrCliente
	WsData WsTitulo		    As StrTitulo
	WsData WsTituloErp      As StrTituloErp
	WsData WsTituloErpPag   As StrTituloErpPag
	WsData WsContabilCab    As StrContabilCab
	WsData WsContabilDetArr As StrContabilDetArr
//	WsData WsContabilDetArr As Array of StrContabilDet
	WsData WsContabilDetQtd As String
	WsData WsMvdatafin	    As String
	WsData WsRetornoS 	    As String
	WsData WsDataMFS	 	As String // Data do Movimento Financeiro
	WsData WsBancoMFS	 	As String // Banco do Movimento Financeiro
	WsData WsAgenciaMFS	    As String // Agência do Movimento Financeiro
	WsData WsContaMFS	 	As String // Conta do Movimento Financeiro
	WsData WsRecnoNF	 	As String // R_E_C_N_0_ DA NF PARA A ROTINA DE COMPENSACAO CR
	WsData WsRecnoPA	 	As String // R_E_C_N_0_ DO PA PARA A ROTINA DE COMPENSACAO CR
	
	WsMethod InfTicketAll			Description "Método para retornar todas as informações do Ticket."
	WsMethod InfCliente				Description "Método para retornar todas as informações do Cliente."         
	WsMethod IncluirCliente			Description "Método para Inclusão de Cliente." 														// Iatan em 22/12/2016
	WsMethod AlterarCliente			Description "Método para Alteração do Cliente." 													// Iatan em 22/12/2016
	WsMethod GetCliente				Description "Método para retornar o Codigo e Loja do Cliente, caso exista."  						// Iatan em 22/12/2016
	WsMethod InfFornecedor			Description "Método para retornar todas as informações do Fornecedor." 								// Iatan em 25/10/2017
//	WsMethod IncluirFornecedor		Description "Método para Inclusão de Fornecedor." 													// Iatan em 25/10/2017
	WsMethod InfTitulo				Description "Método para retornar todas as informações do Título e Movimentação Financeira."
	WsMethod GetTitulo				Description "Método para retornar todas as informações do Título e Movimentação Financeira." 		//Iatan em 22/12/2016
	WsMethod GetTituloPAG			Description "Método para retornar todas as informações do Título e Movimentação Financeira do tipo CONTAS A PAGAR." //Iatan em 22/12/2016
	WsMethod IncluirTitulo			Description "Método para Inclusão de Titulo Financeiro do tipo CONTAS A RECEBER." 					// Iatan em 23/12/2016
	WsMethod IncluirTituloSE   		Description "Método para Inclusão de Titulo Financeiro do tipo CONTAS A RECEBER (Exclusivo para SESuite)." // Iatan em 23/12/2016
	WsMethod IncluirTituloPAG		Description "Método para Inclusão de Titulo Financeiro do tipo CONTAS A PAGAR." 					// Iatan em 30/10/2017
	WsMethod IncluirTituloPAGSE		Description "Método para Inclusão de Titulo Financeiro do tipo CONTAS A PAGAR (Exclusivo para SESuite)." // Iatan em 30/10/2017
	WsMethod AlterarTitulo			Description "Método para Alteração de Titulo Financeiro." 											// Iatan em 01/01/2017
	WsMethod ExcluirTitulo			Description "Método para Exclusão de Titulo Financeiro." 											// Iatan em 14/01/2017
	WsMethod BaixarTitulo			Description "Método para Baixa de Titulo Financeiro." 												// Iatan em 23/12/2016
	WsMethod BaixarTituloPAG		Description "Método para Baixa de Titulo Financeiro do tipo CONTAS A PAGAR." 						// Iatan em 20/11/2017
	WsMethod ExcluirBaixaTitulo		Description "Método para Exclusão de Baixa de Titulo Financeiro." 									// Iatan em 12/01/2017
	WsMethod CancelarBaixaTitulo	Description "Método para Cancelamento de Baixa de Titulo Financeiro." 								// Iatan em 23/12/2016
	WsMethod InfMvdatafin		    Description "Método para retornar o conteúdo do parâmetro MV_DATAFIN."
	WsMethod MovBancarioCent		Description "Método para incluir um Movimento Bancário para Boleto Centralizado." 					// Iatan em 28/12/2016
	WsMethod MovBancarioDev	   		Description "Método para incluir um Movimento Bancário de Devolução de Numerário." 					// Iatan em 16/01/2017
	WsMethod ExcMovBancario  		Description "Método para excluir um Movimento Bancário para Boleto Centralizado." 					// Iatan em 12/01/2017
	WsMethod ExisteAjuste   		Description "Método para Retornar se Existe Ajuste Manual na Movimentação Bancária." 				// Iatan em 15/02/2017
	WsMethod GetObjContabilCab    	Description "Método para Retornar a Estrutura de Cabeçalho dos Lançamentos Contábeis Consolidados." // Iatan em 16/03/2017
	WsMethod GetObjContabilDet    	Description "Método para Retornar a Estrutura de Detalhe dos Lançamentos Contábeis Consolidados." 	// Iatan em 16/03/2017
	WsMethod ContabilConsolidado  	Description "Método para Efetuar os Lançamentos Contábeis Consolidados." 							// Iatan em 14/03/2017
	WsMethod CompensacaoCarteiras 	Description "Método para Efetuar a Compensação de um Titulo de Despesa com um Titulo de Receita." 	// Iatan em 14/11/2017
	WsMethod CompensacaoCR        	Description "Método para Efetuar a Compensação de dois Titulos de Despesa (NF x PA)" 				// Iatan em 20/11/2017

EndWsService


/*/================================================================================================================================/*/
/*/{Protheus.doc} InfTicketAll
Metodo da Classe WEBA01PA, responsável por retornar as informações do Ticket. 

@type 	 method
@author  Thiago Rasmussen
@since 	 15/02/2019
@version P12.1.23
@obs 	 Desenvolvimento FIEG
@return  Lógico, retorna verdadeiro.
@history 14/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 
/*/
/*/================================================================================================================================/*/

WsMethod InfTicketAll WsReceive WsCEmp,WsCFil,WsLogin,WsSenha,WsTicket,WsAHeader WsSend WsRetorno WsService WEBA01PA

Local _aAlsPsq	:= {"ZJ8", "ZJ9", "ZJA"}
Local _aHeaderS	:= {}
Local _aChvZJA	:= {}
Local _lLogin	:= .T.

Local _cWsTicket	:= SubStr(WsTicket+Space(TamSX3("ZJ8_TICKET")[01]), 01, TamSX3("ZJ8_TICKET")[01])

Private INCLUI	:= .F.

PswOrder(02) 												//Nome do Usuário

If PswSeek( WsLogin, .T. )									//Posionando no Usuário
	//--< A Variável é alterada para o Login conforme o cadastrado no Protheus. >--
	//--< Pois para a função do Prepare Environment é necessário dessa forma. >---
	WsLogin := AllTrim(PswRet()[01,02])
Else
	_lLogin := .F.
EndIf

//--< Validando a senha após posiciona no Usuário. >---------------------------
If !PswName( WsSenha )
	_lLogin := .F.
EndIf

//--< Caso não tenha passado pela validação de usuário e senha do Protheus. >--
If !_lLogin
	
	If EMPTY(::WsRetorno:WsMensagens)
		aADD( ::WsRetorno:WsMensagens, WSClassNew("StrMsgRet") )
		_nPMsg	:= Len( ::WsRetorno:WsMensagens )
		::WsRetorno:WsMensagens[_nPMsg]:WsCodMsg := -5
		::WsRetorno:WsMensagens[_nPMsg]:WsDScMsg := "Usuário ou Senha Inválido."
	EndIF
	
	RETURN .T.
	
EndIF

RPCSetType(3)
//PREPARE ENVIRONMENT EMPRESA WsCEmp FILIAL WsCFil USER WsLogin PASSWORD WsSenha
SetModulo("SIGAFIN","FIN")
	
	//--< Variável para as mensagens de retorno. >-----------------------------
	::WsRetorno:WsMensagens := {}
	//aADD( ::WsRetorno:WsMensagens, WSClassNew("StrMsgRet") )
	
	If WsAHeader
		
		::WsRetorno:WsRetHeader := {}
		
		For _nAls := 1 To Len(_aAlsPsq)
			
			aADD( ::WsRetorno:WsRetHeader, WSClassNew("StrCjAliasS") )
			
			::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS := {}
			aADD( ::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS, WSClassNew("StrAlias") )
			::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS[01]:WsHAlias := _aAlsPsq[_nAls]
			::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS[01]:WsHDscAlias := UPPER( AllTrim(Posicione("SX2", 1, _aAlsPsq[_nAls], "X2_NOME")) )
			
			aADD(_aHeaderS, {_aAlsPsq[_nAls], {} } )
			
			::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS[01]:WsCjHeaders := {}
			
			OpenSxs(,,,,cEmpAnt,"SX3TMP","SX3",,.F.,.T.)
			SX3TMP->(DbSetOrder(1))
			SX3TMP->(DbGoTop())
			If SX3TMP->(DbSeek(_aAlsPsq[_nAls]))
				_nCont := 0
				While SX3TMP->(!EOF()) .And. SX3TMP->X3_ARQUIVO == _aAlsPsq[_nAls]
					_nCont++
					
					//Incluindo os campos para o Retorno do WebService.
					aADD( ::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS[01]:WsCjHeaders, WSClassNew("StrHeaders") )
					::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS[01]:WsCjHeaders[_nCont]:Titulo			:= AllTrim(X3Titulo())
					::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS[01]:WsCjHeaders[_nCont]:Campo			:= AllTrim(SX3TMP->X3_CAMPO)
					::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS[01]:WsCjHeaders[_nCont]:Mascara			:= AllTrim(SX3TMP->X3_PICTURE)
					::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS[01]:WsCjHeaders[_nCont]:Tamanho			:= SX3TMP->X3_TAMANHO
					::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS[01]:WsCjHeaders[_nCont]:Decimal			:= SX3TMP->X3_DECIMAL
					::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS[01]:WsCjHeaders[_nCont]:Validacao		:= AllTrim(SX3TMP->X3_VALID)
					::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS[01]:WsCjHeaders[_nCont]:Usado			:= X3Uso(AllTrim(SX3TMP->X3_CAMPO))
					::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS[01]:WsCjHeaders[_nCont]:Tipo				:= AllTrim(SX3TMP->X3_TIPO)
					::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS[01]:WsCjHeaders[_nCont]:ConsultF3		:= AllTrim(SX3TMP->X3_F3)
					::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS[01]:WsCjHeaders[_nCont]:Contexto			:= AllTrim(SX3TMP->X3_CONTEXT)
					::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS[01]:WsCjHeaders[_nCont]:ComboBox			:= AllTrim(SX3TMP->X3_CBOX)
					::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS[01]:WsCjHeaders[_nCont]:Inicializador	:= AllTrim(SX3TMP->X3_RELACAO)
					::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS[01]:WsCjHeaders[_nCont]:EdicaoWhen		:= AllTrim(SX3TMP->X3_WHEN)
					
					//Incluindo os campos para a Varável _aHeaderS
					aADD(_aHeaderS[Len(_aHeaderS), 02], {	AllTrim(X3Titulo())				,;
														AllTrim(SX3TMP->X3_CAMPO)			,;
														AllTrim(SX3TMP->X3_PICTURE)			,;
														SX3TMP->X3_TAMANHO					,;
														SX3TMP->X3_DECIMAL					,;
														AllTrim(SX3TMP->X3_VALID)			,;
														X3Uso(AllTrim(SX3TMP->X3_CAMPO))	,;
														AllTrim(SX3TMP->X3_TIPO)			,;
														AllTrim(SX3TMP->X3_F3)				,;
														AllTrim(SX3TMP->X3_CONTEXT)			,;
														AllTrim(SX3TMP->X3_CBOX)			,;
														AllTrim(SX3TMP->X3_RELACAO)			,;
														AllTrim(SX3TMP->X3_WHEN)			} )
					
					SX3TMP->(DbSkip())
				EndDo
			Else
				
				aADD( ::WsRetorno:WsMensagens, WSClassNew("StrMsgRet") )
				_nPMsg	:= Len( ::WsRetorno:WsMensagens )
				::WsRetorno:WsMensagens[_nPMsg]:WsCodMsg := -1
				::WsRetorno:WsMensagens[_nPMsg]:WsDScMsg := "Estrutura ( "+_aAlsPsq[_nAls]+" ) não encontrada no SX3."
				
			EndIF
		Next _nAls
		
	//Caso não seja solicitado o retorno do cabeçalho
	//O Else abaixo é utilizado para que o aCols de retorno
	//seja sempre igual ao dicionário de dados Protheus
	Else
		For _nAls := 1 To Len(_aAlsPsq)
			
			aADD(_aHeaderS, {_aAlsPsq[_nAls], { } } )
			
			OpenSxs(,,,,cEmpAnt,"SX3TMP","SX3",,.F.,.T.)
			SX3TMP->(DbSetOrder(1))
			SX3TMP->(DbGoTop())
			If SX3TMP->(DbSeek(_aAlsPsq[_nAls]))
				While SX3TMP->(!EOF()) .And. SX3TMP->X3_ARQUIVO == _aAlsPsq[_nAls]
					
					//Incluindo os campos para a Varável _aHeaderS
					aADD(_aHeaderS[Len(_aHeaderS), 02], {	AllTrim(X3Titulo())				,;
														AllTrim(SX3TMP->X3_CAMPO)			,;
														AllTrim(SX3TMP->X3_PICTURE)		,;
														SX3TMP->X3_TAMANHO					,;
														SX3TMP->X3_DECIMAL					,;
														AllTrim(SX3TMP->X3_VALID)			,;
														X3Uso(AllTrim(SX3TMP->X3_CAMPO))	,;
														AllTrim(SX3TMP->X3_TIPO)			,;
														AllTrim(SX3TMP->X3_F3)				,;
														AllTrim(SX3TMP->X3_CONTEXT)		,;
														AllTrim(SX3TMP->X3_CBOX)			,;
														AllTrim(SX3TMP->X3_RELACAO)		,;
														AllTrim(SX3TMP->X3_WHEN)			} )
					
					SX3TMP->(DbSkip())
				EndDo
			Else
				aADD( ::WsRetorno:WsMensagens, WSClassNew("StrMsgRet") )
				_nPMsg	:= Len( ::WsRetorno:WsMensagens )
				::WsRetorno:WsMensagens[_nPMsg]:WsCodMsg := -1
				::WsRetorno:WsMensagens[_nPMsg]:WsDScMsg := "Estrutura ( "+_aAlsPsq[_nAls]+" ) não encontrada no SX3."
			EndIf
			
		Next _nAls
	EndIF
	
	//Variável de Retorno dos aCols
	::WsRetorno:WsRetACols := {}
	
	DbSelectArea("ZJ8")
	ZJ8->(DbSetOrder(02))
	ZJ8->(DbGoTop())
	If ZJ8->(DbSeek(xFilial("ZJ8")+_cWsTicket))
		
		aADD( ::WsRetorno:WsRetACols, WSClassNew("StrCjAColsS") )
		
		::WsRetorno:WsRetACols[01]:WsCjACols := {}
		
		aADD( ::WsRetorno:WsRetACols[01]:WsCjACols, WSClassNew("StrACols") )
		::WsRetorno:WsRetACols[01]:WsCjACols[01]:WsCAlias := "ZJ8"
		
		::WsRetorno:WsRetACols[01]:WsCjACols[01]:WsCjItens := {}
		
		_cCntZJ8	:= 0
		_nPZJ8		:= aScan(_aHeaderS, {|X| X[01] == "ZJ8"})
		_cChvZJ8	:= xFilial("ZJ8")+_cWsTicket
		
		While ZJ8->(!EOF()) .AND. ZJ8->(ZJ8_FILIAL+ZJ8_TICKET) == _cChvZJ8
			_cCntZJ8++
			aADD( ::WsRetorno:WsRetACols[01]:WsCjACols[01]:WsCjItens, WSClassNew("StrItsACols") )
			
			RegToMemory("ZJ8", .F.)
			
			::WsRetorno:WsRetACols[01]:WsCjACols[01]:WsCjItens[_cCntZJ8]:WsCjRegistros := {}
			
			For _nP := 1 To Len(_aHeaderS[_nPZJ8, 02])
				aADD( ::WsRetorno:WsRetACols[01]:WsCjACols[01]:WsCjItens[_cCntZJ8]:WsCjRegistros, WSClassNew("StrRegACols") )
				::WsRetorno:WsRetACols[01]:WsCjACols[01]:WsCjItens[_cCntZJ8]:WsCjRegistros[_nP]:IdRegistro	:= ZJ8->(RECNO())
				::WsRetorno:WsRetACols[01]:WsCjACols[01]:WsCjItens[_cCntZJ8]:WsCjRegistros[_nP]:CampoAcols	:= _aHeaderS[_nPZJ8, 02, _nP, 02]
				
				_xContud := &("M->"+_aHeaderS[_nPZJ8, 02, _nP, 02])
				
				If "ZJ8_USERGI" == _aHeaderS[_nPZJ8, 02, _nP, 02] .Or. "ZJ8_USERGA" == _aHeaderS[_nPZJ8, 02, _nP, 02]
					_xContud := FwLeUserLG(_aHeaderS[_nPZJ8, 02, _nP, 02])
				EndIF
				
				If ValType(_xContud) == "C"
					::WsRetorno:WsRetACols[01]:WsCjACols[01]:WsCjItens[_cCntZJ8]:WsCjRegistros[_nP]:Conteudo	:= AllTrim(_xContud)
				ElseIf ValType(_xContud) == "N"
					::WsRetorno:WsRetACols[01]:WsCjACols[01]:WsCjItens[_cCntZJ8]:WsCjRegistros[_nP]:Conteudo	:= AllTrim(Str(_xContud))
				ElseIf ValType(_xContud) == "D"
					::WsRetorno:WsRetACols[01]:WsCjACols[01]:WsCjItens[_cCntZJ8]:WsCjRegistros[_nP]:Conteudo	:= DToS(_xContud)
				ElseIf ValType(_xContud) == "L"
					::WsRetorno:WsRetACols[01]:WsCjACols[01]:WsCjItens[_cCntZJ8]:WsCjRegistros[_nP]:Conteudo	:= IIF(_xContud, ".T.", ".F.")
				EndIF
			Next _nP
			
			//Posicionando na Tabela ZJ9
			DbSelectArea("ZJ9")
			ZJ9->(DbSetOrder(01))
			ZJ9->(DbGoTop())
			If ZJ9->(DbSeek(SZ8->(ZJ8_FILIAL+ZJ8_CODIGO)))
				
				aADD( ::WsRetorno:WsRetACols, WSClassNew("StrCjAColsS") )
				
				_nPACols := Len(::WsRetorno:WsRetACols)
				
				::WsRetorno:WsRetACols[_nPACols]:WsCjACols := {}
				
				aADD( ::WsRetorno:WsRetACols[_nPACols]:WsCjACols, WSClassNew("StrACols") )
				::WsRetorno:WsRetACols[_nPACols]:WsCjACols[01]:WsCAlias := "ZJ9"
				
				::WsRetorno:WsRetACols[_nPACols]:WsCjACols[01]:WsCjItens := {}
				
				_cCntZJ9	:= 0
				_nPZJ9		:= aScan(_aHeaderS, {|X| X[01] == "ZJ9"})
				
				While ZJ9->(!EOF()) .AND. ZJ9->(ZJ9_FILIAL+ZJ9_CODIGO) == SZ8->(ZJ8_FILIAL+ZJ8_CODIGO)
					
					_cCntZJ9++
					aADD( ::WsRetorno:WsRetACols[_nPACols]:WsCjACols[01]:WsCjItens, WSClassNew("StrItsACols") )
					
					RegToMemory("ZJ9", .F.)
					
					::WsRetorno:WsRetACols[_nPACols]:WsCjACols[01]:WsCjItens[_cCntZJ9]:WsCjRegistros := {}
					
					For _nP := 1 To Len(_aHeaderS[_nPZJ9, 02])
						aADD( ::WsRetorno:WsRetACols[_nPACols]:WsCjACols[01]:WsCjItens[_cCntZJ9]:WsCjRegistros, WSClassNew("StrRegACols") )
						::WsRetorno:WsRetACols[_nPACols]:WsCjACols[01]:WsCjItens[_cCntZJ9]:WsCjRegistros[_nP]:IdRegistro	:= ZJ9->(RECNO())
						::WsRetorno:WsRetACols[_nPACols]:WsCjACols[01]:WsCjItens[_cCntZJ9]:WsCjRegistros[_nP]:CampoAcols	:= _aHeaderS[_nPZJ9, 02, _nP, 02]
						
						_xContud := &("M->"+_aHeaderS[_nPZJ9, 02, _nP, 02])
						
						If "ZJ9_USERGI" == _aHeaderS[_nPZJ9, 02, _nP, 02] .Or. "ZJ9_USERGA" == _aHeaderS[_nPZJ9, 02, _nP, 02]
							_xContud := FwLeUserLG(_aHeaderS[_nPZJ9, 02, _nP, 02])
						EndIF
						
						If ValType(_xContud) == "C"
							::WsRetorno:WsRetACols[_nPACols]:WsCjACols[01]:WsCjItens[_cCntZJ9]:WsCjRegistros[_nP]:Conteudo	:= AllTrim(_xContud)
						ElseIf ValType(_xContud) == "N"
							::WsRetorno:WsRetACols[_nPACols]:WsCjACols[01]:WsCjItens[_cCntZJ9]:WsCjRegistros[_nP]:Conteudo	:= AllTrim(Str(_xContud))
						ElseIf ValType(_xContud) == "D"
							::WsRetorno:WsRetACols[_nPACols]:WsCjACols[01]:WsCjItens[_cCntZJ9]:WsCjRegistros[_nP]:Conteudo	:= DToS(_xContud)
						ElseIf ValType(_xContud) == "L"
							::WsRetorno:WsRetACols[_nPACols]:WsCjACols[01]:WsCjItens[_cCntZJ9]:WsCjRegistros[_nP]:Conteudo	:= IIF(_xContud, ".T.", ".F.")
						EndIF
					Next _nP
					
					DbSelectArea("ZJA")
					ZJA->(DbSetOrder(01))
					ZJA->(DbGoTop())
					
					_cChvZJA := ZJ8->(ZJ8_FILIAL+ZJ8_CODIGO)+ZJ9->ZJ9_SEQ
					
					If aScan(_aChvZJA, {|Z| Z == _cChvZJA }) == 0 
						
						aADD( _aChvZJA, _cChvZJA)
						
						If ZJA->(DbSeek(ZJ8->(ZJ8_FILIAL+ZJ8_CODIGO)+ZJ9->ZJ9_SEQ))
							
							aADD( ::WsRetorno:WsRetACols, WSClassNew("StrCjAColsS") )
							
							_nPACZJA := Len(::WsRetorno:WsRetACols)
							
							::WsRetorno:WsRetACols[_nPACZJA]:WsCjACols := {}
							
							aADD( ::WsRetorno:WsRetACols[_nPACZJA]:WsCjACols, WSClassNew("StrACols") )
							::WsRetorno:WsRetACols[_nPACZJA]:WsCjACols[01]:WsCAlias := "ZJA"
							
							::WsRetorno:WsRetACols[_nPACZJA]:WsCjACols[01]:WsCjItens := {}
							
							_cCntZJA	:= 0
							_nPZJA		:= aScan(_aHeaderS, {|X| X[01] == "ZJA"})
							
							While ZJA->(!EOF()) .AND. ZJA->(ZJA_FILIAL+ZJA_CODIGO+ZJA_SEQ) == _cChvZJA
								
								_cCntZJA++
								aADD( ::WsRetorno:WsRetACols[_nPACZJA]:WsCjACols[01]:WsCjItens, WSClassNew("StrItsACols") )
								
								RegToMemory("ZJA", .F.)
								
								::WsRetorno:WsRetACols[_nPACZJA]:WsCjACols[01]:WsCjItens[_cCntZJA]:WsCjRegistros := {}
								
								For _nP := 1 To Len(_aHeaderS[_nPZJA, 02])
									aADD( ::WsRetorno:WsRetACols[_nPACZJA]:WsCjACols[01]:WsCjItens[_cCntZJA]:WsCjRegistros, WSClassNew("StrRegACols") )
									::WsRetorno:WsRetACols[_nPACZJA]:WsCjACols[01]:WsCjItens[_cCntZJA]:WsCjRegistros[_nP]:IdRegistro	:= ZJA->(RECNO())
									::WsRetorno:WsRetACols[_nPACZJA]:WsCjACols[01]:WsCjItens[_cCntZJA]:WsCjRegistros[_nP]:CampoAcols	:= _aHeaderS[_nPZJA, 02, _nP, 02]
									
									_xContud := &("M->"+_aHeaderS[_nPZJA, 02, _nP, 02])
									
									If "ZJA_USERGI" == _aHeaderS[_nPZJA, 02, _nP, 02] .Or. "ZJA_USERGA" == _aHeaderS[_nPZJA, 02, _nP, 02]
										_xContud := FwLeUserLG(_aHeaderS[_nPZJA, 02, _nP, 02])
									EndIF
									
									If ValType(_xContud) == "C"
										::WsRetorno:WsRetACols[_nPACZJA]:WsCjACols[01]:WsCjItens[_cCntZJA]:WsCjRegistros[_nP]:Conteudo	:= AllTrim(_xContud)
									ElseIf ValType(_xContud) == "N"
										::WsRetorno:WsRetACols[_nPACZJA]:WsCjACols[01]:WsCjItens[_cCntZJA]:WsCjRegistros[_nP]:Conteudo	:= AllTrim(Str(_xContud))
									ElseIf ValType(_xContud) == "D"
										::WsRetorno:WsRetACols[_nPACZJA]:WsCjACols[01]:WsCjItens[_cCntZJA]:WsCjRegistros[_nP]:Conteudo	:= DToS(_xContud)
									ElseIf ValType(_xContud) == "L"
										::WsRetorno:WsRetACols[_nPACZJA]:WsCjACols[01]:WsCjItens[_cCntZJA]:WsCjRegistros[_nP]:Conteudo	:= IIF(_xContud, ".T.", ".F.")
									EndIF
								Next _nP
								
								ZJA->(DbSkip())
							EndDo
						Else
							aADD( ::WsRetorno:WsMensagens, WSClassNew("StrMsgRet") )
							_nPMsg	:= Len( ::WsRetorno:WsMensagens )
							::WsRetorno:WsMensagens[_nPMsg]:WsCodMsg := -4
							::WsRetorno:WsMensagens[_nPMsg]:WsDScMsg := "Filial+Codigo+Sequencia ("+SZ8->(ZJ8_FILIAL+ZJ8_CODIGO)+ZJ9->ZJ9_SEQ+") - Ticket ("+WsTicket+") não encontrado. Tabela ZJA, reponsável pelos Status de execução da sequencia."
						EndIF
						
					EndIF
					
					ZJ9->(DbSkip())
				EndDo
			Else
				
				aADD( ::WsRetorno:WsMensagens, WSClassNew("StrMsgRet") )
				_nPMsg	:= Len( ::WsRetorno:WsMensagens )
				::WsRetorno:WsMensagens[_nPMsg]:WsCodMsg := -3
				::WsRetorno:WsMensagens[_nPMsg]:WsDScMsg := "Filial+Codigo ("+SZ8->(ZJ8_FILIAL+ZJ8_CODIGO)+") - Ticket ("+WsTicket+") não encontrado. Tabela ZJ9, reponsável pelos itens de registros enviados ao WebService"
				
			EndIF
			
			ZJ8->(DbSkip())
		EndDo
	Else
		aADD( ::WsRetorno:WsMensagens, WSClassNew("StrMsgRet") )
		_nPMsg	:= Len( ::WsRetorno:WsMensagens )
		::WsRetorno:WsMensagens[_nPMsg]:WsCodMsg := -2
		::WsRetorno:WsMensagens[_nPMsg]:WsDScMsg := "Filial+Ticket ("+xFilial("ZJ8")+WsTicket+") não encontrado. Tabela ZJ8 responsável pela cabeçalho do Ticket."
	EndIF
	
	If EMPTY(::WsRetorno:WsMensagens)
		aADD( ::WsRetorno:WsMensagens, WSClassNew("StrMsgRet") )
		_nPMsg	:= Len( ::WsRetorno:WsMensagens )
		::WsRetorno:WsMensagens[_nPMsg]:WsCodMsg := 0
		::WsRetorno:WsMensagens[_nPMsg]:WsDScMsg := "Consulta processada com sucesso."
	EndIF
	
//RESET ENVIRONMENT

Return .T.


/*/================================================================================================================================/*/
/*/{Protheus.doc} InfCliente
Metodo da Classe WEBA01PA, responsável por retornar as informações do Ticket. 

@type 	 method
@author  Thiago Rasmussen
@since 	 15/02/2019
@version P12.1.23
@obs 	 Desenvolvimento FIEG
@return  Lógico, retorna verdadeiro.
@history 14/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 
/*/
/*/================================================================================================================================/*/

WsMethod InfCliente WsReceive WsCEmp,WsCFil,WsLogin,WsSenha,WsCliente,WsAHeader WsSend WsRetorno WsService WEBA01PA

Local _aAlsPsq	:= {"SA1"}
Local _aHeaderS	:= {}
Local _lLogin	:= .T.

Private INCLUI	:= .F.

PswOrder(02) //Nome do Usuário
//Posionando no Usuário
If PswSeek( WsLogin, .T. )
	//A Variável é alterada para o Login conforme o cadastrado no Protheus.
	//Pois para a função do Prepare Environment é necessário dessa forma.
	WsLogin := AllTrim(PswRet()[01,02])
Else
	_lLogin := .F.
EndIf

//Validando a senha após posiciona no Usuário.
If !PswName( WsSenha )
	_lLogin := .F.
EndIf

//Caso não tenha passado pela validação de usuário e senha do Protheus.
If !_lLogin
	
	If EMPTY(::WsRetorno:WsMensagens)
		aADD( ::WsRetorno:WsMensagens, WSClassNew("StrMsgRet") )
		_nPMsg	:= Len( ::WsRetorno:WsMensagens )
		::WsRetorno:WsMensagens[_nPMsg]:WsCodMsg := -5
		::WsRetorno:WsMensagens[_nPMsg]:WsDScMsg := "Usuário ou Senha Inválido."
	EndIF
	
	RETURN .T.
	
EndIF

RPCSetType(3)
//PREPARE ENVIRONMENT EMPRESA WsCEmp FILIAL WsCFil USER WsLogin PASSWORD WsSenha
SetModulo("SIGAFIN","FIN")
	
	//Variável para as mensagens de retorno.
	::WsRetorno:WsMensagens := {}
	//aADD( ::WsRetorno:WsMensagens, WSClassNew("StrMsgRet") )
	
	If WsAHeader
		
		::WsRetorno:WsRetHeader := {}
		
		For _nAls := 1 To Len(_aAlsPsq)
			
			aADD( ::WsRetorno:WsRetHeader, WSClassNew("StrCjAliasS") )
			
			::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS := {}
			aADD( ::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS, WSClassNew("StrAlias") )
			::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS[01]:WsHAlias := _aAlsPsq[_nAls]
			::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS[01]:WsHDscAlias := UPPER( AllTrim(Posicione("SX2", 1, _aAlsPsq[_nAls], "X2_NOME")) )
			
			aADD(_aHeaderS, {_aAlsPsq[_nAls], {} } )
			
			::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS[01]:WsCjHeaders := {}
			
			OpenSxs(,,,,cEmpAnt,"SX3TMP","SX3",,.F.,.T.)
			SX3TMP->(DbSetOrder(1))
			SX3TMP->(DbGoTop())
			If SX3TMP->(DbSeek(_aAlsPsq[_nAls]))
				_nCont := 0
				While SX3TMP->(!EOF()) .And. SX3TMP->X3_ARQUIVO == _aAlsPsq[_nAls]
					_nCont++
					
					//Incluindo os campos para o Retorno do WebService.
					aADD( ::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS[01]:WsCjHeaders, WSClassNew("StrHeaders") )
					::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS[01]:WsCjHeaders[_nCont]:Titulo			:= AllTrim(X3Titulo())
					::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS[01]:WsCjHeaders[_nCont]:Campo			:= AllTrim(SX3TMP->X3_CAMPO)
					::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS[01]:WsCjHeaders[_nCont]:Mascara			:= AllTrim(SX3TMP->X3_PICTURE)
					::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS[01]:WsCjHeaders[_nCont]:Tamanho			:= SX3TMP->X3_TAMANHO
					::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS[01]:WsCjHeaders[_nCont]:Decimal			:= SX3TMP->X3_DECIMAL
					::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS[01]:WsCjHeaders[_nCont]:Validacao		:= AllTrim(SX3TMP->X3_VALID)
					::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS[01]:WsCjHeaders[_nCont]:Usado			:= X3Uso(AllTrim(SX3TMP->X3_CAMPO))
					::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS[01]:WsCjHeaders[_nCont]:Tipo				:= AllTrim(SX3TMP->X3_TIPO)
					::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS[01]:WsCjHeaders[_nCont]:ConsultF3		:= AllTrim(SX3TMP->X3_F3)
					::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS[01]:WsCjHeaders[_nCont]:Contexto			:= AllTrim(SX3TMP->X3_CONTEXT)
					::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS[01]:WsCjHeaders[_nCont]:ComboBox			:= AllTrim(SX3TMP->X3_CBOX)
					::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS[01]:WsCjHeaders[_nCont]:Inicializador	:= AllTrim(SX3TMP->X3_RELACAO)
					::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS[01]:WsCjHeaders[_nCont]:EdicaoWhen		:= AllTrim(SX3TMP->X3_WHEN)
					
					//Incluindo os campos para a Varável _aHeaderS
					aADD(_aHeaderS[Len(_aHeaderS), 02], {	AllTrim(X3Titulo())				,;
														AllTrim(SX3TMP->X3_CAMPO)			,;
														AllTrim(SX3TMP->X3_PICTURE)		,;
														SX3TMP->X3_TAMANHO					,;
														SX3TMP->X3_DECIMAL					,;
														AllTrim(SX3TMP->X3_VALID)			,;
														X3Uso(AllTrim(SX3TMP->X3_CAMPO))	,;
														AllTrim(SX3TMP->X3_TIPO)			,;
														AllTrim(SX3TMP->X3_F3)				,;
														AllTrim(SX3TMP->X3_CONTEXT)		,;
														AllTrim(SX3TMP->X3_CBOX)			,;
														AllTrim(SX3TMP->X3_RELACAO)		,;
														AllTrim(SX3TMP->X3_WHEN)			} )
					
					SX3TMP->(DbSkip())
				EndDo
			Else
				
				aADD( ::WsRetorno:WsMensagens, WSClassNew("StrMsgRet") )
				_nPMsg	:= Len( ::WsRetorno:WsMensagens )
				::WsRetorno:WsMensagens[_nPMsg]:WsCodMsg := -1
				::WsRetorno:WsMensagens[_nPMsg]:WsDScMsg := "Estrutura ( "+_aAlsPsq[_nAls]+" ) não encontrada no SX3."
				
			EndIF
		Next _nAls
		
	//Caso não seja solicitado o retorno do cabeçalho
	//O Else abaixo é utilizado para que o aCols de retorno
	//seja sempre igual ao dicionário de dados Protheus
	Else
		For _nAls := 1 To Len(_aAlsPsq)
			
			aADD(_aHeaderS, {_aAlsPsq[_nAls], { } } )
			
			OpenSxs(,,,,cEmpAnt,"SX3TMP","SX3",,.F.,.T.)
			SX3TMP->(DbSetOrder(1))
			SX3TMP->(DbGoTop())
			If SX3TMP->(DbSeek(_aAlsPsq[_nAls]))
				While SX3TMP->(!EOF()) .And. SX3TMP->X3_ARQUIVO == _aAlsPsq[_nAls]
					
					//Incluindo os campos para a Varável _aHeaderS
					aADD(_aHeaderS[Len(_aHeaderS), 02], {	AllTrim(X3Titulo())				,;
														AllTrim(SX3TMP->X3_CAMPO)			,;
														AllTrim(SX3TMP->X3_PICTURE)		,;
														SX3TMP->X3_TAMANHO					,;
														SX3TMP->X3_DECIMAL					,;
														AllTrim(SX3TMP->X3_VALID)			,;
														X3Uso(AllTrim(SX3TMP->X3_CAMPO))	,;
														AllTrim(SX3TMP->X3_TIPO)			,;
														AllTrim(SX3TMP->X3_F3)				,;
														AllTrim(SX3TMP->X3_CONTEXT)		,;
														AllTrim(SX3TMP->X3_CBOX)			,;
														AllTrim(SX3TMP->X3_RELACAO)		,;
														AllTrim(SX3TMP->X3_WHEN)			} )
					
					SX3TMP->(DbSkip())
				EndDo
			Else
				aADD( ::WsRetorno:WsMensagens, WSClassNew("StrMsgRet") )
				_nPMsg	:= Len( ::WsRetorno:WsMensagens )
				::WsRetorno:WsMensagens[_nPMsg]:WsCodMsg := -1
				::WsRetorno:WsMensagens[_nPMsg]:WsDScMsg := "Estrutura ( "+_aAlsPsq[_nAls]+" ) não encontrada no SX3."
			EndIf
			
		Next _nAls
	EndIF
	
	//WsData WsCodCli	AS String
	//WsData WsLojCli	AS String
	//WsData WsCgcCli	AS String
	//
	If !Empty(::WsCliente:WsCgcCli)
		_cCpoPsq := "CGC"
		_cPsqSA1 := SubStr(::WsCliente:WsCgcCli + Space(TamSX3("A1_CGC")[01]), 01, TamSX3("A1_CGC")[01])
		_nOrdSA1 := 03
		_cCondSA1	:= "SA1->(A1_FILIAL+A1_CGC) == _cChvSA1"
	Else
		_cCpoPsq := "Código+Loja"
		_cPsqSA1 := ::WsCliente:WsCodCli+::WsCliente:WsLojCli
		_nOrdSA1 := 01
		_cCondSA1	:= "SA1->(A1_FILIAL+A1_COD+A1_LOJA) == _cChvSA1"
	EndIF
	
	//Variável de Retorno dos aCols
	::WsRetorno:WsRetACols := {}
	
	DbSelectArea("SA1")
	SA1->(DbSetOrder(_nOrdSA1))
	SA1->(DbGoTop())
	If SA1->(DbSeek(xFilial("SA1")+_cPsqSA1))
		
		aADD( ::WsRetorno:WsRetACols, WSClassNew("StrCjAColsS") )
		
		::WsRetorno:WsRetACols[01]:WsCjACols := {}
		
		aADD( ::WsRetorno:WsRetACols[01]:WsCjACols, WSClassNew("StrACols") )
		::WsRetorno:WsRetACols[01]:WsCjACols[01]:WsCAlias := "SA1"
		
		::WsRetorno:WsRetACols[01]:WsCjACols[01]:WsCjItens := {}
		
		_cCntSA1	:= 0
		_nPSA1		:= aScan(_aHeaderS, {|X| X[01] == "SA1"})
		_cChvSA1	:= xFilial("SA1")+_cPsqSA1
		
		While SA1->(!EOF()) .AND. IIF(!Empty(::WsCliente:WsCgcCli), (SA1->(A1_FILIAL+A1_CGC) == _cChvSA1), (SA1->(A1_FILIAL+A1_COD+A1_LOJA) == _cChvSA1) )
			_cCntSA1++
			
			aADD( ::WsRetorno:WsRetACols[01]:WsCjACols[01]:WsCjItens, WSClassNew("StrItsACols") )
			
			RegToMemory("SA1", .F.)
			
			::WsRetorno:WsRetACols[01]:WsCjACols[01]:WsCjItens[_cCntSA1]:WsCjRegistros := {}
			
			For _nP := 1 To Len(_aHeaderS[_nPSA1, 02])
				aADD( ::WsRetorno:WsRetACols[01]:WsCjACols[01]:WsCjItens[_cCntSA1]:WsCjRegistros, WSClassNew("StrRegACols") )
				::WsRetorno:WsRetACols[01]:WsCjACols[01]:WsCjItens[_cCntSA1]:WsCjRegistros[_nP]:IdRegistro	:= SA1->(RECNO())
				::WsRetorno:WsRetACols[01]:WsCjACols[01]:WsCjItens[_cCntSA1]:WsCjRegistros[_nP]:CampoAcols	:= _aHeaderS[_nPSA1, 02, _nP, 02]
				
				//CONTEXTO - REAL ou VIRTUAL
				//Os IF Abaixo foram utilizados para verificar a situação de não-conformidade na execução da rotina
				//RegToMemory ao qual foi visto que faltava a variável INCLUIR.
				/*
				If _aHeaderS[_nPSA1, 02, _nP, 10] != "V"
					_xContud := &("M->"+_aHeaderS[_nPSA1, 02, _nP, 02]+" := SA1->"+_aHeaderS[_nPSA1, 02, _nP, 02])
				Else
					ConOut(_aHeaderS[_nPSA1, 02, _nP, 02])
					_xContud := &("M->"+_aHeaderS[_nPSA1, 02, _nP, 02]+" := CriaVar('"+_aHeaderS[_nPSA1, 02, _nP, 02]+"')")
				EndIf
				*/
				
				_xContud := &("M->"+_aHeaderS[_nPSA1, 02, _nP, 02])
				
				If "A1_USERLGI" == _aHeaderS[_nPSA1, 02, _nP, 02] .Or. "A1_USERLGA" == _aHeaderS[_nPSA1, 02, _nP, 02]
					_xContud := FwLeUserLG(_aHeaderS[_nPSA1, 02, _nP, 02])
				EndIF
				
				If ValType(_xContud) == "C"
					::WsRetorno:WsRetACols[01]:WsCjACols[01]:WsCjItens[_cCntSA1]:WsCjRegistros[_nP]:Conteudo	:= AllTrim(_xContud)
				ElseIf ValType(_xContud) == "N"
					::WsRetorno:WsRetACols[01]:WsCjACols[01]:WsCjItens[_cCntSA1]:WsCjRegistros[_nP]:Conteudo	:= AllTrim(Str(_xContud))
				ElseIf ValType(_xContud) == "D"
					::WsRetorno:WsRetACols[01]:WsCjACols[01]:WsCjItens[_cCntSA1]:WsCjRegistros[_nP]:Conteudo	:= DToS(_xContud)
				ElseIf ValType(_xContud) == "L"
					::WsRetorno:WsRetACols[01]:WsCjACols[01]:WsCjItens[_cCntSA1]:WsCjRegistros[_nP]:Conteudo	:= IIF(_xContud, ".T.", ".F.")
				EndIF
			Next _nP
			
			SA1->(DbSkip())
		EndDo
	Else
		aADD( ::WsRetorno:WsMensagens, WSClassNew("StrMsgRet") )
		_nPMsg	:= Len( ::WsRetorno:WsMensagens )
		::WsRetorno:WsMensagens[_nPMsg]:WsCodMsg := -2
		::WsRetorno:WsMensagens[_nPMsg]:WsDScMsg := "Filial+"+_cCpoPsq+" ("+xFilial("SA1")+_cPsqSA1+") não encontrado. Tabela SA1 Cadastro de Cliente."
	EndIF
	
	If EMPTY(::WsRetorno:WsMensagens)
		aADD( ::WsRetorno:WsMensagens, WSClassNew("StrMsgRet") )
		_nPMsg	:= Len( ::WsRetorno:WsMensagens )
		::WsRetorno:WsMensagens[_nPMsg]:WsCodMsg := 0
		::WsRetorno:WsMensagens[_nPMsg]:WsDScMsg := "Consulta processada com sucesso."
	EndIF

//RESET ENVIRONMENT

Return .T.



/*/================================================================================================================================/*/
/*/{Protheus.doc} InfFornecedor
Metodo da Classe WEBA01PA, responsável por retornar as informações do Fornecedor.

@type 	 method
@author  Thiago Rasmussen
@since 	 15/02/2019
@version P12.1.23
@obs 	 Desenvolvimento FIEG
@return  Lógico, retorna verdadeiro.
@history 14/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 
/*/
/*/================================================================================================================================/*/

WsMethod InfFornecedor WsReceive WsCEmp,WsCFil,WsLogin,WsSenha,WsFornecedor,WsAHeader WsSend WsRetorno WsService WEBA01PA

Local _aAlsPsq	:= {"SA2"}
Local _aHeaderS	:= {}
Local _lLogin	:= .T.

Private INCLUI	:= .F.

PswOrder(02) //Nome do Usuário
//Posionando no Usuário
If PswSeek( WsLogin, .T. )
	//A Variável é alterada para o Login conforme o cadastrado no Protheus.
	//Pois para a função do Prepare Environment é necessário dessa forma.
	WsLogin := AllTrim(PswRet()[01,02])
Else
	_lLogin := .F.
EndIf

//Validando a senha após posiciona no Usuário.
If !PswName( WsSenha )
	_lLogin := .F.
EndIf

//Caso não tenha passado pela validação de usuário e senha do Protheus.
If !_lLogin
	
	If EMPTY(::WsRetorno:WsMensagens)
		aADD( ::WsRetorno:WsMensagens, WSClassNew("StrMsgRet") )
		_nPMsg	:= Len( ::WsRetorno:WsMensagens )
		::WsRetorno:WsMensagens[_nPMsg]:WsCodMsg := -5
		::WsRetorno:WsMensagens[_nPMsg]:WsDScMsg := "Usuário ou Senha Inválido."
	EndIF
	
	RETURN .T.
	
EndIF

RPCSetType(3)
//PREPARE ENVIRONMENT EMPRESA WsCEmp FILIAL WsCFil USER WsLogin PASSWORD WsSenha
SetModulo("SIGAFIN","FIN")
	
	//Variável para as mensagens de retorno.
	::WsRetorno:WsMensagens := {}
	//aADD( ::WsRetorno:WsMensagens, WSClassNew("StrMsgRet") )
	
	If WsAHeader
		
		::WsRetorno:WsRetHeader := {}
		
		For _nAls := 1 To Len(_aAlsPsq)
			
			aADD( ::WsRetorno:WsRetHeader, WSClassNew("StrCjAliasS") )
			
			::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS := {}
			aADD( ::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS, WSClassNew("StrAlias") )
			::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS[01]:WsHAlias := _aAlsPsq[_nAls]
			::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS[01]:WsHDscAlias := UPPER( AllTrim(Posicione("SX2", 1, _aAlsPsq[_nAls], "X2_NOME")) )
			
			aADD(_aHeaderS, {_aAlsPsq[_nAls], {} } )
			
			::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS[01]:WsCjHeaders := {}
			
			OpenSxs(,,,,cEmpAnt,"SX3TMP","SX3",,.F.,.T.)
			SX3TMP->(DbSetOrder(1))
			SX3TMP->(DbGoTop())
			If SX3TMP->(DbSeek(_aAlsPsq[_nAls]))
				_nCont := 0
				While SX3TMP->(!EOF()) .And. SX3TMP->X3_ARQUIVO == _aAlsPsq[_nAls]
					_nCont++
					
					//Incluindo os campos para o Retorno do WebService.
					aADD( ::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS[01]:WsCjHeaders, WSClassNew("StrHeaders") )
					::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS[01]:WsCjHeaders[_nCont]:Titulo			:= AllTrim(X3Titulo())
					::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS[01]:WsCjHeaders[_nCont]:Campo			:= AllTrim(SX3TMP->X3_CAMPO)
					::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS[01]:WsCjHeaders[_nCont]:Mascara			:= AllTrim(SX3TMP->X3_PICTURE)
					::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS[01]:WsCjHeaders[_nCont]:Tamanho			:= SX3TMP->X3_TAMANHO
					::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS[01]:WsCjHeaders[_nCont]:Decimal			:= SX3TMP->X3_DECIMAL
					::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS[01]:WsCjHeaders[_nCont]:Validacao		:= AllTrim(SX3TMP->X3_VALID)
					::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS[01]:WsCjHeaders[_nCont]:Usado			:= X3Uso(AllTrim(SX3TMP->X3_CAMPO))
					::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS[01]:WsCjHeaders[_nCont]:Tipo				:= AllTrim(SX3TMP->X3_TIPO)
					::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS[01]:WsCjHeaders[_nCont]:ConsultF3		:= AllTrim(SX3TMP->X3_F3)
					::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS[01]:WsCjHeaders[_nCont]:Contexto			:= AllTrim(SX3TMP->X3_CONTEXT)
					::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS[01]:WsCjHeaders[_nCont]:ComboBox			:= AllTrim(SX3TMP->X3_CBOX)
					::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS[01]:WsCjHeaders[_nCont]:Inicializador	:= AllTrim(SX3TMP->X3_RELACAO)
					::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS[01]:WsCjHeaders[_nCont]:EdicaoWhen		:= AllTrim(SX3TMP->X3_WHEN)
					
					//Incluindo os campos para a Varável _aHeaderS
					aADD(_aHeaderS[Len(_aHeaderS), 02], {	AllTrim(X3Titulo())				,;
														AllTrim(SX3TMP->X3_CAMPO)			,;
														AllTrim(SX3TMP->X3_PICTURE)		,;
														SX3TMP->X3_TAMANHO					,;
														SX3TMP->X3_DECIMAL					,;
														AllTrim(SX3TMP->X3_VALID)			,;
														X3Uso(AllTrim(SX3TMP->X3_CAMPO))	,;
														AllTrim(SX3TMP->X3_TIPO)			,;
														AllTrim(SX3TMP->X3_F3)				,;
														AllTrim(SX3TMP->X3_CONTEXT)		,;
														AllTrim(SX3TMP->X3_CBOX)			,;
														AllTrim(SX3TMP->X3_RELACAO)		,;
														AllTrim(SX3TMP->X3_WHEN)			} )
					
					SX3TMP->(DbSkip())
				EndDo
			Else
				
				aADD( ::WsRetorno:WsMensagens, WSClassNew("StrMsgRet") )
				_nPMsg	:= Len( ::WsRetorno:WsMensagens )
				::WsRetorno:WsMensagens[_nPMsg]:WsCodMsg := -1
				::WsRetorno:WsMensagens[_nPMsg]:WsDScMsg := "Estrutura ( "+_aAlsPsq[_nAls]+" ) não encontrada no SX3."
				
			EndIF
		Next _nAls
		
	//Caso não seja solicitado o retorno do cabeçalho
	//O Else abaixo é utilizado para que o aCols de retorno
	//seja sempre igual ao dicionário de dados Protheus
	Else
		For _nAls := 1 To Len(_aAlsPsq)
			
			aADD(_aHeaderS, {_aAlsPsq[_nAls], { } } )
			
			OpenSxs(,,,,cEmpAnt,"SX3TMP","SX3",,.F.,.T.)
			SX3TMP->(DbSetOrder(1))
			SX3TMP->(DbGoTop())
			If SX3TMP->(DbSeek(_aAlsPsq[_nAls]))
				While SX3TMP->(!EOF()) .And. SX3TMP->X3_ARQUIVO == _aAlsPsq[_nAls]
					
					//Incluindo os campos para a Varável _aHeaderS
					aADD(_aHeaderS[Len(_aHeaderS), 02], {	AllTrim(X3Titulo())				,;
														AllTrim(SX3TMP->X3_CAMPO)			,;
														AllTrim(SX3TMP->X3_PICTURE)		,;
														SX3TMP->X3_TAMANHO					,;
														SX3TMP->X3_DECIMAL					,;
														AllTrim(SX3TMP->X3_VALID)			,;
														X3Uso(AllTrim(SX3TMP->X3_CAMPO))	,;
														AllTrim(SX3TMP->X3_TIPO)			,;
														AllTrim(SX3TMP->X3_F3)				,;
														AllTrim(SX3TMP->X3_CONTEXT)		,;
														AllTrim(SX3TMP->X3_CBOX)			,;
														AllTrim(SX3TMP->X3_RELACAO)		,;
														AllTrim(SX3TMP->X3_WHEN)			} )
					
					SX3TMP->(DbSkip())
				EndDo
			Else
				aADD( ::WsRetorno:WsMensagens, WSClassNew("StrMsgRet") )
				_nPMsg	:= Len( ::WsRetorno:WsMensagens )
				::WsRetorno:WsMensagens[_nPMsg]:WsCodMsg := -1
				::WsRetorno:WsMensagens[_nPMsg]:WsDScMsg := "Estrutura ( "+_aAlsPsq[_nAls]+" ) não encontrada no SX3."
			EndIf
			
		Next _nAls
	EndIF
	
	//WsData WsCodCli	AS String
	//WsData WsLojCli	AS String
	//WsData WsCgcCli	AS String
	//
	If !Empty(::WsCliente:WsCgcCli)
		_cCpoPsq := "CGC"
		_cPsqSA1 := SubStr(::WsCliente:WsCgcCli + Space(TamSX3("A1_CGC")[01]), 01, TamSX3("A1_CGC")[01])
		_nOrdSA1 := 03
		_cCondSA1	:= "SA1->(A1_FILIAL+A1_CGC) == _cChvSA1"
	Else
		_cCpoPsq := "Código+Loja"
		_cPsqSA1 := ::WsCliente:WsCodCli+::WsCliente:WsLojCli
		_nOrdSA1 := 01
		_cCondSA1	:= "SA1->(A1_FILIAL+A1_COD+A1_LOJA) == _cChvSA1"
	EndIF
	
	//Variável de Retorno dos aCols
	::WsRetorno:WsRetACols := {}
	
	DbSelectArea("SA1")
	SA1->(DbSetOrder(_nOrdSA1))
	SA1->(DbGoTop())
	If SA1->(DbSeek(xFilial("SA1")+_cPsqSA1))
		
		aADD( ::WsRetorno:WsRetACols, WSClassNew("StrCjAColsS") )
		
		::WsRetorno:WsRetACols[01]:WsCjACols := {}
		
		aADD( ::WsRetorno:WsRetACols[01]:WsCjACols, WSClassNew("StrACols") )
		::WsRetorno:WsRetACols[01]:WsCjACols[01]:WsCAlias := "SA1"
		
		::WsRetorno:WsRetACols[01]:WsCjACols[01]:WsCjItens := {}
		
		_cCntSA1	:= 0
		_nPSA1		:= aScan(_aHeaderS, {|X| X[01] == "SA1"})
		_cChvSA1	:= xFilial("SA1")+_cPsqSA1
		
		While SA1->(!EOF()) .AND. IIF(!Empty(::WsCliente:WsCgcCli), (SA1->(A1_FILIAL+A1_CGC) == _cChvSA1), (SA1->(A1_FILIAL+A1_COD+A1_LOJA) == _cChvSA1) )
			_cCntSA1++
			
			aADD( ::WsRetorno:WsRetACols[01]:WsCjACols[01]:WsCjItens, WSClassNew("StrItsACols") )
			
			RegToMemory("SA1", .F.)
			
			::WsRetorno:WsRetACols[01]:WsCjACols[01]:WsCjItens[_cCntSA1]:WsCjRegistros := {}
			
			For _nP := 1 To Len(_aHeaderS[_nPSA1, 02])
				aADD( ::WsRetorno:WsRetACols[01]:WsCjACols[01]:WsCjItens[_cCntSA1]:WsCjRegistros, WSClassNew("StrRegACols") )
				::WsRetorno:WsRetACols[01]:WsCjACols[01]:WsCjItens[_cCntSA1]:WsCjRegistros[_nP]:IdRegistro	:= SA1->(RECNO())
				::WsRetorno:WsRetACols[01]:WsCjACols[01]:WsCjItens[_cCntSA1]:WsCjRegistros[_nP]:CampoAcols	:= _aHeaderS[_nPSA1, 02, _nP, 02]
				
				//CONTEXTO - REAL ou VIRTUAL
				//Os IF Abaixo foram utilizados para verificar a situação de não-conformidade na execução da rotina
				//RegToMemory ao qual foi visto que faltava a variável INCLUIR.
				/*
				If _aHeaderS[_nPSA1, 02, _nP, 10] != "V"
					_xContud := &("M->"+_aHeaderS[_nPSA1, 02, _nP, 02]+" := SA1->"+_aHeaderS[_nPSA1, 02, _nP, 02])
				Else
					ConOut(_aHeaderS[_nPSA1, 02, _nP, 02])
					_xContud := &("M->"+_aHeaderS[_nPSA1, 02, _nP, 02]+" := CriaVar('"+_aHeaderS[_nPSA1, 02, _nP, 02]+"')")
				EndIf
				*/
				
				_xContud := &("M->"+_aHeaderS[_nPSA1, 02, _nP, 02])
				
				If "A1_USERLGI" == _aHeaderS[_nPSA1, 02, _nP, 02] .Or. "A1_USERLGA" == _aHeaderS[_nPSA1, 02, _nP, 02]
					_xContud := FwLeUserLG(_aHeaderS[_nPSA1, 02, _nP, 02])
				EndIF
				
				If ValType(_xContud) == "C"
					::WsRetorno:WsRetACols[01]:WsCjACols[01]:WsCjItens[_cCntSA1]:WsCjRegistros[_nP]:Conteudo	:= AllTrim(_xContud)
				ElseIf ValType(_xContud) == "N"
					::WsRetorno:WsRetACols[01]:WsCjACols[01]:WsCjItens[_cCntSA1]:WsCjRegistros[_nP]:Conteudo	:= AllTrim(Str(_xContud))
				ElseIf ValType(_xContud) == "D"
					::WsRetorno:WsRetACols[01]:WsCjACols[01]:WsCjItens[_cCntSA1]:WsCjRegistros[_nP]:Conteudo	:= DToS(_xContud)
				ElseIf ValType(_xContud) == "L"
					::WsRetorno:WsRetACols[01]:WsCjACols[01]:WsCjItens[_cCntSA1]:WsCjRegistros[_nP]:Conteudo	:= IIF(_xContud, ".T.", ".F.")
				EndIF
			Next _nP
			
			SA1->(DbSkip())
		EndDo
	Else
		aADD( ::WsRetorno:WsMensagens, WSClassNew("StrMsgRet") )
		_nPMsg	:= Len( ::WsRetorno:WsMensagens )
		::WsRetorno:WsMensagens[_nPMsg]:WsCodMsg := -2
		::WsRetorno:WsMensagens[_nPMsg]:WsDScMsg := "Filial+"+_cCpoPsq+" ("+xFilial("SA1")+_cPsqSA1+") não encontrado. Tabela SA1 Cadastro de Cliente."
	EndIF
	
	If EMPTY(::WsRetorno:WsMensagens)
		aADD( ::WsRetorno:WsMensagens, WSClassNew("StrMsgRet") )
		_nPMsg	:= Len( ::WsRetorno:WsMensagens )
		::WsRetorno:WsMensagens[_nPMsg]:WsCodMsg := 0
		::WsRetorno:WsMensagens[_nPMsg]:WsDScMsg := "Consulta processada com sucesso."
	EndIF

//RESET ENVIRONMENT

Return .T.


/*/================================================================================================================================/*/
/*/{Protheus.doc} InfTitulo
Metodo da Classe WEBA01PA, responsável por retornar as informações do Título.

@type 	 method
@author  Thiago Rasmussen
@since 	 15/02/2019
@version P12.1.23
@obs 	 Desenvolvimento FIEG
@return  Lógico, retorna verdadeiro.
@history 14/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 
/*/
/*/================================================================================================================================/*/

WsMethod InfTitulo WsReceive WsCEmp,WsCFil,WsLogin,WsSenha,WsTitulo,WsAHeader /*,WsMovTit*/ WsSend WsRetorno WsService WEBA01PA

Local _aAlsPsq	:= {"SE1"}
Local _aHeaderS	:= {}
Local _lLogin	:= .T.

Private INCLUI	:= .F.

PswOrder(02) //Nome do Usuário
//Posionando no Usuário
If PswSeek( WsLogin, .T. )
	//A Variável é alterada para o Login conforme o cadastrado no Protheus.
	//Pois para a função do Prepare Environment é necessário dessa forma.
	WsLogin := AllTrim(PswRet()[01,02])
Else
	_lLogin := .F.
EndIf

//Validando a senha após posiciona no Usuário.
If !PswName( WsSenha )
	_lLogin := .F.
EndIf

//Caso não tenha passado pela validação de usuário e senha do Protheus.
If !_lLogin
	
	If EMPTY(::WsRetorno:WsMensagens)
		aADD( ::WsRetorno:WsMensagens, WSClassNew("StrMsgRet") )
		_nPMsg	:= Len( ::WsRetorno:WsMensagens )
		::WsRetorno:WsMensagens[_nPMsg]:WsCodMsg := -5
		::WsRetorno:WsMensagens[_nPMsg]:WsDScMsg := "Usuário ou Senha Inválido."
	EndIF
	
	RETURN .T.
	
EndIF

RPCSetType(3)
//PREPARE ENVIRONMENT EMPRESA WsCEmp FILIAL WsCFil USER WsLogin PASSWORD WsSenha
SetModulo("SIGAFIN","FIN")
	
	//Variável para as mensagens de retorno.
	::WsRetorno:WsMensagens := {}
	//aADD( ::WsRetorno:WsMensagens, WSClassNew("StrMsgRet") )
	
	If WsAHeader
		
		::WsRetorno:WsRetHeader := {}
		
		For _nAls := 1 To Len(_aAlsPsq)
			
			aADD( ::WsRetorno:WsRetHeader, WSClassNew("StrCjAliasS") )
			
			::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS := {}
			aADD( ::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS, WSClassNew("StrAlias") )
			::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS[01]:WsHAlias := _aAlsPsq[_nAls]
			::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS[01]:WsHDscAlias := UPPER( AllTrim(Posicione("SX2", 1, _aAlsPsq[_nAls], "X2_NOME")) )
			
			aADD(_aHeaderS, {_aAlsPsq[_nAls], {} } )
			
			::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS[01]:WsCjHeaders := {}
			
			OpenSxs(,,,,cEmpAnt,"SX3TMP","SX3",,.F.,.T.)
			SX3TMP->(DbSetOrder(1))
			SX3TMP->(DbGoTop())
			If SX3TMP->(DbSeek(_aAlsPsq[_nAls]))
				_nCont := 0
				While SX3TMP->(!EOF()) .And. SX3TMP->X3_ARQUIVO == _aAlsPsq[_nAls]
					_nCont++
					
					//Incluindo os campos para o Retorno do WebService.
					aADD( ::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS[01]:WsCjHeaders, WSClassNew("StrHeaders") )
					::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS[01]:WsCjHeaders[_nCont]:Titulo			:= AllTrim(X3Titulo())
					::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS[01]:WsCjHeaders[_nCont]:Campo			:= AllTrim(SX3TMP->X3_CAMPO)
					::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS[01]:WsCjHeaders[_nCont]:Mascara			:= AllTrim(SX3TMP->X3_PICTURE)
					::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS[01]:WsCjHeaders[_nCont]:Tamanho			:= SX3TMP->X3_TAMANHO
					::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS[01]:WsCjHeaders[_nCont]:Decimal			:= SX3TMP->X3_DECIMAL
					::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS[01]:WsCjHeaders[_nCont]:Validacao		:= AllTrim(SX3TMP->X3_VALID)
					::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS[01]:WsCjHeaders[_nCont]:Usado			:= X3Uso(AllTrim(SX3TMP->X3_CAMPO))
					::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS[01]:WsCjHeaders[_nCont]:Tipo				:= AllTrim(SX3TMP->X3_TIPO)
					::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS[01]:WsCjHeaders[_nCont]:ConsultF3		:= AllTrim(SX3TMP->X3_F3)
					::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS[01]:WsCjHeaders[_nCont]:Contexto			:= AllTrim(SX3TMP->X3_CONTEXT)
					::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS[01]:WsCjHeaders[_nCont]:ComboBox			:= AllTrim(SX3TMP->X3_CBOX)
					::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS[01]:WsCjHeaders[_nCont]:Inicializador	:= AllTrim(SX3TMP->X3_RELACAO)
					::WsRetorno:WsRetHeader[_nAls]:WsCjHAliasS[01]:WsCjHeaders[_nCont]:EdicaoWhen		:= AllTrim(SX3TMP->X3_WHEN)
					
					//Incluindo os campos para a Varável _aHeaderS
					aADD(_aHeaderS[Len(_aHeaderS), 02], {	AllTrim(X3Titulo())				,;
														AllTrim(SX3TMP->X3_CAMPO)			,;
														AllTrim(SX3TMP->X3_PICTURE)		,;
														SX3TMP->X3_TAMANHO					,;
														SX3TMP->X3_DECIMAL					,;
														AllTrim(SX3TMP->X3_VALID)			,;
														X3Uso(AllTrim(SX3TMP->X3_CAMPO))	,;
														AllTrim(SX3TMP->X3_TIPO)			,;
														AllTrim(SX3TMP->X3_F3)				,;
														AllTrim(SX3TMP->X3_CONTEXT)		,;
														AllTrim(SX3TMP->X3_CBOX)			,;
														AllTrim(SX3TMP->X3_RELACAO)		,;
														AllTrim(SX3TMP->X3_WHEN)			} )
					
					SX3TMP->(DbSkip())
				EndDo
			Else
				
				aADD( ::WsRetorno:WsMensagens, WSClassNew("StrMsgRet") )
				_nPMsg	:= Len( ::WsRetorno:WsMensagens )
				::WsRetorno:WsMensagens[_nPMsg]:WsCodMsg := -1
				::WsRetorno:WsMensagens[_nPMsg]:WsDScMsg := "Estrutura ( "+_aAlsPsq[_nAls]+" ) não encontrada no SX3."
				
			EndIF
		Next _nAls
		
	//Caso não seja solicitado o retorno do cabeçalho
	//O Else abaixo é utilizado para que o aCols de retorno
	//seja sempre igual ao dicionário de dados Protheus
	Else
		For _nAls := 1 To Len(_aAlsPsq)
			
			aADD(_aHeaderS, {_aAlsPsq[_nAls], { } } )
			
			OpenSxs(,,,,cEmpAnt,"SX3TMP","SX3",,.F.,.T.)
			SX3TMP->(DbSetOrder(1))
			SX3TMP->(DbGoTop())
			If SX3TMP->(DbSeek(_aAlsPsq[_nAls]))
				While SX3TMP->(!EOF()) .And. SX3TMP->X3_ARQUIVO == _aAlsPsq[_nAls]
					
					//Incluindo os campos para a Varável _aHeaderS
					aADD(_aHeaderS[Len(_aHeaderS), 02], {	AllTrim(X3Titulo())				,;
														AllTrim(SX3TMP->X3_CAMPO)			,;
														AllTrim(SX3TMP->X3_PICTURE)		,;
														SX3TMP->X3_TAMANHO					,;
														SX3TMP->X3_DECIMAL					,;
														AllTrim(SX3TMP->X3_VALID)			,;
														X3Uso(AllTrim(SX3TMP->X3_CAMPO))	,;
														AllTrim(SX3TMP->X3_TIPO)			,;
														AllTrim(SX3TMP->X3_F3)				,;
														AllTrim(SX3TMP->X3_CONTEXT)		,;
														AllTrim(SX3TMP->X3_CBOX)			,;
														AllTrim(SX3TMP->X3_RELACAO)		,;
														AllTrim(SX3TMP->X3_WHEN)			} )
					
					SX3TMP->(DbSkip())
				EndDo
			Else
				aADD( ::WsRetorno:WsMensagens, WSClassNew("StrMsgRet") )
				_nPMsg	:= Len( ::WsRetorno:WsMensagens )
				::WsRetorno:WsMensagens[_nPMsg]:WsCodMsg := -1
				::WsRetorno:WsMensagens[_nPMsg]:WsDScMsg := "Estrutura ( "+_aAlsPsq[_nAls]+" ) não encontrada no SX3."
			EndIf
			
		Next _nAls
	EndIF
	
	//WsData WsFilTit	AS String
	//WsData WsPrefTit	AS String
	//WsData WsNumTit	AS String
	//WsData WsParcTit	AS String
	//WsData WsTipoTit	AS String
	//
	_cPsqSE1 := ::WsTitulo:WsFilTit+::WsTitulo:WsPrefTit+::WsTitulo:WsNumTit+::WsTitulo:WsParcTit+::WsTitulo:WsTipoTit
	
	//Variável de Retorno dos aCols
	::WsRetorno:WsRetACols := {}
	
	DbSelectArea("SE1")
	SE1->(DbSetOrder(01))
	SE1->(DbGoTop())
	If SE1->(DbSeek(_cPsqSE1, .T.))
		
		aADD( ::WsRetorno:WsRetACols, WSClassNew("StrCjAColsS") )
		
		::WsRetorno:WsRetACols[01]:WsCjACols := {}
		
		aADD( ::WsRetorno:WsRetACols[01]:WsCjACols, WSClassNew("StrACols") )
		::WsRetorno:WsRetACols[01]:WsCjACols[01]:WsCAlias := "SE1"
		
		::WsRetorno:WsRetACols[01]:WsCjACols[01]:WsCjItens := {}
		
		_cCntSE1	:= 0
		_nPSE1		:= aScan(_aHeaderS, {|X| X[01] == "SE1"})
		_cChvSE1	:= xFilial("SE1")+_cPsqSE1
		
		While SE1->(!EOF()) .AND. SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO) == _cPsqSE1
			_cCntSE1++
			
			aADD( ::WsRetorno:WsRetACols[01]:WsCjACols[01]:WsCjItens, WSClassNew("StrItsACols") )
			
			RegToMemory("SE1", .F.)
			
			::WsRetorno:WsRetACols[01]:WsCjACols[01]:WsCjItens[_cCntSE1]:WsCjRegistros := {}
			
			For _nP := 1 To Len(_aHeaderS[_nPSE1, 02])
				aADD( ::WsRetorno:WsRetACols[01]:WsCjACols[01]:WsCjItens[_cCntSE1]:WsCjRegistros, WSClassNew("StrRegACols") )
				::WsRetorno:WsRetACols[01]:WsCjACols[01]:WsCjItens[_cCntSE1]:WsCjRegistros[_nP]:IdRegistro	:= SE1->(RECNO())
				::WsRetorno:WsRetACols[01]:WsCjACols[01]:WsCjItens[_cCntSE1]:WsCjRegistros[_nP]:CampoAcols	:= _aHeaderS[_nPSE1, 02, _nP, 02]
				
				//CONTEXTO - REAL ou VIRTUAL
				//Os IF Abaixo foram utilizados para verificar a situação de não-conformidade na execução da rotina
				//RegToMemory ao qual foi visto que faltava a variável INCLUIR.
				/*
				If _aHeaderS[_nPSE1, 02, _nP, 10] != "V"
					_xContud := &("M->"+_aHeaderS[_nPSE1, 02, _nP, 02]+" := SE1->"+_aHeaderS[_nPSE1, 02, _nP, 02])
				Else
					ConOut(_aHeaderS[_nPSE1, 02, _nP, 02])
					_xContud := &("M->"+_aHeaderS[_nPSE1, 02, _nP, 02]+" := CriaVar('"+_aHeaderS[_nPSE1, 02, _nP, 02]+"')")
				EndIf
				*/
				
				_xContud := &("M->"+_aHeaderS[_nPSE1, 02, _nP, 02])
				
				If "E1_USERLGI" == _aHeaderS[_nPSE1, 02, _nP, 02] .Or. "E1_USERLGA" == _aHeaderS[_nPSE1, 02, _nP, 02]
					_xContud := FwLeUserLG(_aHeaderS[_nPSE1, 02, _nP, 02])
				EndIF
				
				If ValType(_xContud) == "C"
					::WsRetorno:WsRetACols[01]:WsCjACols[01]:WsCjItens[_cCntSE1]:WsCjRegistros[_nP]:Conteudo	:= AllTrim(_xContud)
				ElseIf ValType(_xContud) == "N"
					::WsRetorno:WsRetACols[01]:WsCjACols[01]:WsCjItens[_cCntSE1]:WsCjRegistros[_nP]:Conteudo	:= AllTrim(Str(_xContud))
				ElseIf ValType(_xContud) == "D"
					::WsRetorno:WsRetACols[01]:WsCjACols[01]:WsCjItens[_cCntSE1]:WsCjRegistros[_nP]:Conteudo	:= DToS(_xContud)
				ElseIf ValType(_xContud) == "L"
					::WsRetorno:WsRetACols[01]:WsCjACols[01]:WsCjItens[_cCntSE1]:WsCjRegistros[_nP]:Conteudo	:= IIF(_xContud, ".T.", ".F.")
				EndIF
			Next _nP
			
			SE1->(DbSkip())
		EndDo
	Else
		aADD( ::WsRetorno:WsMensagens, WSClassNew("StrMsgRet") )
		_nPMsg	:= Len( ::WsRetorno:WsMensagens )
		::WsRetorno:WsMensagens[_nPMsg]:WsCodMsg := -2
		::WsRetorno:WsMensagens[_nPMsg]:WsDScMsg := "Filial+Prefixo+Numero+Parcela+Tipo ("+_cPsqSE1+") não encontrado. Tabela SE1 Cadastro de Títulos a Receber."
	EndIF
	
	If EMPTY(::WsRetorno:WsMensagens)
		aADD( ::WsRetorno:WsMensagens, WSClassNew("StrMsgRet") )
		_nPMsg	:= Len( ::WsRetorno:WsMensagens )
		::WsRetorno:WsMensagens[_nPMsg]:WsCodMsg := 0
		::WsRetorno:WsMensagens[_nPMsg]:WsDScMsg := "Consulta processada com sucesso."
	EndIF

//RESET ENVIRONMENT

Return .T.


/*/================================================================================================================================/*/
/*/{Protheus.doc} InfMvdatafin
Metodo da Classe WEBA01PA, responsável por retornar o conteúdo do parâmetro MV_DATAFIN.

@type 	 method
@author  IATAN
@since 	 18/11/2016
@version P12.1.23
@obs 	 Desenvolvimento FIEG
@return  Lógico, retorna verdadeiro.
@history 14/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 
/*/
/*/================================================================================================================================/*/

WsMethod InfMvdatafin WsReceive WsCEmp,WsCFil,WsLogin,WsSenha WsSend WsMvdatafin WsService WEBA01PA

Local ret

RPCSetType(3)
ret := SuperGetMV("MV_DATAFIN", .F., "", WsCFil)

::WsMvdatafin := DtoS(ret)

Return .T.


/*/================================================================================================================================/*/
/*/{Protheus.doc} GetCliente
Metodo da Classe WEBA01PA, responsável por retornar se um cliente existe ou não.

@type 	 method
@author  IATAN
@since 	 22/12/2016
@version P12.1.23
@obs 	 Desenvolvimento FIEG
@return  Lógico, retorna verdadeiro.
@history 14/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 
/*/
/*/================================================================================================================================/*/

WsMethod GetCliente WsReceive WsCEmp,WsCFil,WsLogin,WsSenha,WsCliente WsSend WsClienteOut WsService WEBA01PA

Local _lLogin	:= .T.
Local cgcCli 	:= ::WsCliente:WsCgcCli
Local _aArea	:= GetArea()
Local _aAreaSM0	:= SM0->(GetArea())
Local _cEmpBkp	:= cEmpAnt
Local _cFilBkp	:= cFilAnt
Local _cFilExe := WsCFil

Private INCLUI	:= .F.

RPCSetType(3)
//PREPARE ENVIRONMENT EMPRESA WsCEmp FILIAL WsCFil USER WsLogin PASSWORD WsSenha
OpenSm0(cEmpAnt, .T.)
SM0->(DbSetOrder(01))
SM0->(DbGoTop())
SM0->(DbSeek(WsCEmp+WsCFil))
cFilAnt := _cFilExe

PswOrder(02) //Nome do Usuário
//Posionando no Usuário
If PswSeek( WsLogin, .T. )
	//A Variável é alterada para o Login conforme o cadastrado no Protheus.
	//Pois para a função do Prepare Environment é necessário dessa forma.
	WsLogin := AllTrim(PswRet()[01,02])
Else
	_lLogin := .F.
EndIf

//Validando a senha após posiciona no Usuário.
If !PswName( WsSenha )
	_lLogin := .F.
EndIf

//Caso não tenha passado pela validação de usuário e senha do Protheus.
If !_lLogin
	
	If EMPTY(::WsRetorno:WsMensagens)
		aADD( ::WsRetorno:WsMensagens, WSClassNew("StrMsgRet") )
		_nPMsg	:= Len( ::WsRetorno:WsMensagens )
		::WsRetorno:WsMensagens[_nPMsg]:WsCodMsg := -5
		::WsRetorno:WsMensagens[_nPMsg]:WsDScMsg := "Usuário ou Senha Inválido."
	EndIF
	
	RETURN .T.
	
EndIF


//SetModulo("SIGAFIN","FIN")

	cgcCli := PadR(cgcCli,TamSX3("A1_CGC")[1], ' ')
	
	DbSelectArea("SA1")
	SA1->(DbSetOrder(3))
	SA1->(DbGoTop())
	If SA1->(DbSeek(xFilial("SA1")+cgcCli))
			::WsClienteOut:WsCodCli := SA1->A1_COD
			::WsClienteOut:WsLojCli := SA1->A1_LOJA
			::WsClienteOut:WsCgcCli := SA1->A1_CGC
			SA1->(DbSkip())
	Else 
			::WsClienteOut:WsCodCli := ''
			::WsClienteOut:WsLojCli := ''
			::WsClienteOut:WsCgcCli := ''
	EndIf
  
cEmpAnt := _cEmpBkp
cFilAnt := _cFilBkp

RestArea(_aAreaSM0)
RestArea(_aArea)
//RESET ENVIRONMENT

Return .T.


/*/================================================================================================================================/*/
/*/{Protheus.doc} GetTitulo
Metodo da Classe WEBA01PA, responsável por retornar se um título de receita existe ou não.

@type 	 method
@author  IATAN
@since 	 24/12/2016
@version P12.1.23
@obs 	 Desenvolvimento FIEG
@return  Lógico, retorna verdadeiro.
@history 14/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 
/*/
/*/================================================================================================================================/*/

WsMethod GetTitulo WsReceive WsCEmp,WsCFil,WsLogin,WsSenha,WsTitulo WsSend WsTituloErp WsService WEBA01PA

Local _lLogin	:= .T.
Local filial  := ::WsTitulo:WsFilTit
Local numero  := ::WsTitulo:WsNumTit
Local prefixo := ::WsTitulo:WsPrefTit
Local parcela := ::WsTitulo:WsParcTit
Local tipo    := ::WsTitulo:WsTipoTit

Local _aArea	:= GetArea()
Local _aAreaSM0	:= SM0->(GetArea())
Local _cEmpBkp	:= cEmpAnt
Local _cFilBkp	:= cFilAnt
Local _cFilExe := WsCFil
Private INCLUI	:= .F.

RPCSetType(3)
//PREPARE ENVIRONMENT EMPRESA WsCEmp FILIAL WsCFil USER WsLogin PASSWORD WsSenha
OpenSm0(cEmpAnt, .T.)
SM0->(DbSetOrder(01))
SM0->(DbGoTop())
SM0->(DbSeek(WsCEmp+WsCFil))
cFilAnt := _cFilExe

RPCSetType(3)
//PREPARE ENVIRONMENT EMPRESA WsCEmp FILIAL WsCFil USER WsLogin PASSWORD WsSenha

PswOrder(02) //Nome do Usuário
//Posionando no Usuário
If PswSeek( WsLogin, .T. )
	//A Variável é alterada para o Login conforme o cadastrado no Protheus.
	//Pois para a função do Prepare Environment é necessário dessa forma.
	WsLogin := AllTrim(PswRet()[01,02])
Else
	_lLogin := .F.
EndIf

//Validando a senha após posiciona no Usuário.
If !PswName( WsSenha )
	_lLogin := .F.
EndIf

//Caso não tenha passado pela validação de usuário e senha do Protheus.
If !_lLogin
	
	If EMPTY(::WsRetorno:WsMensagens)
		aADD( ::WsRetorno:WsMensagens, WSClassNew("StrMsgRet") )
		_nPMsg	:= Len( ::WsRetorno:WsMensagens )
		::WsRetorno:WsMensagens[_nPMsg]:WsCodMsg := -5
		::WsRetorno:WsMensagens[_nPMsg]:WsDScMsg := "Usuário ou Senha Inválido."
	EndIF
	
	RETURN .T.
	
EndIF


SetModulo("SIGAFIN","FIN")

	numero  := PadR(numero,TamSX3("E1_NUM")[1], ' ')
	prefixo := PadR(prefixo,TamSX3("E1_PREFIXO")[1], ' ')
	parcela := PadR(parcela,TamSX3("E1_PARCELA")[1], ' ')
	
	DbSelectArea("SE1")
	SE1->(DbSetOrder(1))
	SE1->(DbGoTop())
	If SE1->(DbSeek(filial+prefixo+numero+parcela+tipo))
			::WsTituloErp:WsFilTit := SE1->E1_FILIAL
			::WsTituloErp:WsNumTit := SE1->E1_NUM
			::WsTituloErp:WsPrefTit := SE1->E1_PREFIXO
			::WsTituloErp:WsParcTit := SE1->E1_PARCELA
			::WsTituloErp:WsTipoTit := SE1->E1_TIPO
			::WsTituloErp:WsValor   := STR(SE1->E1_VALOR)
			SE1->(DbSkip())
	Else 
			::WsTituloErp:WsFilTit  := ''
			::WsTituloErp:WsNumTit  := ''
			::WsTituloErp:WsPrefTit := ''
			::WsTituloErp:WsParcTit := ''
			::WsTituloErp:WsTipoTit := '' //ALTERAR ESTE CAMPO PARA SIMULAR UM ERRO "GROTESCO" E TESTAR MAIS TARDE.
	EndIf
	
cEmpAnt := _cEmpBkp
cFilAnt := _cFilBkp

RestArea(_aAreaSM0)
RestArea(_aArea)
	//RESET ENVIRONMENT

Return .T.


/*/================================================================================================================================/*/
/*/{Protheus.doc} GetTituloPAG
Metodo da Classe WEBA01PA, responsável por retornar se um título de receita existe ou não.

@type 	 method
@author  IATAN
@since 	 30/10/2017
@version P12.1.23
@obs 	 Desenvolvimento FIEG
@return  Lógico, retorna verdadeiro.
@history 14/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 
/*/
/*/================================================================================================================================/*/

WsMethod GetTituloPAG WsReceive WsCEmp,WsCFil,WsLogin,WsSenha,WsTitulo WsSend WsTituloErpPAG WsService WEBA01PA

Local _lLogin	:= .T.
Local filial  	:= ::WsTitulo:WsFilTit
Local numero  	:= ::WsTitulo:WsNumTit
Local prefixo 	:= ::WsTitulo:WsPrefTit
Local parcela 	:= ::WsTitulo:WsParcTit
Local tipo    	:= ::WsTitulo:WsTipoTit

Local _aArea	:= GetArea()
Local _aAreaSM0	:= SM0->(GetArea())
Local _cEmpBkp	:= cEmpAnt
Local _cFilBkp	:= cFilAnt
Local _cFilExe 	:= WsCFil
Private INCLUI	:= .F.

RPCSetType(3)
//PREPARE ENVIRONMENT EMPRESA WsCEmp FILIAL WsCFil USER WsLogin PASSWORD WsSenha
OpenSm0(cEmpAnt, .T.)
SM0->(DbSetOrder(01))
SM0->(DbGoTop())
SM0->(DbSeek(WsCEmp+WsCFil))
cFilAnt := _cFilExe

RPCSetType(3)
//PREPARE ENVIRONMENT EMPRESA WsCEmp FILIAL WsCFil USER WsLogin PASSWORD WsSenha

PswOrder(02) //Nome do Usuário
//Posionando no Usuário
If PswSeek( WsLogin, .T. )
	//A Variável é alterada para o Login conforme o cadastrado no Protheus.
	//Pois para a função do Prepare Environment é necessário dessa forma.
	WsLogin := AllTrim(PswRet()[01,02])
Else
	_lLogin := .F.
EndIf

//Validando a senha após posiciona no Usuário.
If !PswName( WsSenha )
	_lLogin := .F.
EndIf

//Caso não tenha passado pela validação de usuário e senha do Protheus.
If !_lLogin
	
	If EMPTY(::WsRetorno:WsMensagens)
		aADD( ::WsRetorno:WsMensagens, WSClassNew("StrMsgRet") )
		_nPMsg	:= Len( ::WsRetorno:WsMensagens )
		::WsRetorno:WsMensagens[_nPMsg]:WsCodMsg := -5
		::WsRetorno:WsMensagens[_nPMsg]:WsDScMsg := "Usuário ou Senha Inválido."
	EndIF
	
	RETURN .T.
	
EndIF

SetModulo("SIGAFIN","FIN")

	numero  := PadR(numero,TamSX3("E2_NUM")[1], ' ')
	prefixo := PadR(prefixo,TamSX3("E2_PREFIXO")[1], ' ')
	parcela := PadR(parcela,TamSX3("E2_PARCELA")[1], ' ')
	
	DbSelectArea("SE2")
	SE2->(DbSetOrder(1))
	SE2->(DbGoTop())
	If SE2->(DbSeek(filial+prefixo+numero+parcela+tipo))
			::WsTituloErpPAG:WsFilTit := SE2->E2_FILIAL
			::WsTituloErpPAG:WsNumTit := SE2->E2_NUM
			::WsTituloErpPAG:WsPrefTit := SE2->E2_PREFIXO
			::WsTituloErpPAG:WsParcTit := SE2->E2_PARCELA
			::WsTituloErpPAG:WsTipoTit := SE2->E2_TIPO
//			::WsTituloErp:WsValor   := SE1->E1_VALOR
			SE2->(DbSkip())
	Else 
			::WsTituloErpPAG:WsFilTit  := ''
			::WsTituloErpPAG:WsNumTit  := ''
			::WsTituloErpPAG:WsPrefTit := ''
			::WsTituloErpPAG:WsParcTit := ''
			::WsTituloErpPAG:WsTipoTit := '' //ALTERAR ESTE CAMPO PARA SIMULAR UM ERRO "GROTESCO" E TESTAR MAIS TARDE.
	EndIf
	
cEmpAnt := _cEmpBkp
cFilAnt := _cFilBkp

RestArea(_aAreaSM0)
RestArea(_aArea)
	//RESET ENVIRONMENT

Return .T.


/*/================================================================================================================================/*/
/*/{Protheus.doc} IncluirCliente
Metodo da Classe WEBA01PA, responsável por retornar as informações do Cliente.

@type 	 method
@author  IATAN
@since 	 22/12/2016
@version P12.1.23
@obs 	 Desenvolvimento FIEG
@return  Lógico, retorna verdadeiro.
@history 14/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 
/*/
/*/================================================================================================================================/*/

WsMethod IncluirCliente WsReceive WsCEmp,WsCFil,WsLogin,WsSenha,WsClienteInc WsSend WsRetornoS WsService WEBA01PA

Local _lLogin	:= .T.
Local aVetor
Private INCLUI	:= .T.
//Variável da Rotina Automática
Private lMsErroAuto	:= .F.

//RPCSetType(3)
//PREPARE ENVIRONMENT EMPRESA WsCEmp FILIAL WsCFil USER WsLogin PASSWORD WsSenha

PswOrder(02) //Nome do Usuário
//Posionando no Usuário
If PswSeek( WsLogin, .T. )
	//A Variável é alterada para o Login conforme o cadastrado no Protheus.
	//Pois para a função do Prepare Environment é necessário dessa forma.
	WsLogin := AllTrim(PswRet()[01,02])
Else
	_lLogin := .F.
EndIf

//Validando a senha após posiciona no Usuário.
If !PswName( WsSenha )
	_lLogin := .F.
EndIf

//Caso não tenha passado pela validação de usuário e senha do Protheus.
If !_lLogin
	
	If EMPTY(::WsRetorno:WsMensagens)
		aADD( ::WsRetorno:WsMensagens, WSClassNew("StrMsgRet") )
		_nPMsg	:= Len( ::WsRetorno:WsMensagens )
		::WsRetorno:WsMensagens[_nPMsg]:WsCodMsg := -5
		::WsRetorno:WsMensagens[_nPMsg]:WsDScMsg := "Usuário ou Senha Inválido."
	EndIF
	
	RETURN .T.
	
EndIF

SetModulo("SIGAFIN","FIN")

aVetor:={  {"A1_PESSOA"    ,::WsClienteInc:WsTipoPessoa ,Nil},; 
           {"A1_NOME"      ,::WsClienteInc:WsNome       ,Nil},; 
           {"A1_NREDUZ"    ,::WsClienteInc:WsNome       ,Nil},; 
           {"A1_END"       ,::WsClienteInc:WsEndereco   ,Nil},; 
           {"A1_TIPO"      ,"F"                         ,Nil},; 
           {"A1_EST"       ,::WsClienteInc:WsUf         ,Nil},; 
           {"A1_MUN"       ,::WsClienteInc:WsCidade     ,Nil},; 
           {"A1_BAIRRO"    ,::WsClienteInc:WsBairro     ,Nil},; 
           {"A1_CEP"       ,::WsClienteInc:WsCep        ,Nil},; 
           {"A1_COMPLEM"   ,::WsClienteInc:WsComplemento,Nil},; 
           {"A1_PAIS"      ,"105"                       ,Nil},; 
           {"A1_CGC"       ,::WsClienteInc:WsCgcCli     ,Nil},; 
           {"A1_ORIGEM"    ,"CR"                        ,Nil}} 

lMsErroAuto	:= .F.

	MSExecAuto({|x,y| Mata030(x,y)},aVetor,3) 

If lMsErroAuto
  	_erro := "Erro: " + MostraErro() 
  	::WsRetornoS := _erro
Endif

  //	RESET ENVIRONMENT

Return .T.


/*/================================================================================================================================/*/
/*/{Protheus.doc} AlterarCliente
Metodo da Classe WEBA01PA, responsável por retornar as informações do Cliente.

@type 	 method
@author  IATAN
@since 	 22/12/2016
@version P12.1.23
@obs 	 Desenvolvimento FIEG
@return  Lógico, retorna verdadeiro.
@history 14/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 
/*/
/*/================================================================================================================================/*/

WsMethod AlterarCliente WsReceive WsCEmp,WsCFil,WsLogin,WsSenha,WsClienteInc WsSend WsRetornoS WsService WEBA01PA

Local _lLogin	:= .T.
Local aVetor
Private INCLUI	:= .F.
//Variável da Rotina Automática
Private lMsErroAuto	:= .F.

RPCSetType(3)
//PREPARE ENVIRONMENT EMPRESA WsCEmp FILIAL WsCFil USER WsLogin PASSWORD WsSenha

PswOrder(02) //Nome do Usuário
//Posionando no Usuário
If PswSeek( WsLogin, .T. )
	//A Variável é alterada para o Login conforme o cadastrado no Protheus.
	//Pois para a função do Prepare Environment é necessário dessa forma.
	WsLogin := AllTrim(PswRet()[01,02])
Else
	_lLogin := .F.
EndIf

//Validando a senha após posiciona no Usuário.
If !PswName( WsSenha )
	_lLogin := .F.
EndIf

//Caso não tenha passado pela validação de usuário e senha do Protheus.
If !_lLogin
	
	If EMPTY(::WsRetorno:WsMensagens)
		aADD( ::WsRetorno:WsMensagens, WSClassNew("StrMsgRet") )
		_nPMsg	:= Len( ::WsRetorno:WsMensagens )
		::WsRetorno:WsMensagens[_nPMsg]:WsCodMsg := -5
		::WsRetorno:WsMensagens[_nPMsg]:WsDScMsg := "Usuário ou Senha Inválido."
	EndIF
	
	RETURN .T.
	
EndIF

SetModulo("SIGAFIN","FIN")

aVetor:={  {"A1_PESSOA"    , ::WsClienteInc:WsTipoPessoa,Nil},; 
           {"A1_COD"       ,::WsClienteInc:WsCodCli     ,Nil},; 
           {"A1_LOJA"      ,::WsClienteInc:WsLojCli     ,Nil},; 
           {"A1_NOME"      ,::WsClienteInc:WsNome       ,Nil},; 
           {"A1_NREDUZ"    ,::WsClienteInc:WsNome       ,Nil},; 
           {"A1_END"       ,::WsClienteInc:WsEndereco   ,Nil},; 
           {"A1_TIPO"      ,"F"                         ,Nil},; 
           {"A1_EST"       ,::WsClienteInc:WsUf         ,Nil},; 
           {"A1_MUN"       ,::WsClienteInc:WsCidade     ,Nil},; 
           {"A1_BAIRRO"    ,::WsClienteInc:WsBairro     ,Nil},; 
           {"A1_CEP"       ,::WsClienteInc:WsCep        ,Nil},; 
           {"A1_COMPLEM"   ,::WsClienteInc:WsComplemento,Nil},; 
           {"A1_PAIS"      ,"105"                       ,Nil},; 
           {"A1_CGC"       ,::WsClienteInc:WsCgcCli     ,Nil},; 
           {"A1_ORIGEM"    ,"CR"                        ,Nil}} 

lMsErroAuto	:= .F.

MSExecAuto({|x,y| Mata030(x,y)},aVetor,4) 

	If lMsErroAuto
    	_erro := "Erro: " + MostraErro() 
    	::WsRetornoS := _erro
	Endif

//RESET ENVIRONMENT

Return .T.


/*/================================================================================================================================/*/
/*/{Protheus.doc} IncluirTitulo
Metodo da Classe WEBA01PA, responsável por Inclusão de Título.

@type 	 method
@author  IATAN
@since 	 23/12/2016
@version P12.1.23
@obs 	 Desenvolvimento FIEG
@return  Lógico, retorna verdadeiro.
@history 14/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 
/*/
/*/================================================================================================================================/*/

WsMethod IncluirTitulo WsReceive WsCEmp,WsCFil,WsLogin,WsSenha,WsTituloErp WsSend WsRetornoS WsService WEBA01PA

Local _lLogin	:= .T.
Local aVetor
Local _vencimento
Local _valor
Local _emissao        
Local _erro := ""
/*Variaveis responsáveis por tratar as filiais de inserção dos registros*/
Local _aArea	:= GetArea()                                              
Local _aAreaSM0	:= SM0->(GetArea())
Local _cEmpBkp	:= cEmpAnt
Local _cFilBkp	:= cFilAnt
Local _cFilExe := WsCFil
Local dataAtual := ddatabase
/*FIM - Variaveis responsáveis por tratar as filiais de inserção dos registros*/

Private INCLUI	:= .T.                 
//Variável da Rotina Automática
Private lMsErroAuto	:= .F.

RPCSetType(3)
//PREPARE ENVIRONMENT EMPRESA WsCEmp FILIAL WsCFil USER WsLogin PASSWORD WsSenha
SetModulo("SIGAFIN","FIN")

OpenSm0(cEmpAnt, .T.)
SM0->(DbSetOrder(01))
SM0->(DbGoTop())
SM0->(DbSeek(WsCEmp+WsCFil))
cFilAnt := _cFilExe

PswOrder(02) //Nome do Usuário
//Posionando no Usuário
If PswSeek( WsLogin, .T. )
	//A Variável é alterada para o Login conforme o cadastrado no Protheus.
	//Pois para a função do Prepare Environment é necessário dessa forma.
	WsLogin := AllTrim(PswRet()[01,02])
Else
	_lLogin := .F.
EndIf

//Validando a senha após posiciona no Usuário.
If !PswName( WsSenha )
	_lLogin := .F.
EndIf

//Caso não tenha passado pela validação de usuário e senha do Protheus.
If !_lLogin
	
	If EMPTY(::WsRetorno:WsMensagens)
		aADD( ::WsRetorno:WsMensagens, WSClassNew("StrMsgRet") )
		_nPMsg	:= Len( ::WsRetorno:WsMensagens )
		::WsRetorno:WsMensagens[_nPMsg]:WsCodMsg := -5
		::WsRetorno:WsMensagens[_nPMsg]:WsDScMsg := "Usuário ou Senha Inválido."
	EndIF
	
	RETURN .T.
	
EndIF
 
 _vencimento := ::WsTituloErp:WsVencrea
 _valor      := ::WsTituloErp:WsValor
 _emissao    := ::WsTituloErp:WsEmissao

ddatabase := CTOD(::WsTituloErp:WsEmissao)

aVetor:={  {"E1_CREDIT"   ,PadR(::WsTituloErp:WsContaC,TamSX3("E1_CREDIT")[1], ' ')     ,Nil},; 
           {"E1_CCC"      ,PadR(::WsTituloErp:WsCc, TamSX3("E1_CCC")[1], ' ')     		,Nil},; 
           {"E1_CLIENTE"  ,::WsTituloErp:WsCodCli    ,Nil},; 
           {"E1_EMISSAO"  ,CTOD(::WsTituloErp:WsEmissao)   ,Nil},; 
           {"E1_FILIAL"   ,::WsTituloErp:WsFilTit    ,Nil},; 
           {"E1_HIST"     ,::WsTituloErp:WsHist      ,Nil},; 
           {"E1_XMANUAL"  ,::WsTituloErp:WsManual    ,Nil},; 
           {"E1_LOJA"     ,::WsTituloErp:WsLojCli    ,Nil},; 
           {"E1_NATUREZ"  ,PadR(::WsTituloErp:WsNatureza,TamSX3("E1_NATUREZ")[1], ' ')	,Nil},; 
           {"E1_NOMCLI"   ,::WsTituloErp:WsNomCli    ,Nil},; 
           {"E1_NUM"      ,PadR(::WsTituloErp:WsNumTit,TamSX3("E1_NUM")[1], ' ') 		,Nil},; 
           {"E1_XIDESB"   ,PadR(::WsTituloErp:WsNumTit,TamSX3("E1_XIDESB")[1], ' ')		,Nil},; 
           {"E1_PARCELA"  ,PadR(::WsTituloErp:WsParcTit,TamSX3("E1_PARCELA")[1], ' ')	,Nil},; 
           {"E1_PREFIXO"  ,PadR(::WsTituloErp:WsPrefTit,TamSX3("E1_PREFIXO")[1], ' ')	,Nil},; 
           {"E1_TIPO"     ,::WsTituloErp:WsTipoTit   ,Nil},; 
           {"E1_ITEMC"    ,PadR(::WsTituloErp:WsCentResp,TamSX3("E1_ITEMC")[1], ' ')	,Nil},; 
           {"E1_LA"       ,"S"   					 ,Nil},; 
           {"E1_VALOR"    ,Val(::WsTituloErp:WsValor)     								,Nil},; 
           {"E1_VENCREA"  ,CTOD(::WsTituloErp:WsVencrea)   								,Nil},; 
           {"E1_VENCTO"   ,CTOD(::WsTituloErp:WsVencto)    								,Nil}} 

lMsErroAuto	:= .F.

	MSExecAuto({|x,y| FINA040(x,y)},aVetor,3)      
	
	If lMsErroAuto
    	_erro := "Erro: " + MostraErro() 
    	::WsRetornoS := _erro
	Endif

cEmpAnt := _cEmpBkp
cFilAnt := _cFilBkp

RestArea(_aAreaSM0)
RestArea(_aArea)
ddatabase := dataAtual

//RESET ENVIRONMENT

Return .T.


/*/================================================================================================================================/*/
/*/{Protheus.doc} IncluirTituloSE
Metodo da Classe WEBA01PA, responsável por inclusão de título.

@type 	 method
@author  IATAN
@since 	 21/11/2017
@version P12.1.23
@obs 	 Desenvolvimento FIEG
@return  Lógico, retorna verdadeiro.
@history 14/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 
/*/
/*/================================================================================================================================/*/

WsMethod IncluirTituloSE WsReceive WsCEmp,WsCFil,WsLogin,WsSenha,WsTituloErp WsSend WsRetornoS WsService WEBA01PA

Local _lLogin	:= .T.
Local aVetor
Local _vencimento
Local _valor
Local _emissao        
Local _erro := ""       
Local R_E_C_N_O_ := ""
Local filial := ""                                                      
Local numero := ""
Local prefixo := ""
Local parcela := ""
/*Variaveis responsáveis por tratar as filiais de inserção dos registros*/
Local _aArea	:= GetArea()                                              
Local _aAreaSM0	:= SM0->(GetArea())
Local _cEmpBkp	:= cEmpAnt
Local _cFilBkp	:= cFilAnt
Local _cFilExe := WsCFil
Local dataAtual := ddatabase
/*FIM - Variaveis responsáveis por tratar as filiais de inserção dos registros*/

Private INCLUI	:= .T.                 
//Variável da Rotina Automática
Private lMsErroAuto	:= .F.

RPCSetType(3)
//PREPARE ENVIRONMENT EMPRESA WsCEmp FILIAL WsCFil USER WsLogin PASSWORD WsSenha
SetModulo("SIGAFIN","FIN")

OpenSm0(cEmpAnt, .T.)
SM0->(DbSetOrder(01))
SM0->(DbGoTop())
SM0->(DbSeek(WsCEmp+WsCFil))
cFilAnt := _cFilExe

PswOrder(02) //Nome do Usuário
//Posionando no Usuário
If PswSeek( WsLogin, .T. )
	//A Variável é alterada para o Login conforme o cadastrado no Protheus.
	//Pois para a função do Prepare Environment é necessário dessa forma.
	WsLogin := AllTrim(PswRet()[01,02])
Else
	_lLogin := .F.
EndIf

//Validando a senha após posiciona no Usuário.
If !PswName( WsSenha )
	_lLogin := .F.
EndIf

//Caso não tenha passado pela validação de usuário e senha do Protheus.
If !_lLogin
	
	If EMPTY(::WsRetorno:WsMensagens)
		aADD( ::WsRetorno:WsMensagens, WSClassNew("StrMsgRet") )
		_nPMsg	:= Len( ::WsRetorno:WsMensagens )
		::WsRetorno:WsMensagens[_nPMsg]:WsCodMsg := -5
		::WsRetorno:WsMensagens[_nPMsg]:WsDScMsg := "Usuário ou Senha Inválido."
	EndIF
	
	RETURN .T.
	
EndIF
 
 _vencimento := ::WsTituloErp:WsVencrea
 _valor      := ::WsTituloErp:WsValor
 _emissao    := ::WsTituloErp:WsEmissao

ddatabase := CTOD(::WsTituloErp:WsEmissao)

aVetor:={  {"E1_CREDIT"   ,PadR(::WsTituloErp:WsContaC,TamSX3("E1_CREDIT")[1], ' ')   ,Nil},; 
           {"E1_CCC"      ,PadR(::WsTituloErp:WsCc, TamSX3("E1_CCC")[1], ' ')     ,Nil},; 
           {"E1_CLIENTE"  ,::WsTituloErp:WsCodCli  ,Nil},; 
           {"E1_EMISSAO"  ,CTOD(::WsTituloErp:WsEmissao)   ,Nil},; 
           {"E1_FILIAL"   ,::WsTituloErp:WsFilTit    ,Nil},; 
           {"E1_HIST"     ,::WsTituloErp:WsHist      ,Nil},; 
           {"E1_XMANUAL"  ,::WsTituloErp:WsManual    ,Nil},; 
           {"E1_LOJA"     ,::WsTituloErp:WsLojCli    ,Nil},; 
           {"E1_NATUREZ"  ,PadR(::WsTituloErp:WsNatureza,TamSX3("E1_NATUREZ")[1], ' ') ,Nil},; 
           {"E1_NOMCLI"   ,::WsTituloErp:WsNomCli    ,Nil},; 
           {"E1_NUM"      ,PadR(::WsTituloErp:WsNumTit,TamSX3("E1_NUM")[1], ' ')       ,Nil},; 
           {"E1_XIDESB"   ,PadR(::WsTituloErp:WsNumTit,TamSX3("E1_XIDESB")[1], ' ')       ,Nil},; 
           {"E1_PARCELA"  ,PadR(::WsTituloErp:WsParcTit,TamSX3("E1_PARCELA")[1], ' ')  ,Nil},; 
           {"E1_PREFIXO"  ,PadR(::WsTituloErp:WsPrefTit,TamSX3("E1_PREFIXO")[1], ' ')   ,Nil},; 
           {"E1_TIPO"     ,::WsTituloErp:WsTipoTit   ,Nil},; 
           {"E1_ITEMC"    ,PadR(::WsTituloErp:WsCentResp,TamSX3("E1_ITEMC")[1], ' ')   ,Nil},; 
           {"E1_LA"       ,"S"   ,Nil},; 
           {"E1_VALOR"    ,Val(::WsTituloErp:WsValor)     ,Nil},; 
           {"E1_VENCREA"  ,CTOD(::WsTituloErp:WsVencrea)   ,Nil},; 
           {"E1_VENCTO"   ,CTOD(::WsTituloErp:WsVencto)    ,Nil}} 

lMsErroAuto	:= .F.

	MSExecAuto({|x,y| FINA040(x,y)},aVetor,3)      
	
	If lMsErroAuto
	
    	_erro := "Erro: " + MostraErro() 
    	::WsRetornoS := _erro
    	
   Else                                          
   
   filial  := ::WsTituloErp:WsFilTit
	numero  := PadR(::WsTituloErp:WsNumTit,TamSX3("E1_NUM")[1], ' ')
	prefixo := PadR(::WsTituloErp:WsPrefTit,TamSX3("E1_PREFIXO")[1], ' ')
	parcela := PadR(::WsTituloErp:WsParcTit,TamSX3("E1_PARCELA")[1], ' ')
	tipo    := ::WsTituloErp:WsTipoTit
	
	DbSelectArea("SE1")
	SE1->(DbSetOrder(1))
	SE1->(DbGoTop())
		If SE1->(DbSeek(filial+prefixo+numero+parcela+tipo))
				::WsRetornoS := STR(SE1->(RECNO()))
		Else 
				::WsRetornoS := ""
		EndIf
   
	Endif

cEmpAnt := _cEmpBkp
cFilAnt := _cFilBkp

RestArea(_aAreaSM0)
RestArea(_aArea)
ddatabase := dataAtual

//RESET ENVIRONMENT

Return .T.


/*/================================================================================================================================/*/
/*/{Protheus.doc} IncluirTituloPAG
Metodo da Classe WEBA01PA, responsável por INCLUIR UM TITULO DO TIPO "CONTAS A PAGAR"

@type 	 method
@author  IATAN
@since 	 30/10/2017
@version P12.1.23
@obs 	 Desenvolvimento FIEG
@return  Lógico, retorna verdadeiro.
@history 14/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 
/*/
/*/================================================================================================================================/*/

WsMethod IncluirTituloPAG WsReceive WsCEmp,WsCFil,WsLogin,WsSenha,WsTituloErpPag WsSend WsRetornoS WsService WEBA01PA

Local _lLogin	:= .T.
Local aVetor
Local _vencimento
Local _valor
Local _emissao        
Local _erro := ""
/*Variaveis responsáveis por tratar as filiais de inserção dos registros*/
Local _aArea	:= GetArea()                                              
Local _aAreaSM0	:= SM0->(GetArea())
Local _cEmpBkp	:= cEmpAnt
Local _cFilBkp	:= cFilAnt
Local _cFilExe := WsCFil
Local dataAtual := ddatabase
/*FIM - Variaveis responsáveis por tratar as filiais de inserção dos registros*/

Private INCLUI	:= .T.                 
//Variável da Rotina Automática
Private lMsErroAuto	:= .F.

RPCSetType(3)
//PREPARE ENVIRONMENT EMPRESA WsCEmp FILIAL WsCFil USER WsLogin PASSWORD WsSenha
SetModulo("SIGAFIN","FIN")

OpenSm0(cEmpAnt, .T.)
SM0->(DbSetOrder(01))
SM0->(DbGoTop())
SM0->(DbSeek(WsCEmp+WsCFil))
cFilAnt := _cFilExe

PswOrder(02) //Nome do Usuário
//Posionando no Usuário
If PswSeek( WsLogin, .T. )
	//A Variável é alterada para o Login conforme o cadastrado no Protheus.
	//Pois para a função do Prepare Environment é necessário dessa forma.
	WsLogin := AllTrim(PswRet()[01,02])
Else
	_lLogin := .F.
EndIf

//Validando a senha após posiciona no Usuário.
If !PswName( WsSenha )
	_lLogin := .F.
EndIf

//Caso não tenha passado pela validação de usuário e senha do Protheus.
If !_lLogin
	
	If EMPTY(::WsRetorno:WsMensagens)
		aADD( ::WsRetorno:WsMensagens, WSClassNew("StrMsgRet") )
		_nPMsg	:= Len( ::WsRetorno:WsMensagens )
		::WsRetorno:WsMensagens[_nPMsg]:WsCodMsg := -5
		::WsRetorno:WsMensagens[_nPMsg]:WsDScMsg := "Usuário ou Senha Inválido."
	EndIF
	
	RETURN .T.
	
EndIF

dbSelectArea("SE2")
SE2->(dbSetOrder(1))

ddatabase := CTOD(::WsTituloErpPag:WsEmissao)
                                                          
aVetor:={  {"E2_CONTAD"   ,PadR(::WsTituloErpPag:WsContaD,TamSX3("E2_CONTAD")[1], ' ')   ,Nil},; 
           {"E2_CCD"      ,PadR(::WsTituloErpPag:WsCcD,TamSX3("E2_CCD")[1], ' ')         ,Nil},; 
           {"E2_FORNECE"  ,PadR(::WsTituloErpPag:WsCodFor,TamSX3("E2_FORNECE")[1], ' ')  ,Nil},; 
           {"E2_LOJA"     ,PadR(::WsTituloErpPag:WsLojFor,TamSX3("E2_LOJA")[1], ' ')     ,Nil},; 
           {"E2_FILIAL"   ,WsTituloErpPag:WsFilTit                                       ,Nil},; 
           {"E2_HIST"     ,PadR(::WsTituloErpPag:WsHist,TamSX3("E2_HIST")[1], ' ')       ,Nil},; 
           {"E2_NATUREZ"  ,PadR(::WsTituloErpPag:WsNatureza,TamSX3("E2_NATUREZ")[1], ' '),Nil},; 
           {"E2_NOMFOR"   ,PadR(::WsTituloErpPag:WsNomFor,TamSX3("E2_NOMFOR")[1], ' ')   ,Nil},; 
           {"E2_NUM"      ,PadR(::WsTituloErpPag:WsNumTit,TamSX3("E2_NUM")[1], ' ')      ,Nil},; 
           {"E2_PARCELA"  ,PadR(::WsTituloErpPag:WsParcTit,TamSX3("E2_PARCELA")[1], ' ') ,Nil},; 
           {"E2_PREFIXO"  ,PadR(::WsTituloErpPag:WsPrefTit,TamSX3("E2_PREFIXO")[1], ' ') ,Nil},; 
           {"E2_TIPO"     ,PadR(::WsTituloErpPag:WsTipoTit,TamSX3("E2_TIPO")[1], ' ')    ,Nil},;          
           {"E2_EMISSAO"  ,CTOD(::WsTituloErpPag:WsEmissao)                              ,Nil},;          
           {"E2_DATALIB"  ,CTOD(::WsTituloErpPag:WsDataLib)                              ,Nil},;          
           {"E2_USUALIB"  ,PadR(::WsTituloErpPag:WsUsuaLib,TamSX3("E2_USUALIB")[1], ' ') ,Nil},;
           {"AUTBANCO"    ,PadR(::WsTituloErpPag:WsBanco,TamSX3("A6_COD")[1], ' ')       ,NIL},; 
           {"AUTAGENCIA"  ,PadR(::WsTituloErpPag:WsAgencia,TamSX3("A6_AGENCIA")[1], ' ') ,NIL},; 
           {"AUTCONTA"    ,PadR(::WsTituloErpPag:WsConta,TamSX3("A6_NUMCON")[1], ' ')    ,NIL},; 
           {"E2_STATLIB"  ,WsTituloErpPag:WsStatLib											     ,Nil},;                     
           {"E2_VENCTO"   ,CTOD(WsTituloErpPag:WsVencto)											  ,NIL},;
           {"E2_VALOR"    ,Val(WsTituloErpPag:WsValor)  											  ,Nil}}

lMsErroAuto	:= .F.

MSExecAuto({|x,y| FINA050(x,y)},aVetor,3)      
	
	If lMsErroAuto
    	_erro := "Erro: " + MostraErro() 
    	::WsRetornoS := _erro
	Endif


cEmpAnt := _cEmpBkp
cFilAnt := _cFilBkp

RestArea(_aAreaSM0)
RestArea(_aArea)
ddatabase := dataAtual
//RESET ENVIRONMENT

Return .T.


/*/================================================================================================================================/*/
/*/{Protheus.doc} IncluirTituloPAGSE
Metodo da Classe WEBA01PA, responsável por INCLUIR UM TITULO DO TIPO "CONTAS A PAGAR"

@type 	 method
@author  IATAN
@since 	 30/10/2017
@version P12.1.23
@obs 	 Desenvolvimento FIEG
@return  Lógico, retorna verdadeiro.
@history 14/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 
/*/
/*/================================================================================================================================/*/

WsMethod IncluirTituloPAGSE WsReceive WsCEmp,WsCFil,WsLogin,WsSenha,WsTituloErpPag WsSend WsRetornoS WsService WEBA01PA

Local _lLogin	:= .T.
Local aVetor
Local _vencimento
Local _valor
Local _emissao        
Local _erro := ""
Local filial  := ::WsTituloErpPag:WsFilTit
Local numero  := ::WsTituloErpPag:WsNumTit
Local prefixo := ::WsTituloErpPag:WsPrefTit
Local parcela := ::WsTituloErpPag:WsParcTit
Local tipo    := ::WsTituloErpPag:WsTipoTit
/*Variaveis responsáveis por tratar as filiais de inserção dos registros*/
Local _aArea	:= GetArea()                                              
Local _aAreaSM0	:= SM0->(GetArea())
Local _cEmpBkp	:= cEmpAnt
Local _cFilBkp	:= cFilAnt
Local _cFilExe := WsCFil
Local dataAtual := ddatabase
/*FIM - Variaveis responsáveis por tratar as filiais de inserção dos registros*/

Private INCLUI	:= .T.                 
//Variável da Rotina Automática
Private lMsErroAuto	:= .F.

RPCSetType(3)
//PREPARE ENVIRONMENT EMPRESA WsCEmp FILIAL WsCFil USER WsLogin PASSWORD WsSenha
SetModulo("SIGAFIN","FIN")

OpenSm0(cEmpAnt, .T.)
SM0->(DbSetOrder(01))
SM0->(DbGoTop())
SM0->(DbSeek(WsCEmp+WsCFil))
cFilAnt := _cFilExe

PswOrder(02) //Nome do Usuário
//Posionando no Usuário
If PswSeek( WsLogin, .T. )
	//A Variável é alterada para o Login conforme o cadastrado no Protheus.
	//Pois para a função do Prepare Environment é necessário dessa forma.
	WsLogin := AllTrim(PswRet()[01,02])
Else
	_lLogin := .F.
EndIf

//Validando a senha após posiciona no Usuário.
If !PswName( WsSenha )
	_lLogin := .F.
EndIf

//Caso não tenha passado pela validação de usuário e senha do Protheus.
If !_lLogin
	
	If EMPTY(::WsRetorno:WsMensagens)
		aADD( ::WsRetorno:WsMensagens, WSClassNew("StrMsgRet") )
		_nPMsg	:= Len( ::WsRetorno:WsMensagens )
		::WsRetorno:WsMensagens[_nPMsg]:WsCodMsg := -5
		::WsRetorno:WsMensagens[_nPMsg]:WsDScMsg := "Usuário ou Senha Inválido."
	EndIF
	
	RETURN .T.
	
EndIF

dbSelectArea("SE2")
SE2->(dbSetOrder(1))

ddatabase := CTOD(::WsTituloErpPag:WsEmissao)
                                                          
aVetor:={  {"E2_CONTAD"   ,PadR(::WsTituloErpPag:WsContaD,TamSX3("E2_CONTAD")[1], ' ')   ,Nil},; 
           {"E2_CCD"      ,PadR(::WsTituloErpPag:WsCcD,TamSX3("E2_CCD")[1], ' ')         ,Nil},; 
           {"E2_FORNECE"  ,PadR(::WsTituloErpPag:WsCodFor,TamSX3("E2_FORNECE")[1], ' ')  ,Nil},; 
           {"E2_LOJA"     ,PadR(::WsTituloErpPag:WsLojFor,TamSX3("E2_LOJA")[1], ' ')     ,Nil},; 
           {"E2_FILIAL"   ,WsTituloErpPag:WsFilTit                                       ,Nil},; 
           {"E2_HIST"     ,PadR(::WsTituloErpPag:WsHist,TamSX3("E2_HIST")[1], ' ')       ,Nil},; 
           {"E2_NATUREZ"  ,PadR(::WsTituloErpPag:WsNatureza,TamSX3("E2_NATUREZ")[1], ' '),Nil},; 
           {"E2_NOMFOR"   ,PadR(::WsTituloErpPag:WsNomFor,TamSX3("E2_NOMFOR")[1], ' ')   ,Nil},; 
           {"E2_NUM"      ,PadR(::WsTituloErpPag:WsNumTit,TamSX3("E2_NUM")[1], ' ')      ,Nil},; 
           {"E2_PARCELA"  ,PadR(::WsTituloErpPag:WsParcTit,TamSX3("E2_PARCELA")[1], ' ') ,Nil},; 
           {"E2_PREFIXO"  ,PadR(::WsTituloErpPag:WsPrefTit,TamSX3("E2_PREFIXO")[1], ' ') ,Nil},; 
           {"E2_TIPO"     ,PadR(::WsTituloErpPag:WsTipoTit,TamSX3("E2_TIPO")[1], ' ')    ,Nil},;          
           {"E2_EMISSAO"  ,CTOD(::WsTituloErpPag:WsEmissao)                              ,Nil},;          
           {"E2_DATALIB"  ,CTOD(::WsTituloErpPag:WsDataLib)                              ,Nil},;          
           {"E2_USUALIB"  ,PadR(::WsTituloErpPag:WsUsuaLib,TamSX3("E2_USUALIB")[1], ' ') ,Nil},;
           {"AUTBANCO"    ,PadR(::WsTituloErpPag:WsBanco,TamSX3("A6_COD")[1], ' ')       ,NIL},; 
           {"AUTAGENCIA"  ,PadR(::WsTituloErpPag:WsAgencia,TamSX3("A6_AGENCIA")[1], ' ') ,NIL},; 
           {"AUTCONTA"    ,PadR(::WsTituloErpPag:WsConta,TamSX3("A6_NUMCON")[1], ' ')    ,NIL},; 
           {"E2_STATLIB"  ,WsTituloErpPag:WsStatLib											     ,Nil},;                     
           {"E2_VENCTO"   ,CTOD(WsTituloErpPag:WsVencto)											  ,NIL},;
           {"E2_VALOR"    ,Val(WsTituloErpPag:WsValor)  											  ,Nil}}

lMsErroAuto	:= .F.

MSExecAuto({|x,y| FINA050(x,y)},aVetor,3)      
	
	If lMsErroAuto

    	_erro := "Erro: " + MostraErro() 
    	::WsRetornoS := _erro
    	
	Else
		
		numero  := PadR(numero,TamSX3("E2_NUM")[1], ' ')
		prefixo := PadR(prefixo,TamSX3("E2_PREFIXO")[1], ' ')
		parcela := PadR(parcela,TamSX3("E2_PARCELA")[1], ' ')
		
		DbSelectArea("SE2")
		SE2->(DbSetOrder(1))
		SE2->(DbGoTop())
		If SE2->(DbSeek(filial+prefixo+numero+parcela+tipo))
				::WsRetornoS := STR( SE2->(RECNO()) )
		Else 
				::WsRetornoS  := ''
		EndIf

	Endif


cEmpAnt := _cEmpBkp
cFilAnt := _cFilBkp

RestArea(_aAreaSM0)
RestArea(_aArea)
ddatabase := dataAtual
//RESET ENVIRONMENT

Return .T.


/*/================================================================================================================================/*/
/*/{Protheus.doc} AlterarTitulo
Metodo da Classe WEBA01PA, responsável por ALTERAR UM TITULO

@type 	 method
@author  IATAN
@since 	 01/01/2017
@version P12.1.23
@obs 	 Desenvolvimento FIEG
@return  Lógico, retorna verdadeiro.
@history 14/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 
/*/
/*/================================================================================================================================/*/

WsMethod AlterarTitulo WsReceive WsCEmp,WsCFil,WsLogin,WsSenha,WsTituloErp WsSend WsRetornoS WsService WEBA01PA

Local _lLogin	:= .T.
Local aVetor
Local _vencimento
Local _valor
Local _emissao        
Local _erro := ""
/*Variaveis responsáveis por tratar as filiais de inserção dos registros*/
Local _aArea	:= GetArea()                                              
Local _aAreaSM0	:= SM0->(GetArea())
Local _cEmpBkp	:= cEmpAnt
Local _cFilBkp	:= cFilAnt
Local _cFilExe := WsCFil
/*FIM - Variaveis responsáveis por tratar as filiais de inserção dos registros*/

Private INCLUI	:= .T.                 
//Variável da Rotina Automática
Private lMsErroAuto	:= .F.

RPCSetType(3)
//PREPARE ENVIRONMENT EMPRESA WsCEmp FILIAL WsCFil USER WsLogin PASSWORD WsSenha
SetModulo("SIGAFIN","FIN")

OpenSm0(cEmpAnt, .T.)
SM0->(DbSetOrder(01))
SM0->(DbGoTop())
SM0->(DbSeek(WsCEmp+WsCFil))
cFilAnt := _cFilExe

PswOrder(02) //Nome do Usuário
//Posionando no Usuário
If PswSeek( WsLogin, .T. )
	//A Variável é alterada para o Login conforme o cadastrado no Protheus.
	//Pois para a função do Prepare Environment é necessário dessa forma.
	WsLogin := AllTrim(PswRet()[01,02])
Else
	_lLogin := .F.
EndIf

//Validando a senha após posiciona no Usuário.
If !PswName( WsSenha )
	_lLogin := .F.
EndIf

//Caso não tenha passado pela validação de usuário e senha do Protheus.
If !_lLogin
	
	If EMPTY(::WsRetorno:WsMensagens)
		aADD( ::WsRetorno:WsMensagens, WSClassNew("StrMsgRet") )
		_nPMsg	:= Len( ::WsRetorno:WsMensagens )
		::WsRetorno:WsMensagens[_nPMsg]:WsCodMsg := -5
		::WsRetorno:WsMensagens[_nPMsg]:WsDScMsg := "Usuário ou Senha Inválido."
	EndIF
	
	RETURN .T.
	
EndIF
 
 _vencimento := ::WsTituloErp:WsVencrea
 _valor      := ::WsTituloErp:WsValor
 _emissao    := ::WsTituloErp:WsEmissao

aVetor:={  {"E1_CREDIT"   ,PadR(::WsTituloErp:WsContaC,TamSX3("E1_CREDIT")[1], ' ')   ,Nil},; 
           {"E1_CCC"      ,PadR(::WsTituloErp:WsCc, TamSX3("E1_CCC")[1], ' ')     ,Nil},; 
           {"E1_CLIENTE"  ,::WsTituloErp:WsCodCli  ,Nil},; 
           {"E1_EMISSAO"  ,CTOD(::WsTituloErp:WsEmissao)   ,Nil},; 
           {"E1_FILIAL"   ,::WsTituloErp:WsFilTit    ,Nil},; 
           {"E1_HIST"     ,::WsTituloErp:WsHist      ,Nil},; 
           {"E1_XMANUAL"  ,::WsTituloErp:WsManual    ,Nil},; 
           {"E1_LOJA"     ,::WsTituloErp:WsLojCli    ,Nil},; 
           {"E1_NATUREZ"  ,PadR(::WsTituloErp:WsNatureza,TamSX3("E1_NATUREZ")[1], ' ') ,Nil},; 
           {"E1_NOMCLI"   ,::WsTituloErp:WsNomCli    ,Nil},; 
           {"E1_NUM"      ,PadR(::WsTituloErp:WsNumTit,TamSX3("E1_NUM")[1], ' ')       ,Nil},; 
           {"E1_XIDESB"   ,PadR(::WsTituloErp:WsNumTit,TamSX3("E1_XIDESB")[1], ' ')       ,Nil},; 
           {"E1_PARCELA"  ,PadR(::WsTituloErp:WsParcTit,TamSX3("E1_PARCELA")[1], ' ')  ,Nil},; 
           {"E1_PREFIXO"  ,PadR(::WsTituloErp:WsPrefTit,TamSX3("E1_PREFIXO")[1], ' ')   ,Nil},; 
           {"E1_TIPO"     ,::WsTituloErp:WsTipoTit   ,Nil},; 
           {"E1_LA"       ,"S"   ,Nil},; 
           {"E1_ITEMC"    ,PadR(::WsTituloErp:WsCentResp,TamSX3("E1_ITEMC")[1], ' ')   ,Nil},; 
           {"E1_VALOR"    ,Val(::WsTituloErp:WsValor)     ,Nil},; 
           {"E1_VENCREA"  ,CTOD(::WsTituloErp:WsVencrea)   ,Nil},; 
           {"E1_VENCTO"   ,CTOD(::WsTituloErp:WsVencto)    ,Nil}} 

lMsErroAuto	:= .F.

	MSExecAuto({|x,y| FINA040(x,y)},aVetor, 4)      

	
	If lMsErroAuto
    	_erro := "Erro: " + MostraErro() 
    	::WsRetornoS := _erro
	Endif

cEmpAnt := _cEmpBkp
cFilAnt := _cFilBkp

RestArea(_aAreaSM0)
RestArea(_aArea)

//RESET ENVIRONMENT

Return .T.


/*/================================================================================================================================/*/
/*/{Protheus.doc} ExcluirTitulo
Metodo da Classe WEBA01PA, responsável por EXCLUIR UM TITULO

@type 	 method
@author  IATAN
@since 	 14/01/2017
@version P12.1.23
@obs 	 Desenvolvimento FIEG
@return  Lógico, retorna verdadeiro.
@history 14/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 
/*/
/*/================================================================================================================================/*/

WsMethod ExcluirTitulo WsReceive WsCEmp,WsCFil,WsLogin,WsSenha,WsTituloErp WsSend WsRetornoS WsService WEBA01PA

Local _lLogin	:= .T.
Local aVetor
Local _vencimento
Local _valor
Local _emissao        
Local _erro := ""

Local filial  := ::WsTituloErp:WsFilTit
Local numero  := ::WsTituloErp:WsNumTit
Local prefixo := ::WsTituloErp:WsPrefTit
Local parcela := ::WsTituloErp:WsParcTit
Local tipo    := ::WsTituloErp:WsTipoTit

/*Variaveis responsáveis por tratar as filiais de inserção dos registros*/
Local _aArea	:= GetArea()                                              
Local _aAreaSM0	:= SM0->(GetArea())
Local _cEmpBkp	:= cEmpAnt
Local _cFilBkp	:= cFilAnt
Local _cFilExe := WsCFil
/*FIM - Variaveis responsáveis por tratar as filiais de inserção dos registros*/

Private INCLUI	:= .T.                 
//Variável da Rotina Automática
Private lMsErroAuto	:= .F.

RPCSetType(3)
//PREPARE ENVIRONMENT EMPRESA WsCEmp FILIAL WsCFil USER WsLogin PASSWORD WsSenha
SetModulo("SIGAFIN","FIN")

OpenSm0(cEmpAnt, .T.)
SM0->(DbSetOrder(01))
SM0->(DbGoTop())
SM0->(DbSeek(WsCEmp+WsCFil))
cFilAnt := _cFilExe

PswOrder(02) //Nome do Usuário
//Posionando no Usuário
If PswSeek( WsLogin, .T. )
	//A Variável é alterada para o Login conforme o cadastrado no Protheus.
	//Pois para a função do Prepare Environment é necessário dessa forma.
	WsLogin := AllTrim(PswRet()[01,02])
Else
	_lLogin := .F.
EndIf

//Validando a senha após posiciona no Usuário.
If !PswName( WsSenha )
	_lLogin := .F.
EndIf

//Caso não tenha passado pela validação de usuário e senha do Protheus.
If !_lLogin
	
	If EMPTY(::WsRetorno:WsMensagens)
		aADD( ::WsRetorno:WsMensagens, WSClassNew("StrMsgRet") )
		_nPMsg	:= Len( ::WsRetorno:WsMensagens )
		::WsRetorno:WsMensagens[_nPMsg]:WsCodMsg := -5
		::WsRetorno:WsMensagens[_nPMsg]:WsDScMsg := "Usuário ou Senha Inválido."
	EndIF
	
	RETURN .T.
	
EndIF

	numero  := PadR(numero,TamSX3("E1_NUM")[1], ' ')
	prefixo := PadR(prefixo,TamSX3("E1_PREFIXO")[1], ' ')
	parcela := PadR(parcela,TamSX3("E1_PARCELA")[1], ' ')
	
	DbSelectArea("SE1")
	SE1->(DbSetOrder(1))
	SE1->(DbGoTop())
	SE1->(DbSeek(filial+prefixo+numero+parcela+tipo))

 
 _vencimento := ::WsTituloErp:WsVencrea
 _valor      := ::WsTituloErp:WsValor
 _emissao    := ::WsTituloErp:WsEmissao

aVetor:={  {"E1_CREDIT"   ,PadR(::WsTituloErp:WsContaC,TamSX3("E1_CREDIT")[1], ' ')   ,Nil},; 
           {"E1_CCC"      ,PadR(::WsTituloErp:WsCc, TamSX3("E1_CCC")[1], ' ')     ,Nil},; 
           {"E1_CLIENTE"  ,::WsTituloErp:WsCodCli  ,Nil},; 
           {"E1_EMISSAO"  ,CTOD(::WsTituloErp:WsEmissao)   ,Nil},; 
           {"E1_FILIAL"   ,::WsTituloErp:WsFilTit    ,Nil},; 
           {"E1_HIST"     ,::WsTituloErp:WsHist      ,Nil},; 
           {"E1_XMANUAL"  ,::WsTituloErp:WsManual    ,Nil},; 
           {"E1_LOJA"     ,::WsTituloErp:WsLojCli    ,Nil},; 
           {"E1_NATUREZ"  ,PadR(::WsTituloErp:WsNatureza,TamSX3("E1_NATUREZ")[1], ' ') ,Nil},; 
           {"E1_NOMCLI"   ,::WsTituloErp:WsNomCli    ,Nil},; 
           {"E1_NUM"      ,PadR(::WsTituloErp:WsNumTit,TamSX3("E1_NUM")[1], ' ')       ,Nil},; 
           {"E1_XIDESB"   ,PadR(::WsTituloErp:WsNumTit,TamSX3("E1_XIDESB")[1], ' ')       ,Nil},; 
           {"E1_PARCELA"  ,PadR(::WsTituloErp:WsParcTit,TamSX3("E1_PARCELA")[1], ' ')  ,Nil},; 
           {"E1_PREFIXO"  ,PadR(::WsTituloErp:WsPrefTit,TamSX3("E1_PREFIXO")[1], ' ')   ,Nil},; 
           {"E1_TIPO"     ,::WsTituloErp:WsTipoTit   ,Nil},; 
           {"E1_LA"       ,"S"   ,Nil},; 
           {"E1_ITEMC"    ,PadR(::WsTituloErp:WsCentResp,TamSX3("E1_ITEMC")[1], ' ')   ,Nil},; 
           {"E1_VALOR"    ,Val(::WsTituloErp:WsValor)     ,Nil},; 
           {"E1_VENCREA"  ,CTOD(::WsTituloErp:WsVencrea)   ,Nil},; 
           {"E1_VENCTO"   ,CTOD(::WsTituloErp:WsVencto)    ,Nil}} 

lMsErroAuto	:= .F.

  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão
	MSExecAuto({|x,y| FINA040(x,y)},aVetor, 5)      

	
	If lMsErroAuto
    	_erro := "Erro: " + MostraErro() 
    	::WsRetornoS := _erro
	Endif

cEmpAnt := _cEmpBkp
cFilAnt := _cFilBkp

RestArea(_aAreaSM0)
RestArea(_aArea)
SE1->(DBSKIP())
//RESET ENVIRONMENT

Return .T.


/*/================================================================================================================================/*/
/*/{Protheus.doc} BaixarTitulo
Metodo da Classe WEBA01PA, responsável por BAIXAR UM TITULO

@type 	 method
@author  IATAN
@since 	 24/12/2016
@version P12.1.23
@obs 	 Desenvolvimento FIEG
@return  Lógico, retorna verdadeiro.
@history 14/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 
/*/
/*/================================================================================================================================/*/

WsMethod BaixarTitulo WsReceive WsCEmp,WsCFil,WsLogin,WsSenha,WsTituloErp WsSend WsRetornoS WsService WEBA01PA

Local _lLogin	:= .T.

Local cBanco := ""
Local cAgencia := ""
Local cConta := ""
/*Variaveis responsáveis por tratar as filiais de inserção dos registros*/
Local _aArea	:= GetArea()                                              
Local _aAreaSM0	:= SM0->(GetArea())
Local _cEmpBkp	:= cEmpAnt
Local _cFilBkp	:= cFilAnt
Local _cFilExe := WsCFil
Local dataAtual := ddatabase
Local dataLimite := SuperGetMV("MV_DATAFIN", .F., "", WsCFil)
/*FIM - Variaveis responsáveis por tratar as filiais de inserção dos registros*/
Private INCLUI	:= .F.                 
Private aVetor := {}
//Variável da Rotina Automática
Private lMsErroAuto	:= .F.

RPCSetType(3)                       
//COMANDO ABAIXO SENDO EXECUTADO POIS OS MOVIMENTOS ESTAVAM GERANDO CONTABILIZAÇÃO SEM ESTE COMANDO
PREPARE ENVIRONMENT EMPRESA WsCEmp FILIAL WsCFil USER WsLogin PASSWORD WsSenha

OpenSm0(cEmpAnt, .T.)
SM0->(DbSetOrder(01))
SM0->(DbGoTop())
SM0->(DbSeek(WsCEmp+WsCFil))
cFilAnt := _cFilExe

PswOrder(02) //Nome do Usuário
//Posionando no Usuário
If PswSeek( WsLogin, .T. )
	//A Variável é alterada para o Login conforme o cadastrado no Protheus.
	//Pois para a função do Prepare Environment é necessário dessa forma.
	WsLogin := AllTrim(PswRet()[01,02])
Else
	_lLogin := .F.
EndIf

//Validando a senha após posiciona no Usuário.
If !PswName( WsSenha )
	_lLogin := .F.
EndIf

//Caso não tenha passado pela validação de usuário e senha do Protheus.
If !_lLogin
	
	If EMPTY(::WsRetorno:WsMensagens)
		aADD( ::WsRetorno:WsMensagens, WSClassNew("StrMsgRet") )
		_nPMsg	:= Len( ::WsRetorno:WsMensagens )
		::WsRetorno:WsMensagens[_nPMsg]:WsCodMsg := -5
		::WsRetorno:WsMensagens[_nPMsg]:WsDScMsg := "Usuário ou Senha Inválido."
	EndIF
	
	RETURN .T.
	
EndIF

cBanco := PadR(::WsTituloErp:WsBanco,TamSX3("A6_COD")[1], ' ')
cAgencia := PadR(::WsTituloErp:WsAgencia,TamSX3("A6_AGENCIA")[1], ' ')
cConta := PadR(::WsTituloErp:WsConta,TamSX3("A6_NUMCON")[1], ' ')

ddatabase := CTOD(::WsTituloErp:WsDtBx)


If ddatabase < dataLimite
	
	::WsRetornoS := "NÃO SÃO PERMITIDAS MOVIMENTAÇÕES COM DATAS ANTERIORES AO FECHAMENTO MV_DATAFIN - " + DTOC(dataLimite)

	cEmpAnt := _cEmpBkp
	cFilAnt := _cFilBkp

	RestArea(_aAreaSM0)
	RestArea(_aArea)                      
	ddatabase := dataAtual
		
	RETURN .T.
	
EndIF

aVetor:={  {"E1_PREFIXO"   ,PadR(::WsTituloErp:WsPrefTit ,TamSX3("E1_PREFIXO")[1], ' ') ,Nil},; 
           {"E1_NUM"       ,PadR(::WsTituloErp:WsNumTit  ,TamSX3("E1_NUM")[1], ' ')     ,Nil},; 
           {"E1_FILIAL"    ,WsTituloErp:WsFilTit ,Nil},; 
           {"E1_PARCELA"   ,PadR(::WsTituloErp:WsParcTit ,TamSX3("E1_PARCELA")[1], ' ')    ,Nil},; 
           {"E1_CLIENTE"   ,::WsTituloErp:WsCodCli    ,Nil},; 
           {"E1_LOJA"      ,::WsTituloErp:WsLojCli    ,Nil},; 
           {"E1_TIPO"      ,::WsTituloErp:WsTipoTit   ,Nil},; 
           {"AUTMOTBX"     ,::WsTituloErp:WsMotBx     ,Nil},; 
           {"E1_LA"       ,"S"   ,Nil},; 
           {"AUTBANCO"     ,cBanco  ,Nil},; 
           {"AUTAGENCIA"   ,cAgencia    ,Nil},; 
           {"AUTCONTA"     ,cConta       ,Nil},; 
           {"AUTDTBAIXA"   ,CTOD(::WsTituloErp:WsDtBx)     ,Nil},; 
           {"AUTDTCREDITO" ,CTOD(::WsTituloErp:WsDtCred)   ,Nil},; 
           {"AUTHIST"      ,::WsTituloErp:WsHist     ,Nil},; 
           {"AUTJUROS"     ,VAL(::WsTituloErp:WsJuros)    ,Nil},; 
           {"AUTDESCONT"   ,VAL(::WsTituloErp:WsDesconto) ,Nil},; 
           {"AUTVALREC"    ,VAL(::WsTituloErp:WsValRec)   ,Nil}} 

lMsErroAuto	:= .F.

	/*Conteúdos do nOpc: 3 - Baixa de Título, 5 - Cancelamento de baixa, 6 - Exclusão de Baixa.*/
	MsExecAuto( {|X, Y| FINA070(X, Y)}, aVetor, 3 )
           
	If lMsErroAuto
    	_erro := "Erro: " + MostraErro() 
    	Conout(_erro)
    	::WsRetornoS := _erro
	Endif

cEmpAnt := _cEmpBkp
cFilAnt := _cFilBkp

RestArea(_aAreaSM0)
RestArea(_aArea)                      
ddatabase := dataAtual
//RESET ENVIRONMENT

Return .T.


/*/================================================================================================================================/*/
/*/{Protheus.doc} ExcluirBaixaTitulo
Metodo da Classe WEBA01PA, responsável por EXCLUIR A BAIXA DE UM TITULO

@type 	 method
@author  IATAN
@since 	 24/12/2016
@version P12.1.23
@obs 	 Desenvolvimento FIEG
@return  Lógico, retorna verdadeiro.
@history 14/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 
/*/
/*/================================================================================================================================/*/

WsMethod ExcluirBaixaTitulo WsReceive WsCEmp,WsCFil,WsLogin,WsSenha,WsTituloErp WsSend WsRetornoS WsService WEBA01PA

Local _lLogin	:= .T.

Local cBanco := ""
Local cAgencia := ""
Local cConta := ""
/*Variaveis responsáveis por tratar as filiais de inserção dos registros*/
Local _aArea	:= GetArea()                                              
Local _aAreaSM0	:= SM0->(GetArea())
Local _cEmpBkp	:= cEmpAnt
Local _cFilBkp	:= cFilAnt
Local _cFilExe := WsCFil
Local dataAtual := ddatabase
Local documen := ''
/*FIM - Variaveis responsáveis por tratar as filiais de inserção dos registros*/
Private INCLUI	:= .F.                 
Private aVetor := {}
//Variável da Rotina Automática
Private lMsErroAuto	:= .F.

RPCSetType(3)
//COMANDO ABAIXO SENDO EXECUTADO POIS OS MOVIMENTOS ESTAVAM GERANDO CONTABILIZAÇÃO SEM ESTE COMANDO
PREPARE ENVIRONMENT EMPRESA WsCEmp FILIAL WsCFil USER WsLogin PASSWORD WsSenha

OpenSm0(cEmpAnt, .T.)
SM0->(DbSetOrder(01))
SM0->(DbGoTop())
SM0->(DbSeek(WsCEmp+WsCFil))
cFilAnt := _cFilExe

PswOrder(02) //Nome do Usuário
//Posionando no Usuário
If PswSeek( WsLogin, .T. )
	//A Variável é alterada para o Login conforme o cadastrado no Protheus.
	//Pois para a função do Prepare Environment é necessário dessa forma.
	WsLogin := AllTrim(PswRet()[01,02])
Else
	_lLogin := .F.
EndIf

//Validando a senha após posiciona no Usuário.
If !PswName( WsSenha )
	_lLogin := .F.
EndIf

//Caso não tenha passado pela validação de usuário e senha do Protheus.
If !_lLogin
	
	If EMPTY(::WsRetorno:WsMensagens)
		aADD( ::WsRetorno:WsMensagens, WSClassNew("StrMsgRet") )
		_nPMsg	:= Len( ::WsRetorno:WsMensagens )
		::WsRetorno:WsMensagens[_nPMsg]:WsCodMsg := -5
		::WsRetorno:WsMensagens[_nPMsg]:WsDScMsg := "Usuário ou Senha Inválido."
	EndIF
	
	RETURN .T.
	
EndIF

cBanco := PadR(::WsTituloErp:WsBanco,TamSX3("A6_COD")[1], ' ')
cAgencia := PadR(::WsTituloErp:WsAgencia,TamSX3("A6_AGENCIA")[1], ' ')
cConta := PadR(::WsTituloErp:WsConta,TamSX3("A6_NUMCON")[1], ' ')

ddatabase := CTOD(::WsTituloErp:WsDtBx)

dbSelectArea("SE1")
SE1->(dbSetOrder(1))
documen := WsTituloErp:WsFilTit
documen := documen + PadR(::WsTituloErp:WsPrefTit ,TamSX3("E1_PREFIXO")[1], ' ')
documen := documen + PadR(::WsTituloErp:WsNumTit  ,TamSX3("E1_NUM")[1], ' ')
documen := documen + PadR(::WsTituloErp:WsParcTit ,TamSX3("E1_PARCELA")[1], ' ')
documen := documen + ::WsTituloErp:WsTipoTit
SE1->(dbSeek(documen))

aVetor:={  {"E1_PREFIXO"   ,PadR(::WsTituloErp:WsPrefTit ,TamSX3("E1_PREFIXO")[1], ' ') ,Nil},; 
           {"E1_NUM"       ,PadR(::WsTituloErp:WsNumTit  ,TamSX3("E1_NUM")[1], ' ')     ,Nil},; 
           {"E1_FILIAL"    ,WsTituloErp:WsFilTit ,Nil},; 
           {"E1_PARCELA"   ,PadR(::WsTituloErp:WsParcTit ,TamSX3("E1_PARCELA")[1], ' ')    ,Nil},; 
           {"E1_CLIENTE"   ,::WsTituloErp:WsCodCli    ,Nil},; 
           {"E1_LOJA"      ,::WsTituloErp:WsLojCli    ,Nil},; 
           {"E1_TIPO"      ,::WsTituloErp:WsTipoTit   ,Nil},; 
           {"AUTMOTBX"     ,::WsTituloErp:WsMotBx     ,Nil},; 
           {"E1_LA"       ,"S"   ,Nil},; 
           {"AUTBANCO"     ,cBanco  ,Nil},; 
           {"AUTAGENCIA"   ,cAgencia    ,Nil},; 
           {"AUTCONTA"     ,cConta       ,Nil},; 
           {"AUTDTBAIXA"   ,CTOD(::WsTituloErp:WsDtBx)     ,Nil},; 
           {"AUTDTCREDITO" ,CTOD(::WsTituloErp:WsDtCred)   ,Nil},; 
           {"AUTHIST"      ,::WsTituloErp:WsHist     ,Nil},; 
           {"AUTJUROS"     ,VAL(::WsTituloErp:WsJuros)    ,Nil},; 
           {"AUTDESCONT"   ,VAL(::WsTituloErp:WsDesconto) ,Nil},; 
           {"AUTVALREC"    ,VAL(::WsTituloErp:WsValRec)   ,Nil}} 

lMsErroAuto	:= .F.

	/*Conteúdos do nOpc: 3 - Baixa de Título, 5 - Cancelamento de baixa, 6 - Exclusão de Baixa.*/
	MsExecAuto( {|X, Y| FINA070(X, Y)}, aVetor, 6 )
           
	If lMsErroAuto
    	_erro := "Erro: " + MostraErro() 
    	Conout(_erro)
    	::WsRetornoS := _erro
	Endif

cEmpAnt := _cEmpBkp
cFilAnt := _cFilBkp

RestArea(_aAreaSM0)
RestArea(_aArea)                      
ddatabase := dataAtual                

SE1->(DBSKIP())

//RESET ENVIRONMENT

Return .T.


/*/================================================================================================================================/*/
/*/{Protheus.doc} CancelarBaixaTitulo
Metodo da Classe WEBA01PA, responsável por CANCELAR A BAIXA DE UM TITULO

@type 	 method
@author  IATAN
@since 	 02/01/2017
@version P12.1.23
@obs 	 Desenvolvimento FIEG
@return  Lógico, retorna verdadeiro.
@history 14/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 
/*/
/*/================================================================================================================================/*/

WsMethod CancelarBaixaTitulo WsReceive WsCEmp,WsCFil,WsLogin,WsSenha,WsTituloErp WsSend WsRetornoS WsService WEBA01PA

Local _lLogin	:= .T.

Local cBanco := ""
Local cAgencia := ""
Local cConta := ""
/*Variaveis responsáveis por tratar as filiais de inserção dos registros*/
Local _aArea	:= GetArea()                                              
Local _aAreaSM0	:= SM0->(GetArea())
Local _cEmpBkp	:= cEmpAnt
Local _cFilBkp	:= cFilAnt
Local _cFilExe := WsCFil
/*FIM - Variaveis responsáveis por tratar as filiais de inserção dos registros*/
Private INCLUI	:= .F.                 
Private aVetor := {}
//Variável da Rotina Automática
Private lMsErroAuto	:= .F.

RPCSetType(3)
//PREPARE ENVIRONMENT EMPRESA WsCEmp FILIAL WsCFil USER WsLogin PASSWORD WsSenha
OpenSm0(cEmpAnt, .T.)
SM0->(DbSetOrder(01))
SM0->(DbGoTop())
SM0->(DbSeek(WsCEmp+WsCFil))
cFilAnt := _cFilExe

PswOrder(02) //Nome do Usuário
//Posionando no Usuário
If PswSeek( WsLogin, .T. )
	//A Variável é alterada para o Login conforme o cadastrado no Protheus.
	//Pois para a função do Prepare Environment é necessário dessa forma.
	WsLogin := AllTrim(PswRet()[01,02])
Else
	_lLogin := .F.
EndIf

//Validando a senha após posiciona no Usuário.
If !PswName( WsSenha )
	_lLogin := .F.
EndIf

//Caso não tenha passado pela validação de usuário e senha do Protheus.
If !_lLogin
	
	If EMPTY(::WsRetorno:WsMensagens)
		aADD( ::WsRetorno:WsMensagens, WSClassNew("StrMsgRet") )
		_nPMsg	:= Len( ::WsRetorno:WsMensagens )
		::WsRetorno:WsMensagens[_nPMsg]:WsCodMsg := -5
		::WsRetorno:WsMensagens[_nPMsg]:WsDScMsg := "Usuário ou Senha Inválido."
	EndIF
	
	RETURN .T.
	
EndIF


cBanco := PadR(::WsTituloErp:WsBanco,TamSX3("A6_COD")[1], ' ')
cAgencia := PadR(::WsTituloErp:WsAgencia,TamSX3("A6_AGENCIA")[1], ' ')
cConta := PadR(::WsTituloErp:WsConta,TamSX3("A6_NUMCON")[1], ' ')

aVetor:={  {"E1_PREFIXO"   ,PadR(::WsTituloErp:WsPrefTit ,TamSX3("E1_PREFIXO")[1], ' ') ,Nil},; 
           {"E1_NUM"       ,PadR(::WsTituloErp:WsNumTit  ,TamSX3("E1_NUM")[1], ' ')     ,Nil},; 
           {"E1_FILIAL"    ,WsTituloErp:WsFilTit ,Nil},; 
           {"E1_PARCELA"   ,PadR(::WsTituloErp:WsParcTit ,TamSX3("E1_PARCELA")[1], ' ')    ,Nil},; 
           {"E1_CLIENTE"   ,::WsTituloErp:WsCodCli    ,Nil},; 
           {"E1_LOJA"      ,::WsTituloErp:WsLojCli    ,Nil},; 
           {"E1_TIPO"      ,::WsTituloErp:WsTipoTit   ,Nil},; 
           {"AUTMOTBX"     ,::WsTituloErp:WsMotBx     ,Nil},; 
           {"E1_LA"       ,"S"   ,Nil},; 
           {"AUTBANCO"     ,cBanco  ,Nil},; 
           {"AUTAGENCIA"   ,cAgencia    ,Nil},; 
           {"AUTCONTA"     ,cConta       ,Nil},; 
           {"AUTDTBAIXA"   ,CTOD(::WsTituloErp:WsDtBx)     ,Nil},; 
           {"AUTDTCREDITO" ,CTOD(::WsTituloErp:WsDtCred)   ,Nil},; 
           {"AUTHIST"      ,::WsTituloErp:WsHist     ,Nil},; 
           {"AUTJUROS"     ,VAL(::WsTituloErp:WsJuros)    ,Nil},; 
           {"AUTDESCONT"   ,VAL(::WsTituloErp:WsDesconto) ,Nil},; 
           {"AUTVALREC"    ,VAL(::WsTituloErp:WsValRec)   ,Nil}} 

lMsErroAuto	:= .F.


	MsExecAuto( {|X, Y| FINA070(X, Y)}, aVetor, 5 )
           
	If lMsErroAuto
    	_erro := "Erro: " + MostraErro() 
//    	Conout(_erro)
    	::WsRetornoS := _erro
	Endif

cEmpAnt := _cEmpBkp
cFilAnt := _cFilBkp

RestArea(_aAreaSM0)
RestArea(_aArea)
//RESET ENVIRONMENT

Return .T.


/*/================================================================================================================================/*/
/*/{Protheus.doc} MovBancarioCent
Metodo da Classe WEBA01PA, responsável por INCLUIR UM MOVIMENTO BANCÁRIO NA FILIAL CENTRALIZADORA

@type 	 method
@author  IATAN
@since 	 24/12/2016
@version P12.1.23
@obs 	 Desenvolvimento FIEG
@return  Lógico, retorna verdadeiro.
@history 14/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 
/*/
/*/================================================================================================================================/*/

WsMethod MovBancarioCent WsReceive WsCEmp,WsCFil,WsLogin,WsSenha,WsTituloErp WsSend WsRetornoS WsService WEBA01PA

Local _lLogin	:= .T.

Local cBanco := ""
Local cAgencia := ""
Local cConta := ""

/*Variaveis responsáveis por tratar as filiais de inserção dos registros*/
Local _aArea	:= GetArea()                                              
Local _aAreaSM0	:= SM0->(GetArea())
Local _cEmpBkp	:= cEmpAnt
Local _cFilBkp	:= cFilAnt
Local _cFilExe := WsCFil
Local dataAtual := ddatabase
/*FIM - Variaveis responsáveis por tratar as filiais de inserção dos registros*/
Private INCLUI	:= .F.                 
Private aVetor := {}
//Variável da Rotina Automática
Private lMsErroAuto	:= .F.

RPCSetType(3)

//COMANDO ABAIXO SENDO EXECUTADO POIS OS MOVIMENTOS ESTAVAM GERANDO CONTABILIZAÇÃO SEM ESTE COMANDO
PREPARE ENVIRONMENT EMPRESA WsCEmp FILIAL WsCFil USER WsLogin PASSWORD WsSenha

OpenSm0(cEmpAnt, .T.)
SM0->(DbSetOrder(01))
SM0->(DbGoTop())
SM0->(DbSeek(WsCEmp+WsCFil))
cFilAnt := _cFilExe

PswOrder(02) //Nome do Usuário
//Posionando no Usuário
If PswSeek( WsLogin, .T. )
	//A Variável é alterada para o Login conforme o cadastrado no Protheus.
	//Pois para a função do Prepare Environment é necessário dessa forma.
	WsLogin := AllTrim(PswRet()[01,02])
Else
	_lLogin := .F.
EndIf

//Validando a senha após posiciona no Usuário.
If !PswName( WsSenha )
	_lLogin := .F.
EndIf

//Caso não tenha passado pela validação de usuário e senha do Protheus.
If !_lLogin
	
	If EMPTY(::WsRetorno:WsMensagens)
		aADD( ::WsRetorno:WsMensagens, WSClassNew("StrMsgRet") )
		_nPMsg	:= Len( ::WsRetorno:WsMensagens )
		::WsRetorno:WsMensagens[_nPMsg]:WsCodMsg := -5
		::WsRetorno:WsMensagens[_nPMsg]:WsDScMsg := "Usuário ou Senha Inválido."
	EndIF
	
	RETURN .T.
	
EndIF


cBanco := PadR(::WsTituloErp:WsBanco,TamSX3("A6_COD")[1], ' ')
cAgencia := PadR(::WsTituloErp:WsAgencia,TamSX3("A6_AGENCIA")[1], ' ')
cConta := PadR(::WsTituloErp:WsConta,TamSX3("A6_NUMCON")[1], ' ')

ddatabase := CTOD(::WsTituloErp:WsDtCred)
  
aVetor:={  {"E5_DATA"      ,CTOD(::WsTituloErp:WsDtCred), Nil},; 
           {"E5_MOEDA"     ,'M1', Nil},; 
           {"E5_VALOR"     ,VAL(::WsTituloErp:WsValRec), Nil},; 
           {"E5_NATUREZ"   ,PadR(::WsTituloErp:WsNatureza ,TamSX3("E5_NATUREZA")[1], ' '), Nil},; 
           {"E5_BANCO"     ,cBanco, Nil},; 
           {"E5_AGENCIA"   ,cAgencia, Nil},; 
           {"E5_CONTA"     ,cConta, Nil},; 
           {"E5_DOCUMEN"   ,::WsTituloErp:WsOrigemTit+::WsTituloErp:WsNumTit+'.'+WsTituloErp:WsParcTit, Nil},; 
           {"E5_XIDESB"    ,PadR(::WsTituloErp:WsNumTit  ,TamSX3("E5_XIDESB")[1], ' '), Nil},; 
           {"E5_PARCELA"   ,PadR(::WsTituloErp:WsParcTit ,TamSX3("E5_PARCELA")[1], ' '), Nil},; 
           {"E5_HISTOR"    ,'CENTR.:'+::WsTituloErp:WsHist, Nil},; 
           {"E5_TIPOLAN"   ,'C', Nil},; 
           {"E5_FILIAL"    ,::WsTituloErp:WsFilTit, Nil},; 
           {"E5_BENEF"     ,::WsTituloErp:WsNomCli, Nil},; 
           {"E5_CREDITO"   ,PadR(::WsTituloErp:WsContaC,TamSX3("E5_CREDITO")[1], ' '), Nil},; 
           {"E5_CCC"       ,PadR(::WsTituloErp:WsCc, TamSX3("E5_CCC")[1], ' '), Nil},; 
           {"E5_ITEMC"     ,PadR(::WsTituloErp:WsCentResp, TamSX3("E5_ITEMC")[1], ' '), Nil},; 
           {"E5_FILORIG"   ,::WsTituloErp:WsFilTit, Nil}}


lMsErroAuto	:= .F.

	/*
	  Opções do ExecAuto para a rotina FINA100:
	  		3 = "PAGAR",
	  		4 = "RECEBER",
	  		5 = "EXCLUIR",
	  		6 = "CANCELAR",
	  		7 = "TRANSF.",
	  		8 = "EST. TRANSF."
	*/
	//MsExecAuto( {|X, Y| FINA100(X, Y)}, aVetor, 4 ) 
	MSExecAuto({|x,y,z| FINA100(x,y,z)},0,aVetor,4) 
           
	If lMsErroAuto
    	_erro := "Erro: " + MostraErro() 
    	Conout(_erro)
    	::WsRetornoS := _erro
	Endif

cEmpAnt := _cEmpBkp
cFilAnt := _cFilBkp

RestArea(_aAreaSM0)
RestArea(_aArea)                         
ddatabase := dataAtual
//RESET ENVIRONMENT

Return .T.


/*/================================================================================================================================/*/
/*/{Protheus.doc} MovBancarioDev
Metodo da Classe WEBA01PA, responsável por INCLUIR UM MOVIMENTO BANCÁRIO DE DEVOLUÇÃO DE NUMERÁRIO

@type 	 method
@author  IATAN
@since 	 16/01/2017
@version P12.1.23
@obs 	 Desenvolvimento FIEG
@return  Lógico, retorna verdadeiro.
@history 14/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 
/*/
/*/================================================================================================================================/*/

WsMethod MovBancarioDev WsReceive WsCEmp,WsCFil,WsLogin,WsSenha,WsTituloErp WsSend WsRetornoS WsService WEBA01PA

Local _lLogin	:= .T.

Local cBanco := ""
Local cAgencia := ""
Local cConta := ""

/*Variaveis responsáveis por tratar as filiais de inserção dos registros*/
Local _aArea	:= GetArea()                                              
Local _aAreaSM0	:= SM0->(GetArea())
Local _cEmpBkp	:= cEmpAnt
Local _cFilBkp	:= cFilAnt
Local _cFilExe := WsCFil
Local dataAtual := ddatabase
/*FIM - Variaveis responsáveis por tratar as filiais de inserção dos registros*/
Private INCLUI	:= .F.                 
Private aVetor := {}
//Variável da Rotina Automática
Private lMsErroAuto	:= .F.

RPCSetType(3)
//COMANDO ABAIXO SENDO EXECUTADO POIS OS MOVIMENTOS ESTAVAM GERANDO CONTABILIZAÇÃO SEM ESTE COMANDO
PREPARE ENVIRONMENT EMPRESA WsCEmp FILIAL WsCFil USER WsLogin PASSWORD WsSenha

OpenSm0(cEmpAnt, .T.)
SM0->(DbSetOrder(01))
SM0->(DbGoTop())
SM0->(DbSeek(WsCEmp+WsCFil))
cFilAnt := _cFilExe

PswOrder(02) //Nome do Usuário
//Posionando no Usuário
If PswSeek( WsLogin, .T. )
	//A Variável é alterada para o Login conforme o cadastrado no Protheus.
	//Pois para a função do Prepare Environment é necessário dessa forma.
	WsLogin := AllTrim(PswRet()[01,02])
Else
	_lLogin := .F.
EndIf

//Validando a senha após posiciona no Usuário.
If !PswName( WsSenha )
	_lLogin := .F.
EndIf

//Caso não tenha passado pela validação de usuário e senha do Protheus.
If !_lLogin
	
	If EMPTY(::WsRetorno:WsMensagens)
		aADD( ::WsRetorno:WsMensagens, WSClassNew("StrMsgRet") )
		_nPMsg	:= Len( ::WsRetorno:WsMensagens )
		::WsRetorno:WsMensagens[_nPMsg]:WsCodMsg := -5
		::WsRetorno:WsMensagens[_nPMsg]:WsDScMsg := "Usuário ou Senha Inválido."
	EndIF                                      
	
	RETURN .T.
	
EndIF

cBanco := PadR(::WsTituloErp:WsBanco,TamSX3("A6_COD")[1], ' ')
cAgencia := PadR(::WsTituloErp:WsAgencia,TamSX3("A6_AGENCIA")[1], ' ')
cConta := PadR(::WsTituloErp:WsConta,TamSX3("A6_NUMCON")[1], ' ')

ddatabase := CTOD(::WsTituloErp:WsDtCred)

aVetor := {    {"E5_DATA",    CTOD(::WsTituloErp:WsDtCred)    ,Nil},;
               {"E5_MOEDA",   'M1'                            ,Nil},;
               {"E5_VALOR",   VAL(::WsTituloErp:WsValRec)    ,Nil},;
               {"E5_FILIAL",  ::WsTituloErp:WsFilTit         ,Nil},;
               {"E5_NATUREZ", PadR(::WsTituloErp:WsNatureza ,TamSX3("E5_NATUREZA")[1], ' ') ,Nil},;
               {"E5_BANCO",   cBanco                        ,Nil},;
               {"E5_AGENCIA", cAgencia                      ,Nil},;
               {"E5_CONTA",   cConta                        ,Nil},;
               {"E5_DEBITO",  PadR(::WsTituloErp:WsContaC,TamSX3("E5_DEBITO")[1], ' ')      ,Nil},;
               {"E5_CCD",     PadR(::WsTituloErp:WsCc, TamSX3("E5_CCC")[1], ' ')            ,Nil},;
               {"E5_TIPOLAN", 'D'                                ,Nil},;
               {"E5_BENEF",   ::WsTituloErp:WsNomCli             ,Nil},;
               {"E5_HISTOR",  'DEVOLUCAO:'+::WsTituloErp:WsHist  ,Nil}}
  
lMsErroAuto	:= .F.

	/*
	  Opções do ExecAuto para a rotina FINA100:
	  		3 = "PAGAR",
	  		4 = "RECEBER",
	  		5 = "EXCLUIR",
	  		6 = "CANCELAR",
	  		7 = "TRANSF.",
	  		8 = "EST. TRANSF."
	*/
	//MsExecAuto( {|X, Y| FINA100(X, Y)}, aVetor, 4 ) 
	MSExecAuto({|x,y,z|FINA100(x,y,z)},0,aVetor,3) 
           
	If lMsErroAuto
    	_erro := "Erro: " + MostraErro() 
    	Conout(_erro)
    	::WsRetornoS := _erro
	Endif

cEmpAnt := _cEmpBkp
cFilAnt := _cFilBkp

RestArea(_aAreaSM0)
RestArea(_aArea)                         
ddatabase := dataAtual
//RESET ENVIRONMENT

Return .T.


/*/================================================================================================================================/*/
/*/{Protheus.doc} ExcMovBancario
Metodo da Classe WEBA01PA, responsável por EXCLUIR UM MOVIMENTO BANCÁRIO NA FILIAL CENTRALIZADORA

@type 	 method
@author  IATAN
@since 	 24/12/2016
@version P12.1.23
@obs 	 Desenvolvimento FIEG
@return  Lógico, retorna verdadeiro.
@history 14/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 
/*/
/*/================================================================================================================================/*/

WsMethod ExcMovBancario WsReceive WsCEmp,WsCFil,WsLogin,WsSenha,WsTituloErp WsSend WsRetornoS WsService WEBA01PA

Local _lLogin	:= .T.

Local cBanco := ""
Local cAgencia := ""
Local cConta := ""

/*Variaveis responsáveis por tratar as filiais de inserção dos registros*/
Local _aArea	:= GetArea()                                              
Local _aAreaSM0	:= SM0->(GetArea())
Local _cEmpBkp	:= cEmpAnt
Local _cFilBkp	:= cFilAnt
Local _cFilExe := WsCFil
Local dataAtual := ddatabase
Local documen := ''
/*FIM - Variaveis responsáveis por tratar as filiais de inserção dos registros*/
Private INCLUI	:= .F.                 
Private aVetor := {}
//Variável da Rotina Automática
Private lMsErroAuto	:= .F.

RPCSetType(3)
//PREPARE ENVIRONMENT EMPRESA WsCEmp FILIAL WsCFil USER WsLogin PASSWORD WsSenha
OpenSm0(cEmpAnt, .T.)
SM0->(DbSetOrder(01))
SM0->(DbGoTop())
SM0->(DbSeek(WsCEmp+WsCFil))
cFilAnt := _cFilExe

PswOrder(02) //Nome do Usuário
//Posionando no Usuário
If PswSeek( WsLogin, .T. )
	//A Variável é alterada para o Login conforme o cadastrado no Protheus.
	//Pois para a função do Prepare Environment é necessário dessa forma.
	WsLogin := AllTrim(PswRet()[01,02])
Else
	_lLogin := .F.
EndIf

//Validando a senha após posiciona no Usuário.
If !PswName( WsSenha )
	_lLogin := .F.
EndIf

//Caso não tenha passado pela validação de usuário e senha do Protheus.
If !_lLogin
	
	If EMPTY(::WsRetorno:WsMensagens)
		aADD( ::WsRetorno:WsMensagens, WSClassNew("StrMsgRet") )
		_nPMsg	:= Len( ::WsRetorno:WsMensagens )
		::WsRetorno:WsMensagens[_nPMsg]:WsCodMsg := -5
		::WsRetorno:WsMensagens[_nPMsg]:WsDScMsg := "Usuário ou Senha Inválido."
	EndIF
	
	RETURN .T.
	
EndIF

cBanco := PadR(::WsTituloErp:WsBanco,TamSX3("A6_COD")[1], ' ')
cAgencia := PadR(::WsTituloErp:WsAgencia,TamSX3("A6_AGENCIA")[1], ' ')
cConta := PadR(::WsTituloErp:WsConta,TamSX3("A6_NUMCON")[1], ' ')

ddatabase := CTOD(::WsTituloErp:WsDtCred)

dbSelectArea("SE5")
SE5->(dbSetOrder(10)) 										// 10 = E5_FILIAL+E5_DOCUMEN                                    
documen := PadR(::WsTituloErp:WsOrigemTit+::WsTituloErp:WsNumTit+'.'+WsTituloErp:WsParcTit  ,TamSX3("E5_DOCUMEN")[1], ' ')
SE5->(dbSeek(WsCFil+documen))

aVetor:={  {"E5_DATA"      ,CTOD(::WsTituloErp:WsDtCred), Nil},; 
           {"E5_MOEDA"     ,'M1', Nil},; 
           {"E5_VALOR"     ,VAL(::WsTituloErp:WsValRec), Nil},; 
           {"E5_NATUREZ"   ,PadR(::WsTituloErp:WsNatureza ,TamSX3("E5_NATUREZA")[1], ' '), Nil},; 
           {"E5_BANCO"     ,cBanco, Nil},; 
           {"E5_AGENCIA"   ,cAgencia, Nil},; 
           {"E5_CONTA"     ,cConta, Nil},; 
           {"E5_DOCUMEN"   ,::WsTituloErp:WsOrigemTit+::WsTituloErp:WsNumTit+'.'+WsTituloErp:WsParcTit, Nil},; 
           {"E5_XIDESB"    ,PadR(::WsTituloErp:WsNumTit  ,TamSX3("E5_XIDESB")[1], ' '), Nil},; 
           {"E5_PARCELA"   ,PadR(::WsTituloErp:WsParcTit ,TamSX3("E5_PARCELA")[1], ' '), Nil},; 
           {"E5_HISTOR"    ,'CENTR.:'+::WsTituloErp:WsHist, Nil},; 
           {"E5_TIPOLAN"   ,'C', Nil},; 
           {"E5_FILIAL"    ,::WsTituloErp:WsFilTit, Nil},; 
           {"E5_BENEF"     ,::WsTituloErp:WsNomCli, Nil},; 
           {"E5_CREDITO"   ,PadR(::WsTituloErp:WsContaC,TamSX3("E5_CREDITO")[1], ' '), Nil},; 
           {"E5_CCC"       ,PadR(::WsTituloErp:WsCc, TamSX3("E5_CCC")[1], ' '), Nil},; 
           {"E5_ITEMC"     ,PadR(::WsTituloErp:WsCentResp, TamSX3("E5_ITEMC")[1], ' '), Nil},; 
           {"E5_FILORIG"   ,::WsTituloErp:WsFilTit, Nil}}
 
lMsErroAuto	:= .F.

	/*
	  Opções do ExecAuto para a rotina FINA100:
	  		3 = "PAGAR",
	  		4 = "RECEBER",
	  		5 = "EXCLUIR",
	  		6 = "CANCELAR",
	  		7 = "TRANSF.",
	  		8 = "EST. TRANSF."
	*/
	//MsExecAuto( {|X, Y| FINA100(X, Y)}, aVetor, 4 ) 
	MSExecAuto({|x,y,z| FINA100(x,y,z)},0,aVetor,5) 
           
	If lMsErroAuto
    	_erro := "Erro: " + MostraErro() 
    	Conout(_erro)
    	::WsRetornoS := _erro
	Endif

cEmpAnt := _cEmpBkp
cFilAnt := _cFilBkp

RestArea(_aAreaSM0)
RestArea(_aArea)                         
ddatabase := dataAtual
//SE5->(DbSkip())
//RESET ENVIRONMENT

Return .T.


/*/================================================================================================================================/*/
/*/{Protheus.doc} ExisteAjuste
Metodo da Classe WEBA01PA, responsável por retornar se existe uma movimentação bancária de ajuste manual

@type 	 method
@author  IATAN
@since 	 15/02/2017
@version P12.1.23
@obs 	 Desenvolvimento FIEG
@return  Lógico, retorna verdadeiro.
@history 14/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 
/*/
/*/================================================================================================================================/*/

WsMethod ExisteAjuste WsReceive WsCEmp,WsCFil,WsLogin,WsSenha, WsDataMFS, WsBancoMFS, WsAgenciaMFS, WsContaMFS WsSend WsRetornoS WsService WEBA01PA

Local _lLogin	:= .T.
Local _aArea	:= GetArea()
Local _aAreaSM0	:= SM0->(GetArea())
Local _cEmpBkp	:= cEmpAnt
Local _cFilBkp	:= cFilAnt
Local _cFilExe 	:= WsCFil
Local cQuery 	:= ""

Private INCLUI	:= .F.  

::WsRetornoS := "" // VALOR PADRÃO

RPCSetType(3)
//PREPARE ENVIRONMENT EMPRESA WsCEmp FILIAL WsCFil USER WsLogin PASSWORD WsSenha

OpenSm0(cEmpAnt, .T.)
SM0->(DbSetOrder(01))
SM0->(DbGoTop())
SM0->(DbSeek(WsCEmp+WsCFil))
cFilAnt := _cFilExe
                                                                          
//UTILIZANDO UM FILTRO "PRÓXIMO" AO INDICE 1 DA TABELA SE5010
cQuery := " SELECT * "
cQuery += " FROM SE5010 WITH(NOLOCK) "
cQuery += " WHERE D_E_L_E_T_ <> '*' "
cQuery += "       AND E5_FILIAL = '" + WsCFil + "' "
cQuery += "       AND E5_DATA = '" + WsDataMFS + "' "
cQuery += "       AND E5_BANCO = '" + PadR(WsBancoMFS ,TamSX3("E5_BANCO")[1], ' ') + "' "
cQuery += "       AND E5_AGENCIA = '" + PadR(WsAgenciaMFS ,TamSX3("E5_AGENCIA")[1], ' ') + "' "
cQuery += "       AND E5_CONTA = '" + PadR(WsContaMFS ,TamSX3("E5_CONTA")[1], ' ') + "' "
cQuery += "       AND E5_TIPOLAN = 'C' "
cQuery += "       AND E5_NATUREZ = '4010110006' "

TCQUERY cQuery NEW ALIAS "QSE5X"
DbSelectArea("QSE5X")
QSE5X->(DbGotop())
While !QSE5X->(Eof())
	::WsRetornoS := "SIM"  
	QSE5X->(dbskip()) 
END
QSE5X->(dbCloseArea())

PswOrder(02) //Nome do Usuário
//Posionando no Usuário
If PswSeek( WsLogin, .T. )
	//A Variável é alterada para o Login conforme o cadastrado no Protheus.
	//Pois para a função do Prepare Environment é necessário dessa forma.
	WsLogin := AllTrim(PswRet()[01,02])
Else
	_lLogin := .F.
EndIf

//Validando a senha após posiciona no Usuário.
If !PswName( WsSenha )
	_lLogin := .F.
EndIf

//Caso não tenha passado pela validação de usuário e senha do Protheus.
If !_lLogin
	
	If EMPTY(::WsRetorno:WsMensagens)
		aADD( ::WsRetorno:WsMensagens, WSClassNew("StrMsgRet") )
		_nPMsg	:= Len( ::WsRetorno:WsMensagens )
		::WsRetorno:WsMensagens[_nPMsg]:WsCodMsg := -5
		::WsRetorno:WsMensagens[_nPMsg]:WsDScMsg := "Usuário ou Senha Inválido."
	EndIF
	
	RETURN .T.
	
EndIF

cEmpAnt := _cEmpBkp
cFilAnt := _cFilBkp

RestArea(_aAreaSM0)
RestArea(_aArea)

//RESET ENVIRONMENT

Return .T.


/*/================================================================================================================================/*/
/*/{Protheus.doc} GetObjContabilCab
Metodo da Classe WEBA01PA, responsável por efetuar um lançamento contábil consolidado

@type 	 method
@author  IATAN
@since 	 15/02/2017
@version P12.1.23
@obs 	 Desenvolvimento FIEG
@return  Lógico, retorna verdadeiro.
@history 14/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 
/*/
/*/================================================================================================================================/*/

WsMethod GetObjContabilCab WsReceive WsCEmp,WsCFil,WsLogin,WsSenha WsSend WsContabilCab WsService WEBA01PA

Local _lLogin	:= .T.
Local _aArea	:= GetArea()
Local _aAreaSM0	:= SM0->(GetArea())
Local _cEmpBkp	:= cEmpAnt
Local _cFilBkp	:= cFilAnt
Local _cFilExe := WsCFil

Private INCLUI	:= .F.

RPCSetType(3)
//PREPARE ENVIRONMENT EMPRESA WsCEmp FILIAL WsCFil USER WsLogin PASSWORD WsSenha

OpenSm0(cEmpAnt, .T.)
SM0->(DbSetOrder(01))
SM0->(DbGoTop())
SM0->(DbSeek(WsCEmp+WsCFil))
cFilAnt := _cFilExe

PswOrder(02) //Nome do Usuário
//Posionando no Usuário
If PswSeek( WsLogin, .T. )
	//A Variável é alterada para o Login conforme o cadastrado no Protheus.
	//Pois para a função do Prepare Environment é necessário dessa forma.
	WsLogin := AllTrim(PswRet()[01,02])
Else
	_lLogin := .F.
EndIf

//Validando a senha após posiciona no Usuário.
If !PswName( WsSenha )
	_lLogin := .F.
EndIf

//Caso não tenha passado pela validação de usuário e senha do Protheus.
If !_lLogin
	
	If EMPTY(::WsRetorno:WsMensagens)
		aADD( ::WsRetorno:WsMensagens, WSClassNew("StrMsgRet") )
		_nPMsg	:= Len( ::WsRetorno:WsMensagens )
		::WsRetorno:WsMensagens[_nPMsg]:WsCodMsg := -5
		::WsRetorno:WsMensagens[_nPMsg]:WsDScMsg := "Usuário ou Senha Inválido."
	EndIF
	
	RETURN .T.
	
EndIF

::WsContabilCab:WsLote      := '.'
::WsContabilCab:WsSubLote   := '.'
::WsContabilCab:WsDocumento := '.'
::WsContabilCab:WsDataLanc  := '.'

cEmpAnt := _cEmpBkp
cFilAnt := _cFilBkp

RestArea(_aAreaSM0)
RestArea(_aArea)

//RESET ENVIRONMENT
Return .T.


/*/================================================================================================================================/*/
/*/{Protheus.doc} GetObjContabilDet
Metodo da Classe WEBA01PA, responsável por efetuar um lançamento contábil consolidado

@type 	 method
@author  IATAN
@since 	 15/02/2017
@version P12.1.23
@obs 	 Desenvolvimento FIEG
@return  Lógico, retorna verdadeiro.
@history 14/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 
/*/
/*/================================================================================================================================/*/

WsMethod GetObjContabilDet WsReceive WsCEmp,WsCFil,WsLogin,WsSenha,WsContabilDetQtd WsSend WsContabilDetArr WsService WEBA01PA

Local _lLogin	:= .T.
Local _aArea	:= GetArea()
Local _aAreaSM0	:= SM0->(GetArea())
Local _cEmpBkp	:= cEmpAnt
Local _cFilBkp	:= cFilAnt
Local _cFilExe := WsCFil                 
Local qtd := 0
Local i := 0

qtd := VAL(::WsContabilDetQtd)

Private INCLUI	:= .F.

RPCSetType(3)
//PREPARE ENVIRONMENT EMPRESA WsCEmp FILIAL WsCFil USER WsLogin PASSWORD WsSenha

OpenSm0(cEmpAnt, .T.)
SM0->(DbSetOrder(01))
SM0->(DbGoTop())
SM0->(DbSeek(WsCEmp+WsCFil))
cFilAnt := _cFilExe

PswOrder(02) //Nome do Usuário
//Posionando no Usuário
If PswSeek( WsLogin, .T. )
	//A Variável é alterada para o Login conforme o cadastrado no Protheus.
	//Pois para a função do Prepare Environment é necessário dessa forma.
	WsLogin := AllTrim(PswRet()[01,02])
Else
	_lLogin := .F.
EndIf

//Validando a senha após posiciona no Usuário.
If !PswName( WsSenha )
	_lLogin := .F.
EndIf

//Caso não tenha passado pela validação de usuário e senha do Protheus.
If !_lLogin
	
	If EMPTY(::WsRetorno:WsMensagens)
		aADD( ::WsRetorno:WsMensagens, WSClassNew("StrMsgRet") )
		_nPMsg	:= Len( ::WsRetorno:WsMensagens )
		::WsRetorno:WsMensagens[_nPMsg]:WsCodMsg := -5
		::WsRetorno:WsMensagens[_nPMsg]:WsDScMsg := "Usuário ou Senha Inválido."
	EndIF
	
	RETURN .T.
	
EndIF

//cria um vetor de objetos de "WsContabilDetQtd" posições
while i < qtd
	aADD( ::WsContabilDetArr:WsContabilDetArr, WSClassNew("StrContabilDet") )
	::WsContabilDetArr:WsContabilDetArr[i+1]:WsFilial := '.'
	i++
enddo

cEmpAnt := _cEmpBkp
cFilAnt := _cFilBkp

RestArea(_aAreaSM0)
RestArea(_aArea)

//RESET ENVIRONMENT
Return .T.


/*/================================================================================================================================/*/
/*/{Protheus.doc} ContabilConsolidado
Metodo da Classe WEBA01PA, responsável por efetuar um lançamento contábil consolidado

@type 	 method
@author  IATAN
@since 	 14/03/2017
@version P12.1.23
@obs 	 Desenvolvimento FIEG
@return  Lógico, retorna verdadeiro.
@history 14/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 
/*/
/*/================================================================================================================================/*/

WsMethod ContabilConsolidado WsReceive WsCEmp,WsCFil,WsLogin,WsSenha, WsContabilCab, WsContabilDetArr WsSend WsRetornoS WsService WEBA01PA

Local aCab 		:= {}
Local aItens 	:= {}
Local _lLogin	:= .T.
Local _aArea	:= GetArea()
Local _aAreaSM0	:= SM0->(GetArea())
Local _cEmpBkp	:= cEmpAnt
Local _cFilBkp	:= cFilAnt
Local _cFilExe 	:= WsCFil
             
Private lMsErroAuto := .F.

::WsRetornoS := "" // VALOR PADRÃO

RPCSetType(3)
//PREPARE ENVIRONMENT EMPRESA WsCEmp FILIAL WsCFil USER WsLogin PASSWORD WsSenha

OpenSm0(cEmpAnt, .T.)
SM0->(DbSetOrder(01))
SM0->(DbGoTop())
SM0->(DbSeek(WsCEmp+WsCFil))
cFilAnt := _cFilExe
                                                                          
  aAdd(aCab,  {'DDATALANC'  ,STOD(::WsContabilCab:WsDataLanc) ,NIL} )
  aAdd(aCab,  {'CLOTE'      ,::WsContabilCab:WsLote           ,NIL} )
  aAdd(aCab,  {'CSUBLOTE'   ,::WsContabilCab:WsSubLote        ,NIL} )
  aAdd(aCab,  {'CDOC'       ,::WsContabilCab:WsDocumento      ,NIL} ) 
  aAdd(aCab,  {'CPADRAO'    ,''         ,NIL} )
  aAdd(aCab,  {'NTOTINF'    ,0          ,NIL} )
  aAdd(aCab,  {'NTOTINFLOT' ,0          ,NIL} )

		For _nAls := 1 To Len( ::WsContabilDetArr:WSCONTABILDETARR )
			                   
				aAdd(aItens,{  {'CT2_FILIAL' ,::WsContabilDetArr:WSCONTABILDETARR[_nAls]:WsFilial   , NIL},;
				               {'CT2_LINHA'  ,::WsContabilDetArr:WSCONTABILDETARR[_nAls]:WsLinha    , NIL},;
				               {'CT2_MOEDLC' ,'01'                       , NIL},; 
				               {'CT2_DC'     ,::WsContabilDetArr:WSCONTABILDETARR[_nAls]:WsTpLanc     , NIL},;
				               {'CT2_DEBITO' ,PadR(::WsContabilDetArr:WSCONTABILDETARR[_nAls]:WsContaD ,TamSX3("CT2_DEBITO")[1], ' ') , NIL},;      
				               {'CT2_CLVLDB' ,''                         , NIL},;
				               {'CT2_CCC'    ,PadR(::WsContabilDetArr:WSCONTABILDETARR[_nAls]:WsCCC ,TamSX3("CT2_CCC")[1], ' ')          , NIL},;    
				               {'CT2_CCD'    ,PadR(::WsContabilDetArr:WSCONTABILDETARR[_nAls]:WsCCD ,TamSX3("CT2_CCD")[1], ' ')          , NIL},;    
				               {'CT2_ITEMC'  ,PadR(::WsContabilDetArr:WSCONTABILDETARR[_nAls]:WsItemC ,TamSX3("CT2_ITEMC")[1], ' ')   , NIL},;
				               {'CT2_ITEMD'  ,PadR(::WsContabilDetArr:WSCONTABILDETARR[_nAls]:WsItemD ,TamSX3("CT2_ITEMD")[1], ' ')   , NIL},;
				               {'CT2_CREDIT' ,PadR(::WsContabilDetArr:WSCONTABILDETARR[_nAls]:WsContaC ,TamSX3("CT2_CREDIT")[1], ' ') , NIL},;
				               {'CT2_VALOR'  ,Val(::WsContabilDetArr:WSCONTABILDETARR[_nAls]:WsValor)    , NIL},;
				               {'CT2_ORIGEM' ,'INTEGRACAO'               , NIL},;    
				               {'CT2_EMPORI' ,'01'                       , NIL},; 
				               {'CT2_FILORI' ,::WsContabilDetArr:WSCONTABILDETARR[_nAls]:WsFilOrig  , NIL},;
				               {'CT2_HP'     ,''                         , NIL},;
				               {'CT2_HIST'   ,::WsContabilDetArr:WSCONTABILDETARR[_nAls]:WsHist     , NIL}})
				
		Next _nAls

  lMsErroAuto	:= .F.

  MSExecAuto({|x, y,z| CTBA102(x,y,z)}, aCab ,aItens, 3)

	If lMsErroAuto
    	_erro := "Erro: " + MostraErro() 
    	Conout(_erro)
    	::WsRetornoS := _erro
	Endif

PswOrder(02) //Nome do Usuário
//Posionando no Usuário
If PswSeek( WsLogin, .T. )
	//A Variável é alterada para o Login conforme o cadastrado no Protheus.
	//Pois para a função do Prepare Environment é necessário dessa forma.
	WsLogin := AllTrim(PswRet()[01,02])
Else
	_lLogin := .F.
EndIf

//Validando a senha após posiciona no Usuário.
If !PswName( WsSenha )
	_lLogin := .F.
EndIf

//Caso não tenha passado pela validação de usuário e senha do Protheus.
If !_lLogin
	
	If EMPTY(::WsRetorno:WsMensagens)
		aADD( ::WsRetorno:WsMensagens, WSClassNew("StrMsgRet") )
		_nPMsg	:= Len( ::WsRetorno:WsMensagens )
		::WsRetorno:WsMensagens[_nPMsg]:WsCodMsg := -5
		::WsRetorno:WsMensagens[_nPMsg]:WsDScMsg := "Usuário ou Senha Inválido."
	EndIF
	
	RETURN .T.
	
EndIF

cEmpAnt := _cEmpBkp
cFilAnt := _cFilBkp

RestArea(_aAreaSM0)
RestArea(_aArea)

//RESET ENVIRONMENT

Return .T.


/*/================================================================================================================================/*/
/*/{Protheus.doc} CompensacaoCarteiras
Metodo da Classe WEBA01PA, responsável por compensar um titulo de Despesa com um titulo de receita

@type 	 method
@author  IATAN
@since 	 14/11/2017
@version P12.1.23
@obs 	 Desenvolvimento FIEG
@return  Lógico, retorna verdadeiro.
@history 14/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 
/*/
/*/================================================================================================================================/*/

WsMethod CompensacaoCarteiras WsReceive WsCEmp,WsCFil,WsLogin,WsSenha,WsTituloErp,WsTituloErpPag WsSend WsRetornoS WsService WEBA01PA

Local _lLogin	:= .T.

Local cBanco := ""
Local cAgencia := ""
Local cConta := ""
/*Variaveis responsáveis por tratar as filiais de inserção dos registros*/
Local _aArea	:= GetArea()                                              
Local _aAreaSM0	:= SM0->(GetArea())
Local _cEmpBkp	:= cEmpAnt
Local _cFilBkp	:= cFilAnt
Local _cFilExe := WsCFil
Local dataAtual := ddatabase
/*FIM - Variaveis responsáveis por tratar as filiais de inserção dos registros*/
Private INCLUI	:= .F.                 
Private aAutoCab := {}
//Variável da Rotina Automática
Private lMsErroAuto := .F.

RPCSetType(3)                       

//COMANDO ABAIXO SENDO EXECUTADO POIS OS MOVIMENTOS ESTAVAM GERANDO CONTABILIZAÇÃO SEM ESTE COMANDO
PREPARE ENVIRONMENT EMPRESA WsCEmp FILIAL WsCFil USER WsLogin PASSWORD WsSenha

OpenSm0(cEmpAnt, .T.)
SM0->(DbSetOrder(01))
SM0->(DbGoTop())
SM0->(DbSeek(WsCEmp+WsCFil))
cFilAnt := _cFilExe

PswOrder(02) //Nome do Usuário
//Posionando no Usuário
If PswSeek( WsLogin, .T. )
	//A Variável é alterada para o Login conforme o cadastrado no Protheus.
	//Pois para a função do Prepare Environment é necessário dessa forma.
	WsLogin := AllTrim(PswRet()[01,02])
Else
	_lLogin := .F.
EndIf

//Validando a senha após posiciona no Usuário.
If !PswName( WsSenha )
	_lLogin := .F.
EndIf

//Caso não tenha passado pela validação de usuário e senha do Protheus.
If !_lLogin
	
	If EMPTY(::WsRetorno:WsMensagens)
		aADD( ::WsRetorno:WsMensagens, WSClassNew("StrMsgRet") )
		_nPMsg	:= Len( ::WsRetorno:WsMensagens )
		::WsRetorno:WsMensagens[_nPMsg]:WsCodMsg := -5
		::WsRetorno:WsMensagens[_nPMsg]:WsDScMsg := "Usuário ou Senha Inválido."
	EndIF
	
	RETURN .T.
	
EndIF
                  

ddatabase := CTOD(::WsTituloErp:WsDtCred)

aAutoCab := { {"AUTDVENINI450", CTOD(::WsTituloErp:WsVencrea)    , nil},;
              {"AUTDVENFIM450", CTOD(::WsTituloErp:WsVencrea)    , nil},;
              {"AUTNLIM450",    VAL(::WsTituloErpPag:WsValRec) , nil},;
              {"AUTCCLI450",    ::WsTituloErp:WsCodCli        , nil},;
	           {"AUTCLJCLI",     ::WsTituloErp:WsLojCli        , nil},;
	           {"AUTCFOR450" ,   ::WsTituloErpPag:WsCodFor     , nil},;
	           {"AUTCLJFOR" ,    ::WsTituloErpPag:WsLojFor     , nil},;
	           {"AUTCMOEDA450" , "01"                          , nil},;
	           {"AUTNDEBCRED" ,  1                             , nil},;
	           {"AUTLTITFUTURO", .F.                           , nil},;
	           {"AUTARECCHAVE" , {}                            , nil},;
	           {"AUTAPAGCHAVE" , {}                            , nil}}


lMsErroAuto	:= .F.

	// Dados do titulo a receber
	SE1->( dbSetOrder( 1 ) )
	SE1->( MsSeek( ::WsTituloErp:WsFilTit + PadR( ::WsTituloErp:WsPrefTit , TamSX3("E1_PREFIXO" )[ 1 ] ) + ;
	PadR( ::WsTituloErp:WsNumTit , TamSX3( "E1_NUM" )[ 1 ] ) + ;
	PadR( ::WsTituloErp:WsParcTit , TamSX3( "E1_PARCELA" )[ 1 ] ) + ;
	PadR( ::WsTituloErp:WsTipoTit , TamSX3( "E1_TIPO" )[ 1 ] ) ) )

	AAdd( aAutoCab[11,2], { ::WsTituloErp:WsFilTit + PadR( ::WsTituloErp:WsPrefTit , TamSX3("E1_PREFIXO" )[ 1 ] ) + ;
	PadR( ::WsTituloErp:WsNumTit , TamSX3( "E1_NUM" )[ 1 ] ) + ;
	PadR( ::WsTituloErp:WsParcTit , TamSX3( "E1_PARCELA" )[ 1 ] ) + ;
	PadR( ::WsTituloErp:WsTipoTit , TamSX3( "E1_TIPO" )[ 1 ] ) } )

	// Dados do titulo a pagar
	SE2->( dbSetOrder( 1 ) )
	SE2->( MsSeek( ::WsTituloErpPag:WsFilTit + PadR( ::WsTituloErpPag:WsPrefTit , TamSX3("E2_PREFIXO" )[ 1 ] ) + ;
	PadR( ::WsTituloErpPag:WsNumTit , TamSX3( "E2_NUM" )[ 1 ] ) + ;
	PadR( ::WsTituloErpPag:WsParcTit , TamSX3( "E2_PARCELA" )[ 1 ] ) + ;
	PadR( ::WsTituloErpPag:WsTipoTit , TamSX3( "E2_TIPO" )[ 1 ] ) + ; 
	PadR( ::WsTituloErpPag:WsCodFor , TamSX3( "E2_FORNECE" )[ 1 ] ) + ;
	PadR( ::WsTituloErpPag:WsLojFor , TamSX3( "E2_LOJA" )[ 1 ] ) ) )

	AAdd( aAutoCab[12,2], { ::WsTituloErpPag:WsFilTit + PadR( ::WsTituloErpPag:WsPrefTit , TamSX3("E2_PREFIXO" )[ 1 ] ) + ;
	PadR( ::WsTituloErpPag:WsNumTit  , TamSX3( "E2_NUM" )[ 1 ] ) + ;
	PadR( ::WsTituloErpPag:WsParcTit , TamSX3( "E2_PARCELA" )[ 1 ] ) + ;
	PadR( ::WsTituloErpPag:WsTipoTit , TamSX3( "E2_TIPO" )[ 1 ] ) + ;
	PadR( ::WsTituloErpPag:WsCodFor  , TamSX3( "E2_FORNECE" )[ 1 ] ) + ;
	PadR( ::WsTituloErpPag:WsLojFor  , TamSX3( "E2_LOJA" )[ 1 ] ) } )

	
	MSExecAuto({|x,y,z| Fina450(x,y,z)}, nil , aAutoCab , 3 )
           
	If lMsErroAuto
    	_erro := "Erro: " + MostraErro() 
    	Conout(_erro)
    	::WsRetornoS := _erro
	Endif

cEmpAnt := _cEmpBkp
cFilAnt := _cFilBkp

RestArea(_aAreaSM0)
RestArea(_aArea)                      
ddatabase := dataAtual
//RESET ENVIRONMENT

Return .T.


/*/================================================================================================================================/*/
/*/{Protheus.doc} CompensacaoCR
Metodo da Classe WEBA01PA, responsável por compensar titulos de despesa (NF x PA)

@type 	 method
@author  IATAN
@since 	 20/11/2017
@version P12.1.23
@obs 	 Desenvolvimento FIEG
@return  Lógico, retorna verdadeiro.
@history 14/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 
/*/
/*/================================================================================================================================/*/

WsMethod CompensacaoCR WsReceive WsCEmp,WsCFil,WsLogin,WsSenha,WsRecnoNF,WsRecnoPA WsSend WsRetornoS WsService WEBA01PA

Local _lLogin	:= .T.

/*Variaveis responsáveis por tratar as filiais de inserção dos registros*/
Local _aArea	:= GetArea()                                              
Local _aAreaSM0	:= SM0->(GetArea())
Local _cEmpBkp	:= cEmpAnt
Local _cFilBkp	:= cFilAnt
Local _cFilExe 	:= WsCFil
//Local dataAtual := ddatabase

Local aAreaSE2  	:= SE2->(GetArea())
Local lContabiliza 	:= .F.
Local lAglutina    	:= .F.
Local lDigita    	:= .F.

Local aRecSE2 := {}
//A ROTINA AUTOMATICA FUNCIONA PARA UM TIPO DE COMPENSAÇÃO 1 -> N 
//MAS IREI TRABALHAR SEMPRE COM O TIPO 1 NF -> 1 PA AFIM DE TORNAR A CHAMADA DO 
//WEBSERVICE MAIS SIMLES. CASO HAJA A NECESSIDADE DE COMPENSAR MAIS DE UM TITULO, 
//EXECUTAR A CHAMADA DO WEBSERVICE MAIS DE UMA VEZ.
Local aRecPA := {} // Array contendo os Recnos dos titulos PA

/*FIM - Variaveis responsáveis por tratar as filiais de inserção dos registros*/
Private INCLUI	:= .F.                 
Private aAutoCab := {}
//Variável da Rotina Automática
Private lMsErroAuto := .F.

RPCSetType(3)                       

//COMANDO ABAIXO SENDO EXECUTADO POIS OS MOVIMENTOS ESTAVAM GERANDO CONTABILIZAÇÃO SEM ESTE COMANDO
PREPARE ENVIRONMENT EMPRESA WsCEmp FILIAL WsCFil USER WsLogin PASSWORD WsSenha

OpenSm0(cEmpAnt, .T.)
SM0->(DbSetOrder(01))
SM0->(DbGoTop())
SM0->(DbSeek(WsCEmp+WsCFil))
cFilAnt := _cFilExe

PswOrder(02) //Nome do Usuário
//Posionando no Usuário
If PswSeek( WsLogin, .T. )
	//A Variável é alterada para o Login conforme o cadastrado no Protheus.
	//Pois para a função do Prepare Environment é necessário dessa forma.
	WsLogin := AllTrim(PswRet()[01,02])
Else
	_lLogin := .F.
EndIf

//Validando a senha após posiciona no Usuário.
If !PswName( WsSenha )
	_lLogin := .F.
EndIf

//Caso não tenha passado pela validação de usuário e senha do Protheus.
If !_lLogin
	
	If EMPTY(::WsRetorno:WsMensagens)
		aADD( ::WsRetorno:WsMensagens, WSClassNew("StrMsgRet") )
		_nPMsg	:= Len( ::WsRetorno:WsMensagens )
		::WsRetorno:WsMensagens[_nPMsg]:WsCodMsg := -5
		::WsRetorno:WsMensagens[_nPMsg]:WsDScMsg := "Usuário ou Senha Inválido."
	EndIF
	
	RETURN .T.
	
EndIF

PERGUNTE("AFI340",.F.)

aAdd(aRecSE2, VAL(WsRecnoNF))
aAdd(aRecPA,  VAL(WsRecnoPA))

lMsErroAuto	:= .F.

MaIntBxCP(2,aRecSE2,,aRecPA,,{lContabiliza,lAglutina,lDigita,.F.,.F.,.F.},,,,)  
           
	If lMsErroAuto
    	_erro := "Erro: " + MostraErro() 
    	Conout(_erro)
    	::WsRetornoS := _erro
	Endif

cEmpAnt := _cEmpBkp
cFilAnt := _cFilBkp

SE2->(RestArea(aAreaSE2))
SM0->(RestArea(_aAreaSM0))
RestArea(_aArea)                      

//RESET ENVIRONMENT

Return .T.


/*/================================================================================================================================/*/
/*/{Protheus.doc} BaixarTituloPAG
Metodo da Classe WEBA01PA, responsável por BAIXAR UM TITULO DO TIPO "CONTAS A PAGAR"

@type 	 method
@author  IATAN
@since 	 20/11/2017
@version P12.1.23
@obs 	 Desenvolvimento FIEG
@return  Lógico, retorna verdadeiro.
@history 14/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 
/*/
/*/================================================================================================================================/*/

WsMethod BaixarTituloPAG WsReceive WsCEmp,WsCFil,WsLogin,WsSenha,WsTituloErpPag WsSend WsRetornoS WsService WEBA01PA

Local _lLogin	:= .T.
Local aVetor
Local _vencimento
Local _valor
Local _emissao        
Local _erro := ""
/*Variaveis responsáveis por tratar as filiais de inserção dos registros*/
Local _aArea	:= GetArea()                                              
Local _aAreaSM0	:= SM0->(GetArea())
Local _cEmpBkp	:= cEmpAnt
Local _cFilBkp	:= cFilAnt
Local _cFilExe := WsCFil
Local dataAtual := ddatabase
/*FIM - Variaveis responsáveis por tratar as filiais de inserção dos registros*/

Private INCLUI	:= .T.                 
//Variável da Rotina Automática
Private lMsErroAuto	:= .F.

RPCSetType(3)
//PREPARE ENVIRONMENT EMPRESA WsCEmp FILIAL WsCFil USER WsLogin PASSWORD WsSenha
SetModulo("SIGAFIN","FIN")

OpenSm0(cEmpAnt, .T.)
SM0->(DbSetOrder(01))
SM0->(DbGoTop())
SM0->(DbSeek(WsCEmp+WsCFil))
cFilAnt := _cFilExe

PswOrder(02) //Nome do Usuário
//Posionando no Usuário
If PswSeek( WsLogin, .T. )
	//A Variável é alterada para o Login conforme o cadastrado no Protheus.
	//Pois para a função do Prepare Environment é necessário dessa forma.
	WsLogin := AllTrim(PswRet()[01,02])
Else
	_lLogin := .F.
EndIf

//Validando a senha após posiciona no Usuário.
If !PswName( WsSenha )
	_lLogin := .F.
EndIf

//Caso não tenha passado pela validação de usuário e senha do Protheus.
If !_lLogin
	
	If EMPTY(::WsRetorno:WsMensagens)
		aADD( ::WsRetorno:WsMensagens, WSClassNew("StrMsgRet") )
		_nPMsg	:= Len( ::WsRetorno:WsMensagens )
		::WsRetorno:WsMensagens[_nPMsg]:WsCodMsg := -5
		::WsRetorno:WsMensagens[_nPMsg]:WsDScMsg := "Usuário ou Senha Inválido."
	EndIF
	
	RETURN .T.
	
EndIF

dbSelectArea("SE2")
SE2->(dbSetOrder(1))

ddatabase := CTOD(::WsTituloErpPag:WsEmissao)
                                                          
aVetor:={  {"E2_FILIAL"   ,WsTituloErpPag:WsFilTit                                       ,Nil},; 
           {"E2_PREFIXO"  ,PadR(::WsTituloErpPag:WsPrefTit,TamSX3("E2_PREFIXO")[1], ' ') ,Nil},; 
           {"E2_NUM"      ,PadR(::WsTituloErpPag:WsNumTit,TamSX3("E2_NUM")[1], ' ')      ,Nil},; 
           {"E2_PARCELA"  ,PadR(::WsTituloErpPag:WsParcTit,TamSX3("E2_PARCELA")[1], ' ') ,Nil},; 
           {"E2_TIPO"     ,PadR(::WsTituloErpPag:WsTipoTit,TamSX3("E2_TIPO")[1], ' ')    ,Nil},;          
           {"E2_FORNECE"  ,PadR(::WsTituloErpPag:WsCodFor,TamSX3("E2_FORNECE")[1], ' ')  ,Nil},; 
           {"E2_LOJA"     ,PadR(::WsTituloErpPag:WsLojFor,TamSX3("E2_LOJA")[1], ' ')     ,Nil},; 
           {"AUTMOTBX"    ,::WsTituloErpPag:WsMotBx                                      ,Nil},; 
           {"AUTBANCO"    ,PadR(::WsTituloErpPag:WsBanco,TamSX3("A6_COD")[1], ' ')       ,NIL},; 
           {"AUTAGENCIA"  ,PadR(::WsTituloErpPag:WsAgencia,TamSX3("A6_AGENCIA")[1], ' ') ,NIL},; 
           {"AUTCONTA"    ,PadR(::WsTituloErpPag:WsConta,TamSX3("A6_NUMCON")[1], ' ')    ,NIL},; 
           {"AUTDTBAIXA"  ,CTOD(::WsTituloErpPag:WsDtBx)                                 ,Nil},;          
           {"AUTDTCREDITO",CTOD(::WsTituloErpPag:WsDtCred)                               ,Nil},;          
           {"AUTHIST"     ,PadR(::WsTituloErpPag:WsHist,TamSX3("E2_HIST")[1], ' ')       ,Nil},; 
           {"AUTVLRPG"    ,Val(WsTituloErpPag:WsValor)  											  ,Nil}}

lMsErroAuto	:= .F.


MSExecAuto({|x,y| FINA080(x,y)},aVetor,3)      

	
	If lMsErroAuto
    	_erro := "Erro: " + MostraErro() 
    	::WsRetornoS := _erro
	Endif


cEmpAnt := _cEmpBkp
cFilAnt := _cFilBkp

RestArea(_aAreaSM0)
RestArea(_aArea)
ddatabase := dataAtual
//RESET ENVIRONMENT

Return .T.
