#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} FIPCOE01
Retorna Codigo da Planilha Orcamentaria.

@type function
@author Thiago Rasmussen
@since 10/13/2011
@version P12.1.23

@obs Desenvolvimento FIEG

@history 21/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Caractere, Código da Planilha Orcamentaria.
/*/
/*/================================================================================================================================/*/

User Function FIPCOE01()

Local aAliasAK1	:= AK1->(GetArea())
Local _cCodPla  := ""
Local _dDataLan := AKC->AKC_DATA

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
AK1->(DbGoTop())

While !AK1->(Eof())
	If &_dDataLan >= AK1->AK1_INIPER .AND. &_dDataLan <= AK1->AK1_FIMPER .AND. xFilial() == AK1->AK1_FILIAL
		_cCodPla := AK1->AK1_CODIGO
		Exit
	Endif
	AK1->(DbSkip())
EndDo

AK1->(RestArea(aAliasAK1))

Return(_cCodPla)
