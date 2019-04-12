#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SICOMA32
Validacao da linha na Inclusao ou alteracao do Documento de entrada no preenchimento do campo D1_XDTREC .

@type function
@author Claudinei Ferreira - TOTVS
@since 16/01/2012
@version P12.1.23

@obs Desenvolvimento FIEG

@history 07/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Lógico, Retorna verdadeiro se validações estiverem OK.
/*/
/*/================================================================================================================================/*/

User Function SICOMA32()

Local aArea		:= GetArea()
Local lRet 		:= ParamIxb[1] 	
Local nPosDtRec	:= 0

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
If cTipo == 'N'
	
	nPosDtRec:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_XDTREC"})
	
	//--< Verifica preenchimento do campo Data do recebimento e linha do aCols nao deletada >--
	If Empty(aCols[n][nPosDtRec]) .and. !aCols[n][Len(aCols[n])]
		//--< Exibir mensagem somente se validacao do padrao estiver OK >--
		If lRet
			MsgStop("O campo *" + AllTrim(RetTitle("D1_XDTREC")) + "* deve ser preenchido !","Campo obrigatório")
			lRet:=.F.
		Else
			lRet:=.F.
		Endif
	Endif
	
Endif

RestArea(aArea)

Return (lRet)
