#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SICOMA33
Rotina para filtrar fornecedores inabilitados.

@type function
@author Wanderley Monteiro - TOTVS
@since 13/01/2012
@version P12.1.23

@param Parametro_01, Numérico, Informe a descrição do 1º parêmtro.

@obs Projeto ELO

@history 07/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Array, Array com fornecedores.
/*/
/*/================================================================================================================================/*/

User Function SICOMA33(aFornec)

Local i
Local aRet    := {}
Local lAdd    := .f.
Local dDtHab  := CToD('')

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
// Estrutura do vetor
// aadd(aFornec,{ A5_FORNECE,;
//                A5_LOJA   ,;
//                ""        ,;
//                "SA5"     ,;
//                Recno()   })

If ValType( aFornec ) == "A"
   For I:= 1 TO Len(aFornec)
      lAdd:= .f.

      dDtHab := SelDtHabInab( aFornec[i,1], aFornec[i,2], 2 )
      If dDtHab < dDataBase .or. empty( dDtHab )
         AADD(aRet,AClone(aFornec[i]))   
      EndIf
      
   Next
Else
   aRet:= {}
EndIf

Return (aRet)


/*/================================================================================================================================/*/
/*/{Protheus.doc} SelDtHabInab
Retorna a data de Habilitacao ou Inabilitacao do Fornecedor informado, usado na Rotina para filtrar fornecedores inabilitados.

@type function
@author Wanderley Monteiro - TOTVS
@since 13/01/2012
@version P12.1.23

@param cCodFor, Caractere, Codigo do Fornecedor.
@param cLoja  , Caractere, Loja do Fornecedor.
@param nTipo  , Numérico , 1 Retorna a data de Inab / 2. data de hab.

@obs Projeto ELO

@history 07/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Data, Data de Habilitacao ou Inabilitacao.
/*/
/*/================================================================================================================================/*/

Static Function SelDtHabInab(cCodFor, cLoja, nTipo)

Local aArea := GetArea()
Local dData := CToD('')

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
If nTipo = 1
   dData := Posicione("SA2",1,xFilial("SA2")+cCodFor+cLoja,"A2_XDTINA")
ElseIf nTipo = 2
   dData := Posicione("SA2",1,xFilial("SA2")+cCodFor+cLoja,"A2_XDTHAB")
Endif

RestArea(aArea)

Return (dData)


/*/================================================================================================================================/*/
/*/{Protheus.doc} xIsForHab
Rotina para informar se um Fornecedor está bloqueado, usado na Rotina para filtrar fornecedores inabilitados.

@type function
@author Wanderley Monteiro - TOTVS
@since 13/01/2012
@version P12.1.23

@param cCodFor, Caractere, Codigo do Fornecedor.
@param cLoja  , Caractere, Loja do Fornecedor.
@param nTipo  , Numérico , 1 Retorna a data de Inab / 2. data de hab.

@obs Projeto ELO

@history 07/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Lógico, Retorna verdadeiro se Fornecedor estiver Habilitado.
/*/
/*/================================================================================================================================/*/

User Function xIsForHab(cCodFor, cLoja)

Local aArea   := GetArea()
Local lRet    := .T.
Local dDtHab  := CToD('')
Local cTit    := "Fornecedor Inabilitado"
Local cMsg    := ""  

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
dDtHab := SelDtHabInab( cCodFor, cLoja, 2 )
If dDtHab >= dDataBase
   lRet := .F.
   cMsg:= Posicione("SA2",1,xFilial("SA2")+cCodFor+cLoja,"A2_XOBSINA")
   IF EMPTY(cMSG)
      cMsg:= "Consulte o cadastro de Fornecedores.  C?igo: "+cCodFor
   ENDIF
   MsgStop(Alltrim(cMsg)+"  C?igo: "+cCodFor, cTit )
EndIf

RestArea(aArea)

Return (lRet)
