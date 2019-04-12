#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} ValLiq
Retorna Valor liquido para montagem do CNAB Pagamento.

@type function
@author José Fernando
@since 15/08/2012
@version P12.1.23

@obs Desenvolvimento FIEG

@history 13/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Caractere, String com o Valor Líquido.
/*/
/*/================================================================================================================================/*/

User Function ValLiqCnab()

Local nAbat   := 0
Local nAcresc := 0
Local nDecres := 0
Local cValLiq := ""

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------

nAbat	:= SomaAbat(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,"P",SE2->E2_MOEDA,,SE2->E2_FORNECE)
nAcresc := SE2->E2_SDACRES
nDecres := SE2->E2_SDDECRE
cValLiq := PADL(Alltrim(str((SE2->E2_SALDO - nAbat + nAcresc - nDecres ) * 100 )), 15 , "0")

Return(cValLiq)
