#include "totvs.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} DTATFV01
Validacao (X3_VLDUSER) do campo N1_LOCAL na rotina de transferencia ATF060.

@type function
@author Eduardo Fernandes
@since 17/07/2014
@version P12.1.23

@obs Desenvolvimento FIEG

@history 20/02/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return lRet, verdadeitro se validação estiver OK.
/*/
/*/================================================================================================================================/*/

User Function DTATFV01()

Local lRet        := .T.
Local aArea       := GetArea()  
Local cCampo      := ReadVar()
Local cConteudo   := &(ReadVar()) 
Local cBloqLoc    := GetAdvFVal("SNL","NL_BLOQ", xFilial("SNL") + cConteudo ,1)

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Valida LOCAL >----------------------------------------
If AllTrim(cCampo) == "N1_LOCAL" .And. AllTrim(FunName()) == "ATFA060"
	If cBloqLoc == '1'
		Aviso('Aviso','LOCAL utilizado esta bloqueado (NL_BLOQ == 1)',{'Ok'}) 
		lRet := .F.
	Endif	
Endif

//--< Restaura as Areas >-----------------------------------
RestArea(aArea)

Return lRet                       


/*/================================================================================================================================/*/
/*/{Protheus.doc} DTATF01V
Funcao para controle de versao.

@type function
@author Doit Sistemas
@since 02/09/2014
@version P12.1.23

@obs Desenvolvimento FIEG

@history 20/02/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return cRet, versão da rotina.
/*/
/*/================================================================================================================================/*/

User Function DTATF01V() 

Local cRet  := ""                         

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
cRet := "20140902001" 
        
Return (cRet)
