#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} F420CHK
Valida se o bordero podera ser enviado para o arquivo de pagamento.

@type function
@author Leonardo Soncin - TOTVS
@since 08/11/2011
@version P12.1.23

@obs Projeto ELO

@history 13/03/2019, Kley@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23. 

@return Num�rico, Retorna "2" se o conte�do do campo EA_MODELO estiver contido no par�metro SI_MODALID.
/*/
/*/================================================================================================================================/*/

User Function F420CHK()

Local nRet     := 1
Local cModelo  := GetNewPar("SI_MODALID","")
Local aAreaSEA := SEA->(GetArea())
Local cModSEA  := Posicione("SEA",1,xFilial("SEA")+SE2->E2_NUMBOR,"EA_MODELO")

//--< Log das Personaliza��es >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
If cModSEA $ cModelo
	nRet := 2
Endif

RestArea(aAreaSEA)

Return nRet
