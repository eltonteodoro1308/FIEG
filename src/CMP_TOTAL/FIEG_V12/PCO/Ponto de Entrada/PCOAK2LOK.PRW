#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} PCOAK2LOK
Validacao da linha da planilha.

@type function
@author TOTVS
@since 13/03/2012
@version P12.1.23

@param Parametro_01, Num�rico, Informe a descri��o do 1� par�mtro.

@obs Projeto ELO

@history 21/03/2019, Kley@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23. 

@return L�gico, Retorna verdadeiro se todas as valida��es estiverem OK.
/*/
/*/================================================================================================================================/*/

User Function PCOAK2LOK()

Local _lRet     := .T.    
Local _aArea    := GetArea()   
Local _lChanged	:=	.F.

//--< Log das Personaliza��es >-----------------------------
U_LogCustom()

//--< ACHAR AS COLUNAS DE VALOR >---------------------------
_aHeadVal :=	{}
For _nX := 1 To Len(oGD[1]:aHeader)
	If AllTrim(oGD[1]:aHeader[_nX,2]) == "AK2_VAL"
		AADD(_aHeadVal,{_nX,DTOS(CTOD(Substr(oGD[1]:aHeader[_nX][1],1,10)))})
	Endif
Next
nLenHeadVal	:=	Len(_aHeadVal)

For _nCntFor2 := 1 to nLenHeadVal
	nPosVal	:=	_aHeadVal[_nCntFor2,1]
	
	AK2->(DbSetOrder(1))
	dbSelectArea("AK2")
	dbSetOrder(5)
	_cID := GDFieldGet("AK2_ID",oGD[1]:nAt,,oGD[1]:aHeader,oGD[1]:aCols) 
	If MsSeek(xFilial("AK2") + AK1->(AK1_CODIGO+AK1_VERSAO) + AK3->AK3_CO + _cID+ _aHeadVal[_nCntFor2,2])
		
		//--< Verificar se mudou o valor antes de  continuar. >--
		If PcoPlanVal(oGD[1]:aCols[oGD[1]:nAt,nPosVal],AK2->AK2_CLASSE) <> AK2->AK2_VALOR
			_lChanged := .T.
		Endif
		
		//--< Verificar se mudou algum campo antes de continuar. >--
		If !_lChanged
			For _nCntFor3 := 1 To Len(oGD[1]:aHeader)
				If ( oGD[1]:aHeader[_nCntFor3,10] != "V" ) .And. AllTrim(oGD[1]:aHeader[_nCntFor3,2]) != "AK2_VAL"
					If AK2->(FieldGet(FieldPos(oGD[1]:aHeader[_nCntFor3,2]) )) <> oGD[1]:aCols[oGD[1]:nAt,_nCntFor3]
						_lChanged	:=	.T.
						Exit
					Endif
				ElseIf AllTrim(oGD[1]:aHeader[_nCntFor3,2]) == "AK2_VAL"
					If (nPos := Ascan(aFormula, {|aVal|aVal[1]==nCntFor .And. aVal[2]==Alltrim(oGD[1]:aHeader[_nCntFor3][1])})) >  0 .And. Alltrim(AK2->AK2_FORMUL) <> Alltrim(aFormula[nPos][3])
						_lChanged	:=	.T.
						Exit
					Endif
				EndIf
			Next _nCntFor3
		Endif
		
	ENDIF
	
Next _nCntFor2

If _lChanged .and. GDFieldGet("AK2_XSTS")  == "1" 			// Or�amento finalizado
	Aviso("Aviso","Este or�amento est� finalizado e n�o poder� ser alterado.",{"Sair"})
	_lRet := .F.
EndIf

RestArea(_aArea)

Return _lRet
