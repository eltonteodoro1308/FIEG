#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MA103BUT
Adciona botão para replicar a informação do primeiro registro e das seguintes colunas abaixo, para os demais registros.

@type function
@author Thiago Rasmussen
@since 04/04/2016
@version P12.1.23

@obs Desenvolvimento FIEG

@history 26/02/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Array, Array com a lista de botão a serem adcionados.

/*/
/*/================================================================================================================================/*/

User Function MA103BUT()

	Local aButtons  := {}
	Local lVerEspIt := SuperGetMv("MV_XXITESP",.F.,.T.)

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------
	aadd(aButtons, {'Replicar Informação', {|| REPLICAR()}, 'Replicar Informação'})

	If lVerEspIt

		If Type("aCols") == "A"

			Aadd(aButtons,{"S4WB011N",  {|| StaticCall(MA140BUT,fVerEspec) }, "Especificação do produto", "Especificação do produto" })

		EndIf

	EndIf

Return aButtons

/*/================================================================================================================================/*/
/*/{Protheus.doc} REPLICAR
Replica a informação do primeiro registro e das seguintes colunas abaixo, para os demais registros.

@type function
@author Thiago Rasmussen
@since
@version P12.1.23

@obs Desenvolvimento FIEG

@history 26/02/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/
Static Function REPLICAR()

	Local nPOS_D1_TES    := ASCAN(aHeader,{|x| AllTrim(x[2]) == "D1_TES"})
	Local nPOS_D1_XDTREC := ASCAN(aHeader,{|x| AllTrim(x[2]) == "D1_XDTREC"})
	Local cD1_TES        := GDFieldGet("D1_TES",n)
	Local dD1_XDTREC     := GDFieldGet("D1_XDTREC",n)
	Local nI             := 0

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------
	cD1_TES    := GDFieldGet("D1_TES",n)
	dD1_XDTREC := GDFieldGet("D1_XDTREC",n)

	aEval(aCols,{|x| x[GDFieldPos("D1_TES")]    := cD1_TES })
	aEval(aCols,{|x| x[GDFieldPos("D1_XDTREC")] := dD1_XDTREC })

	For nI := 1 To Len(aCols)

		M->D1_TES := aCols[nI][nPOS_D1_TES]
		MaFisLoad("IT_TES","",nI)
		MaFisAlt("IT_TES",aCols[nI][nPOS_D1_TES],nI)
		MaFisToCols(aHeader,aCols,nI,"MT100")

		IF ExistTrigger("D1_TES")

			RunTrigger(2,nI,,"D1_TES")

		EndIf

		M->D1_XDTREC := aCols[nI][nPOS_D1_XDTREC]

		IF ExistTrigger("D1_XDTREC")

			RunTrigger(2,nI,,"D1_XDTREC")

		EndIf

	Next nI

Return