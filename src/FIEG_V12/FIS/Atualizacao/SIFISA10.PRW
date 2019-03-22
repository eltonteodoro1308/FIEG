#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SIFISA10
Mostra códigos de ISS.

@type function
@author Thiago Rasmussen
@since 24/08/2011
@version P12.1.23

@param _cAlias, Caractere,Alias da tabela.

@obs Projeto ELO

@history 21/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Verdadeiro ou Falso .

/*/
/*/================================================================================================================================/*/

User Function SIFISA10(_cAlias)
	Local _lRet		 := .T.
	Local aArea		 := GetArea()
	Local aAreaSF4	 := SF4->( GetArea() )
	Local aAreaSA1	 := SA1->( GetArea() )
	Local aAreaSA2	 := SA2->( GetArea() )
	Local cEst		 := ""
	Local cCodMun	 := ""
	Local _nLinha    := 0

	IF GDDeleted(n)

		//+--------------------------------------------------------------------------+
		//| Posicionar e Avaliar TES                                                 |
		//+--------------------------------------------------------------------------+
		SF4->(dbSetOrder(1))
		If _lRet .and. !SF4->(dbSeek(xFilial("SF4")+&(ReadVar()))) .or. SF4->F4_ISS == "N"

			IF _lRet
				IF _cAlias == "SD1"
					If cTipo $ "B,D"
						//+--------------------------------------------------------------------------+
						//| Posicionar Cliente                                                       |
						//+--------------------------------------------------------------------------+
						SA1->(dbSetOrder(1))
						SA1->(dbSeek(xFilial("SA1")+cA100For+cLoja))
						cEst	:= SA1->A1_EST
						cCodMun := SA1->A1_COD_MUN
					Else
						//+--------------------------------------------------------------------------+
						//| Posicionar Fornecedor                                                    |
						//+--------------------------------------------------------------------------+
						SA2->(dbSetOrder(1))
						SA2->(dbSeek(xFilial( "SA2" )+cA100For+cLoja))
						cEst	:= SA2->A2_EST
						cCodMun	:= SA2->A2_COD_MUN
					Endif
				ELSE
					If !(M->C5_TIPO $ "B,D")
						//+--------------------------------------------------------------------------+
						//| Posicionar Cliente                                                       |
						//+--------------------------------------------------------------------------+
						SA1->(dbSetOrder(1))
						SA1->(dbSeek(xFilial("SA1")+M->(C5_CLIENTE+C5_LOJACLI)))
						cEst	:= SA1->A1_EST
						cCodMun := SA1->A1_COD_MUN
					Else
						//+--------------------------------------------------------------------------+
						//| Posicionar Fornecedor                                                    |
						//+--------------------------------------------------------------------------+
						SA2->(dbSetOrder(1))
						SA2->(dbSeek(xFilial( "SA2" )+M->(C5_CLIENTE+C5_LOJACLI)))
						cEst	:= SA2->A2_EST
						cCodMun	:= SA2->A2_COD_MUN
					Endif
				ENDIF
			ENDIF

			//+--------------------------------------------------------------------------+
			//| Validar Estado e Cod Municipio do Cliente e/ou Fornecedor                |
			//+--------------------------------------------------------------------------+
			If _lRet .and. (Empty( cEst ) .or. Empty( cCodMun ))
				Help("",1,"OBRIGATÓRIO",,"Campo Estado ou Cod. Municipio do Fornecedor e/ou Cliente não cadastrado",4,0)
				_lRet := .f.
			Endif

			IF _lRet
				SZ9->(dbSetOrder(1))
				SZ9->(dbSeek(XFilial("SZ9")+cEst+cCodMun))

				_aCodigos := {}

				While SZ9->(!Eof()) .and. SZ9->Z9_FILIAL == XFilial("SZ9") .and. SZ9->(Z9_ESTADO+Z9_COD_MUN) == cEst+cCodMun
					Aadd(_aCodigos,{SZ9->Z9_CODSERV,Posicione("SX5",1,XFilial("SX5")+"60"+SZ9->Z9_CODSERV,"X5_DESCRI"),SZ9->Z9_ALIQ})
					SZ9->(dbSkip())
				Enddo

				IF Len(_aCodigos) == 0
					Help("",1,"CODISS",,"Não existem códigos de ISS cadastrados para o município "+cCodMun,4,0)
					lRet :=  .f.
				ELSEIF Len(_aCodigos) == 1
					IF _cAlias == "SD1"
						GDFieldPut("D1_CODISS",_aCodigos[1,1])
						GDFieldPut("D1_BASEISS",GDFieldGet("D1_TOTAL"))
						GDFieldPut("D1_ALIQISS",_aCodigos[1,3])
						GDFieldPut("D1_VALISS",GDFieldGet("D1_TOTAL")*(_aCodigos[1,3]/100))
					ELSE
						GDFieldPut("C6_CODISS",_aCodigos[1,1])
						GDFieldPut("C6_XALQISS",_aCodigos[1,3])
					ENDIF
				ELSE
					DEFINE MSDIALOG oDlg FROM  70,1 TO 300,550 TITLE "Informe o Codigo do Serviço" PIXEL STYLE DS_MODALFRAME
					oDlg:lEscClose := .F.
					@ 7,2 LISTBOX oLbx  Var cVar FIELDS HEADER 	"Código","Descrição","Alíquota" SIZE 205,65 OF oDlg PIXEL ON DBLCLICK (_nLinha := oLbx:nAt,oDlg:End()) //EditaCTB( oLbx )
					oLbx:SetArray(_aCodigos)
					oLbx:bLine := { || {_aCodigos[oLbx:nAt,1],_aCodigos[oLbx:nAt,2],Transform(_aCodigos[oLbx:nAt,3],"@E 999,999,999.99")}}
					oLbx:Align := CONTROL_ALIGN_ALLCLIENT
					ACTIVATE MSDIALOG oDlg Centered
					IF _cAlias == "SD1"
						GDFieldPut("D1_CODISS",_aCodigos[_nLinha,1])
						GDFieldPut("D1_BASEISS",GDFieldGet("D1_TOTAL"))
						GDFieldPut("D1_ALIQISS",_aCodigos[_nLinha,3])
						GDFieldPut("D1_VALISS",GDFieldGet("D1_TOTAL")*(_aCodigos[_nLinha,3]/100))
					ELSE
						GDFieldPut("C6_CODISS",_aCodigos[_nLinha,1])
						GDFieldPut("C6_XALQISS",_aCodigos[_nLinha,3])
					ENDIF
				ENDIF
				IF lRet .And. _cAlias == "SD1"
					MaFisAlt("IT_BASEISS",GDFieldGet("D1_BASEISS"),n)
					MaFisAlt("IT_ALIQISS",GDFieldGet("D1_ALIQISS"),n)
					MaFisAlt("IT_VALISS" ,GDFieldGet("D1_VALISS"),n)
				ENDIF
			ENDIF

		Endif

	EndIf

	RestArea(aAreaSF4)
	RestArea(aAreaSA1)
	RestArea(aAreaSA2)

Return lRet
