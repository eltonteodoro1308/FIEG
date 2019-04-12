#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSOLE.CH"
#INCLUDE "TOPCONN.CH"
#include "tbiconn.ch"
#INCLUDE "EICCONST.CH"
#INCLUDE "FILEIO.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ SIFINR09 ºAutor  ³Leonardo Soncin     º Data ³  11/01/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Impressao da Carta de Cobranca                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CNI                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function SIFINR09(aParam)

Local lAuto := Iif(Select("SM0")>0,.F.,.T.)
Local lRet  := .T.

If lAuto
	While lRet
		lRet := xIntWord(aParam)
	EndDo
Else
	xIntWord(aParam)
Endif

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ SIFINR09 ºAutor  ³Leonardo Soncin     º Data ³  11/01/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Impressao da Carta de Cobranca                  			  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CNI                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function xIntWord(aParam)
Local cTitulo		:= ""
Local cErro			:= ""
Local cSolucao		:= ""
Local aEmp  := ""
Local cEmp  := ""
Local cFil  := ""
Local cJob  		:= 'SIFINR09'
Local lOpen			:= .F.
Local aRecnoSM0		:= {}
Local lRet			:= .T.
Local lContinua		:= .T.
Local dData 		:= ""
DEFAULT aParam 		:= {}

Private cFileLog  	:= ""
Private cTexto 	  	:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a rotina foi chamada via menu ou schedule ...    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private lAuto := Iif(Select("SM0")>0,.F.,.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Prepara Environment ou abre tabelas ...                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lAuto
	//Tratamento de Empresa
	If ( lOpen := MyOpenSm0(.T.) )
		
		dbSelectArea( "SM0" )
		dbGoTop()
		
		While !SM0->( EOF() )
			// So adiciona no aRecnoSM0 se a empresa for diferente
			If aScan( aRecnoSM0, { |x| x[2] == SM0->M0_CODIGO } ) == 0
				aAdd( aRecnoSM0, { Recno(), SM0->M0_CODIGO } )
			EndIf
			SM0->( dbSkip() )
		EndDo
		
	Endif
	
	//aEmp  := IIF(Len(aParam)>0,aParam,{cEmpAnt,cEmpFil})
	//cEmp  := aEmp[1]
	//cFil  := aEmp[2]
	//RpcSetEnv( cEmp, cFil,,,'FIN')
	
	SM0->( dbGoTo( aRecnoSM0[1][1] ) )
	ConOut("Preparando Environment ... "+SM0->M0_CODIGO+SM0->M0_CODFIl+" - "+DTOC(Date()) + " - "+Time())
	
	RpcSetType( 3 )
	RpcSetEnv( SM0->M0_CODIGO, SM0->M0_CODFIL,/*User*/,/*Senha*/,'FIN')
	
	SM0->( dbCloseArea() )
	
EndIf

If lAuto
	ValidPerg("SIFI9A")
	Pergunte("SIFI9A", .F., Nil, Nil, Nil, .F.)    
	dData := GetMv("SI_ULTCAR")  //Data da Proxima execução
	If  dDataBase == dData .And. mv_par03 == Substr(time(),1,5) //Atualizar o MV no final.
 		If   !(dDatabase >= mv_par01 .And. dDatabase <= mv_par02)
		       lContinua := .F.
	    Endif      
	Else                                         
		lContinua:= .F.    
	Endif         
	
Endif
If lContinua         
		Private cPerg 		:= "SIFI9A"		
		PRIVATE cWord		:= ""//OLE_CreateLink()
		PRIVATE cPathDot	:= GetMV("SI_DIRDOT") //Diretorio do Arquivo Modelo
		PRIVATE cArqDot		:= GetMV("SI_DOTCAR") //Nome do Arquivo Modelo
		Private cDirDoc 	:= GetMV("SI_DIRCCOB")
		PRIVATE cCadastro 	:= OemToAnsi("Carta de Cobrança")
		Private cLote 		:= GetMV("SI_LOTECAR")
		
		If lAuto
			cWord:= ExecInClient(EIC_OLECREATELINK, { 'TMsOleWord97' } ) [1]
  			OLE_Initialize ( cWord )
		Else
			cWord		:= OLE_CreateLink()
 		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Incrementa Lote                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cLote := Soma1(cLote)
		
		OLE_SetProperty(cWord, oleWdVisible  ,.F. )
		OLE_SetProperty(cWord, oleWdPrintBack,.F. )
				
		If lAuto                            
			cPerg 		:= "SIFI9A"		
		Else	
			cPerg 		:= "SIFI09"		
		Endif	
		
		ValidPerg(cPerg)		     
		
		If lAuto
			Pergunte(cPerg, .F., Nil, Nil, Nil, .F.)
		Else
			If !Pergunte(cPerg,.T.)
				Return .T.
			Endif
		Endif
		
		If !File(AllTrim(cPathDot)+AllTrim(cArqDot)) //MSFILE
			
			cTitulo 	:= "Arquivo modelo não encontrado"
			cErro		:= "O arquivo modelo para impressão dos relatórios "  + Alltrim(cArqDot)
			cErro		+= " não foi encontrado no diretório " + Alltrim(cPathDot)
			cErro		+= ", indicado nos parametros da rotina."
			cSolucao	:= "Informe o diretório e o nome do arquivo "
			cSolucao	+= "corretamente e processe a rotina novamente."
			If !lAuto
				xMagHelpFis(cTitulo,cErro,cSolucao)
			Endif
			
			// Gera Arquivo de Log
			cTexto += Replicate( "-", 128 ) + CRLF
			ctexto += Replicate( " ", 128 ) + CRLF
			ctexto += "LOG DE GERAÇÃO DA CARTA DE COBRANÇA" + CRLF
			ctexto += Replicate( " ", 128 ) + CRLF
			ctexto += Replicate( "-", 128 ) + CRLF
			ctexto += " DataBase...........: " + DtoC( dDataBase )  + CRLF
			ctexto += " Data / Hora Inicio.: " + DtoC( Date() )  + " / " + Time()  + CRLF
			ctexto += cErro	+ CRLF
			cTexto += " Data / Hora Final.: " + DtoC( Date() ) + " / " + Time()  + CRLF
			cTexto += Replicate( "-", 128 ) + CRLF
			cFileLog := AllTrim(cLote)+".LOG"
			MakeDir( cDirDoc+cLote )
			MemoWrite( AllTrim(cDirDoc+cLote)+"\"+cFileLog, cTexto )
			
			Return .T.
		Endif
		
		If (cWord < "0")
			cTitulo 	:= "MS-Word não localizado"
			cErro		:= "O programa MS-Word não está instalado nesta máquina. "
			cErro		+= "Apenas com a existência deste programa, é possível "
			cErro		+= "efetuar a impressão do relatório."
			cSolucao	:= "Instale o MS-Word nesta máquina ou efetue a impressão "
			cSolucao	+= "em outra máquina que possua o programa instalado."
			If !lAuto
				xMagHelpFis(cTitulo,cErro,cSolucao)
			Endif
			
			// Gera Arquivo de Log
			cTexto += Replicate( "-", 128 ) + CRLF
			ctexto += Replicate( " ", 128 ) + CRLF
			ctexto += "LOG DE GERAÇÃO DA CARTA DE COBRANÇA" + CRLF
			ctexto += Replicate( " ", 128 ) + CRLF
			ctexto += Replicate( "-", 128 ) + CRLF
			ctexto += " DataBase...........: " + DtoC( dDataBase )  + CRLF
			ctexto += " Data / Hora Inicio.: " + DtoC( Date() )  + " / " + Time()  + CRLF
			ctexto += cErro	+ CRLF
			cTexto += " Data / Hora Final.: " + DtoC( Date() ) + " / " + Time()  + CRLF
			cTexto += Replicate( "-", 128 ) + CRLF
			cFileLog := AllTrim(cLote)+".LOG"
			MakeDir( cDirDoc+cLote )
			MemoWrite( AllTrim(cDirDoc+cLote)+"\"+cFileLog, cTexto )
			
			Return .T.
		Endif
		
		
		If lAuto	
			If lOpen		
				For nI := 1 To Len( aRecnoSM0 )			
					If !( lOpen := MyOpenSm0(.T.) )
						Exit
					EndIf
					
					SM0->( dbGoTo( aRecnoSM0[nI][1] ) )
					
					RpcSetType( 3 )
					RpcSetEnv( SM0->M0_CODIGO, SM0->M0_CODFIL,,,'FIN')
					
					lRet := xProcImp()
					                                
					RpcClearEnv()                           
					
				Next nI		
			Endif	
		Else
			
			lRet := xProcImp()
			
		Endif
Endif        //Ana


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Reset no Environment ...                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lAuto
	RpcClearEnv()
EndIF

If lAuto
	ConOut("FIM")
Endif

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ xProcImp	º Autor ³ Leonardo Soncin    º Data ³  04/01/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Importacao de Dados                                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Especifico - CNI                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function xProcImp()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local oProcess  := NIL

If lAuto
	xGerImp( Nil,oProcess)
Else
	oProcess := MsNewProcess():New( { | lEnd | xGerImp( @lEnd,oProcess) }, 'Processando', 'Aguarde, processando...', .F. )
	oProcess:Activate()
Endif

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ xGerImp  ³ Autor ³ Leonardo Soncin       ³ Data ³10/01/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de Geracao e Impressao do WORD                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 = Alias do arquivo                                    ³±±
±±³          ³ExpN1 = Numero do registro                                  ³±±
±±³          ³ExpN2 = Numero da opcao selecionada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function xGerImp(lEnd,oProcess)

Local cQuery 	:= ""
Local cAliasTMP := GetNextAlias()
Local cAliasTRB := GetNextAlias()
Local cAliasSZP := GetNextAlias()
Local cNomArqTrb:= ""
Local nTotRegs 	:= 0
Local nProcRegs := 0
Local aEstrut 	:= SE1->(dbStruct())
Local nI
Local lRet		:= .T.

Local nCountC   := 0
Local nCountT   := 0
Local cNomeDoc	:= ""

//--- Objetos da Dialog
Local oDlg
Local oChk
Local oInv
Local oMark
Local nOpc := 0

//--- Parametros para Impressao                 
//-- Os parametros abaixo serão compartilhados por empresa + unidade de negocio.
//Local cCargo 	:= GetNewPar("SI_CARGO","")         Comentado por Ana - variavel nao usada nesta rotina.
Local cContato 	:= ""
//Local cContato 	:= GetNewPar("SI_CONTATO","")        Comentado por Ana
Local cEmail 	:= ""
//Local cEmail 	:= GetNewPar("SI_EMAIL","")  Comentado por Ana
Local cTel	 	:= ""
//Local cTel	 	:= GetNewPar("SI_TELEFON","") Comentado por Ana

//--- MarkBrowse
Local aCampos	:= {}
Private lInverte:= .F.
Private cMarca  := GetMark()
Private lTodos  := .T.
Private lChang  := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Campos visualizados no MarkBrowse ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ       
// Ana incluidas as pictures nos campos.
aAdd( aCampos, { "E1_OK"			,, "" 					,PesqPict("SE1","E1_OK"    			,2) } ) 
aAdd( aCampos, { "E1_FILIAL"		,, "Filial"			,PesqPict("SE1","E1_FILIAL"			,8) }	)
aAdd( aCampos, { "E1_PREFIXO"	,, "Prefixo" 		,PesqPict("SE1","E1_PREFIXO"		,3) } )
aAdd( aCampos, { "E1_NUM"	 		,, "Numero"		,PesqPict("SE1","E1_NUM"				,9) } )
aAdd( aCampos, { "E1_PARCELA"	,, "Parcela"		,PesqPict("SE1","E1_PARCELA"		,3) } )
aAdd( aCampos, { "E1_TIPO"			,, "Tipo"			 	,PesqPict("SE1","E1_TIPO"				,3) } )    	
aAdd( aCampos, { "E1_NATUREZ"	,, "Natureza" 		,PesqPict("SE1","E1_NATUREZ"	  ,10) } )
aAdd( aCampos, { "E1_CLIENTE"	,, "Cliente" 		,PesqPict("SE1","E1_CLIENTE"		,9) } )
aAdd( aCampos, { "E1_NOMCLI"	,, "Descrição" 	,PesqPict("SE1","E1_NOMCLI"	  ,20) } )
aAdd( aCampos, { "E1_LOJA"			,, "Loja" 			,PesqPict("SE1","E1_LOJA"			,4) } )
aAdd( aCampos, { "E1_VALOR"		,, "Valor" 			,PesqPict("SE1","E1_VALOR"		   ,17) } )
aAdd( aCampos, { "E1_SALDO"		,, "Saldo" 			,PesqPict("SE1","E1_SALDO"		    ,17) } )
aAdd( aCampos, { "E1_VENCTO"	,, "Vencimento" ,PesqPict("SE1","E1_VENCTO"		,8) } )
aAdd( aCampos, { "E1_VENCREA"	,, "Vencimento Real" ,PesqPict("SE1","E1_VENCREA",8) } )
aAdd( aCampos, { "E1_ACRESC"	,, "Acrescimo" ,PesqPict("SE1","E1_ACRESC"			,17) } )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria o arquivo temporario ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cNomArqTRB := CriaTrab( aEstrut, .T. )
dbUseArea( .T.,,cNomArqTRB, cAliasTRB, .F., .F. )

IndRegua( cAliasTRB, cNomArqTRB, "E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA",,,"Criando Indice, aguarde..." )
dbClearIndex()
dbSetIndex( cNomArqTRB + OrdBagExt() )

If (cWord >= "0")
	OLE_CloseLink(cWord) //fecha o Link com o Word
	If lAuto
		cWord:= ExecInClient(EIC_OLECREATELINK, { 'TMsOleWord97' } ) [1]
		OLE_Initialize ( cWord )
	Else
		cWord:= OLE_CreateLink()
	Endif
	
	OLE_NewFile(cWord,cPathDot+cArqDot)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Funcao que faz o Word aparecer na Area de Transferencia do Windows,     ³
	//³sendo que para habilitar/desabilitar e so colocar .T. ou .F.            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	OLE_SetProperty(cWord, oleWdVisible  ,.F. )
	OLE_SetProperty(cWord, oleWdPrintBack,.F. )
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Variaves para a impressao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (cWord >= "0")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Informacoes sobre a empresa que esta emitindo o termo ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	OLE_SetDocumentVar(cWord, "c_DiaMesAno"	, Alltrim(Str(Day(dDataBase)))+" de "+AllTrim(MesExtenso(Month(dDataBase)))+" de "+Alltrim(Str(Year(dDataBase))))
Endif

// Query dos Titulos em Aberto
cQuery :=  "SELECT * "
cQuery +=  "FROM "+RetSqlName("SE1")
cQuery +=  " WHERE E1_FILIAL BETWEEN '"+MV_PAR22+"' AND '"+MV_PAR23+"' AND "
cQuery +=  "E1_PREFIXO BETWEEN 	'"+MV_PAR04+"' AND '"+MV_PAR05+"' AND "
cQuery +=  "E1_NUM BETWEEN 		'"+MV_PAR06+"' AND '"+MV_PAR07+"' AND "
cQuery +=  "E1_NATUREZ BETWEEN 	'"+MV_PAR08+"' AND '"+MV_PAR09+"' AND "
cQuery +=  "E1_VENCREA BETWEEN 	'"+Dtos(MV_PAR10)+"' AND '"+Dtos(MV_PAR11)+"' AND "
cQuery +=  "E1_VENCREA  < '"  + DtoS(ddatabase) +"' AND "  //Ana      incluida essa linha
cQuery +=  "E1_CLIENTE BETWEEN 	'"+MV_PAR12+"' AND '"+MV_PAR13+"' AND "
cQuery +=  "E1_LOJA BETWEEN 	'"+MV_PAR14+"' AND '"+MV_PAR15+"' AND "
cQuery +=  "(E1_CREDIT BETWEEN 	'"+MV_PAR16+"' AND '"+MV_PAR17+"' OR "           //Ana    substituido AND por OR
cQuery +=  "E1_DEBITO BETWEEN 	'"+MV_PAR16+"' AND '"+MV_PAR17+"') AND "
cQuery +=  "(E1_CCD BETWEEN 		'"+MV_PAR18+"' AND '"+MV_PAR19+"' OR "           //Ana    substituido AND por OR
cQuery +=  "E1_CCC BETWEEN 		'"+MV_PAR18+"' AND '"+MV_PAR19+"') AND "
cQuery +=  "(E1_ITEMD BETWEEN 	'"+MV_PAR20+"' AND '"+MV_PAR21+"' OR "         //Ana    substituido AND por OR
cQuery +=  "E1_ITEMC BETWEEN 	'"+MV_PAR20+"' AND '"+MV_PAR21+"') AND "
cQuery +=  "E1_SALDO > 0 AND "
cQuery +=  "E1_SITUACA = '0' OR E1_SITUACA = '1' AND "
cQuery +=  "D_E_L_E_T_ = '' "
cQuery := ChangeQuery(cQuery)

If Select(cAliasTMP) > 0
	dbSelectArea(cAliasTMP)
	dbCloseArea()
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTMP,.T.,.F.)

For nCntFor := 1 To Len(aEstrut)
	If ( aEstrut[nCntFor,2]<>"C" )
		TcSetField(cAliasTMP,aEstrut[nCntFor,1],aEstrut[nCntFor,2],aEstrut[nCntFor,3],aEstrut[nCntFor,4])
	EndIf
Next nCntFor

DbSelectArea(cAliasTMP)
dbGotop()

If !Eof(cAliasTMP)
	
	dbEval( {|x| nTotRegs++ },,{|| (cAliasTMP)->(!EOF())})
	If !lAuto
		oProcess:SetRegua1(nTotRegs)
		oProcess:IncRegua1("Iniciando processamento...")
		oProcess:SetRegua2(nTotRegs)
//		oProcess:IncRegua2("Ordem de producao:")
		oProcess:IncRegua2("Carta de Cobrança:") //Ana
	Endif
	
	dbSelectArea(cAliasTMP)
	dbGotop()
	
	// Cria TRB a partir do resultado da Query
	While !Eof(cAliasTMP)
		
		nProcRegs++
		
		If !lAuto
			oProcess:IncRegua1("Processando item: "+CValToChar(nProcRegs)+" / "+CValToChar(nTotRegs))
		Endif
		
		(cAliasTRB)->(DbAppend())
//		For nI := 1 To nTotRegs  --Comentado por Ana 
		For nI := 1 To Len(aEstrut)                                   //Ana
		If  (cAliasTRB)->(FieldPos((cAliasTMP)->( FieldName( ni )))) > 0
				(cAliasTRB)->(FieldPut(nI ,;
				(cAliasTMP)->(FieldGet( ;
				(cAliasTMP)->(FieldPos( ;
				(cAliasTRB)->(FieldName( ni ))))))))
			EndIf
		Next
		(cAliasTMP)->(DbSkip())
	EndDo
	(cAliasTMP)->(dbCloseArea())
Endif

// MarkBrowse
dbSelectArea(cAliasTRB)
dbGotop()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a Tela com MsSelect e Objetos de Check Box ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lAuto
	DEFINE FONT oFont NAME "Mono AS" SIZE 8,15 BOLD
	
	DEFINE MSDIALOG oDlg TITLE "Seleção de Títulos em Aberto" From 3,0 To 40,120
	
	oMark := MsSelect():New(cAliasTRB,"E1_OK",,aCampos, @lInverte, @cMarca, { 30, 0, 260, 477 } )
	
	oMark:oBrowse:lhasMark := .T.
	oMark:oBrowse:bAllMark := {|| U_SIF10Inv( oMark,cAliasTRB ) }  // Na verdade, esse comando esta desabilitado pela instrucao de cima
	
	@ 265,010 CHECKBOX oChk VAR lTodos PROMPT "Marca/Desmarca Todos" SIZE 80,7 COLOR CLR_HBLUE OF oDlg PIXEL ON CLICK U_SIF10Inv( oMark,cAliasTRB ); lTodos := .F.; oChk:oFont := oDlg:oFont
	@ 265,110 CHECKBOX oInv VAR lChang PROMPT "Inverte Seleção" SIZE 80,7 COLOR CLR_HBLUE OF oDlg PIXEL ON CLICK U_SIF10Chg( oMark,cAliasTRB ); lChang := .F.; oChk:oFont := oDlg:oFont
	
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg, {||( nOpc := 1, oDlg:End() )}, {||(nOpc := 0, oDlg:End())},,) CENTERED
	
	DeleteObject( oMark )
	DeleteObject( oDlg )
	DeleteObject( oChk )
	DeleteObject( oInv )
	
Else
	nOpc := 1
Endif

If nOpc == 1
	
	Begin Transaction
	
	//Inicio do Log
	cTexto += Replicate( "-", 128 ) + CRLF
	ctexto += Replicate( " ", 128 ) + CRLF
	ctexto += "LOG DE GERAÇÃO DA CARTA DE COBRANÇA" + CRLF
	ctexto += Replicate( " ", 128 ) + CRLF
	ctexto += Replicate( "-", 128 ) + CRLF
	ctexto += " DataBase...........: " + DtoC( dDataBase )  + CRLF
	ctexto += " Data / Hora Inicio.: " + DtoC( Date() )  + " / " + Time()  + CRLF
	
	dbSelectArea(cAliasTRB)
	dbGoTop()
	
	While !EOF(cAliasTRB)
		
		If (cAliasTRB)->E1_OK == cMarca .or. lAuto
		 //Ana se estiver logado em outra empresa, eu posso visualizar os registros e selecionar, consequentemente nao pode buscar os dados da empresa logada.
			cContato 	:= SuperGetMv("SI_CONTATO",.F.,,Substr((cAliasTRB)->(E1_FILIAL),1,4))            
			cEmail 		:= SuperGetMv("SI_EMAIL",.F.,,Substr((cAliasTRB)->(E1_FILIAL),1,4))                    
			cTel	 	:= SuperGetMv("SI_TELEFON",.F.,,Substr((cAliasTRB)->(E1_FILIAL),1,4))                 
			If (cWord >= "0")
				MakeDir( AllTrim(cDirDoc+cLote))
				If MV_PAR26 == 1 // Impressao trata fila
					//Trata fila de Impressao
					If !xExistFila((cAliasTRB)->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO))
						xCriaFila(cAliasTrb)
					Endif
					
					//Pesquisa fila de Impressao
					cQuery :=  "SELECT ZP_DTSCHED, R_E_C_N_O_ AS NREG"
					cQuery +=  "FROM "+RetSqlName("SZP")
					cQuery +=  " WHERE ZP_FILIAL = '"+(cAliasTRB)->E1_FILIAL+"' AND "
					cQuery +=  "ZP_PREFIXO = '"+(cAliasTRB)->E1_PREFIXO+"' AND "
					cQuery +=  "ZP_NUMERO  = '"+(cAliasTRB)->E1_NUM+"' AND "
					cQuery +=  "ZP_PARCELA  = '"+(cAliasTRB)->E1_PARCELA+"' AND "
					cQuery +=  "ZP_TIPO  = '"+(cAliasTRB)->E1_TIPO+"' AND "
					cQuery +=  "ZP_DTSCHED  <= '"+Dtos(dDataBase)+"' AND "
					cQuery +=  "ZP_DTIMPRE  = '' AND "
					cQuery +=  "D_E_L_E_T_ = '' "
					cQuery := ChangeQuery(cQuery)
					
					If Select(cAliasSZP) > 0
						dbSelectArea(cAliasSZP)
						dbCloseArea()
					Endif
					
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSZP,.T.,.F.)
					
					dbSelectArea(cAliasSZP)
					dbGotop()
					
					While !Eof (cAliasSZP)
						
						If !lAuto
							oProcess:IncRegua2()
						Endif
						
						// Atualiza Lote dos Titulos         
						dbSelectArea("SE1")
						dbSetOrder(1)
						dbSeek((cAliasTRB)->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO))
						RecLock("SE1",.F.)
						SE1->E1_XLOTCAR := cLote
						MsUnLock()
						
						//Informações do contato
						OLE_SetDocumentVar(cWord, "c_Contato"	, cContato  )						    
						OLE_SetDocumentVar(cWord, "c_Email"		, cEmail  )
						OLE_SetDocumentVar(cWord, "c_Telefone"	, cTel  )
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Informacoes sobre a emissao da nota³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						OLE_SetDocumentVar(cWord, "c_Num"		, Alltrim((cAliasTRB)->E1_NUM))
						OLE_SetDocumentVar(cWord, "c_Ccusto"	, Posicione("CTT",1,xFilial("CTT")+SE1->E1_CCC,"CTT_DESC01") )
						OLE_SetDocumentVar(cWord, "d_VencTit"	, Dtoc((cAliasTRB)->E1_VENCREA) )
//						OLE_SetDocumentVar(cWord, "n_Saldo"		, (cAliasTRB)->E1_SALDO )                                            
						OLE_SetDocumentVar(cWord, "n_Saldo"		, Transform((cAliasTRB)->E1_SALDO,"@E 999,999,999.99") ) //Ana
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Informacoes sobre o cliente        ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						dbSelectArea("SA1")
						dbSetOrder(1)
						dbSeek(xFilial("SA1")+(cAliasTRB)->(E1_CLIENTE+E1_LOJA))
						
						OLE_SetDocumentVar(cWord, "c_NomeCliente"	, Alltrim(SA1->A1_NOME))
						OLE_SetDocumentVar(cWord, "c_EndCliente"	, AllTrim(SA1->A1_END)) 
						OLE_SetDocumentVar(cWord, "c_BaiCliente"	, AllTrim(SA1->A1_BAIRRO))
						OLE_SetDocumentVar(cWord, "c_CEPCliente"	, AllTrim(SA1->A1_CEP)) 
						OLE_SetDocumentVar(cWord, "c_TelCliente"	, AllTrim(SA1->A1_TEL))
						
						If SA1->A1_PESSOA=='F'
							OLE_SetDocumentVar(cWord, "c_CpfCnpjCli"	, Transform(SA1->A1_CGC,"@R 999.999.999-99")) //Ana Correção da Picture				 
						Else	
							OLE_SetDocumentVar(cWord, "c_CpfCnpjCli"	, Transform(SA1->A1_CGC,"@R 99.999.999/9999-99")) //Ana Correção da Picture
						Endif			

						OLE_SetDocumentVar(cWord, "c_CidadeCliente"	, AllTrim(SA1->A1_MUN))
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Funcao que atualiza os campos da memoria para o Documento, utilizada logo apos a   ³
						//³funcao OLE_SetDocumentVar().														  ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						OLE_UpdateFields(cWord)
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Salva os Termos Gerados                   ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						cNomeDoc := "CARTA_"+Alltrim(SA1->A1_COD)+"_"+Alltrim(SA1->A1_LOJA)+"_"+Alltrim((cAliasTRB)->E1_PREFIXO)+"_"+Alltrim((cAliasTRB)->E1_NUM)+"_"+Alltrim((cAliasTRB)->E1_PARCELA)+"_"+Alltrim((cAliasTRB)->E1_TIPO)+".DOC"
						//MakeDir( AllTrim(cDirDoc+cLote))
						OLE_SaveAsFile(cWord,AllTrim(cDirDoc+cLote)+"\"+cNomeDoc) 
						nCountC++
						
						//Flaga resgistro na fila de Impessão
						dbSelectArea("SZP")
						dbGoto((cAliasSZP)->NREG)
						RecLock("SZP",.F.)
						SZP->ZP_DTIMPRE := dDataBase
						MsUnLock()
						
						dbSelectArea(cAliasSZP)
						dbSkip()
					Enddo  
					
				Else // Se for re-Impressao nao trata fila
					If !lAuto              
						//Pesquisa fila de Impressao
						cQuery :=  "SELECT DISTINCT ZP_FILIAL,ZP_PREFIXO, ZP_NUMERO, ZP_PARCELA, ZP_TIPO, ZP_SEQ AS NREG"
						cQuery +=  "FROM "+RetSqlName("SZP")
						cQuery +=  " WHERE ZP_FILIAL = '"+(cAliasTRB)->E1_FILIAL+"' AND "
						cQuery +=  "ZP_PREFIXO = '"+(cAliasTRB)->E1_PREFIXO+"' AND "
						cQuery +=  "ZP_NUMERO  = '"+(cAliasTRB)->E1_NUM+"' AND "
						cQuery +=  "ZP_PARCELA  = '"+(cAliasTRB)->E1_PARCELA+"' AND "
						cQuery +=  "ZP_TIPO  = '"+(cAliasTRB)->E1_TIPO+"' AND "
						cQuery +=  "D_E_L_E_T_ = '' "
						cQuery := ChangeQuery(cQuery) 
						
						If Select(cAliasSZP) > 0
							dbSelectArea(cAliasSZP)
							dbCloseArea()
						Endif
						
						dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSZP,.T.,.F.)
						
						dbSelectArea(cAliasSZP)
						dbGotop()
						
						While !Eof (cAliasSZP)
					
							// Atualiza Lote dos Titulos
							dbSelectArea("SE1")
							dbSetOrder(1)
							dbSeek((cAliasTRB)->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO))
							RecLock("SE1",.F.)
							SE1->E1_XLOTCAR := cLote
							MsUnLock()
							  
							OLE_SetDocumentVar(cWord, "c_Contato"	, cContato  )
							OLE_SetDocumentVar(cWord, "c_Email"		, cEmail  )
							OLE_SetDocumentVar(cWord, "c_Telefone"	, cTel  )
		
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Informacoes sobre a emissao da nota³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							OLE_SetDocumentVar(cWord, "c_Num"		, Alltrim((cAliasTRB)->E1_NUM))
							OLE_SetDocumentVar(cWord, "c_Ccusto"	, Posicione("CTT",1,xFilial("CTT")+SE1->E1_CCC,"CTT_DESC01") )
							OLE_SetDocumentVar(cWord, "d_VencTit"	, Dtoc((cAliasTRB)->E1_VENCREA) )
							OLE_SetDocumentVar(cWord, "n_Saldo"		, Transform((cAliasTRB)->E1_SALDO,"@E 999,999,999.99") )
		
							
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Informacoes sobre o cliente        ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							dbSelectArea("SA1")
							dbSetOrder(1)
							dbSeek(xFilial("SA1")+(cAliasTRB)->(E1_CLIENTE+E1_LOJA))
							
							OLE_SetDocumentVar(cWord, "c_NomeCliente"	, Alltrim(SA1->A1_NOME))
							OLE_SetDocumentVar(cWord, "c_EndCliente"	, AllTrim(SA1->A1_END))  
							OLE_SetDocumentVar(cWord, "c_BaiCliente"	, AllTrim(SA1->A1_BAIRRO))
							OLE_SetDocumentVar(cWord, "c_CEPCliente"	, AllTrim(SA1->A1_CEP))							
							OLE_SetDocumentVar(cWord, "c_TelCliente"	, AllTrim(SA1->A1_TEL))    
						
							If SA1->A1_PESSOA=='F'
								OLE_SetDocumentVar(cWord, "c_CpfCnpjCli"	, Transform(SA1->A1_CGC,"@R 999.999.999-99")) //Ana Correção da Picture				 
							Else	
								OLE_SetDocumentVar(cWord, "c_CpfCnpjCli"	, Transform(SA1->A1_CGC,"@R 99.999.999/9999-99")) //Ana Correção da Picture
							Endif			
		
							OLE_SetDocumentVar(cWord, "c_CidadeCliente"	, AllTrim(SA1->A1_MUN))
							
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Funcao que atualiza os campos da memoria para o Documento, utilizada logo apos a   ³
							//³funcao OLE_SetDocumentVar().														  ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							OLE_UpdateFields(cWord)
							
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Salva os Termos Gerados                   ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							cNomeDoc := "CARTA_"+Alltrim(SA1->A1_COD)+"_"+Alltrim(SA1->A1_LOJA)+"_"+Alltrim((cAliasTRB)->E1_PREFIXO)+"_"+Alltrim((cAliasTRB)->E1_NUM)+"_"+Alltrim((cAliasTRB)->E1_PARCELA)+"_"+Alltrim((cAliasTRB)->E1_TIPO)+".DOC"
							//MakeDir( AllTrim(cDirDoc+cLote))
							OLE_SaveAsFile(cWord,AllTrim(cDirDoc+cLote)+"\"+cNomeDoc)
							nCountC++
							dbSelectArea(cAliasSZP)
							dbSkip()
						Enddo  

					Endif	 //Fim !lAuto
				Endif  // Fim If Impressao 
			Endif
			nCountT++
		Endif
		
		dbSelectArea(cAliasTRB)
		dbSkip()
		
	Enddo
	
	//Atualiza SI_LOTECAR com o Ultimo Lote Utilizado
	PutMV('SI_LOTECAR',cLote)
	If lAuto
		PutMV('SI_ULTCAR',ddatabase+1) //Ana: Atualiza o parametro com a data da próxima execução
	Endif	
	
	// Gera Arquivo de Log
	cTexto += " Nr. Lote: " + Alltrim(cLote) + CRLF
	cTexto += " Total de Registros: " + Alltrim(Str(nCountT)) + CRLF
	cTexto += " Total de Cartas Geradas: " + Alltrim(Str(nCountC)) + CRLF
	cTexto += " Data / Hora Final.: " + DtoC( Date() ) + " / " + Time()  + CRLF
	cTexto += Replicate( "-", 128 ) + CRLF
	cFileLog := AllTrim(cLote)+".LOG"
	MemoWrite( AllTrim(cDirDoc+cLote)+"\"+cFileLog, cTexto )
	
	End Transaction
Endif

If (cWord >= "0")
	OLE_CloseLink(cWord) //fecha o Link com o Word
Endif

If Select(cAliasTRB) != 0
	dbSelectArea(cAliasTRB)
	dbCloseArea()
	FErase(cNomArqTrb+GetDBExtension())
	FErase(cNomArqTrb+OrdBagExt())
Endif

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ ValidPerg³ Autor ³ Wagner Gomes          ³ Data ³ 10/12/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria as Perguntas para Fatura para locacao de Bens Moveis  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico Construtora OAS Ltda                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ValidPerg(cPerg)

Local _sAlias := Alias()
Local aRegs := {}
Local i,j

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)
cPerg := Alltrim(cPerg)
//
aHelpPor := {}
aHelpEsp := {}
aHelpEng := {}
	
Aadd(aHelpPor,"Faixa de data inicial para execução do" ) 
Aadd(aHelpPor,"Job." )

PutSX1Help("P." + cPerg + "01.",aHelpPor,aHelpEng,aHelpEsp)	   

aHelpPor := {}
	
Aadd(aHelpPor,"Faixa de data final para execução do Job" ) 
	
PutSX1Help("P." + cPerg + "02.",aHelpPor,aHelpEng,aHelpEsp,.T.)
	
aHelpPor := {}
	
Aadd(aHelpPor,"Horario de execução do Job" ) 
	
PutSX1Help("P." + cPerg + "03.",aHelpPor,aHelpEng,aHelpEsp,.T.)
           
//

aHelpPor := {}
aHelpEsp := {}
aHelpEng := {}
	
AHelpPor := {"Codigo da faixa Inicio do Prefixo",; 
"do Titulo." }        

PutSX1Help("P." + cPerg + "04.",aHelpPor,aHelpEng,aHelpEsp)	   

aHelpPor := {}
	
Aadd(aHelpPor,"Codigo da faixa Fim do Prefixo" ) 
Aadd(aHelpPor,"do Titulo." )
	
PutSX1Help("P." + cPerg + "05.",aHelpPor,aHelpEng,aHelpEsp,.T.)
	
aHelpPor := {}
	
Aadd(aHelpPor,"Codigo da faixa Inicio do Numero" ) 
Aadd(aHelpPor,"do Titulo." )
	
PutSX1Help("P." + cPerg + "06.",aHelpPor,aHelpEng,aHelpEsp,.T.)
	
aHelpPor := {}
	
Aadd(aHelpPor,"Codigo da faixa fim do Numero" ) 
Aadd(aHelpPor,"do Titulo." )
	
PutSX1Help("P." + cPerg + "07.",aHelpPor,aHelpEng,aHelpEsp,.T.)

aHelpPor := {}
	
Aadd(aHelpPor,"Codigo da faixa Inicio da Natureza" ) 
Aadd(aHelpPor,"financeira do Titulo." )
	
PutSX1Help("P." + cPerg + "08.",aHelpPor,aHelpEng,aHelpEsp,.T.)

aHelpPor := {}
	
Aadd(aHelpPor,"Codigo da faixa Fim da Natureza" ) 
Aadd(aHelpPor,"financeira do Titulo." )
	
PutSX1Help("P." + cPerg + "09.",aHelpPor,aHelpEng,aHelpEsp,.T.)
	
aHelpPor := {}
	
Aadd(aHelpPor,"Data Inicio da faixa de vencimento" ) 
Aadd(aHelpPor,"real do Titulo." )
	
PutSX1Help("P." + cPerg + "10.",aHelpPor,aHelpEng,aHelpEsp,.T.)

aHelpPor := {}
	
Aadd(aHelpPor,"Data Fim da faixa de vencimento" ) 
Aadd(aHelpPor,"real do Titulo." )
	
PutSX1Help("P." + cPerg + "11.",aHelpPor,aHelpEng,aHelpEsp,.T.)

aHelpPor := {}
	
Aadd(aHelpPor,"Codigo Inicio da faixa de cliente" ) 
Aadd(aHelpPor,"do Titulo." )
	
PutSX1Help("P." + cPerg + "12.",aHelpPor,aHelpEng,aHelpEsp,.T.)

aHelpPor := {}
	
Aadd(aHelpPor,"Codigo Inicio da faixa de cliente" ) 
Aadd(aHelpPor,"do Titulo." )
	
PutSX1Help("P." + cPerg + "13.",aHelpPor,aHelpEng,aHelpEsp,.T.)

aHelpPor := {}
	
Aadd(aHelpPor,"Codigo Inicio da faixa da loja do" ) 
Aadd(aHelpPor,"Cliente do Titulo." )
	
PutSX1Help("P." + cPerg + "14.",aHelpPor,aHelpEng,aHelpEsp,.T.)

aHelpPor := {}
	
Aadd(aHelpPor,"Codigo Fim da faixa da loja do" ) 
Aadd(aHelpPor,"Cliente do Titulo." )
	
PutSX1Help("P." + cPerg + "15.",aHelpPor,aHelpEng,aHelpEsp,.T.)

aHelpPor := {}
	
Aadd(aHelpPor,"Codigo Inicio da faixa de conta" ) 
Aadd(aHelpPor,"contabil a ser considerada." )
	
PutSX1Help("P." + cPerg + "16.",aHelpPor,aHelpEng,aHelpEsp,.T.)

aHelpPor := {}
	
Aadd(aHelpPor,"Codigo Fim da faixa de conta" ) 
Aadd(aHelpPor,"contabil a ser considerada." )
	
PutSX1Help("P." + cPerg + "17.",aHelpPor,aHelpEng,aHelpEsp,.T.)

aHelpPor := {}
	
Aadd(aHelpPor,"Codigo Inicio da faixa de centro" ) 
Aadd(aHelpPor,"de custo a ser considerado." )
	
PutSX1Help("P." + cPerg + "18.",aHelpPor,aHelpEng,aHelpEsp,.T.)

aHelpPor := {}
	
Aadd(aHelpPor,"Codigo Fim da faixa de centro" ) 
Aadd(aHelpPor,"de custo a ser considerado." )
	
PutSX1Help("P." + cPerg + "19.",aHelpPor,aHelpEng,aHelpEsp,.T.)

aHelpPor := {}
	
Aadd(aHelpPor,"Codigo Inicio da faixa de Item" ) 
Aadd(aHelpPor,"contabil a ser considerado." )
	
PutSX1Help("P." + cPerg + "20.",aHelpPor,aHelpEng,aHelpEsp,.T.)

aHelpPor := {}
	
Aadd(aHelpPor,"Codigo Fim da faixa de Item" ) 
Aadd(aHelpPor,"contabil a ser considerado." )
	
PutSX1Help("P." + cPerg + "21.",aHelpPor,aHelpEng,aHelpEsp,.T.)

aHelpPor := {}
	
Aadd(aHelpPor,"Codigo Inicio da faixa de Filial" ) 
Aadd(aHelpPor,"2 dígitos para empresa" )
Aadd(aHelpPor,"2 dígitos para Unidade de Negócios" )
Aadd(aHelpPor,"4 dígitos para Filial" )
	
PutSX1Help("P." + cPerg + "22.",aHelpPor,aHelpEng,aHelpEsp,.T.)

aHelpPor := {}
	
Aadd(aHelpPor,"Codigo Fim da faixa de Filial" ) 
Aadd(aHelpPor,"2 dígitos para empresa" )
Aadd(aHelpPor,"2 dígitos para Unidade de Negócios" )
Aadd(aHelpPor,"4 dígitos para Filial" )

PutSX1Help("P." + cPerg + "23.",aHelpPor,aHelpEng,aHelpEsp,.T.)
 
aHelpPor := {}
	
Aadd(aHelpPor,"Numero de vezes que cada " ) 
Aadd(aHelpPor,"carta será impressa" )
	
PutSX1Help("P." + cPerg + "24.",aHelpPor,aHelpEng,aHelpEsp,.T.)

aHelpPor := {}
	
Aadd(aHelpPor,"Intervalo em dias entre as " ) 
Aadd(aHelpPor,"impressões de cada carta." )
	
PutSX1Help("P." + cPerg + "25.",aHelpPor,aHelpEng,aHelpEsp,.T.)

aHelpPor := {}
	
Aadd(aHelpPor,"Impressão: para imprimir pela " ) 
Aadd(aHelpPor,"primeira vez a carta." )
Aadd(aHelpPor,"Re-Impressão: para imprimir pela " ) 
Aadd(aHelpPor,"novamente a carta já impressa." )

PutSX1Help("P." + cPerg + "26.",aHelpPor,aHelpEng,aHelpEsp,.T.)

// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
                                      
aAdd(aRegs,{cPerg,"01","Agendamento de: "			,"mv_ch1","D",08,0,0,"G","NaoVazio()"				,"mv_par01","","20000101","","","","","","","","","","","","",""   ,""})
aAdd(aRegs,{cPerg,"02","Agendamento até: "			,"mv_ch2","D",08,0,0,"G","NaoVazio()"				,"mv_par02","","20181231","","","","","","","","","","","","",""   ,""})
aAdd(aRegs,{cPerg,"03","Horario:	  "				,"mv_ch3","C",05,0,0,"G","NaoVazio()"				,"mv_par03","","00:00","",""				,"","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"04","Prefixo de:  "				,"mv_ch4","C",03,0,0,"G",""							,"mv_par04","","","",""				,"","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"05","Prefixo até: "				,"mv_ch5","C",03,0,0,"G","naovazio()"				,"mv_par05","","ZZZ","","","","","","","","","","","","",""   ,""})
aAdd(aRegs,{cPerg,"06","Título de: "				,"mv_ch6","C",09,0,0,"G",""							,"mv_par06","","","","","","","","","","","","","","",""   ,"018"})
aAdd(aRegs,{cPerg,"07","Título até: "				,"mv_ch7","C",09,0,0,"G","naovazio()"				,"mv_par07","","ZZZZZZZZZ","","","","","","","","","","","","",""   ,"018"})
aAdd(aRegs,{cPerg,"08","Natureza de: "				,"mv_ch8","C",10,0,0,"G",""							,"mv_par08","","","","","","","","","","","","","","","SED",""})
aAdd(aRegs,{cPerg,"09","Natureza até: "				,"mv_ch9","C",10,0,0,"G","NaoVazio()"				,"mv_par09","","ZZZZZZZZZZ","","","","","","","","","","","","","SED",""})
aAdd(aRegs,{cPerg,"10","Vencimento de: "			,"mv_cha","D",08,0,0,"G","NaoVazio()"				,"mv_par10","","","","","","","","","","","","","","",""   ,""})
aAdd(aRegs,{cPerg,"11","Vencimento até: "			,"mv_chb","D",08,0,0,"G","NaoVazio()"				,"mv_par11","","","","","","","","","","","","","","",""   ,""})
aAdd(aRegs,{cPerg,"12","Cliente de: "				,"mv_chc","C",09,0,0,"G",""							,"mv_par12","","","","","","","","","","","","","","","CLI","001"})
aAdd(aRegs,{cPerg,"13","Cliente até: "				,"mv_chd","C",09,0,0,"G","NaoVazio()"				,"mv_par13","","ZZZZZZ","","","","","","","","","","","","","CLI","001"})
aAdd(aRegs,{cPerg,"14","Loja de: "					,"mv_che","C",04,0,0,"G",""							,"mv_par14","","","","","","","","","","","","","","",""   ,"002"})
aAdd(aRegs,{cPerg,"15","Loja até: "					,"mv_chf","C",04,0,0,"G","NaoVazio()"				,"mv_par15","","ZZ","","","","","","","","","","","","",""   ,"002"})
aAdd(aRegs,{cPerg,"16","Conta Contábil de: "		,"mv_chg","C",20,0,0,"G",""							,"mv_par16","","","","","","","","","","","","","","","CT1","003"})
aAdd(aRegs,{cPerg,"17","Conta Contábil até: "		,"mv_chh","C",20,0,0,"G","NaoVazio()"				,"mv_par17","","ZZZZZZZZZZZZZZZZZZZZ","","","","","","","","","","","","","CT1","003"})
aAdd(aRegs,{cPerg,"18","Centro de Custo de: "		,"mv_chi","C",15,0,0,"G",""							,"mv_par18","","","","","","","","","","","","","","","CTT","004"})
aAdd(aRegs,{cPerg,"19","Centro de Custo até: "		,"mv_chj","C",15,0,0,"G","NaoVazio()"				,"mv_par19","","ZZZZZZZZZZZZZZZ","","","","","","","","","","","","","CTT","004"})
aAdd(aRegs,{cPerg,"20","Item Contábil de: "			,"mv_chk","C",15,0,0,"G",""							,"mv_par20","","","","","","","","","","","","","","","CTD","005"})
aAdd(aRegs,{cPerg,"21","Item Contábil até: "		,"mv_chl","C",15,0,0,"G","NaoVazio()"				,"mv_par21","","ZZZZZZZZZZZZZZZ","","","","","","","","","","","","","CTD","005"})
aAdd(aRegs,{cPerg,"22","Filial de:"					,"mv_chm","C",08,0,0,"G",""							,"mv_par22","","","","","","","","","","","","","","",""   ,"033"})
aAdd(aRegs,{cPerg,"23","Filial até:"				,"mv_chn","C",08,0,0,"G","NaoVazio()"				,"mv_par23","","ZZZZZZZZ","","","","","","","","","","","","",""   ,"033"})
aAdd(aRegs,{cPerg,"24","Nr. de Impressões:"			,"mv_cho","N",02,0,0,"G","Positivo().and.NaoVazio()","mv_par24","","2","","","","","","","","","","","","",""   ,""})
aAdd(aRegs,{cPerg,"25","Intervalo:"					,"mv_chp","N",03,0,0,"G","Positivo().and.NaoVazio()","mv_par25","","15","","","","","","","","","","","","",""   ,""})
aAdd(aRegs,{cPerg,"26","Tipo:"						,"mv_chq","N",01,0,0,"C",""							,"mv_par26","Impressão","","","Re-impressão","","","",""   ,"","","","","","","",""})

For i := 1 to Len(aRegs)
	PutSX1(aRegs[i,1],aRegs[i,2],aRegs[i,3],aRegs[i,3],aRegs[i,3],aRegs[i,4],aRegs[i,5],aRegs[i,6],aRegs[i,7],;
	aRegs[i,8],aRegs[i,9],aRegs[i,10],iif(len(aRegs[i])>=26,aRegs[i,26],""),aRegs[i,27],"",aRegs[i,11],aRegs[i,12],;
	aRegs[i,12],aRegs[i,12],aRegs[i,13],aRegs[i,15],aRegs[i,15],aRegs[i,15],aRegs[i,18],aRegs[i,18],aRegs[i,18],;
	aRegs[i,21],aRegs[i,21],aRegs[i,21],aRegs[i,24],aRegs[i,24],aRegs[i,24])
Next i


dbSelectArea(_sAlias)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ SIF09Inv  ³ Autor ³ Stanko               ³ Data ³ 04/12/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Marca / Desmarca todas as Filiais                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MP10 - Especifico OAS                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function SIF09Inv( oMark,cAliasTRB )

Local nRec := (cAliasTRB)->( Recno() )

dbSelectArea(cAliasTRB)
dbGoTop()

While !EOF(cAliasTRB)
	
	RecLock(cAliasTRB, .F. )
	(cAliasTRB)->E1_OK := If( (cAliasTRB)->E1_OK == cMarca, "", cMarca )
	MsUnlock()
	
	dbSkip()
EndDo

(cAliasTRB)->( DbGoTo( nRec ) )

lInverte := !lInverte

oMark:oBrowse:Refresh()

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ SIF09Chg  ³ Autor ³ Stanko               ³ Data ³ 04/12/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Inverte Selecao                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MP10 - Especifico OAS                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function SIF09Chg( oMark,cAliasTRB )

Local nRec  := (cAliasTRB)->( Recno() )
Local cFlag := " "

dbSelectArea(cAliasTRB)
dbGoTop()

While !EOF(cAliasTRB)
	
	If IsMark( "E1_OK" , cMarca , lInverte )
		cFlag := " "
	Else
		cFlag := cMarca
	EndIf
	
	RecLock(cAliasTRB, .F. )
	(cAliasTRB)->E1_OK := cFlag
	MsUnlock()
	
	dbSkip()
EndDo

(cAliasTRB)->( DbGoTo( nRec ) )

oMark:oBrowse:Refresh()

Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ xExistFila  ³ Autor ³ Stanko               ³ Data ³ 04/12/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Existe Fila?                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MP10 - Especifico OAS                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function xExistFila(cChave)

Local aArea := GetArea()
Local lRet := .F.

dbSelectArea("SZP")
dbSetOrder(1)
If dbSeek(cChave)
	lRet := .T.
Endif

RestArea(aArea)
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ xCriaFila  ³ Autor ³ Stanko               ³ Data ³ 04/12/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Inverte Selecao                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MP10 - Especifico OAS                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function xCriaFila(cAliasTrb)

Local aArea := GetArea()
Local nX
Local dNextImp := dDataBase

dbSelectArea("SZP")

For nX := 1 to MV_PAR24
	
	RecLock("SZP",.T.)
	SZP->ZP_FILIAL 	:= (cAliasTRB)->E1_FILIAL
	SZP->ZP_PREFIXO := (cAliasTRB)->E1_PREFIXO
	SZP->ZP_NUMERO 	:= (cAliasTRB)->E1_NUM
	SZP->ZP_PARCELA := (cAliasTRB)->E1_PARCELA   
	SZP->ZP_TIPO 	:= (cAliasTRB)->E1_TIPO
	SZP->ZP_SEQ		:= StrZero(MV_PAR24,3)
	dNextImp		:= DataValida(dNextImp,.T.)  //Ana - Buscar o proximo dia util.
	SZP->ZP_DTSCHED := dNextImp 
	MsUnLock()
	
	dNextImp += MV_PAR25
	
Next nX

RestArea(aArea)
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³ MyOpenSM0º Autor ³ TOTVS Protheus     º Data ³  26/01/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Descricao³ Funcao de processamento abertura do SM0 modo exclusivo     ³±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³ Uso      ³ MyOpenSM0  - Gerado por EXPORDIC / Upd. V.4.10.6 EFS       ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MyOpenSM0(lShared)

Local lOpen := .F.
Local nLoop := 0

For nLoop := 1 To 20
	dbUseArea( .T., , "SIGAMAT.EMP", "SM0", lShared, .F. )
	
	If !Empty( Select( "SM0" ) )
		lOpen := .T.
		dbSetIndex( "SIGAMAT.IND" )
		Exit
	EndIf
	
	Sleep( 500 )
	
Next nLoop

If !lOpen
	MsgStop( "Não foi possível a abertura da tabela " + ;
	IIf( lShared, "de empresas (SM0).", "de empresas (SM0) de forma exclusiva." ), "ATENÇÃO" )
EndIf

Return lOpen
