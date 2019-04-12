#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MA020ROT
Cadastro de Tipo de Documento (SZ5).

@type function
@author Leonardo Soncin - TOTVS
@since 12/09/2011
@version P12.1.23

@obs Projeto ELO

@history 22/02/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return aRot, Retorna Array com as opções para o menu.
/*/
/*/================================================================================================================================/*/

User Function MA020ROT

Local aRot := { {"Regularidade Fiscal","U_SICOMA12",0,4} }

//--< Log das Personalizações >-----------------------------
U_LogCustom()

Return aRot
