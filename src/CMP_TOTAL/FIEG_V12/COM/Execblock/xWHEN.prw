#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} xWHEN
Função genérica para ser utilizada no X3_WHEN, devido limitação de 60 caracteres.

@type function
@author Thiago Rasmussen
@since 29/10/2014
@version P12.1.23

@param _CAMPO, Caractere, Nome do Campo.

@obs Desenvolvimento FIEG

@history 23/01/2019, Daniel Flávio, Manutenção Evolutiva. OS: 463514.
@history 21/02/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return lRet, retorna verdadeiro de validações OK.
/*/
/*/================================================================================================================================/*/

User Function xWHEN(_CAMPO)   

Local lRet			:= .T.
Local _MV_XNFPARC 	:= ''

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
Do Case
	Case _CAMPO == "C1_XCODCOM"
		If XFILIAL("SC1")$"01GO0001;02GO0001;03GO0001;04GO0001;05GO0001"
			lRet := .F. 
        EndIf

		IF !Empty(GDFieldGet("C1_XCONTPR")) 
			lRet := .F. 
        EndIf

		If !Empty(POSICIONE("SB1",1,XFILIAL("SB1") + GDFieldGet("C1_PRODUTO"),"B1_XUSER")) .AND. !RetCodUsr()$("000238;000508")
			lRet := .F. 
		EndIf

	Case _CAMPO == "D1_QUANT"
		_MV_XNFPARC := SuperGetMV("MV_XNFPARC", .F.)     

		lRet :=  ( FUNNAME() == "MATA140" .AND. (GDFieldGet("D1_ITEMMED") == "2" .OR. RetCodUsr()$_MV_XNFPARC) )

	Case _CAMPO == "CNB_PRODUT"
	
		If FunName() == "CNTA100" 							// Contratos
			lRet := ( VALTYPE(M->CN9_XREGP) == "C" .AND. M->CN9_XREGP == '1' )
			
		ElseIf FunName() == "CNTA140" 						// Medições
			/*
				[cTipoCtr] 	- Tipo de Revisão 		- [1-Aditivo,2-Reajuste,3-Realinhamento,4-Readequação,5-Paralisação...]
				[cEspec]	- Espécie de Revisão 	- [1-Quantidade,2-Preço,3-Prazo,4-Quantidade/Prazo]
			*/
			If Type("N")#"U"
				lRet := ( cTipoCtr == '1' .AND. cEspec == '1' .AND. !(VALTYPE(CN9->CN9_XREGP) == "C" .AND. CN9->CN9_XREGP == '1') ) // Adicionar validações extras - Verificar com Thiago
			Else
				lRet := .F.
			EndIf
		
		Else
			lRet := .F.
			
		EndIf
	
	Case _CAMPO == "CNB_QUANT"
		lRet := ( (FUNNAME() == "CNTA140" .AND. SUBSTR(GDFieldGet("CNB_XITEM"),4,1) == "*") .OR. (FUNNAME() == "CNTA100" .AND. VALTYPE(M->CN9_XREGP) == "C" .AND. M->CN9_XREGP == '1') )
	Case _CAMPO == "CNB_REALI"
		lRet := ( FUNNAME() == "CNTA140" .AND. GDFieldGet("CNB_QUANT") > GDFieldGet("CNB_QTDMED") )
EndCase

Return lRet