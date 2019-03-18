#Include "Protheus.ch"
#Include "TopConn.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} DoitLegenda
Funcao utilizada para mostrar tela de legenda e permitir que ao clicar na legenda seja aplicado um filtro da legenda selecionada.

@type function
@author Amauri Bailon
@since 28/07/2010
@version P12.1.23

@param cTitulo, Caractere, Título da janela.
@param cMensagem, Caractere, Mensagem.
@param aCores, Array, Array Com as cores que serão mostradas.
@param nXSize, Numérico, Tamanho da descrição da Legenda.
@param cAlias, Caractere, Nome do alias da Tabela.
@param cFiltPad, Caractere, Filtro padrao (Que o botao limpar filtro usa caso informado).
@param lFilTop, Lógico, Verdadeiro ou Falso indicando se Filtro por TopConnect.
@param lAnt, Lógico, Verdadeiro ou Falso indicando se exibe botão de Limpa Filtro.

@obs Desenvolvimento FIEG

@history 18/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function DoitLegenda(cTitulo,cMensagem,aCores,nXSize,cAlias,cFiltPad,lFilTop,lAnt)

	Local nY       			:= 0
	Local nX       			:= 0
	Local aBmp[Len(aCores)]
	Local aSays[Len(aCores)]
	Local cLimpFilt			:= ""
	Local cFilTop			:= ""

	Private oDlgLeg
	Private _cFilBrw		:= ""
	Private _aInd			:= {}

	DEFAULT  nXSize			:= 14
	DEFAULT  cFiltPad		:= ""
	DEFAULT  lFilTop		:= .F.
	DEFAULT  lAnt			:= .T.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If lAnt
		If !Empty(cFiltPad)
			cLimpFilt := "{|NROW,NCOL,NKEYFLAGS| U_ExecFilter('"+cAlias+"','"+cFiltPad+"'), oDlgLeg:End() }"
		EndIf

		If lFilTop
			cFilTop:= "S"
		EndIf

		DEFINE MSDIALOG oDlgLeg FROM 0,0 TO (Len(aCores)*20)+65,320 TITLE cTitulo OF oMainWnd PIXEL

		//+----------------------------------------------+
		//|Fonte especifico para a descricao das legendas|
		//+----------------------------------------------+
		DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD

		//+----------------+
		//|Desenho de fundo|
		//+----------------+
		@ 0, 0 BITMAP RESNAME "PROJETOAP" OF oDlgLeg SIZE 35,155 NOBORDER WHEN .F. PIXEL

		@ 11,35 TO 013,400 LABEL '' OF oDlgLeg PIXEL
		@ 03,37 SAY cMensagem OF oDlgLeg PIXEL SIZE 100,009 FONT oBold
		For nX := 1 to Len(aCores)
			@ 20+((nX-1)*10),43 BITMAP aBmp[nX] RESNAME aCores[nX][1] OF oDlgLeg SIZE 20,10 PIXEL NOBORDER
			aBmp[nX]:BlClicked := MontaBlock("{|NROW,NCOL,NKEYFLAGS| U_ExecFilter('"+cAlias+"','"+aCores[nX][3]+"','"+cFilTop+"'), oDlgLeg:End() }")
			@ 20+((nX-1)*10),(nXSize/2) + 46 SAY aSays[nX] Var If((nY+=1)==nY,aCores[nY][2]+If(nY==Len(aCores),If((nY:=0)==nY,"",""),""),"") OF oDlgLeg PIXEL
			aSays[nX]:BlClicked :=  MontaBlock("{|NROW,NCOL,NKEYFLAGS| U_ExecFilter('"+cAlias+"','"+aCores[nX][3]+"','"+cFilTop+"'), oDlgLeg:End() }")
			If nX == Len(aCores)
				@ 20+((nX)*10),63 BUTTON OemToAnsi("Limpa Filtro") SIZE 040,11 FONT oBold ACTION (If(Empty(cFiltPad),(ClrFilter(cAlias, _aInd, lFilTop ) ,oDlgLeg:End()),(Eval(MontaBlock(cLimpFilt))))) OF oDlgLeg PIXEL
			EndIf
		Next nX
		nY := 0

		ACTIVATE MSDIALOG oDlgLeg CENTERED

	Else
		If !Empty(cFiltPad)
			cLimpFilt := '{|NROW,NCOL,NKEYFLAGS| U_ExecFilter("'+cAlias+'","'+cFiltPad+'"), oDlgLeg:End() }'
		EndIf

		If lFilTop
			cFilTop:= "S"
		EndIf

		DEFINE MSDIALOG oDlgLeg FROM 0,0 TO (Len(aCores)*20)+65,320 TITLE cTitulo OF oMainWnd PIXEL

		//+----------------------------------------------+
		//|Fonte especifico para a descricao das legendas|
		//+----------------------------------------------+
		DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD

		//+----------------+
		//|Desenho de fundo|
		//+----------------+
		@ 0, 0 BITMAP RESNAME "PROJETOAP" OF oDlgLeg SIZE 35,155 NOBORDER WHEN .F. PIXEL

		@ 11,35 TO 013,400 LABEL '' OF oDlgLeg PIXEL
		@ 03,37 SAY cMensagem OF oDlgLeg PIXEL SIZE 100,009 FONT oBold
		For nX := 1 to Len(aCores)
			@ 20+((nX-1)*10),43 BITMAP aBmp[nX] RESNAME aCores[nX][1] OF oDlgLeg SIZE 20,10 PIXEL NOBORDER
			//aBmp[nX]:BlClicked := MontaBlock('{|NROW,NCOL,NKEYFLAGS| U_ExecFilter("'+cAlias+'","'+aCores[nX][3]+'","'+cFilTop+'"), oDlgLeg:End() }')
			aBmp[nX]:BlClicked := MontaBlock('{|NROW,NCOL,NKEYFLAGS| _cFilBrw := "'+aCores[nX][3]+'", oDlgLeg:End() }')
			@ 20+((nX-1)*10),(nXSize/2) + 46 SAY aSays[nX] Var If((nY+=1)==nY,aCores[nY][2]+If(nY==Len(aCores),If((nY:=0)==nY,"",""),""),"") OF oDlgLeg PIXEL
			//aSays[nX]:BlClicked :=  MontaBlock('{|NROW,NCOL,NKEYFLAGS| U_ExecFilter("'+cAlias+'","'+aCores[nX][3]+'","'+cFilTop+'"), oDlgLeg:End() }')
			aSays[nX]:BlClicked :=  MontaBlock('{|NROW,NCOL,NKEYFLAGS| _cFilBrw := "'+aCores[nX][3]+'", oDlgLeg:End() }')
			If nX == Len(aCores)

			EndIf
		Next nX
		nY := 0

		ACTIVATE MSDIALOG oDlgLeg CENTERED

		If !Empty(_cFilBrw)
			U_ExecFilter(cAlias,_cFilBrw,cFilTop)
		EndIf

	EndIf

Return(NIL)

/*/================================================================================================================================/*/
/*/{Protheus.doc} ExecFilter
Funcao utilizada para executar o filtro no browse conforme a cor da legenda selecionada.

@type function
@author Amauri Bailon
@since 29/07/2010
@version P12.1.23

@param cAlias, Caractere, Alias da tabela.
@param _cFilBrw, Caractere, String para filtro.
@param cFilTop, Caractere, Filtro por TopConnect.

@obs Desenvolvimento FIEG

@history 18/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function ExecFilter(cAlias, _cFilBrw, cFilTop)

	Local lBrwAllFil:= VerSenha(114) // Verifica se Usuario Visualiza todas filiais pelo MBrowse

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	IF cFilTop == "S"
		// Limpa Filtro
		// SetMBTopFilter(cAlias, cExprFilTop, lTcSqlFilter, lClear)
		// Converte para expressao SQL
		_cFilBrw:= StrTran(StrTran(StrTran(_cFilBrw,".",""),"==","="),'"',"'")
		(cAlias)->(dbGoBottom())
		IF lBrwAllFil
			SetMBTopFilter(cAlias, PrefixoCpo(cAlias)+"_FILIAL"+" >= ' ' And "+_cFilBrw  , .T., .T.)
		ELSE
			SetMBTopFilter(cAlias, PrefixoCpo(cAlias)+"_FILIAL"+" = '"+xFilial(cAlias)+"' And "+_cFilBrw , .T., .T.)
		ENDIF
		(cAlias)->(dbGoBottom())
	ELSE
		dbSelectArea(cAlias)
		EndFilBrw(cAlias, _aInd)
		FilBrowse(cAlias,@_aInd,@_cFilBrw)
	ENDIF

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} ClrFilter
Descrição detalhada da função.

@type function
@author Thiago Rasmussen
@since
@version P12.1.23

@param cAlias, Caractere, Alias da tabela.
@param _aInd, Array, Array de retorno passado por referência para a FilBrowse().
@param lFilTop, Lógico, Filtro por TopConnect.

@obs Desenvolvimento FIEG

@history 18/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.


/*/
/*/================================================================================================================================/*/

Static Function ClrFilter(cAlias, _aInd, lFilTop )
	Local lBrwAllFil := VerSenha(114) // Verifica se Usuario Visualiza todas filiais pelo MBrowse

	DEFAULT lFilTop:= .F.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	IF lFilTop
		IF lBrwAllFil
			SetMBTopFilter(cAlias, PrefixoCpo(cAlias)+"_FILIAL"+" >= ' '" , .T., .T.)
		ELSE
			SetMBTopFilter(cAlias, PrefixoCpo(cAlias)+"_FILIAL"+" = '"+xFilial(cAlias)+"'" , .T., .T.)
		ENDIF
	ELSE
		EndFilBrw(cAlias, _aInd)
	ENDIF

Return
