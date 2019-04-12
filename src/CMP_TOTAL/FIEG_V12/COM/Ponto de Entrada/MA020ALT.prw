#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MA020ALT
Ponto de Entrada para Obrigatoriedade do CNPJ.

@type function
@author TOTVS
@since 05/16/2012
@version P12.1.23

@obs Projeto ELO

@history 22/02/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return lOk, Retorna verdadeiro se validações OK.
/*/
/*/================================================================================================================================/*/

User Function MA020ALT()

Local lOK	:= .F.      
Local lCNPJ := SuperGetMv("SI_xCNPJ",.F.,.F.,Substr(cFilant,1,4))                              

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
If lCNPJ
	If (M->A2_TIPO = "X" .Or. !Empty(M->A2_CEINSS))
		lOk := .T.
	ElseIf Empty(M->A2_CGC)
		lOk := .F.	
		MsgStop("Para este fornecedor deve ser preenchido o campo CGC.")     	
	ElseIf !Empty(M->A2_CGC)	
		lOk := .T.
	Endif
Else 
	lOk:=.T.
Endif

Return(lOk)
