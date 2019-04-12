#Include "Protheus.ch"
#Include "TopConn.Ch"
#Include "FileIO.Ch"

#Define ENTER CHR(13)+CHR(10)

/*/================================================================================================================================/*/
/*/{Protheus.doc} SIFISA04
Rotina para geração do arquivo de guia de recolhimento conforme o layout definido nas tabelas SZA e SZB.

@type function
@author Renato Lucena Neves
@since 23/08/2011
@version P12.1.23

@obs Projeto ELO

@history 21/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function SIFISA04()

	Local _aSays	:= {}
	Local _aButtons	:= {}
	Local _cTitle	:= "Exportação de Guias de Recolhimento"
	//Local _cPerg	:= PadR("XFISA04",len(SX1->X1_GRUPO))
	Local _nOpca	:= 0
	Local _lEnd		:= .F.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	//+--------------------------------+
	//|Cria o grupo de perguntas do SX1|
	//+--------------------------------+
	//AjustaSX1(_cPerg)

	AADD(_aSays,"Rotina específica para exportação de guias de")
	AADD(_aSays,"impostos conforme layout pré definido.")
	AADD(_aSays,"Os layouts devem estar previamente cadastrados")
	AADD(_aSays,"antes da exportação dos dados")

	AADD(_aButtons, { 5,.T.,{|| pergunte(_cPerg,.T.) } } )
	AADD(_aButtons, { 1,.T.,{|o| _nOpca:= 1,o:oWnd:End()}} )
	AADD(_aButtons, { 2,.T.,{|o| _nOpca:= 2,o:oWnd:End()}} )
	FormBatch( _cTitle, _aSays, _aButtons )


	Pergunte(_cPerg,.F.)


	//+------------------------------------------------------------------------+
	//|Se confirmou e os parametros são validos executa o processamento		   |
	//+------------------------------------------------------------------------+
	If _nOpca = 1 .and. ValidPar()
		Processa({|_lEnd| GeraGuia(@_lEnd)} )
	Endif

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} GeraGuia
Gera o arquivo de guia de recolhimento conforme layout previamente cadasstrado (SZA/SZB).

@type function
@author Thiago Rasmussen
@since 23/08/2011
@version P12.1.23

@param _lEnd, Lógica, Variável que indica que o botão cancelar foi clicado.

@obs Projeto ELO

@history 21/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function GeraGuia(_lEnd)
	Local _cQuery 		:= ""
	Local _lOracle  	:= ( AllTrim(TCGetDB()) == "ORACLE" )
	Local _nHandle		:= 0
	Local _cFile		:= ""
	Local _cPath		:= AllTrim(MV_PAR13)
	Local _cLayout		:= MV_PAR01
	Local _cSeparador   := ""
	Local _nCt			:= 0
	Local lSegue        := .T.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	//+-------------------------------------------------------------+
	//|Define o separador de campos e nome do arquivo a ser gerado  |
	//+-------------------------------------------------------------+
	DbSelectArea("SZA")
	SZA->(DbSetOrder(1))
	SZA->(DbSeek(xFilial("SZA")+MV_PAR01))
	_cFile := AllTrim(SZA->ZA_PREFIXO)+StrZero(MV_PAR08,4)+StrZero(MV_PAR07,2)+"."+AllTrim(SZA->ZA_EXT)

	Do Case
		Case SZA->ZA_DELIMIT = "1"
		_cSeparador := ";"
		Case SZA->ZA_DELIMIT = "2"
		_cSeparador := ","
		Case SZA->ZA_DELIMIT = "3"
		_cSeparador := Chr(9)
	EndCase

	//+--------------------------------------------------------+
	//|Verifica se o arquivo já existe se sim, exclui o arquivo|
	//+--------------------------------------------------------+
	If File(_cPath+_cFile)//verifica se o arquivo ja existe
		If MsgYesNo("O arquivo "+_cPath+_cFile+" já existe, para prosseguir será necessário excluir esse arquivo. Deseja continuar?")
			If fErase(_cPath+_cFile) = -1 //caso deu erro na exclusao
				MsgStop("O arquivo "+_cPath+_cFile+" não pode ser excluido. "+FError())
				lSegue := .F. //Return
			EndIf
		Else
			MsgAlert("Processo não finalizado.")
			lSegue := .F. //Return()
		EndIF
	EndIF

	If lSegue

		//+------------------------------------------+
		//|Seleciona os registros a serem processados|
		//+------------------------------------------+
		_cQuery := " Select R_E_C_N_O_ "
		_cQuery += " From "+RetSqlName("SF6")
		_cQuery += " Where F6_FILIAL = '"+xFilial("SF6")+"' and D_E_L_E_T_='' "
		_cQuery += " and F6_NUMERO between '"+MV_PAR02+"' and '"+MV_PAR03+"' "
		_cQuery += " and F6_EST between '"+MV_PAR04+"' and '"+MV_PAR05+"' "
		_cQuery += " and F6_DTVENC = '"+DToS(MV_PAR06)+"' "
		_cQuery += " and F6_MESREF = "+AllTrim(Str(MV_PAR07))+" "
		_cQuery += " and F6_ANOREF = "+AllTrim(Str(MV_PAR08))+" "
		_cQuery += " and F6_TIPOIMP = '"+SZA->ZA_TIPO+"' "
		If _lOracle
			_cQuery += " and F6_CLIFOR||F6_LOJA between '"+MV_PAR09+MV_PAR10+"' and '"+MV_PAR11+MV_PAR12+"' "
		Else
			_cQuery += " and F6_CLIFOR+F6_LOJA between '"+MV_PAR09+MV_PAR10+"' and '"+MV_PAR11+MV_PAR12+"' "
		EndIf
		_cQuery := changequery(_cQuery)

		MemoWrit( 'SIFISA04.SQL', _cQuery )

		dBUseArea( .T., 'TOPCONN', TCGENQRY( ,, _cQuery ), 'QRY1', .F., .T. )

		QRY1->( dbEval( { || _nCt++ },,{ || !EOF() } ) )
		QRY1->( dbGoTop() )
		ProcRegua( _nCt )

		IF _nCt == 0
			MsgAlert("Não existem dados a serem gerados!")
			QRY1->(dbCloseArea())
			lSegue := .F. //Return()
		ELSE
			//+------------------------------------0+
			//|Cria o arquivo no local especificado|
			//+------------------------------------0+
			_nHandle := FCreate(_cPath+_cFile)
			If _nHandle = -1
				MsgStop("O arquivo "+_cPath+_cFile+" não pode ser criado. "+FError())
				lSegue := .F. //Return
			EndIf
		ENDIF

		If lSegue

			While QRY1->(!Eof())
				IncProc()

				SF6->(DbGoTo(QRY1->R_E_C_N_O_))
				IF SF6->(Recno()) == QRY1->R_E_C_N_O_
					EscreveArq(_cLayout,_nHandle,_cSeparador)
				ENDIF

				QRY1->(DbSkip())
			EndDo

			QRY1->(dbCloseArea())
			fClose(_nHandle) //fecha o arquivo
			MsgAlert("Processamento concluído.")

		EndIf

	EndIf

Return()

/*/================================================================================================================================/*/
/*/{Protheus.doc} EscreveArq
Escreve uma linha no arquivo conforme configuração do Layout.

@type function
@author Thiago Rasmussen
@since 23/08/2011
@version P12.1.23

@param _cLayout, Caractere, Código do Layout.
@param _nHandle, Caractere, Manipulador do Arquivo.
@param _cSep, Caractere, Caractere separador.

@obs Projeto ELO

@history 21/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function EscreveArq(_cLayout,_nHandle,_cSep)
	Local _aArea  := GetArea()
	Local _cLinha := ""

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	SZB->(dbSetOrder(1))
	SZB->(dbSeek(xFilial("SZB")+_cLayout))

	While SZB->(!Eof()) .and. SZB->ZB_FILIAL == xFilial("SZB") .and. SZB->ZB_LAYOUT == _cLayout

		IF SZB->ZB_TIPO == "1" //Campo Fixo
			_cLinha += AllTrim(SZB->ZB_FORMULA)
		Else //Formula
			_cLinha += FormataTexto(&(SZB->ZB_FORMULA))
		EndIF

		_cLinha += _cSep

		SZB->(DbSkip())
	EndDo


	FWrite(_nHandle,_cLinha+ENTER )

	RestArea(_aArea)

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} ValidPar
Verifica se os parametros selecionados são validos.

@type function
@author Renato Lucena Neves
@since 23/08/2011
@version P12.1.23

@obs Projeto ELO

@history 21/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Verdadeiro ou Falso indicando que os parâmetros selecionados são validos.

/*/
/*/================================================================================================================================/*/

Static Function ValidPar()

	Local _lRet		:= .T.
	Local _cErro	:= ""
	Local _cTitulo	:= ""
	Local _aArea	:= GetArea()

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	DbSelectArea("SZA")
	SZA->(DbSetOrder(1))
	SZA->(DbSeek(xFilial("SZA")+MV_PAR01))

	Do Case
		Case MV_PAR03 < MV_PAR02
		_lRet 	:= .F.
		_cTitulo:= "N+mero inválido"
		_cErro 	:= "Faixa de numeração (de/até) inválida. Verifique os parâmetros. "
		Case MV_PAR05 < MV_PAR04
		_lRet 	:= .F.
		_cTitulo:= "Estado inválido"
		_cErro 	:= "Faixa de estado de/até) inválido. Verifique os parâmetros. "
		Case ( MV_PAR11+MV_PAR12 )  < ( MV_PAR09+MV_PAR10 )
		_lRet 	:= .F.
		_cTitulo:= "Cliente + Loja inválido"
		_cErro 	:= "Faixa de Cliente + Loja (de/até) inválido. Verifique os parâmetros. "
		Case SZA->(!Found())
		_lRet 	:= .F.
		_cTitulo:= "Layout inválido"
		_cErro 	:= "O layout definido é inválido. Verifique os parâmetros. "
		Case Empty(MV_PAR13) .or. !ExistDir(MV_PAR13)
		_lRet	:= .F.
		_cTitulo:= "Caminho inválido"
		_cErro 	:= "O caminho de gravação do arquivo (Path)é inválido. Verifique os parâmetros. "
	EndCase


	//+------------------------------------------------------+
	//|Em caso de parametro inválido exibe a mensagem de erro|
	//+------------------------------------------------------+
	If !_lRet
		MsgAlert(_cErro,_cTitulo)
	EndIf


	RestArea(_aArea)

Return _lRet

/*/================================================================================================================================/*/
/*/{Protheus.doc} AjustaSX1
Cria o grupo de perguntas no SX1.

@type function
@author Renato Lucena Neves
@since  23/08/2011
@version P12.1.23

@param _cPerg, Caractere, Nome da Pergunta.

@obs Projeto ELO

@history 21/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@deprecated Static Function sem efeito pois a funçao PutSx1 que inclui pengunta no dicionário foi descontinuada.
/*/
/*/================================================================================================================================/*/

Static Function AjustaSX1(_cPerg)

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	//	PutSx1(_cPerg,"01","Layout ?","Layout ?","Layout ?","mv_ch1","C",TamSx3("ZA_COD")[1],0,0,"G","","SZA","X01","","MV_PAR01","","","","","","","","","","","","","","","","",{},{},{})
	//	PutSx1(_cPerg,"02","Numero de ?","Numero de ?","Numero de ?","mv_ch2","C",TamSx3("F6_NUMERO")[1],0,0,"G","","XSF6","","","MV_PAR02","","","","","","","","","","","","","","","","",{},{},{})
	//	PutSx1(_cPerg,"03","Numero ate ?","Numero ate ?","Numero ate ?","mv_ch3","C",TamSx3("F6_NUMERO")[1],0,0,"G","","XSF6","","","MV_PAR03","","","","","","","","","","","","","","","","",{},{},{})
	//	PutSx1(_cPerg,"04","Estado de ?","Estado de ?","Estado de ?","mv_ch4","C",TamSx3("F6_EST")[1],0,0,"G","","12","010","","MV_PAR04","","","","","","","","","","","","","","","","",{},{},{})
	//	PutSx1(_cPerg,"05","Estado ate ?","Estado ate ?","Estado ate ?","mv_ch5","C",TamSx3("F6_EST")[1],0,0,"G","","12","010","","MV_PAR05","","","","","","","","","","","","","","","","",{},{},{})
	//	PutSx1(_cPerg,"06","Vencimento ?","Vencimento ?","Vencimento ?","mv_ch6","D",8,0,0,"G","","","","","MV_PAR06","","","","","","","","","","","","","","","","",{},{},{})
	//	PutSx1(_cPerg,"07","Mes ?","Mes ?","Mes ?","mv_ch7","N",02,0,0,"G","(MV_PAR07>=1.AND.MV_PAR07<=12)","","","","MV_PAR07","","","","","","","","","","","","","","","","",{},{},{})
	//	PutSx1(_cPerg,"08","Ano ?","Ano ?","Ano ?","mv_ch8","N",04,0,0,"G","","","","","MV_PAR08","","","","","","","","","","","","","","","","",{},{},{})
	//	PutSx1(_cPerg,"09","Cliente de ?","Cliente de ?","Cliente de ?","mv_ch9","C",TamSx3("F6_CLIFOR")[1],0,0,"G","","SA1","001","","MV_PAR09","","","","","","","","","","","","","","","","",{},{},{})
	//	PutSx1(_cPerg,"10","Loja de ?","Loja de ?","Loja de ?","mv_cha","C",TamSx3("F6_LOJA")[1],0,0,"G","","","002","","MV_PAR10","","","","","","","","","","","","","","","","",{},{},{})
	//	PutSx1(_cPerg,"11","Cliente ate ?","Cliente ate ?","Cliente ate ?","mv_chb","C",TamSx3("F6_CLIFOR")[1],0,0,"G","","SA1","001","","MV_PAR11","","","","","","","","","","","","","","","","",{},{},{})
	//	PutSx1(_cPerg,"12","Loja ate ?","Loja ate ?","Loja ate ?","mv_chc","C",TamSx3("F6_LOJA")[1],0,0,"G","","","002","","MV_PAR12","","","","","","","","","","","","","","","","",{},{},{})
	//	PutSx1(_cPerg,"13","Caminho do Arquivo ?","Caminho do Arquivo ?","Caminho do Arquivo ?","mv_chd","C",60,0,0,"G","","DIR2","","","MV_PAR13","","","","","","","","","","","","","","","","",{},{},{})

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |FormataTextoºAutor  |Microsiga           º Data |  29/09/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     |Funcao de formatacao do conteudo para TEXTO                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


/*/================================================================================================================================/*/
/*/{Protheus.doc} FormataTexto
Função de formatação do conteúdo para TEXTO.

@type function
@author Thiago Rasmussen
@since 29/09/11
@version P12.1.23

@param uConteudo, Indefindo, Valor a ser formatado.

@obs Projeto ELO

@history 21/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Caractere, Valor formatado.

/*/
/*/================================================================================================================================/*/

Static Function FormataTexto(uConteudo)
	Local cRetorno := ""

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If ValType(uConteudo) == "C"
		cRetorno := uConteudo
	ElseIf ValType(uConteudo) == "D"
		cRetorno := DToS(uConteudo)
	ElseIf ValType(uConteudo) == "N"
		cRetorno := AllTrim(Str(uConteudo))
	EndIf

Return(cRetorno)
