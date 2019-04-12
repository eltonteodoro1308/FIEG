#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MT120TEL
Limpar os campos de contrato quando eh feito uma copia de um pedido gerado por medicao do contrato.

@type function
@author TOTVS
@since 24/07/2012
@version P12.1.23

@obs Projeto ELO Alterado pela FIRJAN

@history 17/07/2015, Jader Berto, inclusão de rotina MT120Campo.
@history 12/08/2015, Sergio Bruno, inclusão de comentários.
@history 28/02/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

User Function MT120TEL()

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< So executa se for copia >-----------------------------
If ParamIXB[4] == 6
	For i := 1 to Len(aCols)
		If GDDeleted(i)
			Loop
		EndIf
		GDFieldPut("C7_CONTRA"," ",i)
		GDFieldPut("C7_PLANILH"," ",i)	
	Next
EndIf

U_MT120Campo(PARAMIXB[1],PARAMIXB[2],PARAMIXB[3],PARAMIXB[4])	//Incluído por Jader Berto

Return()


/*/================================================================================================================================/*/
/*/{Protheus.doc} MT120Campo
Cria getdados de campos C7_XART30 e C7_TPAQUIS.

@type function
@author Jader Berto
@since 17/07/2015
@version P12.1.23

@obs Projeto ELO Alterado pela FIRJAN

@history 12/08/2015, Sergio Bruno, inclusão de comentários.
@history 28/02/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

User Function MT120Campo(oNewDialog,aPosGet,_nOpcx,_nReg)

Local _aArea 		:= GetArea()
Local lPC_Direto 	:= .F.

Public l120Copia 	:= .F.
Public _cArt30		:= Space(TamSx3("C7_XART30")[1])
Public _cTpAquis 	:= " "
Public aItens 		:= {}

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Verifica se está na função cópia >--
If (Right(alltrim(onewdialog:CCAPTION),5) = "COPIA")
	l120Copia := .T.
EndIf

//--< Verifica se é um pedido feito sem cotação >--
If  alltrim(SC7->C7_NUMCOT) ='' .and. alltrim(SC7->C7_CODED)=''
	lPC_Direto := .T.
EndIf

	//--<"1=RPN - Processo Nucleo","2=RPU - Processo Usuario" >--
	If SC7->C7_TPAQUIS = "2"
		If altera
			aItens := {"2=RPU","1=RPN"}//Alterado a pedido do usuário por email em De: Andre Luiz Veloso de Farias [mailto:AFARIAS@firjan.org.br] Enviada em: quinta-feira, 16 de julho de 2015 12:00
		Else
			aItens := {"2=RPU"}
		EndIf	
	Else
		If altera
			aItens := {"1=RPN","2=RPU"}
		Else
			aItens := {"1=RPN"}
		EndIf	
	EndIf
	
	If inclui .or. l120Copia
		aItens := {"","1=RPN","2=RPU"}
	Else
		_cArt30 := SC7->C7_XART30 //Incluído por Sergio Bruno para evitar edição em tela em deleção e visualização
		If !Altera .and. alltrim(SC7->C7_TPAQUIS) =""
			aItens := {"","1=RPN","2=RPU"}
		EndIf	
	EndIf
	
//--< Campo Art. 30 >--
@ 044,aPosGet[1,1] SAY Alltrim(RetTitle("C7_XART30")) OF oNewDialog PIXEL SIZE 038,006
@ 043,aPosGet[1,2] COMBOBOX _cArt30 ITEMS{"N","S"} Valid If(inclui .or. altera, NAOVAZIO(),.T.) size 30,10 of oNewDialog PIXEL WHEN (Inclui .or. (Altera .and. lPc_Direto) .or. l120Copia)

//--< Tp Aquis. 30 >--
@ 044,225 SAY Alltrim(RetTitle("C7_TPAQUIS")) OF oNewDialog PIXEL SIZE 038,006
@ 043,299 COMBOBOX _cTpAquis ITEMS aItens Valid ((NAOVAZIO()) .and. U_FRJA037("SC7")) size 90,10 of oNewDialog PIXEL WHEN (Inclui .or. (Altera .and. lPc_Direto) .or. l120Copia)

RestArea(_aArea)

Return()
