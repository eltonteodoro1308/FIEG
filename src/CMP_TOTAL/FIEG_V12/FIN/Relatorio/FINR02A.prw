#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} FINR02A
Relatório de fluxo de caixa projetado - diario/mensal.

@type function
@author Caio Renan
@since 12/01/2015
@version P12.1.23

@obs Desenvolvimento FIEG

Campos criados
SED
ED_XTIPO caracter 1 Tipo natureza
O=OPERACIONAL;I=INVESTIMENTOS;F=FINANCIAMENTOS

Esse relatorio fuciona de acordo com o compartilhamento da SED
caso a natureza seja exclusiva esse relatorio funciona de maneira exclusiva
caso SED seja compartilhada o relatorio funciona de maneira compartilhada.

Obs.:
O relatorio ira gerar uma tabela temporaria (_cALiasTmp)
Campos : ORDEM,XTIPO,CODIGO,DESCRIC,VALORN~
ORDEM  1F - BANCOS  |   2F - PEDIDOS | 3F - NATUREZAS  |     				 |
ORDEM  1T - TOT.Bcos|   2T - Tot.Ped | 3T - Tot.Nat    | 4T  - Tot. Geral    |

@history 29/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Objeto, Objeto que representa o relatório.

/*/
/*/================================================================================================================================/*/

User Function FINR02A()
	Local oReport
	Local _lContinua := .T.

	Private _cPerg     := "FINR02A"
	Private _cALias    := GetNextAlias()
	Private _cALiasTmp := GetNextAlias()
	Private _cArqTrab  := Nil
	Private _oFluxo , _oTotal, _oSinte // variaveis dos objetos de secao
	Private _cPicture := TM(999999999.99,14,2) // "@E 999,999,999.99"

	Private _bPrint := {|oReport| Alert("Erro") }

	Private _aCols := {}
	/*  N,1 - Data em Caracter
	/   N,2 - Data em string
	*/
	Private _aSldIniT  := {}  // Total de saldo inicial por dia
	Private _aTotGeral := {} 	// total geral do relatorio
	Private _aTotTip   := {} 		// total por tipo de natureza
	Private _aTotNatS  := {} 	// totalizador por natureza sintetica cada linha do array primeira posicao e o codigo da natureza o restantes são todas os valores somados
	Private _aTotPC	   := {}
	Private _aSelFil   := {}
	Private _lTdasFil  := .F.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	AjustaSX1(_cPerg)

	// e necessario a apresentação da tela de pergunta antes pois as colunas serao dinamicas de acordo com as perguntas.
	// se parametro tipo igual a dia (MV_PAR02 == 1) tera uma coluna para cada dia entre o intervalos das datas
	// de MV_PAR04 ate MV_PAR05 se parametro tipo igual a mes (MV_PAR02 == 2) tera uma coluna para cada mes entre o intervalo das datas
	// de MV_PAR04 ate MV_PAR05
	If Pergunte(_cPerg, .T.)
		_lContinua := .T.
		// enquanto nao passar pela validacao dos parametros continua aparecendo a tela para as perguntas
		While _lContinua .AND. !fValPar()
			If !Pergunte(_cPerg, .T.)
				_lContinua := .F.
			EndIf
		EndDo
	Else
		_lContinua := .F.
	EndIf

	//--------------------------------------------------------------+
	// Seleciona Filial = Sim                                       |
	//--------------------------------------------------------------+
	If MV_PAR07 == 1
		If Empty(_aSelFil)
			_aSelFil := AdmGetFil(@_lTdasFil,.F.,"SED")
		Endif
	Endif

	//--------------------------------------------------------------+
	// Caso MV_PAR07 == 2 ou nao marcar nehuma filial.              |
	// Defino a filial logada                                       |
	//--------------------------------------------------------------+
	If Empty(_aSelFil)
		Aadd(_aSelFil,cFilAnt)
	Endif


	If _lContinua
		If FindFunction("TRepInUse")
			oReport := ReportDef()
			oReport:PrintDialog()
		EndIf
	EndIf

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} ReportDef
Função de definições dos objetos Treport.

@type function
@author Caio Renan
@since 12/01/2015
@version P12.1.23

@obs Desenvolvimento FIEG

@history 29/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Objeto, Objeto que representa o relatório.

/*/
/*/================================================================================================================================/*/

Static Function ReportDef()
	Local oReport
	Local _cDescri := "Fluxo de caixa projetado"

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	_aCols := fGetACol()

	oReport := TReport():New(_cPerg,_cDescri,_cPerg,{|oReport| PrintReport(oReport)},_cDescri)
	oReport:SetLeftMargin(2)
	oReport:SetLandScape() 			// paisagem
	oReport:oPage:SetPaperSize(9) 	// papel A4
	oReport:SetDevice(4) 			// local
	oReport:SetEnvironment(2) 		// local
	oReport:SetTotalInLine(.F.)
	oReport:ParamReadOnly(.T.)

	_oFluxo := TRSection():New(oReport,"Fluxo de caixa projetado",{_cALiasTmp} )
	TRCell():New(_oFluxo, "DESCRIC" ,_cALiasTmp , "Saldo inicial (bancos)", "")

	For _nx := 1 To Len(_aCols)
		TRCell():New(_oFluxo,  _aCols[_nx,2] ,_cALiasTmp, _aCols[_nx,1] ,_cPicture , 14, , {|| 0 }  )
	Next

	// secao para totalizar
	_oTotal := TRSection():New(oReport,"Total",{_cALiasTmp} )
	TRCell():New(_oTotal, "DESCRIC" ,_cALiasTmp , "Saldo inicial (bancos)", "")

	For _nx := 1 To Len(_aCols)
		TRCell():New(_oTotal,  _aCols[_nx,2] ,_cALiasTmp, _aCols[_nx,1] ,_cPicture , 14, , {|| 0 }  )
	Next

	_oTotal:lHeaderSection := .F.
	_oTotal:nLinesBefore := 0
	_oTotal:SetCellBorder("TOP" , 1 , , .F.)
	_oTotal:SetCellBorder("BOTTOM" , 1 , , .F.)

Return(oReport)

/*/================================================================================================================================/*/
/*/{Protheus.doc} fGetACol
Função que retorna um array com cada coluna do relatorio.

@type function
@author Caio Renan
@since 12/01/2015
@version P12.1.23

@obs Desenvolvimento FIEG

@history 29/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Array, Array com cada coluna do relatorio.

/*/
/*/================================================================================================================================/*/

Static Function fGetACol()
	Local _aRet := {}
	Local _nQtdCol := fGetQtdCol()
	Local _dDtCol := MV_PAR04
	Local _cDtCol := DToC(_dDtCol)
	Local _SDtCol := DToS(_dDtCol)
	Local _nMes := month(MV_PAR04)
	Local _nAno := year(MV_PAR04)

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	For _nx := 1 To _nQtdCol

		If MV_PAR02 == 1 // tipo igual dia
			// primeira posicao conforme layout segunda coluna conforme necessario no select
			Aadd(_aRet , { _cDtCol , _SDtCol  } )

			_dDtCol := _dDtCol + 1
			_cDtCol := DToC(_dDtCol)
			_SDtCol := DToS(_dDtCol)


		ElseIf MV_PAR02 == 2 // tipo igual mes
			// primeira posicao conforme layout segunda coluna conforme necessario no select
			Aadd(_aRet , { StrZero(_nMes,2) + "/" + cValToChar(_nAno) , cValToChar(_nAno) + StrZero(_nMes,2) } )

			_nMes++
			If _nMes > 12
				_nMes := 1
				_nAno++
			EndIf
		EndIf
	Next

	//MemoWrite("D:\LOGSQL\arrayacols"+_cPerg+".txt" , VarInfo("_aRet", _aRet ))

Return(_aRet)

/*/================================================================================================================================/*/
/*/{Protheus.doc} PrintReport
Função que realiza o filtro e imprimi os dados na tela.

@type function
@author Caio Croll
@since 15/07/2015
@version P12.1.23

@param oReport, Objeto, Objeto que representa o relatório.

@obs Desenvolvimento FIEG

@history 29/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function PrintReport(oReport)
	// tipos de naturezas disponiveis
	Local _aTipos 		:= {"O" , "I" , "F"}
	Local _aTiposDesc 	:= {"OPERACIONAL" , "INVESTIMENTO" , "FINANCIAMENTO"}
	Local _aTiposComp 	:= {"CAIXA DAS OPERACOES" , "CAIXA DOS INVESTIMENTOS" , "CAIXA DOS FINANCIAMENTOS"}
	Local cDataBase     := Iif(MV_PAR02 == 1,Dtos(dDataBase), SubStr(Dtos(dDataBase),1,6))
	Local lCompoeSld    := (MV_PAR08 == 1)
	Local lSintetico    := (MV_PAR01 == 1)
	Local lPedido       := (MV_PAR09 == 1)

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	//---------------------------------------------------------------------------------+
	// Crio Arquivo temporario para manipular valores do relatorio antes da impressão  |
	//---------------------------------------------------------------------------------+
	fArqTmp()

	// Inicializa totalizadores geral e por tipo
	For _nx := 1 To Len(_aCols)
		Aadd(_aTotGeral, 0 )
		Aadd(_aTotTip  , 0 )
		aAdd(_aTotPC   , 0 )
		aAdd(_aSldIniT , 0 )
	Next


	//--------------------------------------------------------------+
	// PRINT A PRIMEIRA LINHA DO RELATORIO REFERENTE A SALDO INICIAL|
	//--------------------------------------------------------------+


	MsgRun( "Selecionando registros - Saldos iniciais...", "Aguarde" ,  {|| fQrySldIni() } )

	//--------------------------------------------------------------+
	// Percorro  o alias na ORDEM 1f(Saldos Bancos)                 |
	//--------------------------------------------------------------+
	(_cALiasTmp)->(DbGoTop())
	(_cALiasTmp)->(DbSeek("1F"))
	While  (_cALiasTmp)->(!Eof()) .AND. (_cALiasTmp)->ORDEM == "1F"

		//--------------------------------------------------------------+
		// Obtenho o valores para o totalizador dos bancos              |
		//--------------------------------------------------------------+
		For _nx := 1 to Len(_aCols)

			_aSldIniT[_nX]+= (_cALiasTmp)->(&("VALOR"+StrZero(_nX,2)))
		Next

		(_cALiasTmp)->(dbSkip())

	EndDo

	//--------------------------------------------------------------+
	// Crio a linha do totalizador no Alias                         |
	//--------------------------------------------------------------+
	If RecLock((_cALiasTmp),.T.)

		Replace (_cAliasTmp)->(ORDEM)   With "1T"
		Replace (_cAliasTmp)->(XTIPO)   With " "
		Replace (_cAliasTmp)->(CODIGO)  With SPACE(18)
		Replace (_cAliasTmp)->(DESCRIC) With "Total Saldos iniciais"

		For _nx := 1 to Len(_aCols)

			Replace (_cAliasTmp)->(&("VALOR"+StrZero(_nX,2))) With _aSldIniT[_nX]

		Next
		(_cALiasTmp)->(MsUnlock())
	EndIf


	//---------------------------------------
	//- Pedido de Compras
	//---------------------------------------
	If lPedido

		MsgRun( "Selecionando registros - Pedido de Compras...", "Aguarde" ,  {|| fProcPC() } )

		//--------------------------------------------------------------+
		// Percorro o Alias na ORDEM 2F (PC)                            |
		//--------------------------------------------------------------+
		(_cALiasTmp)->(DbGoTop())
		(_cALiasTmp)->(DbSeek("2F"))
		While  (_cALiasTmp)->(!Eof()) .AND. (_cALiasTmp)->ORDEM == "2F"

			//--------------------------------------------------------------+
			// Obtenho os valores para criar o totalizador                  |
			//--------------------------------------------------------------+
			For _nx := 1 to Len(_aCols)

				_aTotPC[_nX]+= (_cALiasTmp)->(&("VALOR"+StrZero(_nX,2)))

			Next

			(_cALiasTmp)->(dbSkip())

		EndDo

		//--------------------------------------------------------------+
		// Crio a linha de totalizador para o PC                        |
		//--------------------------------------------------------------+
		If RecLock((_cALiasTmp),.T.)

			Replace (_cAliasTmp)->(ORDEM)   With "2T"
			Replace (_cAliasTmp)->(XTIPO)   With " "
			Replace (_cAliasTmp)->(CODIGO)  With SPACE(18)
			Replace (_cAliasTmp)->(DESCRIC) With "Total Pedido de Compra"

			For _nx := 1 to Len(_aCols)

				Replace (_cAliasTmp)->(&("VALOR"+StrZero(_nX,2))) With _aTotPC[_nX]

			Next

			(_cALiasTmp)->(MsUnlock())
		EndIf

	EndIf



	MsgRun( "Selecionando registros - Natureza...", "Aguarde" ,  {|| fProcNat() } )

	MsgRun( "Selecionando registros - "+ NGSX2NOME("SE1") +"...", "Aguarde" ,  {|| fProcSe1() } )

	MsgRun( "Selecionando registros - "+ NGSX2NOME("SE2") +"...", "Aguarde" ,  {|| fProcSe2() } )

	// totalizador por natureza sintetica
	_aTotNatS := fGetTot()

	SED->(DbSetOrder(1)) // ED_FILIAL + ED_CODIGO

	//--------------------------------------------------------------+
	// Percorro o array de tipo com base no parametro MV_PAR06      |
	//--------------------------------------------------------------+
	For _nTipo:= 1 to Len(_aTipos)

		If MV_PAR06 == 2 .AND. _aTipos[_nTipo] <> "O" // OPERACIONAL
			loop
		ElseIf MV_PAR06 == 3 .AND. _aTipos[_nTipo] <> "I" // INVESTIMENTO
			loop
		ElseIf MV_PAR06 == 4 .AND. _aTipos[_nTipo] <> "F" // FINANCIAMENTO
			loop
		EndIf
		//--------------------------------------------------------------+
		// Zero as posicoes do array                                    |
		//--------------------------------------------------------------+
		For _ny := 1 To Len(_aCols)
			_aTotTip[_ny] := 0
		Next

		//--------------------------------------------------------------+
		// Percorro o Alis na Ordem 3F (Naturezas) + XTIPO              |
		//--------------------------------------------------------------+
		(_cALiasTmp)->(DbGoTop())
		(_cALiasTmp)->(DbSeek("3F" +_aTipos[_nTipo]))
		While  (_cALiasTmp)->(!Eof()) .AND. (_cALiasTmp)->ORDEM == "3F" .AND. (_cALiasTmp)->XTIPO == _aTipos[_nTipo]

			//--------------------------------------------------------------+
			// Caso posicionar na SED atualizo a Descriçao                  |
			//--------------------------------------------------------------+
			If	SED->(DbSeek(xFilial("SED") + (_cALiasTmp)->(CODIGO)))
				If RecLock((_cALiasTmp),.F.)
					Replace (_cAliasTmp)->(DESCRIC) With  (fGetDescN())
					(_cALiasTmp)->(MsUnlock())
				EndIf
			EndIf

			//--------------------------------------------------------------+
			// Obtenho os valores por dia para criar o totalizador          |
			//--------------------------------------------------------------+
			For _nx := 1 to Len(_aCols)

				_aTotTip[_nx]+= (_cALiasTmp)->(&("VALOR"+StrZero(_nx,2)))

			Next
			(_cALiasTmp)->(dbSkip())

		EndDo


		//--------------------------------------------------------------+
		// Crio a linha do totalizador Natureza + XTIPO                 |
		//--------------------------------------------------------------+
		If RecLock((_cALiasTmp),.T.)

			Replace (_cAliasTmp)->(ORDEM)   With "3T"
			Replace (_cAliasTmp)->(XTIPO)   With _aTipos[_nTipo]
			Replace (_cAliasTmp)->(CODIGO)  With SPACE(18)
			Replace (_cAliasTmp)->(DESCRIC) With _aTiposComp[_nTipo]



			For _nx := 1 to Len(_aCols)

				Replace (_cAliasTmp)->(&("VALOR"+StrZero(_nX,2))) With (_aTotTip[_nx])

			Next
			(_cAliasTmp)->(MsUnlock())
		EndIf

	Next


	//---------------------------------------------------------------+
	// Crio a linha do totalizador geral com os saldos por dia zerado|
	//---------------------------------------------------------------+
	If Reclock(_cAliasTmp,.T.)
		For nY:= 1 To (_cAliasTmp)->(FCount())
			FieldPut(nY, IIF(nY==1,"4T",IIF(nY==2," ",IIF(nY==3,SPACE(18),IIF(nY==4,"RESUMO FINAL -> CAIXA ATUAL",0)))))
		Next nY
		(_cAliasTmp)->(MsUnLock())
	EndIf


	//--------------------------------------------------------------------------------------+
	// Percorro o Alias temporario por coluna para recalcular o relatorio por dia ou mes    |
	//--------------------------------------------------------------------------------------+
	For _nX := 1 To Len(_aCols )

		//--------------------------------------------------------------+
		// Saldos iniciais                                              |
		//--------------------------------------------------------------+
		(_cALiasTmp)->(DbGoTop())
		If (_cALiasTmp)->(DbSeek("1T"))
			_aSldIniT[_nX]:= (_cALiasTmp)->(&("VALOR"+StrZero(_nX,2)))
		EndIf

		//--------------------------------------------------------------+
		// Pc                                                           |
		//--------------------------------------------------------------+
		(_cALiasTmp)->(DbGoTop())
		If (_cALiasTmp)->(DbSeek("2T"))
			_aTotPC[_nX]:= (_cALiasTmp)->(&("VALOR"+StrZero(_nX,2)))
		EndIf


		//--------------------------------------------------------------+
		// Naturezas                                                    |
		//--------------------------------------------------------------+
		//zero a posição do array
		_aTotTip[_nX]:= 0
		For _nY := 1 to Len(_aTipos)
			(_cALiasTmp)->(DbGoTop())
			If (_cALiasTmp)->(DbSeek("3T"+_aTipos[_nY]))
				_aTotTip[_nX]+= (_cALiasTmp)->(&("VALOR"+StrZero(_nX,2)))
			EndIf

		Next

		_aTotGeral[_nX] := _aSldIniT[_nX] + _aTotPC[_nX] + _aTotTip[_nX]


		If lCompoeSld

			If (_nX+1) <= Len(_aCols) .AND.      _aCols[_nX,2] < cDataBase

				(_cALiasTmp)->(DbGoTop())
				If (_cALiasTmp)->(DbSeek("1T"))
					If RecLock(_cALiasTmp,.F.)
						Replace (_cAliasTmp)->(&("VALOR"+StrZero(_nX+1,2))) With _aTotGeral[_nX]
						(_cALiasTmp)->(MsUnlock())
					EndIf
				EndIf
			Endif
		EndIf
	Next


	//--------------------------------------------------------------+
	// Atualizo o Totalizador geral(Resumo caixa atual)             |
	//--------------------------------------------------------------+
	(_cALiasTmp)->(DbGoTop())
	If (_cALiasTmp)->(DbSeek("4T"))
		If RecLock(_cALiasTmp,.F.)

			for _nX:= 1 to Len(_aCols)

				Replace (_cAliasTmp)->(&("VALOR"+StrZero(_nX,2))) With _aTotGeral[_nX]

			next
			(_cALiasTmp)->(MsUnlock())
		EndIf
	EndIf



	//=========================================================================================
	//================== PRINTLINE Do Relatorio ===============================================
	//=========================================================================================


	For _nx := 1 To Len(_aCols)
		_oFluxo:Cell(_aCols[_nx,2]):SetBlock( &("{|| (_cAliasTmp)->VALOR" + StrZero(_nx,02) +"  }") )
		_oTotal:Cell(_aCols[_nx,2]):SetBlock( &("{|| (_cAliasTmp)->VALOR" + StrZero(_nx,02) +"  }") )
	Next

	//--------------------------------------------------------------+
	// IMPRIME OS SALDOS BANCARIOS                                  |
	//--------------------------------------------------------------+
	If !lSintetico
		_oFluxo:Init()
		(_cALiasTmp)->(DbGoTop())
		(_cALiasTmp)->(DbSeek("1F"))
		While  (_cALiasTmp)->(!Eof()) .AND. (_cALiasTmp)->ORDEM == "1F"

			_oFluxo:PrintLine()
			(_cALiasTmp)->(dbSkip())

		EndDo
		_oFluxo:Finish()
	Else

		_oTotal:lHeaderSection := .T.

	EndIf

	//--------------------------------------------------------------+
	// IMPRIME O TOTALIZADOR DOS SALDOS BANCARIOS                   |
	//--------------------------------------------------------------+
	(_cALiasTmp)->(DbGoTop())
	If (_cALiasTmp)->(DbSeek("1T"))

		_oTotal:Init()
		_oTotal:PrintLine()
		_oTotal:Finish()

		_oFluxo:lHeaderSection := .F.
		_oTotal:lHeaderSection := .F.
	EndIf

	//--------------------------------------------------------------+
	// IMPRIME OS PEDIDOS                                           |
	//--------------------------------------------------------------+
	If lPedido

		_oFluxo:Init()
		(_cALiasTmp)->(DbGoTop())
		(_cALiasTmp)->(DbSeek("2F"))
		While  (_cALiasTmp)->(!Eof()) .AND. (_cALiasTmp)->ORDEM == "2F"

			If !lSintetico
				_oFluxo:PrintLine()
			EndIf
			(_cALiasTmp)->(dbSkip())

		EndDo
		_oFluxo:Finish()

		//--------------------------------------------------------------+
		// IMPRIME O TOTALIZADOR DOS PEDIDOS                            |
		//--------------------------------------------------------------+
		(_cALiasTmp)->(DbGoTop())
		If (_cALiasTmp)->(DbSeek("2T"))

			_oTotal:Init()
			_oTotal:PrintLine()
			_oTotal:Finish()

		EndIf

	EndIf


	//--------------------------------------------------------------+
	// IMPRIME AS NATUREZAS                                         |
	//--------------------------------------------------------------+
	For _nx := 1 To Len(_aCols)
		_oFluxo:Cell(_aCols[_nx,2]):SetBlock( &("{|| U_FIRF2CC((_cAliasTmp)->VALOR" + StrZero(_nx,02) + ","+ StrZero(_nx + 1,02) +" ) }") )
	Next


	For _nX := 1 to Len(_aTipos)

		If MV_PAR06 == 2 .AND. _aTipos[_nX] <> "O" // OPERACIONAL
			loop
		ElseIf MV_PAR06 == 3 .AND. _aTipos[_nX] <> "I" // INVESTIMENTO
			loop
		ElseIf MV_PAR06 == 4 .AND. _aTipos[_nX] <> "F" // FINANCIAMENTO
			loop
		EndIf


		_oFluxo:Init()
		(_cALiasTmp)->(DbGoTop())
		(_cALiasTmp)->(DbSeek("3F" + _aTipos[_nX] ))
		While  (_cALiasTmp)->(!Eof()) .AND. (_cALiasTmp)->ORDEM == "3F" .AND. (_cALiasTmp)->XTIPO == _aTipos[_nX]

			SED->(DbSeek(xFilial("SED") + (_cALiasTmp)->CODIGO))

			// Se relatorio for sintetico imprime apenas as naturezas sinteticas
			If lSintetico .AND. SED->ED_TIPO == "1" // Sintetico
				_oFluxo:PrintLine()
			ElseIf !lSintetico // para relatorio analitico imprime todas as naturezas
				_oFluxo:PrintLine()
			EndIf
			(_cALiasTmp)->(dbSkip())

		EndDo
		_oFluxo:Finish()

		//--------------------------------------------------------------+
		// IMPRIME O TOTALIZADOR DOS PEDIDOS                            |
		//--------------------------------------------------------------+
		(_cALiasTmp)->(DbGoTop())
		If (_cALiasTmp)->(DbSeek("3T"+_aTipos[_nX]))

			_oTotal:Init()
			_oTotal:PrintLine()
			_oTotal:Finish()

		EndIf

	Next


	//--------------------------------------------------------------+
	// IMPRIME O totalizador Geral                                  |
	//--------------------------------------------------------------+
	(_cALiasTmp)->(DbGoTop())
	If (_cALiasTmp)->(DbSeek("4T"))

		_oTotal:Init()
		_oTotal:PrintLine()
		_oTotal:Finish()

	EndIf


	(_cALiasTmp)->(dbClosearea())


	//-------------------------------------
	//-- Apaga Arquivo temporáio
	//-------------------------------------
	//-- arquivo de trabalho
	If File(_cArqTrab+GetDBExtension())
		FERASE(_cArqTrab+GetDBExtension())
	EndIf

	//-- ndice gerado
	If File(_cArqTrab+OrdBagExt())
		FERASE(_cArqTrab+OrdBagExt())
	EndIf

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} FIRF2CC
funcao a ser utilizada no setblock das celulas de valores para as naturezas sinteticas retorna os valores totalizados.

@type function
@author Caio Croll
@since 15/07/2015
@version P12.1.23

@param _nValorCell, Numércio, Valor da célula.
@param _nCol, Numércio, Número da coluna.

@obs Desenvolvimento FIEG

@history 29/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Numérico, Valores totalizados.

/*/
/*/================================================================================================================================/*/


User Function FIRF2CC( _nValorCell , _nCol )
	Local _nRet := 0
	Local _nPos := 0

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If SED->ED_TIPO = "1" // Sintetico
		_nPos := aScan(_aTotNatS, {|x| x[1] == (_cAliasTmp)->CODIGO } )

		If _nPos > 0
			_nRet := _aTotNatS[_nPos , _nCol ]
		Else
			_nRet := _nValorCell
		EndIf

	Else // Analitico
		_nRet := _nValorCell
	EndIf

Return(_nRet)

/*/================================================================================================================================/*/
/*/{Protheus.doc} fGetTot
Função que efetua a totalização necessária para as naturezas sintéticas.

@type function
@author Caio Croll
@since 15/07/2015
@version P12.1.23

@obs Desenvolvimento FIEG

@history 29/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Array, Totalizadores Sintéticas.

/*/
/*/================================================================================================================================/*/

Static Function fGetTot()
	Local _aRet := {}
	Local _nPos := 0
	Local _nLen := 0
	Local _cNat := ""
	Local _aAux := {}
	Local _nTNat := 0
	Local _lSoma := 0

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	(_cAliasTmp)->(dbGoTop())
	(_cAliasTmp)->(DbSeek("3F"))
	while ( (_cAliasTmp)->(!Eof()) .AND. (_cAliasTmp)->ORDEM == "3F" )

		If  Posicione("SED",1,xFilial("SED") + (_cAliasTmp)->CODIGO,"ED_TIPO") = "1" // Sintetico
			_cNat := (_cAliasTmp)->CODIGO
		EndIf

		If Empty(_cNat) // se tiver vazio quer dizer que nao teve nenhum natureza sintetica anterior
			_cNat := (_cAliasTmp)->CODIGO
		EndIf
		_nPos := aScan(_aRet, {|x| x[1] == _cNat } )

		If _nPos = 0 // se nao encontrou faz o add
			Aadd(_aRet , { (_cAliasTmp)->CODIGO } )

			_nLen := Len(_aRet)

			For _nz := 1 To Len(_aCols)
				Aadd(_aRet[_nLen] , &("(_cAliasTmp)->VALOR" + StrZero(_nz,02)) )
			Next
		Else// se encontrou efetua a soma

			For _nz := 1 To Len(_aCols)
				_aRet[_nPos,_nz + 1] += &("(_cAliasTmp)->VALOR" + StrZero(_nz,02))
			Next
		EndIf

		(_cAliasTmp)->(dbSkip())
	EndDo
	_aAux := aClone(_aRet)

	// soma valores para todas as nauturezas sinteticas
	If Len(_aRet) > 1
		For _nt := 1 To Len(_aRet)
			For _nu := _nt + 1 To Len(_aAux)
				_cNat := RTrim(_aRet[_nt,1])
				_nTNat := Len(_cNat)
				//_lSoma := _aRet[_nt,1] != _aAux[_nu,1]

				If _cNat == SubStr(_aAux[_nu,1],1,_nTNat)
					For _nz := 1 To Len(_aCols)
						_aRet[_nt,_nz + 1] += _aAux[_nu,_nz + 1]
					Next
				Else
					Exit
				EndIf
			Next
		Next
	EndIf

Return _aRet

/*/================================================================================================================================/*/
/*/{Protheus.doc} fGetDescN
Funcao que retorna a descrica da natureza utilizada no setblock.

@type function
@author Caio Croll
@since 15/07/2015
@version P12.1.23

@obs Desenvolvimento FIEG

@history 29/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Caracter, Descrição Natureza.

/*/
/*/================================================================================================================================/*/

Static Function fGetDescN()
	Local _cRet := ""
	Local _cPref := ""

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If SED->ED_COND == "R" // Receita
		_cPref := ""
	ElseIf SED->ED_COND == "D" // Despesa
		_cPref := "(-) "
	EndIf

	If SED->ED_TIPO == "1" // Sintetico
		_cRet := UPPER(AllTrim(SED->ED_CODIGO) + ". " + SED->ED_DESCRIC )
	ElseIf SED->ED_TIPO == "2" // Analitico
		_cRet := Capital(SED->ED_DESCRIC)
	EndIf

	If SED->ED_TIPO == "2" // Analitico
		_cRet := _cPref + _cRet
	EndIf

Return(_cRet)

/*/================================================================================================================================/*/
/*/{Protheus.doc} fGetSqlFil
Função que retorna uma string sql com a correta trativa para os possiveis compartilhamentos das tabelas.

@type function
@author Caio Croll
@since 15/07/2015
@version P12.1.23

@param _cAlias1, Caractere, Alias Principal.
@param _cAlias2, Caractere, Alias Segundário.

@obs Desenvolvimento FIEG

@history 29/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Caracter , Query.

/*/
/*/================================================================================================================================/*/

Static Function fGetSqlFil( _cAlias1, _cAlias2 )

	Local _nTmFil1 	:= Len(AllTrim(FWxFilial(_cAlias1)))
	Local _nTmFil2 	:= Len(AllTrim(FWxFilial(_cAlias2)))
	Local _cTpTab1  := _cAlias1+"."+SubStr(_cAlias1,2,2)
	Local _cTpTab2  := _cAlias2+"."+SubStr(_cAlias2,2,2)

	Local _cRet := ""

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	// trativa para pega o compartilhamento correto das tabelas
	If _nTmFil1 > 0 .AND. _nTmFil2 > 0
		If _nTmFil1 = _nTmFil2
			_cRet += " AND "+_cTpTab1+"_FILIAL = "+_cTpTab2+"_FILIAL"

		ElseIf _nTmFil1 > _nTmFil2
			_cRet += " AND SUBSTRING("+_cTpTab1+"_FILIAL,1,"+cValToChar(_nTmFil2)+") = "+_cTpTab2+"_FILIAL"

		ElseIf _nTmFil1 < _nTmFil2
			_cRet += " AND SUBSTRING("+_cTpTab2+"_FILIAL,1,"+cValToChar(_nTmFil1)+") = "+_cTpTab1+"_FILIAL"

		EndIf
	ElseIf _nTmFil1 > 0 .AND. _nTmFil2 = 0

	EndIf

	If _nTmFil1 > 0 .AND. MV_PAR07 == 1
		_cRet += " AND "+_cTpTab1+"_FILIAL "+ GetRngFil( _aSelFil, _cAlias1 ) +" "
	EndIf

Return(_cRet)

/*/================================================================================================================================/*/
/*/{Protheus.doc} fQrySldIni
Saldo Inicial Bancário.

@type function
@author Caio Croll
@since 15/07/2015
@version P12.1.23

@obs Desenvolvimento FIEG

@history 29/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function fQrySldIni()
	Local cQuery     := ""
	Local _cSqlSA6   := GetRngFil(_aSelFil,"SA6")
	Local _cSqlSE8   := GetRngFil(_aSelFil,"SE8")
	Local lSintetico := (MV_PAR01 == 1)
	Local lCompoeSld := (MV_PAR08 == 1)
	local  nY        := 0
	Local cData      := Iif(MV_PAR02 == 1,Dtos(dDataBase),SubStr(Dtos(dDataBase),1,6) )


	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------


	If lSintetico
		If Reclock(_cAliasTmp,.T.)
			For nY:= 1 To (_cAliasTmp)->(FCount())
				FieldPut(nY, IIF(nY==1,"1F",IIF(nY==2," ",IIF(nY==3,SPACE(18),IIF(nY==4,SPACE(TAMSX3("A6_NOME")[1]),0)))))
			Next nY
			(_cAliasTmp)->(MsUnLock())
		EndIf
	EndIF

	For _nX := 1 To Len(_aCols)


		// Compoe Saldo anterior
		If ! lCompoeSld
			//--------------------------------------------------------------+
			// Caso nao compoe saldo obter somente saldo da database(d-1)   |
			//--------------------------------------------------------------+
			If  cData  <> _aCols[_nX,2]
				Loop
			EndIf

		Else
			//----------------------------------------------------------------------------------------------------+
			// Conforme conversado irá compor todos os saldos ate a database baseado no primeiro dia (MV_PAR04)   |
			//----------------------------------------------------------------------------------------------------+
			If _nX > 1
				Loop
			EndIf

		EndIf



		cQuery:="     FROM "+ RetSqlName("SA6") +" SA6 "+CRLF
		cQuery+="LEFT JOIN (SELECT MAX(E8_DTSALAT) DTSALDO, E8_FILIAL, E8_BANCO, E8_AGENCIA, E8_CONTA  "+CRLF
		cQuery+="	         FROM "+ RetSqlName("SE8") +" SE8  "+CRLF
		cQuery+="	        WHERE SE8.D_E_L_E_T_ <> '*'  "+CRLF
		If MV_PAR02 == 1
			cQuery+="              AND E8_DTSALAT < '"+ _aCols[_nx,2] +"' "+CRLF
		Else
			cQuery+="              AND E8_DTSALAT <= '"+ Dtos(LastDate(Stod(_aCols[_nx,2]+"01"))) +"' "+CRLF
		EndIf
		cQuery+="              AND E8_FILIAL "+ _cSqlSE8 +" "+CRLF
		cQuery+="         GROUP BY E8_FILIAL, E8_BANCO, E8_AGENCIA, E8_CONTA) SE8DT "+CRLF
		cQuery+="       ON SE8DT.E8_FILIAL+SE8DT.E8_BANCO+SE8DT.E8_AGENCIA+SE8DT.E8_CONTA = A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON "+CRLF
		cQuery+="LEFT JOIN "+ RetSqlName("SE8") +" SE8VL  "+CRLF
		cQuery+="       ON  (SE8VL.E8_FILIAL+SE8VL.E8_BANCO+SE8VL.E8_AGENCIA+SE8VL.E8_CONTA = A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON "+CRLF
		cQuery+="      AND SE8VL.E8_DTSALAT = SE8DT.DTSALDO  "+CRLF
		cQuery+="      AND SE8VL.D_E_L_E_T_<>'*' ) "+CRLF
		cQuery+="    WHERE SA6.D_E_L_E_T_<>'*' "+CRLF
		cQuery+="      AND SA6.A6_FLUXCAI <> 'N' "+CRLF
		cQuery+="      AND SA6.A6_BLOCKED <> '1' "+CRLF
		cQuery+="      AND A6_FILIAL "+ GetRngFil( _aSelFil,"SA6")


		If lSintetico // sintetico

			cQuery:="   SELECT  SUM(ISNULL(E8_SALATUA,  A6_SALATU)) AS SALDO "+CRLF+cQuery

		Else // Analitico

			cQuery:="  SELECT A6_COD, A6_AGENCIA, A6_NUMCON, A6_NOME, ISNULL(E8_SALATUA,  A6_SALATU)AS SALDO "+CRLF+cQuery
			cQuery+=" Order by A6_NOME "

		EndIf


		MemoWrite("C:\temp\LOGSQL\"+_cPerg+"SldIni.txt" , cQuery) // escreve em arquivo de texto e se nao encontrar cria o arquivo

		If Select(_cALias) > 0
			(_cALias)->(dbClosearea())
		Endif

		DbUseArea(.T., "TOPCONN", TCGenQry(,,ChangeQuery(cQuery)), _cALias, .F., .F.)



		While ( (_cAlias)->(!Eof()) )


			If lSintetico

				If RecLock(_cAliasTmp,.F.)
					Replace (_cAliasTmp)->(&("VALOR"+StrZero(_nX,2))) With (_cAlias)->SALDO
					(_cAliasTmp)->(MsUnLock())
				EndIF

			Else
				//--------------------------------------------------------------+
				// Verifico se ja existe o banco no alias temporario            |
				//--------------------------------------------------------------+
				If !(_cAliasTmp)->(DbSeek("1F "+(_cAlias)->(A6_COD+A6_AGENCIA+A6_NUMCON)))
					//--------------------------------------------------------------+
					// Adiciono o banco ao alias temporario                         |
					//--------------------------------------------------------------+
					If Reclock(_cALiasTmp,.T.)
						For _YY:=1 To (_cALiasTmp)->(FCount())
							FieldPut(_yy,IIF(_yy==1,"1F",IIF(_yy==2," ",IIF(_yy==3,(_cAlias)->(A6_COD+A6_AGENCIA+A6_NUMCON),IIF(_yy==4,(_cAlias)->A6_NOME,0)))))
						Next _yy

						Replace (_cAliasTmp)->(&("VALOR"+StrZero(_nX,2))) With (_cAlias)->SALDO

						(_cALiasTmp)->(MsUnLock())
					EndIf

				Else

					If RecLock(_cAliasTmp,.F.)
						Replace (_cAliasTmp)->(&("VALOR"+StrZero(_nX,2))) With ( (_cAliasTmp)->(&("VALOR"+StrZero(_nX,2))) + (_cAlias)->SALDO)
						(_cAliasTmp)->(MsUnLock())
					EndIf

				EndIf

			EndIf

			(_cAlias)->(dbSkip())
		EndDo
	Next

Return Nil

/*/================================================================================================================================/*/
/*/{Protheus.doc} fGetQtdCol
Retorna a quantidade de colunas de valor que o relatório devera ter.

@type function
@author Caio Croll
@since 19/01/2015
@version P12.1.23

@obs Desenvolvimento FIEG

@history 29/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Numérico, quantidade de colunas de valor que o relatório devera ter.

/*/
/*/================================================================================================================================/*/

Static Function fGetQtdCol()
	Local _nRet := 0

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If MV_PAR02 == 1 // tipo igual dia
		_nRet := MV_PAR05 - MV_PAR04 + 1

	ElseIf MV_PAR02 == 2 // tipo igual mes
		_nRet := fCalcMont(MV_PAR04, MV_PAR05)
	EndIf

Return(_nRet)

/*/================================================================================================================================/*/
/*/{Protheus.doc} fValPar
Funcao para validacao dos parametros digitados nao permite que seja selecionado um intervalo entre datas muito grande.

@type function
@author Caio Croll
@since 15/01/2015
@version P12.1.23

@obs Desenvolvimento FIEG

@history 29/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Verdadeiro ou Falso para validacao dos parametros digitados.

/*/
/*/================================================================================================================================/*/

Static Function fValPar()
	Local _lRet := .T.
	Local _nMaxDif := 0
	Local _nDif := 0

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If Empty(MV_PAR04) .OR. Empty(MV_PAR05)
		Alert("Parâmetros 'data de' e 'data até' não podem ser vazios.")
		_lRet := .F.
	EndIf

	If _lRet .AND. MV_PAR04 > MV_PAR05
		Alert("Parâmetro 'data de' não pode ser maior que o parâmetro 'data até'.")
		_lRet := .F.
	EndIf

	If _lRet .AND. MV_PAR02 == 1 // tipo igual dia
		_nMaxDif := 40 // dias

		_nDif := MV_PAR05 - MV_PAR04

		If _nDif > _nMaxDif
			Alert("Para relatório tipo 'Dia' o intervalo entre as datas deve ser no maximo " + cValToChar(_nMaxDif) + " dias." )
			_lRet := .F.
		EndIf

	ElseIf _lRet .AND. MV_PAR02 == 2 // tipo igual mes
		_nMaxDif := 12 // meses

		_nDif := fCalcMont(MV_PAR04, MV_PAR05)

		If _nDif > _nMaxDif
			Alert("Para relatório tipo 'Mês' o intervalo entre as datas deve ser no maximo " + cValToChar(_nMaxDif) + " meses." )
			_lRet := .F.
		EndIf

	EndIf

Return _lRet

/*/================================================================================================================================/*/
/*/{Protheus.doc} fCalcMont
Função que calcula o numero de meses entre duas datas.

@type function
@author Caio Croll
@since 16/01/2015
@version P12.1.23

@param _dDtDe, Data, Data incial.
@param _dDtAte, data, Data Final.

@obs Desenvolvimento FIEG

@history 29/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Numérico, Número de meses entre duas datas.

/*/
/*/================================================================================================================================/*/

Static Function fCalcMont(_dDtDe , _dDtAte)
	Local _nRet := 0
	Local _sDtDe := DToS(_dDtDe)
	Local _sDtAte := DToS(_dDtAte)
	Local _cAnoDe := SubStr(_sDtDe , 1, 4)
	Local _cMesDe := SubStr(_sDtDe , 5, 2)
	Local _cAnoAte := SubStr(_sDtAte , 1, 4)
	Local _cMesAte := SubStr(_sDtAte , 5, 2)
	Local _nMesDe := 0
	Local _nMesAte:= 0

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	// para efetuar qualquer calculo primeiro devemos passar tudo para a mesma medida
	// nesse caso como eu quero os mesese entao vou passar tudo para mes
	_nMesDe := Val(_cAnoDe)
	_nMesDe := _nMesDe * 12
	_nMesDe := _nMesDe + Val(_cMesDe)

	_nMesAte := Val(_cAnoAte)
	_nMesAte := _nMesAte * 12
	_nMesAte := _nMesAte + Val(_cMesAte)

	// mais 1 para levar em conta tambem o do parametro
	_nRet := _nMesAte - _nMesDe + 1

Return(_nRet)

/*/================================================================================================================================/*/
/*/{Protheus.doc} fProcPC
Processa Pedido de Compras.

@type function
@author Allan da Silva Faria
@since 22/07/2015
@version P12.1.23

@obs Desenvolvimento FIEG

@history 29/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function fProcPC()

	Local _cTmp 	:= Nil
	//Local _nValor 	:= 0
	Local _aTitulo	:= {}
	Local _nPosTit	:= 0
	Local _sData	:= Nil
	Local _cField	:= "VALOR"
	Local _dData	:= Nil	//-- Data de Entregua/DataBase
	Local _cFilial  := ""	//-- Filial PC
	Local _cNumPC	:= ""	//-- Numero PC
	Local _cCond	:= ""	//-- Código Condição de Pagamento
	Local _cNomFor	:= ""	//-- Nome do Fornecedor
	Local _cCodFor	:= ""	//-- Codigo do Fornecedor
	Local _nValIPI	:= 0	//-- Valor do IPI
	Local _nBaseIPI := 0	//-- Valor Base do IPI
	Local _nValLIPI	:= 0  	//-- Valor Liquido
	Local _nTotDesc := 0	//-- Total Descontos
	Local _nValTot  := 0	//-- Valor Total do PC
	Local _nDespFret:= 0	//-- Valor Total Despesas/Frete/Seguros
	Local _nTxMoed  := 0	//-- Taxa Seguda Moeda
	Local _nMoeda	:= 1	//-- Moeda Nascional
	Local _nPrcComp := 0	//-- Preço do Item - Compra
	Local _nDecimais:= TamSx3("C7_PRECO")[2]

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------


	//---------------------------------------
	//-- Filtra Registro Pedido de Compras
	//---------------------------------------
	_cTmp := fQryPC()

	dbSelectArea(_cTmp)
	(_cTmp)->(dbGoTop())


	dbSelectArea("SF4")
	SF4->(dbSetOrder(1))

	dbSelectArea("SB1")
	SB1->(dbSetOrder(1))

	While (_cTmp)->(!EOF())

		_cFilial	:= (_cTmp)->C7_FILIAL
		_cNumPC 	:= (_cTmp)->C7_NUM
		_cCond		:= (_cTmp)->C7_COND
		_cNomFor	:= Iif(EMPTY((_cTmp)->(C7_XNOMFOR)),Posicione("SA2",1, xFilial("SA2") + (_cTmp)->(C7_FORNECE),"A2_NOME") ,(_cTmp)->(C7_XNOMFOR))
		_cCodFor	:= (_cTmp)->(C7_FORNECE)
		_nValIPI	:= 0
		_nTotDesc	:= SC7->C7_VLDESC
		_nValTot  	:= 0
		_nDespFret	:= 0
		_nPrcComp   := 0
		_nValTIPI   := 0

		While ( (_cTmp)->(!EOF()) .AND. (_cTmp)->C7_FILIAL == _cFilial .AND.  (_cTmp)->C7_NUM == _cNumPC )

			SB1->(dbSeek(FWxFilial("SB1")+(_cTmp)->C7_PRODUTO)) 	//-- Posiciona Produto
			If !Empty((_cTmp)->C7_TES)
				SF4->(dbSeek(FWxFilial("SF4")+(_cTmp)->C7_TES ))  	//-- Posiciona TES
			Else
				SF4->(dbSeek(FWxFilial("SF4")+SB1->B1_TE)) 		//-- Posiciona TES
			Endif

			//------------------------------------------------------------------
			//-- Se nao houver TES no Pedido ou Produto serah considerado
			//-- pois o tes no PC nao eh obrigatorio ou comum.
			//------------------------------------------------------------------
			If SF4->F4_DUPLIC == "N"
				(_cTmp)->(dbSkip())
				Loop
			Endif

			//------------------------------------------------------
			//-- Data Base para Calculo de Vencimento de títulos
			//-- Data Entrega ou DataBase
			//------------------------------------------------------
			//_dData := Iif((_cTmp)->C7_DATPRF < dDataBase, dDataBase, DataValida((_cTmp)->C7_DATPRF))
			_dData := (_cTmp)->C7_EMISSAO

			//------------------------------------------------------
			//-- Valor de Compre por Item
			//------------------------------------------------------
			_nTxMoed	:= RecMoeda(_dData,(_cTmp)->C7_MOEDA)
			_nPrcComp 	:= xMoeda((_cTmp)->C7_PRECO,(_cTmp)->C7_MOEDA,_nMoeda,_dData,_nDecimais,Iif(_nTxMoed==0,(_cTmp)->C7_TXMOEDA,0))

			//------------------------------------------------------
			//-- Valor Frete/Seguros e Despesas
			//------------------------------------------------------
			_nDespFret := xMoeda((_cTmp)->C7_VALFRE+(_cTmp)->C7_SEGURO+(_cTmp)->C7_DESPESA,(_cTmp)->C7_MOEDA,_nMoeda,_dData,_nDecimais,Iif(_nTxMoed==0,(_cTmp)->C7_TXMOEDA,0))

			//------------------------------------------------------
			//-- Valor Total + Frete/Seguros/Despesas
			//------------------------------------------------------
			_nValTot	  := (((_cTmp)->C7_QUANT-(_cTmp)->C7_QUJE) * _nPrcComp)+_nDespFret

			_nValIPI  := 0
			_nValLIPI := _nValTot

			//------------------------------------------------------
			//-- Calcula Valor Desconto
			//------------------------------------------------------
			If _nTotDesc == 0
				_nTotDesc := CalcDesc(_nValTot,(_cTmp)->C7_DESC1,(_cTmp)->C7_DESC2,(_cTmp)->C7_DESC3)
			Else
				//------------------------------------------------------------------
				//-- Proporcionaliza o desconto de pedidos com entrega parcial
				//------------------------------------------------------------------
				_nTotDesc := (((_cTmp)->C7_VLDESC * _nValTot) / (_cTmp)->C7_TOTAL)
			EndIf

			_nValTot := _nValTot - _nTotDesc

			//------------------------------------------------------
			//-- Calcula IPI
			//------------------------------------------------------
			IF (_cTmp)->C7_IPI > 0
				If (_cTmp)->C7_IPIBRUT != "L"
					_nBaseIPI := _nValTot
				Else
					_nBaseIPI := _nValLIPI
				Endif
				IF SF4->F4_BASEIPI > 0
					_nBaseIPI *= SF4->F4_BASEIPI / 100
				Endif
				_nValIPI := IIf(_nBaseIPI = 0, 0, _nBaseIPI * (_cTmp)->C7_IPI / 100)
			Endif
			_nValTot  += _nValIPI

			//------------------------------------------------------
			//-- Calcula Juros conforme cond. Pagamento
			//------------------------------------------------------
			dbSelectArea("SE4")
			SE4->(dbSeek(FWxFilial("SE4")+_cCond))
			_nValTot  *= (SE4->E4_ACRSFIN/100)+1

			//------------------------------------------------------
			//-- Calcula vencimento e valores de títulos
			//------------------------------------------------------
			_aTitulo :=  Condicao(_nValTot,_cCond,_nValTIPI,_dData)

			For _n:= 1 To Len(_aTitulo)

				//-- Por Dia
				If MV_PAR02 == 1
					_nPosTit := aScan(_aCols,{|HH| HH[2] == DtoS(_aTitulo[_n,1]) })
					//-- Por Mês
				ElseIf MV_PAR02 == 2
					_nPosTit := aScan(_aCols,{|HH| HH[2] == cValToChar(Year(_aTitulo[_n,1])) + StrZero(Month(_aTitulo[_n,1]),2) })
				EndIf

				//-- Se não achar em uma posição no Acols
				//-- lupa para o próximo título
				If _nPosTit == 0
					Loop
				EndIf

				_cField:= "VALOR"+StrZero(_nPosTit,2)

				If (_cALiasTmp)->(DbSeek("2F "+_cCodFor))

					If RecLock(_cALiasTmp,.F.)
						Replace (_cALiasTmp)->(&_cField) With ((_cALiasTmp)->(&_cField) + (_aTitulo[_n,2] * -1) )
						(_cALiasTmp)->(MsUnLock())
					EndIf

				Else

					If Reclock(_cALiasTmp,.T.)
						For _YY:=1 To (_cALiasTmp)->(FCount())
							FieldPut(_yy,IIF(_yy==1,"2F",IIF(_yy==2," ",IIF(_yy==3,_cCodFor,IIF(_yy==4,_cNomFor,0)))))
						Next _yy
						Replace (_cALiasTmp)->(&_cField) With ((_cALiasTmp)->(&_cField) + (_aTitulo[_n,2] * -1) )
						(_cALiasTmp)->(MsUnLock())
					EndIf
				EndIf

			Next _n

			(_cTmp)->(dbSkip())
		EndDo

	EndDo

	(_cTmp)->(dbCloseArea())

Return Nil

/*/================================================================================================================================/*/
/*/{Protheus.doc} fArqTmp
Cria Arquivo de trabalho Temporário para o Relatorio.

@type function
@author Allan da Silva Faria
@since 22/07/2015
@version P12.1.23

@obs Desenvolvimento FIEG

@history 29/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function fArqTmp()

	Local _aCampos	:= {}

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If Select(_cAliasTmp) > 0
		dbSelectArea(_cAliasTmp)
		(_cAliasTmp)->(dbCloseArea())
	EndIf

	_nx:=0

	aAdd(_aCampos,{"ORDEM"  ,"C",2                     ,0})
	aAdd(_aCampos,{"XTIPO"  ,"C",1                     ,0})
	aAdd(_aCampos,{"CODIGO" ,"C",18                    ,0})
	aAdd(_aCampos,{"DESCRIC","C",TamSX3("A6_NOME")[1]  ,0})
	aEval(_aCols,{|HH| _nx++,aAdd(_aCampos,{"VALOR"+StrZero(_nx,02),"N",14,2})})

	_cArqTrab := CriaTrab(_aCampos,.T.)

	dbUseArea(.T.,,_cArqTrab,_cAliasTmp,.F.,.F. )

	IndRegua(_cAliasTmp,_cArqTrab,"ORDEM+XTIPO+CODIGO+DESCRIC",,,"Selecionando Registros...",.F.)

	dbSelectArea(_cAliasTmp)
	(_cAliasTmp)->(dbSetOrder(1))

Return Nil

/*/================================================================================================================================/*/
/*/{Protheus.doc} fQryPC
Filtra Pedido de Compras.

@type function
@author Allan da Silva Faria
@since 22/07/2015
@version P12.1.23

@obs Desenvolvimento FIEG

@history 29/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Caractere, Alias da tabela com os pedidos.

/*/
/*/================================================================================================================================/*/

Static Function fQryPC()

	Local _aStruC7:= SC7->(dbStruct())
	Local _cTbPC  := GetNextAlias()
	Local cQuery  := " "

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------


	If Select(_cTbPC) > 0
		dbSelectArea(_cTbPC)
		(_cTbPC)->(dbCloseArea())
	EndIf

	cQuery:=" SELECT * "
	cQuery+=" FROM  "+ RetSqlName("SC7") +" SC7
	cQuery+=" WHERE  SC7.D_E_L_E_T_ = '' "
	cQuery+=" AND SC7.C7_FILIAL  "+ GetRngFil(_aSelFil,"SC7") +" "
	cQuery+=" AND SC7.C7_FLUXO <> 'N'   "
	cQuery+=" AND SC7.C7_RESIDUO = ' '  "
	cQuery+=" AND SC7.C7_CONAPRO = 'L' "
	cQuery+=" AND ( SC7.C7_QUJE >=0 OR SC7.C7_QTDACLA>=0 ) "
	cQuery+=" AND SC7.C7_QUJE < SC7.C7_QUANT "
	cQuery+=" ORDER BY SC7.C7_XNOMFOR,SC7.C7_FILIAL,SC7.C7_NUM,SC7.C7_ITEM "

	DbUseArea(.T., "TOPCONN", TCGenQry(,,ChangeQuery(cQuery)), _cTbPC, .F., .F.)

	aEval(_aStruC7,{|HH| TCSetField(_cTbPC,HH[1],HH[2],HH[3],HH[4])})

Return(_cTbPC)

/*/================================================================================================================================/*/
/*/{Protheus.doc} fProcNat
Busco as naturezas.

@type function
@author Marcelo Evangelista
@since 31/05/2016
@version P12.1.23

@obs Desenvolvimento FIEG

@history 29/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function fProcNat()

	Local _aStruED:= SED->(dbStruct())
	Local _cTbNat := GetNextAlias()
	Local cQuery  := " "

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------


	If Select(_cTbNat) > 0
		dbSelectArea(_cTbNat)
		(_cTbNat)->(dbCloseArea())
	EndIf

	cQuery:="SELECT *  "+CRLF
	cQuery+="  FROM "+ RetSqlName("SED") +" SED "+CRLF
	cQuery+=" WHERE SED.D_E_L_E_T_ <> '*' "+CRLF
	cQuery+="   AND SED.ED_FILIAL"+ GetRngFil(_aSelFil,"SED") +" "  +CRLF
	cQuery+="   AND SED.ED_MSBLQL  <> '1'  " +CRLF
	cQuery+="   AND SED.ED_XTIPO   IN ('F','I','O') " +CRLF
	cQuery+="   AND SED.ED_COND    IN ('D','R') "+CRLF
	cQuery+="ORDER BY ED_FILIAL,ED_CODIGO,ED_DESCRIC,ED_PAI,ED_XTIPO,ED_TIPO,ED_COND "+CRLF


	MemoWrite("C:\temp\LOGSQL\"+_cPerg+"fProcNat.txt" , cQuery) // escreve em arquivo de texto e se nao encontrar cria o arquivo

	DbUseArea(.T., "TOPCONN", TCGenQry(,,ChangeQuery(cQuery)), _cTbNat, .F., .F.)

	aEval(_aStruED,{|HH| TCSetField(_cTbNat,HH[1],HH[2],HH[3],HH[4])})


	While ( (_cTbNat)->(!Eof()) )
		(_cALiasTmp)->(DbGoTop())
		If !(_cALiasTmp)->(dbSeek("3F"+(_cTbNat)->(ED_XTIPO + ED_CODIGO )))
			If Reclock(_cALiasTmp,.T.)
				For _YY:=1 To (_cALiasTmp)->(FCount())
					FieldPut(_yy,IIF(_yy==1,"3F",IIF(_yy==2,(_cTbNat)->(ED_XTIPO),IIF(_yy==3,(_cTbNat)->(ED_CODIGO),IIF(_yy==4,(_cTbNat)->(ED_DESCRIC),0)))))
				Next _yy
				(_cALiasTmp)->(MsUnLock())
			EndIf
		EndIf

		(_cTbNat)->(dbSkip())
	EndDo

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} fProcSe1
Busco os registros na SE1.

@type function
@author Marcelo Evangelista
@since 31/05/2016
@version P12.1.23

@obs Desenvolvimento FIEG

@history 29/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function fProcSe1()

	Local _aStruE1 := SE1->(dbStruct())
	Local _cTbSe1  := GetNextAlias()
	Local cQryIn   := Iif(MV_PAR06==2,"O",Iif(MV_PAR06==3,"I",Iif(MV_PAR06==4,"F","F#O#I")))
	Local cQuery   := " "
	Local nPos     := 0
	Local cData    := ""
	//	Local nSaldoTit:= 0

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------


	If Select(_cTbSe1) > 0
		dbSelectArea(_cTbSe1)
		(_cTbSe1)->(dbCloseArea())
	EndIf


	cQuery:="   SELECT SE1.*,SED.ED_XTIPO "+CRLF
	cQuery+="      FROM "+ RetSqlName("SE1") +" SE1  "+CRLF
	cQuery+="INNER JOIN "+ RetSqlName("SED") +" SED "+CRLF
	cQuery+="        ON SE1.E1_NATUREZ= SED.ED_CODIGO    "+CRLF
	cQuery+="       AND SED.ED_FILIAL"+ GetRngFil(_aSelFil,"SED") +" "  +CRLF
	cQuery+="       AND SED.ED_XTIPO IN "+FormatIn(cQryIn,"#") +" "+CRLF
	cQuery+="       AND SED.ED_COND = 'R'    "+CRLF
	cQuery+="       AND SED.ED_MSBLQL <> '1'  "+CRLF
	cQuery+="       AND SED.D_E_L_E_T_ = '' "+CRLF
	cQuery+=" LEFT JOIN "+ RetSqlName("SE5") +" SE5  "+CRLF
	cQuery+=" 	     ON  E5_FILIAL  = E1_FILIAL "+CRLF
	cQuery+="	    AND  E5_PREFIXO = E1_PREFIXO  "+CRLF
	cQuery+="	    AND  E5_NUMERO  = E1_NUM "+CRLF
	cQuery+="	    AND  E5_PARCELA = E1_PARCELA "+CRLF
	cQuery+="	    AND  E5_TIPO    = E1_TIPO "+CRLF
	cQuery+="	    AND  E5_CLIFOR  = E1_CLIENTE "+CRLF
	cQuery+="	    AND  E5_LOJA    = E1_LOJA "+CRLF
	cQuery+="	    AND  SE5.D_E_L_E_T_ = '' "+CRLF
	cQuery+="     WHERE E1_FILIAL "+ GetRngFil(_aSelFil,"SE1") +" "+CRLF
	cQuery+="	    AND (E5_NUMERO IS NULL  OR E5_DATA BETWEEN '"+Dtos(MV_PAR04)+"' AND '"+Dtos(MV_PAR05)+"' ) "+CRLF
	cQuery+="       AND SE1.E1_FLUXO <> 'N'   "+CRLF
	cQuery+="       AND SE1.D_E_L_E_T_ <> '*'  "+CRLF
	cQuery+="       AND SE1.E1_VENCREA BETWEEN '"+Dtos(MV_PAR04)+"' AND '"+Dtos(MV_PAR05)+"' "+CRLF


	MemoWrite("C:\temp\LOGSQL\"+_cPerg+"fProcSe1.txt" , cQuery) // escreve em arquivo de texto e se nao encontrar cria o arquivo

	DbUseArea(.T., "TOPCONN", TCGenQry(,,ChangeQuery(cQuery)), _cTbSe1, .F., .F.)

	aEval(_aStruE1,{|HH| TCSetField(_cTbSe1,HH[1],HH[2],HH[3],HH[4])})

	While ( (_cTbSe1)->(!Eof()) )
		(_cALiasTmp)->(DbGoTop())
		If (_cALiasTmp)->(dbSeek("3F"+(_cTbSe1)->(ED_XTIPO + E1_NATUREZ )))
			cData:= Iif(MV_PAR02 == 1,Dtos((_cTbSe1)->(E1_VENCREA)), SubStr(Dtos((_cTbSe1)->(E1_VENCREA)),1,6))
			nPos := aScan(_ACols,{|x| x[2] == cData })

			If Reclock(_cALiasTmp,.F.)

				Replace (_cALiasTmp)->(&("VALOR"+StrZero(nPos,02))) With ( (_cTbSe1)->(E1_VALOR ) + (_cALiasTmp)->(&("VALOR"+StrZero(nPos,02))))

				(_cALiasTmp)->(MsUnLock())
			EndIf
		EndIf

		(_cTbSe1)->(dbSkip())
	EndDo

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} fProcSe2
Busco os registros na SE2.

@type function
@author Marcelo Evangelista
@since 31/05/2016
@version P12.1.23

@obs Desenvolvimento FIEG

@history 29/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function fProcSe2()


	Local _cTbSe2  := GetNextAlias()
	Local cQuery   := " "
	Local cQryIn   := Iif(MV_PAR06==2,"O",Iif(MV_PAR06==3,"I",Iif(MV_PAR06==4,"F","F#O#I")))
	Local nPos     := 0
	Local nSaldoTit:= 0
	Local cData    := ""

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If Select(_cTbSe2) > 0
		dbSelectArea(_cTbSe2)
		(_cTbSe2)->(dbCloseArea())
	EndIf

	cQuery+="  SELECT SE2.E2_NATUREZ AS NATUREZ, SED.ED_XTIPO AS TIPO, SE2.E2_VENCREA AS VENCREA, (SE2.E2_VALOR*-1) AS VALOR   " +CRLF
	cQuery+="      FROM "+ RetSqlName("SE2") +" SE2   " +CRLF
	cQuery+="INNER JOIN "+ RetSqlName("SED") +" SED   " +CRLF
	cQuery+="        ON SE2.E2_NATUREZ = SED.ED_CODIGO  " +CRLF
	cQuery+= fGetSqlFil("SED", "SE2")
	cQuery+="       AND SED.ED_XTIPO IN "+ FormatIn(cQryIn,"#") +" "+CRLF
	cQuery+="       AND SED.ED_COND = 'D'    "+CRLF
	cQuery+="       AND SED.ED_MSBLQL <> '1'  "+CRLF
	cQuery+="       AND SED.D_E_L_E_T_ = '' "+CRLF
	cQuery+=" LEFT JOIN "+ RetSqlName("SE5") +" SE5  " +CRLF
	cQuery+="        ON  E5_FILIAL  = E2_FILIAL " +CRLF
	cQuery+="       AND  E5_PREFIXO = E2_PREFIXO  " +CRLF
	cQuery+="       AND  E5_NUMERO  = E2_NUM " +CRLF
	cQuery+="       AND  E5_PARCELA = E2_PARCELA " +CRLF
	cQuery+="       AND  E5_TIPO    = E2_TIPO " +CRLF
	cQuery+="       AND  E5_CLIFOR  = E2_FORNECE " +CRLF
	cQuery+="       AND  E5_LOJA    = E2_LOJA " +CRLF
	cQuery+="       AND  SE5.D_E_L_E_T_ = '' " +CRLF
	cQuery+="     WHERE SE2.E2_FILIAL "+ GetRngFil(_aSelFil,"SE2") +"  " +CRLF
	cQuery+="       AND (E5_NUMERO IS NULL  OR E5_DATA BETWEEN '"+Dtos(MV_PAR04)+"' AND '"+Dtos(MV_PAR05)+"' ) " +CRLF
	cQuery+="       AND SE2.D_E_L_E_T_ <> '*'   " +CRLF
	cQuery+="       AND SE2.E2_FLUXO <> 'N'   " +CRLF
	cQuery+="       AND SE2.E2_MULTNAT <> 1   " +CRLF
	cQuery+="       AND (SE2.E2_VENCREA BETWEEN '"+Dtos(MV_PAR04)+"' AND '"+Dtos(MV_PAR05)+"' )  " +CRLF

	cQuery+=" UNION ALL" +CRLF

	cQuery+="      SELECT SEV.EV_NATUREZ AS NATUREZ,  "+CRLF
	cQuery+="             SED.ED_XTIPO   AS TIPO,     "+CRLF
	cQuery+="             SE2.E2_VENCREA AS VENCREA,  "+CRLF
	cQuery+="             (SEV.EV_VALOR*-1)   AS VALOR    "+CRLF
	cQuery+="        FROM "+ RetSqlName("SEV") +" SEV  "+CRLF
	cQuery+="  INNER JOIN "+ RetSqlName("SE2") +" SE2  "+CRLF
	cQuery+="          ON SE2.E2_FILIAL  = SEV.EV_FILIAL    "+CRLF
	cQuery+="         AND SE2.E2_PREFIXO = SEV.EV_PREFIXO   "+CRLF
	cQuery+="         AND SE2.E2_NUM     = SEV.EV_NUM       "+CRLF
	cQuery+="         AND SE2.E2_TIPO    = SEV.EV_TIPO      "+CRLF
	cQuery+="         AND SE2.E2_FORNECE = SEV.EV_CLIFOR    "+CRLF
	cQuery+="         AND SE2.E2_LOJA    = SEV.EV_LOJA      "+CRLF
	cQuery+="         AND SE2.D_E_L_E_T_ <> '*'  "+CRLF
	cQuery+="   LEFT JOIN  "+ RetSqlName("SE5") +" SE5  "+CRLF
	cQuery+="          ON  E5_FILIAL  = E2_FILIAL "+CRLF
	cQuery+="         AND  E5_PREFIXO = E2_PREFIXO  "+CRLF
	cQuery+="         AND  E5_NUMERO  = E2_NUM "+CRLF
	cQuery+="         AND  E5_PARCELA = E2_PARCELA "+CRLF
	cQuery+="         AND  E5_TIPO    = E2_TIPO "+CRLF
	cQuery+="         AND  E5_CLIFOR  = E2_FORNECE "+CRLF
	cQuery+="         AND  E5_LOJA    = E2_LOJA "+CRLF
	cQuery+="  INNER JOIN  "+ RetSqlName("SED") +" SED "+CRLF
	cQuery+="          ON  SED.ED_CODIGO = SEV.EV_NATUREZ  "+CRLF
	cQuery+= fGetSqlFil("SED", "SEV")
	cQuery+="         AND SED.D_E_L_E_T_= '' "+CRLF
	cQuery+="       WHERE SEV.EV_FILIAL "+ GetRngFil(_aSelFil,"SEV") +"  " +CRLF
	cQuery+="         AND (E5_NUMERO IS NULL  OR E5_DATA BETWEEN '"+Dtos(MV_PAR04)+"' AND '"+Dtos(MV_PAR05)+"' ) "+CRLF
	cQuery+="         AND SEV.D_E_L_E_T_ <> '*'  "+CRLF
	cQuery+="         AND SE2.E2_MULTNAT = 1  "+CRLF
	cQuery+="         AND SEV.EV_RECPAG = 'P'  "+CRLF
	cQuery+="         AND SEV.EV_IDENT = '1'  "+CRLF
	cQuery+="         AND SE2.E2_FLUXO<>'N' "+CRLF
	cQuery+="         AND (SE2.E2_VENCREA BETWEEN '"+Dtos(MV_PAR04)+"' AND '"+Dtos(MV_PAR05)+"' )  "+CRLF


	MemoWrite("C:\temp\LOGSQL\"+_cPerg+"fProcSe2.txt" , cQuery) // escreve em arquivo de texto e se nao encontrar cria o arquivo

	DbUseArea(.T., "TOPCONN", TCGenQry(,,ChangeQuery(cQuery)), _cTbSe2, .F., .F.)



	While ( (_cTbSe2)->(!Eof()) )
		(_cALiasTmp)->(DbGoTop())
		If (_cALiasTmp)->(DbSeek("3F"+(_cTbSe2)->(TIPO + NATUREZ )))

			cData:= Iif(MV_PAR02 == 1,(_cTbSe2)->(VENCREA), SubStr((_cTbSe2)->(VENCREA),1,6))
			nPos := aScan(_aCols,{|x| x[2] == cData })
			If Reclock(_cALiasTmp,.F.)

				Replace (_cALiasTmp)->(&("VALOR"+StrZero(nPos,02))) With ((_cTbSe2)->(VALOR ) + (_cALiasTmp)->(&("VALOR"+StrZero(nPos,02))))

				(_cALiasTmp)->(MsUnLock())
			EndIf
		EndIf

		(_cTbSe2)->(dbSkip())
	EndDo

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} AjustaSX1
Ajusta as Perguntas.

@type function
@author Caio Renan
@since 15/07/2015
@version P12.1.23

@param cPerg, character, Nome do Cadastro de Pergunta.

@obs Desenvolvimento FIEG

@history 29/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function AjustaSX1(cPerg)

	//Local aHelp01 := {}
	//Local aHelp03 := {}
	//Local aHelp04 := {}
	//Local aHelp05 := {}
	//Local aHelp06 := {}
	//Local _nLenFilial := Len(FWxFilial("CT1"))

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	//	PutSx1(cPerg, "01", "Considera fluxo?"       ,"","","mv_ch1","N",01         ,00,00,"C","",""    ,"","","mv_par01","1-Sintético","","","","2-Analítico","","","","","","","","","","","",,"","","")
	//	PutSx1(cPerg, "02", "Tipo?"                  ,"","","mv_ch2","N",01         ,00,00,"C","",""    ,"","","mv_par02","1-Dia","","","","2-Mês","","","","","","","","","","","",,"","","")
	//	PutSx1(cPerg, "03", "Natureza?"              ,"","","mv_ch3","C",20         ,00,00,"R","","SED" ,"","","mv_par03","","","","","","","","","","","","","","","","",,"","","")
	//	PutSx1(cPerg, "04", "Data de?"               ,"","","mv_ch4","D",08         ,00,00,"G","",""    ,"","","mv_par04","","","","","","","","","","","","","","","","",,"","","")
	//	PutSx1(cPerg, "05", "Data ate?"              ,"","","mv_ch5","D",08         ,00,00,"G","",""    ,"","","mv_par05","","","","","","","","","","","","","","","","",,"","","")
	//	PutSx1(cPerg, "06", "Mostra visão?"          ,"","","mv_ch6","N",01         ,00,00,"C","",""    ,"","","mv_par06","1-Geral","","","","2-Operacional","","","3-Investimento","","","4-Financiamento","","","","","",,"","","")
	//	PutSx1(cPerg, "07", "Seleciona Filial?"      ,"","","mv_ch7","N",01         ,00,00,"C","",""    ,"","","mv_par07","1-Sim","","","","2-Não","","","","","","","","","","","",,"","","")
	//	PutSx1(cPerg, "08", "Compor Saldo Alterior?" ,"","","mv_ch8","N",01         ,00,00,"C","",""    ,"","","mv_par08","1-Sim","","","","2-Não","","","","","","","","","","","",,"","","")
	//	PutSx1(cPerg, "09", "Cons. Pedido de Compra?","","","mv_ch9","N",01         ,00,00,"C","",""    ,"","","mv_par09","1-Sim","","","","2-Não","","","","","","","","","","","",,"","","")

Return Nil
