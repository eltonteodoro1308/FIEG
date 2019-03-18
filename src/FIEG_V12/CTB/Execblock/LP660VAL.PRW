#Include "Protheus.ch"
#Include "TopConn.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} LP660VAL
Gravar o valor liquido do documento de entrada. NF com retencao de impostos.

@type function
@author Wagner Soares
@since 01/08/2014
@version P12.1.23

@obs Desenvolvimento FIEG

@history 18/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Numérico, Valor líquido do documento de entrada.

/*/
/*/================================================================================================================================/*/

User Function LP660VAL()
	Local _nValor := 0

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------
	
	//IIF(!(SD1->D1_TIPO$"BD").AND.SF1->F1_ESPECIE<>"RP   ".AND.(!SA2->A2_XCOOP=="S") .AND. SD1->D1_XRESTPG <> "3",SF1->F1_VALBRUT,0)  --Campo Valor do LP660 antes da Alteracao
	IF (!(SD1->D1_TIPO$"BD") .AND. SF1->F1_ESPECIE<>"RP   " .AND. (!SA2->A2_XCOOP=="S")) //.AND. SD1->D1_XRESTPG <> "3")

		_nValor := SF1->F1_VALBRUT - (SF1->F1_VALIRF+SF1->F1_INSS+U_LP660ISS()+FORMULA("C01")+FORMULA("C02")+FORMULA("C03")/*+SF1->F1_VALPIS+SF1->F1_VALCOFI+SF1->F1_VALCSLL*/)

	Endif

Return(_nValor)

/*/================================================================================================================================/*/
/*/{Protheus.doc} LP660VAV
Funcao para controle de versao.

@type function
@author Thiago Rasmussen
@since 01/08/2014
@version P12.1.23

@obs Desenvolvimento FIEG

@history 18/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Caractere, Versão.

/*/
/*/================================================================================================================================/*/

User Function LP660VAV()

	Local cRet  := ""

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	cRet := "20140902001"

Return (cRet)

