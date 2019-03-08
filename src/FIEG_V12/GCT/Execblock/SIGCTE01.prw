#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SIGCTE01
Filtra Item Contabil de acordo com cadastro de amarra��o cont�bil.

@type function
@author Thiago Rasmussen
@since 03/12/2012
@version P12.1.23

@obs Desenvolvimento FIEG

@history 08/03/2019, elton.alves@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.

@return L�gico, Verdadeiro ou Falso para Macro Filtro no SXB(Consulta Padr�o).

/*/
/*/================================================================================================================================/*/

User Function SIGCTE01()

	//--< Log das Personaliza��es >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	cFiltro := ""
	If Alltrim(Upper(FunName())) == "MATA110"
		cFiltro := "CTA_FILIAL == XFILIAL('CTA') .AND. CTA_CUSTO == CCUSTO"
	Elseif Alltrim(Upper(FunName())) == "CNTA200"
		_nPosCC	:= aScan(aHeader,{|x| Alltrim(x[2]) == "CNB_CC"})
		cFiltro := "CTA_FILIAL == XFILIAL('CTA') .AND. CTA_CUSTO == aCols[n][_nPosCC]"
	Elseif Alltrim(Upper(FunName())) == "CNTA100"
		_nPosCC	:= aScan(aHeader,{|x| Alltrim(x[2]) == "CNB_CC"})
		cFiltro := "CTA_FILIAL == XFILIAL('CTA') .AND. CTA_CUSTO == aCols[n][_nPosCC]"
	Endif

Return(&cFiltro)
