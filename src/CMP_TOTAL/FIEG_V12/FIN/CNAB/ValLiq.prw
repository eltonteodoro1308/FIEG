#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} ValLiq
Retorna Valor liquido para montagem do CNAB.

@type function
@author Wagner Farias - TOTVS
@since 15/08/2012
@version P12.1.23

@obs Projeto ELO

@history 13/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

User Function ValLiq()

Local cValLiq := ""
Local nAbat   := 0
Local nDecres := 0
Local nAcresc := 0

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
If FunName() == "FINA150"
		nAbat	:= SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)
		nAcresc := SE1->E1_SDACRES
		nDecres := SE1->E1_SDDECRE
		cValLiq:=PADL(Alltrim(str((SE1->E1_SALDO - nAbat + nAcresc - nDecres ) * 100 )), 15 , "0")
Else	
	If GetMv("MV_BX10925") == "1"
		nAbat	:= SomaAbat(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,"P",SE2->E2_MOEDA,,SE2->E2_FORNECE)
		nAcresc := SE2->E2_SDACRES
		nDecres := SE2->E2_SDDECRE
		cValLiq:=PADL(Alltrim(str((SE2->E2_SALDO - nAbat + nAcresc - nDecres ) * 100 )), 15 , "0")
	Else                          
		nAcresc := SE2->E2_SDACRES
		nDecres := SE2->E2_SDDECRE	
		cValLiq := PADL(Alltrim(str((SE2->E2_SALDO + nAcresc - nDecres ) * 100 )), 15 , "0")
	Endif
Endif

Return(cValLiq)
