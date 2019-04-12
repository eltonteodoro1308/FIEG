#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SISP001
ExecBlock disparado para retornar agencia e conta Forncedor Campo 024-043 do CNAB a Pagar.

@type function
@author Wagner Farias - TOTVS
@since 15/08/2012
@version P12.1.23

@obs Projeto ELO

@history 13/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Caractere, Função sem retorno.
/*/
/*/================================================================================================================================/*/

User Function SISP001()

Local _cReturn

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
cBcoemp:= PADL(SUBSTR(SA6->A6_COD,1,3),3,"0")
cBanco := IIF(!EMPTY(SE2->E2_XBANC)  ,PADL(SUBSTR(SE2->E2_XBANC,1,3),3,"0"),  PADL(SUBSTR(SA2->A2_BANCO,1,3),3,"0"))
cAgenc := IIF(!EMPTY(SE2->E2_XAGENC) ,PADL(SUBSTR(SE2->E2_XAGENC,1,5),5,"0"), PADL(SUBSTR(SA2->A2_AGENCIA,1,5),5,"0"))
cConta := IIF(!EMPTY(SE2->E2_XNUMCON),STRZERO(VAL(STRTRAN(SE2->E2_XNUMCON,"-","")),10), STRZERO(VAL(STRTRAN(SA2->A2_NUMCON,"-","")),10))

IF cBcoemp == "341" .and. cBanco == "341"
	_cReturn :=	STRZERO(VAL(ALLTRIM(SUBSTR(cAgenc,1,4))),5)+" "+STRZERO(VAL(SUBSTR(cConta,1,len(cConta)-1)),12)+" "+ IIF(SEA->EA_MODELO $ "10/02", "0",Right(cConta,1))
Endif
IF cBcoemp == "341"
	_cReturn :=	STRZERO(VAL(ALLTRIM(SUBSTR(cAgenc,1,4))),5)+" "+STRZERO(VAL(SUBSTR(cConta,1,len(cConta)-1)),12)+" "+Right(cConta,1)
Endif
IF cBcoemp <> "341"
	_cReturn :=	StrZero(Val(ALLTRIM(SUBSTR(cAgenc,1,5))),6)+STRZERO(VAL(ALLTRIM(SUBSTR(cConta,1,10))),13)+" "
Endif

Return(_cReturn)
