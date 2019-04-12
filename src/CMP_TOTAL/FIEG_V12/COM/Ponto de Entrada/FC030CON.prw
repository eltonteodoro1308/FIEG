#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} FC030CON
Ponto de Entrada para consulta especifica na tela de posicao do fornecedor.

@type function
@author Fabricio Romera
@since 10/05/2011
@version P12.1.23

@obs Projeto ELO

@history 22/02/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

User Function FC030CON()	

Local aArea := GetArea()

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Consulta avaliacao de fornecedores >------------------
U_CNIA200(SA2->A2_COD, SA2->A2_LOJA)                        
		
RestArea(aArea) 		

Return
