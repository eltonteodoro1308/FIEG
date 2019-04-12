#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} PCOA3102
Ponto de entrada utilizado para inclusao de funcoes de usuarios na validacao do reprocessamento dos Lancamentos.

@type function
@author Carlos Henrique
@since 01/04/2013
@version P12.1.23

@obs Desenvolvimento FIEG

@history 21/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Lógico, Retorna verdadeiro se filtro estiver OK.
/*/
/*/================================================================================================================================/*/

USER FUNCTION PCOA3102()

Local cProc	:= PARAMIXB[1]
Local cItem	:= PARAMIXB[2] 
Local aPar	:= PARAMIXB[3]
Local lRet	:= .T.

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
If cProc+cItem == "00008201"
	lRet:=	CT2->CT2_DATA >= aPar[4] .And. CT2->CT2_DATA <= aPar[5] 
ElseIf cProc+cItem == "00005401"
	lRet:=	SD1->D1_EMISSAO >= aPar[4] .And. SD1->D1_EMISSAO <= aPar[5] 
EndIf

Return lRet
