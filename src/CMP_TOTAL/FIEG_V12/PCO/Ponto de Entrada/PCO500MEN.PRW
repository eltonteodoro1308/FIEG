#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} PCO500MEN
PE para remover opcao de EXCLUSAO da Contingencia.

@type function
@author TOTVS
@since 24/04/2012
@version P12.1.23

@obs Projeto ELO

@history 21/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Array, Opções da rotina.
/*/
/*/================================================================================================================================/*/

User Function PCO500MEN()

Local _aRet := ParamIXB

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Pesquisa e remove opção de exclusão da rotina de contingencia >--
IF (_nPosDel := Ascan(_aRet,{|x| x[2] == "PCOA500DLG" .and. x[4] == 5 })) > 0
	Adel(_aRet,_nPosDel)
	aSize(_aRet,Len(_aRet)-1)
ENDIF

Return(_aRet)
