#Include "Protheus.ch"
#Include "TopConn.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SIESTA01
Cadastro de Inventário.

@type function
@author Leonardo Soncin
@since 02/12/2011
@version P12.1.23

@obs Projeto ELO

@history 21/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function SIESTA01()

	//+---------------------------------------------------------------------+
	//| Declaracao de Variaveis                                             |
	//+---------------------------------------------------------------------+
	Local aCores := {	{ "ZK_STATUS == '1'", "BR_VERDE"		},;
	{ "ZK_STATUS == '2'", "BR_AMARELO"	},;
	{ "ZK_STATUS == '3'", "BR_VERMELHO"		} }


	Private cCadastro := "Cadastro de Inventário"

	//+---------------------------------------------------------------------+
	//| Monta um aRotina proprio                                            |
	//+---------------------------------------------------------------------+

	Private aRotina := { {"Pesquisar","AxPesqui",0,1} ,;
	{"Visualizar","U_SIEST01C",0,2} ,;
	{"Criar","U_SIEST01C",0,3} ,;
	{"Manutenção","U_SIEST01C",0,4} ,;
	{"Excluir","U_SIEST01C",0,5} ,;
	{"Gerar Inventário","U_SIEST01G",0,4} ,;
	{"Estorna","U_SIEST01E",0,6},;
	{"Legenda","U_SIEST01L",0,2}}

	Private cDelFunc := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock

	Private cString := "SZK"

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	dbSelectArea("SZK")
	SZK->(dbSetOrder(1))

	dbSelectArea(cString)
	mBrowse( 6,1,22,75,cString,,,,,,aCores)

Return


/*/================================================================================================================================/*/
/*/{Protheus.doc} SIEST01C
Tela de Manutenção do Inventário (Criação, manutenção e exclusão e Visualização).

@type function
@author Leonardo Soncin
@since 02/12/2011
@version P12.1.23

@param cAlias, characters, Alias da tabela.
@param nReg, numeric, RECNO do registro posicionado.
@param nOpc, numeric, Código da opção.

@obs Projeto ELO

@history 21/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function SIEST01C(cAlias,nReg,nOpc)

	Local cPerg 		:= "SIEA01"
	Local _cQuery 		:= ""
	Local cAliasTMP 	:= GetNextAlias()
	Local nX 	 		:= 0
	Local nUsado 	 	:= 0
	Local nOpcX 	 	:= 0
	Local aRegNo    	:= {}
	Local aButtons		:= {}
	Local aCpoEnch 		:= {}
	Local aAlterEnch	:= {}
	Local aPos			:= {000,000,080,400}
	Local nModelo		:= 3
	Local lF3 			:= .F.
	Local lMemoria		:= .T.
	Local lColumn		:= .F.
	Local caTela 		:= ""
	Local cIniCpos 		:= ""
	Local lNoFolder		:= .F.
	Local lProperty		:= .F.
	Local aStru			:= SZL->(dbStruct())
	Local aCpoGDad      := {}
	Local nSuperior    	:= 081
	Local nEsquerda    	:= 000
	Local nInferior    	:= 250
	Local nDireita     	:= 400
	Local cLinOk       	:= "U_ESTA1LOk"
	Local cTudoOk      	:= "AllwaysTrue"
	Local nFreeze      	:= 000
	Local nMax         	:= 999
	Local cFieldOk     	:= "AllwaysTrue"
	Local cSuperDel     := ""
	Local cDelOk        := "AllwaysTrue"
	Local aAlterGDad	:= {}
	Local cClasse		:= ""
	Local aCols         := {}
	Local aHeader       := {}
	Local nStyle		:= 0
	Local aAlter        := {}
	Local lSegue        := .T.

	Private oDlg
	Private oBrw
	Private oEnch
	Private aTELA[0][0]
	Private aGETS[0]

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	// Valida Alteracao
	If SZK->ZK_STATUS <> '1' .and. (nOpc == 4 .or. nOpc == 5)
		Help(" ",1, "OPCINV","Opção inválida","O status do registro nao permite esta operação.",1,0 )
		lSegue := .F.
	Endif

	If lSegue

		// Monta Enchoice
		DbSelectArea("SX3")
		SX3->(DbSetOrder(1))
		SX3->(MsSeek(cAlias))

		While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == cAlias
			If !(SX3->X3_CAMPO $ "ZK_FILIAL") .And. cNivel >= SX3->X3_NIVEL .And.;
			X3Uso(SX3->X3_USADO)
				AAdd(aCpoEnch,SX3->X3_CAMPO)
			EndIf
			SX3->(DbSkip())
		End

		If nOpc == 3
			aAlterEnch := aClone(aCpoEnch)
		ENdif

		//+--------------------------------------------------------------+
		//| Montagem GetDados e AHeader                                  |
		//+--------------------------------------------------------------+

		DbSelectArea("SX3")
		SX3->(DbSetOrder(1))
		SX3->(MsSeek("SZL"))

		While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "SZL"
			If	!(AllTrim(SX3->X3_CAMPO) $ "ZL_FILIAL") .And. cNivel >= SX3->X3_NIVEL .And. X3Uso(SX3->X3_USADO)
				AAdd(aCpoGDad,SX3->X3_CAMPO)
			EndIf
			SX3->(DbSkip())
		End

		aAlterGDad := aClone(aCpoGDad)

		nUsado:=0
		dbSelectArea("SX3")
		SX3->(dbSeek("SZL"))
		aHeader:={}
		While SX3->(!Eof()).And.(x3_arquivo=="SZL")
			If X3USO(x3_usado).And.cNivel>=x3_nivel .and. !(x3_campo $ "ZL_DOC    ")
				nUsado:=nUsado+1
				Aadd(aHeader,{ TRIM(x3_titulo), x3_campo, x3_picture,;
				x3_tamanho, x3_decimal,X3_VALID,;
				x3_usado, x3_tipo, X3_F3, x3_context } )
			Endif
			SX3->(dbSkip())
		End

		aCols:={}

		If ! (nOpc == 3)
			dbSelectArea("SZL")
			SZL->(dbSetOrder(1))
			SZL->(dbSeek(xFilial("SZL")+SZK->ZK_DOC))
			While SZL->(!eof()).and. ZL_FILIAL == xFilial("SZL") .and. ZL_DOC==SZK->ZK_DOC
				AADD(aCols,Array(nUsado+1))
				For nX:=1 to nUsado

					Do Case
						Case  ( AllTrim(aHeader[nX,2]) <> "ZL_DESC" )
						aCols[Len(aCols),nX]:=FieldGet(FieldPos(aHeader[nX,2]))
						Otherwise
						aCols[Len(aCols),nX]:= POSICIONE('SB1',1,XFILIAL('SB1')+FieldGet(FieldPos("ZL_COD")),'B1_DESC')
					EndCase

				Next
				aCols[Len(aCols),nUsado+1]:=.F.

				aadd(aRegNo,SZL->(RECNO()))

				SZL->(dbSkip())
			EndDo

		Endif
		ValidPerg(cPerg)

		nPosOrig    := aScan(aHeader,{|x| AllTrim(x[2])=="ZL_USER"})

		If nOpc == 3

			If Pergunte(cPerg,.T.)

				/*
				//+----------------+
				//| Classe ABC     |
				//+----------------+
				For i:= 1 to Len(mv_par09)
				cClasse += "'"+Subs(mv_par09,i,1)+"'"
				If ( i+1 ) <= Len(mv_par09)
				cClasse += ","
				Endif
				Next i
				*/

				_cQuery :=  "SELECT B2_COD AS ZL_COD, B1_DESC AS ZL_DESC, B2_LOCAL AS ZL_LOCAL, B1_TIPO AS ZL_TIPO, B1_GRUPO AS ZL_GRUPO, B3_CLASSE AS ZL_CLASSE, B8_LOTECTL AS ZL_LOTECTL, B8_NUMLOTE AS ZL_NUMLOTE, 0 AS ZL_QUANT, 0 AS ZL_QTSEGUM "
				_cQuery +=  "FROM "+RetSqlName("SB2")+" SB2 "
				_cQuery +=  "INNER JOIN "+RetSqlName("SB1")+" SB1 ON B1_COD = B2_COD AND SB1.D_E_L_E_T_ = ' ' "
				_cQuery +=  "LEFT OUTER JOIN "+RetSqlName("SB3")+" SB3 ON B3_FILIAL = B2_FILIAL AND B3_COD = B2_COD AND SB3.D_E_L_E_T_ = ' ' "
				_cQuery +=  "LEFT OUTER JOIN "+RetSqlName("SB8")+" SB8 ON B8_FILIAL = B2_FILIAL AND B8_PRODUTO = B2_COD AND B8_LOCAL = B2_LOCAL AND SB8.D_E_L_E_T_ = ' ' "
				_cQuery +=  "WHERE B2_FILIAL = '"+xFilial("SB2")+"' AND "
				_cQuery +=  "B2_COD BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND "
				_cQuery +=  "B2_LOCAL BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' AND "
				_cQuery +=  "B1_TIPO BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' AND "
				_cQuery +=  "B1_GRUPO BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' AND "
				//_cQuery +=  "B3_CLASSE IN ("+cClasse+") AND "
				_cQuery +=  "SB2.D_E_L_E_T_ = ' ' "
				_cQuery +=  "ORDER BY B2_COD,B2_LOCAL,B1_TIPO,B8_LOTECTL"
				_cQuery := ChangeQuery(_cQuery)

				If Select(cAliasTMP) > 0
					dbSelectArea(cAliasTMP)
					(cAliasTMP)->(dbCloseArea())
				Endif

				dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),cAliasTMP,.T.,.F.)

				For nCntFor := 1 To Len(aStru)
					If ( aStru[nCntFor,2]<>"C" )
						TcSetField(cAliasTMP,aStru[nCntFor,1],aStru[nCntFor,2],aStru[nCntFor,3],aStru[nCntFor,4])
					EndIf
				Next nCntFor

				DbSelectArea(cAliasTMP)
				(cAliasTMP)->(dbGotop())

				While (cAliasTMP)->(!Eof())

					//Trata Classe ABC
					If !((cAliasTMP)->ZL_CLASSE $ MV_PAR09)
						dbSelectArea(cAliasTMP)
						(cAliasTMP)->(dbSkip())
						Loop
					Endif

					//Atualiza aCols
					AADD(aCols,Array(nUsado+1))
					For nX:=1 to 10
						aCols[Len(aCols),nX]:=FieldGet(FieldPos(aHeader[nX,2]))
					Next
					aCols[Len(aCols),nPosOrig]:= "SIESTA01"

					aCols[Len(aCols),nUsado+1]:=.F.
					dbSelectArea(cAliasTMP)
					(cAliasTMP)->(dbSkip())
				EndDo
			Else
				lSegue := .F.
			Endif

		Endif

		If lSegue

			//+--------------------------------------------------------------+
			//| Montagem da Tela de Consulta                                 |
			//+--------------------------------------------------------------+

			aObjects 	:= {}
			aSizeAut	:= MsAdvSize()
			Aadd( aObjects, { 100, 100, .T., .T. } )
			Aadd( aObjects, { 100, 100, .T., .T. } )
			Aadd( aObjects, { 100, 015, .T., .F. } )
			aInfo		:= { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
			aPosObj		:= MsObjSize( aInfo, aObjects )
			aPosGet		:= MsObjGetPos(aSizeAut[ 3 ]-aSizeAut[ 1 ], 315, {{003, 033, 160, 200, 240, 265}} )

			oDlg 		:= MSDIALOG():New(aSizeAut[7],000, aSizeAut[6],aSizeAut[5], cCadastro,,,,,,,,,.T.)

			If nOpc == 3
				INCLUI := .T.
				ALTERA := .F.
				nStyle := GD_INSERT+GD_UPDATE+GD_DELETE
			ElseIf nOpc == 4
				INCLUI := .F.
				ALTERA := .T.
				nStyle := GD_INSERT+GD_UPDATE+GD_DELETE
			Else
				INCLUI := .F.
				nStyle := 0
			Endif

			RegToMemory("SZK",INCLUI)

			//Atualiza os campos // Inicializadores para Inclusao
			If nOpc == 3
				M->ZK_CODDE 	:= MV_PAR01
				M->ZK_CODATE 	:= MV_PAR02
				M->ZK_LOCDE 	:= MV_PAR03
				M->ZK_LOCATE 	:= MV_PAR04
				M->ZK_TIOPDE 	:= MV_PAR05
				M->ZK_TIPOATE 	:= MV_PAR06
				M->ZK_GRUPDE 	:= MV_PAR07
				M->ZK_GRUPATE 	:= MV_PAR08
				M->ZK_CLASSE 	:= MV_PAR09
			Endif

			oEnch 	:= MsMGet():New(cAlias, nReg,nOpc, /*aCRA*/, /*cLetra*/, /*cTexto*/,;
			aCpoEnch,aPosObj[1],	aAlterEnch, nModelo, /*nColMens*/, /*cMensagem*/,;
			/*cTudoOk*/, oDlg,lF3, lMemoria,lColumn,caTela,lNoFolder,lProperty)

			oBrw	:= MsNewGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nStyle,cLinOk, cTudoOk, cIniCpos, aAlterGDad, nFreeze, nMax, cFieldOk, cSuperDel,cDelOk,oDlg, @aHeader, @aCols)
			oBrw:bChange := {|| xGet2Chg()}

			oDlg:bInit	:= {|| EnchoiceBar(oDlg, {|| aCols := oBrw:aCols,nOpcX:=1,IIf(oBrw:TudoOk().and.Obrigatorio(aGets, aTela),oDlg:End(),nOpcX:=0)}, {||nOpcx := 0, oDlg:End()},,aButtons)}
			oDlg:lCentered := .T.
			oDlg:Activate()

			If nOpcX == 1 .and. !nOpc == 2
				//Gravaçao dos Dados
				xSIESTGRV(aCols,aHeader,nUsado,aRegno,nOpc)
			Endif

		Endif

	Endif

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} ValidPerg
Cria as Perguntas para Fatura para locacao de Bens Moveis.

@type function
@author Wagner Gomes
@since 10/12/2009
@version P12.1.23

@param cPerg, characters, Nome da Pergunta.

@obs Projeto ELO

@history 21/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function ValidPerg(cPerg)

	Local _sAlias := Alias()
	Local aRegs := {}
	Local i//,j

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	dbSelectArea("SX1")
	SX1->(dbSetOrder(1))
	cPerg := PADR(cPerg,10)

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
	aAdd(aRegs,{cPerg,"01","Produto de:  "				,"mv_ch1","C",30,0,0,"G","","mv_par01","","","","","","","","","","","","","","","SB1","030"})
	aAdd(aRegs,{cPerg,"02","Produto até: "				,"mv_ch2","C",30,0,0,"G","naovazio()","mv_par02","","","","","","","","","","","","","","","SB1","030"})
	aAdd(aRegs,{cPerg,"03","Armazem de:  "				,"mv_ch3","C",02,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","024"})
	aAdd(aRegs,{cPerg,"04","Armazem até: "				,"mv_ch4","C",02,0,0,"G","naovazio()","mv_par04","","","","","","","","","","","","","","","","024"})
	aAdd(aRegs,{cPerg,"05","Tipo de: "					,"mv_ch5","C",02,0,0,"G","","mv_par05","","","","","","","","","","","","","","","02",""})
	aAdd(aRegs,{cPerg,"06","Tipo até: "					,"mv_ch6","C",02,0,0,"G","NaoVazio()","mv_par06","","","","","","","","","","","","","","","02",""})
	aAdd(aRegs,{cPerg,"07","Grupo de:"					,"mv_ch7","C",04,0,0,"G","","mv_par07","","","","","","","","","","","","","","","SBM",""})
	aAdd(aRegs,{cPerg,"08","Grupo até:"					,"mv_ch8","C",04,0,0,"G","","mv_par08","","","","","","","","","","","","","","","SBM",""})
	aAdd(aRegs,{cPerg,"09","Classe:"					,"mv_ch9","C",04,0,0,"G","u_f_Classe()","mv_par09","","","","","","","","","","","","","","","",""})

	For i := 1 to Len(aRegs)
		PutSX1(aRegs[i,1],aRegs[i,2],aRegs[i,3],aRegs[i,3],aRegs[i,3],aRegs[i,4],aRegs[i,5],aRegs[i,6],aRegs[i,7],;
		aRegs[i,8],aRegs[i,9],aRegs[i,10],iif(len(aRegs[i])>=26,aRegs[i,26],""),aRegs[i,27],"",aRegs[i,11],aRegs[i,12],;
		aRegs[i,12],aRegs[i,12],aRegs[i,13],aRegs[i,15],aRegs[i,15],aRegs[i,15],aRegs[i,18],aRegs[i,18],aRegs[i,18],;
		aRegs[i,21],aRegs[i,21],aRegs[i,21],aRegs[i,24],aRegs[i,24],aRegs[i,24])

	Next i

	dbSelectArea(_sAlias)

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} SIEST01L
Legenda da rotina.

@type function
@author Leonardo Soncin
@since 02/12/2011
@version P12.1.23

@obs Projeto ELO

@history 21/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Fixo Verdadeiro.

/*/
/*/================================================================================================================================/*/

User Function SIEST01L()

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	BrwLegenda( "Status", "Legenda", {	{ "BR_VERDE"	, "Digitação em andamento"  	},;
	{ "BR_AMARELO"	, "Digitação confirmada"		},;
	{ "BR_VERMELHO"	, "Inventário concluído"	} } )

Return .T.

/*/================================================================================================================================/*/
/*/{Protheus.doc} SIEST01G
Gera Inventario (SB7) .

@type function
@author Leonardo Soncin
@since 02/12/2011
@version P12.1.23

@obs Projeto ELO

@history 21/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function SIEST01G

	Local aArea := GetArea()
	Local nOpc 	:= 3 //Inclusao
	Local aItens:= {}

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If SZK->ZK_STATUS == "1"

		dbSelectArea("SZL")
		SZL->(dbSetOrder(1))
		SZL->(dbSeek(xFilial("SZL")+SZK->ZK_DOC))

		While SZL->(!Eof()) .and. SZL->ZL_FILIAL == xFilial("SZL") .AND. SZL->ZL_DOC == SZK->ZK_DOC

			AADD( aItens , {SZL->ZL_COD	, SZL->ZL_LOCAL , SZL->ZL_DOC, SZL->ZL_QUANT, SZL->ZL_LOTECTL , SZL->ZL_NUMLOTE } )

			dbSelectArea("SZL")
			SZL->(dbSkip())
		EndDo

		IF 	xGerInv(aItens,nOpc)
			dbSelectArea("SZK")
			RecLock("SZK",.F.)
			SZK->ZK_STATUS := "2"
			SZK->(MsUnLock())
		Endif

	Else
		Help(" ",1, "OPCINV","Opção inválida","O status do registro nao permite esta operação.",1,0 )
	Endif
	RestArea(aArea)
Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} xGerInv
Geracao de Registro de Inventario - Integracao MsExecAuto().

@type function
@author Leonardo Soncin
@since 12/04/2006
@version P12.1.23

@param aItens, Array, Array com valores dos campos.
@param nOpc, Numérico, Código da opção do ExecAuto.

@obs Projeto ELO

@history 21/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Verdadeiro ou Falso para sucesso na operação do ExecAuto.

/*/
/*/================================================================================================================================/*/

Static Function xGerInv(aItens,nOpc)

	Local aRotAuto := {}
	Private lMsHelpAuto := .T. //Se .t. direciona as msgs de help para o arq. de log.
	Private lMsErroAuto := .F. //Nessecario a criacao, pois sera atualizado quando houver alguma inconsistencia nos parametros

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	Begin Transaction

		For nX := 1 to Len(aItens)

			aRotAuto := {	    {"B7_FILIAL"	,xFilial("SB7")				,Nil},;
			{"B7_COD"		,aItens[nX][1]				,Nil},;
			{"B7_LOCAL"		,aItens[nX][2]				,Nil},;
			{"B7_DOC"		,aItens[nX][3]			    ,Nil},;
			{"B7_QUANT"		,aItens[nX][4]				,Nil},;
			{"B7_LOTECTL"	,aItens[nX][5]				,Nil},;
			{"B7_NUMLOTE"	,aItens[nX][6]				,Nil},;
			{"B7_DATA"		,SZK->ZK_DATA				,Nil},;
			{"B7_XORIGEM"	,"SIESTA01"			 		,Nil}}

			MSExecAuto({|x,y| MATA270(x,y)},aRotAuto,nOpc)

			If lMsErroAuto
				DisarmTransaction()
				Break
			Endif

		Next nX

	End Transaction

	If lMsErroAuto
		MostraErro()
	Endif

Return(!lMsErroAuto)

/*/================================================================================================================================/*/
/*/{Protheus.doc} xSIESTGRV
Geracao de Registro de Inventario - Integracao MsExecAuto().

@type function
@author Leonardo Soncin
@since 12/04/2006
@version P12.1.23

@param aCols, Array, aCols do GetDados.
@param aHeader, Array, aHeader do GetDados.
@param nUsado, Numérico, Indica a posição no aCols que indica linha deletada.
@param aRegNo, Array, Lista dos RECNO´s dos registros.
@param nOpc, Numérico, Código da Opção.

@obs Projeto ELO

@history 21/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function xSIESTGRV(aCols,aHeader,nUsado,aRegNo,nOpc)

	Local bCampo 	 := {|nCPO| Field(nCPO) }

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	dbSelectArea("SZK")
	SZK->(dbSetOrder(1))

	If !nOpc == 5

		If SZK->(MsSeek(xFilial("SZK")+M->ZK_DOC))
			RecLock("SZK",.F.)
		Else
			RecLock("SZK",.T.)
		EndIf

		For nX := 1 TO FCount()
			FieldPut(nX,M->&(EVAL(bCampo,nX)))
		Next nX
		SZK->ZK_FILIAL := xFilial("SZK")

		SZK->(MsUnLock())

		SZK->(FkCommit(.T.))

		//+--------------------------------------------------------------+
		//|Grava os itens                                                |
		//+--------------------------------------------------------------+
		For nX := 1 To Len(aCols)

			lTravou := .F.

			dbSelectArea("SZL")

			If nX <= Len(aRegNo)
				SZL->(dbGoto(aRegNo[nX]))
				RecLock("SZL",.F.)
				lTravou := .T.
			EndIf

			If ( !aCols[nX][nUsado+1] )
				If !lTravou
					RecLock("SZL",.T.)
				EndIf
				For nY := 1 to Len(aHeader)
					If aHeader[nY][10] <> "V"
						SZL->(FieldPut(FieldPos(aHeader[nY][2]),aCols[nX][nY]))
					EndIf
				Next nY
				SZL->ZL_FILIAL 	:= xFilial("SZL")
				SZL->ZL_DOC 	:= M->ZK_DOC

				If Empty(FieldGet(FieldPos("ZL_USER")))
					SZL->ZL_USER := USRRETNAME(RETCODUSR())
				Endif

				SZL->(MsUnLock())
				lGravou := .T.
			Else
				If lTravou
					SZL->(dbDelete())
				EndIf
			EndIf
			SZL->(MsUnLock())
		Next nX

	Else

		dbSelectArea("SZL")
		SZL->(dbSetOrder(1))
		SZL->(MsSeek(xFilial("SZL")+M->ZK_DOC))
		While ( SZL->(!Eof()) .And. xFilial("SZL") == SZL->ZL_FILIAL .And. M->ZK_DOC == SZL->ZL_DOC )
			RecLock("SZL")
			dbDelete()
			SZL->(MsUnLock())
			SZL->(dbSelectArea("SZL"))
			SZL->(dbSkip())
		EndDo

		dbSelectArea("SZK")
		SZK->(dbSetOrder(1))
		If SZK->(MsSeek(xFilial("SZK")+M->ZK_DOC))
			RecLock("SZK")
			dbDelete()
			SZK->(MsUnLock())
		EndIf

	Endif

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} SIE1SgUm
Calcula e inicializa campos da segunda unidade de medida.

@type function
@author Eveli Morasco
@since 29/01/1992
@version P12.1.23

@param nUM, numeric, Indica se é a 1- ou 2ª unidade de medida.

@obs Projeto ELO

@history 21/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Fixo Verdadeiro.

/*/
/*/================================================================================================================================/*/

User Function SIE1SgUm(nUM)
	Local nPosQT   := 0
	Local nX       := 0
	Local cCod     := ""
	Local nPosCod 		:= aScan(aHeader,{|x| AllTrim(x[2])=="ZL_COD"})
	Local nPosQuant 	:= aScan(aHeader,{|x| AllTrim(x[2])=="ZL_QUANT"})
	Local nPosQtSegUm 	:= aScan(aHeader,{|x| AllTrim(x[2])=="ZL_QTSEGUM"})

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	cCod := aCols[n,nPosCod]

	dbSelectArea("SB1")
	SB1->(dbSeek(xFilial("SB1")+cCod))

	If nUm == 1
		aCols[n][nPosQtSegUm] := ConvUm(cCod,If(ReadVar()=="M->ZL_QUANT",M->ZL_QUANT,aCols[n,nPosQuant]),aCols[n][nPosQtSegUm],2)
	Else
		aCols[n][nPosQuant] := ConvUm(cCod,aCols[n,nPosQuant],If(ReadVar()=="M->ZL_QTSEGUM",M->ZL_QTSEGUM,aCols[n][nPosQtSegUm]),1)
	Endif

Return .T.

/*/================================================================================================================================/*/
/*/{Protheus.doc} SIEST01E
Estorna Geração do Inventário (SB7).

@type function
@author Leonardo Soncin
@since 05/12/2011
@version P12.1.23

@obs Desenvolvimento FIEG

@history 21/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function SIEST01E()

	Local aArea 	:= GetArea()
	//Local aItens 	:= {}
	//Local nOpc 		:= 5
	Local cQuery 	:= ""
	Local cAliasDel := GetNextAlias()
	Local lRet 		:= .F.
	Local lTodosNao := .F.
	Local lTodosSim := .F.
	Local cMsg 		:= ""
	Local nOpcA     := 0

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	dbSelectArea("SB2")
	SB2->(dbSetOrder(1))

	If SZK->ZK_STATUS == "2"

		// Deleta SB7
		cQuery := "SELECT R_E_C_N_O_ AS NREG FROM "
		cQuery += RetSqlName("SB7")+" "
		cQuery += " WHERE B7_FILIAL = '"+xFilial("SB7")+"' AND B7_DOC = '"+SZK->ZK_DOC+"' AND "
		cQuery += " D_E_L_E_T_ <> '*' "

		cQuery := ChangeQuery(cQuery)

		If Select(cAliasDel) > 0
			dbSelectArea(cAliasDel)
			(cAliasDel)->(dbCloseArea())
		Endif

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDel,.T.,.F.)

		DbSelectArea(cAliasDel)
		(cAliasDel)->(dbGotop())

		If (cAliasDel)->(!Eof())

			While (cAliasDel)->(!Eof())

				dbSelectArea("SB7")
				SB7->(dbgoTo((cAliasdel)->NREG))

				dbSelectArea("SB2")
				If SB2->(dbSeek(xFilial("SB2")+SB7->B7_COD+SB7->B7_LOCAL) .And. (SB2->B2_DINVENT == SB7->B7_DATA))

					cMsg := "Ja foi processado inventario para o produto: "+Alltrim(SB7->B7_COD)+" no armazem: "+Alltrim(SB7->B7_LOCAL) +" na data: "+Dtoc(SB7->B7_DATA)+" , confirma a exclusao ?"

					If      lTodosSim
						nOpcA := 1
					ElseIf  lTodosNao
						nOpcA := 2
					Else
						nOpcA := Aviso( "Atenção", cMsg, { "Sim", "Não", "Sim p/Todos", "Não p/Todos" }, 3, "Exclusão de Inventário" )
						lTodosSim := ( nOpcA == 3 )
						lTodosNao := ( nOpcA == 4 )

						If lTodosSim
							nOpcA := 1
						EndIf

						If lTodosNao
							nOpcA := 2
						EndIf

					EndIf
				Else
					nOpcA := 1
				EndIf


				If nOpcA == 1
					dbSelectArea("SB7")
					RecLock("SB7",.F.)
					SB7->(dbDelete())
					SB7->(MsUnLock())
					lRet := .T.
				EndIf

				dbSelectArea(cAliasDel)
				(cAliasDel)->(dbSkip())
			EndDo

		Endif

		IF 	lRet //xGerInv(aItens,nOpc)
			dbSelectArea("SZK")
			RecLock("SZK",.F.)
			SZK->ZK_STATUS := "1"
			SZK->(MsUnLock())
		Endif

	Else
		Help(" ",1, "OPCINV","Opção inválida","O status do registro nao permite esta operação.",1,0 )
	Endif

	RestArea(aArea)
Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} f_Classe
Selecionar a Situacao do Func. com Base no SX5.

@type function
@author José Maria
@since 13/04/1995
@version P12.1.23

@param l1Elem, Lógico, Se a Selecao sera de apenas 1 Elemento por vez.
@param lTipoRet, Lógico, Indica o tipo de retorno.

@obs Projeto ELO

@history 21/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Indefinido, Retorno conforme tipo indicado.

/*/
/*/================================================================================================================================/*/

User Function f_Classe(l1Elem,lTipoRet)

	Local cTitulo:=""
	Local MvPar
	Local MvParDef:=""

	Private aSit:={}

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	l1Elem := If (l1Elem = Nil , .F. , .T.)

	DEFAULT lTipoRet := .T.

	cAlias := Alias() 					 // Salva Alias Anterior

	IF lTipoRet
		MvPar:=&(Alltrim(ReadVar()))		 // Carrega Nome da Variavel do Get em Questao
		mvRet:=Alltrim(ReadVar())			 // Iguala Nome da Variavel ao Nome variavel de Retorno
	EndIF

	aSit := {;
	"  - Sem Classificação " ,;
	"A - Classe A " ,;
	"B - Classe B" ,;
	"C - Classe C" ;
	}

	MvParDef:=" ABC"
	cTitulo := "Escolha Classe"

	IF lTipoRet
		IF f_Opcoes(@MvPar,cTitulo,aSit,MvParDef,12,49,l1Elem)  // Chama funcao f_Opcoes
			&MvRet := mvpar                                                                          // Devolve Resultado
		EndIF
	EndIF

	dbSelectArea(cAlias) 								 // Retorna Alias

Return( IF( lTipoRet , .T. , MvParDef ) )

/*/================================================================================================================================/*/
/*/{Protheus.doc} xGet2Chg
Altera a edicao dos campos na edicao dos itens.

@type function
@author Leonardo Soncin
@since 13/12/2011
@version P12.1.23

@obs Projeto ELO

@history 21/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Fixo Verdadeiro.

/*/
/*/================================================================================================================================/*/

Static Function xGet2Chg()

	Local nPosOrig 	:= aScan(oBrw:aHeader,{|x| Alltrim(x[2]) == "ZL_USER"})
	Local aAlter 	:= {}

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If nPosOrig > 0
		//+----------------------------------------------------------+
		//|Permite alterar parcelas que nao tenham sido  apropriadas |
		//+----------------------------------------------------------+
		If Alltrim(oBrw:aCols[oBrw:nAt,nPosOrig]) == 'SIESTA01'

			//+-----------------------------------------------------+
			//|Libera apenas campo de quantidade e desconto para    |
			//|edicao                                               |
			//+-----------------------------------------------------+
			aAdd(aAlter,"ZL_QUANT")
			aAdd(aAlter,"ZL_QTSEGUM")
			oBrw:OBROWSE:aAlter := aAlter
		Else
			//+-----------------------------------------------------+
			//|Libera campos para inclusao de item                  |
			//+-----------------------------------------------------+
			aAdd(aAlter,"ZL_COD")
			aAdd(aAlter,"ZL_LOCAL")
			aAdd(aAlter,"ZL_CLASSE")
			aAdd(aAlter,"ZL_QUANT")
			aAdd(aAlter,"ZL_QTSEGUM")
			aAdd(aAlter,"ZL_LOTECTL")
			aAdd(aAlter,"ZL_NUMLOTE")
			oBrw:OBROWSE:aAlter := aAlter
		EndIf
	EndIf

Return .T.

/*/================================================================================================================================/*/
/*/{Protheus.doc} ESTA1LOk
Confere se a linha digitada esta OK.

@type function
@author Leonardo Soncin
@since 11/12/2011
@version P12.1.23

@obs Projeto ELO

@history 21/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Verdadeiro ou Falso para validação da Linha.

/*/
/*/================================================================================================================================/*/

User FuncTion ESTA1LOk()
	Local lRet := .T.
	Local nX, lDuplicado := .F.
	Local nPosCod		:= Ascan(aHeader, {|e| Alltrim(e[2]) = "ZL_COD"} )
	Local nPosLocal		:= Ascan(aHeader, {|e| Alltrim(e[2]) = "ZL_LOCAL"} )
	Local nPosLote		:= Ascan(aHeader, {|e| Alltrim(e[2]) = "ZL_LOTECTL"} )
	Local nPosSubLote	:= Ascan(aHeader, {|e| Alltrim(e[2]) = "ZL_NUMLOTE"} )

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If nPosCod > 0

		// Pesquisa por item ja cadastrado
		For nX := 1 To Len(aCols)
			// Se encontrou um item igual ao ja cadastrado, avisa e nao permite continuar
			If !(GdDeleted( n, aHeader, aCols)) .And.;
			aCols[nX][nPosCod]+aCols[nX][nPosLocal]+aCols[nX][nPosLote]+aCols[nX][nPosSubLote] == ;
			aCols[n][nPosCod]+aCols[n][nPosLocal]+aCols[n][nPosLote]+aCols[n][nPosSubLote] .And. nX != n
				lDuplicado := .T.
				Exit
			Endif
		Next
	Endif

	// Se encontrou um titulo igual ao ja cadastrado, avisa e nao permite continuar
	If !(GdDeleted( n, aHeader, aCols)) .And. lDuplicado
		lRet := .F.
		//+------------------------------------------------------+
		//| Nao permite duplicar o numero !                      |
		//+------------------------------------------------------+
		Help(" ",1, "SI01EXIST","Item já existente.","Produto já existente, verifique por favor.",1,0 )
	Endif

Return lRet

/*/================================================================================================================================/*/
/*/{Protheus.doc} ESTA1VLt
Valida o número do lote com o produto.

@type function
@author Rodrigo de A. Sartorio
@since 16/04/1996
@version P12.1.23

@obs Projeto ELO

@history 21/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Verdadeiro ou Falso para validação do Número do Lote.

/*/
/*/================================================================================================================================/*/

User Function ESTA1VLt()
	Local cVar:=ReadVar(),cConteudo:=&(ReadVar())
	Local cAlias:=Alias(),nRecno:=Recno(),nOrdem:=IndexOrd()
	Local lRet:=.T.
	Local cCod,cLocal,cLote,cSubLote
	Local lHelp := .T.

	Local nPosCod		:= Ascan(aHeader, {|e| Alltrim(e[2]) = "ZL_COD"} )
	Local nPosLocal		:= Ascan(aHeader, {|e| Alltrim(e[2]) = "ZL_LOCAL"} )
	Local nPosLote		:= Ascan(aHeader, {|e| Alltrim(e[2]) = "ZL_LOTECTL"} )
	Local nPosSubLote	:= Ascan(aHeader, {|e| Alltrim(e[2]) = "ZL_NUMLOTE"} )

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	cCod      := If(!Empty(nPosCod),aCols[n,nPosCod],CriaVar('ZL_COD'))
	cLocal    := If(!Empty(nPosLocal),aCols[n,nPosLocal],CriaVar('ZL_LOCAL'))
	cLote     := If(!Empty(nPosLote),aCols[n,nPosLote],CriaVar('ZL_LOTECTL'))
	cSubLote  := If(!Empty(nPosSubLote),aCols[n,nPosSubLote],CriaVar('ZL_NUMLOTE'))

	If !Rastro(cCod)
		Help(" ",1,"NAORASTRO")
		lRet:=.F.
	EndIf

	If lRet
		If cVar == "M->ZL_LOTECTL"
			If Rastro(cCod,"S")
				If !Empty(cLote)
					dbSelectArea("SB8")
					SB8->(dbSetOrder(2))
					If SB8->(dbSeek(xFilial()+cLote) .And. cCod+cLocal == SB8->B8_PRODUTO+SB8->B8_LOCAL)
						If cConteudo != SB8->B8_LOTECTL
							Help(" ",1,"A240LOTCTL")
							lRet:=.F.
						EndIf
					EndIf
				EndIf
			Endif

		ElseIf cVar == "M->ZL_NUMLOTE"
			If Rastro(cCod,"S")
				If lRet
					dbSelectArea("SB8")
					SB8->(dbSetOrder(2))
					If SB8->(dbSeek(xFilial()+cConteudo) .And. cCod+cLocal == SB8->B8_PRODUTO+SB8->B8_LOCAL)
						If !Empty(nPosLote)
							aCols[n,nPosLote]:=M->ZL_NUMLOTE
						EndIf
						M->ZL_LOTECTL:=SB8->B8_LOTECTL

						//If !Empty(nPosLotCTL)
						//aCols[n,nPosLotCTL]:=M->D3_LOTECTL
						//EndIf

					EndIf
				EndIf
			Else
				M->ZL_NUMLOTE:=CriaVar("ZL_NUMLOTE")
				If !Empty(nPosLote)
					aCols[n,nPosLote]:=M->ZL_NUMLOTE
				EndIf

			EndIf
		EndIf
	EndIf
	dbSelectArea(cAlias)
	(cAlias)->(dbSetOrder(nOrdem))
	(cAlias)->(dbGoTo(nRecno))
Return lRet