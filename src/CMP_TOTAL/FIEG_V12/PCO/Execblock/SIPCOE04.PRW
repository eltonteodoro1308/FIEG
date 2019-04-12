#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SIPCOE04
Tratamento do campo valor da baixa da SC  - Lacto 000052/01.

@type function
@author TOTVS
@since 08/06/2012
@version P12.1.23

@param _nPar, Numérico, Informe a descrição do 1º parêmtro.

@obs Projeto ELO

@history 21/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Numérico, Valor usado no lançamento do PCO.
/*/
/*/================================================================================================================================/*/

User Function SIPCOE04(_nValor)

Local _nRet := _nValor

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
IF SC1->C1_APROV <> "B" .AND. !EMPTY(SC7->C7_NUMSC)
	SC1->(DbSeek(xFilial("SC1")+SC7->C7_NUMSC+SC7->C7_ITEMSC))
	If SC7->C7_TOTAL < ((SC1->C1_QUANT - SC1->C1_QUJE) * SC1->C1_VUNIT)
		_nRet := SC7->C7_TOTAL
	Elseif SC7->C7_TOTAL >= (SC1->C1_QUANT * SC1->C1_VUNIT) .OR. (SC7->C7_QUANT == SC1->C1_QUANT)
		_nRet := (SC1->C1_QUANT * SC1->C1_VUNIT)
	Elseif (SC1->C1_QUANT - SC1->C1_QUJE) == 0 .AND. (SC7->C7_QUANT < SC1->C1_QUANT)
		_nRet := (SC7->C7_QUANT * SC1->C1_VUNIT)
	Endif
ElseIf EMPTY(SC7->C7_NUMSC)
	_nRet := 0
Endif    

Return(_nRet)
