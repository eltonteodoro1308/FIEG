#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SICOME01
Faz a verificacao de produto estocavel ou nao com relacao a SA ou SC.

@type function
@author TOTVS
@since Mar/2012
@version P12.1.23

@param cTipo, Caractere, SA=Solicitacao ao armazem; SC=Solicitacao de Compra.

@obs Projeto ELO, Alterado pela FIEG

@history 21/02/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return lRet, Retorna True se validações OK.
/*/
/*/================================================================================================================================/*/

User Function SICOME01(cTipo)

Local lRet 		:= .T.
Local cProduto 	:= &(ReadVar())//Traz o produto digitdo na SA ou SC
Local cEst		:= " "

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
If Upper(Alltrim(GetMv("MV_ARQPROD"))) == "SB1"
	cEst := GetAdvFVal("SB1","B1_XESTQ",xFilial("SB1")+cProduto,1,0) //1=Sim(Estocavel) 2=Nao(Nao estocavel)
Else
	cEst := GetAdvFVal("SBZ","BZ_XESTQ",xFilial("SBZ")+cProduto,1,0) //1=Sim(Estocavel) 2=Nao(Nao estocavel)
EndIf

//--< 07/11/2018 - Thiago Rasmussen - Validação para as solicitações de armazém, permite informar somente produtos do local 02. >--
IF cTipo == "SA"
	IF Posicione("SB1",1,XFILIAL("SB1")+cProduto,"B1_LOCPAD") != "02"
		MsgAlert("Somente produtos armazenados no local 02 podem ser informados para solicitações de armazém.","SICOME01")
		lRet := .F.
	ENDIF
ENDIF
	
If SuperGetMv("SI_PRODEST",.T.,.T.) 						//Indica se permite(.T.) ou nao(.F.) a inclusao de produto estocavel na SA ou SC. Por padrao .T.
	Return(lRet)
EndIf

If cTipo == "SA" 											//Se for SA, aceito somente produto estocavel B1_XESTQ = 1-Sim
	If cEst == "2" 											//Se for nao estocavel, nao permito continuar
		MsgAlert("Produto não estocável não pode ser utilizado na SA, favor uilizar SC.","SICOME01")
		lRet := .F.
	EndIf

ElseIf cTipo == "SC"										//Se for SC, aceito somente produto nao estocavel B1_XESTQ = 2-Nao
	If cEst <> "2" 											//Se for estocavel, nao permito continuar.
		MsgAlert("Produto estocável não pode ser utilizado na SC, favor uilizar SA.","SICOME01")
		lRet := .F.
	EndIf

EndIf

Return(lRet)
