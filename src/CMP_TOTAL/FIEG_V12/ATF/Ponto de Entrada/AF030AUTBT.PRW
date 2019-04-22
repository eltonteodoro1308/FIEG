#Include "Protheus.ch"
Static _FILTRO
Static _TELA

/*/================================================================================================================================/*/
/*/{Protheus.doc} AF030AUTBT
Ponto de entrada que inclui op��es customizadas no menu A��es Relacionadas da tela de baixas de ativos em lote.

@type function
@author Thiago Rasmussen
@since 03/12/2014
@version P12.1.23

@param oDLG, object, descricao

@obs Desenvolvimento FIEG

@history 13/03/2019, elton.alves@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.

@return Array, Array com op��es customizadas.

/*/
/*/================================================================================================================================/*/

User Function AF030AUTBT(oDLG)

	Local aButtons := {}
	_FILTRO := ""
	_TELA   := PARAMIXB[1]:CCAPTION

	//--< Log das Personaliza��es >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	//----------------------------------------------------
	// Variavel utilizadas no ponto de entrada AF030GRV
	//----------------------------------------------------
	IF !( Type("_cpProcess") == "U" )
		_cpProcess := Nil
	ENDIF

	IF !( Type("_dpDtProc") == "U" )
		_dpDtProc := Nil
	ENDIF

	DEFINE SBUTTON FROM 30,246 TYPE 17  ENABLE OF oDlg ACTION SN3->(_FILTRO := BuildExpr("SN3",oDlg),U_AF03AUTFIL())

Return(aButtons)

/*/================================================================================================================================/*/
/*/{Protheus.doc} AF03AUTFIL
Ponto de entrada que cria filtros de ativos para sele��o na tela de baixa de ativo em lote.

@type function
@author Thiago Rasmussen
@since 03/12/2014
@version P12.1.23

@obs Desenvolvimento FIEG

@history 13/03/2019, elton.alves@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.

@return Caractere, Filtro a ser aplicado na tela.

/*/
/*/================================================================================================================================/*/

User Function AF03AUTFIL()

	//--< Log das Personaliza��es >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	IF EMPTY(ALLTRIM(_FILTRO))
		_FILTRO := IIF(_TELA=="Baixas Autom�ticas",'N3_BAIXA=="0"','N3_BAIXA=="1"')
	ELSE
		_FILTRO := IIF(_TELA=="Baixas Autom�ticas",'N3_BAIXA=="0" .AND. ','N3_BAIXA=="1" .AND. ') + _FILTRO
	ENDIF

Return _FILTRO