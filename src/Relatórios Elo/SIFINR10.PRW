#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSOLE.CH"
#INCLUDE "TOPCONN.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � SIFINR10 �Autor  �Leonardo Soncin     � Data �  11/01/2012 ���
�������������������������������������������������������������������������͹��
���Desc.     � Impressao do Termo de Confissao de Divida                  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � CNI                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function SIFINR10()

Local cTitulo		:= ""
Local cErro			:= ""
Local cSolucao		:= ""

Private cPerg 		:= "SIFI10"
PRIVATE cWord		:= OLE_CreateLink()
PRIVATE cPathDot	:= GetNewPar("SI_DIRDOT","") //Diretorio do Arquivo Modelo
PRIVATE cArqDot		:= GetNewPar("SI_DOTTER","") //Nome do Arquivo Modelo
PRIVATE cCadastro 	:= OemToAnsi("Termo de confiss�o de d�vida")

//��������������������������������������������������������������������������
//�Funcao que faz o Word aparecer na Area de Transferencia do Windows,     �
//�sendo que para habilitar/desabilitar e so colocar .T. ou .F.            �
//��������������������������������������������������������������������������
OLE_SetProperty(cWord, oleWdVisible  ,.F. )
OLE_SetProperty(cWord, oleWdPrintBack,.F. )

ValidPerg(cPerg)
If !Pergunte(cPerg,.T.)
	Return
Endif

If !File(AllTrim(cPathDot)+AllTrim(cArqDot))
	cTitulo 	:= "Arquivo modelo n�o encontrado"
	cErro		:= "O arquivo modelo para impress�o dos relat�rios "  + Alltrim(cArqDot)
	cErro		+= " n�o foi encontrado no diret�rio " + Alltrim(cPathDot)
	cErro		+= ", indicado nos parametros da rotina."
	cSolucao	:= "Informe o diret�rio e o nome do arquivo "
	cSolucao	+= "corretamente e processe a rotina novamente."
	xMagHelpFis(cTitulo,cErro,cSolucao)
	Return
Endif

If (cWord < "0")
	cTitulo 	:= "MS-Word n�o localizado"
	cErro		:= "O programa MS-Word n�o est� instalado nesta m�quina. "
	cErro		+= "Apenas com a exist�ncia deste programa, � poss�vel "
	cErro		+= "efetuar a impress�o do relat�rio."
	cSolucao	:= "Instale o MS-Word nesta m�quina ou efetue a impress�o "
	cSolucao	+= "em outra m�quina que possua o programa instalado."
	xMagHelpFis(cTitulo,cErro,cSolucao)
	Return
Endif

xProcImp()

Return Nil

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � xProcImp	� Autor � Leonardo Soncin    � Data �  04/01/12   ���
�������������������������������������������������������������������������͹��
���Descricao � Processa Impressao                                         ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Especifico - CNI                                           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function xProcImp()

//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������
Local oProcess  := NIL

oProcess := MsNewProcess():New( { | lEnd | xGerImp( @lEnd,oProcess) }, 'Processando', 'Aguarde, processando...', .F. )
oProcess:Activate()

Return

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � xGerImp  � Autor � Leonardo Soncin       � Data �10/01/2012���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao de Geracao e Impressao do WORD                       ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpC1 = Alias do arquivo                                    ���
���          �ExpN1 = Numero do registro                                  ���
���          �ExpN2 = Numero da opcao selecionada                         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function xGerImp(lEnd,oProcess)

Local cQuery 	:= ""
Local cAliasTMP := GetNextAlias()
Local cAliasTRB := GetNextAlias()
Local cNomArqTrb:= ""
Local nTotRegs 	:= 0
Local nProcRegs := 0
Local aEstrut 	:= SE1->(dbStruct())
Local nI, nF
Local cChave	:= ""
Local nSaldo	:= 0
Local nParc		:= 0
Local aParc		:= {}

Local cNomeDoc	:= ""
Local cDirDoc 	:= GetNewPar("SI_DIRCCOB","")
Local cSeqPar	:= GetNewPar("SI_SEQTER","")                                  
Local nNumLin 	:= GetNewPar("SI_NUMLINT",999)                                 

Local cSeq		:= ""

//--- Objetos da Dialog
Local oDlg
Local oChk
Local oInv
Local oMark
Local nOpc := 0

//--- Parametros para Impressao
//Local cCargo 	:= GetNewPar("SI_CARGO","")
Local cCargo 	:= ""
//Local cContato 	:= GetNewPar("SI_CONTATO","")                                 
Local cContato 	:= ""
Local nMulta	:= 0

//--- MarkBrowse
Local aCampos	:= {}
Private lInverte:= .F.
Private cMarca  := GetMark()
Private lTodos  := .T.
Private lChang  := .T.

//�����������������������������������Ŀ
//� Campos visualizados no MarkBrowse �
//�������������������������������������
// Ana incluidas as pictures nos campos.
aAdd( aCampos, { "E1_OK"		,, "" 					,PesqPict("SE1","E1_OK"    			,2) } ) 
aAdd( aCampos, { "E1_FILIAL"	,, "Filial"				,PesqPict("SE1","E1_FILIAL"			,8) }	)
aAdd( aCampos, { "E1_PREFIXO"	,, "Prefixo" 			,PesqPict("SE1","E1_PREFIXO"		,3) } )
aAdd( aCampos, { "E1_NUM"	 	,, "Numero"				,PesqPict("SE1","E1_NUM"			,9) } )
aAdd( aCampos, { "E1_PARCELA"	,, "Parcela"			,PesqPict("SE1","E1_PARCELA"		,3) } )
aAdd( aCampos, { "E1_TIPO"		,, "Tipo"			 	,PesqPict("SE1","E1_TIPO"			,3) } )    	
aAdd( aCampos, { "E1_NATUREZ"	,, "Natureza" 			,PesqPict("SE1","E1_NATUREZ"		,10) } )
aAdd( aCampos, { "E1_CLIENTE"	,, "Cliente" 			,PesqPict("SE1","E1_CLIENTE"		,9) } )
aAdd( aCampos, { "E1_NOMCLI"	,, "Descri��o" 			,PesqPict("SE1","E1_NOMCLI"	  		,20) } )
aAdd( aCampos, { "E1_LOJA"		,, "Loja" 				,PesqPict("SE1","E1_LOJA"			,4) } )
aAdd( aCampos, { "E1_VALOR"		,, "Valor" 				,PesqPict("SE1","E1_VALOR"			,17) } )
aAdd( aCampos, { "E1_SALDO"		,, "Saldo" 				,PesqPict("SE1","E1_SALDO"		    ,17) } )
aAdd( aCampos, { "E1_VENCTO"	,, "Vencimento" 		,PesqPict("SE1","E1_VENCTO"			,8) } )
aAdd( aCampos, { "E1_VENCREA"	,, "Vencimento Real" 	,PesqPict("SE1","E1_VENCREA"		,8) } )
aAdd( aCampos, { "E1_ACRESC"	,, "Acrescimo" 			,PesqPict("SE1","E1_ACRESC"			,17) } )

//���������������������������Ŀ
//� Cria o arquivo temporario �
//�����������������������������
cNomArqTRB := CriaTrab( aEstrut, .T. )
dbUseArea( .T.,,cNomArqTRB, cAliasTRB, .F., .F. )

IndRegua( cAliasTRB, cNomArqTRB, "E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA",,,"Criando Indice, aguarde..." )
dbClearIndex()
dbSetIndex( cNomArqTRB + OrdBagExt() )

If (cWord >= "0")
	//OLE_CloseFile(cWord)
	OLE_CloseLink(cWord) //fecha o Link com o Word 
	cWord:= OLE_CreateLink()
	OLE_NewFile(cWord,cPathDot+cArqDot)
	
	//��������������������������������������������������������������������������
	//�Funcao que faz o Word aparecer na Area de Transferencia do Windows,     �
	//�sendo que para habilitar/desabilitar e so colocar .T. ou .F.            �
	//��������������������������������������������������������������������������
	OLE_SetProperty(cWord, oleWdVisible  ,.F. )
	OLE_SetProperty(cWord, oleWdPrintBack,.F. )
Endif


// Query dos Titulos em Aberto
cQuery :=  "SELECT * "
cQuery +=  "FROM "+RetSqlName("SE1")
cQuery +=  " WHERE E1_FILIAL = '"+xFilial("SE1")+"' AND "
cQuery +=  "E1_NUM BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND "
cQuery +=  "E1_PREFIXO BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' AND "
cQuery +=  "E1_NATUREZ BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' AND "
cQuery +=  "E1_VENCREA BETWEEN '"+Dtos(MV_PAR07)+"' AND '"+Dtos(MV_PAR08)+"' AND "
cQuery +=  "E1_CLIENTE BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"' AND "
cQuery +=  "E1_LOJA BETWEEN '"+MV_PAR11+"' AND '"+MV_PAR12+"' AND "
cQuery +=  "E1_SALDO > 0 AND "
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
	oProcess:SetRegua1(nTotRegs)
	oProcess:IncRegua1("Iniciando processamento...")
	oProcess:SetRegua2(nTotRegs)
	oProcess:IncRegua2("Termo de Confissao de Divida")
	
	dbSelectArea(cAliasTMP)
	dbGotop()
	
	// Cria TRB a partir do resultado da Query
	While !Eof(cAliasTMP)
		
		nProcRegs++
		oProcess:IncRegua1("Processando item: "+CValToChar(nProcRegs)+" / "+CValToChar(nTotRegs))
		
		(cAliasTRB)->(DbAppend())
//		For nI := 1 To nTotRegs  --Comentado por Ana 
		For nI := 1 To Len(aEstrut)                                   // ajustado por Ana
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

//��������������������������������������������������Ŀ
//� Monta a Tela com MsSelect e Objetos de Check Box �
//����������������������������������������������������
DEFINE FONT oFont NAME "Mono AS" SIZE 8,15 BOLD

DEFINE MSDIALOG oDlg TITLE "Sele��o de T�tulos em Aberto" From 3,0 To 40,120

oMark := MsSelect():New(cAliasTRB,"E1_OK",,aCampos, @lInverte, @cMarca, { 30, 0, 260, 477 } )

oMark:oBrowse:lhasMark := .T.
oMark:oBrowse:bAllMark := {|| U_SIF10Inv( oMark,cAliasTRB ) }  // Na verdade, esse comando esta desabilitado pela instrucao de cima

@ 265,010 CHECKBOX oChk VAR lTodos PROMPT "Marca/Desmarca Todos" SIZE 80,7 COLOR CLR_HBLUE OF oDlg PIXEL ON CLICK U_SIF10Inv( oMark,cAliasTRB ); lTodos := .F.; oChk:oFont := oDlg:oFont
@ 265,110 CHECKBOX oInv VAR lChang PROMPT "Inverte Sele��o" SIZE 80,7 COLOR CLR_HBLUE OF oDlg PIXEL ON CLICK U_SIF10Chg( oMark,cAliasTRB ); lChang := .F.; oChk:oFont := oDlg:oFont

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg, {||( nOpc := 1, oDlg:End() )}, {||(nOpc := 0, oDlg:End())},,) CENTERED

DeleteObject( oMark )
DeleteObject( oDlg )
DeleteObject( oChk )
DeleteObject( oInv )

If nOpc == 1
	
	Begin Transaction
	
	dbSelectArea(cAliasTRB)
	dbGoTop()
	
	While !EOF(cAliasTRB)
				
		cChave := (cAliasTRB)->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_TIPO+E1_CLIENTE+E1_LOJA)
		
		If (cAliasTRB)->E1_OK == cMarca
		
			If (cWord >= "0") //Ana   quando gerava v�rios docs com clientes diferentes estava sobrepondo as parcelas.
	
				OLE_CloseFile(cWord)
				OLE_CloseLink(cWord) //fecha o Link com o Word 
				cWord:= OLE_CreateLink()
				OLE_NewFile(cWord,cPathDot+cArqDot)
		
				//��������������������������������������������������������������������������
				//�Funcao que faz o Word aparecer na Area de Transferencia do Windows,     �
				//�sendo que para habilitar/desabilitar e so colocar .T. ou .F.            �
				//��������������������������������������������������������������������������
				OLE_SetProperty(cWord, oleWdVisible  ,.F. )
				OLE_SetProperty(cWord, oleWdPrintBack,.F. )
			Endif

			//�������������������������Ŀ
			//�Variaves para a impressao�
			//���������������������������
			If (cWord >= "0")
				//��������������������������������������������������������
				//�Informacoes sobre a empresa que esta emitindo o termo �
				//��������������������������������������������������������
				OLE_SetDocumentVar(cWord, "c_Empresa"	, SM0->M0_NOMECOM )
				OLE_SetDocumentVar(cWord, "c_NomeRed"	, SM0->M0_NOME )
				OLE_SetDocumentVar(cWord, "c_EndEmp"	, Alltrim(SM0->M0_ENDCOB)+", "+Alltrim(SM0->M0_CIDCOB)+" - "+Alltrim(SM0->M0_ESTCOB))
				OLE_SetDocumentVar(cWord, "c_CNPJEmp"	, Transform(SM0->M0_CGC,"@R 99.999.999/9999-99"))
				OLE_SetDocumentVar(cWord, "c_CidadeEmp"	, AllTrim(SM0->M0_CIDCOB))
				OLE_SetDocumentVar(cWord, "d_DataBase"	, dDataBase  )
				OLE_SetDocumentVar(cWord, "c_DiaMesAno"	, Alltrim(Str(Day(dDataBase)))+" de "+AllTrim(MesExtenso(Month(dDataBase)))+" de "+Alltrim(Str(Year(dDataBase))))
			Endif
				

		 	// Ana -> se estiver logado em outra empresa, eu posso visualizar os registros e selecionar, 
		 	// consequentemente nao pode buscar os dados da empresa logada.
			cContato 	:= Substr(SuperGetMv("SI_CONTATO",.F.,,Substr((cAliasTRB)->(E1_FILIAL),1,4)),1,30)  //Ana os parametros ser�o criados por Empresa/Unidade de Negocio
			cCargo 		:= SuperGetMv("SI_CARGO",.F.,,Substr((cAliasTRB)->(E1_FILIAL),1,4))                    
			
			If (cWord >= "0")
				
				//�����������������������������������Ŀ
				//� Incrementa Lote                   �
				//�������������������������������������

				dbSelectArea("SE1")
				dbSetOrder(1)
				dbSeek((cAliasTRB)->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO))												
				If Empty(SE1->E1_XSEQTC)				
					cSeqPar := Soma1(cSeqPar)		
					cSeq := cSeqPar+Alltrim(Str(YEAR(dDataBase)))
				Else
					cSeq := SE1->E1_XSEQTC
				Endif

				//Informa��es do Contato
				OLE_SetDocumentVar(cWord, "c_Cargo"		, PadR(cCargo,30)  	)
				OLE_SetDocumentVar(cWord, "c_Contato"	, cContato  )
								
				//�����������������������������������Ŀ
				//�Informacoes sobre a emissao da nota�
				//�������������������������������������				
				OLE_SetDocumentVar(cWord, "c_SeqAno"	, Substr(cSeq,1,4)+"/"+Substr(cSeq,5,4) )      //Ana incluida a barra que separa o sequencial e ano conforme PL
				OLE_SetDocumentVar(cWord, "c_Num"		, Alltrim((cAliasTRB)->E1_NUM))				
				OLE_SetDocumentVar(cWord, "n_TotJuros"	, (cAliasTrb)->E1_VALJUR )
				
				dbSelectArea("SEE")
				dbSetOrder(1)
				If dbSeek(xFilial("SEE")+(cAliasTRB)->(E1_PORTADO+E1_AGEDEP+E1_CONTA))
					nMulta := EE_XMULTA				
				Endif
				OLE_SetDocumentVar(cWord, "n_Multa"	, nMulta )
				                                                                     
				// Busca Campo Memo
				dbSelectArea("SE1")
				dbSetOrder(1)
				dbSeek((cAliasTRB)->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO))
				OLE_SetDocumentVar(cWord, "c_Motivo"	, Alltrim(SE1->E1_XMOTDIV) )
								
				//�����������������������������������Ŀ
				//�Informacoes sobre o cliente        �
				//�������������������������������������
				dbSelectArea("SA1")
				dbSetOrder(1)
				dbSeek(xFilial("SA1")+(cAliasTRB)->(E1_CLIENTE+E1_LOJA))
				
				OLE_SetDocumentVar(cWord, "c_NomeCliente"	, PadR(Substr(SA1->A1_NOME,1,40),40)) //Estava pulando para outra linha - Ana
				OLE_SetDocumentVar(cWord, "c_EndCliente"	, AllTrim(SA1->A1_END)+" - "+AllTrim(SA1->A1_COMPLEM)+" - "+AllTrim(SA1->A1_MUN)+" - "+AllTrim(SA1->A1_EST))
				OLE_SetDocumentVar(cWord, "c_Pessoa"		, Iif(SA1->A1_PESSOA=='F',"PESSOA F�SICA","PESSOA JUR�DICA") )          
				If SA1->A1_PESSOA=='F'
					OLE_SetDocumentVar(cWord, "c_CpfCnpjCli"	, Transform(SA1->A1_CGC,"@R 999.999.999-99")) //Ana Corre��o da Picture				 
				Else	
					OLE_SetDocumentVar(cWord, "c_CpfCnpjCli"	, Transform(SA1->A1_CGC,"@R 99.999.999/9999-99")) //Ana Corre��o da Picture
				Endif			
			Endif
		Else //Senao est� selecionado
			dbSelectArea(cAliasTRB)
			dbSkip()
			Loop
		Endif
		
		While !Eof() .and. (cAliasTRB)->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_TIPO+E1_CLIENTE+E1_LOJA) == cChave
			
			If (cAliasTRB)->E1_OK == cMarca   
			
				oProcess:IncRegua2()
				
				//Totalizadores
				nParc++
				nSaldo += (cAliasTRB)->E1_SALDO
				
				Aadd(aParc,{(cAliasTRB)->E1_PARCELA,(cAliasTRB)->E1_SALDO,(cAliasTRB)->E1_VALJUR,dDataBase})
				
				// Atualiza Sequencia dos Titulos
				dbSelectArea("SE1")
				dbSetOrder(1)
				dbSeek((cAliasTRB)->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO))
				RecLock("SE1",.F.)
				SE1->E1_XSEQTC := cSeq
				MsUnLock()
								
			EndIf                                                                                                                                               
			If Len(aParc) = 1  //Incluido por Ana - Quando ha somente uma parcela, esta deve ser incluida na nomeclatura.
				cNomeDoc := "TERMO_"+Alltrim(SA1->A1_COD)+"_"+Alltrim(SA1->A1_LOJA)+"_"+Alltrim((cAliasTRB)->E1_PREFIXO)+"_"+Alltrim((cAliasTRB)->E1_NUM)+"_"+Alltrim((cAliasTRB)->E1_PARCELA)+".DOC"			
			Else                  
				cNomeDoc := "TERMO_"+Alltrim(SA1->A1_COD)+"_"+Alltrim(SA1->A1_LOJA)+"_"+Alltrim((cAliasTRB)->E1_PREFIXO)+"_"+Alltrim((cAliasTRB)->E1_NUM)+".DOC"
			Endif	
			dbSelectArea(cAliasTRB)
			dbSkip()
		EndDo
	
		If (cWord >= "0")                                                     
		
	//			For nF := 1 to nNumLin  //Comentado por Ana
				For nF := 1 to Len(aParc) //modificado por Ana
					OLE_SetDocumentVar(cWord, "c_Parc"+Alltrim(Str(nF))			, Iif(nF<=Len(aParc),aParc[nF][1],""))			          
					OLE_SetDocumentVar(cWord, "n_Saldo"+Alltrim(Str(nF))		, Iif(nF<=Len(aParc),Transform(aParc[nF][2],"@E 999,999,999.99"),"")) //Ana Ajuste Picture			          
					OLE_SetDocumentVar(cWord, "n_Juros"+Alltrim(Str(nF))		, Iif(nF<=Len(aParc),aParc[1][3],""))			          //Ana repetir o valor dos juros para todas as linhas.
					OLE_SetDocumentVar(cWord, "d_Data"+Alltrim(Str(nF))			, Iif(nF<=Len(aParc),aParc[nF][4],""))			          												
				Next 
		                                                                  
				OLE_SetDocumentVar(cWord, "c_Saldo"		, Extenso(nSaldo))
				OLE_SetDocumentVar(cWord, "c_Parcela"	, Alltrim(Str(nParc))+"/"+Extenso(nParc,.T.))
			
				OLE_SetDocumentVar(cWord, "h_nlinhas"		, Len(aParc)) //Incluido por Ana - passa para a variavel da macro o numero de linhas
				OLE_ExecuteMacro(cWord,"Parcelas") //Incluido por Ana - Executa a macro.
				
				//�������������������������������������������������������������������������������������
				//�Funcao que atualiza os campos da memoria para o Documento, utilizada logo apos a   �
				//�funcao OLE_SetDocumentVar().														  �
				//�������������������������������������������������������������������������������������
				OLE_UpdateFields(cWord)

				//�������������������������������������������Ŀ
				//� Salva os Termos Gerados                   �
				//���������������������������������������������
				OLE_SaveAsFile(cWord,AllTrim(cDirDoc) + cNomeDoc) //Ana								
			Endif

		// Zera Totalizadores
		nParc 	:= 0
		nSaldo 	:= 0         
		aParc	:= {}
		
	Enddo
	
	//Atualiza Sequencia
	PutMV('SI_SEQTER',cSeqPar)
	If (cWord >= "0")
		OLE_CloseFile(cWord)
		OLE_CloseLink(cWord) //fecha o Link com o Word 
	Endif

	End Transaction
Endif
    
/*If (cWord >= "0")                                           //Comentado por Ana
	OLE_CloseFile(cWord)
	OLE_CloseLink(cWord) //fecha o Link com o Word 
	
Endif*/

If Select(cAliasTRB) != 0
	dbSelectArea(cAliasTRB)
	dbCloseArea()
	FErase(cNomArqTrb+GetDBExtension())
	FErase(cNomArqTrb+OrdBagExt())
Endif

Return(.T.)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � ValidPerg� Autor � Wagner Gomes          � Data � 10/12/09 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cria as Perguntas para Fatura para locacao de Bens Moveis  ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Especifico Construtora OAS Ltda                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ValidPerg(cPerg)

Local _sAlias := Alias()
Local aRegs := {}
Local i,j

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
aAdd(aRegs,{cPerg,"01","T�tulo de: "				,"mv_ch1","C",09,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","018"})
aAdd(aRegs,{cPerg,"02","T�tulo at�: "				,"mv_ch2","C",09,0,0,"G","naovazio()","mv_par02","","","","","","","","","","","","","","","","018"})
aAdd(aRegs,{cPerg,"03","Prefixo de:  "				,"mv_ch3","C",03,0,0,"G","","mv_par03","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"04","Prefixo at�: "				,"mv_ch4","C",03,0,0,"G","naovazio()","mv_par04","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"05","Natureza de: "				,"mv_ch5","C",10,0,0,"G","","mv_par05","","","","","","","","","","","","","","","SED",""})
aAdd(aRegs,{cPerg,"06","Natureza at�: "				,"mv_ch6","C",10,0,0,"G","NaoVazio()","mv_par06","","","","","","","","","","","","","","","SED",""})
aAdd(aRegs,{cPerg,"07","Vencimento de: "			,"mv_ch7","D",08,0,0,"G","NaoVazio()","mv_par07","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"08","Vencimento at�: "			,"mv_ch8","D",08,0,0,"G","NaoVazio()","mv_par08","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"09","Cliente de: "				,"mv_ch9","C",09,0,0,"G","","mv_par09","","","","","","","","","","","","","","","SA1","001"})
aAdd(aRegs,{cPerg,"10","Cliente at�: "				,"mv_cha","C",09,0,0,"G","NaoVazio()","mv_par10","","","","","","","","","","","","","","","SA1","001"})
aAdd(aRegs,{cPerg,"11","Loja de: "					,"mv_chb","C",04,0,0,"G","","mv_par11","","","","","","","","","","","","","","","","002"})
aAdd(aRegs,{cPerg,"12","Loja at�: "					,"mv_chc","C",04,0,0,"G","NaoVazio()","mv_par12","","","","","","","","","","","","","","","","002"})

For i := 1 to Len(aRegs)
	PutSX1(aRegs[i,1],aRegs[i,2],aRegs[i,3],aRegs[i,3],aRegs[i,3],aRegs[i,4],aRegs[i,5],aRegs[i,6],aRegs[i,7],;
	aRegs[i,8],aRegs[i,9],aRegs[i,10],iif(len(aRegs[i])>=26,aRegs[i,26],""),aRegs[i,27],"",aRegs[i,11],aRegs[i,12],;
	aRegs[i,12],aRegs[i,12],aRegs[i,13],aRegs[i,15],aRegs[i,15],aRegs[i,15],aRegs[i,18],aRegs[i,18],aRegs[i,18],;
	aRegs[i,21],aRegs[i,21],aRegs[i,21],aRegs[i,24],aRegs[i,24],aRegs[i,24])
Next i

dbSelectArea(_sAlias)

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � SIF10Inv  � Autor � Stanko               � Data � 04/12/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Marca / Desmarca todas as Filiais                          ���
�������������������������������������������������������������������������Ĵ��
���Uso       � MP10 - Especifico OAS                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function SIF10Inv( oMark,cAliasTRB )

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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � SIF10Chg  � Autor � Stanko               � Data � 04/12/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Inverte Selecao                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � MP10 - Especifico OAS                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function SIF10Chg( oMark,cAliasTRB )

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
