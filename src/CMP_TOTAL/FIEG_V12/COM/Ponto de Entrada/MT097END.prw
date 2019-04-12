#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MT097END
Ponto de entrada de encerramento do processo de liberacao de pedido de compra / SC.

@type function
@author TOTVS FSW
@since 11/04/2011
@version P12.1.23

@obs Projeto ELO Alterado pela FIEG

@history 26/02/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

User Function MT097END()

Local aParam := PARAMIXB
Local cFiltroSCR
Local aAreaSCR

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
If PARAMIXB[2] == 'PC'
	cFiltroSCR := SCR->(dbFilter())
	aAreaSCR   := SCR->(GetArea())
	SCR->(dbClearFilter())
	U__fWFRetPC(,aParam)
	IF !Empty( cFiltroSCR ) 								// verifica filtro
		SCR->(DbSetfilter({||&cFiltroSCR},cFiltroSCR))
	EndIf
	SCR->(RestArea(aAreaSCR))
EndIf 		

Return
